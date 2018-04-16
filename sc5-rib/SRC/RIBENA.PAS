program Ribena;
uses dos,crt,ts,TD_256,berrybin,Sound,Load,MouseRMW,berryb2;
{$M $8000,0,655360}

type
  keyrec=record
    kleft,kright,kup,kdown,kCTRL,kALT,kSHIFT,kQ,kR,kY,kZ,kESC,KS,Kdel,Space: boolean;
    kF : array[1..10] of boolean;
    end;

var
  Global1,Global2,Global3,Global4 : integer;
  Potato : boolean;
  RGBs : array[0..255,1..3] of byte;
  Chan,sn,Speedrate : byte;

  fxon,muson : boolean;

  Card   : DSMCard;
  Module : PDSM;

  anint,Volume : Integer;
  ISin,Icos : array[-1256..1256] of real;
  Storeage : array[1..8,0..17,0..9,1..4] of byte;
  Berrys : array[0..17,0..9,1..4] of byte;
  Got : array[1..8,1..8] of boolean;
  MrFizzy : array[1..8] of boolean;
  MoveCheck,PlBounce,LevelNo,KeyTime : byte;
  Falling : array[1..96,1..4] of integer;
  DeadFlag,ExplodeDelay : boolean;

  KbdIntVec : Procedure;
  keydata: Keyrec;

  ScGraph,LiGraph : pointer;

  AniFlop,IconX,IconY : byte;

  Scores : array[1..10] of string[25];
  Level,Lives,Speeds : array[1..8] of byte;
  Score : array[1..8] of longint;
  SoundOn : boolean;
  StartLevel,Players,Speed : byte;
  Names : array[1..8] of string[8];
  Gadgets : array[0..8,1..8] of byte;
  Splodge,NoFallThings : byte;
  Sample : array[1..12] of PDSMInst;
  LastSound : byte;

