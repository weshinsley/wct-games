{$M 65520,0,655360}
program TWITRIS;

uses crt,dos,td_pcx,td_256,sound,load,ts,td_key;

var
  Card   : DSMCard;
  Module : PDSM;
  SoundOn        : boolean;

const
  PMode : array[0..2] of string[13] = ('SCORE','SUDDEN DEATH','BORN AGAIN');
  Bool : array[0..1] of string[3] = ('NO','YES');
  ROT : array[0..1] of string[5] = ('CLOCK','ANTI');

  AUDIO_DIR : string = 'AUDIO\';
  GFX_DIR : string = 'GFX\';

  Players : byte = 2;     { No. of simultaneous players }
  RotateDir : byte = 1;   { 0 = clockwise, 1 = anti-clockwise}
  Nasties : byte = 1;     { 0 = No nasty lines, 1 = yes - multiplayer shift}
  Preview : byte = 1;     { Preview a piece in advance}
  BSize : byte = 7;       { The block size }
  Top : word = 20;        { Top screen co-ord of Tetris playfield }
  Left : word = 10;       { Left screen co-ord of Tetris playfield }
  Width : byte = 10;      { Width in blocks }
  Height : byte = 20;     { Height in blocks }
  InitHeight : byte = 0;  { Initial height of random mess }
  PlayMode   : byte = 0;  { 0 = Score, 1 = Sudden Death, 2 = Born Again
{Variables used at runtime, to prevent huge parameterised functions}

  DropSpeed : array[1..3] of byte = (30,30,30);  { How many 50ths of a second between drops }
  Drop : array[1..3] of byte = (0,0,0);        { How long til we move the piece again }
  CurrentPiece : array[1..3] of byte = (0,0,0);
  NextPiece : array[1..3] of byte = (0,0,0);
  NextRot : array[1..3] of byte = (0,0,0);
  NextCol : array[1..3] of byte = (0,0,0);
  Rotation : array[1..3] of byte = (0,0,0);
  CurrentHeight : array[1..3] of byte = (0,0,0);
  CurrentWidth : array[1..3] of byte = (0,0,0);
  PX : array[1..3] of byte = (0,0,0);
  PY : array[1..3] of byte = (0,0,0);
  LeftHeld : array[1..3] of byte = (0,0,0);
  RightHeld : array[1..3] of byte = (0,0,0);
  UpHeld : array[1..3] of byte = (0,0,0);
  Colour : array[1..3] of byte = (0,0,0);
  DownHeld : array[1..3] of byte = (0,0,0);
  Rows : array[1..3] of byte = (0,0,0);
  Scores : array[1..3] of word = (0,0,0);
  LeftK : array[1..3] of byte = (33,108,75);
  RightK : array[1..3] of byte = (35,104,77);
  UpK : array[1..3] of byte = (20,106,72);
  DownK : array[1..3] of byte = (34,110,76);
  Alive : array[1..3] of boolean = (false,false,false);

var TheGrid : array[1..10,1..21,1..3] of byte;
    OldX,OldY,OldPiece,OldRot : byte;
    Lets : array[1..52] of pointer;
    LetsW,LetsH : array[1..52] of word;
    HiScores : array[1..6] of string[25];
    SbC,SbI,SbD,SbB : word;

procedure StartInterrupt;
begin
  TSInit;
  TSSetRate(60);
  TSSetRoutine(DSMPoll);
end;

procedure ShutInterrupt;
begin
  TSDone;
  TSRestoreTime;
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
    if ch<>'!' then begin
      S:=S+ch;
    end;
    L:=L+1;
    if L=255 then L:=0;
  until ch='!';
end;

procedure ReadHi;
  var F : file;
      L : byte;
begin
  assign(F,'Twit.HI');
  reset(F,1);
  for L:=1 to 6 do
    ReadCode(F,HiSCORES[L]);
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

procedure WriteHi;
  var F : file;
      L : byte;
begin
  assign(F,'TWIT.HI');
  rewrite(F,1);
  for L:=1 to 6 do
    WriteCode(F,HiSCORES[L]);
  close(F);
end;

procedure WriteDefaultHi;
  var F : file;
begin
  assign(F,'TWIT.HI');
  rewrite(F,1);
  WriteCode(F,'JON@5000');
  WriteCode(F,'LANA@1000');
  WriteCode(F,'WES@500');
  WriteCode(F,'RICH@200');
  WriteCode(F,'DAVE@100');
  WriteCode(F,'LISA@50');
  close(F);
end;

procedure WriteDefaultIni;
  var F : text;
begin
  assign(F,'Twit.INI');
  rewrite(F);
  writeln(F,'SOUND=YES');
  writeln(F,'PLAYER=1');
  writeln(F,'P1L=33'); writeln(F,'P1R=35'); writeln(F,'P1U=20'); writeln(F,'P1D=34');
  writeln(F,'P2L=108'); writeln(F,'P2R=104'); writeln(F,'P2U=106'); writeln(F,'P2D=110');
  writeln(F,'P3L=75'); writeln(F,'P3R=77'); writeln(F,'P3U=72'); writeln(F,'P3D=76');
  writeln(F,'RD=1');
  writeln(F,'NA=0');
  writeln(F,'PR=1');
  writeln(F,'PL=0');
  close(F);
end;

procedure WriteIni;
  var F : text;
begin
  assign(F,'Twit.INI');
  rewrite(F);
  if SoundOn then writeln(F,'SOUND=YES') else writeln(F,'SOUND=NO');
  writeln(F,'PLAYER=',Players);
  writeln(F,'P1L=',LeftK[1]); writeln(F,'P1R=',RightK[1]); writeln(F,'P1U=',UpK[1]); writeln(F,'P1D=',DownK[1]);
  writeln(F,'P2L=',LeftK[2]); writeln(F,'P2R=',RightK[2]); writeln(F,'P2U=',UpK[2]); writeln(F,'P2D=',DownK[2]);
  writeln(F,'P3L=',LeftK[3]); writeln(F,'P3R=',RightK[3]); writeln(F,'P3U=',UpK[3]); writeln(F,'P3D=',DownK[3]);
  writeln(F,'RD=',RotateDir);
  writeln(F,'NA=',Nasties);
  writeln(F,'PR=',Preview);
  writeln(F,'PL=',PlayMode);
  close(F);
end;

procedure ReadIni;
  var F : text;
      PNo : byte;
      S : string[25];
      s1 : string[1];
      code : integer;
begin
  assign(F,'Twit.INI');
  reset(F);
  repeat
    readln(F,S);
    if copy(S,1,5)='SOUND' then begin S:=copy(S,7,length(S)-6); Soundon:=(S='YES'); end
    else if copy(S,1,6)='PLAYER' then begin S:=copy(S,8,length(S)-7); val(S,Players,code); end
    else if copy(S,1,3)='P1L' then begin S:=copy(S,5,length(S)-4); val(S,LeftK[1],code); end
    else if copy(S,1,3)='P1R' then begin S:=copy(S,5,length(S)-4); val(S,RightK[1],code); end
    else if copy(S,1,3)='P1U' then begin S:=copy(S,5,length(S)-4); val(S,UpK[1],code); end
    else if copy(S,1,3)='P1D' then begin S:=copy(S,5,length(S)-4); val(S,DownK[1],code); end
    else if copy(S,1,3)='P2L' then begin S:=copy(S,5,length(S)-4); val(S,LeftK[2],code); end
    else if copy(S,1,3)='P2R' then begin S:=copy(S,5,length(S)-4); val(S,RightK[2],code); end
    else if copy(S,1,3)='P2U' then begin S:=copy(S,5,length(S)-4); val(S,UpK[2],code); end
    else if copy(S,1,3)='P2D' then begin S:=copy(S,5,length(S)-4); val(S,DownK[2],code); end
    else if copy(S,1,3)='P3L' then begin S:=copy(S,5,length(S)-4); val(S,LeftK[3],code); end
    else if copy(S,1,3)='P3R' then begin S:=copy(S,5,length(S)-4); val(S,RightK[3],code); end
    else if copy(S,1,3)='P3U' then begin S:=copy(S,5,length(S)-4); val(S,UpK[3],code); end
    else if copy(S,1,3)='P3D' then begin S:=copy(S,5,length(S)-4); val(S,DownK[3],code); end
    else if copy(S,1,2)='RD' then begin S:=copy(S,4,length(S)-3); val(S,RotateDir,code); end
    else if copy(S,1,2)='NA' then begin S:=copy(S,4,length(S)-3); val(S,Nasties,code); end
    else if copy(S,1,2)='PR' then begin S:=copy(S,4,length(S)-3); val(S,Preview,code); end
    else if copy(S,1,2)='PL' then begin S:=copy(S,4,length(S)-3); val(S,PlayMode,code); end;
  until eof(F);
  close(F);
end;


procedure LoadDefaults;
  var DirInfo : SearchRec;
begin
  findfirst('Twit.INI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultIni;
  findfirst('Twit.HI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultHi;
  ReadIni;
  ReadHi;
end;

procedure CLEARBUF;
begin
  repeat
    if TK_Keypressed then repeat until TK_Readkey<>0;
  until not TK_Keypressed;
end;

procedure SetupSound;
var L : byte;
begin
  if DSMLoadSetup(Card) then begin
    t2_End;
    writeln('Please run SETUP.EXE to configure.');
    halt;
  end;
  if DSMInit(Card) then begin
    t2_end;
    writeln('Error Initializing the Sound System.');
     halt;
  end;
  Module := DSMLoad(AUDIO_DIR+'TWIT3.DSM',0);
  if Module = nil then begin
    case DSMStatus of
      ERR_NORAM:  writeln('Not enough system memory.');
      ERR_NODRAM: writeln('Not enough card memory.');
      ERR_NOFILE: writeln('File not found.');
      ERR_FORMAT: writeln('Invalid file format.');
      ERR_ACCESS: writeln('File damaged.');
    end;
    DSMDone;
    t2_end;
    halt;
  end;
  StartInterrupt;
  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);
  for L:=0 downto 200 do begin DSMSetMusicVolume(L); delay(10); end;
end;

procedure ShutSound;
  var L : byte;
begin
  for L:=200 downto 0 do begin DSMSetMusicVolume(L); delay(3); end;
  DSMStopMusic;
  ShutInterrupt;
  DSMFree(Module);
  DSMDone;
end;

procedure ZapFont(X1,X2,Y1,Y2 : word; P : byte);
begin
  LetsW[P]:=1+(X2-X1);
  LetsH[P]:=1+(Y2-Y1);
  getmem(Lets[P],6+(LetsW[P]*LetsH[P]));
  t2_getpic(X1,Y1,(X2-X1)+1,(Y2-Y1)+1,Lets[P]);
end;

procedure LoadFont1;
begin
  t2_Set_buf(1); load_pcx(GFX_DIR+'font1.pcx');
  ZapFont(2,12,3,13,1); ZapFont(22,29,3,13,2); ZapFont(40,47,3,13,3);
  ZapFont(58,66,3,13,4); ZapFont(77,84,3,13,5); ZapFont(95,102,3,13,6);
  ZapFont(112,120,3,13,7); ZapFont(131,139,3,13,8); ZapFont(150,152,3,13,9);
  ZapFont(163,168,3,13,10); ZapFont(179,188,3,13,11); ZapFont(199,204,3,13,12);
  ZapFont(3,14,19,29,13); ZapFont(25,34,19,29,14); ZapFont(44,53,19,29,15);
  ZapFont(64,71,19,29,16); ZapFont(82,91,19,31,17); ZapFont(102,110,19,29,18);
  ZapFont(121,127,19,29,19); ZapFont(138,146,19,29,20); ZapFont(157,165,19,29,21);
  ZapFont(175,184,19,29,22); ZapFont(194,208,19,29,23); ZapFont(2,12,35,45,24);
  ZapFont(21,31,35,45,25); ZapFont(40,47,35,45,26); ZapFont(58,66,35,45,27);
  ZapFont(77,79,35,45,28); ZapFont(90,97,35,45,29); ZapFont(108,115,35,45,30);
  ZapFont(126,134,35,45,31); ZapFont(146,152,35,45,32); ZapFont(163,170,35,45,33);
  ZapFont(181,188,35,45,34); ZapFont(199,207,35,45,35); ZapFont(218,225,35,45,36);
  ZapFont(3,5,51,61,37); ZapFont(17,23,51,61,38); ZapFont(32,39,51,61,39);
  ZapFont(42,49,51,61,40); ZapFont(54,57,51,60,41); ZapFont(62,74,51,61,42);
  ZapFont(76,88,51,61,43); ZapFont(91,96,51,54,44); ZapFont(98,108,51,61,45);
  ZapFont(110,120,49,54,46); ZapFont(110,120,51,59,47); ZapFont(123,132,51,59,48);
  ZapFont(137,146,51,60,49); ZapFont(151,154,47,57,50); ZapFont(156,158,47,57,51);
  ZapFont(151,154,55,57,52);
end;

function TWidth(s : string) : word;
  var L : byte;
      W : word;
  const range = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:?[];\/`#-=+*,.''';
begin
  W:=0;
  for L:=1 to length(S) do begin
    if s[L]<>' ' then W:=W+LetsW[pos(s[l],range)] else W:=W+5;
    W:=W+2;
  end;
  TWidth:=W;
end;

procedure TText(X,Y : word; s : string; col : byte);
  var L,C,W,M,N : word;
      High : word;
  const range = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789:?[];\/`#-=+*,.''';
begin
  L:=X; C:=0;
  repeat
    inc(C);
    if S[c]=' ' then inc(L,5) else begin
      W:=LetsW[pos(s[c],range)];
      if W+L<=319 then begin
        t2_block(L,Y,W+1,LetsH[pos(s[c],range)]+1,0);
        t2_putpic(L,Y,Lets[pos(s[c],range)]);
      end;
      if col>0 then for M:=L to L+W do
        for N:=Y to Y+LetsH[pos(s[c],range)] do
          t2_dot(M,N,t2_getdot(M,N)+col);
      L:=L+W+2;
    end;
  until C=length(S);
end;

procedure NormalOpt(Highlight,Offs,Ofy : integer);
begin
  t2_line(80+Offs,25+Ofy,80+Offs,81+Ofy,124);
  t2_line(140+Offs,25+Ofy,140+Offs,81+Ofy,124);
  t2_line(200+Offs,25+Ofy,200+Offs,81+Ofy,124);
  t2_line(260+Offs,25+Ofy,260+Offs,81+Ofy,124);
  t2_line(80+Offs,25+Ofy,260+Offs,25+Ofy,124);
  t2_line(80+Offs,39+Ofy,260+Offs,39+Ofy,124);
  t2_line(80+Offs,53+Ofy,260+Offs,53+Ofy,124);
  t2_line(80+Offs,67+Ofy,260+Offs,67+Ofy,124);
  t2_line(80+Offs,81+Ofy,260+Offs,81+Ofy,124);
  TText(0+Offs,1+Ofy,'CONTROLS',197);
  Ttext(0+Offs,186+Ofy,'LEF/RGT/ENTER/ESC/SPACE',210);

  if (Highlight=2) or (Highlight=7) or (Highlight=12) then TText(0+Offs,27+Ofy,'LEFT = ',218) else
    TText(0+Offs,27+Ofy,'LEFT = ',193);
  if (Highlight=3) or (Highlight=8) or (Highlight=13) then TText(0+Offs,41+Ofy,'RIGHT = ',218) else
    TText(0+Offs,41+Ofy,'RIGHT = ',193);
  if (Highlight=4) or (Highlight=9) or (Highlight=14) then TText(0+Offs,55+Ofy,'ROT = ',218) else
    TText(0+Offs,55+Ofy,'ROT = ',193);
  if (Highlight=5) or (Highlight=10) or (Highlight=15) then TText(0+Offs,69+Ofy,'DROP = ',218) else
    TText(0+Offs,69+Ofy,'DROP = ',193);
  if (Highlight>=1) and (Highlight<=5) then TText(100+Offs,13+Ofy,'P1',197) else TText(100+Offs,13+Ofy,'P1',201);
  if (Highlight>=6) and (Highlight<=10) then TText(160+Offs,13+Ofy,'P2',197) else TText(160+Offs,13+Ofy,'P2',201);
  if (Highlight>=11) and (Highlight<=15) then TText(220+Offs,13+Ofy,'P3',197) else TText(220+Offs,13+Ofy,'P3',201);
  if Highlight=16 then TText(0+Offs,90+Ofy,'SOUND',218) else TText(0+Offs,90+Ofy,'SOUND',193);
  if Highlight=17 then TText(80+Offs,130+Ofy,'PLAYERS = ',218) else TText(80+Offs,130+Ofy,'PLAYERS = ',193);
  if Highlight=18 then TText(60+Offs,143+Ofy,'ROT-DIR = ',218) else TText(60+Offs,143+Ofy,'ROT-DIR = ',193);
  if Highlight=19 then TText(0+Offs,156+Ofy,'NASTIES = ',218) else TText(0+Offs,156+Ofy,'NASTIES = ',193);
  if Highlight=20 then TText(123+Offs,156+Ofy,'PREVIEW = ',218) else TText(123+Offs,156+Ofy,'PREVIEW = ',193);
  if Highlight=21 then TText(70+Offs,169+Ofy,'MODE = ',218) else TText(70+Offs,169+Ofy,'MODE = ',193);
end;

procedure BlockParams;
begin
  t2_block(122,25,50,13,0); t2_block(182,25,50,13,0); t2_block(242,25,50,13,0);
  t2_block(122,39,50,13,0); t2_block(182,39,50,13,0); t2_block(242,39,50,13,0);
  t2_block(122,53,50,13,0); t2_block(182,53,50,13,0); t2_block(242,53,50,13,0);
  t2_block(122,67,50,13,0); t2_block(182,67,50,13,0); t2_block(242,67,50,13,0);
  t2_block(121,154,32,13,0); t2_block(251,154,30,13,0); t2_block(111,102,60,13,0);
  t2_block(111,115,20,13,0); t2_block(185,141,52,13,0); t2_block(207,128,20,13,0);
  t2_block(251,102,40,13,0); t2_block(251,115,20,13,0); t2_block(175,167,130,13,0);
  t2_block(111,88,40,13,0);
end;

procedure Params(Ofx,Ofy : integer);
  var st : string;
begin
  if Ofy<0 then BlockParams;
  TText(90+Ofx,27+Ofy,KeyName[LeftK[1]],205);
  TText(90+Ofx,41+Ofy,KeyName[RightK[1]],205);
  TText(90+Ofx,55+Ofy,KeyName[UpK[1]],205);
  TText(90+Ofx,69+Ofy,KeyName[DownK[1]],205);
  TText(150+Ofx,27+Ofy,KeyName[LeftK[2]],205);
  TText(150+Ofx,41+Ofy,KeyName[RightK[2]],205);
  TText(150+Ofx,55+Ofy,KeyName[Upk[2]],205);
  TText(150+Ofx,69+Ofy,KeyName[DownK[2]],205);
  TText(210+Ofx,27+Ofy,KeyName[LeftK[3]],205);
  TText(210+Ofx,41+Ofy,KeyName[RightK[3]],205);
  TText(210+Ofx,55+Ofy,KeyName[UpK[3]],205);
  TText(210+Ofx,69+Ofy,KeyName[DownK[3]],205);
  TText(90+Ofx,156+Ofy,bool[Nasties],205);
  TText(218+Ofx,156+Ofy,bool[Preview],205);
  TText(154+Ofx,143+Ofy,Rot[RotateDir],205);
  str(players,st);
  TText(176+Ofx,130+Ofy,st,205);
  TText(144+Ofx,169+Ofy,PMode[PlayMode],205);
  if SoundOn then TText(80+Ofx,90+Ofy,'ON',205) else TText(80+Ofx,90+Ofy,'OFF',205);
end;

procedure ExitTetris;
  var X : byte;
begin
  tk_end;
  for X:=1 to 52 do freemem (Lets[X],6+(LetsW[X]*LetsH[X]));
  t2_end;
end;

function ScConv(S : string) : longint;
  var Code : integer;
      Temp : longint;
begin
  val(copy(S,pos('@',S)+1,length(S)-pos('@',S)),Temp,Code);
  ScConv:=Temp;
end;

procedure CloseScreen;
  var X : byte;
begin
  X:=0;
  repeat
    t2_line(0,X,319,X,0);
    t2_line(X,0,X,199,0);
    t2_line(319-X,0,319-X,199,0);
    t2_line(0,199-X,319,199-X,0);
    inc(X);
    t2_vretrace;
  until X=100;
end;

procedure TitlePage;
  var P,P2 : pointer;
  r,g,b : byte;
  X2,Y2,L : word;
  st : string;
  Highlight : byte;
  GameOn : boolean;
  const X : word =0;
        Go : byte=0;
        Sel : byte = 8;
begin
  repeat
    randomize; GameOn:=false;
    t2_set_buf(1); t2_band(0,200,0);
    yespalette;
    load_pcx(GFX_DIR+'ttitle.pcx');
    getmem(P,960);

    t2_set_buf(0); t2_band(0,200,0);
    for X:=0 to 255 do
      t2_dot(random(319),random(199),random(5)+210);
    t2_set_buf(1);
    for X:=0 to 128 do begin
      X2:=random(319); Y2:=random(199);
      t2_getrgb(t2_getdot(X2,Y2),r,g,b);
      if r+g+b<10 then t2_dot(X2,y2,random(5)+210);
    end;
    Ttext(103,110,'OPTIONS',193);
    Ttext(78,130,'HALL OF FAME',193);
    Ttext(74,150,'PLAY TWITRIS',193);
    Ttext(120,170,'EXIT',193);
    t2_setrgb(193,0,0,0); t2_setrgb(194,0,5,0); t2_setrgb(195,0,15,0); t2_setrgb(196,0,25,0);
    t2_setrgb(197,0,0,0); t2_setrgb(198,15,10,10); t2_setrgb(199,30,20,20); t2_setrgb(200,45,30,30);
    t2_setrgb(201,0,0,0); t2_setrgb(202,5,0,0); t2_setrgb(203,15,0,0); t2_setrgb(204,25,0,0);
    t2_setrgb(205,0,0,0); t2_setrgb(206,10,15,10); t2_setrgb(207,20,30,20); t2_setrgb(208,30,45,30);

    t2_setrgb(210,10,10,10); t2_setrgb(211,15,15,15); t2_setrgb(212,20,20,20); t2_setrgb(213,25,25,25);
    t2_setrgb(214,25,25,25); t2_setrgb(215,30,30,30);
    t2_setrgb(218,0,0,0);
    t2_setrgb(219,30,30,0); t2_setrgb(220,45,45,0); t2_setrgb(221,63,63,0);
    X:=0;
    repeat
      if X<281 then begin
        t2_set_buf(1);
        t2_getpic(X,0,4,192,P);
        t2_set_buf(0);
        t2_putpic((312+x) mod 320,0,P);
      end;
      t2_hw_Scroll(X,0);
      inc(X,4);
    until X>=281;
    t2_hw_scroll(x,0);
    t2_set_buf(0);
    nopalette;
    Sel:=1;
    repeat
      Go:=0;
      if Sel=1 then begin Ttext(95,110,'OPTIONS',205)end else Ttext(95,110,'OPTIONS',193);
      if Sel=2 then begin Ttext(70,130,'HALL OF FAME',205) end else Ttext(70,130,'HALL OF FAME',193);
      if Sel=3 then begin Ttext(66,150,'PLAY TWITTRIS',205) end else Ttext(66,150,'PLAY TWITTRIS',193);
      if Sel=4 then begin Ttext(112,170,'EXIT',205) end else Ttext(112,170,'EXIT',193);
      clearbuf;
      repeat until TK_Keypressed;
      if (TK_KP[106]) and (Sel>1) then dec(Sel);
      if (TK_KP[110]) and (Sel<4) then inc(Sel);
      if (TK_KP[28]) then Go:=Sel;
    until (TK_KP[1]) or (Go>0);
    t2_set_buf(1); t2_block(0,0,320,200,0);
    if (Go>=4) or (TK_KP[1]) then begin ExitTetris; halt; end;
    if Go=3 then GameOn:=true;
    if Go=2 then begin
      t2_set_buf(1); t2_block(0,0,320,200,0);
      Ttext(70,20,'HALL OF FAME',222);
      t2_setrgb(222,5,0,0); t2_setrgb(223,32,0,0); t2_setrgb(224,48,0,0); t2_setrgb(225,63,0,0);
      t2_setrgb(226,0,0,0); t2_setrgb(227,10,32,10); t2_setrgb(228,20,48,20); t2_setrgb(229,30,63,30);
      t2_setrgb(230,0,0,0); t2_Setrgb(231,0,20,20); t2_setrgb(232,0,40,40); t2_setrgb(233,0,60,60);
      for L:=1 to 6 do begin
        str(ScConv(HiScores[L]),st);
        Ttext(110-TWidth(copy(HiScores[L],1,pos('@',HiScores[L])-1)),50+(L*20),
        copy(HiScores[L],1,pos('@',HiScores[L])-1),226);
        Ttext(140,50+(L*20),st,230);
      end;
    end;
    if Go=1 then begin
      t2_set_buf(1); t2_block(0,0,320,200,0); Highlight:=1;
      NormalOpt(Highlight,0,0);
      Params(0,0);
    end;
    repeat
      t2_set_buf(1);
      t2_getpic(x,0,4,199,P);
      t2_set_buf(0);
      t2_putpic(x,0,P);
      t2_hw_Scroll(x,0);
      if X>3 then X:=X-4 else X:=X+316;
    until abs(X-281)<=4;
    if Go=2 then begin clearbuf; repeat until tk_keypressed; Go:=0; end;
    if Go=1 then begin
      clearbuf;
      repeat
        repeat
          clearbuf;
        until not tk_keypressed;
        repeat until tk_keypressed;
        if TK_KP[104] then begin
          if Highlight=1 then Highlight:=6
          else if Highlight=6 then Highlight:=11
          else if Highlight=11 then Highlight:=16
          else if Highlight=21 then Highlight:=1
          else inc(Highlight);
        end;
        if TK_KP[108] then begin
          if Highlight=1 then Highlight:=21
          else if Highlight=6 then Highlight:=1
          else if Highlight=11 then Highlight:=6
          else if Highlight=16 then Highlight:=11
          else dec(Highlight);
        end;
        if (TK_KP[28]) and (Highlight=1) then begin
          Highlight:=2; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          LeftK[1]:=TK_ReadKey;
          Params(32,-1); Highlight:=3; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          RightK[1]:=TK_ReadKey;
          Params(32,-1); Highlight:=4; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          UpK[1]:=TK_ReadKey;
          Params(32,-1); Highlight:=5; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          DownK[1]:=TK_ReadKey;
          Params(32,-1); Highlight:=1; NormalOpt(Highlight,32,-1);
        end else
        if (TK_KP[28]) and (Highlight=6) then begin
          Highlight:=7; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          LeftK[2]:=TK_ReadKey;
          Params(32,-1); Highlight:=8; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          RightK[2]:=TK_ReadKey;
          Params(32,-1); Highlight:=9; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          UpK[2]:=TK_ReadKey;
          Params(32,-1); Highlight:=10; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          DownK[2]:=TK_ReadKey;
          Params(32,-1); Highlight:=6; NormalOpt(Highlight,32,-1);
        end else
        if (TK_KP[28]) and (Highlight=11) then begin
          Highlight:=12; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          LeftK[3]:=TK_ReadKey;
          Params(32,-1); Highlight:=13; NormalOpt(Highlight,32,-1);
          repeat Clearbuf; until not tk_keypressed;
          RightK[3]:=TK_ReadKey;
          Params(32,-1); Highlight:=14; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          UpK[3]:=TK_ReadKey;
          Params(32,-1); Highlight:=15; NormalOpt(Highlight,32,-1);
          repeat clearbuf; until not tk_keypressed;
          DownK[3]:=TK_ReadKey;
          Params(32,-1); Highlight:=11; NormalOpt(Highlight,32,-1);
        end
        else if TK_KP[28] and (Highlight=16) then SoundOn:=not SoundOn
        else if TK_KP[28] and (Highlight=17) then Players:=(Players mod 3)+1
        else if TK_KP[28] and (Highlight=18) then RotateDir:=1-RotateDir
        else if TK_KP[28] and (Highlight=19) then Nasties:=1-Nasties
        else if TK_KP[28] and (Highlight=20) then Preview:=1-Preview
        else if TK_KP[28] and (Highlight=21) then PlayMode:=(PlayMode+1) mod 3;
        Params(32,-1);
        NormalOpt(Highlight,32,-1);
      until tK_KP[1] or tk_KP[57];
      if TK_KP[57] then WriteIni;
    end;
    ReadIni;
    freemem(P,960);
    CloseScreen;
    t2_set_buf(0); t2_band(0,200,0);
    t2_set_buf(1); t2_band(0,200,0);
    t2_hw_scroll(0,0);
  until GameOn;
  if Go=4 then ExitTetris;
end;

function max(a : integer; b : integer) : integer;
begin
 if (a>b) then max:=a
 else max:=b;
end;
procedure TetBlock(X,Y : integer; Pl : byte);
  var Xb,Yb : word;
      pl2 : byte;
      F : text;
begin
  pl2:=pl;
  if (players=2) and (pl=2) then pl2:=3;
  if (players=1) then pl2:=2;
  XB:=Left+(X*(Bsize+1))+((pl2-1)*100);
  YB:=Top+(Y*(Bsize+1));
  if (Yb>0) then begin
    t2_block(Xb,Yb,BSize,BSize,Colour[pl]);
    t2_block(Xb,Yb,BSize,BSize,Colour[pl]);
    t2_line(Xb,Yb,Xb+BSize,Yb,Colour[pl]+1);
    t2_line(Xb,Yb,Xb,Yb+BSize,Colour[pl]+1);
    t2_line(Xb+BSize-1,Yb+BSize-1,Xb+BSize-1,Yb+BSize,max(0,Colour[pl]-1));
    t2_line(Xb+1,Yb+BSize-1,Xb+BSize-1,Yb+BSize-1,max(0,Colour[pl]-1));
  end;
end;

procedure ReDraw(pl : byte);
  var X,Y : byte;
      Xb,Yb,L : word;
      pl2 : byte;
      st : string;
      OldColour : byte;
begin
  OldColour:=Colour[pl];
  for X:=1 to Width do for Y:=1 to Height do begin
    Colour[pl]:=TheGrid[X,Y,pl]; if Colour[pl]=0 then Colour[pl]:=1;
    TetBlock(X,Y,pl);
  end;

  Colour[pl]:=38;
  for L:=1 to Height do begin TetBlock(0,L,pl); TetBlock(Width+1,L,pl); end;
  for L:=0 to Width+1 do TetBlock(L,Height+1,pl);
  Colour[pl]:=OldColour;
  pl2:=pl;
  if (players=2) and (pl=2) then pl2:=3;
  if players=1 then pl2:=2;
  str(Scores[pl],st);
  t2_block(20+(100*(pl2-1)),5,60,20,0);
  TText(20+(100*(pl2-1)),5,st,2);
end;

procedure DrawPiece(P,R : byte; X,Y,Pl : shortint);
begin
  if P=1 then begin
    if R=1 then begin
      TetBlock(X,Y,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X,Y+2,pl);
      TetBlock(X,Y+3,pl);
    end else if R=2 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+2,Y,pl);
      TetBlock(X+3,Y,pl);
    end;
  end else if P=2 then begin
    TetBlock(X,Y,pl);
    TetBLock(X+1,Y,pl);
    TetBlock(X,Y+1,pl);
    TetBLock(X+1,Y+1,pl);
  end else if P=3 then begin
    if R=1 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+2,Y+1,pl);
    end else if R=2 then begin
      TetBlock(X+1,Y,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X,Y+2,pl);
    end;
  end else if P=4 then begin
    if R=1 then begin
      TetBlock(X,Y+1,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+2,Y,pl);
    end else if R=2 then begin
      TetBlock(X,Y,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+1,Y+2,pl);
    end;
  end else if P=5 then begin
    if R=1 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+1,Y+2,pl);
    end else if R=2 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+2,Y,pl);
      TetBlock(X,Y+1,pl);
    end else if R=3 then begin
      TetBlock(X,Y,pl);
      TetBLock(X,Y+1,pl);
      TetBlock(X,Y+2,pl);
      TetBlock(X+1,Y+2,pl);
    end else if R=4 then begin
      TetBlock(X,Y+1,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+2,Y+1,pl);
      TetBlock(X+2,Y,pl);
    end;
  end else if P=6 then begin
    if R=1 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X,Y+2,pl);
    end else if R=2 then begin
      TetBlock(X,Y,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+2,Y+1,pl);
    end else if R=3 then begin
      TetBlock(X+1,Y,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+1,Y+2,pl);
      TetBlock(X,Y+2,pl);
    end else if R=4 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+2,Y,pl);
      TetBlock(X+2,Y+1,pl);
    end
  end else if P=7 then begin
    if R=1 then begin
      TetBlock(X,Y,pl);
      TetBlock(X+1,Y,pl);
      TetBlock(X+2,y,Pl);
      TetBlock(X+1,Y+1,pl);
    end else if R=2 then begin
      TetBlock(X+1,Y,pl);
      TetBlock(X+1,Y+1,pl);
      TetBlock(X+1,Y+2,pl);
      TetBlock(X,Y+1,pl);
    end else if R=3 then begin
      TetBlock(X+1,Y,pl);
      TetBlock(X,Y+1,pl);
      tetBlock(X+1,Y+1,pl);
      TetBlock(X+2,y+1,pl);
    end else if R=4 then begin
      TetBlock(X,Y,pl);
      TetBlock(X,Y+1,pl);
      TetBlock(X,Y+2,pl);
      TetBlock(X+1,Y+1,pl);
    end;
  end;
