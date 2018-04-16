{$M 32768,0,655360}
program TUB;
uses crt,dos,td_256,td_pcx,td_key,mousermw,sound,load;

const

Fires = 1;
ExTubs = 2;
ExCoatS = 3;
ExTvS = 4;
ExHeads = 5;
LevComS = 6;
ShipExs = 7;
TimeUpS = 8;
GameOver = 9;

GFX = 'GFX\';
AUDIO = 'AUDIO\';

{GFX = '..\GFX\';
AUDIO = '..\AUDIO\';
}
var
  Card   : DSMCard;
  Sample : array[1..9] of PDSMInst;
  Key    : Char;
  Note   : Integer;
  Chan   : Integer;
  Module : PDSM;

  Count70 : longint;

  Cm,Cs,Chund : integer;
  SoundOn : boolean;
  sn : byte;
  Nums : array[0..9] of pointer;
  Let2s, Lets : array[1..26] of pointer;
  Letsw,Letsh : array[1..26] of byte;
  Tubs : array[1..3,1..4] of pointer;
  TubW : array[1..3,1..4] of byte;
  Xplod : array[1..16] of pointer;
  Xplo : array[1..16,1..2] of word;
  Heads,CoatHangers,TVs : array[1..4] of pointer;
  Grey : array[1..4] of pointer;
  FireDelay :  byte;

  TimerDelay: Word;
  TimerIntVec : Procedure;

  Falling : array[1..144,1..4] of real;
  Fwid,FHei,FallType : array[1..144] of byte;
  NoPlayers : byte;
  Level,Lives,Scores : array[1..8]  of longint;
  HiScores : array[1..8] of string[20];
  Names : array[1..8] of string[8];
  {Round 1 globals}
  Sh,Sm,Ss,Shun : word;
  StartLevel,Life,TimeM,TimeS : word;

  Aliens : array[1..12,1..4,1..2] of word; AlienSpeed : shortint;
  Firing : boolean; FireX : word; FireY : byte;
  OldShipX,ShipX : word;
  CurrentPlayer,ShipY : byte;
  Ship : pointer;
  AnimCnt : byte; Animate : array[1..12,1..4] of byte;
  AnimBack : array[1..12,1..4] of boolean;
  DeadFlag,TimeFlag,TabFlag,ExitFlag,BigExit : boolean;
  AnInt : integer;

  ExplodeList : array[1..80,1..2] of real; {X,Y,Frame}
  Explodes : array[1..80] of byte;
  NoFalling, NoExps : byte;
  ShotList : array[1..5,1..2] of word;
  NoShots,Notubbies : byte;


{Palettes}

procedure front; external; {$l front.obj}
procedure default; external; {$l default.obj}
procedure colfont; external; {$l colfont.obj}
procedure noonoo; external; {$l noonoo.obj}

(****************************************************************************)

Procedure SPLAY(n : byte);
begin
  DSMPlaySample(Chan,Sample[n]);
  dsmpoll;
  chan:=chan+1;
  if chan=4 then chan:=0;
 end;

{$F+,S-}
procedure TimerHandler; interrupt;
begin
  Inc(TimerDelay);
  inline ($9C);
  TimerIntVec;
end;
{$F-,S+}

procedure Vretrace;
begin
  repeat
    dsmpoll;
  until TimerDelay>0;
  t2_vretrace;
  TimerDelay:=0;
end;

procedure SetNooNoo;
var L : byte; P : pointer;
begin
  P:=@noonoo;
  for L:=112 to 127 do begin
    RGBSpace[L,1]:=mem[seg(P^):Ofs(P^)+(L*3)];
    RGBSpace[L,2]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
    RGBSpace[L,3]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
  end;
  for L:=144 to 191 do begin
    RGBSpace[L,1]:=mem[seg(P^):Ofs(P^)+(L*3)];
    RGBSpace[L,2]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
    RGBSpace[L,3]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
  end;
end;

procedure ShutSound;
begin
  DSMStopMusic;
  DSMFree(Module);
  DSMDone;
end;

procedure ShutSoundFx;
begin
  DsmFreeSample(Sample[1]); DsmFreeSample(Sample[2]);
  DsmFreeSample(Sample[3]); DsmFreeSample(Sample[4]);
  DsmFreeSample(Sample[5]); DsmFreeSample(Sample[6]);
  DsmFreeSample(Sample[7]); DsmFreeSample(Sample[8]);
  DsmFreeSample(Sample[9]);
  DsmDone;
end;

procedure SetupSound;
begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Module := DSMLoad(AUDIO+'TUB.DSM',0);
  if Module = nil then begin
    case DSMStatus of
      ERR_NORAM:  writeln('Not enough system memory.');
      ERR_NODRAM: writeln('Not enough card memory.');
      ERR_NOFILE: writeln('File not found.');
      ERR_FORMAT: writeln('Invalid file format.');
      ERR_ACCESS: writeln('File damaged.');
    end;
    DSMDone;
    exit;
  end;
  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);
  DSMSetMusicVolume(255);
end;

procedure SetupSoundFX;
begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Sample[1]:=DsmLoadSample(AUDIO+'fire.wav',0);
  Sample[2]:=DsmLoadSample(AUDIO+'extub.wav',0);
  Sample[3]:=DsmLoadSample(AUDIO+'excoat.wav',0);
  Sample[4]:=DsmLoadSample(AUDIO+'extv.wav',0);
  Sample[5]:=DsmLoadSample(AUDIO+'exhead.wav',0);
  Sample[6]:=DsmLoadSample(AUDIO+'levcomp.wav',0);
  Sample[7]:=DsmLoadSample(AUDIO+'shipex.wav',0);
  Sample[8]:=DsmLoadSample(AUDIO+'timeup.wav',0);
  Sample[9]:=DsmLoadSample(AUDIO+'gameover.wav',0);
  DSMSetupVoices(4,128);
end;

procedure WriteDefaultIni;
var  F : text;
begin
  assign(F,'TUB.INI');
  rewrite(F);
  writeln(F,'P1=WES');
  writeln(F,'P2=PETE');
  writeln(F,'P3=KAY');
  writeln(F,'P4=CHRIS');
  writeln(F,'P5=DAVE');
  writeln(F,'P6=MARK');
  writeln(F,'P7=JOY');
  writeln(F,'P8=FLICKER');
  writeln(F,'SL=1');
  writeln(F,'LI=3');
  writeln(F,'NP=1');
  close(F);
end;

procedure WriteIni;
  var S : string;
      F : text;
begin
  assign(F,'TUB.INI');
  rewrite(F);
  writeln(F,'P1='+Names[1]);
  writeln(F,'P2='+Names[2]);
  writeln(F,'P3='+Names[3]);
  writeln(F,'P4='+Names[4]);
  writeln(F,'P5='+Names[5]);
  writeln(F,'P6='+Names[6]);
  writeln(F,'P7='+Names[7]);
  writeln(F,'P8='+Names[8]);
  str(StartLevel,S);writeln(F,'SL='+S);
  str(Life,S); writeln(F,'LI='+S);
  str(NoPlayers,S); writeln(F,'NP='+S);
  close(F);
end;

procedure ReadIni;
  var Code : integer; F : text;  S : string;
begin
  assign(F,'TUB.INI');
  reset(F);
  while not eof(F) do begin
    readln(F,S);
    if copy(S,1,2)='P1' then Names[1]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P2' then Names[2]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P3' then Names[3]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P4' then Names[4]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P5' then Names[5]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P6' then Names[6]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P7' then Names[7]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='P8' then Names[8]:=copy(S,4,length(S)-3)
    else if copy(S,1,2)='LI' then val(copy(S,4,length(S)-3),Life,Code)
    else if copy(S,1,2)='SL' then val(copy(S,4,length(S)-3),StartLevel,Code)
    else if copy(S,1,2)='NP' then val(copy(S,4,length(S)-3),NoPlayers,Code);
  end;
  close(F);
end;

procedure WriteCode(var F : file; S :  string);
  var L,K : byte;
      ch: char;
begin
  K:=random(255);
  ch:=chr(k);
  blockwrite(F,ch,1);
  S:=S+'!';
  for L:=1 to length(S) do begin
    ch:=chr(ord(S[l]) xor K);
    blockwrite(F,ch,1);
    K:=K+1;
    if K=255 then K:=0;
  end;
end;

procedure WriteDefaultHi;
  var F : file;
begin
  assign(F,'TUB.HI');
  rewrite(F,1);
  WriteCode(F,'wes@10000000');
  WriteCode(F,'rich@7500000');
  WriteCode(F,'matt@5000000');
  WriteCode(F,'sam@2500000');
  WriteCode(F,'tim@2000000');
  WriteCode(F,'karim@1750000');
  WriteCode(F,'jon@1500000');
  WriteCode(F,'chris@1250000');
  close(F);
end;

procedure ReadCode(var F : file; var S : string);
  var ch : char;
      L : byte;
begin
  S:='';
  blockread(F,ch,1);
  L:=ord(ch);
  repeat
    blockread(F,ch,1);
    CH:=chr(ord(ch) xor L);
    if ch<>'!' then S:=S+ch;
    L:=L+1;
    if L=255 then L:=0;
  until ch='!';
end;


procedure ReadHi;
  var F : file;
      L : byte;
