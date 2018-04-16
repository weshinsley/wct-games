program TDA;
{$M 65520,0,655360}

uses crt,dos,td_256,td_pcx,tda_2,TDA_3,tda_4,flippers,sound,load,ts;

type
  keyrec=record
    kleft,kright,kup,kdown,kESC,Kdel,kins: boolean;
    end;
var
  Card   : DSMCard;
  Module : PDSM;
  Dirinfo : searchrec;
  N : array[1..6] of string;
  SCS : array[1..5] of STRING;
  SCV : array[1..5] of longint;
  MAX_LEVEL,SCN,PVAL,MANFLAG,X,Y,OLDX,OLDY,
  TOLTOG,GSPEED_TOGGLE,L,SPEED_TOGGLE,MAX_SPEED,MX,MY,MD,NX,NY,GX,GY,DX,DY,
  LOYTOG,GARDENER_MOVE,OLDGMD,GMD,GMDX,GMDY,NMD,NMDX,NMDY,NEIGHBOUR_MOVE,M,
  LEVNO,DDIR,DOG_TOL,DOG_MOVE,DOG_DIR,MOWER_T,DOGFLAG,ANITOG,DANITOG,DFRAME,
  LIVES,DMDX,L2,DMDY,DOG_LOY,OLD_DIR,DD,ND,GANITOG,NANITOG,GFRAME,MFRAME,NFRAME : byte;
  KbdIntVec : Procedure;
  keydata: Keyrec;
  AIMX,AIMY,CHCOUNT,GBITS,MBITS,GD_X,GD_Y,ND_X,ND_Y,DMX,DMY,CX,CY,GMX,GMY,GNX,GNY : longint;
  CH : char;
  ST : string;
  F : text;
  SCORE,OLD_SCORE : longint;
  DROWNFLAG,GF,NF,GARD,GL,GR,GU,GD,OVERLOAD,KILLFLAG : boolean;
  SCREEN : array[1..40,1..20] of byte;
  GFRAMEDIR,DFRAMEDIR,MFRAMEDIR,NFRAMEDIR : shortint;
  BACKP,P : pointer;
  DG : real;

const
  AUDIO_DIR = 'AUDIO\';
  GFX_DIR = 'GFX\';
  LEV_DIR = 'LEVELS\';

procedure ShutInterrupt;
 begin
  TSDone;
  TSRestoreTime;
end;

procedure ShutSound;
  var L : byte;
begin
  for L:=200 downto 0 do begin DSMSetMusicVolume(L); delay(3); end;
  DSMStopMusic;
  DSMFree(Module);
  DSMDone;
end;

procedure Jumpout;
begin
  writeln('(C) 1996, WCT Entertainment');
  t2_end;
  SetIntVec($9,@KbdIntVec);
  halt;
end;

procedure StartInterrupt;
begin
  TSInit;
  TSSetRate(60);
  TSSetRoutine(DSMPoll);
end;

Procedure SCREEN_FLIP(DEST : byte;RGB_ALTER : boolean; avoid : boolean);
begin
  if maxavail<66000 then begin
    t2_end;
    writeln('Not enough memory to screen flip, so rather than crashing, I bailed out.');
    writeln('For Microsoft Windows familiar users:');
    writeln('TDA produced a general exception 0x000x0000x00x000');
    writeln('    at reference 0-x84bd5c5e66eceffa7fbc8838efbc52');
    writeln(' The only solution is to upgrade to IE5 and Win98' );
    ShutInterrupt;
    ShutSound;
    SetIntVec($9,@KbdIntVec);
  end;
  Screen_Flip2(DEST,RGB_ALTER,AVOID);
end;


procedure SetupSound;
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
  Module := DSMLoad(AUDIO_DIR+'TOMSDAY.DSM',0);
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

  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);
  for L:=0 downto 200 do begin DSMSetMusicVolume(L); delay(10); end;
end;

procedure UPDATE_PANEL;
  var SCT : string;
      L : byte;
      CSX : integer;
begin
  t2_block(178,165,DOG_TOL,3,100);
  T2_BLOCK(178+DOG_TOL,165,130-DOG_TOL,3,0);
  t2_block(178,174,DOG_LOY,3,100);
  T2_BLOCK(178+DOG_LOY,174,130-DOG_LOY,3,0);
  t2_block(178,183,MOWER_T,3,100);
  if MOWER_T>100 then t2_block(278,183,MOWER_T-100,3,40);
  if MOWER_T>=128 then OVERLOAD:=true;
  if (OVERLOAD) and (MOWER_T<100) then OVERLOAD:=false;
  if OVERLOAD then t2_setrgb(40,random(32)+32,0,0);
  t2_block(178+MOWER_T,183,130-MOWER_T,3,0);
  if OLD_SCORE<>SCORE then begin
    t2_block(178,191,100,5,0);
    OLD_SCORE:=SCORE;
    str(SCORE,SCT);
    CSX:=178;
    for L:=1 to length(SCT) do begin
      if SCT[L]='1' then begin t2_block(CSX,191,1,5,136); inc(CSX,3); end;
      if (SCT[L]='2') or (SCT[L]='3') or (SCT[L]='5') or (SCT[L]='6')
        or (SCT[L]='0') or (SCT[L]='7') or (SCT[L]='8') or (SCT[L]='9') or (sct[l]='0')
        then t2_block(CSX,191,3,1,136);
      if (SCT[L]='2') or (SCT[L]='3') or (SCT[L]='4') or (SCT[L]='5')
        or (sCT[L]='6') or (sCT[L]='8') or (SCT[L]='9')
        then t2_block(CSX,193,3,1,136);
      if (SCT[L]='2') or (SCT[L]='3') or (SCT[L]='5') or (SCT[L]='6')
        or (SCT[L]='8') or (SCT[L]='9') or (SCT[L]='0')
        then t2_block(CSX,195,3,1,136);
      if (SCT[L]='4') or (SCT[L]='5') or (SCT[L]='6') or (SCT[L]='8')
        or (SCT[L]='9') then t2_block(CSX,191,1,3,136);
      if (SCT[L]='2') or (SCT[L]='6') or (SCT[L]='8') or (SCT[L]='0')
        then t2_block(CSX,193,1,3,136);
      IF (Sct[l]='2') OR (sct[l]='3') or (SCT[L]='4') or (SCT[L]='7') or (SCT[L]='0')
        or (SCT[L]='8') or (SCT[L]='9') or (SCT[L]='0') then t2_block(CSX+3,191,1,3,136);
      if (SCT[L]='3') or (SCT[L]='4') or (SCT[L]='5') or (SCT[L]='6')
        or (SCT[L]='7') or (SCT[L]='8') or (SCT[L]='9') or (SCT[L]='0') then t2_block(CSX+3,193,1,3,136);
      if SCT[L]<>'1' then inc(CSX,5);
    end;
  end;
end;

procedure HI_SCORE;
var   PTS : array[1..5] of pointer;
      CZ,ANGLE,Y,Z : array[1..5] of real;
      PR : byte;
      OLDY,PRio : array[1..5] of byte;
      ys : integer;
      ANGLE_SPEED,COUNTER : real;
      K : byte;
      F : text;
