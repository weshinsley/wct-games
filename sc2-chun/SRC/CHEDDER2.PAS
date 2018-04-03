{$N+}
program HBAB;
uses TDfonts,crt,graph,mousermw,dos;
var SPL,SCORE,GD,GM,drunktime,anumb,midcol,SPFLAG: integer;
    TimerDelay: Word;
    TimerIntVec : Procedure;
    DirInfo:searchRec;
    cheat: array[1..4] of boolean;
    keybinput,inchar,cst: string;
    mousexpos,mouseypos: word;
    drunk,totnum,maxnum: longint;
    polo: array[1..4] of real;
    BALLS : array[1..10,1..5] of real;
    CHEX  : array[1..10] of Byte;
    CHEXY : array[1..10] of Integer;
    SPEED : array[1..10,1..2] of real;
    FLAGS : array[1..10] of byte;
    tt,increm,tinc,CG : real;
    pixpos: array[1..20,1..2] of longint;
    Hi_names:array[1..6] of string[10];   {names}
    Hi_strings:array[1..6] of string[10]; {strings of scores}
    Hi_scores: array[1..6] of longint;    {values of scores}
    yv: array[1..6] of longint;
    F : file;
    k,akey,ch : char;
    XXX,YY,nn,kkk,starn,X,III,XT,XB,P,ppp,b,u,v,w,jjj ,i: longint;
    Q : text;
    PL : pointer;
    SC,hst1,hst2,dlev: string;
    times: array[1..6] of real;
   cols: array[1..6] of longint;

    G,CC,LL,JJ,NOI,L,S : byte;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal : Integer;
  Name: String;
  ColorNum: Integer;
end;
const
     MaxColors=15;
     Andy=Yellow;

    ARF : fillpatterntype = ($00 XOR 255,$26 XOR 255,$55 XOR 255,$55 XOR 255,$76 XOR 255,$55 XOR 255,$55 XOR 255,$55 XOR 255);
    Triangle1: array[1..3] of PointType = ((X:  0; Y: 0),
    (X: 320; Y: 175), (X: 640; Y: 0));
    Triangle2: array[1..3] of PointType = ((X:  0; Y: 0),
    (X: 320; Y: 175), (X: 0; Y: 350));
    Triangle3: array[1..3] of PointType = ((X:  0; Y: 350),
    (X: 320; Y: 175), (X: 640; Y: 350));
    Triangle4: array[1..3] of PointType = ((X:  640; Y: 0),
    (X: 320; Y: 175), (X: 640; Y: 350));

    fa: array[1..8] of fillpatterntype = (
    ($00,$26,$55,$55,$76,$55,$55,$00),
    ($26,$55,$55,$76,$55,$55,$00,$00),
    ($55,$55,$76,$55,$55,$00,$00,$26),
    ($55,$76,$55,$55,$00,$00,$26,$55),
    ($76,$55,$55,$00,$00,$26,$55,$55),
    ($55,$55,$00,$00,$26,$55,$55,$76),
    ($55,$00,$00,$26,$55,$55,$76,$55),
    ($00,$00,$26,$55,$55,$76,$55,$55));

    ball_horiz: array[1..8] of fillpatterntype = (
    ($00,$10,$38,$7c,$38,$10,$00,$00),
    ($10,$38,$7c,$38,$10,$00,$00,$00),
    ($38,$7c,$38,$10,$00,$00,$00,$10),
    ($7c,$38,$10,$00,$00,$00,$10,$38),
    ($38,$10,$00,$00,$00,$10,$38,$7c),
    ($10,$00,$00,$00,$10,$38,$7c,$38),
    ($00,$00,$00,$10,$38,$7c,$38,$10),
    ($00,$00,$10,$38,$7c,$38,$10,$00));

    ball_vert: array[1..8] of fillpatterntype = (
    ($00,$10,$38,$7c,$38,$10,$00,$00),
    ($00,$20,$70,$f8,$70,$20,$00,$00),
    ($00,$40,$e0,$f1,$e0,$40,$00,$00),
    ($00,$80,$c1,$e3,$c1,$80,$00,$00),
    ($00,$01,$83,$c7,$83,$01,$00,$00),
    ($00,$02,$07,$8f,$07,$02,$00,$00),
    ($00,$04,$0e,$1f,$0e,$04,$00,$00),
    ($00,$08,$1c,$3e,$1c,$08,$00,$00));


  Colors : array[0..MaxColors] of RGBRec = (
   ( RedVal:0;GreenVal:0;BlueVal:0;Name:'Black';ColorNum: 0),
   ( RedVal:0;GreenVal:0;BlueVal:40;Name:'Blue';ColorNum: 1),
   ( RedVal:0;GreenVal:40;BlueVal:0;Name:'Green';ColorNum: 2),
   ( RedVal:0;GreenVal:40;BlueVal:40;Name:'Cyan';ColorNum: 3),
   ( RedVal:40;GreenVal:7;BlueVal:7;Name:'Red';ColorNum: 4),
   ( RedVal:40;GreenVal:0;BlueVal:40;Name:'Magenta';ColorNum: 5),
   ( RedVal:40;GreenVal:30; BlueVal:0;Name:'Brown';ColorNum: 6),
   ( RedVal:49;GreenVal:49;BlueVal:49;Name:'Light Gray';ColorNum: 7),
   ( RedVal:26;GreenVal:26;BlueVal:26;Name:'Dark Gray';ColorNum: 8),
   ( RedVal:0;GreenVal:0;BlueVal:63;Name:'Light Blue';ColorNum: 9),
   ( RedVal:0{9};GreenVal:63;BlueVal:0{9};Name:'Light Green';ColorNum: 10),
   ( RedVal:0;GreenVal:63;BlueVal:63;Name:'Light Cyan';ColorNum: 11),
   ( RedVal:63;GreenVal:10;BlueVal:10;Name:'Light Red';ColorNum: 12),
   ( RedVal:44;GreenVal:0;BlueVal:63;Name:'Light Magenta';
          ColorNum: 13),
   ( RedVal:63;GreenVal:63;BlueVal:18;Name:'Yellow';ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:63; Name: 'White'; ColorNum: 15)
  );