end;

procedure ShiftRowUp(pl : byte);
  var X,Y : byte;
begin
  for Y:=1 to 19 do for x:=1 to 10 do
    TheGrid[X,Y,pl]:=TheGrid[X,Y+1,pl];
  dec(PY[pl]); if PY[pl]<1 then PY[pl]:=1;
end;

procedure RemoveRow(R,pl : byte);
  var X,Y : byte;

begin
  for Y:=R downto 2 do for X:=1 to 10 do
    TheGrid[X,Y,pl]:=TheGrid[X,Y-1,pl];

  if Nasties>0 then begin
    for X:=1 to players do
      if (X<>pl) and Alive[x] then begin
        ShiftRowUp(X);
        redraw(x);
        DrawPiece(CurrentPiece[x],Rotation[x],PX[x],Py[x],x);
      end;
  end;
end;

procedure CheckForRows(pl : byte);
  var Y,X,C : byte;
begin
  for Y:=1 to 20 do begin
    C:=0;
    for X:=1 to 10 do
      if TheGrid[X,Y,pl]<>0 then C:=C+1;
    if C=10 then begin
      RemoveRow(Y,pl); inc(Rows[pl]); inc(Scores[pl],5*(31-Dropspeed[pl]));
      if (Rows[pl] mod 5=0) and (DropSpeed[pl]>1) then dec(DropSpeed[pl]);
    end;
  end;
  ReDraw(pl);
  t2_vretrace;