begin
  assign(F,'TABLE.HSC');
  reset(F);
  ANGLE_SPEED:=0;
  t2_set_buf(1); t2_band(0,200,0);
  for K:=1 to 5 do begin 
    readln(F,N[K]); readln(F,SCS[K]);
    N[K]:=N[K]+'    '+SCS[K];
  end;
  close(F);
  for L:=1 to 5 do begin 
    ANGLE[L]:=sin(6.28*(l/5)); 
    Y[L]:=120+(40*sin(ANGLE[L])); 
    Z[L]:=sin((ANGLE[L])+1.57); 
  end;
  N[6]:=N[3]; N[3]:=N[4]; N[4]:=N[5]; N[5]:=N[6];

  for K:=1 to 5 do begin
    t2_set_style(0,0,text_centre,0);
    t2_write(160,1,N[K],15);
    for L:=0 to 16 do
      for YS:=0 to 320 do
        begin
          if K<>4 then if t2_getdot(YS,L)=15 then t2_dot(YS,L,L+(K*32));
          if K=4 then if t2_getdot(YS,L)=15 then t2_dot(YS,L,L+(9*16));
        end;
    getmem(PTS[K],1702);
    t2_getpic(106,0,106,16,PTS[K]);
    t2_band(0,16,0);
  end;
  t2_band(0,200,0); screen_flip(1,FALSE,false); t2_set_buf(0); t2_band(0,200,0);
  P:=@HOF; t2_putpic(0,0,P); for K:=1 to 5 do OLDY[K]:=180;
  repeat
    for L:=1 to 5 do CZ[L]:=Z[L];
    {GET PRIORITY}
    PR:=1;
    for K:=1 to 5 do begin
      for L:=1 to 5 do begin
        if CZ[L]>CZ[PR] then PR:=L;
      end;
      PRIO[K]:=PR;
      CZ[PR]:=-999;
    end;
    t2_vretrace;
    for K:=1 to 5 do t2_block(106,OLDY[PRIO[K]],106,16,0);
    foR K:=1 to 5 do begin
      t2_putbakpic(100,trunc(Y[PRIO[K]]),PTS[PRIO[K]]);
      OLDY[PRIO[K]]:=trunc(Y[PRIO[K]]);
    end;
    COUNTER:=COUNTER+0.005;
    if COUNTER>6.28 THEN COUNTER:=COUNTER-6.28;
    ANGLE_SPEED:=0.08*sin(COUNTER);
    for K:=1 to 5 do begin
      ANGLE[K]:=ANGLE[K]+ANGLE_SPEED;
      if ANGLE[K]<0 then ANGLE[K]:=ANGLE[K]+6.28;
      if ANGLE[K]>6.28 then ANGLE[K]:=ANGLE[K]-6.28;
      Y[K]:=120+(40*sin(ANGLE[K])); Z[K]:=sin((ANGLE[K])+1.57);
    end;
  until keypressed;
  for K:=1 to 5 do freemem(PTS[K],1702);
end;

procedure CHECKOUT;
begin
  DROWNFLAG:=false;
  if SCREEN[trunc( CX/8)+1,trunc(CY/8)+1]=7 then begin
    SCREEN[trunc(CX/8)+1,trunc(CY/8)+1]:=8;
    inc(MBITS); INC(SCORE,LEVNO); inc(MOWER_T,2); 
  end;
  if (SCREEN[trunc(CX/8)+1,trunc(CY/8)+1]=5) or (SCREEN[trunc(CX/8)+1,trunc(CY/8)+1]=6) then begin
    SCREEN[trunc(CX/8)+1,trunc(CY/8)+1]:=9; GARD:=true; 
  end;
  if SCREEN[trunc(CX/8)+1,trunc(CY/8)+1]>9 then DROWNFLAG:=true;

  GL:=true; GR:=GL; GU:=GL; GD:=GL;
  if (CX>=8) then if SCREEN[trunc(CX/8),trunc(CY/8)+1]<=4 then GL:=false;
  if (CX<312) then if SCREEN[trunc(CX/8)+2,trunc(CY/8)+1]<=4 then GR:=false;
  if (CY>=8) then if SCREEN[trunc(CX/8)+1,trunc(CY/8)]<=4 then GU:=false;
  if (CY<152) then if SCREEN[trunc(CX/8)+1,trunc(CY/8)+2]<=4 then GD:=false;
  if CX<8 then GL:=false;
  if CX>=312 then GR:=false;
  if CY<8 then GU:=false;
  if CY>=152 then GD:=false;
end;

procedure WRITE_LETTER(CHS : char; Col : byte);
  var W1,W2 : byte;
begin
  t2_block(0,180,16,16,0);
  if CHS<>' ' then begin
    t2_write(0,180,CHS,15);
    for W1:=180 to 194 do
      for W2:=0 to 16 do
        if t2_getdot(W2,W1)<>0 then t2_dot(W2,W1,232+ ((Col+(W1-180)) mod 20) );
  end;
end;

procedure TITLE;
  var SCOUNT,fall,CYC,L1,L2,L3,HMOVE : byte;
      STRIPS : array[1..121] of pointer;
      YPOS,FALL_RATE : array[1..121] of real;
      CHCOUNT : integer;
      PT : pointer;
      C : char;
      music  : PDSMMusicInfo;
      ANGLE : real;
      Ct,Tc,GlobStart : byte;
      Track : array[0..3] of byte;