{$F+,S-}
procedure TimerHandler; interrupt;
  begin
    Inc(TimerDelay);
    inline ($9C);
    TimerIntVec;
  end;
{$F-,S+}

Procedure Graphics_Error;
begin
SetIntVec($8,@TimerIntVec);
clrscr;
writeln('*********************** ERROR *******************************');
Writeln(' Error occurred during graphics initialisation');
Writeln(' '+GraphErrorMsg(Graphresult));
writeln(' You may not have VGA/EGA graphics.');
writeln(' If you have EGA, try running CHEDDER2 /EGA');
writeln('*************************************************************');
while keypressed do ch:=readkey;
writeln('Press any key');
repeat until keypressed;
halt(0);
end;

Procedure T2_vretrace; assembler;
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

Procedure SETRgb(nR,r,g,b:bYTE);
begin
     Port[$3c8]:=Nr;
     Port[$3c9]:=R;
     Port[$3c9]:=G;
     Port[$3c9]:=B;
End;

Procedure  Chunder; external;
{$l chundgfx.obj}

Procedure CH_E1; external;
{$L CH_E1.OBJ}
Procedure CH_E2; external;
{$L CH_E2.OBJ}
Procedure CH_E3; external;
{$L CH_E3.OBJ}
Procedure CH_E4; external;
{$L CH_E4.OBJ}
Procedure CH_S1; external;
{$L CH_S1.OBJ}
Procedure CH_S2; external;
{$L CH_S2.OBJ}
Procedure CH_S3; external;
{$L CH_S3.OBJ}
Procedure CH_S4; external;
{$L CH_S4.OBJ}


Procedure TDborder(bco:byte); assembler; {Sets border colour}
asm
     mov ah,10h
     mov al,01h
     mov bh,bco
     int 10h
end;
Procedure Keywait;
begin
     repeat
     mouseinfo; if keypressed then k:=readkey;
     until not ((keypressed) or (mouse.left) or (mouse.right));
end;

Procedure VWait; assembler;
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


Procedure ReadHi;
var
   b: longint;
   nm,sc: string;
   f:text;
   code: integer;
begin
  assign(f,'hbatab.dat');
  reset(f);
  for b:=1 to 6 do begin
    readln(f,nm); readln(f,sc);
    Hi_names[b]:=nm; Hi_strings[b]:=sc;
    Val(sc,Hi_scores[b],code);   end;
  CLOSE(F);
end;

Procedure WriteHi;
var
   b: longint;
   nm,sc: string;
   f:text;
begin
assign(f,'hbatab.dat');
rewrite(f);
for b:=1 to 6 do begin
    nm:=Hi_names[b]; str(Hi_scores[b],sc);
    writeln(f,nm); writeln(f,sc);
    end;
    close(F);
end;


procedure Show_Hiscores;
begin
  repeat
  p:=p+1;
  x:=1-x;
  xt:=xt-8;
  if xt<-100 then xt:=700;
  xb:=xb+8;
  if xb>700 then xb:=-80;

  for iii:=1 to 6 do begin
  times[iii]:=times[iii]+increm;
  if (times[iii])>=(2*pi) then times[iii]:=times[iii]-(2*pi); end;

  yv[1]:=round(cos(times[1])*100);
  yv[2]:=round(cos(times[2])*100);
  yv[3]:=round(cos(times[3])*100);
  yv[4]:=round(cos(times[4])*100);
  yv[5]:=round(cos(times[5])*100);
  yv[6]:=round(cos(times[6])*100);

  for jjj:=1 to 20 do begin