end;

procedure TetrisPlayfield(pl : byte);
  var L : byte;
      OldColour : byte;
begin
  OldColour:=Colour[pl];
  Colour[pl]:=38;
  for L:=1 to Height do begin TetBlock(0,L,pl); TetBlock(Width+1,L,pl); end;
  for L:=0 to Width+1 do TetBlock(L,Height+1,pl);
  Colour[pl]:=OldColour;
end;

procedure PiecePalette;
begin
  t2_setrgb(1,0,0,0); t2_setrgb(2,0,0,0); t2_setrgb(3,20,20,32); t2_setrgb(4,32,32,0);
  t2_setrgb(5,48,48,0); t2_setrgb(6,63,63,0); t2_setrgb(0,0,0,0);
  t2_setrgb(16,0,0,0); t2_setrgb(17,0,0,0); t2_setrgb(18,0,0,0);
  t2_setrgb(19,32,0,0); t2_setrgb(20,48,0,0); t2_setrgb(21,63,0,0); {R}
  t2_setrgb(22,0,32,0); t2_setrgb(23,0,48,0); t2_setrgb(24,0,63,0); {G}
  t2_setrgb(25,0,0,32); t2_setrgb(26,0,0,48); t2_setrgb(27,0,0,63); {B}
  t2_setrgb(28,32,32,0); t2_Setrgb(29,48,48,0); t2_setrgb(30,63,63,0); {Y}
  t2_setrgb(31,32,0,32); t2_setrgb(32,48,0,48); t2_setrgb(33,63,0,63); {M}
  t2_setrgb(34,0,32,32); t2_setrgb(35,0,48,48); t2_setrgb(36,0,63,63); {C}
  t2_setrgb(37,24,24,24); t2_setrgb(38,40,40,40); t2_setrgb(39,56,56,56); {W}