begin
  startinterrupt;
  GlobStart:=0;
  t2_set_buf(1);
  t2_band(0,200,0);
  PT:=@TEXTY;
  if ch<>'H' then begin
    FALL:=0;
    t2_set_buf(1);
    t2_band(0,200,0);
    t2_putpic(0,1,@WCTE);
    for CYC:=1 to 49 do begin
      getmem(STRIPS[CYC],126);
      t2_getpic(0,CYC-1,120,1,STRIPS[CYC]);
    end;
    CYC:=0;
    t2_Set_buf(0); t2_band(0,200,0);
    for L1:=49 downto 1 do begin
      L2:=0;
      for CYC:=L1 to 49 do begin
        inc(L2);
        t2_putpic(100,L2,STRIPS[CYC]);
      end;
      t2_vretrace;
    end;
    for L1:=2 to 50 do
      t2_putpic(100,L1,STRIPS[L1-1]);
    for L1:=1 to 49 do begin
      freemem(STRIPS[L1],126);
    end;
    for L1:=100 to 220 do begin
      getmem(STRIPS[L1-99],56);
      t2_getpic(L1,1,1,50,STRIPS[L1-99]);
      YPOS[L1-99]:=1;
      FALL_RATE[L1-99]:=(random(500)/1500)+0.7;
    end;
    delay(500);
    repeat
      for L1:=100 TO 220 do begin
        YPOS[L1-99]:=YPOS[L1-99]+FALL_RATE[L1-99];
        t2_putpic(L1,trunc(YPOS[L1-99]),STRIPS[L1-99]);
        if (YPOS[L1-99]>=100) and (FALL_RATE[L1-99]<>0) then begin FALL_RATE[L1-99]:=0; INC(FALL); end;
      end;
      t2_vretrace;
    until FALL=121;
    delay(500);
    for L1:=100 to 220 do freemem(STRIPS[L1-99],56);
    for L1:=1 to 50 do begin
      getmem(STRIPS[L1],130);
      t2_getpic(98,L1+99,124,1,STRIPS[L1]);
    end;
    L2:=101;
    ANGLE:=-1.57;
    repeat
      dec(L2);
      for L1:=L2 to L2+49 do begin
        if L1>100 then t2_putpic(98,L1,STRIPS[L1-(L2-1)]);
        if (l1<=100) and (L1>=50) then begin
          ANGLE:=1.57+(((100-L1)/50)*3.14);
          t2_putpic(49+TRUNC(50*(SIN(ANGLE))),L1,STRIPS[L1-(L2-1)]);
          t2_putpic(147-TRUNC(50*(SIN(angle))),l1,STRIPS[L1-(L2-1)]);
        end;
        if (L1<=50) then begin 
          t2_putpic(1,L1,STRIPS[L1-(L2-1)]);
          t2_putpic(196,L1,STRIPS[L1-(L2-1)]); 
        end;
      end;
      t2_vretrace;
    until L2<=1;
    for L1:=1 to 50 do freemem(STRIPS[L1],130);
    DELAY(500);
  end;
  repeat
    if keypressed then repeat until readkey<>'';
  until not keypressed;
  t2_set_buf(1);
  t2_band(0,200,0);
  t2_putpic(3,3,@WCTE);
  t2_putpic(198,3,@WCTE);
  t2_putBAKpic(85,40,@TDAT);
  t2_putpic(242,111,@PLAY);
  t2_putpic(11,64,@HISC);
  t2_putpic(242,64,@LEVE);
  t2_putpic(11,111,@SPEE);
  T2_SET_STYLE(0,0,2,2);
  t2_block(131,0,58,40,0);
  if MAX_SPEED=1 then T2_write(160,10,'FAST',15);
  if MAX_SPEED=2 then T2_write(160,10,'SLOW',15);
  str(LEVNO,ST); ST:='LEVEL '+ST;
  t2_write(160,30,ST,15);
  t2_set_buf(0);
  t2_set_Style(0,0,0,0);
  screen_flip(1,false,false);
  CHCOUNT:=0; HMOVE:=0;
  repeat
    shutinterrupt; DSMPoll;
    repeat
      t2_vretrace;
      getmem(P,2234);
      t2_getpic(83,180,159,14,P);
      t2_putpic(81,180,P);
      t2_block(240,180,2,14,0);
      freemem(P,2234);
      Music:=DSMGetMusicInfo;
      Track[0]:=Music^.Tracks[0].Eqbar div 4;
      Track[1]:=Music^.Tracks[1].Eqbar div 4;
      Track[2]:=Music^.Tracks[2].Eqbar div 4;
      Track[3]:=Music^.Tracks[3].Eqbar div 4;
      Tc:=0;
      repeat
        if Track[0]>=Tc then Ct:=244-Tc;
        if Track[0]<Tc then Ct:=0;
        t2_dot(22,185-(tc),Ct); t2_dot(26,185-(tc),(Ct*2) mod 255);
        t2_dot(38,185-(tc*2),Ct); t2_dot(42,185-(tc*2),(Ct*2) mod 255);
        if Track[1]>=Tc then Ct:=244-Tc;
        if Track[1]<Tc then Ct:=0; 
        t2_dot(30,185-(tc*2),(Ct*2) mod 255); t2_dot(34,185-(tc*2),Ct);
        t2_dot(46,185-(tc),(Ct*2)mod 255); t2_dot(50,185-(tc),Ct);
        if Track[2]>=Tc then Ct:=244-Tc;
        if Track[2]<Tc then Ct:=0;
        t2_dot(260,185-(tc),Ct); t2_dot(264,185-(tc),(Ct*2) mod 255);
        t2_dot(276,185-(tc*2),Ct); t2_dot(280,185-(tc*2),(Ct*2) mod 255);
        if Track[3]>=Tc then Ct:=244-Tc;
        if Track[3]<Tc then Ct:=0;
        t2_dot(268,185-(tc*2),(Ct*2) mod 255); t2_dot(272,185-(tc*2),Ct);
        t2_dot(284,185-(tc),(Ct*2) mod 255); t2_dot(288,185-(tc),Ct);
        inc(Tc);
      until Tc>=16;
      t2_set_buf(1);

      if CHCOUNT=0 then begin
        t2_band(0,200,0);
        inc(CHCOUNT); if CHCOUNT>=sizeof(PT) then CHCOUNT:=1;
        T2_SET_STYLE(0,0,0,0);
        WRITE_LETTER(chr(mem[seg(PT^):Ofs(PT^)+CHCOUNT]),GlobStart);
      end;

      inc(HMOVE); L2:=0; DSMPoll;
      c:=chr(mem[seg(PT^):Ofs(PT^)+CHCOUNT]);
      if HMOVE<T2_WidthChar(c) then L2:=1;

      if (L2=0) and (c=' ') and (SCOUNT>0) then BEGIN dec(SCOUNT); L2:=1; END;

      if L2=0 then begin
        inc(CHCOUNT);
        if CHCOUNT=1023 then CHCOUNT:=1025
        else if CHCOUNT=2047 then CHCOUNT:=2049
        else if CHCOUNT=3071 then CHCOUNT:=3073
        else if CHCOUNT=3311 then CHCOUNT:=1;
        c:=chr(mem[seg(PT^):Ofs(PT^)+CHCOUNT]);
        WRITE_LETTER(C,GlobStart);
        GlobStart:=(GlobStart+1) mod 20;
        if C=' ' then SCOUNT:=5;
        HMOVE:=0;
      end;
      if HMOVE<>0 then BEGIN
        getmem(P,22); t2_getpic(HMOVE,180,1,14,P);
        t2_set_buf(0);
        t2_putpic(240,180,P); t2_putpic(241,180,P); freemem(P,22);
      end;
      t2_set_buf(0);
    until keypressed;
    startinterrupt;
    ch:=upcase(readkey);
    if ch='S' then begin
      inc(MAX_SPEED);
      if MAX_SPEED=3 then MAX_SPEED:=1;
    end;
    if ch='L' then begin
      inc(LEVNO); if LEVNO>MAX_LEVEL then LEVNO:=1;
    end;
    if ch=chr(27) then begin
      shutsound;
      Jumpout;
    end;
    if (ch='S') or (ch='L') then begin
      t2_set_buf(0);
      T2_SET_STYLE(0,0,2,2);
      t2_block(131,0,58,40,0);
      if MAX_SPEED=1 then T2_write(160,10,'FAST',15);
      if MAX_SPEED=2 then T2_write(160,10,'SLOW',15);
      str(LEVNO,ST); ST:='LEVEL '+ST;
      t2_write(160,30,ST,15);
      t2_set_style(0,0,0,0);
    end;
    if (ch='H') then HI_SCORE;
  until (ch='P') or (ch='H');
end;

procedure CLEARBUF;
begin
  inline($fa);
  memw[$40:$1A]:=memw[$40:$1C];
  inline($fb);
end;

procedure Keyclick; interrupt;
begin
  Pval:=Port[$60];
  if Pval < $80 then begin
    if Pval=$48 then keydata.kUP:=true
    else if Pval=$50 then keydata.kDOWN:=true
    else if Pval=$4B then keydata.kLEFT:=true
    else if Pval=$4D then keydata.kRIGHT:=true
    else if Pval=1 then keydata.KESC:=true
    else if Pval=82 then keydata.kINS:=true
    else if PVal=83 then keydata.kdel:=true;
  end else begin
    Dec(Pval,$80);
    if Pval=$48 then keydata.kUP:=false
    else if Pval=$50 then keydata.kDOWN:=false
    else if Pval=$4B then keydata.kLEFT:=false
    else if Pval=$4D then keydata.kRIGHT:=false
    else if Pval=1 then keydata.kesc:=false
    else if Pval=82 then keydata.KINS:=false
    else if Pval=83 then keydata.KDEL:=false;
  end;
  inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  KbdIntVec;
end;
{$F-}

procedure LOADLEV(S : string;REPLACE : boolean);
  var LX,LY : byte;
      F : file;
      st : string;
begin
  t2_band(0,200,0);
  assign(F,S);
  reset(F,1);
  blockread(F,CH,1); st:=ch;
  blockread(F,CH,1); st:=st+ch;
  blockread(F,CH,1); st:=st+ch;
  blockread(F,CH,1); st:=st+ch;
  if REPLACE then GBITS:=0;
  if ST='@TDA' then begin
    for X:=1 to 40 do for Y:=1 to 20 do begin
      blockread(F,CH,1);
      if REPLACE then SCREEN[X,Y]:=ord(CH);
      if (REPLACE) and (ord(CH)=7) then inc(GBITS);
      t2_putpic(((X-1)*8),((Y-1)*8),GPOINTERS[SCREEN[X,Y]]);
      OLDX:=255; OLDY:=255;
    end;
    blockread(F,CH,1); MX:=ord(CH);
    blockread(F,CH,1); MY:=ord(CH);
    blockread(F,CH,1); MD:=ord(CH);
    blockread(F,CH,1); NX:=ord(CH);
    blockread(F,CH,1); NY:=ord(CH);
    blockread(F,CH,1); GX:=ord(CH);
    blockread(F,CH,1); GY:=ord(CH);
    blockread(F,CH,1); DX:=ord(CH);
    blockread(F,CH,1); DY:=ord(CH);
    close(F);
    MFRAME:=1; MFRAMEDIR:=1; DFRAME:=1; DFRAMEDIR:=1; GFRAME:=1; GFRAMEDIR:=1;
    NFRAME:=1; NFRAMEDIR:=1; DMX:=(DX-1)*8; DMY:=(DY-1)*8; GNX:=(NX-1)*8; GNY:=(NY-1)*8;
    GMX:=(GX-1)*8; GMY:=(GY-1)*8; CX:=(MX-1)*8; CY:=(MY-1)*8;
    P:=@PANEL;
    t2_putpic(0,161,P);
    getmem(BACKP,6406);
    t2_getpic(0,161,320,20,BACKP);
    P:=@MOWER;
    if LIVES=3 then t2_putpic(48,182,P);
    if LIVES>=2 then t2_putpic(26,182,P);
    t2_putpic(4,182,P);
  end;