begin
  assign(F,'TUB.HI');
  reset(F,1);
  for L:=1 to 8 do ReadCode(F,HiSCORES[L]);
  close(F);
end;

procedure WriteHi;
  var F : file;
      L,M : byte;
      Temp : string;
begin
  assign(F,'TUB.HI');
  rewrite(F,1);
  for L:=1 to 8 do
    WriteCode(F,HiSCORES[L]);
  close(F);
end;

procedure LoadDefaults;
  var DirInfo : SearchRec;
begin
  findfirst('TUB.INI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultIni;
  findfirst('TUB.HI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultHi;
  ReadIni;
  ReadHi;
end;

procedure ShutMeUp;
  var X,Y : byte;
begin
  SetIntVec($8,@TimerIntVec);
  for X:=1 to 3 do for Y:=1 to 4 do freemem(Tubs[X,Y],6+(TubW[X,Y]*50));
  for X:=1 to 16 do freemem(xplod[X],6+(Xplo[X,1]*Xplo[X,2]));
  for X:=1 to 26 do freemem(Lets[X],6+(LetsW[X]*LetsH[X]));
  for X:=0 to 9 do freemem(Nums[X],60);
  for X:=1 to 26 do freemem(Let2s[X],60);
  for X:=1 to 4 do freemem(Grey[X ],1076);
  for X:=1 to 4 do freemem(Heads[X],160);
  freemem(CoatHangers[1],27); freemem(CoatHangers[2],55); freemem(CoatHangers[3],48); freemem(CoatHangers[4],48);
  freemem(TVs[1],76); freemem(TVs[2],86); freemem(TVs[3],86); freemem(TVs[4],86);
  t2_end;
  textmode(co80);
  halt;
end;

procedure ZapXPlod(X1,Y1,X2,Y2,No : word);
begin
  getmem(XPlod[No],6+((1+(X2-X1))*(1+(Y2-Y1))));
  t2_getpic(X1,Y1,1+(X2-X1),1+(Y2-Y1),Xplod[No]);
  XPlo[No,1]:=(1+(X2-X1));
  XPlo[No,2]:=(1+(Y2-Y1));
end;

procedure ZapTubby(X,Y,X2,X3 : word);
begin
  getmem(Tubs[X,Y],6+(50*((X3-X2)+1)));
  t2_getpic(X2,1,1+(X3-X2),50,Tubs[X,Y]);
  TubW[X,Y]:=(X3-X2)+1;
end;

procedure ZapFont(X1,X2,Y1,Y2 : word; P : byte);
begin
  LetsW[P]:=1+(X2-X1);
  LetsH[P]:=1+(Y2-Y1);
  getmem(Lets[P],6+(LetsW[P]*LetsH[P]));
  t2_getpic(X1,Y1,(X2-X1)+1,(Y2-Y1)+1,Lets[P]);
end;

procedure SetMeUp;
  var B :byte;
begin
  GetIntVec($8,@TimerIntVec);
  SetIntVec($8,Addr(TimerHandler));
  SoundOn:=true; sn:=0;
  t2_start(1); setmousexlimits(0,608);
  NoPalette; for B:=0 to 255 do t2_setrgb(B,0,0,0);
  t2_set_buf(1); t2_block(0,0,320,200,0);
  load_pcx(GFX+'colfont.pcx');
  ZapFont(0,32,0,26,1); ZapFont(33,62,0,26,2); ZapFont(63,90,0,26,3);
  ZapFont(91,120,0,26,4); ZapFont(121,151,0,26,5); ZapFont(152,181,0,26,6);
  ZapFont(182,210,0,26,7); ZapFont(212,243,0,26,8); ZapFont(244,267,0,26,9);
  ZapFont(268,297,0,26,10); ZapFont(0,32,27,53,11); ZapFont(33,61,27,53,12);
  ZapFont(62,100,27,53,13); ZapFont(101,134,27,53,14); ZapFont(135,163,27,53,15);
  ZapFont(164,193,27,53,16); ZapFont(194,224,27,57,17); ZapFont(225,255,27,53,18);
  ZapFont(256,286,27,53,19); ZapFont(287,316,27,53,20); ZapFont(0,28,54,80,21);
  ZapFont(29,59,54,80,22); ZapFont(60,98,54,80,23); ZapFont(99,132,54,80,24);
  ZapFont(133,169,54,80,25); ZapFont(259,287,54,80,26);
  load_pcx(GFX+'gfx.pcx');
  getmem(Grey[1],1076); getmem(Grey[2],1076); getmem(Grey[3],1076); getmem(Grey[4],1076);
  t2_getpic(214,125,21,51,Grey[1]); t2_getpic(235,125,21,51,Grey[2]);
  t2_getpic(256,125,21,51,Grey[3]); t2_getpic(278,125,21,51,Grey[4]);

  ZapTubby(1,1,1,19); ZapTubby(2,1,20,40); ZapTubby(3,1,42,62);
  ZapTubby(1,2,64,83); ZapTubby(2,2,84,105); ZapTubby(3,2,106,127);
  ZapTubby(1,3,128,147); ZapTubby(2,3,148,169); ZapTubby(3,3,170,191);
  ZapTubby(1,4,192,210); ZapTubby(2,4,212,232); ZapTubby(3,4,234,254);

  ZapXplod(5,58,22,69,1); ZapXPlod(23,58,40,69,2); ZapXPlod(41,58,58,69,3);
  ZapXPlod(59,58,76,69,4); ZapXPlod(5,73,22,91,5); ZapXPlod(23,73,40,91,6);
  ZapXPlod(41,73,58,91,7); ZapXPlod(59,73,76,91,8); ZapXPlod(5,92,22,110,9);
  ZapXPlod(23,92,40,110,10); ZapXPlod(41,92,58,110,11); ZapXPlod(59,92,76,110,12);
  ZapXPlod(5,111,22,129,13); ZapXPlod(23,111,40,129,14); ZapXPlod(41,111,58,129,15);
  ZapXPlod(59,111,76,129,16);

  getmem(Ship,105); t2_getpic(78,73,11,9,Ship);
  getmem(Heads[1],160); getmem(Heads[2],160); getmem(Heads[3],160); getmem(HEads[4],160);
  t2_getpic(3,9,14,11,Heads[1]); t2_getpic(67,9,14,11,Heads[2]); t2_getpic(152,9,14,11,Heads[3]);
  t2_getpic(195,9,14,11,Heads[4]);

  getmem(CoatHangers[1],27); t2_getpic(49,1,3,7,CoatHangers[1]);
  getmem(CoatHangers[2],55); t2_getpic(71,1,7,7,CoatHangers[2]);
  getmem(CoatHangers[3],48); t2_getpic(135,1,6,7,CoatHangers[3]);
  getmem(CoatHangers[4],48); t2_getpic(201,1,6,7,CoatHangers[4]);
  getmem(TVs[1],76); t2_getpic(47,29,10,7,TVs[1]);
  getmem(TVs[2],86); t2_getpic(111,29,10,8,Tvs[2]);
  getmem(TVs[3],86); t2_getpic(175,29,10,8,Tvs[3]);
  getmem(TVs[4],86); t2_Getpic(197,29,10,8,Tvs[4]);
  for B:=0 to 9 do begin
    getmem(Nums[B],60);
    t2_getpic(80+(B*7),58,6,9,Nums[B]);
  end;
  for B:=1 to 24 do begin
    getmem(Let2s[B],60);
    t2_getpic(143+(B*7),58,6,9,Let2S[B]);
  end;
  for B:=1 to 2 do begin
    getmem(Let2s[24+B],60);
    t2_Getpic(282+(B*7),67,6,9,Let2S[B+24]);
  end;
  t2_block(0,0,320,200,0);
end;

function LitWid(S : string) : word;
  var L : byte; Wid : word;
begin
  Wid:=0;
  for L:=1 to length(S) do begin
    if (S[L]<>'I') and (S[L]<>'J') and (S[L]<>'T') and (S[L]<>'.') and (S[L]<>'Э') then inc(Wid,7)
    else if (S[L]<>'.') then inc(Wid,6)
    else inc(Wid,2);
  end;
  LitWid:=Wid;
end;

procedure Potty(X : word; Y : byte; S : string;J : byte);
  {0 = Left, 1 = Centre, 2 = Right}
  var St : word;
      L : byte;
begin
  for L:=1 to length(S) do S[L]:=upcase(S[L]);
  if (J=0) or (J=3) then St:=X;
  if (J=1) or (J=4) then St:=X-(LitWid(S) div 2);
  if (J=2) or (J=5) then St:=X-LitWid(S);
  if (J=6) then St:=X-((length(S)*7) div 2);
  for L:=1 to length(S) do begin
    if (S[L]>='A') and (S[L]<='Z')  and (J<3) then t2_putpic(St,Y,Let2s[ord(S[L])-64]);
    if (S[L]>='0') and (S[L]<='9') and (J<3) then t2_putpic(St,Y,Nums[ord(S[L])-48]);
    if (S[L]>='A') and (S[L]<='Z')  and (J>2) then t2_putbakpic(St,Y,Let2s[ord(S[L])-64]);
    if (S[L]>='0') and (S[L]<='9') and (J>2) then t2_putbakpic(St,Y,Nums[ord(S[L])-48]);
    if (S[L]='.') then begin t2_dot(St,Y+8,32); end;
    if (S[L]='Э') then begin t2_dot(St,Y+8,32); t2_dot(St+2,Y+8,32); t2_dot(St+4,Y+8,32); end;
    if (J<>6) then begin
      St:=St+6;
      if S[L]='.' then St:=St-5;
      if S[L]='Э' then dec(St);
      if (S[L]<>'T')  and (S[L]<>'I') and (S[L]<>'J') then inc(St);
    end;
    if (J=6) then St:=St+7;
  end;
end;

procedure Fadein(Steps,from,unt : byte);
var RGBChange  : array[0..255,1..3] of real;
    RGBNow     : array[0..255,1..3] of real;
    L1,L2,L3 : byte;
    tr,tb,tg : byte;
begin
  for L1:=from to unt do begin
    t2_getrgb(L1,tr,tb,tg);
    RGBNow[L1,1]:=tr;
    RGBNow[L1,2]:=tg;
    RGBNOw[L1,3]:=tb;
  end;
  for L1:=from to unt do for L2:=1 to 3 do RGBChange[L1,L2]:=(RGBSpace[L1,L2]-RGBNow[L1,L2])/Steps;
  for L3:=1 to steps do begin
    for L1:=from to unt do begin
      for L2:=1 to 3 do RGBNow[L1,L2]:=RGBNow[L1,L2]+RGBChange[L1,L2];
        t2_setrgb(L1,trunc(RGBNow[L1,1]),trunc(RGBNow[L1,2]),trunc(RGBNow[L1,3]));
      end;
    dsmpoll;
    t2_vretrace;
  end;
end;

procedure Fadeout(Steps,from,unt : byte);
var RGBChange  : array[0..255,1..3] of real;
    RGBNow     : array[0..255,1..3] of real;
    L1,L2,L3,tr,tg,tb : byte;
begin
  for L1:=from to unt do begin
    t2_getrgb(L1,tr,tg,tb);
    RGBNow[L1,1]:=tr;
    RGBNow[L1,2]:=tg;
    RGBNOw[L1,3]:=tb;
  end;

  for L1:=from to unt do for L2:=1 to 3 do RGBChange[L1,L2]:=RGBNow[L1,L2]/Steps;
  for L3:=1 to steps do begin
    for L1:=from to unt do begin
      for L2:=1 to 3 do RGBNow[L1,L2]:=RGBNow[L1,L2]-RGBChange[L1,L2];
      t2_setrgb(L1,trunc(RGBNow[L1,1]),trunc(RGBNow[L1,2]),trunc(RGBNow[L1,3]));
    end;
    dsmpoll;
    t2_vretrace;
  end;
end;

(****************************************************************************)

procedure CheckMoveShip;
  var L,L2 : byte;
begin
  dsmpoll;
  mouseinfo;
  ShipX:=(mouse.x) div 2;
  if FireDelay<4 then inc(FireDelay);
  if not mouse.left then FireDelay:=4;
  if (mouse.left) and (NoShots<=4) and (FireDelay=4) then begin
    splay(fires);
    inc(NoShots);
    ShotList[NoShots,1]:=ShipX+3;
    ShotList[NoShots,2]:=ShipY;
    FireDelay:=0;
  end;
end;

procedure CheckDroppings;
  var L,L2 :  byte;
begin
  dsmpoll;
  L:=1;
  if NoFalling>0 then repeat
    if Falling[L,1]+Falling[L,3]<2 then Falling[L,3]:=-Falling[L,3];
    if Falling[L,1]+Falling[L,3]>308 then Falling[L,3]:=-Falling[L,3];
    Falling[L,1]:=Falling[L,1]+Falling[L,3];
    Falling[L,2]:=Falling[L,2]+Falling[L,4];
    Falling[L,4]:=Falling[L,4]+0.1+(0.05*(Level[CurrentPlayer]-1));
    if (Falling[L,2]>180) then begin
      if L=NoFalling then begin
        Falling[L,1]:=400; dec(NoFalling);
      end else if L<NoFalling then begin
        for L2:=L to NoFalling-1 do begin
          Falling[L2,1]:=Falling[L2+1,1];
          Falling[L2,2]:=Falling[L2+1,2];
          Falling[L2,3]:=Falling[L2+1,3];
          Falling[L2,4]:=Falling[L2+1,4];
          FallType[L2]:=FallType[L2+1];
        end;
        dec(L); dec(NoFalling);
      end;
    end;
    inc(L);
  until L>NoFalling;
end;

procedure UnPlotDroppings;
  var L : byte;
begin
  dsmpoll;
  if NoFalling>0 then
  for L:=1 to NoFalling do begin
    if Falling[L,2]>110 then begin
      if Falling[L,2]<0 then Falling[L,2]:=0;
      if Falling[L,1]<0 then Falling[L,1]:=0;
      if Falling[L,1]>310 then Falling[L,1]:=310;
      if FallType[L]<=4 then t2_block(trunc(Falling[L,1]),trunc(Falling[L,2]),15,12,0);
      if (FallType[L]>4) and (FallType[L]<=8) then t2_block(trunc(Falling[L,1]),trunc(Falling[L,2]),15,12,0);
      if (FallType[L]>8) then t2_block(trunc(Falling[L,1]),trunc(Falling[L,2]),15,12,0);
    end;
  end;
end;

procedure PlotDroppings;
  var L : byte;
begin
  dsmpoll;
  if NoFalling>0 then
  for L:=1 to NoFalling do begin
    if FallType[L]<=4 then t2_putbakpic(trunc(Falling[L,1]),trunc(Falling[L,2]),Heads[FallType[L]]);
    if (FallType[L]>4) and (FallType[L]<=8) then
      t2_putbakpic(trunc(Falling[L,1]),trunc(Falling[L,2]),CoatHangers[FallType[L]-4]);
    if (FallType[L]>8) then t2_putbakpic(trunc(Falling[L,1]),trunc(Falling[L,2]),TVs[FallType[L]-8]);
  end;
end;

procedure PlotAliens;
  var L1,L2 : byte;
begin
  dsmpoll;
  for L2:=1 to 4 do for L1:=1 to 12 do begin
    if (Aliens[L1,L2,1]<320) then begin
      if (Animate[L1,L2]<>2) then
        t2_putbakpic(Aliens[L1,L2,1]+1,Aliens[L1,L2,2],Tubs[Animate[L1,L2],L2])
      else t2_putbakpic(Aliens[L1,L2,1],Aliens[L1,L2,2],Tubs[Animate[L1,L2],L2]);
    end;
  end;
end;

procedure PlotShot(Fx : word;Fy : byte);
begin
  dsmpoll;
  t2_dot(FX+1,fy+1,176); t2_dot(fX,fY,184);
  t2_dot(fX,fy+1,184); t2_dot(fX+2,fY,188);
  t2_dot(fX+1,fY,184); t2_dot(fX+2,fY+2,188);
  t2_dot(fX+2,fY+1,184); t2_dot(fX,fY+2,190);
  t2_dot(fX+1,fY+2,184);
end;

function CommaIse(a : String) : string;
var s : string;
    L : byte;
begin
  for l:=length(a) to 0 do begin
    if (length(a)-l) mod 3=0 then s:='.'+s;
    S:=a[l]+s;
  end;
  if s[length(s)]='.' then s:=copy(s,1,length(s)-1);
  if s[1]='.' then s:=copy(s,2,length(s)-1);
  CommaIse:=s;
end;

procedure UnPlotShot(Fx : word;Fy : byte);
begin
  dsmpoll;
  t2_dot(FX+1,fy+1,0); t2_dot(fX,fY,0);
  t2_dot(fX,fy+1,0); t2_dot(fX+2,fY,0);
  t2_dot(fX+1,fY,0); t2_dot(fX+2,fY+2,0);
  t2_dot(fX+2,fY+1,0); t2_dot(fX,fY+2,0);
  t2_dot(fX+1,fY+2,0);
end;

procedure UnPlotShip;
begin
  dsmpoll;
  t2_block(OldShipX,ShipY,12,10,0);
end;
function PlotShip : boolean;
  var C,L,Gotcha : byte;
begin
  dsmpoll;
  C:=0;
  Gotcha:=t2_getdot(ShipX,ShipY+4);
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+1,ShipY+3); inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+2,ShipY+2); inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+3,ShipY+1); inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+4,ShipY);   inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+6,ShipY);   inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+7,ShipY+1); inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+8,ShipY+2); inc(C); end;
  if Gotcha=0 then begin Gotcha:=t2_getdot(ShipX+9,ShipY+3); inc(C); end;
  t2_putpic(ShipX,ShipY,Ship);
  dsmpoll;
  plotship:=(gotcha>0);