end;

function OkToPlace(Piece,Rotation,X,Y,pl : byte) : boolean;
begin
  if (Piece=1) then begin

    if (Rotation=1) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                      (TheGrid[X,Y+1,pl]=0) and
                                      (TheGrid[X,Y+2,pl]=0) and
                                      (TheGrid[X,Y+3,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+2,Y,pl]=0) and
                                           (TheGrid[X+3,Y,pl]=0);

  end else if (Piece=2) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                          (TheGrid[X+1,Y,pl]=0) and
                                          (TheGrid[X,Y+1,pl]=0) and
                                          (TheGrid[X+1,Y+1,pl]=0)
  else if (Piece=3) then begin

    if (Rotation=1) then  OkToPlace := (TheGrid[X,Y,pl]=0) and
                                       (TheGrid[X+1,Y,pl]=0) and
                                       (TheGrid[X+1,Y+1,pl]=0) and
                                       (TheGrid[X+2,Y+1,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X,Y+2,pl]=0);
  end else if (Piece=4) then begin

    if (Rotation=1) then OkToPlace := (TheGrid[X,Y+1,pl]=0) and
                                      (TheGrid[X+1,Y+1,pl]=0) and
                                      (TheGrid[X+1,Y,pl]=0) and
                                      (TheGrid[X+2,Y,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+2,pl]=0);
  end else if (Piece=5) then begin

    if (Rotation=1) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                      (TheGrid[X+1,Y,pl]=0) and
                                      (TheGrid[X+1,Y+1,pl]=0) and
                                      (TheGrid[X+1,Y+2,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+2,Y,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0)

    else if (Rotation=3) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X,Y+2,pl]=0) and
                                           (TheGrid[X+1,Y+2,pl]=0)

    else if (Rotation=4) then OkToPlace := (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+2,Y+1,pl]=0) and
                                           (TheGrid[X+2,Y,pl]=0);
  end else if (Piece=6) then begin

    if (Rotation=1) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                      (TheGrid[X+1,Y,pl]=0) and
                                      (TheGrid[X,Y+1,pl]=0) and
                                      (TheGrid[X,Y+2,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+2,Y+1,pl]=0)

    else if (Rotation=3) then OkToPlace := (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+2,pl]=0) and
                                           (TheGrid[X,Y+2,pl]=0)

    else if (Rotation=4) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+2,Y,pl]=0) and
                                           (TheGrid[X+2,Y+1,pl]=0);
  end else if (Piece=7) then begin

    if (Rotation=1) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                      (TheGrid[X+1,Y,pl]=0) and
                                      (TheGrid[X+2,Y,pl]=0) and
                                      (TheGrid[X+1,Y+1,pl]=0)

    else if (Rotation=2) then OkToPlace := (TheGrid[X+1,Y,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+2,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0)

    else if (Rotation=3) then OkToPlace := (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0) and
                                           (TheGrid[X+2,Y+1,pl]=0) and
                                           (TheGrid[X+1,Y,pl]=0)

    else if (Rotation=4) then OkToPlace := (TheGrid[X,Y,pl]=0) and
                                           (TheGrid[X,Y+1,pl]=0) and
                                           (TheGrid[X,Y+2,pl]=0) and
                                           (TheGrid[X+1,Y+1,pl]=0);
  end else OkToPlace:=false;
end;

procedure RotatePiece(var P,R : byte; var X,Y,Pl : byte);
begin
  if RotateDir=1 then begin
    if P=1 then begin
      R:=(R mod 2) + 1;
      if R=1 then begin dec(Y); inc(X); CurrentWidth[pl]:=1; CurrentHeight[pl]:=4; end
      else if R=2 then begin inc(Y); dec(X); CurrentWidth[pl]:=4; CurrentHeight[pl]:=1; end;
    end
    else if P=2 then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=2; end
    else if P=3 then begin
       R:=(R mod 2) + 1;
       if R=1 then begin inc(Y); dec(X); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
       else if R=2 then begin inc(X); dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end;
    end
    else if P=4 then begin
       R:=(R mod 2) + 1;
       if R=1 then begin inc(Y); dec(X); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
       else if R=2 then begin inc(X); dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end;
    end
    else if P=5 then begin
      R:=(R mod 4) + 1;
      if R=1 then begin dec(Y); inc(X); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=2 then begin dec(X); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=3 then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=4 then begin inc(Y); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end;
    end
    else if P=6 then begin
      R:=(R mod 4) + 1;
      if R=1 then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=2 then begin inc(Y); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=3 then begin inc(X); dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=4 then begin CurrentWidth[pl]:=3; dec(X); CurrentHeight[pl]:=2; end;
    end
    else if P=7 then begin
      dec(R); if R=0 then R:=4;
      if R=1 then begin inc(Y); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=2 then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=3 then begin dec(X); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=4 then begin inc(X); dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end;
    end;
  end
  else if RotateDir=0 then begin
    if P=1 then begin
      dec(R); if R=0 then R:=2;
      if R=1 then begin inc(Y); dec(X); CurrentWidth[pl]:=1; CurrentHeight[pl]:=4; end
      else if R=2 then begin dec(Y); inc(X); CurrentWidth[pl]:=4; CurrentHeight[pl]:=1; end;
    end
    else if P=2 then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=2; end
    else if (P=3) or (P=4) then begin
      dec(R); if R=0 then R:=2;
      if (R=1) then begin CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if (R=2) then begin CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end;
    end

    else if P=5 then begin
      dec(R); if R=0 then R:=4;
      if R=1 then begin inc(X); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=2 then begin CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=3 then begin dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=4 then begin dec(X); inc(Y); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end;
    end
    else if P=6 then begin
      dec(R); if R=0 then R:=4;
      if R=1 then begin dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=2 then begin inc(Y); dec(X); CurrentWidth[pl]:=3; CurrentHeighT[pl]:=2; end
      else if R=3 then begin inc(X); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=4 then begin CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end;
    end
    else if P=7 then begin
      R:=(R mod 4) + 1;
      if R=1 then begin dec(X); inc(Y); CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=2 then begin dec(Y); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end
      else if R=3 then begin CurrentWidth[pl]:=3; CurrentHeight[pl]:=2; end
      else if R=4 then begin inc(X); CurrentWidth[pl]:=2; CurrentHeight[pl]:=3; end;
    end;
  end;
  if X=0 then X:=1
  else if X+CurrentWidth[pl]>11 then X:=11-CurrentWidth[pl];
  if Y=0 then Y:=1;

end;

procedure Settle(pl : byte);
  var OldColour : byte;
      Lx,Ly : byte;
begin
  if (CurrentPiece[Pl]=1) then begin

    if (Rotation[pl]=1) then begin TheGrid[PX[pl],PY[pl],pl]:=Colour[pl];
      TheGrid[PX[pl],Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl],Py[pl]+2,pl]:=COlour[pl];
      TheGrid[Px[pl],Py[pl]+3,pl]:=Colour[pl];

    end else if (rotation[pl]=2) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl]; TheGrid[Px[pl]+2,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+3,Py[pl],pl]:=Colour[pl];
    end;

  end else if (CurrentPiece[pl]=2) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
     TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl];

  end else if (CurrentPiece[pl]=3) then begin
    if (Rotation[pl]=1) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+2,Py[pl]+1,pl]:=Colour[pl];
    end else if (Rotation[pl]=2) then begin TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+2,pl]:=Colour[pl];
    end;

  end else if (CurrentPiece[pl]=4) then begin
    if (Rotation[pl]=1) then begin TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+2,Py[pl],pl]:=Colour[pl];
    end else if (Rotation[pl]=2) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+2,pl]:=Colour[pl];
    end;

  end else if (CurrentPiece[pl]=5) then begin
    if (Rotation[pl]=1) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl]+2,pl]:=Colour[pl];
    end else if (Rotation[pl]=2) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+2,Py[pl],pl]:=Colour[pl]; TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
    end else if (Rotation[pl]=3) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+2,pl]:=Colour[pl]; TheGrid[Px[pl]+1,Py[pl]+2,pl]:=Colour[pl];
    end else if (Rotation[pl]=4) then begin TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+2,Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+2,Py[pl],pl]:=Colour[pl];
    end;

  end else if (CurrentPiece[pl]=6) then begin
    if (Rotation[pl]=1) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl],Py[pl]+2,pl]:=Colour[pl];
    end else if (Rotation[pl]=2) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl],Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl]; TheGrid[Px[pl]+2,Py[pl]+1,pl]:=Colour[pl];
    end else if (Rotation[pl]=3) then begin TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+1,pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl]+2,pl]:=Colour[pl]; TheGrid[Px[pl],Py[pl]+2,pl]:=Colour[pl];
    end else if (Rotation[pl]=4) then begin TheGrid[Px[pl],Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+1,Py[pl],pl]:=Colour[pl];
      TheGrid[Px[pl]+2,Py[pl],pl]:=Colour[pl]; TheGrid[Px[pl]+2,Py[pl]+1,pl]:=Colour[pl];
    end;

  end else if (CurrentPiece[pl]=7) then begin
    if (Rotation[pl]=1) then begin TheGrid[Px[Pl],Py[Pl],pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl],pl]:=Colour[pl]; TheGrid[Px[Pl]+2,Py[Pl],pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl]+1,pl]:=Colour[pl];
    end else if (Rotation[pl]=2) then begin TheGrid[Px[Pl]+1,Py[Pl],pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl]+1,pl]:=Colour[pl]; TheGrid[Px[Pl]+1,Py[Pl]+2,pl]:=Colour[pl];
      TheGrid[Px[Pl],Py[Pl]+1,pl]:=Colour[pl];
    end else if (Rotation[pl]=3) then begin TheGrid[Px[Pl],Py[Pl]+1,pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl]+1,pl]:=Colour[pl]; TheGrid[Px[Pl]+2,Py[Pl]+1,pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl],pl]:=Colour[pl];
    end else if (Rotation[pl]=4) then begin TheGrid[Px[Pl],Py[Pl],pl]:=Colour[pl];
      TheGrid[Px[Pl],Py[Pl]+1,pl]:=Colour[pl]; TheGrid[Px[Pl],Py[Pl]+2,pl]:=Colour[pl];
      TheGrid[Px[Pl]+1,Py[Pl]+1,pl]:=Colour[pl];
    end;
  end;

  UpHeld[pl]:=9; DownHeld[pl]:=255; LeftHeld[pl]:=5; RightHeld[pl]:=5;
  OldColour:=Colour[pl]; Colour[pl]:=1; DrawPiece(OldPiece,OldRot,OldX,OldY,pl);
  Colour[pl]:=OldColour; DrawPiece(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl);
  CheckForRows(pl);
  CurrentPiece[pl]:=NextPiece[pl];
  Rotation[pl]:=NextRot[pl];
  Colour[pl]:=NextCol[pl];
  RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
  RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
  RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
  RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
  OldColour:=Colour[pl];

  if Preview=1 then begin
    Colour[pl]:=0;
    BSize:=3;
    DrawPiece(NextPiece[pl],NextRot[pl],20,-3,pl);
    BSize:=7;
    Colour[pl]:=OldColour;
  end;
  NextPiece[pl]:=random(7)+1;
  NextRot[pl]:=random(4)+1;
  if NextPiece[pl]<=4 then NextRot[pl]:=(NextRot[pl] mod 2)+1;
  if NextPiece[pl]=2 then NextRot[pl]:=1;
  NextCol[pl]:=(21+(3*random(7)))-1;
  if Preview=1 then begin
    Colour[pl]:=NextCol[pl];
    BSize:=3;
    DrawPiece(NextPiece[pl],NextRot[pl],20,-3,pl);
    BSize:=7;
    Colour[pl]:=OldColour;
  end;
  Py[pl]:=1; Px[pl]:=4; Drop[pl]:=0;
  Oldx:=Px[pl]; OldY:=Py[pl]; OldPiece:=CurrentPiece[pl]; OldRot:=Rotation[pl];
  if not OkToPlace(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl) then begin
    Alive[pl]:=false;
    if PlayMode=2 then begin
      for LX:=1 to 10 do for LY:=1 to 20 do TheGrid[lX,lY,pl]:=0;
      ReDraw(pl);
      Scores[pl]:=0;
      Alive[pl]:=true;
    end;
    for LX:=1 to 10 do for LY:=1 to 20 do if TheGrid[lX,lY,pl]>0 then TheGrid[lX,lY,pl]:=38;
    Redraw(pl);
    Colour[pl]:=(21+(3*random(7)))-1;
    DrawPiece(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl);
  end
  else DrawPiece(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl);
