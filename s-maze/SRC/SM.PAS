{$M 65520,0,655360}
program SM;
uses crt,dos,graph,load,sound,tdfonts,ts;
type
  keyrec=record
    kleft,kright,kup,kdown,kCTRL,kALT,kSHIFT,kQ,kR,kY,kZ,kESC,KS,Kdel,Space: boolean;
    end;
var
  card : DSMCard;
  samples : array[1..5] of PDSMInst;
  storepalette: array[0..15,1..3] of byte;
  MAZE : array[0..79,0..60] of byte;
  KbdIntVec : Procedure;
  keydata: Keyrec;
  MAP : array[0..79,0..60,1..2] of byte;
  cH : char;
  hr,m,sec,h,osec : word;
  PVAL,TIM,TSC,LSEC,EX,EY,CODE,XSPAN,L,YSPAN,FLAG,R,C,D,E,F,XL,YL,
  PLAYER,LB,B,SFX,OSFX,OPT,ROUND,TOGGLE,SN : byte;
  WIN,ESCAP,POWCH,POWCT,MOVEL,MOVER,MOVEU,MOVED : array[1..2] of byte;
  NAMEA,NAMEB,ST : string;
  ANGLE : real;
  anint,PS,OUT,NOTECOUNT,STARTNOTE,OCTAVE : integer;
  TOTAL,X,Y,OSC,SC : array[1..2] of integer;
  pPOWCHUNK,pCUBE,pCHUNK,pWCTSOFT,pSMTITLE  : pointer;
  pchap : array[1..2] of pointer;
  newTog : boolean;
  fxon : boolean;
const

  MUSIC : array[1..12] of integer
  = (262,277,294,311,330,350,367,392,415,440,466,494);
  TUNE : array[1..2,1..32] of byte
  = ((1,8,13,8,1,8,15,8,1,8,17,8,1,8,15,8,1,8,13,8,1,8,15,8,1,8,17,8,1,8,15,8),
     (1,1,13,1,11,1,16,1,13,1,8,1,6,8,6,4,1,1,16,1,18,1,23,1,20,1,1,6,8,6,4,1));
  {audiodir : string = '../AUDIO/';}
  audiodir : string = 'AUDIO/';

  CRUNCH : integer = 1;
  POWER : integer = 2;
  FLUSH : integer = 3;
  COMBUST : integer = 4;
  ESCAPE : integer = 5;

procedure StartInterrupt;
begin
  TSInit;
  TSSetRate(100);
  TSSetRoutine(DSMPoll);
end;

procedure ShutInterrupt;
begin
  TSDone;
  TSRestoreTime;
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
    Samples[COMBUST]:=DsmLoadSample(audiodir+'COMBUST.WAV',0);
    Samples[POWER]:=DsmLoadSample(audiodir+'POWER.WAV',0);
    Samples[CRUNCH]:=DsmLoadSample(audiodir+'CRUNCH.WAV',0);
    Samples[ESCAPE]:=DsmLoadSample(audiodir+'ESCAPE.WAV',0);
    Samples[FLUSH]:=DsmLoadSample(audiodir+'FLUSH.WAV',0);
    DSMSetupVoices(4,192);
  end;
  fxon:=true;
  StartInterrupt;
end;

procedure ShutSoundFx;
  var L : byte;
begin
  shutinterrupt;
  if fxon then begin
    for L:=1 to 5 do DSmFreeSample(Samples[L]);
    dsmdone;
  end;
  fxon:=false;

end;

procedure SETRGB(NR,R,G,B: byte);
begin
  Port[$3c8]:=Nr;
  Port[$3c9]:=R;
  Port[$3c9]:=G;
  Port[$3c9]:=B;
end;

Procedure SPLAY(n : byte; chan : byte; FREQ : integer);
begin
  DSMSetPeriod(chan,trunc(8363*428/Freq));
  DSMPlaySample(chan, samples[n]);
end;

procedure playcols;
begin
  repeat
    storepalette[13,1]:=trunc(random(2))*30;
    storepalette[13,2]:=trunc(random(2))*30;
    storepalette[13,3]:=trunc(random(2))*30;
    storepalette[9,1]:=trunc(random(2)*24);
    storepalette[9,2]:=trunc(random(2)*24);
    storepalette[9,3]:=trunc(random(2)*24);
    storepalette[1,1]:=storepalette[9,1] div 2;
    storepalette[1,2]:=storepalette[9,2] div 2;
    storepalette[1,3]:=storepalette[9,3] div 2;
  until (storepalette[13,1]+storepalette[13,2]+storepalette[13,3]>0) and
    not ((storepalette[13,1]+storepalette[13,2]=0) and (storepalette[13,3]>0)) and
    not (storepalette[1,1]+storepalette[1,2]+storepalette[1,3]=0);
  for lb:=0 to 15 do setrgb(lb,storepalette[lb,1],storepalette[lb,2],storepalette[lb,3]);
end;