end;

procedure Explode(A : real; B : byte);
begin
  if NoExps<80 then begin
    inc(NoExps);
    ExplodeList[NoExps,1]:=a; ExplodeList[NoExps,2]:=b-20;
    Explodes[NoExps]:=1;
  end;
end;

procedure ExplodeTub(A,B : byte);
  const TubScores : array[1..4] of byte = (163,142,109,78);
begin
  Splay(extubs);
  dec(NoTubbies);
  inc(Scores[CurrentPlayer],TubScores[b]*Level[CurrentPlayer]);
  if NoExps<80 then begin
    inc(NoExps);
    ExplodeList[NoExps,1]:=Aliens[A,B,1];
    ExplodeList[NoExps,2]:=Aliens[A,B,2]+20;
    Explodes[NoExps]:=1;

    inc(NoFalling);
    Falling[NoFalling,1]:=Aliens[A,B,1];
    Falling[NoFalling,2]:=Aliens[A,B,2]+20;
    FallType[NoFalling]:=B;
    Falling[NoFalling,3]:=random(8);
    Falling[NoFalling,3]:=Falling[NoFalling,3]-2;
    Falling[NoFalling,4]:=(random(3)-1.5)*(Level[CurrentPlayer]/3);
    FHei[NoFalling]:=11;
    FWid[NoFalling]:=14;
    inc(NoFalling);
    Falling[NoFalling,1]:=Aliens[A,B,1];
    Falling[NoFalling,2]:=Aliens[A,B,2]+20;
    FallType[NoFalling]:=B+4;
    Falling[NoFalling,3]:=random(8);
    Falling[NoFalling,3]:=Falling[NoFalling,3]-2;
    Falling[NoFalling,4]:=(random(3)-1.5)*(Level[CurrentPlayer]/3);
    if B=1 then FWid[NoFalling]:=3
    else if B=2 then FWid[NoFalling]:=6
    else if B=3 then FWid[NoFalling]:=6
    else if B=4 then FWid[NoFalling]:=5;
    FHei[NoFalling]:=8;
    inc(NoFalling);
    Falling[NoFalling,1]:=Aliens[A,B,1];
    Falling[NoFalling,2]:=Aliens[A,B,2]+20;
    FallType[NoFalling]:=B+8;
    Falling[NoFalling,3]:=random(8);
    Falling[NoFalling,3]:=Falling[NoFalling,3]-2;
    Falling[NoFalling,4]:=(random(3)-1.5)*(Level[CurrentPlayer]/3);
    FWid[NoFalling]:=10; FHei[NoFalling]:=8;
    Aliens[A,B,1]:=350;
  end;