end;

procedure ERASE_1(Direction : byte; BX,BY : integer);
begin
  t2_putpic(trunc(BX/8)*8,(trunc(BY/8))*8,GPOINTERS[SCREEN[trunc(BX/8)+1,TRUNC(by/8)+1]]);
  if (Direction=0) and (BY<152) then
     t2_putpic((trunc(BX/8)*8),(trunc(BY/8)+1)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+2]])
  else if (Direction=1) and (BX>=8) then
     t2_putpic((trunc(BX/8)+1)*8,(trunc(BY/8))*8,GPOINTERS[SCREEN[trunc(BX/8)+2,TRUNC(BY/8)+1]])
  else if (Direction=2) and (BY>=8) then
     t2_putpic((trunc(BX/8)*8),(trunc(BY/8)+1)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+2]])
  else if (Direction=3) and (BX<312) then
    t2_putpic((trunc(BX/8)+1)*8,(trunc(BY/8)*8),GPOINTERS[SCREEN[trunc(BX/8)+2,trunc(BY/8)+1]])
  end;

procedure ERASE_2(Direction : byte; BX,BY : integer);
begin
  if DIRECTION=0 then begin
    t2_putpic(trunc(BX/8)*8,(trunc(BY/8))*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+1]]);
    if BY<152 then t2_putpic(trunc(BX/8)*8,(trunc(BY/8)+1)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+2]]);
    If BY<144 then t2_putpic(trunc(BX/8)*8,(trunc(BY/8)+2)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+3]]);
    if BY>=152 then begin t2_block(trunc(BX/8)*8,(trunc(BY/8)+1)*8,8,8,0); T2_putpic(0,161,BACKP); end;
    IF BY>=144 then begin t2_block(trunc(BX/8)*8,(trunc(BY/8)+2)*8,8,8,0); T2_putpic(0,161,BACKP); end;
  end else if DIRECTION=1 then begin
    t2_putpic(trunc(BX/8)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+1]]);
    if BX<312 then t2_putpic((trunc(BX/8)+1)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+2,trunc(BY/8)+1]]);
    if BX>=8 then t2_putpic((trunc(BX/8)-1)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8),trunc(BY/8)+1]]);
  end else if DIRECTION=2 then begin
    if BY<152 then t2_putpic(trunc(BX/8)*8,trunc((BY/8)+1)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+2]]);
    t2_putpic(trunc(BX/8)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+1]]);
    if BY>=8 then t2_putpic(trunc(BX/8)*8,trunc((BY/8)-1)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)]]);
  end else if DIRECTION=3 then begin
    t2_putpic(trunc(BX/8)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+1,trunc(BY/8)+1]]);
    if BX<312 then t2_putpic((trunc(BX/8)+1)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+2,trunc(BY/8)+1]]);
    if BX<304 then t2_putpic((trunc(BX/8)+2)*8,trunc(BY/8)*8,GPOINTERS[SCREEN[trunc(BX/8)+3,trunc(BY/8)+1]]);
  end;
end;

procedure MOVE_MAN(DIRECTION,FB : byte); {0=UP, 1=RIGHT, 2=DOWN, 3=LEFT}
begin
  if DIRECTION=0 then begin {UP}
    if FB<>3 then begin
      IF ANITOG=0 then begin
        MFRAME:=MFRAME+MFRAMEDIR;
        IF (MFRAME=1) or (MFRAME=3) then MFRAMEDIR:=-MFRAMEDIR;
      end;
      inc(ANITOG); if ANITOG=3 then ANITOG:=0;
    end;
    if FB=1 then dec(CY);
    t2_putbakpic(CX,CY,MANIM[1+((MFRAME-1)*2)]);
    t2_putbakpic(CX,CY+8,MANIM[2+((MFRAME-1)*2)]);
  end else if DIRECTION=1 then begin {RIGHT}
    if FB<>3 then begin
      if ANITOG=0 then begin
        MFRAME:=MFRAME+MFRAMEDIR;
        IF (MFRAME=1) or (MFRAME=3) then MFRAMEDIR:=-MFRAMEDIR;
      end;
      inc(ANITOG); if ANITOG=3 then ANITOG:=0;
    end;
    if FB=1 then inc(CX);
    t2_putbakpic(CX,CY,MANIM[20+((MFRAME-1)*2)]);
    t2_putbakpic(CX-8,CY,MANIM[19+((MFRAME-1)*2)]);
  end else if DIRECTION=2 then begin {DOWN}
    if FB<>3 then begin
      if ANITOG=0 then begin
        MFRAME:=MFRAME+MFRAMEDIR;
        IF (MFRAME=1) or (MFRAME=3) then MFRAMEDIR:=-MFRAMEDIR;
      end;
      inc(ANITOG); if ANITOG=3 then ANITOG:=0;
    end;
    if FB=1 then inc(CY);
    t2_putbakpic(CX,CY,MANIM[8+((MFRAME-1)*2)]);
    t2_putbakpic(CX,CY-8,MANIM[7+((MFRAME-1)*2)]);
  end else if DIRECTION=3 then begin {LEFT}
    if FB<>3 then begin
      IF ANITOG=0 then begin
        MFRAME:=MFRAME+MFRAMEDIR;
        IF (MFRAME=1) or (MFRAME=3) then MFRAMEDIR:=-MFRAMEDIR;
      end;
      inc(ANITOG); if ANITOG=3 then ANITOG:=0;
    end;
    if FB=1 then dec(CX);
    t2_putbakpic(CX,CY,MANIM[13+((MFRAME-1)*2)]);
    t2_putbakpic(CX+8,CY,MANIM[14+((MFRAME-1)*2)]);
  end;
end;

procedure MOVE_NEIGHBOUR(DIRECTION : byte;FB : byte); {0=UP, 1=RIGHT, 2=DOWN, 3=LEFT}
begin
  if DIRECTION=0 then begin {UP}
    if FB<>3 then begin
      if NANITOG=0 then begin
        NFRAME:=NFRAME+NFRAMEDIR;
        IF (NFRAME=1) or (NFRAME=3) then NFRAMEDIR:=-NFRAMEDIR;
      end;
      inc(NANITOG); if NANITOG=3 then NANITOG:=0;
    end;
    if FB=1 then Dec(GNY);
    t2_putbakpic(gNX,gNY,NANIM[1+((NFRAME-1))]);
  end else if DIRECTION=1 then begin {RIGHT}
    if FB<>3 then begin
      if NANITOG=0 then begin
        NFRAME:=NFRAME+NFRAMEDIR;
        IF (NFRAME=1) or (NFRAME=3) then NFRAMEDIR:=-NFRAMEDIR;
      end;
      inc(NANITOG); if NANITOG=3 then NANITOG:=0;
    end;
    if FB=1 then inc(gNX);
    t2_putbakpic(gNX,gNY,NANIM[7+((NFRAME-1))]);
  end else if DIRECTION=2 then begin {DOWN}
    if FB<>3 then begin
      if NANITOG=0 then begin
        NFRAME:=NFRAME+NFRAMEDIR;
        IF (NFRAME=1) or (NFRAME=3) then NFRAMEDIR:=-NFRAMEDIR;
      end;
      inc(NANITOG); if NANITOG=3 then NANITOG:=0;
    end;
    if FB=1 then inc(gNY);
    t2_putbakpic(gNX,gNY,NANIM[4+((NFRAME-1))]);
  end else if DIRECTION=3 then begin {LEFT}
    if FB<>3 then begin
      IF NANITOG=0 then begin
        NFRAME:=NFRAME+NFRAMEDIR;
        IF (NFRAME=1) or (NFRAME=3) then NFRAMEDIR:=-NFRAMEDIR;
      end;
      inc(NANITOG); if NANITOG=3 then NANITOG:=0;
    end;
    if FB=1 then dec(gNX);
    t2_putbakpic(gNX,gNY,NANIM[10+((NFRAME-1))]);
  end;
end;