putpixel(pixpos[jjj,1],pixpos[jjj,2],round(random*15)+1);
end;
  inc(starn); if starn=21 then starn:=1;

pixpos[starn,1]:=round(random*640);
  pixpos[starn,2]:=round(random*350);
  setcolor(Andy);
  settextstyle(2,0,12);
{  outtextxy(xt,20,hst1);
  outtextxy(xb,300,hst2);}
  outtextxy(320,20,hst1);
  outtextxy(320,300,hst2);
    setcolor(9);
  settextstyle(2,horizdir,9);

  for nn:=6 downto 1 do begin
      setcolor(cols[nn]);
setusercharsize((11-nn)*10,30,60,30);
      outtextxy(320,yv[nn]+160,hi_names[nn]+'  '+hi_strings[nn]);
      end;
setvisualpage(1-x);
setactivepage(x);
{vwait;}
T2_Vretrace;
cleardevice;
mouseinfo;
  until ((keypressed) or (mouse.left) or (mouse.right));
  k:=chr(0);
  if keypressed then k:=readkey;
end;

Procedure cls;
begin
     setbkcolor(black);
     cleardevice;
     setactivepage(1);
     cleardevice;
     setactivepage(0);
     cleardevice;
     setvisualpage(0);
end;

Procedure Hiscore_defaults;
begin
  x:=1;
  TDborder(black);
  setbkcolor(black);
  cleardevice;
  increm:=pi/60;
  setvisualpage(0);
  setactivepage(1);
  settextstyle(2,horizdir,8);
  settextjustify(centertext,centertext);

  jjj:=0;
  hidepointer;
  xt:=700;
  xb:=-80;
  kkk:=1;
  times[6]:=0;
  times[5]:=10*increm;
  times[4]:=20*increm;
  times[3]:=30*increm;
  times[2]:=40*increm;
  times[1]:=50*increm;
  cols[1]:=14; cols[2]:=13; cols[3]:=12; cols[4]:=11; cols[5]:=10; cols[6]:=9;
  hst1:='Hi-scores'; hst2:='Waistwear';


  for jjj:=1 to 20 do begin pixpos[jjj,1]:=round(random*640);
  pixpos[jjj,2]:=round(random*350) end;
end;


Procedure Hi_input;
var
   stt,spc: string;
begin
     hst1:='New Hi Score!'; hst2:='Enter your name';
     for ppp:=1 to 6 do cols[ppp]:=lightgray;
     cols[b]:=lightgreen;
     stt:=''; spc:='<               ';
     hi_names[b]:=copy(spc,1,10);
     keywait;
     repeat
       show_hiscores;
       if (k=chr(8)) and (length(stt)>0) then stt:=copy(stt,1,length(stt)-1);
       if (k>=' ') and (length(stt)<9) then stt:=stt+k;
       hi_names[b]:=stt+copy(spc,1,10-length(stt));
     until k=chr(13);
     cols[1]:=14; cols[2]:=13; cols[3]:=12; cols[4]:=11; cols[5]:=10; cols[6]:=9;
     hst1:='Hi-scores'; hst2:='Waistwear';

     hi_names[b]:=stt+copy(spc,2,10-length(stt));
end;


Procedure hi_check;
var
   bb,tmp: longint;
begin
  b:=0;
  tmp:=0;
  repeat
    inc(b);
    if score>hi_scores[b] then tmp:=1;
  until (tmp=1) or (b=6);
  if tmp=1 then begin
  bb:=6;
  if B<>6 then begin
    repeat
      if bb>b then begin
      hi_strings[bb]:=hi_strings[bb-1];
      hi_scores[bb]:=hi_scores[bb-1];
      hi_names[bb]:=hi_names[bb-1]; end;
      dec(bb);
    until (bb=b);
  end;
  hi_scores[b]:=score; Str(score,hi_strings[b]);
  hi_input;
  writehi;
end;
  end;

Procedure Game_complete;
  begin
    tdborder(lightblue);
    setbkcolor(lightblue);
    jjj:=0;
    settextjustify(centertext,centertext);
    settextstyle(2,horizdir,6);
    setvisualpage(0);
    setactivepage(1);
    v:=320;
    i:=0;
    settextjustify(centertext,centertext);
    settextstyle(3,horizdir,8);
    setfillstyle(1,lightblue);
    tinc:=pi/40;
    repeat
      jjj:=1-jjj;
      setactivepage(jjj);
      tt:=tt+tinc;
      inc(i);
      if i=9 then i:=1;
      w:=round(sin(tt)*50);
      u:=round(sin(tt+pi/2)*100);
      setcolor(lightblue);
      setfillpattern(ball_vert[i],lightmagenta);
      fillpoly(3,triangle1);
      setfillpattern(ball_vert[9-i],lightmagenta);
      fillpoly(3,triangle3);
      setfillpattern(ball_horiz[9-i],lightmagenta);
      fillpoly(3,triangle2);
      setfillpattern(ball_horiz[i],lightmagenta);
      fillpoly(3,triangle4);
      setcolor(Andy);
      outtextxy(320-u,175-w,'WELL');
      setcolor(lightgreen);
      outtextxy(320+u,175+w,'DONE');
      vwait;
      setvisualpage(jjj);
      mouseinfo;
    until (keypressed) or (mouse.left) or (mouse.right);
    if keypressed then k:=readkey;
  end;