procedure defaultpal;
begin
  storepalette[0,1]:=$00; storepalette[0,2]:=$00; storepalette[0,3]:=$00;
  storepalette[1,1]:=$00; storepalette[1,2]:=$00; storepalette[1,3]:=$FC;
  storepalette[2,1]:=$24; storepalette[2,2]:=$FC; storepalette[2,3]:=$24;
  storepalette[3,1]:=$00; storepalette[3,2]:=$FC; storepalette[3,3]:=$FC;
  storepalette[4,1]:=$FC; storepalette[4,2]:=$14; storepalette[4,3]:=$14;
  storepalette[5,1]:=$B0; storepalette[5,2]:=$00; storepalette[5,3]:=$FC;
  storepalette[6,1]:=$70; storepalette[6,2]:=$48; storepalette[6,3]:=$00;
  storepalette[7,1]:=$C4; storepalette[7,2]:=$C4; storepalette[7,3]:=$C4;
  storepalette[8,1]:=$34; storepalette[8,2]:=$34; storepalette[8,3]:=$34;
  storepalette[9,1]:=$00; storepalette[9,2]:=$00; storepalette[9,3]:=$70;
  storepalette[10,1]:=$00; storepalette[10,2]:=$70; storepalette[10,3]:=$00;
  storepalette[11,1]:=$00; storepalette[11,2]:=$70; storepalette[11,3]:=$70;
  storepalette[12,1]:=$70; storepalette[12,2]:=$00; storepalette[12,3]:=$00;
  storepalette[13,1]:=$FC; storepalette[13,2]:=$FC; storepalette[13,3]:=$00;
  storepalette[14,1]:=$FC; storepalette[14,2]:=$FC; storepalette[14,3]:=$24;
  storepalette[15,1]:=$FC; storepalette[15,2]:=$FC; storepalette[15,3]:=$FC;
end;

procedure JUMPOUT;
  var i : byte;
begin
  nosound;
  shutSoundFx;
  SetIntVec($9,@KbdIntVec);
  cleardevice;
  closegraph;
  TextMode(CO80);
  ClrScr;
  halt;
end;

procedure CLEARBUF;
begin
  inline($fa);
  memw[$40:$1A]:=memw[$40:$1C];
  inline($fb);
end;

function NAMEIN : string;
begin
  ST:='';
  repeat
    ch:=readkey;
    if (ch<>chr(8)) and (ch<>chr(13)) and (length(ST)<8) then begin
      bar(0,320,639,360);
      ST:=ST+CH;
      outtextxy(320,330,ST);
    end;
    if (ch=chr(8)) and (length(ST)>0) then begin
      ST:=copy(ST,1,length(ST)-1);
      bar(0,320,639,360);
      outtextxy(320,330,ST);
    end;
  until (ch=chr(13)) and (ST<>'');;
  NAMEIN:=ST;
end;

Procedure vwait; assembler;
asm
  @@loop1:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    jz      @@loop3  {Not in retrace}

  @@loop2:
    mov     dx,$3da  {Retrace already started- wait for next}
    in      ax,dx
    and     ax,8
    jnz     @@loop2

  @@loop3:          {Wait until retrace}
    mov     dx,$3da
    in      ax,dx
    and     ax,8

    jz      @@loop3
end;

procedure FIREWORK(ST : string);
var
    S,L,LL : byte;
    XPOS,YPOS,XTRAG,YTRAG : array[1..8] of real;
    XC,YC : array[1..16,1..8] of real;
    OCX,OCY : array[1..16,0..1,1..8] of real;
    XT,YT : array[1..16,1..8] of real;

    OXPOS,OYPOS : array[0..1,1..8] of real;
    FALL : array[1..8] of real;
    DELa,CR,MODE : array[1..8] of byte;