procedure MOVE_GARDENER(DIRECTION,FB : byte); {0=UP, 1=RIGHT, 2=DOWN, 3=LEFT}
begin
  if DIRECTION=0 then begin {UP}
    if FB<>3 then begin
      if GANITOG=0 then begin
        GFRAME:=GFRAME+GFRAMEDIR;
        IF (GFRAME=1) or (GFRAME=3) then GFRAMEDIR:=-GFRAMEDIR;
      end;
      inc(GANITOG); if GANITOG=6 then GANITOG:=0;
    end;
    if FB=1 then dec(GMY);
    t2_putbakpic(GMX,GMY,GANIM[1+((GFRAME-1)*2)]);
    t2_putbakpic(GMX,GMY+8,GANIM[2+((GFRAME-1)*2)]);
  end else if DIRECTION=1 then begin {RIGHT}
    if FB<>3 then begin
      if GANITOG=0 then begin
        GFRAME:=GFRAME+GFRAMEDIR;
        IF (GFRAME=1) or (GFRAME=3) then GFRAMEDIR:=-GFRAMEDIR;
      end;
      inc(GANITOG); if GANITOG=6 then GANITOG:=0;
    end;
    if FB=1 then inc(GMX);
    t2_putbakpic(GMX,GMY,GANIM[20+((GFRAME-1)*2)]);
    t2_putbakpic(GMX-8,GMY,GANIM[19+((GFRAME-1)*2)]);
  end else if DIRECTION=2 then begin {DOWN}
    if FB<>3 then begin
      if GANITOG=0 then begin
        GFRAME:=GFRAME+GFRAMEDIR;
        IF (GFRAME=1) or (GFRAME=3) then GFRAMEDIR:=-GFRAMEDIR;
      end;
      inc(GANITOG); if GANITOG=6 then GANITOG:=0;
    end;
    if FB=1 then inc(GMY);
    t2_putbakpic(GMX,GMY,GANIM[8+((GFRAME-1)*2)]);
    t2_putbakpic(GMX,GMY-8,GANIM[7+((GFRAME-1)*2)]);
  end else if DIRECTION=3 then begin {LEFT}
    if FB<>3 then begin
      if GANITOG=0 then begin
        GFRAME:=GFRAME+GFRAMEDIR;
        IF (GFRAME=1) or (GFRAME=3) then GFRAMEDIR:=-GFRAMEDIR;
      end;
      inc(GANITOG); if GANITOG=6 then GANITOG:=0;
    end;
    if FB=1 then dec(GMX);
    t2_putbakpic(GMX,GMY,GANIM[13+((GFRAME-1)*2)]);
    t2_putbakpic(GMX+8,GMY,GANIM[14+((GFRAME-1)*2)]);
  end;
end;

procedure MOVE_DOG(DIRECTION,FB : byte); {0=UP, 1=RIGHT, 2=DOWN, 3=LEFT}
begin
  if DIRECTION=0 then begin {UP}
    if FB<>3 then begin
      if DANITOG=0 then begin
        DFRAME:=DFRAME+DFRAMEDIR;
        IF (DFRAME=1) or (DFRAME=3) then DFRAMEDIR:=-DFRAMEDIR;
      end;
      inc(DANITOG); if DANITOG=3 then DANITOG:=0;
    end;
    if FB=1 then dec(DMY);
    t2_putbakpic(DMX,DMY,DANIM[13+((DFRAME-1)*2)]);
    t2_putbakpic(DMX,DMY+8,DANIM[14+((DFRAME-1)*2)]);
  end else if DIRECTION=1 then begin {RIGHT}
    if FB<>3 then begin
      if DANITOG=0 then begin
        DFRAME:=DFRAME+DFRAMEDIR;
        IF (DFRAME=1) or (DFRAME=3) then DFRAMEDIR:=-DFRAMEDIR;
      end;
      inc(DANITOG); if DANITOG=3 then DANITOG:=0;
    end;
    if FB=1 then inc(DMX);
    t2_putbakpic(DMX,DMY,DANIM[8+((DFRAME-1)*2)]);
    t2_putbakpic(DMX-8,DMY,DANIM[7+((DFRAME-1)*2)]);
  end else if DIRECTION=2 then begin {DOWN}
    if FB<>3 then begin
      if DANITOG=0 then begin
        DFRAME:=DFRAME+DFRAMEDIR;
        IF (DFRAME=1) or (DFRAME=3) then DFRAMEDIR:=-DFRAMEDIR;
      end;
      inc(DANITOG); if DANITOG=3 then DANITOG:=0;
    end;
    if FB=1 then inc(DMY);
    t2_putbakpic(DMX,DMY,DANIM[20+((DFRAME-1)*2)]);
    t2_putbakpic(DMX,DMY-8,DANIM[19+((DFRAME-1)*2)]);
  end else if DIRECTION=3 then begin {LEFT}
    if FB<>3 then begin
      if DANITOG=0 then begin
        DFRAME:=DFRAME+DFRAMEDIR;
        IF (DFRAME=1) or (DFRAME=3) then DFRAMEDIR:=-DFRAMEDIR;
      end;
      inc(DANITOG); if DANITOG=3 then DANITOG:=0;
    end;
    if FB=1 then dec(DMX);
    t2_putbakpic(DMX,DMY,DANIM[1+((DFRAME-1)*2)]);
    t2_putbakpic(DMX+8,DMY,DANIM[2+((DFRAME-1)*2)]);
  end;
end;