Procedure Main_Defaults;
begin
tt:=0; tinc:=pi/20; i:=1;
jjj:=0;
settextjustify(centertext,centertext);
settextstyle(2,horizdir,6);
setfillstyle(1,lightgreen);
setvisualpage(0);
setactivepage(1);
tdborder(lightgreen);
setbkcolor(lightgreen);
v:=320;
i:=0;
end;


Procedure Normal_colours;
var
   i:integer;
begin
for i := 0 to 15 do
  with Colors[i] do
    begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
    setpalette(i,i); end;
end;


Procedure Mainscreen;
  begin
    repeat
    jjj:=1-jjj;
    setactivepage(jjj);
    tt:=tt+tinc;
    inc(i);
    if i=9 then i:=1;
    w:=290+round(sin(tt)*40);
    u:=round(sin(tt*2)*200);
    settextjustify(centertext,centertext);
    setcolor(lightred);
    settextstyle(5,horizdir,3);
    setusercharsize(16,10,10,10);
    setfillpattern(fa[i],lightmagenta);
    bar(0,0,640,350);
    outtextxy(320,240,'by Tom and Wes');
    if cheat[1] then begin
    cst:='Cheat ';if cheat[2] then cst:=cst+'W ';
    if cheat[3] then cst:=cst+'C ';
    if cheat[4] then cst:=cst+'T';
    outtextxy(320,200,cst);
    end;
    settextstyle(10,horizdir,7);
    if jjj=0 then setcolor(lightcyan) else setcolor(lightmagenta);
    outtextxy(320,280,'WaistWear');
    setcolor(lightblue);
    settextstyle(2,horizdir,6);
    outtextxy(320,335,'Click: left to start, right for hi-scores, press [ESC] to quit');    setcolor(WHITE);
    settextstyle(7,horizdir,5);
    setusercharsize(3,1,abs(u),100);
    if u>0 then settextjustify(centertext,bottomtext) else
    settextjustify(centertext,toptext);
    outtextxy(320,60,'Shooting');
    if u<0 then settextjustify(centertext,bottomtext) else
    settextjustify(centertext,toptext);
    vwait;
    outtextxy(320,170,'Chundery');
{    Delay(3);}
    setvisualpage(jjj);
    mouseinfo;
  until ((keypressed) OR (MOUSE.LEFT) OR (MOUSE.RIGHT));

end;

Procedure Fade_out(begnum: integer);
var
   aaa,i:integer;
   rv,gv,bv: integer;
   charc: char;
begin
aaa:=100;
repeat
aaa:=aaa-1;
  vwait;

for i := begnum to 15 do begin
  with Colors[i] do begin
       rv:=round(Redval/100*aaa);
       bv:=round(Blueval/100*aaa);
       gv:=round(Greenval/100*aaa);
    SetRGB{Palette}(i,rv,gv,bv); end; end;
until aaa<1;
end;

procedure SETUPSTATS;
  begin
    setactivepage(0);
    setfillpattern(ARF,9);
    bar(0,160,639,200);
    setcolor(Andy); settextstyle(2,0,5); outtextxy(20,175,'Cloud Cover'); outtextxy(340,175,'Score');
    outtextxy(20,160,'Jelly Teddy Gun'); outtextxy(340,160,'Crocodile launcher');
    setfillstyle(1,black);
    bar(160,163,320,173);
    setcolor(white); rectangle(160,163,320,173);
    bar(500,163,600,173);
    rectangle(500,163,600,173);
    setfillstyle(1,red);
    bar(160,178,320,188);
    rectangle(160,178,320,188);
    setactivepage(1);
    setfillpattern(ARF,9);

    bar(0,160,639,200);
    setcolor(Andy); settextstyle(2,0,5); outtextxy(20,175,'Cloud Cover'); outtextxy(340,175,'Score');
    outtextxy(20,160,'Jelly Teddy Gun'); outtextxy(340,160,'Crocodile launcher');
    setfillstyle(1,black);
    bar(160,163,320,173);
    setcolor(white); rectangle(160,163,320,173);
    bar(500,163,600,173);
    rectangle(500,163,600,173);
    setfillstyle(1,red);
    bar(160,178,320,188);
    rectangle(160,178,320,188);
  end;


procedure CLEARAREA;
  var tts: byte;
      sst: word;
  begin
    sst:=$A000; If s=1 then SSt:=$A000+1024;
    SETFILLSTYLE(1,BLACK); tts:=0;
    if flags[6]=1 then begin
      tts:=round(random*15); setfillstyle(1,tts); end;

    asm
      push ds
      mov es,sst
      xor di,di
      mov cx,12800
      mov ah,tts
      rep stosb
      pop ds
    end;