begin
  OUT:=1;
  SetGraphMode(vgamed);
  cleardevice;
  settextjustify(centertext,toptext);
  settextstyle(9,0,2);
  setcolor(14);
  setactivepage(0);
  outtextxy(320,5,ST);
  setactivepage(1);
  outtextxy(320,5,ST);
  nosound;
  delay(700);
  clearbuf;
  randomize;
  for L:=1 to 15 do setpalette(L,L);
  setrgb(1,63,0,0); setrgb(2,63,63,0);
  setrgb(3,0,63,0); setrgb(4,63,63,63);
  setrgb(5,0,63,63); setrgb(6,0,0,63);
  setrgb(7,63,0,63); setrgb(8,0,63,63);
  for LL:=1 to 8 do begin
    CR[LL]:=63;
    XPOS[LL]:=random(320)+160;
    XTRAG[Ll]:=random(4)-2;
    YPOS[LL]:=350;
    FALL[LL]:=(random(10)/100)+0.85;
    YTRAG[LL]:=random(14)+6 ;
    OXPOS[0,LL]:=XPOS[LL]; OYPOS[0,LL]:=YPOS[LL];
    OXPOS[1,LL]:=XPOS[LL]; OYPOS[1,LL]:=YPOS[LL];
  end;
  S:=0;
  setpalette(12,12);
  setrgb(12,0,63,63);
  for LL:=1 to 8 do begin MODE[LL]:=4; dela[LL]:=random(230); end;
  repeat
    S:=1-S;
    setactivepage(S);
    vwait;
    setvisualpage(1-S);
    for LL:=1 to 8 do begin
      if MODE[LL]=0 then begin
        if (oxpos[s,ll]>0) and (oxpos[s,ll]<639) and (oypos[s,ll]>0) and (oypos[s,ll]<350) then
          putpixel(trunc(OXPOS[S,LL]),trunc(OYPOS[S,LL]),0);
        if (xpos[ll]>0) and (xpos[ll]<639) and (ypos[ll]>0) and (ypos[ll]<350) then
          putpixel(trunc(XPOS[LL]),trunc(YPOS[LL]),LL);
        OXPOS[S,LL]:=XPOS[LL];
        OYPOS[S,LL]:=YPOS[LL];
        XPOS[LL]:=XPOS[LL]+XTRAG[LL];
        YPOS[LL]:=YPOS[LL]-YTRAG[LL];
        YTRAG[LL]:=YTRAG[LL]*FALL[LL];
        if trunc(YTRAG[LL])=0 then begin
          MODE[LL]:=1;
          setactivepage(0);
          if (oxpos[0,ll]>0) and (oxpos[0,ll]<639) and (oypos[0,ll]>0) and (oypos[0,ll]<350) then
            putpixel(trunc(OXPOS[0,LL]),trunc(OYPOS[0,LL]),0);
          setactivepage(1);
          if (oxpos[1,ll]>0) and (oxpos[1,ll]<639) and (oypos[1,ll]>0) and (oypos[1,ll]<350) then
            putpixel(trunc(OXPOS[1,LL]),trunc(OYPOS[1,LL]),0);
          setactivepage(S);
        end;
      end;
      if MODE[LL]=1 then begin
        for L:=1 to 16 do begin
          XT[L,LL]:=(2*sin((L/16)*6.28));
          YT[L,LL]:=(2*cos((L/16)*6.28));
          XC[L,LL]:=trunc(XPOS[LL]);
          YC[L,LL]:=trunc(YPOS[LL]);
          OCX[L,0,LL]:=XPOS[LL]; OCX[L,1,LL]:=XPOS[LL];
          OCY[L,0,LL]:=YPOS[LL]; OCY[L,1,LL]:=YPOS[LL];
        end;
        MODE[LL]:=2;
        if sfx=1 then begin
          crt.sound(10);
          SPLAY(COMBUST,2,24000);
          nosound;
        end;
      end;
      if MODE[LL]=2 then begin
        for L:=1 to 16 do
          if (ocx[l,s,ll]>0) and (ocx[l,s,ll]<639) and (ocy[l,s,ll]>0) and (ocy[l,s,ll]<350) then
            putpixel(trunc(OCX[L,S,LL]),trunc(OCY[L,S,LL]),0);
        for L:=1 to 16 do begin
          XC[L,LL]:=XC[L,LL]+(XT[L,LL]);
          YC[L,LL]:=YC[L,LL]+(YT[L,LL]);
          YT[L,LL]:=YT[L,LL]+(FALL[LL]/20);
          OCX[L,S,LL]:=XC[L,LL];
          OCY[L,S,LL]:=YC[L,LL];
          if (Xc[L,LL]>0) and (XC[L,LL]<639) and (Yc[L,LL]>0) and (Yc[L,LL]<350) then
            putpixel(trunc(XC[L,LL]),trunc(YC[L,LL]),LL);
        end;
        if S=0 then dec(CR[LL]);
        if LL=1 then setrgb(LL,CR[LL],0,0)
        else if LL=2 then setrgb(LL,CR[LL],CR[LL],0)
        else if LL=3 then setrgb(LL,0,CR[LL],0)
        else if LL=4 then setrgb(LL,CR[LL],CR[LL],CR[LL])
        else if LL=5 then setrgb(LL,0,CR[LL],CR[LL])
        else if LL=6 then setrgb(LL,0,0,CR[LL])
        else if LL=7 then setrgb(LL,CR[LL],0,CR[LL])
        else if LL=8 then setrgb(LL,CR[LL],CR[LL],CR[LL]);
        if CR[LL]=0 then begin
          setactivepage(0);
          for L:=1 to 16 do
            if (ocx[l,0,ll]>0) and (ocx[l,0,ll]<639) and (ocy[l,0,ll]>0) and (ocy[l,0,ll]<350) then
              putpixel(trunc(OCX[L,0,LL]),trunc(OCY[L,0,LL]),0);
          setactivepage(1);
          for L:=1 to 16 do
            if (ocx[l,1,ll]>0) and (ocx[l,1,ll]<639) and (ocy[l,1,ll]>0) and (ocy[l,1,ll]<350) then
              putpixel(trunc(OCX[L,1,LL]),trunc(OCY[L,1,LL]),0);

          setactivepage(S);
          CR[LL]:=63;
          if LL=1 then setrgb(LL,CR[LL],0,0)
          else if LL=2 then setrgb(LL,CR[LL],CR[LL],0)
          else if LL=3 then setrgb(LL,0,CR[LL],0)
          else if LL=4 then setrgb(LL,CR[LL],CR[LL],CR[LL])
          else if LL=5 then setrgb(LL,0,CR[LL],CR[LL])
          else if LL=6 then setrgb(LL,0,0,CR[LL])
          else if LL=7 then setrgb(LL,CR[LL],0,CR[LL])
          else if LL=8 then setrgb(LL,CR[LL],CR[LL],CR[LL]);
          MODE[LL]:=4;
          dela[LL]:=random(20);
          XPOS[LL]:=random(320)+160;
          XTRAG[Ll]:=random(4)-2;
          YPOS[LL]:=350;
          FALL[LL]:=(random(10)/100)+0.85;
          YTRAG[LL]:=random(2)+14 ;
          OXPOS[0,LL]:=XPOS[LL]; OYPOS[0,LL]:=YPOS[LL];
          OXPOS[1,LL]:=XPOS[LL]; OYPOS[1,LL]:=YPOS[LL];
        end;
      end;
      if MODE[LL]=4 then begin
        dec(dela[LL]);
        if dela[LL]=0 then MODE[LL]:=0;
      end;
    end;
  until keypressed;
end;

{F+}
procedure Keyclick; interrupt;
var v : boolean;
begin
  Pval:=Port[$60];
  v:=(PVal<$80);
  if (PVal>=$80) then Dec(PVal,$80);

  if Pval=$1D then keydata.kCTRL:=v
  else if Pval=$60 then keydata.kCTRL:=v
  else if Pval=$38 then keydata.kALT:=v
  else if Pval=$2A then keydata.kSHIFT:=v
  else if Pval=$36 then keydata.kSHIFT:=v
  else if Pval=$48 then keydata.kUP:=v
  else if Pval=$50 then keydata.kDOWN:=v
  else if Pval=$4B then keydata.kLEFT:=v
  else if Pval=$4D then keydata.kRIGHT:=v
  else if Pval=16 then keydata.kQ:=v
  else if Pval=19 then keydata.kR:=v
  else if Pval=21 then keydata.kY:=v
  else if Pval=44 then keydata.kZ:=v
  else if Pval=1 then keydata.KESC:=v
  else if Pval=31 then keydata.KS:=v
  else if Pval=83 then keydata.KDEL:=v
  else if Pval=57 then keydata.SPACE:=v;
  inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  KbdIntVec;
  