procedure dogame;
begin
  T2_SET_BUF(1);
  str(LEVNO,ST);
  ST:=LEV_DIR+'LEVEL'+ST+'.TDA`';
  MBITS:=0;
  loadlev(ST,true);
  SCREEN_FLIP(1,false,false);
  repeat
    GARD:=FALSE; LOYTOG:=0; ANITOG:=0; NEIGHBOUR_MOVE:=0; SPEED_TOGGLE:=0; OVERLOAD:=false;
    GSPEED_TOGGLE:=0; GARDENER_MOVE:=0; GMD:=8; NF:=FALSE; MANFLAG:=0; GF:=FALSE;
    TOLTOG:=0; MOWER_T:=0; DOG_TOL:=130; DOG_DIR:=0; DOG_MOVE:=0; KILLFLAG:=false; DOG_LOY:=130;
    T2_SET_BUF(0);
    X:=30; M:=0; Y:=2; DD:=3; ND:=3; OLD_DIR:=3; GU:=false; GD:=GU; GL:=GU; GR:=GU;
    repeat
      if (keydata.kleft) or (keydata.kright) or (keydata.kup) or (keydata.kdown) or (keydata.kins) OR (keydata.kesc) then begin
        if M=0 then begin
          KILLFLAG:=false;
          CHECKOUT;
          if (not OVERLOAD) and (keydata.kup) and (GU) and (CY>=8) then begin nD:=0; M:=8; end;
          if (not OVERLOAD) and (keydata.kdown) and (GD) and (CY<152) then begin nD:=2; M:=8; end;
          if (not OVERLOAD) and (keydata.kright) and (GR) and (CX<312) then begin nD:=1; M:=8; end;
          if (not OVERLOAD) and (keydata.kleft) and (GL) and (CX>=8) then begin nD:=3; M:=8; end;
          if (keydata.kesc) then begin shutinterrupt; shutsound; Jumpout;  end;
          if (keydata.kins) and (DOG_LOY>0) then begin 
            KILLFLAG:=true; inc(LOYTOG); if LOYTOG=3 then LOYTOG:=0;
            if LOYTOG=0 then dec(DOG_LOY); 
          end;
        end;
      end;
      if (CX/8=trunc(CX/8)) and (CY/8=trunc(CY/8)) and (M=8) then DD:=ND;
      if (DD=0) AND (CY>=0) and (M>0) then begin ERASE_2(OLD_DIR,CX,CY); MANFLAG:=1; end;
      if (DD=1) and (CX<312) and (M>0) then begin ERASE_2(OLD_DIR,CX,CY); MANFLAG:=1; end;
      if (DD=2) and (CY<152) and (M>0) then begin ERASE_2(OLD_DIR,CX,CY); MANFLAG:=1; end;
      if (DD=3) and (CX>=0) and (M>0) then begin ERASE_2(OLD_DIR,CX,CY); MANFLAG:=1;  end;
      inc(TOLTOG);
      if (TOLTOG div 5=(TOLTOG/5)) and (MOWER_T>0) then dec(MOWER_T);
      if TOLTOG>=20 then begin
        if DOG_TOL>0 then dec(DOG_TOL);
        TOLTOG:=0;
      end;

      {Artificial Intelligence for dog}
      if (DOG_MOVE=0) and ((DOG_TOL=0) and (not (OVERLOAD)) and (not (KILLFLAG))) then begin
        GD_X:=CX-gMX;
        GD_Y:=CY-gMY;
        DMDX:=4; DMDY:=4; DOG_DIR:=4;
        if (CX>DMX) and (DMX<312) then
          if (SCREEN[trunc(DMX/8)+2,trunc(DMY/8)+1]>6) and (SCREEN[trunc(DMX/8)+2,trunc(DMY/8)+1]<10)
            then DMDX:=1;
        if (CX<DMX) and (DMX>7) then
          if (SCREEN[trunc(DMX/8),trunc(DMY/8)+1]>6) and (SCREEN[trunc(DMX/8),trunc(DMY/8)+1]<10)
            then DMDX:=3;
        if (CY>DMY) and (DMY<152) then
          if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)+2]>6) and (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)+2]<10)
            then DMDY:=2;
        if (CY<DMY) and (DMY>7) then
          if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]>6) and (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]<10)
            then DMDY:=0;
        if (DMDX<>4) and (DMDY=4) then DOG_DIR:=DMDX;
        if (DMDY<>4) and (DMDX=4) then DOG_DIR:=DMDY;
        if (DMDX<>4) and (DMDY<>4) then begin
          if abs(GD_X)<abs(GD_Y) then DOG_DIR:=DMDY;
          if abs(GD_X)>=abs(GD_Y) then DOG_DIR:=DMDX;
        end;
        if DOG_DIR<>4 then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DDIR:=DOG_DIR; DOGFLAG:=1; end;
      end;

      if (KILLFLAG) and (DOG_MOVE=0) then begin
        DG:=sqrt(Abs(sqr(GMX-DMX)+sqr(GMY-DMY))); AIMX:=GNX; AIMY:=GNY;
        if DG<sqrt(Abs(sqr(GNX-DMX)+SQR(GNY-DMY))) then begin AIMX:=GMX; AIMY:=GMY; end;
        if not GARD then begin AIMX:=GNX; AIMY:=GNY; end;
        GD_X:=AIMX-DMX;
        GD_Y:=AIMY-DMY;
        DMDX:=4; DMDY:=4; DOG_DIR:=4;
        if (AIMX>DMX) and (DMX<312) then
          if (SCREEN[trunc(DMX/8)+2,trunc(DMY/8)+1]>6) and (SCREEN[trunc(DMX/8)+2,trunc(DMY/8)+1]<10)
            then DMDX:=1;
        if (AIMX<DMX) and (DMX>7) then
          if (SCREEN[trunc(DMX/8),trunc(DMY/8)+1]>6) and (SCREEN[trunc(DMX/8),trunc(DMY/8)+1]<10)
            then DMDX:=3;
        if (AIMY>DMY) and (DMY<152) then
          if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)+2]>6) and (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)+2]<10)
            then DMDY:=2;
        if (AIMY<DMY) and (DMY>7) then
          if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]>6) and (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]<10)
            then DMDY:=0;
        if (DMDX<>4) and (DMDY=4) then DOG_DIR:=DMDX;
        if (DMDY<>4) and (DMDX=4) then DOG_DIR:=DMDY;
        if (DMDX<>4) and (DMDY<>4) then begin
          if abs(GD_X)<abs(GD_Y) then DOG_DIR:=DMDY;
          if abs(GD_X)>=abs(GD_Y) then DOG_DIR:=DMDX;
        end;
        if DOG_DIR<>4 then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DOGFLAG:=1; DDIR:=DOG_DIR; end;

      end;

      if DOG_MOVE>0 then begin ERASE_2(DDIR,DMX,DMY); DOGFLAG:=1; end;
      if ((DOG_TOL>0) or (OVERLOAD)) and (not KILLFLAG) then begin
        if DOG_DIR>4 then DOG_DIR:=random(4);
        if DOG_MOVE=0 then begin
          if random(50)<5 then DOG_DIR:=random(4);
          if (DOG_DIR=0) then begin
            if (DMY>=8) then if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]>6) and (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)]<10)
              then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DOGFLAG:=1; end; 
          end;
          if (DOG_DIR=1) then begin
            if (DMX<312) then if (SCREEN[trunc(DMX/8)+2,trunc(DMY/8)+1]>6) and (SCREEN[TRUNC(DMX/8)+2,trunc(DMY/8)+1]<10)
              then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DOGFLAG:=1; end; 
          end;
          if (DOG_DIR=2) then begin
            if (DMY<152) then if (SCREEN[trunc(DMX/8)+1,trunc(DMY/8)+2]>6) and (SCREEN[TRUNC(DMX/8)+1,trunc(DMY/8)+2]<10)
              then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DOGFLAG:=1; end; 
          end;
          if (DOG_DIR=3) then begin
            if (DMX>=8) then if (SCREEN[trunc(DMX/8),trunc(DMY/8)+1]>6) and (SCREEN[TRUNC(DMX/8),trunc(DMY/8)+1]<10)
              then begin DOG_MOVE:=8; erase_2(DDIR,DMX,DMY); DOGFLAG:=1; end; 
          end;
          if DOG_MOVE=0 then begin DOG_DIR:=random(4); erase_2(DDIR,DMX,DMY); end;
          DDIR:=DOG_DIR;
        end;
      end;

      {Artificial Intelligence for gardener}
      if GARD=TRUE then begin
        DG:=sqrt(Abs(sqr(GMX-DMX)+sqr(GMY-DMY)));
        if GARDENER_MOVE=0 then begin
          if DG>64 then begin
            GD_X:=CX-gMX;
            GD_Y:=CY-gMY;
            GMDX:=4; GMDY:=4; GMD:=4;
            if (CX>gMX) and (gMX<312) then
              if (SCREEN[trunc(gMX/8)+2,trunc(gMY/8)+1]>6) and (SCREEN[trunc(gMX/8)+2,trunc(gMY/8)+1]<10)
                then GMDX:=1;
            if (CX<gMX) and (GMX>7) then
              if (SCREEN[trunc(gMX/8),trunc(gMY/8)+1]>6) and (SCREEN[trunc(gMX/8),trunc(gMY/8)+1]<10)
                then GMDX:=3;
            if (CY>gMY) and (GMY<152) then
              if (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)+2]>6) and (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)+2]<10)
                then GMDY:=2;
            if (CY<gMY) and (GMY>7) then
              if (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)]>6) and (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)]<10)
                then GMDY:=0;
            if (GMDX<>4) and (GMDY=4) then GMD:=GMDX;
            if (GMDY<>4) and (GMDX=4) then GMD:=GMDY;
            if (GMDX<>4) and (GMDY<>4) then begin
              if abs(GD_X)<abs(GD_Y) then GMD:=GMDY;
              if abs(GD_X)>=abs(GD_Y) then GMD:=GMDX;
            end;
            if GMD<>4 then GARDENER_MOVE:=8;
          end;
          if DG<=64 then begin
            GD_X:=DMX-gMX;
            GD_Y:=DMY-gMY;
            GMDX:=4; GMDY:=4; GMD:=4;
            if (DMX<gMX) and (gMX<312) then
              if (SCREEN[trunc(gMX/8)+2,trunc(gMY/8)+1]>6) and (SCREEN[trunc(gMX/8)+2,trunc(gMY/8)+1]<10)
                then GMDX:=1;
            if (DMX>gMX) and (GMX>7) then
              if (SCREEN[trunc(gMX/8),trunc(gMY/8)+1]>6) and (SCREEN[trunc(gMX/8),trunc(gMY/8)+1]<10)
                then GMDX:=3;
            if (DMY<gMY) and (GMY<152) then
              if (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)+2]>6) and (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)+2]<10)
                then GMDY:=2;
            if (DMY>gMY) and (GMY>7) then
              if (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)]>6) and (SCREEN[trunc(gMX/8)+1,trunc(gMY/8)]<10)
                then GMDY:=0;
            if (GMDX<>4) and (GMDY=4) then GMD:=GMDX;
            if (GMDY<>4) and (GMDX=4) then GMD:=GMDY;
            if (GMDX<>4) and (GMDY<>4) then begin
              if abs(GD_X)<abs(GD_Y) then GMD:=GMDY;
              if abs(GD_X)>=abs(GD_Y) then GMD:=GMDX;
            end;
            if GMD<>4 then GARDENER_MOVE:=8;
          end;
        end;
        if (GARDENER_MOVE>0) and (GSPEED_TOGGLE=0) then begin
          if (OLDGMD<>GMD) and (OLDGMD<>8) then ERASE_2(OLDGMD,gMX,gMY);
          OLDGMD:=GMD;
          ERASE_2(GMD,GMX,GMY);
          GF:=TRUE;
          GSPEED_TOGGLE:=MAX_SPEED;
        end;
        if GSPEED_TOGGLE>0 then dec(GSPEED_TOGGLE);
      end;
      if SCORE>99999 then SCORE:=99999;
  
      {Artificial Intelligence for neighbour}

      if NEIGHBOUR_MOVE=0 then begin
        DG:=sqrt(Abs(sqr(GNX-DMX)+sqr(GNY-DMY)));
        if DG>64 then begin
          ND_X:=CX-gNX;
          ND_Y:=CY-gNY;
          NMDX:=4; NMDY:=4; NMD:=4;
          if (CX>gNX) and (gNX<312) then
            if (SCREEN[trunc(gNX/8)+2,trunc(gNY/8)+1]>4) and (SCREEN[trunc(gNX/8)+2,trunc(gNY/8)+1]<10)
              then NMDX:=1;
          if (CX<gNX) and (GNX>7) then
            if (SCREEN[trunc(gNX/8),trunc(gNY/8)+1]>4) and (SCREEN[trunc(gNX/8),trunc(gNY/8)+1]<10)
              then NMDX:=3;
          if (CY>gNY) and (GNY<152) then
            if (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)+2]>4) and (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)+2]<10)
              then NMDY:=2;
          if (CY<gNY) and (GNY>7) then
            if (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)]>4) and (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)]<10)
              then NMDY:=0;
          if (NMDX<>4) and (NMDY=4) then NMD:=NMDX;
          if (NMDY<>4) and (NMDX=4) then NMD:=NMDY;
          if (NMDX<>4) and (NMDY<>4) then begin
            if abs(ND_X)<abs(ND_Y) then NMD:=NMDY;
            if abs(ND_X)>=abs(ND_Y) then NMD:=NMDX;
          end;
          if NMD<>4 then NEIGHBOUR_MOVE:=8;
        end;
        if DG<65 then begin
          ND_X:=DMX-gNX;
          ND_Y:=DMY-gNY;
          NMDX:=4; NMDY:=4; NMD:=4;
          if (DMX<gNX) and (gNX<312) then
            if (SCREEN[trunc(gNX/8)+2,trunc(gNY/8)+1]>4) and (SCREEN[trunc(gNX/8)+2,trunc(gNY/8)+1]<10)
              then NMDX:=1;
          if (DMX>gNX) and (GNX>7) then
            if (SCREEN[trunc(gNX/8),trunc(gNY/8)+1]>4) and (SCREEN[trunc(gNX/8),trunc(gNY/8)+1]<10)
              then NMDX:=3;
          if (DMY<gNY) and (GNY<152) then
            if (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)+2]>4) and (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)+2]<10)
              then NMDY:=2;
          if (DMY>gNY) and (GNY>7) then
            if (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)]>4) and (SCREEN[trunc(gNX/8)+1,trunc(gNY/8)]<10)
              then NMDY:=0;
          if (NMDX<>4) and (NMDY=4) then NMD:=NMDX;
          if (NMDY<>4) and (NMDX=4) then NMD:=NMDY;
          if (NMDX<>4) and (NMDY<>4) then begin
            if abs(ND_X)<abs(ND_Y) then NMD:=NMDY;
            if abs(ND_X)>=abs(ND_Y) then NMD:=NMDX;
          end;
          if NMD<>4 then NEIGHBOUR_MOVE:=8;
        end;
      end;
      if (NEIGHBOUR_MOVE>0) and (SPEED_TOGGLE=0) then begin
        ERASE_1(NMD,gNX,gNY);
        NF:=TRUE;
        SPEED_TOGGLE:=MAX_SPEED;
      end;
      if SPEED_TOGGLE>0 then dec(SPEED_TOGGLE);
      if (not OVERLOAD) and (((CX=DMX) and (CY=DMY)) or ((DMX=CX) and (DMY=CY-1) and (DD=2))
        or ((DMX=CX) and (DMY=CY+1) and (DD=0)) or ((DMX=CX+1) and (DMY=CY) and (DD=3)) or
        ((DMX=CX-1) and (DMY=CY) and (DD=1))) then begin DOG_TOL:=0; MOWER_T:=128; OVERLOAD:=true; end;
      if (((GNX=DMX) and (GNY=DMY)) or ((DMX=GNX) and (DMY=GNY-1) and (NMD=2))
        or ((DMX=GNX) and (DMY=GNY+1) and (NMD=0)) or ((DMX=GNX+1) and (DMY=GNY) and (NMD=3)) or
        ((DMX=GNX-1) and (DMY=GNY) and (NMD=1))) then inc(SCORE);
      if (((GMX=DMX) and (GMY=DMY)) or ((DMX=GMX) and (DMY=GMY-1) and (GMD=2))
        or ((DMX=GMX) and (DMY=GMY+1) and (GMD=0)) or ((DMX=GMX+1) and (DMY=GMY) and (GMD=3)) or
        ((DMX=GMX-1) and (DMY=GMY) and (GMD=1))) then inc(SCORE);

      OLD_DIR:=DD;
      clearbuf;
      CHECKOUT;
      if MANFLAG=1 then begin MOVE_MAN(DD,1); dec(M); MANFLAG:=0; end;
      if GF then begin MOVE_GARDENER(GMD,1); dec(GARDENER_MOVE); GF:=FALSE; end;
      if NF then begin MOVE_NEIGHBOUR(NMD,1); dec(NEIGHBOUR_MOVE); NF:=FALSE; end;
      if MANFLAG=1 then begin MOVE_MAN(DD,1); dec(M); MANFLAG:=0; end;
      if DOGFLAG=1 then begin MOVE_DOG(DDIR,1); dec(DOG_MOVE); DOGFLAG:=0; end;
      MOVE_MAN(DD,3);
      MOVE_GARDENER(GMD,3);
      MOVE_NEIGHBOUR(NMD,3);
      MOVE_DOG(DDIR,3);
      UPDATE_PANEL;
      T2_vretrace;
      if CY<39 Then delay(5);
    UNTIL  (DROWNFLAG) or ((GNX=CX) and (GNY=CY))              or ((GARD) and (GMX=CX) and (GMY=CY))
      or ((GNX=CX) and (GNY=CY-1) and (DD=2)) or ((GARD) and (GMX=CX) and (GMY=CY-1) and (DD=2))
      or ((GNX=CX) and (GNY=CY+1) and (DD=0)) or ((GARD) and (GMX=CX) and (GMY=CY+1) and (DD=0))
      or ((GNX=CX+1) and (GNY=CY) and (DD=3)) or ((GARD) and (GMX=CX+1) and (GMY=CY) and (DD=3))
      or ((GNX=CX-1) and (GNY=CY) and (DD=1)) or ((GARD) and (GMX=CX-1) and (GMY=CY) and (DD=1))
      or (MBITS=GBITS);
    freemem(BACKP,6406);
    DELAY(1000);
    if MBITS=GBITS then begin
      if DOG_TOL>0 then repeat
        dec(DOG_TOL); inc(SCORE,LEVNO*2); UPDATE_PANEL;
        t2_vretrace;
      until DOG_TOL=0;
      if DOG_LOY>0 then repeat
        dec(DOG_LOY); inc(SCORE,LEVNO); UPDATE_PANEL;
        t2_vretrace;
      until DOG_LOY=0;
      delay(1000);
      t2_set_buf(1);
      inc(LEVNO); if LEVNO>MAX_LEVEL then begin LEVNO:=1; MAX_SPEED:=1; end;
      str(LEVNO,ST);
      ST:=LEV_dir+'LEVEL'+ST+'.TDA';
      MBITS:=0; loadlev(ST,true);
    end;
    T2_SET_BUF(1);
    P:=@TDAPAL;
    for L:=0 to 255 do begin
      R1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)];
      G1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
      B1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
    end;
    SCN:=0;
    if ((GNX=CX) and (GNY=CY)) or ((GNX=CX) and (GNY=CY-1) and (DD=2)) or
       ((GNX=CX) and (GNY=CY+1) and (DD=0)) or ((GNX=CX+1) and (GNY=CY) and (DD=3))
       or ((GNX=CX-1) and (GNY=CY) and (DD=1)) then begin P:=@DEADPAL; SCN:=2; end;

    if (GARD) and (((GMX=CX) and (GMY=CY)) or ((GMX=CX) and (GMY=CY-1) and (DD=2)) or
       ((GMX=CX) and (GMY=CY+1) and (DD=0)) or ((GMX=CX+1) and (GMY=CY) and (DD=3))
       or ((GMX=CX-1) and (GMY=CY) and (DD=1))) then begin P:=@SLICEDP; SCN:=3; end;
  
    if DROWNFLAG then begin SCN:=4; P:=@TDAPAL; end;
    for L:=0 to 255 do begin
      R2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)];
      G2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
      B2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
    end;

    if SCN>1 then begin
      t2_set_buf(1); t2_band(0,200,0);
      SCREEN_FLIP(1,false,true); t2_set_buf(0);
      t2_band(0,200,0);
      nopalette;
      for L:=0 to 255 do begin R1C[L]:=0; G1C[L]:=0; B1C[L]:=0; t2_setrgb(L,0,0,0); end;
      if SCN=2 then load_pcx(GFX_DIR+'DEAD.PCX')
      else if SCN=3 then load_pcx(GFX_DIR+'SLICED.PCX')
      else if SCN=4 then load_pcx(GFX_DIR+'DROWN.PCX');
      t2_copy(1,0,200);
      t2_set_buf(0); t2_band(0,200,0);
      SCREEN_FLIP(1,true,false);
      dec(LIVES);
      repeat 
        if keypressed then repeat until readkey<>''; 
      until not keypressed;
      repeat until readkey<>'';
      t2_set_buf(1);
      str(LEVNO,ST);
      ST:=LEV_DIR+'LEVEL'+ST+'.TDA';
      LOADLEV(ST,false);
      P:=@TDAPAL;
      for L:=0 to 255 do begin
        R1C[L]:=R2C[L]; G1C[L]:=G2C[L]; B1C[L]:=B2C[L];
        R2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)];
        G2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
        B2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
      end;
      if LIVES>0 then SCREEN_FLIP(1,true,false);
    end;
    if SCN=0 then SCREEN_FLIP(1,false,false);
  until LIVES=0;

  t2_set_buf(1);

  P:=@TDAPAL;
  for L:=0 to 255 do begin
    R2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)];
    G2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
    B2C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
  end;
  if SCN=2 then P:=@DEADPAL;
  if SCN=3 then P:=@SLICEDP;
  for L:=0 to 255 do begin
    R1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)];
    G1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
    B1C[L]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
  end;
  P:=@GMOVR;
  t2_putpic(77,58,P); screen_flip(1,true,false); delay(1000); t2_set_buf(1);
  t2_Band(0,200,0); screen_flip(1,true,false); t2_set_buf(0); t2_band(0,200,0);

  assign(F,'TABLE.HSC');
  reset(F);
  for L:=1 to 5 do begin
    readln(F,N[L]);
    readln(F,SCV[L]);
  end;
  if SCORE>SCV[5] then begin
    ST:='';
    t2_set_style(0,0,text_centre,0);
    t2_write(160,40,'NEW HISCORE - ENTER YOUR NAME',15);
    t2_set_style(0,0,0,0);
    for L:=40 to 50 do
      for L2:=40 to 255 do
        if t2_getdot(L2,L)=15 then t2_dot(L2,L,136+(L-40));
    L:=0;
    repeat
      ch:=readkey;
      if (ch=chr(8)) and (length(ST)>0) then ST:=copy(ST,1,length(ST)-1);
      if (ch>chr(31)) and (ch<chr(127)) and (length(ST)<5) then ST:=ST+CH;
      t2_block(0,96,320,20,0);
      t2_set_style(0,0,0,0);
      t2_vretrace;
      t2_write(130,98,ST,70);
      for L:=98 to 110 do
        for L2:=100 to 209 do
          if t2_getdot(L2,L)=70 then t2_dot(L2,L,40+(L-40));
    until ch=chr(13);
    L:=5;
    repeat
      dec(L);
    until (SCV[L]>SCORE) or (L=1);
    inc(L);
    if SCORE>SCV[1] then L:=1;
    if L<5 then begin
      for L2:=4 downto L do begin
        SCV[L2+1]:=SCV[L2];
        N[L2+1]:=N[L2];
      end;
    end;
    SCV[L]:=score;
    N[L]:=ST;
    assign(F,'TABLE.HSC');
    rewrite(F);
    for L:=1 to 5 do begin
      writeln(F,N[L]);
      writeln(F,SCV[L]);
    end;
    close(F);
  END;
  Shutsound;
  ShutInterrupt;
  Setupsound;
  {Jumpout;}