end;

(*************************************************************)


function GetName : string;
  var ch: string; S : string;
      B : byte;
begin
  S:='';
  clearbuf;
  repeat
    B:=TK_Readkey;
    if (B=14) and (length(S)>1) then S:=copy(S,1,length(S)-1);
    ch:=KeyName[B];
    if (length(ch)=1) and (length(s)<8) then S:=S+ch;
    t2_block(60,60,150,20,0);
    TText(60,60,S,209);
  until B=28;
  GetName:=S;
end;



procedure CheckHiScores;
  var l,L2,Rep : byte;
      ls : string;
begin
  t2_setrgb(205,0,0,0); t2_setrgb(206,0,32,32); t2_setrgb(207,0,48,48); t2_setrgb(208,0,60,60);
  t2_setrgb(209,0,0,0); t2_setrgb(210,32,5,0); t2_setrgb(211,48,10,0); t2_setrgb(212,60,15,0);
  for l:=1 to players do begin
    if Scores[l]>ScConv(HiScores[6]) then begin
      L2:=6;
      repeat
        if (Scores[l]>ScConv(HiScores[L2])) then Rep:=L2;
        dec(L2);
      until L2=0;
      if Rep<6 then for L2:=6 downto Rep+1 do HiScores[l2]:=HiScores[L2-1];
      str(l,ls);
      Ttext(40,40,'PLAYER '+LS+', ENTER YOUR NAME',205);
      str(Scores[L],Ls);
      HiScores[Rep]:=GetName+'@'+Ls;
    end;
    WriteHi;
  end;