end;
{$F-}

Procedure SET_TIMER;
begin
  gettime(hr,m,sec,h);
  LSEC:=SEC+1;
end;

Procedure DISP_TIME;
  var S1,S2 : string;
begin
  setfillstyle(1,black);
  bar(0,0,70,20);
  settextstyle(smallfont,0,6);
  setcolor(White);
  str(TIM,S1);
  str(TSC,S2);
  if TSC<10 then S2:='0'+S2;
  S1:=S1+' : '+S2;
  settextjustify(lefttext,toptext);
  outtextxy(2,2,S1);
  setcolor(black);
end;

Procedure DISP_SCORE(PLAYER : byte);
  var S : string;
begin
  setfillstyle(1,black);
  if PLAYER=1 then begin
    bar(80,0,130,20);
    settextstyle(smallfont,0,6);
    setcolor(yellow);
    str(SC[PLAYER],S);
    outtextxy(82,2,S);
    setcolor(black);
  end else if PLAYER=2 then begin
    bar(400,0,450,20);
    settextstyle(smallfont,0,6);
    setcolor(lightcyan);
    str(SC[PLAYER],S);
    outtextxy(402,2,S);
    setcolor(black);
  end;
end;

Procedure PICKUP(PLAYER : byte);
begin
  If MAP[X[PLAYER],Y[PLAYER],PLAYER]=0 then begin
    MAP[X[PLAYER],Y[PLAYER],PLAYER]:=2;
    if OPT>=2 then MAP[X[PLAYER],Y[PLAYER],PLAYER]:=3;
    SC[PLAYER]:=SC[PLAYER]+1;
    if SFX=1 then SPLAY(CRUNCH,0,24000);
    if POWCH[PLAYER]=1 then begin
      INC(SC[PLAYER]);
      dec(POWCT[PLAYER]);
    end;
    if POWCT[PLAYER]=0 then POWCH[PLAYER]:=0;

  end else if MAP[X[PLAYER],Y[PLAYER],PLAYER]=1 then begin
    MAP[X[PLAYER],Y[PLAYER],PLAYER]:=2;
    if OPT>=2 then MAP[X[PLAYER],Y[PLAYER],PLAYER]:=3;
    SC[PLAYER]:=SC[PLAYER]+10;
    POWCT[PLAYER]:=50;
    POWCH[PLAYER]:=1;
    if SFX=1 then SPLAY(POWER,1,12000);
  end;
end;

Procedure NOTES1(TUNUM : integer);
begin
  if OCTAVE<>0 then crt.sound(MUSIC[OUT]*OCTAVE);
  inc(NOTECOUNT);
  OCTAVE:=1;
  OUT:=TUNE[TUNUM,NOTECOUNT]+STARTNOTE;
  repeat
    if OUT>12 then begin
      dec(OUT,12);
      OCTAVE:=2*OCTAVE;
    end;
  until OUT<=12;
  if (NOTECOUNT=2) and (TUNUM=2) then playcols;
  if NOTECOUNT=32 then begin
    NOTECOUNT:=0;
    inc(STARTNOTE);
  end;
end;

Procedure CUBE; external; {$L CUBE.OBJ}
Procedure POWCHUNK ; external; {$L POWCHUNK.OBJ}
Procedure CHAP; external; {$L CHAP.OBJ}
Procedure CHAP2; external; {$L CHAP2.OBJ}
Procedure CHUNK; external; {$L CHUNK.OBJ}
Procedure WCTSOFT; external; {$L WCTSOFT.OBJ}
Procedure SMTITLE; external; {$L SMTITLE.OBJ}

procedure GETRGB(NR: byte; Var R,G,B :byte);
begin
  Port[$3c7]:=Nr;
  r:=Port[$3c9];
  g:=Port[$3c9];
  b:=Port[$3c9];
end;