end;

function convup(s : string) : string;
var L : byte;
begin
  for L:=1 to length(s) do s[L]:=upcase(s[L]);
  convup:=s;
end;

procedure writeDefaultHi;
var F : text;
begin
  assign(F,'TABLE.HSC');
  rewrite(F);
  writeln(F,'Tom');
  writeln(F,'5000');
  writeln(F,'Wes');
  writeln(F,'2500');
  writeln(F,'Chris');
  writeln(F,'2000');
  writeln(F,'Andy');
  writeln(F,'1500');
  writeln(F,'Gladys');
  writeln(F,'1000');
  close(F);
end;

begin
  setupsound;
  LEVNO:=0;
  repeat
    inc(LEVNO);
    str(LEVNO,ST);
    ST:=LEV_DIR+'LEVEL'+ST+'.TDA';
    findfirst(ST,archive,dirinfo);
  until doserror<>0;



  MAX_LEVEL:=LEVNO-1;
  if MAX_LEVEL=0 then begin writeln('TDA - Error - No level data found. Need LEVELS/LEVEL1.TDA, etc.'); jumpout; end;

  findfirst('TABLE.HSC',Archive,DirInfo);
  if DosError<>0 then WriteDefaultHi;

  LEVNO:=1;
  LOYTOG:=0; ANITOG:=0; NEIGHBOUR_MOVE:=0; MAX_SPEED:=2; SPEED_TOGGLE:=0; GBITS:=0; OVERLOAD:=false;
  GSPEED_TOGGLE:=0; GARDENER_MOVE:=0; GMD:=8; NF:=FALSE; MANFLAG:=0; GF:=FALSE;
  TOLTOG:=0; MOWER_T:=0;
  DOG_TOL:=130; DOG_DIR:=0; DOG_MOVE:=0; KILLFLAG:=false; DOG_LOY:=130;
  MBITS:=0; LIVES:=3;
  t2_start(1);
  t2_set_buf(0);
  for L:=0 to 255 do t2_Setrgb(L,0,0,0);
  t2_band(0,200,0);

  With keydata do begin
    kleft:=false; kright:=false; kup:=false; kdown:=false;
    kESC:=false; KDEL:=false;
  end;
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keyclick));

  P:=@COSMIX;
  t2_user_font(P,1);
  t2_set_font(1);
  P:=@TDAPAL;
  for L:=0 to 255 do begin
    t2_Setrgb(L,mem[seg(P^):Ofs(P^)+(L*3)],mem[seg(P^):Ofs(P^)+(L*3)+1],mem[seg(P^):Ofs(P^)+(L*3)+2]);
  end;
  repeat
     TITLE;
    dogame;
  until false;
end.