end;

procedure InitialiseTetris;
begin
  LoadDefaults;
  t2_start(1);
  Loadfont1;
  TK_Start;
end;

Procedure GameReady;
  var X,Y,Pl : byte;
begin
  if (SoundOn) then begin
    setupSound;
  end;
  for X:=0 to 255 do t2_setrgb(X,0,0,0);
  t2_set_buf(0);
  randomize;
  PiecePalette;
  TetrisPlayField(players);
  for pl:=1 to 3 do for X:=1 to 10 do for Y:=1 to 20 do TheGrid[X,Y,pl]:=0;
  for pl:=1 to 3 do begin for X:=1 to 10 do TheGrid[X,21,pl]:=1; ReDraw(pl); end;
  for pl:=1 to players do alive[pl]:=true;
end;

(*************************************************************)


procedure HandleKeyboard(pl : byte);
  var R1,R2,R3,R4 : byte;
begin
  if LeftHeld[pl]>0 then dec(LeftHeld[pl]);
  if RightHeld[pl]>0 then dec(RightHeld[pl]);
  if UpHeld[pl]>0 then dec(UpHeld[pl]);
  if not TK_KP[LeftK[pl]] then LeftHeld[pl]:=0;
  if not TK_KP[RightK[pl]] then RightHeld[pl]:=0;
  if not TK_KP[UpK[pl]] then UpHeld[pl]:=0;
  if not TK_KP[DownK[pl]] then DownHeld[pl]:=16;
  if TK_KP[DownK[pl]] and (DownHeld[pl]<16) and (DownHeld[pl]>0) then dec(DownHeld[pl]);

  if (TK_KP[LeftK[pl]]) and (PX[pl]>1) and (LeftHeld[pl]=0) then begin
    if OkToPlace(CurrentPiece[pl],Rotation[pl],PX[pl]-1,PY[pl],pl) then begin
      dec(PX[pl]); LeftHeld[pl]:=8;
    end;
  end;

  if (TK_KP[RightK[pl]]) and (PX[pl]<=10-CurrentWidth[pl]) and (RightHeld[pl]=0) then begin
    if OkToPlace(CurrentPiece[pl],Rotation[pl],PX[pl]+1,PY[pl],pl) then begin
      inc(PX[pl]); RightHeld[pl]:=8;
    end;
  end;


  if (TK_KP[UpK[pl]]) and (UpHeld[pl]=0) then begin
    R1:=CurrentPiece[pl]; R2:=Rotation[pl]; R3:=PX[pl]; R4:=PY[pl];
    RotatePiece(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl);
    if OkToPlace(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl) then UpHeld[pl]:=8
    else begin
      CurrentPiece[pl]:=R1; Rotation[pl]:=R2; Px[pl]:=R3; Py[pl]:=R4;
    end;
  end;

  if ((tk_KP[DownK[pl]]) and ((DownHeld[pl]=16) or (DownHeld[pl]=0))) or (Drop[pl]>=DropSpeed[pl]) then begin
    if OkToPlace(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl]+1,pl) then begin
      Drop[pl]:=0;
      inc(PY[pl]);
      if DownHeld[pl]>0 then dec(DownHeld[pl]);
    end
    else Settle(pl);
  end;