end;

procedure PlotFire;
  var L,L2,L3,L4,Check : byte;
      Done : boolean;
  const FalScores : array[1..3] of word = (213,1747,645);
begin
  Done:=false;
  if NoShots>0 then begin
    L3:=1;
    repeat
      if L3<=NoShots then begin
        if (ShotList[L3,2]<ShipY-8) and (ShotList[L3,2]>110) then UnPlotShot(ShotList[L3,1],ShotList[L3,2]+8);
        t2_set_buf(0);
        Check:=0;
        for L4:=ShotList[L3,2] to ShotList[L3,2]+8 do
          Check:=Check or t2_getdot(ShotList[L3,1],L4);
        t2_set_buf(1);
        if (Check>0) then begin
          L2:=4; L:=1;
          repeat
            repeat
              if (ShotList[L3,2]>=Aliens[L,L2,2]+5) and (ShotList[L3,2]<=Aliens[L,L2,2]+45) and
                 (ShotList[L3,1]+1>Aliens[L,L2,1]) and (ShotList[L3,1]<Aliens[L,L2,1]+TubW[Animate[L,L2],L2]) then
              begin
                ExplodeTub(L,L2);  Done:=true;
                if L3<NoShots then begin
                  for L2:=L3 to NoShots-1 do begin
                    ShotList[L2,1]:=ShotList[L2+1,1];
                    ShotList[L2,2]:=ShotList[L2+1,2];
                  end;
                end;
                dec(NoShots); dec(L3);
              end;
              inc(L);
            until (L=13) or Done;
            L:=1;
            dec(L2);
          until (L2=0) or Done;
        end;
        {Finished Checking Tubbies - now check falling!}
        if (not Done) and (NoFalling>0) then begin
          L:=1;
          repeat
            if (ShotList[L3,1]+1>Falling[L,1]) and (ShotList[L3,1]-1<Falling[L,1]+FWid[L]) and
               (ShotList[L3,2]-2<Falling[L,2]+FHei[L]) and (ShotList[L3,2]+2>Falling[L,2]) then
            begin
              if Falling[L,2]<0 then Falling[L,2]:=0;
              if Falling[L,1]<0 then Falling[L,1]:=0;
              if Falling[L,1]>310 then Falling[L,1]:=310;
              inc(Scores[CurrentPlayer],Level[CurrentPlayer]*FalScores[((FallType[L]-1) div 4)+1]);
              if FallType[L]<5 then splay(exheads)
              else if FallType[L]<9 then splay(excoats)
              else splay(extvs);

              Explode(trunc(Falling[L,1]),trunc(Falling[L,2]));
              ShotList[L3,2]:=0;
              if L3<NoShots then begin
                for L4:=L3 to NoShots-1 do begin
                  ShotList[L4,1]:=ShotList[L4+1,1];
                  ShotList[L4,2]:=ShotList[L4+1,2];
                end;
              end;
              dec(NoShots); Done:=true; dec(L3);
              if L=NoFalling then begin
                Falling[L,1]:=400; dec(NoFalling);
              end else if L<NoFalling then begin
                for L2:=L to NoFalling-1 do begin
                  Falling[L2,1]:=Falling[L2+1,1];
                  Falling[L2,2]:=Falling[L2+1,2];
                  Falling[L2,3]:=Falling[L2+1,3];
                  Falling[L2,4]:=Falling[L2+1,4];
                  FallType[L2]:=FallType[L2+1];
                  if FallType[L]>8 then Falling[L2,4]:=Falling[L2,4]+0.2;
                end;
                dec(L); dec(NoFalling);
              end;
            end;
            inc(L);
          until (L>NoFalling) or Done;
        end;
      end;
      if L3>0 then PlotShot(ShotList[L3,1],ShotList[L3,2]);
      inc(L3); Done:=false;
    until L3>NoShots;
  end;
end;

procedure CheckTubs;
  var L,L2,Y1 : byte; X1 :  word;
begin
  inc(AnimCnt);
  if AnimCnt=5 then begin
    AnimCnt:=0;
    for L:=1 to 12 do begin
      for L2:=1 to 4 do begin
        if AnimBack[L,L2] then dec(Animate[L,L2]);
        if not AnimBack[L,L2] then inc(Animate[L,L2]);
        if Animate[L,L2]<>2 then AnimBack[L,L2]:=not AnimBack[L,L2];
      end;
    end;
  end;
  if NoExps>0 then begin
    for L:=1 to NoExps do begin
      Explodes[L]:=Explodes[L]+1;
      if (Explodes[L]=17) then begin
        if (ExplodeList[L,2]>85) then begin
          X1:=trunc(ExplodeList[L,1]+10)-(Xplo[16,1] div 2);
          Y1:=trunc(ExplodeList[L,2]+25)-(Xplo[16,2] div 2);
          if X1+Xplo[16,1]>319 then  X1:=319-Xplo[16,1];
          if X1<0 then X1:=0;
          if Y1+Xplo[16,2]>199 then Y1:=199-XPlo[16,2];
          if Y1<0 then Y1:=0;
          t2_block(X1,Y1,Xplo[16,1]+1,Xplo[16,2]+1,0);
        end;
        if L<NoExps then begin
          for L2:=L to NoExps do begin
            ExplodeList[L2,1]:=ExplodeList[L2+1,1];
            ExplodeList[L2,2]:=ExplodeList[L2+1,2];
            Explodes[L2]:=Explodes[L2+1];
          end;
        end;
        dec(NoExps);
      end;
    end;
  end;
end;

procedure PlotExplosions;
  var L,L2 : byte; X1,Y1: real;
begin
  if NoExps>0 then begin
    for L2:=1 to NoExps do begin
      X1:=(ExplodeList[L2,1]+10)-(Xplo[Explodes[L2],1] div 2);
      Y1:=(ExplodeList[L2,2]+25)-(Xplo[Explodes[L2],2] div 2);
      if X1+Xplo[16,1]>319 then  X1:=319-Xplo[16,1];
      if X1<0 then X1:=0;
      if Y1+Xplo[16,2]>199 then Y1:=199-XPlo[16,2];
      if Y1<0 then Y1:=0;
      t2_putbakpic(trunc(X1),trunc(Y1),Xplod[Explodes[L2]]);
      dsmpoll;
    end;
  end;
end;

procedure CheckShots;
  var L,L2 : byte;
begin
  dsmpoll;
  if NoShots>0 then begin
    for L:=1 to NoShots do begin
      dec(ShotList[L,2],8);
      if ShotList[L,2]<5 then begin
        ShotList[L,2]:=0;
        if L<NoShots then begin
          for L2:=L to NoShots-1 do begin
            ShotList[L2,1]:=ShotList[L2+1,1];
            ShotList[L2,2]:=ShotList[L2+1,2];
          end;
        end;
        dec(NoShots);
      end;
    end;
  end;
end;

function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then s := '0' + s;
  LeadingZero := s;
end;

procedure PlotRScore(S : string; X : word; Y : byte; Over : boolean);
  var Q,L,V : word;
      Code : integer;
begin
  dsmpoll;
  Q:=0;
  for L:=length(S) downto 1 do begin
    val(S[L],V,Code);
    X:=X-5; if not Over then t2_putpic(X,Y,Nums[V]);
    if Over then t2_putbakpic(X,Y,Nums[V]);
    X:=X-2;
    inc(Q);
    if (Q=3) and (L>1) then begin
      if Over=false then t2_block(X-1,186,3,9,0);
      t2_line(X,Y+7,X,Y+9,32);
      X:=X-2;
      Q:=0;
    end;
  end;