{    bar(0,0,639,160);}
    if (SPFLAG=0){flags[2]=0} then setcolor(lightblue) else setcolor(lightred);
    LINE(0,160,639,160);
    setcolor(lightblue);
  end;


procedure STATS;
  begin
    setactivepage(0);
    if FLAGS[3]=1 then begin
      setfillstyle(1,lightgreen);
      bar(162,164,162+JJ,172);
      if JJ>100 then begin
        setfillstyle(1,red);
        bar(262,164,162+JJ,172);
        END;
      setfillstyle(1,black);
      bar(162+jj,164,319,172);
    end;
    if FLAGS[4]=1 then begin
      setfillstyle(1,lightmagenta);
      bar(501,164,501+trunc(CG),172);
      setfillstyle(1,black);
      bar(501+trunc(CG),164,599,172);
    end;

    if FLAGS[2]=1 then begin
      setfillstyle(1,black);
      bar(318-cc,179,318,187);
      end;

    if FLAGS[1]=1 then begin
      setfillpattern(ARF,9);
      bar(440,178,480,188);
      str(SCORE,SC);
      setcolor(White);
      settextstyle(2,0,5);
      outtextxy(440,175,SC);
      setfillstyle(1,red);
    end;
    setactivepage(1);
    if FLAGS[4]=1 then begin
      setfillstyle(1,lightmagenta);
      bar(501,164,501+trunc(CG),172);
      setfillstyle(1,black);
      bar(501+trunc(CG),164,599,172);
    end;
    if FLAGS[3]=1 then begin
      setfillstyle(1,lightgreen);
      bar(162,164,162+JJ,172);
      FLAGS[3]:=0;
      if JJ>100 then begin
         setfillstyle(1,red);
         bar(262,164,162+JJ,172);
         end;
      setfillstyle(1,black);
      bar(162+jj,164,319,172);

    end;
    if FLAGS[2]=1 then begin
      FLAGS[2]:=0;
      setfillstyle(1,black);
      bar(318-cc,179,318,187);
    end;
    if FLAGS[1]=1 then begin
      FLAGS[1]:=0;
      setfillPATTERN(ARF,9);
      bar(440,178,480,188);
      str(SCORE,SC);
      setcolor(White);
      settextstyle(2,0,5);
      outtextxy(440,175,SC);
    end;
  end;


function GETPTEST(XX,YY : integer) : byte;
  begin
    GETPTEST:=0;
    if (getpixel(XX,YY)<>0) or (getpixel(XX-1,YY)<>0) or (getpixel(XX-1,YY-1)<>0)
       or (getpixel(XX-1,YY+1)<>0) or (getpixel(XX,YY-1)<>0) or (getpixel(XX,YY+1)<>0)
       or (getpixel(XX+1,YY-1)<>0) or (getpixel(XX+1,YY)<>0) or (getpixel(XX+1,YY+1)<>0)
         THEN GETPTEST:=1;
  end;


procedure SHOOT;
  begin
    if mouse.left then begin
    if (flags[5]=1) and (JJ<100) then begin
    if midcol=white then begin
    polo[4]:=polo[4]-1; score:=score+10; flags[1]:=1;
    jj:=99; flags[7]:=1;
    if polo[4]<0 then begin flags[6]:=1; score:=score+90; end;
    end; end;


    SPL:=SPL-10;
    JJ:=JJ+2;
    FLAGS[3]:=1;
    if JJ<100{157} then begin
      G:=getptest(mousexpos+6,mouseypos+26);
      if G=0 then G:=getptest(mousexpos+2,mouseypos+26);
      if G=0 then G:=getptest(mousexpos+6,mouseypos+23);
      if G=0 then G:=getptest(mousexpos+6,mouseypos+29);
      IF G=0 then G:=getptest(mousexpos+10,mouseypos+26);
      putpixel(mousexpos+7,mouseypos+26,0);
      if G<>0 then begin
        L:=0;
        repeat
          inc(L);
          xXx:=mousexpos+7;
          yy:=mouseypos+26;
        if (G<>0) and (xxX>BALLS[L,1]) and (xxX<BALLS[L,1]+17) and (yY>BALLS[L,2]) and
        (yy<BALLS[L,2]+20) and (CHEX[L]=0)
          then
            begin
{               setfillstyle(1,black);
               bar(trunc(BALLS[L,1]),trunc(BALLS[L,2]),trunc(BALLS[L,1]+17),trunc(BALLS[L,2]+20));}
               SCORE:=SCORE+5; SPL:=SPL+40;
               FLAGS[1]:=1;
               CHEXY[L]:=Round(BALLS[L,2]);
               BALLS[L,2]:=940;
               CHEX[L]:=11;
               end;
             until L>=10;
           end;
        end;
      end;
    if (mouse.right) and (FLAGS[4]=0) and (flags[5]=0) then begin
      LL:=0;
      settextstyle(7,0,8);
      repeat
        inc(LL);
        setactivepage(S);
        setvisualpage(S);
        setfillstyle(1,lightmagenta);
        setcolor(lightgreen);
        bar(0,0,639,160);
        outtextxy(80,20,'CROCODILE!');
        DELAY(20);
        setfillstyle(1,lightgreen);
        setcolor(lightmagenta);
        bar(0,0,639,160);
        outtextxy(80,20,'CROCODILE!');
        DELAY(20);
      until LL>10;
      CG:=97; FLAGS[4]:=1; FLAGS[1]:=1; totnum:=totnum+10;
      For LL:=1 to 10 do if CHEX[L]>0 then Dec(Totnum);
      SCORE:=SCORE+5*Totnum;
      SPL:=SPL-15;
      LL:=0;
      repeat
        inc(LL);
        BALLS[LL,1]:=random(589)+28;
        BALLS[LL,2]:=-20;
        CHEX[LL]:=0;
        CHEXY[LL]:=0;
        if totnum>maxnum then SPEED[LL,2]:=0 else
        repeat
          SPEED[LL,1]:=(random(400)/SPL);
          SPEED[LL,2]:=(random(400)/SPL);
        until (SPEED[LL,1]<>0) and (SPEED[LL,2]>(1200-SPL)/1500);
        BALLS[LL,3]:=random(14)+1;
      until LL>=10;
    END;
    if (mouse.right) and (CG>0) then CG:=97;

  end;