const
    AUDIO_DIR = 'AUDIO/';
    CompleteSound = 12;
    GoverSound = 11;
    ReadySound = 10;
    SloRaspSound = 14;
    RaspSound = 9;
    LifeSound = 8;
    LitRaspSound = 13;
    BonusSound = 7;
    CaughtSound = 6;
    SquishSound = 5;
    OohSound   = 4;
    BanHSound  = 3;
    ShotSound  = 2;
    BoingSound = 1;


    LETTERS : array[0..48,0..13] of byte = {space A-Z 0-9 ,./?'!"()-}
                        ((8,0,0,0,0,0,0,0,0,0,0,0,0,0),
                        (13,0,252,254,255,55,51,51,51,51,55,255,254,252),
                        (13,0,255,255,219,219,219,219,219,219,219,255,255,118),
                        (13,0,60,126,255,231,195,195,195,195,195,195,195,195),
                        (13,0,255,255,255,195,195,195,195,195,231,255,126,60),
                        (13,0,255,255,255,219,219,219,219,219,219,219,195,195),
                        (13,0,255,255,255,27,27,27,27,27,27,27,3,3),
                        (13,0,126,255,255,195,219,219,219,219,219,251,251,114),
                        (13,0,255,255,255,24,24,24,24,24,24,255,255,255),
                        (13,0,195,195,195,195,255,255,255,255,195,195,195,195),
                        (13,0,195,195,195,195,195,195,195,195,227,255,255,127),
                        (13,0,255,255,255,24,24,24,24,60,126,231,195,129),
                        (13,0,255,255,255,192,192,192,192,192,192,192,192,192),
                        (13,0,255,255,255,14,28,56,56,28,14,255,255,255),
                        (13,0,255,255,255,7,14,28,56,112,224,255,255,255),
                        (13,0,60,126,255,231,195,195,195,195,231,255,126,60),
                        (13,0,255,255,255,51,51,51,51,51,51,63,63,30),
                        (13,0,60,126,255,231,195,195,211,179,103,207,62,60),
                        (13,0,255,255,255,51,51,51,51,51,123,255,207,134),
                        (13,0,206,223,223,219,219,219,219,219,219,251,251,115),
                        (13,0,3,3,3,3,255,255,255,255,3,3,3,3),
                        (13,0,63,127,255,224,192,192,192,192,224,255,127,63),
                        (13,0,15,31,63,112,224,192,192,224,112,63,31,15),
                        (13,0,255,255,255,112,56,28,28,56,112,255,255,255),
                        (13,0,129,195,231,126,60,24,24,60,126,231,195,129),
                        (13,0,199,207,207,204,204,204,204,204,204,255,255,127),
                        (13,0,195,227,227,243,243,211,211,207,207,199,199,195),
                        (8,0,126,255,195,195,195,255,126,0,0,0,0,0),
                        (8,0,192,196,254,255,255,192,192,0,0,0,0,0),
                        (8,0,195,227,243,223,207,198,192,0,0,0,0,0),
                        (8,0,195,195,195,219,255,255,102,0,0,0,0,0),
                        (8,0,15,31,24,24,24,255,255,0,0,0,0,0),
                        (8,0,95,223,219,219,219,251,115,0,0,0,0,0),
                        (8,0,126,255,219,219,219,251,115,0,0,0,0,0),
                        (8,0,194,227,115,59,31,15,6,0,0,0,0,0),
                        (8,0,102,255,255,219,255,255,102,0,0,0,0,0),
                        (8,0,206,223,219,219,219,255,126,0,0,0,0,0),
                        (4,0,128,224,96,0,0,0,0,0,0,0,0,0),
                        (3,0,96,96,0,0,0,0,0,0,0,0,0,0),
                        (9,0,128,192,96,48,24,12,6,3,0,0,0,0),
                        (8,0,6,7,3,219,223,15,6,0,0,0,0,0),
                        (3,0,108,108,0,0,0,0,0,0,0,0,0,0),
                        (4,0,128,236,108,0,0,0,0,0,0,0,0,0),
                        (4,0,4,7,3,0,0,0,0,0,0,0,0,0),
                        (6,0,64,239,239,239,64,0,0,0,0,0,0,0),
                        (6,0,6,6,0,6,6,0,0,0,0,0,0,0),
                        (5,0,126,255,255,129,0,0,0,0,0,0,0,0),
                        (5,0,129,255,255,126,0,0,0,0,0,0,0,0),
                        (5,0,24,24,24,24,0,0,0,0,0,0,0,0));



    ExtraScroll : byte = 1;

    Bend : array[0..109] of byte = (0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,
    10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,
    10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,8,8,7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0);

    PassWords : array[1..80] of string[8] =
       ('BANANANA','STOMMYDO','BERRYMAN','SLOSHBOD','CRINGLES','BRUSSOCK',
        'TRINDLER','CASSAGES','SHANSIDE','PRUMBELL','STROGGLE','SHUMPITS',
        'FLOMPOLE','MOOSEMAN','SCKWISCH','CHOSPILL','BOGPIPES','PANPILES',
        'SPILLAGE','CATAPIKL','BLOBALOB','DUNGFACE','ISSMELLY','GRUNSIDD',
        'SLOPULUS','TRIPANTS','GODRULES','QUANSTID','ZIGACRAB','TURBOBEN',
        'RENTAHAG','SPLUMSHA','SQWODGEL','BROGGLER','SPAMSTER','PEABRAIN',
        'SUPASLUG','WESPOWER','SPLAGARD','SHRUBULA','WOMBRIES','JAVASPUD',
        'MANKYPOD','UNDERBAG','STILYWIG','CRUMPEES','BAGGEYAK','THRONGLE',
        'ALKABANG','SPRUFTIN','VESTIBLE','INVECKLE','SLOPYWOP','MERETISH',
        'HEADFLAP','WONGFORK','CHULLOMP','PETTYWOK','HYPAFROG','CHEMALIE',
        'FUDGEHOG','SPLETCHY','DESKHEAD','QUACIALY','BASHMERE','STURGIST',
        'CORISHUS','CAMPROLL','BOVINECA','RESHZITS','FLATAJIG','STIGFLAB',
        'FLUSHERS','TWOPFISH','SLABAGOK','FLIPYKER','CONCHIBO','MUNCHPOP',
        'CLYBROID','RIBLYBOB');


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


procedure RibPalette;
  var P : pointer;
      L : byte;
begin
  P:=@RIBPAL;
  for L:=0 to 255 do begin
    RGBs[L,1]:=mem[seg(P^):Ofs(P^)+(L*3)];
    RGBS[L,2]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
    RGBS[L,3]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
  end;
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

procedure SetupSoundFx;
  var L : byte;
begin
  if not fxon then begin
    if DSMLoadSetup(Card) then begin
      writeln('Please run SETUP.EXE to configure.');
      exit;
    end;
    if DSMInit(Card) then begin
      writeln('Error Initializing the Sound System.');
      exit;
    end;
    Sample[1]:=DsmLoadSample(AUDIO_DIR+'boing.wav',0);
    Sample[2]:=DsmLoadSample(AUDIO_DIR+'shot.wav',0);
    Sample[3]:=DsmLoadSample(AUDIO_DIR+'banh.wav',0);
    Sample[4]:=DsmLoadSample(AUDIO_DIR+'Ooh.wav',0);
    Sample[5]:=DsmLoadSample(AUDIO_DIR+'squish.wav',0);
    Sample[6]:=DsmLoadSample(AUDIO_DIR+'caught.wav',0);
    Sample[7]:=DsmLoadSample(AUDIO_DIR+'bonus.wav',0);
    Sample[8]:=DsmLoadSample(AUDIO_DIR+'life.wav',0);
    Sample[9]:=DsmLoadSample(AUDIO_DIR+'rasp.wav',0);
    Sample[10]:=DsmLoadSample(AUDIO_DIR+'ready.wav',0);
    Sample[11]:=DsmLoadSample(AUDIO_DIR+'gover.wav',0);
    Sample[12]:=DsmLoadSample(AUDIO_DIR+'gladness.wav',0);

    DSMSetupVoices(4,192);
  end;
  fxon:=true;
end;

procedure ShutSoundFx;
  var L : byte;
begin
  if fxon then begin
    for L:=1 to 10 do DSmFreeSample(Sample[L]);
    dsmdone;
  end;
  fxon:=false;
end;

procedure ReadHi;
  var F : file;
      L : byte;
begin
  assign(F,'RIBENA.HI');
  reset(F,1);
  for L:=1 to 10 do
    ReadCode(F,SCORES[L]);
  close(F);
end;

procedure RandomizeElements(PlayerNo : byte);
var N1,N2,N3,N4,N5,N6,N7,N8 : boolean;
    R : real;
    X,Y,Z : byte;
begin
  N1:=false; N2:=false; N3:=false; N4:=false; N5:=false; N6:=false; N7:=false;
  for X:=0 to 255 do begin
    r:=random(200)/200;
    if R<0.25 then begin
      R:=random(150);
      z:=random(18);
      Y:=random(7);
      if (R<150) and (not N1) then begin Storeage[PlayerNo,Z,Y,2]:=1; N1:=true;  end
      else if (R<120) and (not N2) then begin Storeage[PlayerNo,Z,Y,2]:=2; N2:=true;  end
      else if (R<100) and (not N6) then begin Storeage[PlayerNo,Z,Y,2]:=6; N6:=true;  end
      else if (R<75) and (not N3) then begin Storeage[PlayerNo,Z,Y,2]:=3; N3:=true;  end
      else if (R<50) and (not N7) then begin Storeage[PlayerNo,Z,Y,2]:=7; N7:=true; end
      else if (R<25) and (not N5) then begin Storeage[PlayerNo,Z,Y,2]:=5; N5:=true; end
      else if (R<8) and (not N8) then begin Storeage[PlayerNo,Z,Y,2]:=8; N8:=true; end
      else if (R<4) and (not N4) then begin Storeage[PlayerNo,Z,Y,2]:=4; N4:=true; end;
    end;
  end;
end;

Procedure ReadLevel(PlayerNo,LNo : byte);
  var LoadIn : array[1..540] of char;
      X,Y,D : byte;
      L : integer;
      F : file;
      DirInfo : SearchRec;
begin
  X:=0; Y:=0; D:=0;
  findfirst('RIBENA.DAT',Archive,DirInfo);
  if DosError<>0 then begin t2_end; writeln('Missing level data - fatal error! Sorry - not enough data to run the game.');
                                    writeln('See accompanying text file on contacting us, and downloading WCT freeware.');
                                    writeln; halt; end;
  assign(F,'RIBENA.DAT');
  reset(F,1);
  for L:=1 to LNo do begin
    blockread(F,D,1);
    blockread(F,LoadIn,540);
  end;
  L:=1; X:=0; Y:=0;
  repeat
    Storeage[PlayerNo,X,Y,1]:=ord(Loadin[L]);
    Storeage[PlayerNo,X,Y,2]:=0;
    Storeage[PlayerNo,X,Y,3]:=ord(Loadin[L+1]);
    Storeage[PlayerNo,X,Y,4]:=ord(Loadin[L+2]);
    inc(L,3);
    inc(X);
    if X=18 then begin X:=0; inc(Y); end;
  until L>=541;
  close(F);
  RandomizeElements(PlayerNo);
end;

Procedure SPLAY(n,bantype : byte; ExpFlag : boolean);
var nn : byte;
    Freq : longint;

begin
  if (n=BanhSound) and (LastSound=n) then exit;
  LastSound:=n;
  nn:=n;
  if (n=SloRaspSound) or (n=LitRaspSound) then nn:=RaspSound;
  Freq:=11025;
  if n=CompleteSound then Freq:=6000;
  if n=GoverSound then Freq:=6500;
  if n=BonusSound then Freq:=11000;
  if n=Readysound then Freq:=5610;
  if n=SquishSound then Freq:=12000;
  if n=LifeSound then Freq:=6000;
  if n=ShotSound then Freq:=28050;
  if n=BoingSound then Freq:=22000;
  if n=OohSound then Freq:=20050+random(6000);
  if n=CaughtSound then Freq:=14000+random(5000);
  if n=SloRaspSound then Freq:=6000;
  if n=LitRaspSound then Freq:=14000+random(12000);
  if n=RaspSound then Freq:=12000;
  if n=BanhSound then begin
    Freq:=30050-(BanType*2000);
    if ExpFlag then Freq:=Freq div 2;
    if Freq<8000 then Freq:=8000;
  end;
  mouseinfo; if n=GoverSound then mouse.right:=false;
  DSMPlaySample(Chan,Sample[nn]);
  if not mouse.right then DsmSetPeriod(chan,trunc(8363*428/Freq));
  if mouse.right then DsmSetPeriod(chan,trunc(4181*428/Freq));
  dsmpoll;
  chan:=chan+1;
  if chan=4 then chan:=0;
end;

procedure WriteDefaultIni;
  var F : text;
begin
  assign(F,'RIBENA.INI');
  rewrite(F);
  writeln(F,'SOUND=YES');
  writeln(F,'PLAYERS=1');
  writeln(F,'LEVEL=1');
  writeln(F,'SPEED=1');
  writeln(F,'NAME1=PLAYER 1');
  writeln(F,'NAME2=PLAYER 2');
  writeln(F,'NAME3=PLAYER 3');
  writeln(F,'NAME4=PLAYER 4');
  writeln(F,'NAME5=PLAYER 5');
  writeln(F,'NAME6=PLAYER 6');
  writeln(F,'NAME7=PLAYER 7');
  writeln(F,'NAME8=PLAYER 8');
  close(F);
end;

procedure ZeroPalette;
  var L : byte;
begin
  for L:=0 to 255 do t2_setrgb(L,0,0,0);
end;

function ScConv(S : string) : longint;
  var Code : integer;
      Temp : longint;
begin
  val(copy(S,pos('@',S)+1,length(S)-pos('@',S)),Temp,Code);
  ScConv:=Temp;
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
  assign(F,'RIBENA.HI');
  rewrite(F,1);
  for L:=1 to 10 do
    WriteCode(F,SCORES[L]);
  close(F);
end;

procedure ReadIni;
  var F : text;
      PNo : byte;
      S : string[25];
      s1 : string[1];
      code : integer;
begin
  assign(F,'RIBENA.INI');
  reset(F);
  repeat
    readln(F,S);
    if copy(S,1,5)='SOUND' then begin
      S:=copy(S,7,length(S)-6);
      Soundon:=(S='YES');
    end;
    if copy(S,1,5)='LEVEL' then begin
      S:=copy(S,7,length(S)-6);
      val(S,StartLevel,code);
    end;
    if copy(S,1,7)='PLAYERS' then begin
      S:=copy(S,9,length(S)-8);
      val(S,Players,code);
    end;
    if copy(S,1,5)='SPEED' then begin
      S:=copy(S,7,length(S)-6);
      val(S,Speed,code);
    end;
    if copy(S,1,4)='NAME' then begin
      S1:=copy(S,5,1);
      val(S1,PNo,code);
      S:=copy(S,7,8);
      Names[PNo]:=S;
      if S='' then Names[PNo]:='PLAYER'+S1;
    end;
  until eof(F);
  close(F);
end;

procedure WriteIni;
  var F : text;
      L : byte;
      S : string[25];
begin
  assign(F,'RIBENA.INI');
  rewrite(F);
  write(F,'LEVEL=');
  writeln(F,StartLevel);
  write(F,'SPEED=');
  writeln(F,Speed);
  write(F,'PLAYERS=');
  writeln(F,Players);
  write(F,'SOUND=');
  if Soundon then writeln(F,'YES');
  if not Soundon then writeln(F,'NO');
  for L:=1 to 8 do begin
    write(F,'NAME');
    str(L,S);
    write(F,S);
    write(F,'=');
    writeln(F,Names[L]);
  end;
  close(F);
end;

procedure WriteDefaultHi;
  var F : file;
begin
  assign(F,'RIBENA.HI');
  rewrite(F,1);
  WriteCode(F,'ben@10000');
  WriteCode(F,'tom@5000');
  WriteCode(F,'chris@4000');
  WriteCode(F,'wes@3000');
  WriteCode(F,'rich@2000');
  WriteCode(F,'andy@1000');
  WriteCode(F,'jon@800');
  WriteCode(F,'sam@600');
  WriteCode(F,'ed@400');
  WriteCode(F,'slap@200');
  close(F);
end;

procedure LoadDefaults;
  var DirInfo : SearchRec;
begin
  findfirst('RIBENA.INI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultIni;
  findfirst('RIBENA.HI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultHi;
  ReadIni;
  ReadHi;
end;

function LCon(ch : Char) : byte;
begin
  Lcon:=pos(upcase(ch),' ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,./?:;''!"()-')-1;
end;

function LitCon(Ch : CHar) : byte;
begin
  LitCon:=pos(upcase(ch),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ');
end;

function Centre(S : string) : byte;
  var W : integer;
      L : byte;
begin
  W:=0;
  for L:=1 to length(S) do begin
    if (S[L]<>' ') and (S[L]<>'-') and (S[L]<>'.') and (S[L]<>',') then
      W:=W+Wid[LitCon(S[L])];
    if (S[L]=' ') or (S[L]='.') or (S[L]=',') then W:=W+4;
    if S[L]='-' then W:=W+6;
  end;
  Centre:=160-trunc(W/2);
end;

function Rig(XX : integer; S : string) : byte;
  var W : integer;
      L : byte;
begin
  W:=0;
  for L:=1 to length(S) do begin
    if (S[L]<>' ') and (S[L]<>'-') and (S[L]<>'.') and (S[L]<>',') then
      W:=W+Wid[LitCon(S[L])];
    if (S[L]=' ') or (S[L]='.') or (S[L]=',') then W:=W+4;
    if S[L]='-' then W:=W+6;
  end;
  Rig:=XX-trunc(W);
end;

procedure LittleText(X : integer; Y : byte; S : string);
  var L : byte;
      Ix : integer;
      St : string[80];
begin
  Ix:=X; St:=s;
  for L:=1 to length(ST) do begin
    if (St[1]<>' ') and (ST[1]<>'.') and (ST[1]<>',') AND (ST[1]<>'-') then begin
      if St[1]='1' then inc(Ix,3);
      t2_putpic(Ix,Y+FOfs[LitCon(ST[1])],Alpha[LitCon(ST[1])]);
      if St[1]='1' then dec(IX,3);
      Ix:=Ix+Wid[LitCon(St[1])];
    end;
    if St[1]=' ' then IX:=Ix+4;
    if St[1]='.' then begin
      t2_dot(IX+1,Y+7,15); t2_dot(IX+2,Y+7,15);
      t2_dot(Ix+1,Y+6,15); t2_dot(IX+2,Y+6,15);
      t2_dot(Ix,Y+6,8); t2_dot(Ix,Y+7,8);
      t2_dot(Ix+1,Y+8,8); t2_dot(Ix+2,Y+8,8); inc(Ix,5);
    end;
    if St[1]=',' then begin
      t2_dot(IX+1,Y+7,15); t2_dot(IX+2,Y+7,15);
      t2_dot(Ix+2,Y+6,15); t2_dot(IX+3,Y+6,15);
      t2_dot(Ix+1,Y+6,8); t2_dot(Ix,Y+7,8);
      t2_dot(Ix+1,Y+8,8); t2_dot(Ix+2,Y+8,8); inc(Ix,5);
    end;
    if St[1]='-' then begin
      t2_line(IX+1,y+5,ix+4,y+5,15);
      t2_line(IX+1,y+6,Ix+5,y+6,8);
      t2_dot(Ix,y+5,8);
      inc(Ix,6);
    end;
    St:=copy(St,2,length(st)-1);
  end;
end;

procedure CenLittleText(Y : byte; S : string);
begin
  LittleText(Centre(S),Y,S);
end;

procedure RigLittleText(X : integer; Y : byte; S : string);
begin
  LittleText(Rig(X,S),Y,S);
end;

procedure PlotLetter(X : integer; Y : byte; S : char; Col : byte);
  var L,TX,TY : byte;
begin
  for L:=1 to Letters[Lcon(S),0] do begin
    TX:=Letters[Lcon(S),L];
    TY:=Y;
    repeat
      if (TX and 1)=1 then t2_dot(X+(2*(L-1)),TY,Col+(((Ty-y)-4)));
      Tx:=TX div 2;
      Ty:=Ty+2;
    until Tx=0;
  end;
end;

procedure PlotString(X : integer; Y : byte; St : string;Col : byte);
  var LT : integer;
      L : byte;
begin
  LT:=X;
  for L:=1 to length(st) do begin
    PlotLetter(LT,Y,ST[L],Col);
    LT:=LT+(Letters[Lcon(ST[L]),0]*2)+2;
  end;
end;


procedure NoFadein;
  var L : byte;
begin
  for L:=0 to 255 do
    t2_setrgb(L,RGBs[L,1],RGBs[L,2],RGBS[L,3]);
end;

procedure Fadein(ds : boolean);
var RGB2 : array[0..255,1..3] of byte;
    L : byte;
    Yes : boolean;
begin
  for L:=0 to 255 do begin
    RGB2[L,1]:=0;
    RGB2[L,2]:=0;
    RGB2[L,3]:=0;
  end;
  repeat
    Yes:=false;
    for L:=0 to 255 do begin
      if RGB2[L,1]<RGBs[L,1] then begin Yes:=true; inc(RGB2[L,1]); end;
      if RGB2[L,2]<RGBs[L,2] then begin Yes:=true; inc(RGB2[L,2]); end;
      if RGB2[L,3]<RGBs[L,3] then begin Yes:=true; inc(RGB2[L,3]); end;
      t2_setrgb(L,RGB2[L,1],RGB2[L,2],RGB2[L,3]);
    end;
    if ds then dsmpoll;
    t2_Vretrace;
  until not Yes;
end;

procedure FadeOut(ds : boolean);
var   RGB2 : array[0..255,1..3] of byte;
      L : byte;
      Yes : boolean;
begin
  t2_getrgb(14,RGBS[14,1],RGBS[14,2],RGBS[14,3]);
  for L:=0 to 255 do begin
    RGB2[L,1]:=RGBS[L,1];
    RGB2[L,2]:=RGBS[L,2];
    RGB2[L,3]:=RGBS[L,3];
  end;
  if ds then dsmpoll;
  repeat
    Yes:=false;
    for L:=0 to 255 do begin
      if RGB2[L,1]>0 then begin Yes:=true; dec(RGB2[L,1]); end;
      if RGB2[L,2]>0 then begin Yes:=true; dec(RGB2[L,2]); end;
      if RGB2[L,3]>0 then begin Yes:=true; dec(RGB2[L,3]); end;
      t2_setrgb(L,RGB2[L,1],RGB2[L,2],RGB2[L,3]);
    end;
    if ds then dsmpoll;
    t2_Vretrace;
  until not Yes;
end;

procedure CLEARBUF;
begin
  inline($fa);
  memw[$40:$1A]:=memw[$40:$1C];
  inline($fb);
end;

procedure ShowHi(d : boolean);
  var L : byte;
      S : string[25];
begin
  startinterrupt;
  t2_block(52,52,224,148,0);
  for L:=1 to 10 do
    LittleText(93,52+(L*12),'. . . . . . . . . . . . . ');

  for L:=1 to 10 do begin
    if Scores[L][1]<>'@' then LittleText(93,52+(12*L),copy(Scores[L],1,pos('@',Scores[L])-1));
    S:=copy(Scores[L],pos('@',Scores[L])+1,length(Scores[L])-pos('@',Scores[L]));
    RigLittleText(236,52+(12*L),S);
  end;

  if d then begin
    clearbuf;
    repeat
      LittleText(Centre('PRESS ANY KEY'),187,'PRESS ANY KEY');
    until keypressed;
    Clearbuf;
    t2_block(52,52,224,148,0);
  end;
  ShutInterrupt;
end;

function GetStrHi(x : integer; y : byte;Mus : boolean) : string;
  var S : string[25];
      L : byte;
      ch : char;
begin
  S:='';
  clearbuf;
  repeat
    t2_block(x,y,108,20,0);
    LittleText(X,Y,S+'-');
    Clearbuf;
    repeat
      if not keypressed then ch:=chr(0);
      if keypressed then ch:=upcase(Readkey);
    until ((ch>='A') and (ch<='Z')) or (ch=' ') or (ch=chr(13)) or (ch=chr(8));
    if (ch<>chr(13)) and (ch<>chr(8)) then S:=S+ch;
    if (ch=chr(8)) and (length(S)>0) then S:=copy(S,1,length(S)-1);
    if (length(S)>12) then S:=copy(S,1,12);
  until ch=chr(13);
  GetStrHi:=S;
end;

procedure DelKey(ds : boolean);
  var L : byte;
begin
  if ds then dsmpoll;
  ClearBuf;
  L:=0;
  repeat
    inc(L);
    if ds then dsmpoll;
    t2_vretrace;
  until (L>80) or keypressed;
end;

procedure CheckHiScores(M : byte);
var NewPlaces : Array[1..10] of byte;
    ExitFlag : boolean;
    L,J,K : Byte;
    S : string[25];
begin
  for L:=1 to 10 do NewPlaces[L]:=0;
  for L:=1 to M do begin
    if Score[L]>ScConv(Scores[10]) then begin
      J:=10;
      repeat
        if Score[L]>ScConv(Scores[J]) then dec(J);
        ExitFlag:=false;
        if J=0 then ExitFlag:=true;
        if J>0 then if (Score[L]<=ScConv(Scores[J])) then ExitFlag:=true;
      until ExitFlag;
      inc(J);
      if J=10 then begin NewPlaces[10]:=L; str(Score[L],Scores[10]); end;
      if J<10 then begin
        for K:=10 downto J+1 do begin
          Scores[K]:=Scores[K-1];
          NewPlaces[K]:=NewPlaces[K-1];
        end;
        NewPlaces[J]:=L; str(Score[L],Scores[J]);
      end;
    end;
  end;
  for L:=1 to 10 do
    if NewPlaces[L]<>0 then begin
      t2_block(0,0,320,200,0);
      ZeroPalette;
      if copy(Names[NewPlaces[L]],1,6)='PLAYER' then begin
        PlotString(21,30,'ENTER YOUR',68);
        PlotString(100,60,'NAME',68);
        str(NewPlaces[L],S);
        S:='PLAYER '+S;
        PlotString(62,90,S,94);
        Fadein(false);
        S:='';
        S:=getstrhi(130,120,false);
        for K:=1 to length(S) do
          if (ord(S[L])>=65) and (ord(S[L])<=90) then S[L]:=chr(ord(S[L])+32);
        Names[NewPlaces[L]]:=S;
        Fadeout(false);
      end;
      S:=Names[NewPlaces[L]];
      Scores[L]:=S+'@'+Scores[L];
    end;
  WriteHi;
  t2_block(0,0,320,200,0);
  PlotString(65,0,'HALL OF',68);
  PlotString(108,28,'FAME',94);
  ShowHi(false);
  for L:=1 to 10 do begin
    if NewPlaces[L]<>0 then begin
      t2_putpic(70,50+(L*12),BBMP[1,L]);
      t2_putpic(250,50+(L*12),BBMP[1,L]);
    end;
  end;
  fadein(false);
  delkey(false);
  fadeout(false);
  t2_block(0,0,320,200,0);

end;

{F+}
procedure Keyclick; interrupt;
var Pval : byte;
    val : boolean;
begin
  Pval:=Port[$60];
  val:=true;
  if Pval >= $80 then begin
    val:=false;
    dec(PVal,$80);
  end;
  if Pval=$1D then keydata.kCTRL:=val
  else if Pval=$60 then keydata.kCTRL:=val
  else if Pval=$38 then keydata.kALT:=val
  else if Pval=$2A then keydata.kSHIFT:=val
  else if Pval=$36 then keydata.kSHIFT:=val
  else if Pval=$48 then keydata.kUP:=val
  else if Pval=$50 then keydata.kDOWN:=val
  else if Pval=$4B then keydata.kLEFT:=val
  else if Pval=$4D then keydata.kRIGHT:=val
  else if Pval=16 then keydata.kQ:=val
  else if Pval=19 then keydata.kR:=val
  else if Pval=21 then keydata.kY:=val
  else if Pval=44 then keydata.kZ:=val
  else if Pval=1 then keydata.KESC:=val
  else if Pval=31 then keydata.KS:=val
  else if Pval=83 then keydata.KDEL:=val
  else if Pval=57  then keydata.SPACE:=val
  else if (Pval>=59) and (Pval<=68) then keydata.kF[Pval-58]:=val;
  inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  KbdIntVec;
end;
{$F-}

procedure ShutSound;
begin
  if muson then begin
    DSMStopMusic;
    DSMFree(Module);
    DSMDone;
  end;
  muson:=false;
end;

procedure JUMPOUT;
begin
  shutsoundfx;
  SetIntVec($9,@KbdIntVec);
  t2_end;
  TextMode(CO80);
  ClrScr;
  Writeln('                          ---- SHOOTING CHEDDERY ----');
  Writeln('                                       5'); writeln;
  Writeln('                             SHOOTING  RIBENABERRY'); writeln;
  Writeln('                    WCT Entertainment. Copyright,  April 1998');
  Writeln;
  Writeln('                           Main Programming......Wes');
  Writeln('                           Technical Support.....Tom');
  Writeln;
  Writeln;
  StartLevel:=1; WriteIni;
  halt;
end;

Procedure DecodeLetter(D : byte; var CODES : array of byte);
  var L : byte;
begin
  for L:=0 to 7 do begin
    CODES[L]:=D and 1;
    D:=D shr 1;
  end;
end;

procedure InitCos;
  var L : Integer;
begin
  for L:=-1256 to 1256 do
    Icos[L]:=cos(L/200);
end;

procedure InitSin;
  var L : integer;
begin
  for L:=-1256 to 1256 do
    Isin[L]:=sin(L/200);
end;


procedure SetupSound;
  var L : byte;
begin
  if (not muson) then begin
    if DSMLoadSetup(Card) then begin
      writeln('Please run SETUP.EXE to configure.');
      exit;
    end;
    if DSMInit(Card) then begin
      writeln('Error Initializing the Sound System.');
      exit;
    end;
    Module := DSMLoad(AUDIO_DIR+'ribena.dsm',0);
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
    DSMSetMusicVolume(255);
    DsmPlayMusic(Module);
  end;
  muson:=true;
end;

procedure GamePlot;
begin
  StartInterrupt;
  t2_block(52,52,224,148,0);
  CenLittleText(52,'  YOUR MISSION - USE YOUR WEAPONRY TO');
  CenLittleText(64,'LIBERATE THE BERRIES FROM THEIR COMA.');
  CenLittleText(76,'MAKE USE OF THE ANGULAR ARCHITECTURE,');
  CenLittleText(88,'AND FLEXIBILITY OF YOUR BANANA, TO HELP');
  CenLittleText(100,'EVERY LAST BERRY ON EACH LEVEL, THAT');
  CenLittleText(112,'CAN BE LIBERATED. LOOK OUT FOR GADGETS');
  CenLittleText(124,'WHICH THE WCT EXPERTS HAVE SENT OUT TO');
  CenLittleText(136,'YOU TO HELP YOU ON YOUR MISSION. MOST');
  CenLittleText(148,'ARE GOOD, BUT SOME ARE SENT FROM ANDY.');
  CenLittleText(160,'TRY TO CATCH FALLING BERRIES, AS THEY');
  CenLittleText(172,'PLUMMET IN THEIR NEWLY LIBERATED STATE.');

  CenLittleText(187,'PRESS ANY KEY');
  Clearbuf;

  repeat until keypressed;
  clearbuf;
  t2_block(52,52,224,148,0);
  CenLittleText(52,'CONTROLS');
  CenLittleText(76,'MOUSE - MOVE BANANA');
  CenLittleText(88,'LEFT BUTTON - LAUNCH CHED, USE GADGET');
  CenLittleText(100,'RIGHT BUTTON - SPEED UP ACTION');
  CenLittleText(124,'UP-DOWN ARROWS - BEND THE BANANA');
  CenLittleText(136,'LEFT-RIGHT ARROWS - SELECT GADGET');
  CenLittleText(160,'ESCAPE - GIVE UP');
  CenLittleText(187,'PRESS ANY KEY');
  clearbuf;
  repeat until keypressed;
  clearbuf;
  t2_block(52,52,224,148,0);
  CenLittleText(52,'WCT GADGETRY DEPARTMENT');
  t2_putpic(60,73,@IC1); t2_putpic(60,89,@IC2); t2_putpic(60,105,@IC3);
  t2_putpic(60,121,@IC4);
  t2_putpic(251,73,@IC5); t2_putpic(251,89,@IC6);
  t2_putpic(251,105,@IC7); t2_putpic(251,121,@IC8);
  LittleText(80,75,'STRETCHER'); LittleText(80,91,'LASER');
  LittleText(80,107,'EXTRA LIFE'); LittleText(80,123,'NUCLEAR BOMB');
  RigLittleText(246,75,'ANDYS REVENGE'); RigLittleText(246,91,'MR. FIZZ');
  RigLittleText(246,107,'RADIO-BANANA'); RigLittleText(246,123,'RADIO-CHED');
  CenLittleText(187,'PRESS ANY KEY');
  clearbuf;
  repeat until keypressed;

  clearbuf;
  t2_block(52,52,224,148,0);
  ShutInterrupt;

end;

procedure Opts;
  var s,st,ps : string[25];
      l : byte;
      ch : char;
begin
  StartInterrupt;
  t2_block(52,52,224,148,0);
  If Potato then begin
    t2_putpic(245,54,@MRFIZZ);
  end;
  repeat
    t2_vretrace;

    S:='S - GAME SOUNDS - ';
    if SoundON then S:=S+'ON';
    if not SoundOn then S:=S+'OFF';
    t2_block(100,65,120,14,0);
    LittleText(Centre(S),65,S);
    t2_block(100,80,120,14,0);
    S:='L - START LEVEL - ';
    str(StartLevel,ST); S:=S+St;
    LittleText(Centre(S),80,S);
    s:='G - GAME SPEED - ';
    str(SPEED,st); s:=s+st;
    t2_block(100,95,120,14,0);
    LittleText(Centre(S),95,S);
    S:='P - PLAYERS - ';
    str(PLAYERS,st); S:=s+st;
    t2_block(100,110,120,14,0);
    LittleText(Centre(S),110,S);
    S:='N - EDIT NAMES';
    LittleText(Centre(S),125,S);
    t2_block(55,180,210,19,0);
    Clearbuf;
    LittleText(Centre('ANY OTHER KEY TO CONTINUE'),180,'ANY OTHER KEY TO CONTINUE');
    repeat until keypressed;
    t2_block(55,180,210,19,0);
    ch:=upcase(readkey);
    if ch='P' then inc(Players);
    if Players=9 then Players:=1;
    if ch='G' then inc(Speed);
    if Speed=8 then Speed:=1;
    if ch='L' then begin
      PlotString(50,150,'PASSWORD',68);
      PS:=GetStrHi(130,180,true);
      Clearbuf;
      StartLevel:=1;
      for L:=1 to 40 do
        if Passwords[L]=Ps then StartLevel:=L;
      if Ps='MOOSEBREATH' then begin
        Potato:=not Potato;
        t2_block(245,54,30,30,0);
        if Potato then t2_putpic(245,54,@MRFIZZ);
      end;
      t2_block(50,137,225,53,0);
    end;
    if ch='S' then SoundOn:=not SoundOn;
    if ch='N' then begin
      for L:=1 to Players do begin
        t2_block(50,137,225,53,0);
        str(L,S);
        S:='PLAYER '+S;
        PlotString(62,150,S,68);
        PS:=GetStrHi(130,180,true);
        str(L,S);
        if Ps='' then Ps:='PLAYER '+S;
        Names[L]:=Ps;
        Clearbuf;
      end;
      t2_block(50,137,225,53,0);
    end;
    t2_vretrace;
  until (ch<>'S') and (ch<>'L') and (ch<>'G') and (ch<>'P') and (ch<>'N');
  t2_block(52,52,224,148,0);
  t2_vretrace;
  WriteIni;
  ShutInterrupt;
end;

procedure TitlePage;
var
    ch: char;
    FirstTimeFlag : boolean;
    Oldx,Oldy,X,Y : array[1..16] of byte;
    L,PixCount,Bx,By,First,loop,loop2,Ani,Array_S,Array_F,No_Bobs : byte;
    rot : real;
    ExitFlag,Toggle : boolean;
    ExPlode,LetCount,xq,yq : integer;
    xqs,yqs : real;
    Anid : shortint;
    Strip : array[0..7] of byte;
    Screen : array[0..109,0..7] of byte;


const
    SCROLLText : array[1..10] of string =
    (' WCT ENTERTAINMENT PRESENTS ...... SHOOTING CHEDDERY V .....',
     '. SHOOTING RIBENABERRY ...... HAPPY BIRTHDAY BEN! ......    ',
     'P - PLAY ... H - HISCORES ... G - GAMEPLAN ... O - OPTIONS  .',
     '...     DESIGN, CODING, MUSIC : WES ... 256-COLOUR MODE, KEY',
     'BOARD, MATHS ANALYSIS : TOM ... DESIGN HELP : CHRIS ... SOUN',
     'D EFFECTS TEAM : RICH, JON, WES, ED, SAM ....... BETA TESTER',
     'S : TEAM A: WES, RICH, SAM, JAMIE, KARIM, JON, ED ... TEAM B',
     ': CHRIS, DAVE, MARK, JOY ... TEAM C: SARAH, ANDI ... TEAM D:',
     ' JOY, SAM ... TEAM E: FRANS, DEB .... TEAM F: FIONA, ALISON ',
     '....   COPYRIGHT WCT ENTERTAINMENT, APRIL 1998             œ');



begin
  t2_block(0,0,320,200,0);
  Potato:=false;
  First:=0;
  LetCount:=1; PixCount:=0;  rot:=0;
  ExitFlag:=False; Toggle:=True;
  Xq:=628; Yq:=Xq;
  Xqs:=Xq/100;
  Yqs:=Yq/100;
  InitSin;  InitCos;
  Ani:=1; Anid:=1;
  Array_S:=0; Array_F:=Array_S; No_Bobs:=Array_S;
  ZeroPalette;
  t2_putpic(2,0,@srib);
  t2_putpic(0,55,@tleft);
  t2_putpic(274,55,@tright);
  ribpalette;
  FirstTimeFlag:=true;
  Randomize;
  for loop:=0 to 109 do
    for loop2:=0 to 7 do
      Screen[Loop,Loop2]:=0;
  for loop:=0 to 7 do
    Strip[loop]:=0;
  X[1]:=0; Y[1]:=0;
  SetupSound;
  NoFadein;
  Repeat
    For loop:=1 to 16 do begin
      Oldx[loop]:=X[loop];
      Oldy[loop]:=Y[loop];
      X[loop]:=round(160-(80*isin[round(200*((loop/16)*xqs+rot)) mod 1256]));
      Y[loop]:=round(103+(40*icos[round(200*((loop/16)*yqs+rot)) mod 1256]));
      if FirstTimeFlag then begin
        Oldx[loop]:=X[loop];
        Oldy[loop]:=Y[loop];
      end;
    end;
    FirstTimeFlag:=false;
    dsmpoll;
    rot:=rot+0.05;
    yq:=(yq mod 1256)+1;
    yqs:=12.56+(25.12*(isin[yq]));
    if yq mod 5=0 then xq:=(xq mod 1256)+1;
    xqs:=(628+(628*(isin[xq])))/100;
    t2_vretrace;
    for loop:=1 to 16 do
      t2_block(Oldx[loop],Oldy[loop],14,14,0);
    for loop:=1 to 16 do
      t2_putbakpic(X[loop],Y[loop],BBMP[ani,(loop+1) div 2]);

    toggle:=not toggle;
    if toggle then begin
      ani:=ani+anid;
      if (ani=1) or (ani=3) then anid:=-anid;
    end;
    dsmpoll;
    inc(PixCount);
    if PixCount>Letters[Lcon(ScrollText[1+(LetCount div 60)][1+(LetCount mod 60)]),0] then begin
      PixCount:=1;
      inc(LetCount);
      if ScrollText[1+(LetCount div 60)][2+(LetCount mod 60)]='œ' then LetCount:=1;
    end;
    DecodeLetter(Letters[LCon(ScrollText[1+(LetCount div 60)][1+(LetCount mod 60)]),PixCount],Strip);
    for L:=0 to 7 do
      Screen[First,L]:=(162+(abs(3-L)*2))*Strip[L];
    DSMPoll;
    Bx:=0; By:=0;
{    t2_vretrace;}
    repeat
      repeat
        if (Bx shl 1)>0 then t2_dot(50+(Bx shl 1),173+Bend[BX]+(By shl 1),Screen[(Bx+First) mod 110,By]);
        inc(Bx);
      until Bx>109;
      DSMPoll;
      Bx:=0;
      inc(By);
    until By>7;
    First:=(First+1) mod 110;
    mouseinfo;

    if keypressed or (mouse.left) then begin
      ch:='Z';
      if keypressed then ch:=upcase(Readkey);
      mouseinfo;
      ExitFlag:=(CH='P')  or (ch=chr(27)) or (mouse.left);
      if ch='G' then GamePlot;
      if ch='H' then ShowHi(true);
      if ch='O' then Opts;
    end;
    dsmpoll;
  until ExitFlag;
  ShutSound;
  for ExPlode:=4 to 11 do begin
    for loop:=1 to 16 do
      t2_block(X[loop],Y[loop],14,14,0);
    for loop:=1 to 16 do
      t2_putbakpic(X[loop],Y[loop],BBMP[ExPlode,(loop+1) div 2]);
    delay(30);
    t2_vretrace;
  end;
  for loop:=1 to 16 do
    t2_block(X[loop],Y[loop],14,14,0);
  FadeOut(false);
  ZeroPalette;
  SetupSoundFx;
  if ch=chr(27) then JumpOut;
end;

procedure DrawBorder;
begin
  t2_line(60,0,319,0,7);
  t2_line(60,0,60,199,7);
  t2_line(60,199,319,199,7);
  t2_line(319,0,319,199,7);
end;

procedure SPB(X,Y : integer);
  VAR xb,yb : byte;
begin
  if Berrys[X,Y,1]<>0 then begin
    XB:=(Berrys[X,Y,1] div 11)+1;
    YB:=(Berrys[X,Y,1] mod 11)+1;
    if Berrys[X,Y,1]<=11 then Xb:=1;
    t2_putpic(66+(X*14),1+(Y*14),BBMP[Xb,Yb]);
  end;
end;

procedure PlotBerries(OldCx,OldCy : real);
  var Q,X : byte;
      Tx,Ty : integer;
begin
  Ty:=trunc(Oldcy-1) div 14;
  Tx:=trunc(OldcX-66) div 14;
  if ty<10 then begin
    SPB(tx,ty);
    if tx<17 then SPB(1+tx, ty);
  end;
  if ty<9 then begin
    SPB(tx,1+ty);
    if tx<17 then SPB(1+tx,1+ty);
  end;
end;

function LoadLevel(PlayerNo : byte) : integer;
  var X,Y : byte;
      Total : integer;
begin
  randomize;
  Total:=0;
  for X:=0 to 17 do for Y:=0 to 9 do begin
    Berrys[X,Y,1]:=Storeage[PlayerNo,X,Y,1];
    Berrys[X,Y,2]:=Storeage[PlayerNo,X,Y,2];
    Berrys[X,Y,3]:=Storeage[PlayerNo,X,Y,3];
    Berrys[X,Y,4]:=Storeage[PlayerNo,X,Y,4];
    if (Berrys[X,Y,3]<>0) and (Berrys[X,Y,1]<>0) then inc(Total);
  end;
  LoadLevel:=Total;
  for X:=1 to 64 do
    for Y:=1 to 4 do
      Falling[X,Y]:=0;
end;

procedure SaveLevel(PlayerNo : byte);
  var X,Y : byte;
begin
  for X:=0 to 17 do for Y:=0 to 9 do begin
    Storeage[PlayerNo,X,Y,1]:=Berrys[X,Y,1];
    Storeage[PlayerNo,X,Y,2]:=Berrys[X,Y,2];
    Storeage[PlayerNo,X,Y,3]:=Berrys[X,Y,3];
    Storeage[PlayerNo,X,Y,4]:=Berrys[X,Y,4];
  end;
end;

procedure EraseBanana(XPos : integer; ExpandFlag : boolean);
begin
  if not ExpandFlag then t2_block(XPos,180,41,19,0);
  if ExpandFlag then t2_block(Xpos,180,84,19,0);
end;

procedure PutBanana(XPos : integer; BanType : byte; LasFlag,ExpandFlag : boolean);
  var Tot : byte;
begin
  Tot:=BanType+Splodge;
  if not (LasFlag or ExpandFlag) then begin
    if Tot=1 then t2_putpic(XPos,180,@BAN1)
    else if tot=2 then t2_putpic(XPos,180,@BAN2)
    else if tot=3 then t2_putpic(XPos,180,@BAN3)
    else if tot=4 then t2_putpic(XPos,180,@BAN4)
    else if tot>=5 then t2_putpic(XPos,180,@BAN5);
  end else if ExpandFlag then begin
    if tot=1 then t2_putpic(XPos,180,@BIGBAN1)
    else if tot=2 then t2_putpic(XPos,180,@BIGBAN2)
    else if tot=3 then t2_putpic(XPos,180,@BIGBAN3)
    else if tot=4 then t2_putpic(XPos,180,@BIGBAN4)
    else if tot>=5 then t2_putpic(XPos,180,@BIGBAN5);
  end else if LasFlag then begin
    if tot=1 then t2_putpic(XPos,180,@LASBAN1)
    else if tot=2 then t2_putpic(XPos,180,@LASBAN2)
    else if tot=3 then t2_putpic(XPos,180,@LASBAN3)
    else if tot=4 then t2_putpic(XPos,180,@LASBAN4)
    else if tot>=5 then t2_putpic(XPos,180,@LASBAN5);
  end;
  if Splodge>=1 then dec(Splodge);
end;

procedure UnPlotChed(var X,Y : real);
begin
  if X<62 then X:=62;
  if X>311 then X:=311;
  t2_block(trunc(X),trunc(Y),9,9,0);
end;

procedure UnPlotFizz(var MfX : integer; var MfY : byte; var MfMotion : boolean);
begin
  t2_block(Mfx,Mfy,27,23,0);
  dec(MfY,2);
  if MfY<2 then begin Splay(SloRaspSound,0,false); MfMotion:=false; end;
  PlotBerries(MFx,MFy); PlotBerries(Mfx,MfY+16);
  if ((Mfx-66) mod 14>5) then begin PlotBerries(MFx+16,MfY); PlotBerries(MFx+16,Mfy+16); end;
end;

procedure PlotChed(var X,Y  : real);
begin
  if X<62 then X:=62;
  if X>311 then X:=311;
  t2_putpic(trunc(X),trunc(Y),@sChped);
end;

procedure LaunchChed(var ChedVX,ChedVY : real; sflag : boolean);
begin
  ChedVX:=(random(300)/100)-1;
  ChedVY:=-(sqrt(abs(SpeedRate-(ChedVX*ChedVX))));
  MoveCheck:=0;
  PLBounce:=0;
  if sflag then Splay(Shotsound,0,false);
end;

procedure BananaHit(ExpandFlag : boolean; BanType : byte; ChedX,ChedY : real; BanX : integer; var ChedVX,ChedVY : real);
  const
     BanAngle : array[-20..52] of real =
     (-0.8,-0.77,-0.74,-0.71,-0.68,-0.65,-0.62,-0.59,-0.56,-0.53,
     -0.50,-0.48,-0.46,-0.44,-0.42,-0.40,-0.38,-0.36,-0.34,-0.32,-0.30,-0.28,-0.26,
      -0.24,-0.22,-0.20,-0.18,-0.16,-0.14,-0.12,-0.10,-0.08,-0.06,-0.04,
      -0.02,-0.01,0.01,0.01,0.02,0.04,0.06,0.08,0.1,0.12,0.14,0.16,0.18,0.2,
      0.22,0.24,0.26,0.28,0.3,0.32,0.34,0.36,0.38,0.4,0.42,0.44,0.46,0.48,0.5,
      0.53,0.56,0.59,0.62,0.65,0.68,0.71,0.74,0.77,0.8);

var NewChedVX,NewChedVY,cos2G,sin2G,FActor : real;
    thing2 : byte;
begin
  Splodge:=2;
  Splay(BanHSound,BanType,ExpandFlag);
  Factor:=400*(BanType/5); Thing2:=1;
  if ExpandFlag then begin Factor:=Factor/2; Thing2:=2; end;
  Cos2G:=icos[trunc(Factor*BanAngle[trunc(2.5+ChedX-BanX) div Thing2])];
  Sin2G:=isin[trunc(Factor*BanAngle[trunc(2.5+ChedX-BanX) div thing2])];
  NewChedVX:=(ChedVx*cos2G)-(ChedVy*sin2G);
  NewChedVY:=-((ChedVy*cos2G)+(ChedVx*sin2G));
  if abs(NewChedVX)>1.25*(Speed) then begin
    if NewChedVX<0 then NewChedVX:=-1.25*Speed;
    if NewChedVX>0 then NewChedVX:=1.25*Speed;
    NewChedVY:=-(sqrt(abs(Speedrate-(ChedVX*ChedVX))));
  end;
  if (NewChedVx*NewChedVX)+(NewChedVY*NewChedVY)<>Speedrate then
    NewChedVY:=-(sqrt(abs(Speedrate-(ChedVX*ChedVX))));
  if NewChedVY>0 then NewChedVY:=-NewChedVY;
  ChedVx:=NewChedVx;
  ChedVy:=NewChedVy;
end;

procedure PlotDigit(Xp,Yp,dig : byte);
  const Digits : array[0..9] of string =
              ('111101101101111','001001001001001','111001111100111',
               '111001011001111','101101111001001','111100111001111',
               '111100111101111','111001001001001','111101111101111',
               '111101111001111');
  var St : string;
      TempXp,Xc,Yc : byte;
begin
  St:=Digits[dig];
  TempXp:=Xp-6;
  Yc:=0;
  repeat
    Xc:=0;
    repeat
      if St[1]='1' then begin
        t2_dot(TempXp+Xc,Yp+yc,192+Yc);
        t2_dot(TempXp+Xc+1,Yp+yc,192+Yc);
        t2_dot(TempXp+Xc,Yp+1+yc,193+Yc);
        t2_dot(TempXp+Xc+1,Yp+1+yc,193+Yc);
      end;
      St:=copy(St,2,length(St)-1);
      inc(Xc,2);
    until Xc=6;
    inc(Yc,2);
  until Yc=10;
end;

procedure PlotScore(Xp,Yp : integer;S : longint);
var TempS : longint;
    XPos,YPos : byte;
    StTemp : string;
begin
  dsmpoll;
  if Yp=47 then t2_putpic(0,47,ScGraph);
  if Yp=77  then t2_putpic(0,77,LiGraph);
  XPos:=Xp; YPos:=Yp;
  TempS:=S;
  repeat
    if TempS>0 then begin
      str(TempS,StTemp);
      Plotdigit(Xpos,Ypos,ord(StTemp[length(StTemp)])-48);
      dec(XPos,10);
    end;
    TempS:=TempS div 10;
  until TempS=0;
end;

procedure PlotMini(Xp,Yp : integer; L : byte);

var TempS : longint;
    XPos,YPos : byte;
    StTemp : string;
begin
  dsmpoll;
  XPos:=Xp; YPos:=Yp;
  TempS:=L;
  repeat
    if TempS>=0 then begin
      str(TempS,StTemp);
      PlotDigit(Xpos,Ypos,ord(StTemp[length(StTemp)])-48);
      dec(XPos,10);
    end;
    TempS:=TempS div 10;
  until TempS=0;
end;

procedure SetupScreen(Scorel : longint; PlayerNo,Livesl,Level : byte);
  var X,Y : byte;
begin
  ZeroPalette;
  DrawBorder;
  t2_block(61,1,257,197,0);
  t2_putpic(0,0,@ScBar);
  dsmpoll;
  for X:=0 to 17 do
    for Y:=0 to 9 do
      SPB(X,Y);
  getmem(ScGraph,624);
  getmem(LiGraph,624);
  t2_getpic(0,47,55,10,ScGraph);
  dsmpoll;
  t2_getpic(0,77,55,10,LiGraph);
  PlotDigit(52,17,PlayerNo);
  PlotScore(52,47,Scorel);
  PlotScore(52,77,Livesl);
  dsmpoll;
  PlotMini(52,107,Level);
end;

procedure Explode(X,Y : byte; var Scorel : longint; var BTG,NH,BanHit : integer; FizzyFlag : boolean);
begin
  if (X>=0) and (X<=17) and (Y>=0) and (Y<=9) then begin
    if (Berrys[X,Y,1]<>0) and (Berrys[X,Y,3]=3) then begin
      if not FizzyFlag then Splay(BoingSound,0,false);
      if Berrys[X,Y,4]>1 then inc(Berrys[X,Y,1]);
      if Berrys[X,Y,1]=12 then Berrys[X,Y,1]:=1;
      if Berrys[X,Y,4]>0 then dec(Berrys[X,Y,4]);
      if Berrys[X,Y,4]=0 then Berrys[X,Y,3]:=1;
      BanHit:=0;
    end;
    if (Berrys[X,Y,1]<>0) and (Berrys[X,Y,3]=2) then begin
      if not FizzyFlag then Splay(BoingSound,0,false);
      if Berrys[X,Y,4]>1 then dec(Berrys[X,Y,1]);
      if Berrys[X,Y,1]=0 then Berrys[X,Y,1]:=11;
      if Berrys[X,Y,4]>0 then dec(Berrys[X,Y,4]);
      if Berrys[X,Y,4]=0 then Berrys[X,Y,3]:=1;
      BanHit:=0;
    end;
    if (Berrys[X,Y,3]=0) and (Berrys[X,Y,1]<>0) then begin
      if not FizzyFlag then Splay(BoingSound,0,false);
    end;
    if (Berrys[X,Y,1]<>0) and (Berrys[X,Y,3]=1) then begin
      if not (FizzyFlag) then Splay(OohSound,0,false);
      if FizzyFlag then Splay(LitRaspSound,0,false);

      BanHit:=0;
      dec(BTG);
      inc(Scorel,5);
      inc(NoFallThings);
      Falling[NoFallThings,1]:=66+(X*14);
      Falling[NoFallThings,2]:=(Y*14);
      if berrys[X,y,2]<>0 then Falling[NoFallThings,3]:=berrys[X,Y,2];
      if berrys[x,y,2]=0 then Falling[NoFallThings,3]:=(berrys[x,y,1] mod 11)+16;
      if Falling[NoFallThings,3]=16 then Falling[NoFallThings,3]:=24;
      Berrys[X,Y,1]:=0;
    end;
  end;
end;

procedure MoveLaserShot(var ShootFlag : boolean; var BTG,Lx : integer; var Ly : byte;
                            var Scorel : longint; var NH,BanHit : integer);
  var  TLx,Tlx2,Tly : byte;
begin
  t2_dot(Lx,Ly,0);
  t2_dot(Lx,Ly+2,0);
  t2_dot(Lx+7,Ly+2,0);
  t2_dot(Lx+7,Ly,0);
  dec(Ly,5);
  if Ly>2 then begin
    t2_dot(Lx,Ly,180);
    t2_dot(Lx,Ly+2,180);
    t2_dot(Lx+7,Ly+2,180);
    t2_dot(Lx+7,Ly,180);
    Tly:=trunc(Ly-1) div 14;
    Tlx:=trunc(Lx-66) div 14;
    Tlx2:=trunc(Lx-55) div 14;
    if (Tly<=9) then
      if ((Berrys[Tlx,Tly,1]<>0) or (Berrys[Tlx2,Tly,1]<>0)) then begin
        t2_dot(Lx,Ly,0);
        t2_dot(Lx,Ly+2,0);
        t2_dot(Lx+7,Ly+2,0);
        t2_dot(Lx+7,Ly,0);
        if Tlx2<>Tlx then Explode(Tlx2,Tly,Scorel,BTG,NH,BanHit,false);
        Explode(Tlx,Tly,Scorel,BTG,NH,BanHit,false);
        ShootFlag:=false;
      end;
  end;
  if Ly<=2 then ShootFlag:=false;
  PlotBerries(Lx,Ly);
end;

procedure UnPlotFalling(X : integer;Y : byte);
  var Tx,Ty : byte;
begin
  Ty:=trunc(y-1) div 14;
  Tx:=trunc(x-66) div 14;
  if ty<10 then begin
    SPB(tx,ty);
    if tx<17 then SPB(1+tx, ty);
  end;
  if ty<9 then begin
    SPB(tx,1+ty);
    if tx<17 then SPB(1+tx,1+ty);
  end;
end;

procedure BounceCheck;
begin
  if (MoveCheck<40) then begin
    inc(PLBounce);
    MoveCheck:=0;
  end;
  if (MoveCheck>39) then begin PLBounce:=0; MoveCheck:=0; end;
end;

procedure CheckThatBerry(var ChedVX,ChedVY : real; ChedX,ChedY : real; BerryL,BerryR,BerryT,BerryB : boolean;
                             BerryX : integer; BerryY : byte; var Scorel : longint; var BTG,NH,BanHit : integer);
var OverX,OverY : boolean;
    BerX,BerY : byte;
begin

  if (BerryY-1) mod 14>0 then OverX:=true;
  if (BerryX-66) mod 14>0 then OverY:=true;
  BerY:=(BerryY-1) div 14;
  BerX:=(BerryX-66) div 14;
  Explode(BerX,BerY,Scorel,BTG,NH,BanHit,false);
  if OverX then Explode(BerX+1,BerY,Scorel,BTG,NH,Banhit,false);
  if OverY then Explode(BerX,BerY+1,Scorel,BTG,NH,banhit,false);
  if OverX and OverY then Explode(BerX+1,BerY+1,Scorel,BTG,NH,banhit,false);
  if BerryL {and not BerryR} then if ChedVx<0 then begin BounceCheck; ChedVx:=-ChedVx; end;
  if BerryR {and not BerryL} then if ChedVx>0 then begin BounceCheck; ChedVx:=-ChedVx; end;
  if BerryT {and not BerryB} then if ChedVy<0 then begin BounceCheck; ChedVy:=-ChedVy; end;
  if BerryB {and not BerryT} then if ChedVy>0 then begin BounceCheck; ChedVy:=-ChedVy; end;
end;

procedure CheckThatFizzyBerry(MFx : integer; MfY : byte; var Scorel : longint; var BTG,NH,BanHit : integer);
  var BerX,BerY : byte;
begin
  BerX:=(MFx-66) div 14; BerY:=(MFy-1) div 14;
  Explode(BerX,BerY,ScoreL,BTG,NH,BanHit,true);
  Explode(BerX,BerY+1,ScoreL,BTG,NH,BanHit,true);
  Explode(BerX+1,BerY,ScoreL,BTG,NH,BanHit,true);
  Explode(BerX+1,BerY+1,ScoreL,BTG,NH,BanHIT,true);
  if (Mfx-66) mod 14>5 then begin
    Explode(BerX+2,BerY+1,ScoreL,BTG,NH,BanHit,true);
    Explode(BerX+2,BerY,SCoreL,BTG,NH,BanHit,true);
  end;
end;

procedure PlotFizz(MfX : integer; MfY : byte; var ScoreL : longint; var BTG,NH,BanHit : integer);
begin
  t2_putbakpic(Mfx,Mfy,@MRFIZZ);
  CheckThatFizzyBerry(Mfx,MFy,ScoreL,BTG,NH,BanHit);
end;

function Collides(X1,Y1,X2,Y2 : integer) : boolean;
begin
  {Size of X1,Y1 = 8x8, X2,Y2=14x14)}
  Collides:=(X1+10>=X2) and (X1<X2+16) and (Y1+10>Y2) and (Y1<Y2+16);
end;

procedure CheckFExplode(K : byte);
begin
  if (Falling[K,4]=0) and (Falling[K,3]>=16) then begin
    Falling[K,4]:=4;
    Splay(SquishSound,0,false);
  end;
end;

procedure CheckForFalling(var BerryL,BerryR,BerryT,BerryB : boolean; Bx : integer; By : byte;var ChedVx,ChedVy : real);
  var L : byte;
      Collide : boolean;
begin
  for L:=1 to NoFallThings do
    if (Falling[L,1]<>0) and (Falling[L,4]<=8) then begin
      Collide:=Collides(Bx,By,Falling[L,1],Falling[L,2]);
      if (BerryL) and Collide then begin CheckFExplode(L); BerryL:=false; if ChedVx<0 then ChedVx:=-ChedVx; end;
      if (BerryR) and Collide then begin CheckFExplode(L); BerryR:=false; if ChedVx>0 then ChedVx:=-ChedVx; end;
      if (BerryB) and Collide then begin CheckFExplode(L); BerryB:=false; if ChedVy>0 then ChedVy:=-ChedVy; end;
      if (BerryT) and Collide then begin CheckFExplode(L); BerryT:=false; if ChedVy<0 then ChedVy:=-ChedVy; end;
     end;
end;

procedure UnNegFlag(var NF : boolean; OldX,BanX : integer; ExpandFlag : boolean);
begin
  if NF=true then begin
    NF:=false;
    EraseBanana(BanX,ExpandFlag);
    if (not ExpandFlag) then setmouseposition(678-(BanX*2),80);
    if ExpandFlag then setmouseposition(593-(BanX*2),80);
    Oldx:=BanX;
  end;
end;

procedure DoNegFlag(var NF : boolean; var NFF : integer;
                    var OldX,BanX : integer; ExpandFlag,LasFlag : boolean);

begin
  if NF=false then begin
    NF:=true;
    NFF:=BanX;
    EraseBanana(BanX,ExpandFlag);
    mouseinfo;
    if not ExpandFlag then setmouseposition(678-(BanX*2),80);
    if ExpandFlag then setmouseposition(593-(BanX*2),80);
    OldX:=BanX;
  end;
end;

procedure SetExpanded(var ExpandFlag,Nf,LasFlag : boolean;  var OldX,BanX : integer; var NegF : integer);
  var tempmf:boolean;
begin
  tempmf:=nf;
  EraseBanana(BanX,ExpandFlag);
  setmousexlimits(120,557);
  if not ExpandFlag then begin
    if tempmf then UnNegFlag(Nf,OldX,BanX,false);
    dec(BanX,16); if BanX<60 then BanX:=60;
    if BanX>235 then BanX:=235;
    OldX:=BanX; Setmouseposition(Banx*2,80);
    if tempmf then DoNegFlag(Nf,NegF,OldX,BanX,true,LasFlag);
  end;
  ExpandFlag:=true;
  setmousexlimits(120,472);
end;

procedure SetUnExpanded(var NF,LasFlag : boolean; var OldX,BanX,NegF : integer; var ExpandFlag : boolean);
  var tempmf :  boolean;
begin
  tempmf:=nf;
  EraseBanana(BanX,ExpandFlag);
  setmousexlimits(120,557);
  if ExpandFlag then begin
    if tempmf then UnNegFlag(Nf,OldX,BanX,true);
    inc(BanX,16); OldX:=BanX; setmouseposition(BanX*2,80);
    if tempmf then DoNegFlag(Nf,NegF,OldX,BanX,false,LasFlag);
  end;
  ExpandFlag:=false;
end;

procedure Highlight(g,c : byte);
  var X,Y : byte;
begin
  if g>0 then begin
    X:=(g-1) mod 3;
    Y:=(g-1) div 3;
    X:=3+(X*15);
    Y:=173+(Y*15);
    t2_horiz_line(X,Y,13,c);
  end;
end;

procedure SetGadget(PlayerNo,Oldb,b : byte; var LasFlag,ExpandFlag,NegFlag : boolean;
                    var Banx,OldX,NegF : integer);
begin
  if Oldb>0 then Highlight(Oldb,0);
  HighLight(b,14);
  b:=Gadgets[b,PlayerNo];
  if b=0 then begin
    LasFlag:=false;
    EraseBanana(BanX,ExpandFlag);
    SetUnExpanded(Negflag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end else if b=1 then begin
    LasFlag:=false;
    EraseBanana(Banx,ExpandFlag);
    SetExpanded(ExpandFlag,NegFlag,LasFlag,OldX,BanX,NegF);
  end else if b=2 then begin
    LasFlag:=true;
    EraseBanana(BanX,ExpandFlag); SetUnExpanded(Negflag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end else if b=4 then begin
    EraseBanana(Banx,ExpandFlag);
    LasFlag:=false;
    SetUnExpanded(NegFlag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end else if b=7 then begin
    EraseBanana(Banx,ExpandFlag);
    LasFlag:=false; SetUnExpanded(NegFlag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end else if b=6 then begin
    EraseBanana(BanX,ExpandFlag);
    LasFlag:=false;
    SetUnExpanded(NegFlag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end else if b=8 then begin
    EraseBanana(BanX,ExpandFlag);
    LasFlag:=false; SetUnExpanded(NegFlag,LasFlag,OldX,BanX,NegF,ExpandFlag);
  end;
end;

procedure ForceGet(PlayerNo,Forced : byte; var LasFlag,ExpandFlag,NegFlag : boolean; var Scorel : longint;
                   var Livesl : byte; var NegFactor : integer; var BanType,MaxGad,Gad : byte;
                   var BanX,OldX : integer; var CompleteLevel : boolean);

begin
  if Forced<=8 then begin
    if (Forced=1) and (not Got[1,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      Scorel:=Scorel+10;
      t2_putpic(IconX+3,IconY+160,@IC1);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      if IconX=45 then begin IconX:=0; IconY:=IconY+15;  end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=1;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end else if (Forced=2) and (not Got[2,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      Scorel:=Scorel+10;
      t2_putpic(IconX+3,IconY+160,@IC2);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      if IconX=45 then begin IconX:=0; IconY:=IconY+15;  end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=2;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end else if (Forced=3) and (not Got[3,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      Livesl:=Livesl+1;
      PlotScore(52,77,Livesl);
      Scorel:=Scorel+10;
    end else if (Forced=4) and (not Got[4,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      t2_putpic(IconX+3,IconY+160,@IC4);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      if IconX=45 then begin IconX:=0; IconY:=IconY+15; end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=4;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end else if (Forced=5) and (not Got[5,PlayerNo]) then begin
      Splay(BonusSound,0,false);
        DoNegFlag(NegFlag,NegFactor,OldX,BanX,ExpandFlag,LasFlag);
    end else if (Forced=6) and (not Got[6,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      t2_putpic(IconX+3,IconY+160,@IC6);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      MrFizzy[PlayerNo]:=true;
      if IConX=45 then begin IconX:=0; IConY:=IconY+15; end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=6;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end else if (Forced=7) and (not Got[7,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      t2_putpic(IconX+3,IconY+160,@IC7);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      if IconX=45 then begin IconX:=0; IconY:=IconY+15; end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=7;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end else if (Forced=8) and (not Got[8,PlayerNo]) then begin
      Splay(BonusSound,0,false);
      t2_putpic(IconX+3,IconY+160,@IC8);
      t2_horiz_line(IconX+3,IconY+173,13,0);
      IconX:=IconX+15;
      if IconX=45 then begin IconX:=0; IconY:=IconY+15; end;
      inc(MaxGad); Gadgets[MaxGad,PlayerNo]:=8;
      if MaxGad=1 then begin Gad:=1; SetGadget(PlayerNo,0,1,LasFlag,ExpandFlag,NegFlag,Banx,OldX,NegFactor); end;
    end;
    Got[Forced,PlayerNo]:=true;
  end;
end;

procedure BounceChed(ExpandFlag : boolean; BanType : byte; ChedX,ChedY : real; BanX : integer;
                     var ChedVX,ChedVY : real; var Scorel : longint; var BTG,NoHit,HitBan : integer);
var ChedScan : array[0..9,0..9] of byte;
    Ty,ScanL,ScanR,ScanB,ScanT,X,Y : byte;
    Tx :  integer;
    BanHitFlag,BerryL,BerryR,BerryT,BerryB : boolean;
begin
  ScanL:=0; ScanR:=0; ScanB:=0; ScanT:=0;
  BanHitFlag:=false;
  BerryL:=false; BerryR:=false; BerryT:=false; BerryB:=false;
  Tx:=trunc(ChedX); Ty:=trunc(ChedY);
  if (TX<63) or (ChedX>307) then begin Splay(BoingSound,0,false); ChedVX:=-ChedVX; end;
  if (TY<4) then begin Splay(BoingSound,0,false); ChedVY:=-ChedVY; end;
  if (TX<63) and (ChedVx<0) then
    begin ChedVx:=abs(ChedVX); Tx:=64; end;
  if (TX>307) and (ChedVX>0) then
    begin ChedVX:=-abs(ChedVX); Tx:=306; end;
  for X:=0 to 9 do begin
    ChedScan[X,0]:=t2_getdot(Tx+x,Ty);
    if ChedScan[X,0]>15 then inc(ScanT);
    ChedScan[X,9]:=t2_getdot(Tx+x,Ty+9);
    if ChedScan[X,9]>15 then inc(ScanB);
    ChedScan[0,X]:=t2_Getdot(Tx,Ty+x);
    if ChedScan[0,X]>15 then inc(ScanL);
    ChedScan[9,X]:=t2_getdot(Tx+9,Ty+x);
    if ChedScan[9,X]>15 then inc(ScanR);
  end;

  BerryT:=(ScanT>=2); BerryB:=(ScanB>=2); BerryL:=(ScanL>=2); BerryR:=(ScanR>=2);
  CheckForFalling(BerryL,BerryR,BerryT,BerryB,tx,ty,ChedVx,ChedVy);
  if (Ty>170) and BerryB and not BerryT then BanHitFlag:=true;
  if (BanHitFlag) and (ChedY>170+(BanType*2)) then ChedY:=170+(BanType*2);
  inc(NoHit);
  if (NoHit>=400) and (ChedVy<0) then begin NoHit:=0; LaunchChed(ChedVx,ChedVy,false); end;
  if BanHitFlag then NoHit:=0;
  if (ty>=193) then DeadFlag:=true;
  if BanHitFlag then begin inc(HitBan); BananaHit(ExpandFlag,BanType,ChedX,ChedY,BanX,ChedVX,ChedVY); end;
  if (BerryL or BerryR or BerryT or BerryB) then
    CheckThatBerry(ChedVx,ChedVy,ChedX,ChedY,BerryL,BerryR,BerryT,BerryB,Tx,Ty,Scorel,BTG,NoHit,HitBan);
end;


procedure MoveChed(ExpandFlag : boolean; BanType : byte; var ChedX,ChedY,ChedVX,ChedVY : real;
                   var BanX : integer; var Scorel : longint; var BTG,NH,HitBan : integer);
begin
  if MoveCheck<42 then inc(MoveCheck);
  ChedX:=ChedX+ChedVX;
  ChedY:=ChedY+ChedVY;
  BounceChed(ExpandFlag,BanType,ChedX,ChedY,BanX,ChedVX,ChedVY,Scorel,BTG,NH,HitBan);
end;

procedure CheckKeyBoard(PlayerNo : byte; var BanType,Gad,MaxGad : byte; var ExitFlag,LasFlag,ExpandFlag,NegFlag : boolean;
                        var Scorel : longint; var Livesl : byte; var NegFactor,BanX,OldX : integer;
                        var CompleteLevel : boolean; MfMotion : boolean);
begin
  if Potato then begin
    if (keydata.kF[1]) and (not GOT[1,PlayerNo]) then ForceGet(PlayerNo,1,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[2]) and (not GOT[2,PlayerNo]) then ForceGet(PlayerNo,2,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[3]) and (not GOT[3,PlayerNo]) then ForceGet(PlayerNo,3,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[4]) and (not GOT[4,PlayerNo]) then ForceGet(PlayerNo,4,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[5]) and (not GOT[5,PlayerNo]) then ForceGet(PlayerNo,5,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[6]) and (not GOT[6,PlayerNo]) then ForceGet(PlayerNo,6,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[6]) and (not MfMotion) then MrFizzy[PlayerNo]:=true;
    if (keydata.kF[7]) and (not GOT[7,PlayerNo]) then ForceGet(PlayerNo,7,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
    if (keydata.kF[8]) and (not GOT[8,PlayerNo]) then ForceGet(PlayerNo,8,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
    NegFactor,BanType,MaxGad,Gad,BanX,OldX,CompleteLevel);
  end;
  if (keydata.kEsc) then begin shutsoundfx; FadeOut(false); ExitFlag:=true; end;

  if (keydata.kRight) and (gad<maxgad) then begin
    inc(KeyTime);
    if KeyTime>=6 then begin
      inc(Gad);
      KeyTime:=0;
    end;
  end else if (keydata.kLeft) and (gad>0) then begin
    inc(KeyTime);
    if KeyTime>=6 then begin
      dec(Gad);
      KEyTime:=0;
    end;
  end else if (keydata.kUp) and (BanType>1) then begin
    inc(KeyTime);
    if KeyTime>=3 then begin
      KeyTime:=0;
      dec(BanType);
    end;
  end else if (keydata.kDown) and (BanType<5) then begin
    inc(KeyTime);
    if KeyTime>=3 then begin
      KeyTime:=0;
      inc(BanType);
    end;
  end else begin
    KeyTime:=0;
  end;
  ClearBuf;
end;

procedure ClickLeftButton(PlayerNo, gad : byte; var CompleteLevel,ShootFlag,NotLaunched : boolean;
                          var Lx,Banx : integer; var Ly : byte; ChedX : real; var MFx : integer; var MFy : byte;
                          var MfMotion : boolean; var ChedVx,ChedVy : real);
  var temp : byte;
      dist : real;
begin
  temp:=Gadgets[gad,PlayerNo];
  case temp of
    2:
    begin
      if (not ShootFlag) and (not NotLaunched) then begin
        Lx:=Banx+16;
        Ly:=170;
        ShootFlag:=true;
        Splay(ShotSound,0,false);
      end;
    end;
    4:
    begin
      CompleteLevel:=true;
      {COMPLETE DESTRUCTION!!!}
    end;
    7:
    begin
      setmouseposition(2*trunc(ChedX-16),200);
    end;
    6:
    begin
      if MrFizzy[PlayerNo]=true then begin
        MFx:=8+BanX;
        MFy:=160;
        MfMotion:=true;
        MrFizzy[PlayerNO]:=false;
        splay(RaspSound,0,false);
      end;
    end;
    8:
    begin
      ChedVX:=((BanX+16)-ChedX)/(32);
      if ChedVx>=(sqrt(SpeedRate)*0.8) then ChedVx:=sqrt(SpeedRate)*0.8;
      if ChedVy>0 then ChedVY:=sqrt( abs((SpeedRate)-(ChedVX*ChedVX))  );
      if ChedVy<0 then ChedVy:=-sqrt( abs((SpeedRate)-(ChedVX*ChedVX))   );
    end;
  end;
end;

procedure FallingThings(PlayerNo : byte; var LasFlag,ExpandFlag,NegFlag : boolean; var Scorel : longint;
                            var Livesl : byte; var NegFactor : integer; var BanType,MaxGad,Gad : byte; var BanX,OldX : integer;
                            var CompleteLevel : boolean );
  var L,L2 : byte;
      EraseFall : array[1..64] of byte;
      NoEraseThings : byte;
      NS : string;
begin
  NoEraseThings:=0;
  for L:=1 to NoFallThings do begin
    t2_block(Falling[L,1],Falling[L,2],13,13,0);
    UnPlotFalling(Falling[L,1],Falling[L,2]);
    inc(Falling[L,2]);
    if Falling[L,2]>=170 then begin
      inc(NoEraseThings);
      EraseFall[NoEraseThings]:=L;
      if (Falling[L,1]>=BanX-12)  and
        ( (ExpandFlag and (Falling[L,1]<BanX+84)) or ((not ExpandFlag) and (Falling[L,1]<BanX+42))) then
      begin
        ForceGet(PlayerNo,Falling[L,3],LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
                 NegFactor,BanType,MaxGad,Gad,Banx,OldX,CompleteLevel);

        if Falling[L,3]>=16 then begin
          Splay(CaughtSound,0,false);
          Scorel:=Scorel+10;
        end;
      end;
      Falling[L,1]:=0; Falling[L,4]:=0; Falling[L,2]:=0; Falling[L,3]:=0;
    end;
    if (Falling[L,2]<170) and (Falling[L,1]>0) then begin
      if Falling[L,3]=1 then t2_putpic(Falling[L,1],Falling[L,2],@Ic1);
      if Falling[L,3]=2 then t2_putpic(Falling[L,1],Falling[L,2],@Ic2);
      if Falling[L,3]=3 then t2_putpic(Falling[L,1],Falling[L,2],@Ic3);
      if Falling[L,3]=4 then t2_putpic(Falling[L,1],Falling[L,2],@Ic4);
      if Falling[L,3]=5 then t2_putpic(Falling[L,1],Falling[L,2],@Ic5);
      if Falling[L,3]=6 then t2_putpic(Falling[L,1],Falling[L,2],@Ic6);
      if Falling[L,3]=7 then t2_putpic(Falling[L,1],Falling[L,2],@Ic7);
      if Falling[L,3]=8 then t2_putpic(Falling[L,1],Falling[L,2],@Ic8);
      if (Falling[L,3]>=16) then t2_putbakpic(Falling[L,1],Falling[L,2],BBMP[AniFlop,Falling[L,3]-15]);
    end;
    if (Falling[L,4]<>0){ and (Falling[L,2]=0)} then begin
      Global1:=Falling[L,1];
      Global2:=Falling[L,2];
      Global3:=Falling[L,3];
      Global4:=Falling[L,4];
      t2_putpic(Falling[L,1],Falling[L,2],BBMP[Falling[L,4],Falling[L,3]-15]);
      if AniFlop=2 then begin
        inc(Falling[L,4]);
        if Falling[L,4]>=11 then begin
          Falling[L,4]:=0;
          t2_block(Falling[L,1],Falling[L,2],14,14,0);
          Unplotfalling(Falling[L,1],Falling[L,2]);
          inc(NoEraseThings);
          EraseFall[NoEraseThings]:=L;
          Falling[L,1]:=0; Falling[L,2]:=0; Falling[L,3]:=0;
        end;
      end;
    end;
  end;
  if NoEraseThings>0 then begin
    for L:=1 to NoEraseThings do begin
      for L2:=EraseFall[L] to NoFallThings-1 do begin
        Falling[L2,1]:=Falling[L2+1,1];
        Falling[L2,2]:=Falling[L2+1,2];
        Falling[L2,3]:=Falling[L2+1,3];
        Falling[L2,4]:=Falling[L2+1,4];
      end;
      for L2:=L to NoEraseThings do
        EraseFall[L2]:=EraseFall[L2]-1;
      dec(NoFallThings);
    end;
    NoEraseThings:=0;
  end;
end;

procedure DoOneLife(var PlayerNo,Livesl,Level : byte; var Scorel : longint; var ExitFlag : boolean);
  var S,OldX,BanX : integer;
      OldScore : longint;
      OldCX,OldCY,ChedVX,ChedVY,ChedX,ChedY : real;
      flagger,CompleteFlag,NegFlag,LasFlag,
      ShootFlag,ExpandFlag,NotLaunched : boolean;
      BanType,Ly,oldgad,gad,maxgad : byte;
      NoHit,HitBan,Lx,BerrysToGo,NEgFactor : integer;
      RAN,IcX,IcY : byte;
      R14,G14,B14,CR14,CG14,CB14 : shortint;
      MFX : integer; MFY : byte;
      ZitFlag,MfMotion : boolean;

begin
  MaxGad:=0; Gad:=0; OldGad:=0;
  CR14:=1; CG14:=1; CB14:=1; R14:=0; G14:=0; B14:=0;
  splodge:=0; ZitFlag:=true; MfMotion:=false;

  flagger:=false; HitBan:=0;
  repeat
    gad:=0; OldGad:=0;
    repeat
      if Level<1 then begin Level:=1; readlevel(PlayerNo,1); end;
      BerrysToGo:=LoadLevel(PlayerNo);
      if BerrysToGo=0 then begin Level:=0; inc(Speeds[PlayerNo]); end;
    until Level<>0;
    Speed:=Speeds[PlayerNo];
    Speedrate:=2+(2*Speed);
    NoFallThings:=0;
    NoHit:=0;
    ZeroPalette;
    t2_block(0,0,320,200,0);
    PlotString(56,140,PassWords[Level],146);
    PlotString(160-((26*length(Names[PlayerNo])) div 2),100,Names[PlayerNo],180);
    Splay(ReadySound,0,false);
    Fadein(true);
    DelKey(true);
    Fadeout(true);
    t2_block(0,0,320,200,0);
    for Ly:=1 to 64 do begin Falling[Ly,1]:=0; Falling[Ly,2]:=0; Falling[Ly,3]:=0; Falling[Ly,4]:=0; end;
    dsmpoll;
    S:=0; IconX:=0; IconY:=0; BanType:=5; ChedVx:=0; ChedVy:=0;
    ShootFlag:=false; ExpandFlag:=false; LasFlag:=false; DeadFlag:=false;
    NegFlaG:=false;
    CompleteFlag:=false; ExplodeDelay:=false; NotLaunched:=True;
    RibPalette;
    SetupScreen(Scorel,PlayerNo,Livesl,Level);
    MaxGad:=0; Gad:=0; IcY:=0; IcX:=0; IconX:=0; IconY:=0;
    for splodge:=1 to 8 do begin
      if Gadgets[splodge,PlayerNo]=1 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC1);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[1,PlayerNo]:=true; end;
      if Gadgets[splodge,PlayerNo]=2 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC2);
        t2_horiz_line(IcX+3,IcY+173,13,0);IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[2,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=3 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC3);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[3,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=4 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC4);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[4,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=5 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC5);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[5,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=6 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC6);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[6,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=7 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC7);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[7,PlayerNo]:=true;end;
      if Gadgets[splodge,PlayerNo]=8 then begin inc(maxgad); t2_putpic(IcX+3,IcY+160,@IC8);
        t2_horiz_line(IcX+3,IcY+173,13,0); IcX:=IcX+15;
        if IcX=45 then begin IcX:=0; IcY:=IcY+15;  end;
        Got[8,PlayerNo]:=true;end;

    end;
    IconX:=IcX; IconY:=IcY;
    fadein(true);

    setmouseposition(400,80);
    setmousexlimits(120,557);
    mouseinfo;
    BanX:=mouse.x div 2;  Oldx:=BanX;
    ChedX:=BanX+16; ChedY:=170;
    OldCX:=ChedX; OldCY:=ChedY;
    repeat
      mouseinfo;
      dsmpoll;
      if ZitFlag then ZitFlag:=(mouse.left);
       if not NegFlag then BanX:=mouse.x div 2;
(**************************************************************************)
       if NegFlag then
         begin
           if ExpandFlag then BanX:=(593-mouse.x) div 2;
           if not ExpandFlag then BanX:=(678-mouse.x) div 2;
         end;
       if (ExpandFlag) and (mouse.x>472) then
        begin
          if BanX>235 then Banx:=235;
          if (mouse.x>472) and (not NegFlag) then setmouseposition(472,80);
       end;

      if mouse.left then ClickLeftButton(PlayerNo,gad,CompleteFlag,ShootFlag,NotLaunched,Lx,
                                         BanX,Ly,ChedX,MfX,MfY,MfMotion,ChedVx,ChedVy);

      if Banx>Oldx then
        if Banx-Oldx>8 then Banx:=Oldx+8;
      if Banx<Oldx then
        if Oldx-Banx>8 then Banx:=Oldx-8;
      if NotLaunched then
        begin
          if not ExpandFlag then ChedX:=BanX+16;
          if ExpandFlag then ChedX:=BanX+32;
          ChedY:=170;
          if (mouse.left) and (not ZitFlag) then
            begin
              NotLaunched:=False;
              LaunchChed(ChedVX,ChedVY,true);
            end;
        end;
      R14:=R14+CR14;
      G14:=G14+CG14;
      B14:=B14+CB14;
      if ((R14>=63) or (R14=0)) and ((G14>=63) or (G14=0)) and ((B14>=63) or (B14=0))
      then begin
        repeat
          RAN:=random(50);
          CR14:=0;
          if (RAN<25) and (R14=0) then CR14:=3;
          if (RAN<25) and (R14=63) then CR14:=-3;
          RAN:=random(50);
          CG14:=0;
          if (RAN<25) and (G14=0) then CG14:=3;
          if (RAN<25) and (G14=63) then CG14:=-3;
          RAN:=random(50);
          CB14:=0;
          if (RAN<25) and (B14=0) then CB14:=3;
          if (RAN<25) and (B14=63) then CB14:=-3;
        until ((CR14<>0) or (CB14<>0) or (CG14<>0));
        END;
      t2_setrgb(14,r14,b14,g14);
      dsmpoll;
      UnPlotChed(OldCX,OldCY);
      if not (notlaunched) then MoveChed(ExpandFlag,BanType,ChedX,ChedY,ChedVX,ChedVY,BanX,Scorel,BerrysToGo,NoHit,HitBan);
      if OldScore<>Scorel then PlotScore(52,47,Scorel);
      OldScore:=Scorel;
      PlotBerries(OldCx,OldCy);
      OldCX:=ChedX; OldCY:=ChedY;
      EraseBanana(OldX,ExpandFlag);
      PutBanana(BanX,BanType,LasFlag,ExpandFlag);

      OldGad:=Gad;
      CheckKeyBoard(PlayerNo,BanType,Gad,MaxGad,ExitFlag,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
                    NegFactor,BanX,OldX,CompleteFlag,MfMotion);
      if (OldGad<>Gad) then
        setgadget(PlayerNo,oldgad,gad,LasFlag,ExpandFlag,NEgFlag,BanX,OldX,NegFactor);

      PlotChed(ChedX,ChedY);
      if ShootFlag then MoveLaserShot(ShootFlag,BerrysToGo,Lx,Ly,Scorel,NoHit,HitBan);
      AniFlop:=AniFlop+1;
      if AniFlop=4 then AniFlop:=1;
      DrawBorder;
      OldX:=BanX;
      dsmpoll;
      if ExitFlag then exit;
      if MfMotion then UnPlotFizz(MfX,MfY,MfMotion);

      FallingThings(PlayerNo,LasFlag,ExpandFlag,NegFlag,Scorel,Livesl,
                    NegFactor,BanType,MaxGad,Gad,Banx,OldX,CompleteFlag);
            if MfMotion then PlotFizz(Mfx,MfY,Scorel,BerrysToGo,NoHit,HitBan);

      if (not mouse.right) or (flagger) then t2_vretrace;

      PlotChed(ChedX,ChedY);
      if (mouse.right) then flagger:=not flagger;
      if BerrysToGo=0 then CompleteFlag:=true;
      if HitBan>=40 then begin
        t2_block(61,1,257,197,0);
        drawborder;
        PlotString(110,30,'BANANA',68);
        PlotString(103,60,'HAS GOT',92);
        PlotString(110,94,'RATHER',146);
        PlotString(118,120,'TIRED!',180);
        CompleteFlag:=true;
        HitBan:=0;
        DelKey(true);
      end;
      if (PLBounce>30) then begin
        Splay(Caughtsound,0,false);
        Unplotched(ChedX,ChedY);
        PlBounce:=0;
        PlotBerries(ChedX,ChedY);
        NotLaunched:=true;
        ZitFlag:=true;
      end;
      dsmpoll;
    until DeadFlag or CompleteFlag;
    MfMotion:=false;
    UnPlotChed(OldCx,OldCY);
    PlotBerries(ChedX,ChedY);
    PutBanana(BanX,BanType,LasFlag,ExpandFlag);
    DrawBorder;
    if DeadFlag then begin
      Splay(lifesound,0,false);
      SaveLevel(PlayerNo);
      dec(Livesl);
      PlotString(125,140,'OOPS!',116);
      DelKey(true);
      FadeOut(true);
    end;
    if CompleteFlag then begin
      Splay(CompleteSound,0,false);
      For splodge:=1 to 8 do begin
        Got[splodge,playerno]:=false;
        Gadgets[splodge,playerno]:=0;
      end;
      MrFizzy[playerno]:=false;
      PlotBerries(ChedX,ChedY);
      t2_vretrace;
      for Ly:=1 to 64 do
        begin Falling[Ly,1]:=0; Falling[Ly,4]:=0; end;
      inc(level);
      ReadLevel(PlayerNo,Level);
      DelKey(true);
      DelKey(true);
      DelKey(true);
      FadeOut(true);
    end;
    freemem(scgraph,624);
  until DeadFlag;
end;

procedure Ranks(Pl : byte);
  const Coltint : array[1..8] of byte = (36,68,100,117,145,164,180,198);
  var Max,L,K : byte;
      S : string[20];
      Order : array[1..8] of byte;
      Gone : array[1..8] of boolean;
begin
  t2_block(0,0,320,200,0);
  RibPalette;
  for K:=1 to Pl do Gone[K]:=false;
  for K:=1 to Pl do begin
    Max:=0;
    for L:=1 to Pl do begin
      if Max>0 then
        if (Score[L]>=Score[Max]) and (not Gone[L]) then Max:=L;
      if (Max=0) and (not Gone[L]) then Max:=L;
    end;
    Order[K]:=Max;
    Gone[Max]:=true;
  end;
  for L:=1 to Pl do begin
    str(L,S);
    PlotString(40,20+(L*18),S,Coltint[L]);
    PlotString(267,20+(L*18),S,Coltint[L]);
    LittleText(64,23+(L*18),Names[Order[L]]);
    str(Level[Order[L]],S);
    LittleText(148,23+(L*18),S);
    str(Lives[Order[L]],S);
    if Lives[Order[L]]<>255 then LittleText(189,23+(L*18),S);
    if Lives[Order[L]]=255 then LittleText(170,23+(L*18),'DEADBERRY');
    Str(Score[Order[L]],S);
    LittleText(234,23+(L*18),S);
  end;
  LittleText(70,15,'NAME');
  LittleText(140,15,'LEVEL');
  LittleText(180,15,'LIVES');
  LittleText(220,15,'SCORE');
  Fadein(true);
  DelKey(true);
  Fadeout(true);
end;

procedure DoGame(Players,LevelStart : byte);
  var M,L : byte; Alive,ExitFlag : boolean;
begin
  for M:=1 to 8 do for L:=1 to 8 do begin
    Gadgets[M,L]:=0;
    Got[M,L]:=false;
  end;
  ExitFlag:=false;
  aniflop:=1;
  for M:=1 to Players do begin
    ReadLevel(M,LevelStart);
    Speeds[M]:=Speed;
    Score[M]:=0;
    Lives[M]:=3;
    Level[M]:=LevelStart;
  end;
  repeat
    Alive:=false;
    for M:=1 to Players do
      if (Lives[M]>0) and (Lives[M]<254) then begin
        Alive:=true;
        DoOneLife(M,Lives[M],Level[M],Score[M],ExitFlag);
        if ExitFlag then exit;
        if Lives[M]=0 then begin
          Splay(GoverSound,0,false);
          t2_block(0,0,320,200,0);
          PlotString(52,60,'GAME OVER',180);
          PlotString(160-((26*length(Names[M])) div 2),100,Names[M],148);
          Lives[M]:=255;
          FadeIn(true);
          DelKey(true);
          FadeOut(true);
          DelKey(true);
        end;
      end;
    if (Players>1) and (Alive) then Ranks(Players);
  until not Alive;
  CheckHiScores(Players);
  ShutSoundFx;
end;

function convup(s : string) : string;
var L : byte;
begin
  for L:=1 to length(s) do s[L]:=upcase(s[L]);
  convup:=s;
end;

begin
  fxon:=false; muson:=false;
  LoadDefaults;
  StartLevel:=1;
  initmouse;
  t2_start(0);
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keyclick));
  With keydata do begin
    kleft:=false; kright:=false; kup:=false; kdown:=false;
    kSHIFT:=false; kALT:=false; kCTRL:=false; kY:=false; kQ:=false;
    kR:=false; kZ:=false; kESC:=false; KS:=false; KDEL:=false;
  end;
  repeat
    TitlePage;
    DoGame(Players,StartLevel);
  until false;
  JumpOut;
end.