end;

var ch : char;
    X,Y,Pl,OldColour : byte;
begin
  InitialiseTetris;
  repeat
    TitlePage;
    GameReady;
    for PL:=1 to players do begin
      for X:=1 to 10 do for Y:=1 to 20 do TheGrid[X,Y,pl]:=0;
      TheGrid[X,21,pl]:=1;
      Scores[pl]:=0;
      alive[pl]:=true;
      dropspeed[pl]:=30;

      Px[pl]:=5; Py[pl]:=1;
      CurrentPiece[pl]:=random(7)+1;
      Rotation[pl]:=random(4)+1;
      Colour[pl]:=(21+(3*random(7)))-1;

      NextPiece[pl]:=random(7)+1;
      NextCol[pl]:=(21+(3*random(7)))-1;
      NextRot[pl]:=random(4)+1;

      RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
      RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
      RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);
      RotatePiece(CurrentPiece[pl],Rotation[pl],Px[pl],Py[pl],pl);

      if Preview=1 then begin
        OldColour:=Colour[pl];
        Colour[pl]:=NextCol[pl];
        BSize:=3;
        DrawPiece(NextPiece[pl],NextRot[pl],20,-3,pl);
        BSize:=7;
        Colour[pl]:=OldColour;
      end;
    end;
    repeat
      for pl:=1 to players do begin
        if alive[pl] then begin
          OldX:=PX[pl]; OldY:=PY[pl]; OldPiece:=CurrentPiece[pl]; OldRot:=Rotation[pl];
          HandleKeyboard(pl);
          ClearBuf;
          inc(drop[pl]);
          if (OldX<>Px[pl]) or (OldY<>Py[pl]) or (OldRot<>Rotation[pl]) then begin
            OldColour:=Colour[pl];
            Colour[pl]:=1; DrawPiece(OldPiece,OldRot,OldX,OldY,pl);
            Colour[pl]:=OldColour; DrawPiece(CurrentPiece[pl],Rotation[pl],PX[pl],PY[pl],pl);
          end;
        end;
      end;
      t2_vretrace;
    until (TK_KP[1]) or not (alive[1] or alive[2] or alive[3]) or ((PlayMode=1) and
              ((alive[1] xor alive[2] xor alive[3]) and not (alive[1] and alive[2] and alive[3])));
    CloseScreen;
    shutsound;
    t2_block(0,0,320,200,0);
    TText(100,20,'GAME OVER',205);
    t2_setrgb(205,0,0,0); t2_Setrgb(206,32,0,0); t2_setrgb(207,48,0,0); t2_setrgb(208,60,0,0);
    t2_setrgb(209,0,0,0); t2_setrgb(210,0,32,0); t2_setrgb(211,0,48,16); t2_setrgb(212,0,60,32);

    if PlayMode=0 then begin
      CheckHiScores;
      clearbuf;
      repeat until TK_Keypressed;
    end

    else if PlayMode=1 then begin
    {Sudden death}
      if alive[1] then TText(73,60,'WINNER: PLAYER 1',209)
      else if alive[2] then TText(73,60,'WINNER: PLAYER 2',209)
      else if alive[3] then TText(73,80,'WINNER: PLAYER 3',209);
      clearbuf;
      repeat until TK_Keypressed;
    end;
    repeat until TK_Keypressed;
  until false;
end.