end;

procedure ShowHiScores;
  var L : byte;
begin
  Potty(200,20,'TUBBY HALL OF FAME',4);
  for L:=1 to 8 do begin
    Potty(175,35+(L*11),copy(HiScores[L],1,pos('@',HiScores[L])-1),5);
    PlotRScore(copy(HiScores[L],pos('@',HiScores[L])+1,length(Hiscores[L])),252,35+(L*11),true);
  end;
end;

Procedure StoryLine;
begin
  t2_set_buf(0);
  Potty(270,20,'OVER THE HILLS AND FAR AWAY',5);
  Potty(270,31,'THE TUBBIES ARE LOOSE AGAIN',5);
  Potty(270,42,'AND ARE GIBBERING INSANELY',5);
  Potty(270,53,'TO ANY INNOCENT PASSERS BY',5);
  Potty(270,64,'CAUSING INSTANT BRAIN DEATH.',5);
  Potty(270,75,'YOUR JOB IS TO BLAST THEM',5);
  Potty(270,86,'OUT OF EXISTENCE BEFORE',5);
  Potty(270,97,'YOU GO INSANE YOURSELF.',5);
  Potty(270,108,'USE THE MOUSE TO AIM AND',5);
  Potty(270,119,'FIRE YOUR MISSILES.',5);
end;

procedure UpDateScore;
  var S,T : string[30];
      H,M,Se,Hund,X : word;
      Fh,Fm,Fs,FHun : word;
      L,V,Q : byte; Code : integer;
      SinceMid,SinceMid2 : longint;
      Gone : longint;

begin
  t2_setrgb(0,0,0,0);
  str(Scores[CurrentPlayer],S); PlotRScore(S,318,186,false);
  {First calculate elapsed time since start}
  if (NoTubbies>0) and (not TimeFlag) then begin
    GetTime(h,m,se,hund);
    Fh:=sh; Fm:=Sm; Fs:=Ss; FHun:=Shun;
    if hunD>=Fhun then chund:=hund-fHUN
    else begin 
      chund:=(hund+100)-fhun; inc(Fs);
      if Fs>59 then begin 
        Fs:=0; inc(Fm);
        if Fm>59 then begin
          Fm:=0; inc(Fh);
          if Fh>23 then Fh:=0; 
        end; 
      end; 
    end;
    if SE>=FS then Cs:=SE-FS
    else begin 
      Cs:=(SE+60)-FS; inc(Fm);
      if Fm>59 then begin 
        Fm:=0; inc(Fh);
        if Fh>23 then Fh:=0; 
      end; 
    end;
    if M>=Fm then Cm:=M-Fm
    else begin 
      Cm:=(m+60)-Fm; 
      inc(Fh); 
      if Fh>23 then Fh:=0;  
    end;

    Hund:=Chund; Se:=Cs; M:=Cm;
    {Now calculate difference between Change, and Target}
    Chund:=100-Hund; inc(Cs); if Cs>59 then begin Cs:=0; inc(Cm); end;

    if Se<=TimeS then Cs:=TimeS-Se
    else begin 
      Cs:=(Times+60)-se; inc(m); 
    end;
    Cm:=TimeM-m;
    if (Chund<=5) and (cs<=0) and (cm<=0) then begin
      TimeFlag:=true;
      Chund:=0; Cs:=0; Cm:=0;
    end;
  end;
  t2_putpic(0,186,Nums[CM]);
  str(Level[CurrentPlayer],T);
  Potty(70,186,'LEVEL '+T,0);
  str(Lives[CurrentPlayer],T);
  Potty(200,186,'CELLS '+T,0);
  if Chund>50 then begin t2_line(7,188,7,189,32); t2_line(7,191,7,192,32); end;
  if Chund<50 then begin t2_line(7,188,7,189,0); t2_line(7,191,7,192,0); end;
  S:=LeadingZero(CS); val(S[1],V,Code);
  t2_putpic(9,186,Nums[V]); val(S[2],V,Code); t2_putpic(16,186,Nums[V]);
  t2_dot(23,192,32); S:=LeadingZero(CHund); val(S[1],V,Code);
  t2_putpic(25,186,Nums[V]); val(S[2],V,Code); t2_putpic(32,186,Nums[V]);
  Potty(160,186,Names[CurrentPlayer],1);
end;

procedure DoBanner;
  var Wid : word;
      L,M : byte;
      Select : word;
      Done : array[1..8] of boolean;
      S : array[1..8] of string;
      Temp,Lev : string;
      Ch : Char;
  const Cols : array[1..80] of byte =
  (72,73,74,75,76,72,73,74,75,76,157,158,159,127,126,157,159,158,126,127,
   190,107,179,107,187,179,107,187,190,107,176,216,204,219,233,216,176,233,219,204,
   144,163,146,180,164,146,163,180,164,144,227,222,138,161,192,222,161,227,138,192,
   239,222,246,241,247,222,245,240,248,244,8,11,7,13,9,12,10,14,9,7);
begin
  for L:=1 to 8 do Done[L]:=false;
  t2_set_buf(0);
  t2_block(0,0,320,200,0);
  pointpalarr(@colfont); Wid:=0;
  for l:=1 to length(Names[CurrentPlayer]) do
    Wid:=Wid+LetsW[ord(Names[CurrentPlayer][L])-64];
  Wid:=160-(Wid div 2);
  for l:=1 to length(Names[CurrentPlayer]) do begin
    t2_putpic(Wid,10,Lets[ord(Names[CurrentPlayer][L])-64]);
    Wid:=Wid+LetsW[ord(Names[CurrentPlayer][L])-64];
  end;
  str(Level[CurrentPlayer],Lev);
  potty(160,45,'GET READY ... CLICK TO ENTER',1);

  Potty(160,70,'  NAME        SCORE     LEVEL   CELLS  ',6);
  for L:=1 to NoPlayers do begin
    S[L]:='';
    for M:=1 to 12-length(Names[L]) do
      S[L]:=S[L]+' ';
    S[L]:=S[L]+Names[L];
    S[L]:=S[L]+'    ';
    str(Scores[L],Temp);
    if length(Temp)<9 then
      for M:=1 to 9-length(Temp) do
        S[L]:=S[L]+'0';
    S[L]:=S[L]+Temp+'    '; str(Level[L],Temp);
    if Level[L]<10 then S[L]:=S[L]+'0';
    S[L]:=S[L]+Temp; S[L]:=S[L]+'        ';
    str(Lives[L],Temp); S[L]:=S[L]+Temp+'  ';
  end;
  for L:=1 to NoPlayers do begin
    M:=0;
    Select:=0;
    repeat
      inc(Select);
    until not Done[Select];
    for M:=1 to NoPlayers do
      if (Scores[M]>Scores[Select]) and (not Done[M]) then Select:=M;
    Done[Select]:=true;
    Potty(144,80+(10*L),S[Select],6);
    for M:=80+(10*L) to 89+(10*L) do begin
      for Select:=0 to 319 do
      if t2_getdot(Select,M)<>0 then t2_dot(Select,M,Cols[M-89]);
    end;
  end;

  fadein(30,0,255);
  repeat mouseinfo;
    if keypressed then repeat until readkey<>'';
  until not (mouse.left or keypressed);
  repeat
    mouseinfo;
  until mouse.left or keypressed;
  ch:=chr(0);
  if keypressed then ch:=readkey;
  if ch=chr(27) then BigExit:=true;
  repeat
    if keypressed then repeat until readkey<>'';
  until not keypressed;
  fadeout(30,0,255);
end;

function BigWid(S : string) : word;
  var L : byte;
      Wid : word;
begin
  Wid:=0;
  for L:=1 to length(S) do begin
    if (S[L]>='A') and (S[L]<='Z') then inc(Wid,Letsw[ord(S[L])-64])
    else inc(Wid,15);
  end;
  bIGwID:=wID;
end;

procedure BigPot(X : word; Y : byte; S : string; J : byte);
  var St : word;
      L : byte;
begin
  if J=0 then St:=X;
  if J=1 then St:=X-(BigWid(S) div 2);
  if J=2 then St:=X-(BigWid(S));
  for l:=1 to length(S) do begin
    IF S[L]<>' ' then t2_putpic(St,Y,Lets[ord(S[L])-64]);
    St:=St+BigWid(S[L]) ;
  end;
end;

procedure StartInterrupt;
begin
  SetupSoundFx;
end;

procedure ShutInterrupt;
begin
  ShutSoundFx;
end;

procedure FrontPage;
  var B : byte;
      ch  :  char;
      P,P6,P7 : pointer;
      PQ : array[2..5] of pointer;
      DealWith : string[2];
      Tuba : array[1..3,1..2] of integer; {3 Tubbies, Colour and Y Position}
      Tubsy,NewTub,Next,Tp,YSize,Total,LineNo,LetNo,Cycles,Phase: byte;
      ShowingHi,StoryLi : boolean;
      Flop :  boolean;
      UpTo : shortint;