procedure dMAZE(XSPAN,YSPAN,PLAYERS : byte);
begin
  FLAG:=0;
  R:=0;
  C:=0;
  D:=0;
  E:=0;
  F:=0;
  XL:=0;
  YL:=0;
  randomize;
  for XL:=0 to XSPAN do for YL:=0 to YSPAN do begin
    MAZE[XL,YL]:=0;
    MAP[XL,YL,1]:=3;
    MAP[XL,YL,2]:=3;
  end;

  for XL:=0 to XSPAN do begin
    MAZE[XL,1]:=2; MAZE[XL,2]:=2; MAZE[XL,YSPAN-1]:=2; MAZE[XL,YSPAN]:=2;
    MAP[XL,1,1]:=3; MAP[XL,2,1]:=3; MAP[XL,YSPAN-1,1]:=3; MAP[XL,YSPAN,1]:=3;
    MAP[XL,1,2]:=3; MAP[XL,2,2]:=3; MAP[XL,YSPAN-1,2]:=3; MAP[XL,YSPAN,2]:=3;
  end;

  for YL:=2 to YSPAN-2 do begin
    MAZE[0,YL]:=2; MAZE[1,YL]:=2; MAZE[XSPAN-1,YL]:=2; MAZE[XSPAN,YL]:=2;
  end;

  for XL:=0 to XSPAN do for YL:=1 to YSPAN do begin
    putimage(XL*8,YL*8,pCUBE^,normalput);
    if PLAYERS=2 then putimage(320+(XL*8),YL*8,pCUBE^,normalput);
  end;

  YL:=4+(2*random(trunc(YSPAN/3)));
  Y[1]:=YL;
  X[1]:=0;
  Y[2]:=YL;
  X[2]:=0;
  setfillstyle(1,0);
  for XL:=0 to 4 do begin
    putimage(XL*8,YL*8,pCHUNK^,normalput);
    if PLAYERS=2 then putimage(320+(XL*8),YL*8,pCHUNK^,normalput);
    MAP[XL,YL,1]:=0;
    MAP[XL,YL,2]:=0;
  end;

  MAZE[XL,YL]:=2;
  repeat
    if not ((MAZE[XL+2,YL]<>0) and (MAZE[XL-2,YL]<>0) and (MAZE[XL,YL+2]<>0) and (MAZE[XL,YL-2]<>0)) then begin
      repeat
        putimage(XL*8,YL*8,pCHUNK^,normalput);
        if PLAYERS=2 then putimage(320+(XL*8),YL*8,pCHUNK^,normalput);
        MAP[XL,YL,1]:=0;
        MAP[XL,YL,2]:=0;
        R:=random(4);
        if R=0 then C:=XL+2;
        if R=1 then C:=XL-2;
        if R>1 then C:=XL;
        if R=2 then D:=YL+2;
        if R=3 then D:=YL-2;
        if R<2 then D:=YL;
      until MAZE[C,D]=0;
      E:=trunc((C+XL)/2);
      F:=trunc((D+YL)/2);
      MAZE[C,D]:=1; MAZE[E,F]:=1;
      putimage(E*8,F*8,pCHUNK^,normalput);
      if PLAYERS=2 then putimage(320+(E*8),F*8,pCHUNK^,normalput);
      MAP[E,F,1]:=0;
      MAP[E,F,2]:=0;
      XL:=C; YL:=D;

    end else begin
      MAZE[XL,YL]:=2;
      putimage(XL*8,YL*8,pCHUNK^,normalput);
      if PLAYERS=2 then putimage(320+(XL*8),YL*8,pCHUNK^,normalput);
      MAP[XL,YL,1]:=0;
      MAP[XL,YL,2]:=0;
      FLAG:=0;
      if (FLAG=0) and (MAZE[XL+1,YL]=1) then begin MAZE[XL+1,YL]:=2; inc(XL,2); FLAG:=1; end;
      if (FLAG=0) and (MAZE[XL-1,YL]=1) then begin MAZE[XL-1,YL]:=2; dec(XL,2); FLAG:=1; end;
      if (FLAG=0) and (MAZE[XL,YL+1]=1) then begin MAZE[XL,YL+1]:=2; inc(YL,2); FLAG:=1; end;
      if (FLAG=0) and (MAZE[XL,YL-1]=1) then begin MAZE[XL,YL-1]:=2; dec(YL,2); FLAG:=1; end;
      if FLAG=0 then begin
        YL:=4+(2*random(trunc(YSPAN/3)));
        EX:=XSPAN-2;
        EY:=YL;
        for XL:=XSPAN-2 to XSPAN do begin
          setfillstyle(1,0);
          putimage(XL*8,YL*8,pCHUNK^,normalput);
          if PLAYERS=2 then putimage(320+(XL*8),YL*8,pCHUNK^,normalput);
          MAP[XL,YL,1]:=0;
          MAP[XL,YL,2]:=0;
          FLAG:=2;
        end;
      end;
    end;
  until FLAG=2;
  for L:=1 to TRUNC((XSPAN/16)+(YSPAN/16)) do begin
    repeat
      XL:=random(XSpAN-2)+1;
      YL:=random(YSpAN-2)+1;
    until MAP[XL,YL,1]=0;
    MAP[XL,YL,1]:=1;
    MAP[XL,YL,2]:=1;
    putimage(XL*8,(YL*8),pPOWCHUNK^,normalput);
    if PLAYERS=2 then putimage(320+(XL*8),(YL*8),pPOWCHUNK^,normalput);
  end;
end;