begin
  TimerDelay:=0;
  findfirst('HBAtab.dat',anyfile,dirinfo);
  if doserror<>0 then begin
  Hi_Names[1]:='Chris     '; Hi_Names[2]:='Wes       ';
  Hi_Names[3]:='Tom       '; Hi_Names[4]:='Andy      ';
  Hi_Names[5]:='Merrick   '; Hi_Names[6]:='Ben       ';
  Hi_Scores[1]:=80; Hi_Scores[2]:=70;  Hi_Scores[3]:=60;
  Hi_Scores[4]:=50; Hi_Scores[5]:=40; Hi_Scores[6]:=30; WriteHi; end;
  cheat[1]:=false; cheat[2]:=false; cheat[3]:=false; cheat[4]:=false;
  egavga;
  INITVGA(vgahi);
  font2;
  font3;
  font5;
  font6;
  font7;
  font10;
  PL:=@Chunder;

  randomize;
  initmouse;
  readhi;
  GetIntVec($8,@TimerIntVec);
  SetIntVec($8,Addr(TimerHandler));

  if paramstr(1)='/EGA' then begin
  GD:=ega; GM:=egahi; end else begin
  GD:=vga; GM:=vgamed; end;
  initgraph(GD,GM,'');
  If graphresult<>grok then graphics_Error;

  repeat {until false}
  keybinput:='';

  closegraph;
  if paramstr(1)='/EGA' then begin
  GD:=ega; GM:=egahi; end else begin
  GD:=vga; GM:=vgamed; end;
  initgraph(GD,GM,'');
  If graphresult<>grok then graphics_Error;


  normal_colours;
     hidepointer;
     main_defaults;
     keywait;
     repeat
     mainscreen;
     akey:=chr(0);
     if keypressed then akey:=readkey;
     inchar:=upcase(akey);

     if (inchar>='A') and (inchar<='Z') then begin
        keybinput:=keybinput+inchar;
        l:=length(keybinput);
        if l>5 then keybinput:=copy(keybinput,l-4,5);
        if keybinput='DRUNK' then cheat[1]:=not cheat[1];
        if cheat[1] then begin
        if inchar='W' then cheat[2]:=not cheat[2];
        if inchar='C' then cheat[3]:=not cheat[3];
        if inchar='T' then cheat[4]:=not cheat[4]; end
        else begin cheat[2]:=false; cheat[3]:=false; cheat[4]:=false; end;
     end;

     if ((inchar='H') or (mouse.right)) then begin
        cls;
        Hiscore_defaults; keywait; show_hiscores; cls;
        main_defaults;
        keywait;
        end;
     if akey=chr(27) then begin
        fade_out(9);
        cls;
        closegraph;
        textcolor(lightgray);
        textbackground(black);
        clrscr; keywait;
        SetIntVec($8,@TimerIntVec);
        halt(0);

        end;

    until ((inchar='S') or (mouse.left));

  cls;
  closegraph;



  if paramstr(1)='/EGA' then begin
  GD:=ega; GM:=egalo; end else begin
  GD:=vga; GM:=vgalo; end;
  initgraph(GD,GM,'');
  If graphresult<>grok then graphics_Error;
  settextjustify(lefttext,toptext);
  L:=0; repeat inc(l); flags[l]:=0; until l=10; l:=0;
  SCORE:=0;
  SPL:=1200; cc:=0; cg:=0;
  SETUPSTATS; drunk:=0; drunktime:=0; totnum:=10; maxnum:=600;
  polo[1]:=random(560)+40; polo[2]:=-20; polo[3]:=11; polo[4]:=10;
  jj:=0; s:=0;
  keywait;
       setmousexlimits(1,639);
       setmouseylimits(0,130);

  repeat
    inc(L);
    BALLS[L,1]:=random(589)+28;
    BALLS[L,2]:=-20;
    CHEX[L]:=0;
    repeat
        SPEED[L,1]:=(random(400)/SPL);
        SPEED[L,2]:=(random(400)/SPL);
    until (SPEED[L,1]<>0) and (SPEED[L,2]>0.1);
  until L>=10;

  repeat
    inc(drunktime);
    if drunktime>200 then begin inc(drunk); drunktime:=0; end;
    if (totnum>maxnum) and (flags[5]=0) then begin
       flags[5]:=1; for anumb:=1 to 10 do
          if speed[anumb,2]<>0 then flags[5]:=0;
       end;

    S:=1-S;
    setactivepage(S);
    setvisualpage(1-S);

    Repeat
      vwait;
      Until TimerDelay>0;
    TimerDelay:=0;
    CLEARAREA;
    settextstyle(0,horizdir,2);
    str(drunk,dlev);
    settextjustify(centertext,centertext);
    if (drunktime>185) or (flags[5]=1) then begin
       setcolor(round(int(random*14))+1);
       if flags[6]=0 then
          circle(round(random*640),round(random*100),30); end;
    if flags[5]=0 then outtextxy(320,75,'Alcohol level '+dlev)
    else begin
    if flags[6]=0 then begin
    outtextxy(320,75,'Shoot the Polo !');
    Polo[2]:=polo[2]+0.5;
    if polo[2]>135 then cc:=158;
    If (polo[1]>600) then polo[3]:=-abs(polo[3]);
    If (polo[1]<40) then polo[3]:=abs(polo[3]);
    polo[1]:=polo[1]+polo[3];
    end else begin
    outtextxy(320,75,'You did it!');
    polo[4]:=polo[4]+12;
    end; end;
    settextjustify(lefttext,toptext);
    STATS;

    if spl>120 then dec(spl);
    if spl<120 then spl:=spl+10;

    setactivepage(S);
    L:=0;
      settextstyle(6,0,4);
      if flags[5]=1 then begin
          if flags[6]=0 then begin
          setcolor(white);
          circle(round(polo[1]),round(polo[2]),40);
          circle(round(polo[1]),round(polo[2]),20);
          if flags[7]=0 then setfillstyle(1,white)
          else begin setfillstyle(1,red); flags[7]:=0; end;
          Floodfill(round(polo[1]),round(polo[2])+17,white);
          end else begin
          setcolor(round(int(random*15))+1);
          Ellipse(round(polo[1]),round(polo[2]),0,360,round(40+polo[4]),18);
          Ellipse(round(polo[1]),round(polo[2]),0,360,round(20+polo[4]),9);
          setfillstyle(1,getcolor);
          Floodfill(round(polo[1]),round(polo[2])+17,getcolor);
          Floodfill(round(polo[1]),round(polo[2])-17,getcolor);
          end; end;
      SPFLAG:=0;
      repeat
        inc(L);

        If CHEX[L]=0 then begin
            if BALLS[L,2]<140 then putimage(trunc(BALLS[L,1]),trunc(BALLS[L,2]),PL^,xorput)
          end else begin
            If CHEX[L]<10 then Inc(SPFLAG);
            If CHEXY[L]>139 then CHEXY[L]:=139;
            Case CHEX[L] of
              1: Putimage(trunc(BALLS[L,1]),143,@CH_E1^,XorPut);
              2: Putimage(trunc(BALLS[L,1]),143,@CH_E2^,XorPut);
              3: Putimage(trunc(BALLS[L,1]),143,@CH_E3^,XorPut);
              4: Putimage(trunc(BALLS[L,1]),143,@CH_E4^,XorPut);
              11: Putimage(trunc(BALLS[L,1])+4,CHEXY[L]+4,@CH_S1^,XorPut);
              12: Putimage(trunc(BALLS[L,1])+4,CHEXY[L]+4,@CH_S2^,XorPut);
              13: Putimage(trunc(BALLS[L,1])+4,CHEXY[L]+4,@CH_S3^,XorPut);
              14: Putimage(trunc(BALLS[L,1])+4,CHEXY[L]+4,@CH_S4^,XorPut);
              end;


          end;
        BALLS[L,1]:=(BALLS[L,1]+SPEED[L,1]);
        BALLS[L,2]:=(BALLS[L,2]+SPEED[L,2]);
        If chex[L]>9 then Inc(CHEXY[L],Round(SPEED[L,2]));
        if BALLS[L,1]<0 then BALLS[L,1]:=10;
        if (BALLS[L,1]<10) or (BALLS[L,1]>620) or (BALLS[L,2]>140) then
          begin
            if (BALLS[L,1]<10) or (BALLS[L,1]>620) then SPEED[L,1]:=-SPEED[L,1];
            if (BALLS[L,2]>140) Then Inc(CHEX[L]);
            If ((CHEX[L]>4) and (CHEX[L]<10)) or (CHEX[L]>14) then
              begin inc(totnum);
                CHEX[L]:=0;
                CC:=CC+2; FLAGS[2]:=1;
                if BALLS[L,2]>=940 then begin
                CC:=CC-2; FLAGS[2]:=0 end else flags[7]:=1;
                repeat
                  BALLS[L,1]:=random(639);
                until (BALLS[L,1]>40) and (BALLS[L,1]<600);
                BALLS[L,2]:=-20;
                repeat
                  SPEED[L,1]:=(random(400)/SPL);
                  SPEED[L,2]:=(random(400)/SPL);
                until (SPEED[L,1]<>0) and (SPEED[L,2]>0.1);
                if totnum>maxnum then speed[L,2]:=0;
              end;
            end;
       until L>=10;
       mouseinfo;
       SETTEXTSTYLE(DEFAULTFONT,0,1);
       mousexpos:=mouse.x+round(random*drunk*3/2);
       mouseypos:=mouse.y+round(random*drunk/2);
       if mouseypos>131 then mouseypos:=131;
       midcol:=getpixel(mousexpos+6,mouseypos+26);
       putpixel(mousexpos+6,mouseypos+26,15);
       putpixel(mousexpos+2,mouseypos+26,15);
       putpixel(mousexpos+6,mouseypos+23,15);
       putpixel(mousexpos+6,mouseypos+29,15);
       putpixel(mousexpos+10,mouseypos+26,15);
       if (mouse.left) or (mouse.right) then shoot;
       if keypressed then begin
          akey:=upcase(readkey);
          if akey=chr(27) then cc:=158;
          if (akey=' ') and (cheat[1]) then begin
             cg:=0; jj:=0; flags[3]:=1;
             setfillstyle(1,black);
             bar(501,164,599,172);
             setactivepage(1-s);
             bar(501,164,599,172);
             setactivepage(s);
              end;
          if (akey='W') and (cheat[2]) then maxnum:=totnum;
          if (akey='C') and (cheat[3]) then begin
             setactivepage(1-s);
             setfillstyle(1,red); bar(161,179,318,187);
             setactivepage(s);
             setfillstyle(1,red); bar(161,179,318,187);
             cc:=0; end;
          if (akey='T') and (cheat[4]) then begin
             score:=score+100; flags[1]:=1; end;
          end;
       if CG>0 then CG:=CG-0.5;
       if CG=0 then FLAGS[4]:=0;
       if JJ>157 then JJ:=157;
       if (JJ>0) and (not ((mouse.left) or (mouse.right))) then begin jJ:=JJ-1; FLAGS[3]:=1; end;
  until (CC>157) or ((flags[6]=1) and (polo[4]>600));


  if flags[6]=1 then begin
    setactivepage(0);
    setvisualpage(0);
    setfillstyle(1,black);
    bar(0,0,639,160);
    settextstyle(0,horizdir,2);
    settextjustify(centertext,centertext);
    L:=0;
    repeat inc(l);
    setcolor(round(random*15)+1);
    outtextxy(320,75,'The Earth is safe!');
    until l>100;
    closegraph;
  if paramstr(1)='/EGA' then begin
  GD:=ega; GM:=egahi; end else begin
  GD:=vga; GM:=vgamed; end;
  initgraph(GD,GM,'');
  If graphresult<>grok then graphics_Error;
  keywait;
  normal_colours;
  game_complete;
  fade_out(9); cls;
  end else begin
  setfillstyle(1,6); setactivepage(0); setvisualpage(0);
  settextstyle(10,0,6); setcolor(1); setrgbpalette(1,0,63,0);
  SEttextjustify(centertext,centertext);
  bar(0,0,639,200);
  outtextxy(320,20,'GAME');
  OUTTEXTXY(320,100,'OVER');
  L:=63;
  setrgbpalette(6,L,L,0);
  repeat
    L:=L-1;
    setrgbpalette(6,L,L,0);
    delay(40);
  until L<=1;
  L:=63;
  repeat
    L:=L-1;
    setrgbpalette(1,0,L,0);
    delay(10);
  until L<=1;
  end;
  closegraph;
  GD:=vga;
  GM:=vgamed;
  initgraph(GD,GM,'');
  If graphresult<>grok then graphics_Error;
  keywait;
  hiscore_defaults; hi_check;
  keywait; show_hiscores; cls; {main_defaults;}
until false;
end.