const    SCROLLText : array[1..10] of string =
  ('ЭЭЭ WCT ENTERTAINMENT PRESENTS ЭЭЭЭЭЭЭ THE UNOFFICIAL FINAL RELEASE OF ЭЭЭЭЭ',
  ' SHOOTING CHEDDERY 6 ЭЭЭЭЭ SHOOTING TELETUBBERY ЭЭЭЭЭ DESIGNЭCODEЭMUSIC BY WES ЭЭЭЭЭЭ ',
   '256 COLOUR SUPPORT BY TOM ЭЭЭЭЭЭ ADDITIONAL GRAPHICS BY RICH ЭЭЭЭЭЭ BETA TESTERS ЭЭЭ ',
   'WES Э RICH Э SAM Э MATT Э TIM Э KARIM Э CHRIS Э DAVE Э FRANS Э JON Э GILLIAN Э JAMES Э SARAH Э ANDI ЭЭЭЭ COPYRIGHT 1998 ',
   'WCT ENTERTAINMENT ЭЭЭЭЭЭ OVER THE HILLS AND FAR AWAYЭЭ THE TUBBIES ARE LOOSE AGAIN',
  ' AND ARE GIBBERING INSANELY TO ANY INNOCENT PASSERS BY CAUSING INSTANT BRAIN ',
   'DEATH ЭЭЭЭЭ YOUR JOB IS TO BLAST THEM SILLY WITH YOUR PORTABLE MISSILE LAUNCHER ЭЭЭЭЭ',
  ' DEBRIS WILL FALL ON YOU AS THEY PERISH ЭЭЭ THIS DEBRIS ALONE HAS BEEN EXPOSED TO ',
   'SO MUCH TUBBY DRIVVEL THAT IT WILL KILL YOUR BRAIN CELLS IF IT TOUCHES YOU ',
   'SO YOU MUST ALSO BLOW THAT UP OR AVOID IT ЭЭЭЭЭ GOOD LUCK ЭЭЭЭЭњњ');

begin
  repeat
    mouseinfo; 
    if keypressed then repeat until readkey<>''; 
  until not mouse.left and not keypressed;
  LoadDefaults;
  setupsound;
  getmem(P6,1500);
  NewTub:=2; Tubsy:=0; ShowingHi:=false;  StoryLi:=false;
  Next:=1;
  Tuba[1,1]:=250; Tuba[1,2]:=1;
  Tuba[2,1]:=250; Tuba[3,1]:=250;
  YSize:=0; Flop:=false; Cycles:=248; Tp:=2; Phase:=1;
  NoPalette;
  t2_set_buf(0); for B:=0 to 255 do t2_setrgb(B,0,0,0);
  load_pcx(gfx+'front.pcx'); PointPalArr(@front);
  getmem(PQ[2],12766); getmem(PQ[3],12766); getmem(PQ[4],12766); getmem(PQ[5],12766);
  t2_set_buf(1); t2_block(0,0,320,200,0);
  BigPot(160,160,'H  HISCORES',1);
  t2_getpic(0,160,319,39,PQ[2]);
  t2_block(0,160,319,199,0);
  BigPot(160,160,'S  STORY',1);
  t2_getpic(0,160,319,39,PQ[3]);
  t2_block(0,160,319,199,0);
  BigPot(160,160,'ESC  QUIT',1);
  t2_getpic(0,160,319,39,PQ[4]);
  t2_block(0,160,319,199,0);
  BigPot(160,160,'WCT  GAMES',1);
  t2_getpic(0,160,319,39,PQ[5]);
  t2_block(0,160,319,199,0);
  Fadein(30,0,255);
  t2_set_buf(0); getmem(P7, 25836); {210*103} dsmpoll; t2_getpic(70,20,210,123,P7);
  LetNo:=1; LineNo:=1;
  t2_setrgb(32,63,0,0); getmem(P,3188); dsmpoll;
  t2_set_buf(1); t2_Block(0,0,20,10,0);
  t2_putpic(0,125,Grey[1]); t2_putpic(30,125,Grey[2]); t2_putpic(60,125,Grey[3]); t2_putpic(90,125,Grey[4]);
  DealWith:=copy(ScrollText[1],1,2);
  Total:=LitWid(DealWith); dsmpoll;
  Potty(0,0,DealWith,0);
  Upto:=0;
  {Title Page Loop}

  repeat 
    repeat
      dsmpoll;
      mouseinfo;
      if Upto>=Total-2 then begin
        dec(UpTo,LitWid(DealWith[1]));
        DealWith[1]:=DealWith[2];
        t2_set_buf(1); t2_block(0,0,20,10,0);
        inc(LetNo);
        if LetNo>length(ScrollText[LineNo]) then begin LetNo:=1; inc(LineNo); end;
        if ScrollText[LineNo][LetNo]='њ' then begin LineNo:=1; LetNo:=1; end;
        if (LetNo<length(ScrollText[LineNo]))  and (ScrollText[LineNo][LetNo+1]='њ') then begin LineNo:=1; LetNo:=1; end;
        dealwith[2]:=ScrollText[LineNo][LetNo];
        Potty(0,0,DealWith,0);
        total:=litwid(DealWith);
      end;
      dsmpoll;
      t2_set_buf(0); t2_getpic(2,0,318,10,P); t2_putpic(0,0,P);
      t2_set_buf(1); t2_getpic(UpTo,0,2,10,P);
      t2_set_buf(0); t2_putpic(318,0,P);
      inc(UpTo,2);
      if (tubsy<45) then inc(tubsy);
      if (tubsy=45) then begin
        if Tuba[Next,1]>45 then begin
          Tubsy:=0; Tuba[Next,2]:=NewTub; Tuba[Next,1]:=170; NewTub:=NewTub+1; if NewTub=5 then NewTub:=1;
          Next:=Next+1; if Next=4 then Next:=1;
        end;
      end;
      if (cycles<250) then inc(cycles);
      dsmpoll;
      if (cycles>=250) then begin
        if (Phase=4) then begin
          if YSize>1 then dec(YSize);
          t2_set_scale_size(319,YSize);
          t2_scale_pic(0,174+(26-YSize),PQ[Tp]);
          t2_line(0,172+(26-YSize),319,172+(26-YSize),0);
          if YSize=1 then begin
            YSize:=0; t2_block(0,173,319,26,0); inc(tp); if tp=6 then tp:=2;
            Phase:=1;
          end;
        end;
        if (Phase=3) then begin
          if YSize<26 then inc(YSize);
          t2_set_scale_size(319,YSize);
          t2_scale_pic(0,173,PQ[Tp]);
          if YSize>=26 then begin Phase:=4; Cycles:=0; YSize:=26; end;
        end;

        if (Phase=2) then begin
          if YSize>1 then dec(YSize);
          t2_set_scale_size(319,YSize);
          t2_scale_pic(0,173,PQ[Tp]);
          t2_line(0,YSize+173,319,YSize+173,0);
          if YSize=1 then begin YSize:=0; t2_block(0,173,319,26,0); inc(tp); if tp=6 then tp:=2;
            Phase:=3; 
          end;
        end;
        dsmpoll;
        if (Phase=1) then begin
          if YSize<26 then inc(YSize);
          t2_set_scale_size(319,YSize);
          t2_scale_pic(0,199-YSize,PQ[Tp]);
          if YSize>=26 then begin Phase:=2; Cycles:=0; YSize:=26; end;
        end;
      end;
      for B:=1 to 3 do begin
        if (Tuba[B,1]<=170) and (tuba[B,1]>-35) then begin
          if (tuba[B,1]<120) and (Tuba[B,1]>=15) then begin
            t2_putpic(6,Tuba[B,1],Grey[Tuba[B,2]]); t2_putpic(292,Tuba[B,1],Grey[Tuba[B,2]]);
            t2_block(6,Tuba[B,1]+50,21,2,0); t2_block(292,Tuba[B,1]+50,21,2,0);
          end;
          if (tuba[B,1]<15) and (tuba[B,1]>-37) then begin
            t2_set_buf(1);
            if tuba[B,2]=1 then t2_getpic(0,125+(16-Tuba[B,1]),21,(53+(Tuba[B,1]-15)),P6)
            else if tuba[B,2]=2 then t2_getpic(30,125+(16-Tuba[B,1]),21,(53+(Tuba[B,1]-15)),P6)
            else if tuba[B,2]=3 then t2_getpic(60,125+(16-Tuba[B,1]),21,(53+(Tuba[B,1]-15)),P6)
            else if tuba[B,2]=4 then t2_getpic(90,125+(16-Tuba[B,1]),21,(53+(Tuba[B,1]-15)),P6);
            t2_set_buf(0); t2_putpic(6,15,P6); t2_putpic(292,15,P6);
          end;
          if (tuba[B,1]>=120) then begin
            t2_set_buf(1);
            if tuba[B,2]=1 then t2_getpic(0,125,21,173-Tuba[B,1],P6)
            else if tuba[B,2]=2 then t2_getpic(30,125,21,173-Tuba[B,1],P6)
            else if tuba[B,2]=3 then t2_getpic(60,125,21,173-Tuba[B,1],P6)
            else if tuba[B,2]=4 then t2_getpic(90,125,21,173-Tuba[B,1],P6);
            t2_set_buf(0); t2_putpic(6,tuba[B,1],P6); t2_putpic(292,tuba[B,1],P6);
          end;
          dec(Tuba[B,1],2);
          if (Tuba[B,1]<-35) then begin Tuba[B,1]:=240; end;
        end;
        dsmpoll;
        t2_block(6,170,21,4,0); t2_block(6,12,21,4,0);
        t2_block(292,170,21,4,0); t2_block(292,12,21,4,0);
      end;
      dsmpoll;
      t2_Vretrace;
    until mouse.left or keypressed;
    if keypressed then ch:=upcase(readkey);
    if ch='H' then begin StoryLi:=false; t2_putpic(70,20,P7); ShowingHi:=not ShowingHi; if ShowingHi then ShowHiScores; end;
    if ch='S' then begin ShowingHi:=false; t2_putpic(70,20,P7); StoryLi:=not StoryLi; if StoryLi then StoryLine; end;

    if ch=chr(27) then begin shutsound; fadeout(20,0,255); shutmeup; end;
  until (ch<>'H') and (ch<>'S') and (ch<>chr(27)) or mouse.left;
  repeat if keypressed then repeat until readkey<>''; until not keypressed;

  ShutSound;
  freemem(PQ[2],12766); freemem(PQ[3],12766); freemem(P,3188);
  Fadeout(30,0,255); freemem(PQ[4],12766); freemem(PQ[5],12766);
  freemem(P7, 25836); freemem(P6,1500);