begin
  fxon:=false;
  egavga;
  font6;
  font2;
  font9;
  font1;
  setupSoundFx;

  pCUBE:=@CUBE; pSMTITLE:=@SMTITLE; pCHUNK:=@CHUNK; pPOWCHUNK:=@POWCHUNK;
  SFX:=1;
  PCHAP[1]:=@CHAP; pCHAP[2]:=@CHAP2; pWCTSOFT:=@WCTSOFT;
  With keydata do begin
    kleft:=false; kright:=false; kup:=false; kdown:=false;
    kSHIFT:=false; kALT:=false; kCTRL:=false; kY:=false; kQ:=false;
    kR:=false; kZ:=false; kESC:=false; KS:=false; KDEL:=false;
  end;
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keyclick));
  initVGA(vgahi);

  repeat
    for L:=1 to 2 do begin
      ESCAP[L]:=0; POWCH[L]:=0; POWCT[L]:=0; SC[L]:=0; OSC[L]:=1;
      TOTAL[L]:=0; WIN[L]:=0; MOVER[l]:=0; MOVEL[L]:=0; MOVED[L]:=0; MOVEU[L]:=0;
    end;
    ROUND:=1; OPT:=1; PS:=0; CLEARBUF;
    STARTNOTE:=0; NOTECOUNT:=0; OCTAVE:=0;
    PLAYER:=1;
    TOGGLE:=0;

    while keypressed do ch:=readkey;
    cleardevice;
    for L:=0 to 15 do setpalette(L,L);
    putimage(68,128,pSMTITLE^,normalput);
    settextstyle(6,0,5);
    setcolor(5);
    settextjustify(centertext,centertext);
    outtextxy(320,300,'HAPPY BIRTHDAY MARK!');
    setcolor(6);
    settextstyle(6,0,3);
    outtextxy(320,350,'15.04.82 - 15.04.96');
    angle:=0;
    repeat
      for L:=1 to 5 do setrgb(L,random(10),random(30),30+(L*6));
      for L:=8 to 13 do setrgb(L,63,40+((L-7)*4),0);
      setrgb(6,32,32,32);
      setrgb(14,63,63,32);
      putimage(248+TRUNC(20*sin(2*ANGLE)),trunc(48+20*(sin(ANGLE))),pWCTSOFT^,normalput);
      ANGLE:=ANGLE+0.0657;
      if ANGLE>(2*PI) then ANGLE:=ANGLE-(2*PI);
      vwait;
    until keypressed;

    ch:=readkey;
    clearbuf;
    if ch=chr(27) then JUMPOUT;
    cleardevice;
    settextjustify(centertext,centertext);
    settextstyle(9,0,2);
    putimage(68,20,pSMTITLE^,normalput);
    setcolor(lightgray);
    outtextxy(320,150,'Select Your Game');
    repeat
      setcolor(green);
      if OPT=1 then setcolor(lightgreen);
      outtextxy(320,240,'Two player Duel');
      setcolor(green);
      if OPT=2 then setcolor(lightgreen);
      outtextxy(320,280,'Tricky Smudge');
      setcolor(green);
      if OPT=3 then setcolor(lightgreen);
      outtextxy(320,320,'Smudging Duel');
      setcolor(green);
      if OPT=4 then setcolor(lightgreen);
      outtextxy(320,360,'ULTIMATE SMIDGE');
      if SFX<>OSFX then begin
        setcolor(black);
        outtextxy(320,400,'Sound Effects : ON');
        outtextxy(320,400,'Sound Effects : OFF');
      end;
      OSFX:=SFX;
      setcolor(green);
      if OPT=5 then setcolor(lightgreen);
      if SFX=1 then Outtextxy(320,400,'Sound Effects : ON')
      else if SFX=0 then Outtextxy(320,400,'Sound Effects : OFF');
      setcolor(Yellow);
      repeat
        if keypressed then repeat until readkey<>'';
      until not keypressed;
      repeat until keypressed;
      ch:=readkey;
      if keypressed then ch:=readkey;
      if ch=chr(27) then JUMPOUT;
      if (ch=chr(72)) and (OPT>1) then dec(OPT);
      if (ch=chr(80)) and (OPT<5) then inc(OPT);
      if (ch=chr(13)) and (OPT=5) then begin SFX:=1-SFX; ch:=chr(0); end;
    until ch=chr(13);
    SetGraphMode(vgahi);
    setfillstyle(10,darkgray);
    bar(0,0,639,200); setcolor(White); rectangle(0,0,639,200);
    settextstyle(6,0,3); settextjustify(centertext,centertext);

    if OPT=1 then begin
      setcolor(lightcyan); outtextxy(320,20,'The standard smudgelet maze. Three rounds of');
      setcolor(lightgreen); Outtextxy(320,50,'growing mazes - just keep scoring. Watch for');
      setcolor(yellow); outtextxy(320,80,'powerchunks, which give 10 points, and 2 per');
      setcolor(lightred); outtextxy(320,110,'standard chunk for the next 50. 2 Points per');
      setcolor(lightmagenta); outtextxy(320,140,'remaining second if you escape, NO SCORE if not!');

    end else if (OPT=2) or (OPT=3) then begin
      setcolor(lightcyan); outtextxy(320,20,'A bit more tricky! Your smidgelet has got rather');
      setcolor(lightgreen); outtextxy(320,50,'peckish, and this has resulted in some form of');
      setcolor(yellow); outtextxy(320,80,'schizo-psycho-induced paralysis syndrome. He simply');
      setcolor(lightred); outtextxy(320,110,'refuses to move onto a square without some food');
      setcolor(lightmagenta); outtextxy(320,140,'chunk on it. SHAME!');

    end else if OPT=4 then begin
      setcolor(lightcyan); outtextxy(320,20,'This is the big one! A full screen maze for you');
      setcolor(lightgreen); outtextxy(320,50,'get through, in two minutes. Smidgelet is still');
      setcolor(yellow); outtextxy(320,80,'vulnerable to hunger-driven paralysis, so you really');
      setcolor(lightred); outtextxy(320,110,'will have to be a very careful smidgeman to');
      setcolor(lightmagenta); outtextxy(320,140,'win this one! Good luck!');
    end;

    setcolor(lightcyan);
    settextstyle(9,0,1);
    outtextxy(320,230,'PLAYER ONE'); setcolor(lightgray);
    settextstyle(Triplexfont,0,2); outtextxy(320,260,'Controls : Q,Z,R,Y..directions  S..self-combust');
    settextstyle(9,0,1); setcolor(lightgreen); outtextxy(320,290,'SIGN ON, SMIDGELET');
    setfillstyle(1,black); settextstyle(6,0,4); setcolor(lightred);
    NAMEA:=NAMEIN;

    if (OPT=1) or (OPT=3) then begin
      setfillstyle(1,black);
      bar(0,210,639,479);
      settextstyle(9,0,1);
      outtextxy(320,230,'PLAYER TWO'); setcolor(lightgray);
      settextstyle(Triplexfont,0,2); outtextxy(320,260,'Controls : Cursor keys..directions  DEL..self-combust');
      settextstyle(9,0,1); setcolor(lightgreen); outtextxy(320,290,'SIGN ON, SMIDGELET');
      setfillstyle(1,black); settextstyle(6,0,4); setcolor(lightred);
      NAMEB:=NAMEIN;
    end;

    repeat
      SetGraphMode(vgahi);
      settextstyle(6,0,2);
      XSPAN:=37;
      YSPAN:=25+(10*(ROUND-1));
      PS:=1;
      if (OPT=3) or (OPT=1) then PS:=2
      else if OPT=4 then begin XSPAN:=79; YSPAN:=60; end;
      for L:=0 to 15 do begin setpalette(l,l); setrgb(l,0,0,0); end;
      dmaze(XSPAN,YSPAN,PS);
      defaultpal;
      playcols;

      for PLAYER:=1 to PS do PUTIMAGE(X[PLAYER]*8+((PLAYER-1)*320),(Y[PLAYER]*8),pCHAP[PLAYER]^,normalput);
      setcolor(black);
      SET_TIMER;
      if OPT=4 then begin TIM:=2; TSC:=0; end
      else if OPT<4 then begin TIM:=1; TSC:=30; end;
      repeat
        for PLAYER:=1 to PS do begin

          if MOVER[PLAYER]>0 then begin
            line((X[PLAYER]*8)+(8-MOVER[PLAYER])+((PLAYER-1)*320),
              (Y[PLAYER]*8),(X[PLAYER]*8)+(8-MOVER[PLAYER])+((PLAYER-1)*320),(Y[PLAYER]*8)+7);
            dec(MOVER[PLAYER]);
            putimage((X[PLAYER]*8)+((PLAYER-1)*320)+(8-MOVER[PLAYER]),(Y[PLAYER]*8),pCHAP[PLAYER]^,normalput);
            if MOVER[PLAYER]=0 then begin PICKUP(PLAYER); inc(X[PLAYER]); end;
          end;

          if MOVEL[PLAYER]>0 then begin
            line((7+(X[PLAYER]*8))-(8-MOVEL[PLAYER])+((PLAYER-1)*320),(Y[PLAYER]*8),
              (7+(X[PLAYER]*8))-(8-MOVEL[PLAYER])+((PLAYER-1)*320),(Y[PLAYER]*8)+7);
            dec(MOVEL[PLAYER]);
            putimage((X[PLAYER]*8)-(8-MOVEL[PLAYER])+((PLAYER-1)*320),(Y[PLAYER]*8),pCHAP[PLAYER]^,normalput);
            if MOVEL[PLAYER]=0 then begin PICKUP(PLAYER); dec(X[PLAYER]); end;
          end;

          if MOVED[PLAYER]>0 then begin
            line((X[PLAYER]*8)+((PLAYER-1)*320),(Y[PLAYER]*8)+(8-MOVED[PLAYER]),(X[PLAYER]*8)+7+((PLAYER-1)*320)
              ,(Y[PLAYER]*8)+(8-MOVED[PLAYER]));
            dec(MOVED[PLAYER]);
            putimage((X[PLAYER]*8)+((PLAYER-1)*320),(Y[PLAYER]*8)+(8-MOVED[PLAYER]),pCHAP[PLAYER]^,normalput);
            if MOVED[PLAYER]=0 then begin PICKUP(PLAYER); inc(Y[PLAYER]); end;
          end;

          if MOVEU[PLAYER]>0 then begin
            line((X[PLAYER]*8)+((PLAYER-1)*320),((Y[PLAYER]*8)+7)-(8-MOVEU[PLAYER]),(X[PLAYER]*8)+7+((PLAYER-1)*320)
              ,((y[PLAYER]*8)+7)-(8-MOVEU[PLAYER]));
            dec(MOVEU[PLAYER]);
            putimage((X[PLAYER]*8)+((PLAYER-1)*320),(Y[PLAYER]*8)-(8-MOVEU[PLAYER]),pCHAP[PLAYER]^,normalput);
            line((X[PLAYER]*8)+((PLAYER-1)*320),((Y[PLAYER]*8)+8)-(8-MOVEU[PLAYER]),(X[PLAYER]*8)+7+((PLAYER-1)*320)
              ,((y[PLAYER]*8)+8)-(8-MOVEU[PLAYER]));

            if MOVEU[PLAYER]=0 then begin PICKUP(PLAYER); dec(Y[PLAYER]); end;
          end;

          gettime(hr,m,sEC,h);
          if (h div 10<>b) and (SFX=1) then begin
            nosound;
            NewTog:=not NewTog;
            if NewTog then begin
              if OPT=4 then NOTES1(2);
              if OPT<4 then NOTES1(1);
            end;
            B:=(h div 10);
          end;

          if sec<>lsec then begin
            LSEC:=SEC;
            IF TSC>0 then begin dec(TSC) end
            else begin TSC:=59; dec(TIM); end;
            DISP_TIME;
          end;

          if SC[PLAYER]<>OSC[PLAYER] then DISP_SCORE(PLAYER);
          OSC[PLAYER]:=SC[PLAYER];

          if (MOVEU[PLAYER]+MOVED[PLAYER]+MOVEL[PLAYER]+MOVER[PLAYER]=0) then begin
            if KEYDATA.SPACE then playcols;
            if ESCAP[1]=0 then begin
              if KEYDATA.KY and (MAP[X[1]+1,Y[1],1]<3) and (MOVEL[1]+MOVEU[1]+MOVED[1]+MOVER[1]=0) then MOVER[1]:=8;
              if KEYDATA.KR and (MAP[X[1]-1,Y[1],1]<3) and (MOVER[1]+MOVEU[1]+MOVED[1]+MOVEL[1]=0)
                            and (X[1]>1) then MOVEL[1]:=8;
              if KEYDATA.KQ and (MAP[X[1],Y[1]-1,1]<3) and (MOVEL[1]+MOVER[1]+MOVED[1]+MOVEU[1]=0) then MOVEU[1]:=8;
              if KEYDATA.KZ and (MAP[X[1],Y[1]+1,1]<3) and (MOVEL[1]+MOVER[1]+MOVEU[1]+MOVED[1]=0) then MOVED[1]:=8;
            end;

            if (PS=2) and (ESCAP[2]=0) then begin
              if KEYDATA.Kright and (MAP[X[2]+1,Y[2],2]<3) and (MOVEL[2]+MOVEU[2]+MOVED[2]+MOVER[2]=0) then MOVER[2]:=8;
              if KEYDATA.Kleft and (MAP[X[2]-1,Y[2],2]<3) and (MOVER[2]+MOVEU[2]+MOVED[2]+MOVEL[2]=0)
                               and (X[2]>1) then MOVEL[2]:=8;
              if KEYDATA.Kup and (MAP[X[2],Y[2]-1,2]<3) and (MOVEL[2]+MOVER[2]+MOVED[2]+MOVEU[2]=0) then MOVEU[2]:=8;
              if KEYDATA.Kdown and (MAP[X[2],Y[2]+1,2]<3) and (MOVEL[2]+MOVER[2]+MOVEU[2]+MOVED[2]=0) then MOVED[2]:=8;
            end;

            if (KEYDATA.KS) and (ESCAP[1]=0) then begin
              ESCAP[1]:=2;
              SC[1]:=0;
              setcolor(yellow);
              settextstyle(9,0,1);
              if SFX=1 then SPLAY(COMBUST,2,24000);
              outtextxy(20,440,'SELF-COMBUSTED');
              setcolor(black);
            end;

            if (PS=2) and (KEYDATA.KDEL) and (ESCAP[2]=0) then begin
              ESCAP[2]:=2;
              SC[2]:=0;
              setcolor(lightcyan);
              settextstyle(9,0,1);
              if SFX=1 then SPLAY(COMBUST,2,24000);
              outtextxy(340,440,'SELF-COMBUSTED');
              setcolor(black);
            end;
            clearbuf;
          end;

          IF (X[PLAYER]>XSPAN-1) and (ESCAP[PLAYER]=0) then begin
            ESCAP[PLAYER]:=1;
            settextstyle(9,0,1);
            MOVER[PLAYER]:=0; MOVEL[PLAYER]:=0; MOVEU[PLAYER]:=0; MOVED[PLAYER]:=0;
            if PLAYER=1 then begin
              setcolor(yellow);
              outtextxy(20,440,'ESCAPED!');
            end;
            if PLAYER=2 then begin
              setcolor(lightcyan);
              outtextxy(340,440,'ESCAPED!');
            end;
            if SFX=1 then SPLAY(ESCAPE,2,12000);
            SC[PLAYER]:=SC[PLAYER]+(2*TSC)+(120*TIM);
            DISP_SCORE(PLAYER);
          end;
        end;
        inc(TOGGLE);

        if ((TOGGLE=2) and (PS=2)) or ((TOGGLE=2) and (PS=1)) then begin
          TOGGLE:=0; vwait;
        end;
      until (keydata.Kesc) or ((ESCAP[1]>0) and (ESCAP[2]>0)) or (((OPT=2) or (OPT=4)) and (ESCAP[1]>0))
          or ((TSC=0) and (TIM=0));

      if keydata.kesc then JUMPOUT;
      if (tsc=0) and (tim=0) and (ESCAP[1]=0) then SC[1]:=0;
      if (tsc=0) and (tim=0) and (ESCAP[2]=0) then SC[2]:=0;
      if (tsc=0) and (tim=0) and (SFX=1) then begin nosound; splay(FLUSH,1,12000); end;
      If (OPT<>1) and (OPT<>3) then begin nosound; Delay(1000); end;
      nosound;

      if OPT=2 then inc(ROUND);
      if (OPT=1) or (OPT=3) then begin
        setfillstyle(1,black);
        bar(200,100,440,200); setcolor(White); rectangle(200,100,440,200);
        LINE(320,100,320,200); line(200,120,440,120);
        settextjustify(centertext,centertext);
        settextstyle(smallfont,0,6);
        setcolor(yellow);
        if SC[1]>SC[2] then inc(WIN[1]);
        if SC[2]>SC[1] then inc(WIN[2]);
        outtextxy(260,110,NAMEA);
        str(SC[1],ST);
        outtextxy(260,140,ST);
        str(WIN[1],ST);
        outtextxy(260,170,ST);
        setcolor(lightcyan);
        outtextxy(380,110,NAMEB);
        str(SC[2],ST);
        outtextxy(380,140,ST);
        str(WIN[2],ST);
        outtextxy(380,170,ST);
        inc(TOTAL[1],SC[1]);
        inc(TOTAL[2],SC[2]);
        SC[1]:=0; SC[2]:=0;
        nosound;
        delay(200);
        clearbuf;
        repeat until readkey<>'';
        inc(ROUND);
      end;
      if OPT<>4 then ESCAP[1]:=0; ESCAP[2]:=0;
    until ((ROUND=4) or (abs(WIN[1]-WIN[2])>(4-ROUND)) and (OPT<4)) or (OPT=4);

    if OPT=4 then begin
      delay(500);
      cleardevice;
      if ESCAP[1]=1 then begin FIREWORK('YOU WON ULTIMATE SMUDGE!'); end;
      if (ESCAP[1]<>1) then begin
        SetGraphMode(vgamed);
        settextstyle(9,0,1);
        setcolor(white);
        settextjustify(centertext,centertext);
        outtextxy(320,240,'SMUDGELET FAILS');
        delay(200);
        if SFX=1 then SPLAY(FLUSH,1,12000);
        nosound;
        delay(200);
        clearbuf;
        repeat until keypressed;
      end;
    end;

    if (OPT=1) or (OPT=3) then begin
      cleardevice;
      IF WIN[1]>WIN[2] then FIREWORK('WINNER '+NAMEA);
      if WIN[2]>WIN[1] then FIREWORK('WINNER '+NAMEB);
      if WIN[2]=WIN[1] then FIREWORK('EQUAL SMUDGES!');
    end;

    if (OPT=2) then begin
      str(SC[1],ST);
      cleardevice;
      FIREWORK(NAMEA+' : '+ST);
    end;

    SetGraphMode(vgahi);
    until false;
    closegraph;
    SetIntVec($9,@KbdIntVec);
end.