end;

function ScConv(S : string) : longint;
  var Code : integer;
      Temp : longint;
begin
  val(copy(S,pos('@',S)+1,length(S)-pos('@',S)),Temp,Code);
  ScConv:=Temp;
end;

procedure CheckHiScores(M : byte);
var NewPlaces : Array[1..8] of byte;
    ExitFlag : boolean;
    L,J,K : Byte;
    S : string[25];
begin
  for L:=1 to 8 do NewPlaces[L]:=0;
  for L:=1 to M do begin
    if Scores[L]>ScConv(HiScores[8]) then begin
      J:=8;
      repeat
        if Scores[L]>ScConv(HiScores[J]) then dec(J);
        ExitFlag:=false;
        if J=0 then ExitFlag:=true;
        if J>0 then if (Scores[L]<=ScConv(HiScores[J])) then ExitFlag:=true;
      until ExitFlag;
      inc(J);
      if J=8 then begin NewPlaces[8]:=L; str(Scores[L],HiScores[8]); end;
      if J<8 then begin
        for K:=8 downto J+1 do begin
          HiScores[K]:=HiScores[K-1];
          NewPlaces[K]:=NewPlaces[K-1];
        end;
        NewPlaces[J]:=L; str(Scores[L],HiScores[J]);
      end;
    end;
  end;
  for L:=1 to 8 do
  if NewPlaces[L]<>0 then begin
    S:=Names[NewPlaces[L]];
    HiScores[L]:=S+'@'+HiScores[L];
  end;
  WriteHi;
end;

procedure Round;
  var L,L2 : byte;
      ch : char;
      Wid : word;
      Vwtog : byte;
      S : string;

  const Score100 : array[1..16] of word = (23,47,84,159,275,482,761,1357,2315,3478,7529,13572,19235,32958,46597,53824);
        WaitFor  : array[1..16] of word = (150,130,110,90,70,50,30,1,1,1,1,1,1,1,1,1);
begin
  if Level[CurrentPlayer]=1 then begin TimeM:=1; TimeS:=30; end
  else if Level[CurrentPlayer]=2 then begin TimeM:=1; TimeS:=20; end
  else if Level[CurrentPlayer]=3 then begin TimeM:=1; TimeS:=10; end
  else if Level[CurrentPlayer]=4 then begin TimeM:=1; TimeS:=0; end
  else if Level[CurrentPlayer]=5 then begin TimeM:=0; TimeS:=50; end
  else if Level[CurrentPlayer]=6 then begin TimeM:=0; TimeS:=40; end
  else if Level[CurrentPlayer]=7 then begin TimeM:=0; TimeS:=30; end
  else if Level[CurrentPlayer]=8 then begin TimeM:=0; TimeS:=25; end
  else if Level[CurrentPlayer]>8 then begin TimeM:=0; TimeS:=20; end;
  t2_set_buf(0); t2_block(0,0,320,200,0);
  NoTubbies:=48; TabFlag:=false;
  for L:=1 to 12 do begin
    Aliens[L,1,1]:=((L-1)*25)+12; Aliens[L,1,2]:=0;
    Aliens[L,2,1]:=((L-1)*25); Aliens[L,2,2]:=20;
    Aliens[L,3,1]:=((L-1)*25)+12; Aliens[L,3,2]:=40;
    Aliens[L,4,1]:=((L-1)*25); Aliens[L,4,2]:=60;
  end;
  randomize;
  for L:=1 to 12 do for L2:=1 to 4 do begin
    if random(100)<30 then Animate[L,L2]:=1
    else if random(100)<30 then Animate[L,L2]:=2
    else Animate[L,L2]:=3;
    AnimBack[L,L2]:=false;
    if Animate[L,L2]=3 then AnimBack[l,l2]:=true;
  end;
  AnimCnt:=0;
  OldShipX:=154; ShipX:=155;
  setmouseposition(320,170);
  NoExps:=0; NoShots:=0; NoFalling:=0;
  GetTime(Sh,Sm,Ss,Shun);

  PointPalArr(@default);
  PlotAliens; t2_copy(0,0,200);
  Fadein(40,0,255);

    (********* Game loop **********)
  repeat
    dsmpoll;
    OldShipX:=ShipX;
    t2_set_buf(1); t2_block(0,0,320,122,0);
    ExitFlag:=false;
    if not DeadFlag then CheckMoveShip;   {move ship, set off shots}
    CheckShots;       {move shots, check for collisions, deal with tub bursts}
    CheckTubs;       {move/animate tubs, includes explosion handling}
    CheckDroppings;  {move droppings, check if they blow the ship up}
    UpDateScore;     {Update the scoring stufF}

    if not DeadFlag then UnPlotShip;
    PlotFire;
    t2_block(0,ShipY,319,4,0);
    PlotExplosions;
    PlotAliens;
    PlotDroppings;
    if not DeadFlag then begin
      DeadFlag:=PlotShip;
      if DeadFlag then begin
        UnplotShip;
        splay(shipexs);
        if ShipX>2 then Explode(ShipX-2,ShipY)
        else Explode(0,ShipY);
      end;
    end;
    dsmpoll;
    t2_copy(0,0,200);
    t2_set_buf(1);
    UnPlotDroppings;
    UpdateScore;
    vretrace;

    if TK_KP[1] then BigExit:=true;
    if (NoTubbies=0) and (NoFalling=0) and (NoExps=0) then ExitFlag:=true;
    if (DeadFlag) and (NoFalling=0) and (NoExps=0) then ExitFlag:=true;
    if (TimeFlag) then begin
      splay(timeups);
      ExitFlag:=true;
    end;
  until ExitFlag or BigExit;
  tk_end;
  UpdateScore;
  if not (DeadFlag or TimeFlag or BigExit) then splay(levcoms);
  if TimeFlag then begin chund:=0; UpdateScore; fadeout(120,0,255); end
  else if DeadFlag then fadeout(60,0,255)
  else if BigExit then fadeout(60,0,255)
  else begin
    vwtog:=0;
    {Level Complete!}
    chund:=100;
    if (cs=0) and (cm=0) then inc(Scores[CurrentPlayer],chund*Score100[Level[CurrentPlayer]]);
    UpdateScore;
    if (chund>0) or (cs>0) or (cm>0) then repeat
      t2_set_buf(0);
      dsmpoll;
      if Level[CurrentPlayer]<=16 then inc(Scores[CurrentPlayer],5*Score100[Level[CurrentPlayer]])
      else inc(Scores[CurrentPlayer],5*Score100[16]);
      UpdateScore;
      dec(chund,5);
      inc(Vwtog);
      if chund<0 then begin
        chund:=100;
        dec(cs);
        if cs<0 then begin
          cs:=60;
          dec(cm);
          if cm<0 then begin
            chund:=0; cs:=0; cm:=0;
          end;
        end;
      end;
      UpdateScore;
      if vwtog>=WaitFor[Level[CurrentPlayer]] then begin vwtog:=0; t2_vretrace; end;
    until (chund=0) and (cm=0) and (cs=0);
    fadeout(50,0,255);
  end;
  if not BigExit then begin
    if (DeadFlag or TimeFlag) then dec(Lives[CurrentPlayer])
    else inc(Level[CurrentPlayer]);
    if Lives[CurrentPlayer]=0 then begin
      t2_set_buf(0);
      t2_block(0,0,320,200,0);
      PointPalArr(@colfont);
      BigPot(160,40,'GAME OVER',1);
      BigPot(160,100,Names[CurrentPlayer],1);
      str(Scores[CurrentPlayer],S);
      Potty(120,160,'SCORE ... ',0);
      splay(gameover);
      PlotRScore(S,190+LitWid(S),160,false);
      fadein(50,0,255);
      repeat
        mouseinfo;
        dsmpoll;
      until not mouse.left and not keypressed;
      repeat
        dsmpoll;
        mouseinfo;
      until mouse.left or keypressed;
      repeat
        dsmpoll;
        if keypressed then repeat until readkey<>'';
      until not keypressed;
      fadeout(60,0,255);
    end;
    ExitFlag:=false; TimeFlag:=false; DeadFlag:=false;
  end;
  shutinterrupt;
end;

Procedure Game;
  var L :  byte;
begin
  Chan:=1;
  BigExit:=false;
  LoadDefaults;
  ShipX:=155; ShipY:=170;
  for L:=1 to NoPlayers do begin
    Level[L]:=StartLevel;
    Lives[L]:=Life;
     Scores[L]:=0;
  end;
  repeat
    L:=0;
    for CurrentPlayer:=1 to NoPlayers do begin
      t2_set_buf(0); t2_block(0,0,320,200,0);
      t2_set_buf(1); t2_block(0,0,320,200,0);
      if Lives[CurrentPlayer]>0 then begin
        if not BigExit then DoBanner;
        if not BigExit then begin
          tk_start;
          startinterrupt;
          Round;
        end;
      end;
      L:=L+Lives[CurrentPlayer];
    end;
  until (L=0) or (BigExit);
  if not BigExit then CheckHiScores(NoPlayers);
end;

procedure PlotNames(P : pointer);
  var L : byte; S : string;
begin
  for L:=1 to 8 do begin
    if NoPlayers>=L then begin
      if L mod 2=1 then begin
        t2_block(93,40+(((L+1) div 2)*16),60,10,0);
        potty(93,40+(((L+1) div 2)*16),Names[L],0); str(L,S);
        potty(60,40+(((L+1) div 2)*16),'PLAYER '+S,2);
        t2_putpic(64,(38+((L+1) div 2)*16),P);
      end;
      if L mod 2=0 then begin
        t2_block(253,40+(((L+1) div 2)*16),60,10,0);
        potty(253,40+(((L+1) div 2)*16),Names[L],0); str(L,s);
        potty(220,40+(((L+1) div 2)*16),'PLAYER '+S,2);
        t2_putpic(224,(38+((L+1) div 2)*16),P);
      end;
    end;
    if (NoPlayers<L) and (L mod 2=0) then t2_block(164,(38+((L+1) div 2)*16),150,16,0);
    if (NoPlayers<L) and (L mod 2=1) then t2_block(0,(38+((L+1) div 2)*16),150,16,0);
  end;
end;

function mousein(X1,Y1,X2,Y2 : word) : boolean;
  var X,Y : word;
begin
  X:=mouse.x div 2;
  Y:=mouse.y;
  mousein:=((X>=X1) and (X<=X2) and (Y>=Y1) and  (Y<=Y2));
end;

procedure Nedit(Nm : byte);
  var ch : char;
      OldSt : string;
begin
  OldSt:=Names[Nm];
  Potty(100,150,'EDIT ME',1);
  repeat
    t2_block(60,170,130,10,0);
    Potty(60,170,Names[Nm],0);
    repeat until keypressed;
    ch:=upcase(readkey);
    if (ch>='A') and (ch<='Z') and (length(Names[Nm])<8) then Names[Nm]:=Names[Nm]+ch;
    if ch=chr(27) then Names[Nm]:=OldSt;
    if (ch=chr(8)) and (length(Names[Nm])>0) then Names[Nm]:=copy(Names[Nm],1,length(Names[Nm])-1);
  until (ch=chr(13)) or (ch=chr(27));
  t2_block(60,170,130,10,0); t2_block(50,150,100,10,0);
end;

procedure OptionPage;
  var P,P2,P3,P4,P5,P6 : pointer;
      S : string[1];
      ch : char;
begin
  LoadDefaults;
  t2_set_buf(0);
  t2_block(0,0,320,200,0);
  t2_set_buf(1); nopalette; load_pcx(GFX+'gfx.pcx');
  getmem(P3,8833); getmem(P5,2913); getmem(P4,5473); getmem(P6,1153);
  t2_getpic(93,74,97,91,P3);
  t2_getpic(103,84,77,71,P4);
  t2_getpic(113,94,57,51,P5);
  t2_getpic(123,104,37,31,P6);
  t2_set_buf(0);
  t2_putpic(222,108,P3); t2_set_buf(1);
  getmem(P,381); t2_getpic(218,85,25,15,P);
  getmem(P2,381); t2_getpic(218,100,25,15,P2);t2_set_buf(0);
  pointpalarr(@default);
  SetNooNoo;
  Potty(120,3,'PLAYERS',2); t2_putpic(130,0,P); t2_putpic(170,0,P2);
  str(NoPlayers,S); Potty(162,3,S,1);
  Potty(120,19,'START LEVEL',2); t2_putpic(130,16,P); t2_putpic(170,16,P2);
  str(StartLevel,S); Potty(162,19,S,1);
  Potty(120,35,'LIVES',2); t2_putpic(130,32,P); t2_putpic(170,32,P2);
  str(Life,S); Potty(162,35,S,1);
  PlotNames(P);
  setmouseposition(320,100); setmousexlimits(0,619); setmouseylimits(0,170);
  Potty(160,190,'BLAST THE HOOVER TO BEGIN',1);
  showpointer;
  fadein(30,0,255);
  repeat
    repeat 
      mouseinfo; 
    until not mouse.left;
    repeat
      mouseinfo;
    until mouse.left or keypressed;
    if mousein(130,0,155,15) and (NoPlayers>1) then begin 
      dec(NoPlayers); str(NoPlayers,S); hidepointer; Potty(162,3,S,1); plotnames(P); showpointer; 
    end;
    if mousein(170,0,195,15) and (NoPlayers<8) then begin
      inc(NoPlayers); str(NoPlayers,S); hidepointer; Potty(162,3,S,1); plotnames(P); showpointer; 
    end;
    if mousein(130,16,155,31) and (StartLevel>1) then begin
      dec(StartLevel); str(StartLevel,S); hidepointer; Potty(162,19,S,1); showpointer; 
    end;
    if mousein(170,16,195,31) and (StartLevel<8) then begin
      inc(StartLevel); str(StartLevel,S); hidepointer; Potty(162,19,S,1); showpointer; 
    end;
    if mousein(130,32,155,47) and (Life>1) then begin
      dec(Life); str(Life,S); hidepointer; Potty(162,35,S,1); showpointer; 
    end;
    if mousein(170,32,195,47) and (Life<8) then begin
      inc(Life); str(Life,S); hidepointer; Potty(162,35,S,1); showpointer; 
    end;

    if mousein(64,54,89,68) then begin hidepointer; Nedit(1); plotnames(P); showpointer; end;
    if mousein(224,54,249,68) and (NoPlayers>1) then begin hidepointer; Nedit(2); plotnames(P); showpointer; end;
    if mousein(64,70,89,84) and (NoPlayers>2) then begin hidepointer; Nedit(3); plotnames(P); showpointer; end;
    if mousein(224,70,249,84) and (NoPlayers>3) then begin hidepointer; Nedit(4); plotnames(P); showpointer; end;
    if mousein(64,86,89,100) and (NoPlayers>4) then begin hidepointer; Nedit(5); plotnames(P); showpointer; end;
    if mousein(224,86,249,100) and (NoPlayers>5) then begin hidepointer; Nedit(6); plotnames(P); showpointer; end;
    if mousein(64,102,89,116) and (NoPlayers>6) then begin hidepointer; Nedit(7); plotnames(P); showpointer; end;
    if mousein(224,102,249,116) and (NoPlayers>7) then begin hidepointer; Nedit(8); plotnames(P); showpointer; end;
  until ((mouse.x>444) and (mouse.y>128)) or keypressed;
  ch:=chr(0);
  if keypressed then ch:=upcase(readkey);
  repeat
    if keypressed then repeat until readkey<>'';
    mouseinfo;
  until not keypressed and not mouse.left;
  hidepointer;
  t2_set_scale_size(117,101); t2_scale_pic(202,98,P3); t2_vretrace;
  t2_set_scale_size(137,111); t2_scale_pic(182,88,P3); t2_vretrace;
  t2_set_scale_size(157,121); t2_scale_pic(162,78,P3); t2_vretrace;
  t2_set_scale_size(177,131); t2_scale_pic(142,68,P3); t2_Vretrace;
  t2_set_scale_size(197,141); t2_scale_pic(122,58,P3); t2_vretrace;
  t2_set_scale_size(217,151); t2_scale_pic(102,48,P3); t2_vretrace;
  t2_set_scale_size(237,161); t2_scale_pic(82,38,P3); t2_vretrace;
  t2_set_scale_size(257,171); t2_Scale_pic(62,28,P3); t2_vretrace;
  t2_set_scale_size(277,181); t2_scale_pic(42,18,P3); t2_Vretrace;
  t2_Set_scale_size(297,191); t2_scale_pic(22,8,P3); t2_vretrace;
  t2_set_scale_size(319,199); t2_scale_pic(0,0,P3); t2_vretrace;
  t2_scale_pic(0,0,P4); t2_vretrace;
  t2_scale_pic(0,0,P5); t2_vretrace;
  t2_scale_pic(0,0,P6); t2_vretrace;

  fadeout(30,0,255);
  freemem(p,381); freemem(p2,381);
  freemem(P3,8833); freemem(P5,2913); freemem(P4,5473); freemem(P6,1153);
  if ch<>chr(27) then begin WriteIni; Game; end;
end;

begin
  initmouse;
  SetMeUp;
  repeat
    FrontPage;
    OptionPage;
  until false;
end.