{
************************************************************************
***************** SHOOTING CHEDDERY PART 1, revision 2 *****************
************************************************************************
***** A Waistwear Product. (C) WCT SOFTWARE March 1995, June 1996  *****
*** All programming (C) Wes Hinsley & Tom Doel March 1995, June 1996 ***
***          This version: 30th August 2000, Pentium Upgrade         ***
************************************************************************
***** This program code and associated object files are copyright  *****
***** WCT Software and may not be used in other programs or        *****
***** distributed without written consent from WCT Software        *****
************************************************************************
***** The name "CHRIS" is a trademark of CPG. All Rights Reserved  *****
************************************************************************
}

{$m 6000,5000,5000}

program sched;
uses graph,crt,mousermw,DOS,tdgraph,tdfonts;
var PEANUTS,GD,GM,abb : integer;
  DirInfo: SearchRec;
  TIME : array[1..21] of longint;
  POSS : array[1..21,1..2] of longint;
  FLAGS : array[1..10] of byte;
  Hi_scores: array[1..5] of longint;
  Hi_names: array[1..5] of string[6];
  Level_name: array[1..12] of string[16];
  ch : char;
  p : pointer;
  JURY,L,LL,kL,FLAG,NOI,MAX,RATE,TM : byte;
  SHOTS,HITS,MISSES,CTT,CT,xxx,yy,CHEDDERS,SCORE,TIMR,LEVEL,CTR,RNA,XS: Longint;
  YS,SC,XX,X,Y,X1,X2 : LONGint;
  SCR,LEV : string;
  f:text;

const
  CRM='SC1/2.0 (C) WCT';
  RN : array[1..13] of byte = (1,0,1,0,0,1,0,1,0,0,1,0,1);
  FCPG : fillpatterntype = (110,74,72,74,74,74,110,0);
  Andy=Yellow;

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

Procedure Graphics_Error;
begin
  clrscr;
  writeln('SHOOTING CHEDDERY 1, (C) WCT Software.');
  writeln('*********************** ERROR *******************************');
  Writeln(' Error occurred during graphics initialisation');
  Writeln(' '+GraphErrorMsg(Graphresult));
  writeln(' You may not have VGA/EGA graphics.');
  writeln(' If you have EGA, try running CHEDDER1 /EGA');
  writeln('*************************************************************');
  while keypressed do ch:=readkey;
  writeln('Press any key');
  repeat until keypressed; halt(1);

end;

Procedure ReadHi;
  var nm,sc: string;
      code: integer;
begin
  assign(f,'hitable.dat');
  reset(f);
  for abb:=1 to 5 do begin
    readln(f,nm); readln(f,sc);
    Hi_names[abb]:=nm; Val(sc,Hi_scores[abb],code);   end;
  close(F);
end;

Procedure WriteHi;
  var nm,sc: string;
begin
  assign(f,'hitable.dat');
  rewrite(f);
  for abb:=1 to 5 do begin
    nm:=Hi_names[abb];
    str(Hi_scores[abb],sc);
    writeln(f,nm);
    writeln(f,sc);
  end;
  close(F);
end;

Procedure scrollin(xp,yp: longint;txt: string);
begin
  settextstyle(SmallFont,horizdir,8);
  settextjustify(centertext,centertext);
  setfillstyle(1,black);
  x1:=-100; x2:=740;
  repeat
    t2_vretrace;
    bar(0,yp-20,640,yp+20);
    outtextxy(x1,yp,txt);
    outtextxy(x2,yp,txt);
    x1:=x1+30;
    x2:=x2-30;
  until x1>320;
end;

Procedure scrollout(xp,yp: longint;txt: string);
begin
  settextstyle(SmallFont,horizdir,8);
  settextjustify(centertext,centertext);
  setfillstyle(1,black);
  x1:=320; x2:=320;
  repeat
    t2_vretrace;
    bar(0,yp-20,640,yp+20);
    outtextxy(x1,yp,txt);
    outtextxy(x2,yp,txt);
    x1:=x1-30;
    x2:=x2+30;
  until x1<-100;
  bar(0,yp-20,640,yp+20);
end;

procedure Show_Hiscores;
var
   ss: string;
begin
  readhi;
  cleardevice;
  setcolor(lightgreen);
  scrollin(320,30,'Hi-Scores');
  setcolor(Andy);
  for abb:=1 to 5 do begin
    Str(hi_scores[abb],ss);
    scrollin(320,40+50*abb,hi_names[abb]+'   '+ss);
  end;
  repeat
    mouseinfo;
  until (keypressed) or (mouse.left) or (mouse.right);
  scrollout(320,30,'Hi-Scores');
  for abb:=1 to 5 do begin
    Str(hi_scores[abb],ss);
    scrollout(320,40+50*abb,hi_names[abb]+'   '+ss);
  end;
end;

Procedure Show_levelname;
begin
  hidepointer;
  str(level,lev);
  setcolor(lightmagenta);
  scrollin(320,80,'Level '+lev);
  scrollin(320,140,level_name[level]);
  delay(1000);
  scrollout(320,80,'Level '+lev);
  scrollout(320,140,level_name[level]);
  showpointer;
end;

Function hi_input: string;
  var tempst,keyin: string;
begin
  setfillstyle(1,black);
  settextjustify(centertext,centertext);
  setcolor(Andy);
  scrollin(320,30,'Brilliant');
  scrollin(320,70,'Hi-Score!');
  setcolor(lightgreen);
  scrollin(320,120,'Enter your name:');
  tempst:='';
  setcolor(lightred);
  repeat
    keyin:=readkey;
    if (keyin=chr(8)) and (length(tempst)>0) then begin
      tempst:=copy(tempst,1,length(tempst)-1);
      bar(220,150,420,200); outtextxy(320,175,tempst);
    end;
    if (keyin>=' ') and (length(tempst)<6) then begin
      tempst:=tempst+keyin; bar(220,150,420,200);
      outtextxy(320,175,tempst);
    end;
  until keyin=chr(13);
  hi_input:=tempst;
end;

procedure Hi_check;
  var b,bb,tmp: longint;
begin
  readhi;
  b:=0;
  tmp:=0;
  repeat
    inc(b);
    if score>hi_scores[b] then tmp:=1;
  until (tmp=1) or (b=5);
  if tmp=1 then begin
    bb:=5;
    if B<>5 then begin
      repeat
        if bb>b then begin
          hi_scores[bb]:=hi_scores[bb-1];
          hi_names[bb]:=hi_names[bb-1];
        end;
        bb:=bb-1;
      until (bb=b);
    end;
    hi_scores[b]:=score;
    hi_names[b]:=hi_input;
    writehi;
  end;
end;

Procedure screen;
begin
  hidepointer;
  tdborder(lightgray);
  setfillstyle(1,BLACK);
  bar(0,260,640,360);
  TDsetwindowColour(darkgray,blue,1);
  TDdrawWindow(8,270,620,70);
  settextstyle(SmallFont,0,6);
  settextjustify(lefttext,centertext);
  setcolor(white);
  outtextxy(20,280,'TIME:');
  setfillstyle(1,Andy);
  bar(109,274,621,291);
  setfillstyle(1,red);
  bar(110,275,620,290);
  outtextxy(20,300,'PEANUTS:');
  setfillstyle(1,Andy);
  bar(109,294,311,311);
  setfillstyle(7,lightblue);
  bar(110,295,310,310);
  outtextxy(330,300,'MINI-CHEDDARS:');
  setfillstyle(1,Andy);
  bar(469,294,621,311);
  setfillstyle(8,magenta);
  bar(470,295,620,310);
  outtextxy(20,320,'SCORE:');
  settextjustify(lefttext,centertext);
  str(score,scr);
  setcolor(lightgreen);
  outtextxy(110,320,scr);
  setcolor(white);
  outtextxy(222,320,'LEVEL:');
  settextstyle(SmallFont,0,6);
  setcolor(lightgreen);
  outtextxy(400,320,'(C) WAISTWEAR 1995');
  showpointer;
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

function GETPTEST(XX,YY : integer) : byte;
begin
  GETPTEST:=0;
  if (getpixel(XX,YY)<>0) or (getpixel(XX-1,YY)<>0) or (getpixel(XX-1,YY-1)<>0)
     or (getpixel(XX-1,YY+1)<>0) or (getpixel(XX,YY-1)<>0) or (getpixel(XX,YY+1)<>0)
     or (getpixel(XX+1,YY-1)<>0) or (getpixel(XX+1,YY)<>0) or (getpixel(XX+1,YY+1)<>0)
       THEN GETPTEST:=1;
end;

procedure Game_Quit;
begin
  hidepointer;
  cleardevice;
  setcolor(lightcyan);
  settextstyle(7,0,4);
  outtextxy(320,30,'So, you''ve given up ');
  setcolor(lightblue);
  outtextxy(320,60,'SHOOTING CHEDDARY');
  setcolor(lightgreen);
  outtextxy(320,90,'have you? Remember that if');
  setcolor(Andy);
  outtextxy(320,120,'you are as alert, and as fast');
  setcolor(brown);
  outtextxy(320,150,'as you can make yourself, then');
  setcolor(red);
  outtextxy(320,180,'you may be amongst the realms of');
  setcolor(lightred);
  outtextxy(320,210,'the TOP GUNNER, whose reactions &');
  setcolor(lightmagenta);
  outtextxy(320,240,'degree of alertness is unbeatable.....');
  setpointer(pCPG); s
  howpointer;
  repeat
    mouseinfo;
  until (keypressed) or (mouse.left) or (mouse.right);
  HidePointer;
  cleardevice;
  closegraph;
  clrscr;
  halt;
end;

procedure TITLE;
begin
  hidepointer;
  repeat
    if keypressed then repeat until readkey<>'';
  until not keypressed;
  cleardevice;
  SCORE:=0;
  settextjustify(centertext,centertext);
  settextstyle(8,0,7); setcolor(lightmagenta); setfillpattern(FCPG,lightgray); bar(0,0,639,479);
  setfillstyle(1,blue);
  bar(20,6,619,132);
  outtextxy(320,20,'Shooting');
  setcolor(lightgreen);
  outtextxy(320,75,'Cheddery');
  setfillstyle(1,black); bar(100,200,539,240);
  settextstyle(10,0,1); setcolor(lightred);
  outtextxy(320,211,'by WAISTWEAR');
  setfillpattern(FCPG,darkgray); bar(0,310,639,350);
  setcolor(White); settextstyle(7,0,1);
  setfillpattern(FCPG,darkgray); bar(200,163,429,185);
  outtextxy(320,170,'Happy Birthday Chris!');
  settextstyle(6,0,1); setcolor(lightcyan);
  outtextxy(320,315,'Controls : LEFT MOUSE BUTTON for peanuts, RIGHT MOUSE BUTTON for cheddars');
  settextstyle(6,0,1); setcolor(Andy);
  outtextxy(320,331,'Press Left Beerglass to play, or Right Beerglass for high scores ');
  setpointer(pBeerglass);
  bar(0,246,639,286);setcolor(lightblue); settextstyle(10,0,1); outtextxy(328,260,'Designed and Programmed by Wes and Tom');
  setfillstyle(1,black);
  bar(0,286,639,309);
  setcolor(lightmagenta); settextstyle(7,0,1);
  outtextxy(320,293,'Sponsored by Carpetland Wastecoat Design Department');
  setmousexlimits(10,630);
  setmouseylimits(10,340);
  showpointer;
  repeat
    repeat
      mouseinfo;
    until (mouse.left) or (mouse.right) or (keypressed);
    if keypressed then ch:=readkey;
    FLAGS[8]:=0;
    if (ch=chr(67)) then begin
      FLAGS[8]:=1;
      MOUSE.LEFT:=true;
    end;
    if (ch=chr(27)) then Game_Quit;
  until (MOUSE.LEFT) or (MOUSE.RIGHT);
  FLAGS[7]:=0;
  if MOUSE.RIGHT then begin hidepointer; show_hiscores; showpointer; FLAGS[7]:=1; end;
end;

procedure PIG; external;      {$l PIG.OBJ}
procedure HOSTAGE; external;  {$l HOSTAGE.obj}
procedure CACTUS; external;   {$l cactus.obj}
procedure LADYBIRD; external; {$l LADYBIRD.obj}
procedure BARN; external;     {$l BARN.obj}
procedure DINO; external;     {$l DINO.obj}
procedure FISH1; external;    {$l FISH1.obj}
procedure FROG; external;     {$l FROG.obj}
procedure CHICKEN; external;  {$l CHICKEN.obj}
procedure BUS; external;      {$l BUS.obj}
procedure PLAYER; external;   {$l PLAYER.obj}
procedure FISH2; external;    {$l FISH2.obj}

procedure UpdateStatus;
begin
  settextstyle(SmallFont,0,5);
  settextjustify(lefttext,centertext);
  if flags[1]=1 then begin
    FLAGS[1]:=0;
    setfillstyle(1,blue);bar(110,314,200,330); str(score,scr);
    setcolor(lightgreen); outtextxy(110,320,scr);
  end;
  if flags[2]=1 then begin
    FLAGS[2]:=0; setfillstyle(1,black);
    bar(470+chedders,295,620,310);
  end;
  if flags[3]=1 then begin
    FLAGS[3]:=0; setfillstyle(1,black);
    bar(110+peanuts,295,310,310); FLAGS[4]:=1; CTR:=0;
  end;
  if flags[5]=1 then begin
    FLAGS[5]:=0; setFILLSTYLE(1,black);
    bar(110+TIMR,275,620,290);
  end;
  if flags[6]=1 then begin
    FLAGS[6]:=0; Setfillstyle(1,blue); bar(290,314,370,330);
    str(level,lev);
    setcolor(lightred);
    outtextxy(290,320,lev);
  end;
end;

procedure SHOOT;
begin
  hidepointer;
  if (MOUSE.LEFT) AND (FLAGS[4]=0) AND (PEANUTS>0) then begin
    Inc(SHOTS); Dec(PEANUTS);
  end;
  if (MOUSE.RIGHT) then begin
    Dec(CHEDDERS,30); Inc(SHOTS,10);
  end;
  if CHEDDERS<-20 then CHEDDERS:=-20;
  if (MOUSE.RIGHT) and (CHEDDERS>-20) then begin
    L:=0;
    repeat
      if NOI>0 then begin
        inc(L);
        settextstyle(7,0,9);
        setcolor(brown);
        setfillstyle(1,Andy);
        bar(POSS[L,1],POSS[L,2],POSS[L,1]+XS,POSS[L,2]+YS);
        if POSS[L,1]>40 then POSS[L,1]:=POSS[L,1]-40;
        if POSS[L,2]>70 then POSS[L,2]:=POSS[L,2]-70;
        settextjustify(0,0);
        outtextxy(POSS[L,1],POSS[L,2],'CHEDDAR');
        LL:=0;
        SCORE:=SCORE+SC; HITS:=HITS+1; FLAGS[1]:=1;
        TIME[L]:=0;
      end;
    until l>=noi;
    delay(500);
    NOI:=0;
    repeat
      LL:=LL+1;
      setfillstyle(random(14)+1,lightmagenta);

      bar(0,0,639,260);
      settextjustify(0,0);
      settextstyle(7,0,9);
      outtextxy(random(439),random(170),'CHEDDAR'); vwait;
      FLAGS[2]:=1;
      setfillstyle(random(14)+1,lightgreen);
      bar(0,0,639,260);
      outtextxy(random(439),random(170),'CHEDDAR'); vwait;
      setfillstyle(random(14)+1,Andy);
      bar(0,0,639,260);
      outtextxy(random(639),random(170),'CHEDDAR'); vwait;
    until LL>10;
    setfillstyle(1,black);
    bar(0,0,639,260);
  END;
  if (MOUSE.LEFT) and (FLAGS[4]=0) and (PEANUTS>0) then begin
    FLAGS[3]:=1;
    FLAGS[4]:=1;
    L:=0;
    repeat
      inc(L);
      xXx:=mouse.x;
      yy:=mouse.y;
      if (getPTEST(XXX,YY)<>black) and (MOUSE.X>POSS[L,1]) and (MOUSE.X<POSS[L,1]+XS) and (MOUSE.Y>POSS[L,2]) and
      (MOUSE.Y<POSS[L,2]+YS) then begin
        if NOI>0 then begin
          PutImage(POSS[L,1],POSS[L,2],P^,NotPut);
          Vwait;
          Vwait;
          PutImage(POSS[L,1],POSS[L,2],P^,XorPut);
          Vwait;
          Vwait;
          PutImage(POSS[L,1],POSS[L,2],P^,XorPut);
          Vwait;
          Vwait;

          setfillstyle(1,black);
          bar(POSS[L,1],POSS[L,2],POSS[L,1]+XS,POSS[L,2]+YS);
          SCORE:=SCORE+SC; HITS:=HITS+1; FLAGS[1]:=1;
          KL:=L;
          if NOI>0 then begin
            NOI:=NOI-1;
            repeat
              POSS[KL,1]:=POSS[KL+1,1]; POSS[KL,2]:=POSS[KL+1,2]; TIME[KL]:=TIME[KL+1];
              KL:=KL+1;
            until KL>(NOI);
          end;
        end;
      end;
    until L>NOI;
  end;
  showpointer;
end;

procedure DECTIME;
begin
  CTT:=CTT+1;
  if CTT>300 then begin CTT:=0; TIMR:=TIMR-1; FLAGS[5]:=1; end;
end;

procedure TIMECHK;
begin
  IF NOI>0 then begin
    L:=0;
    CT:=CT+1;
    if CT>=1000 then begin
      CT:=0;
      repeat
        L:=L+1;
        TIME[L]:=TIME[L]+1;
        if TIME[L]>=TM then
          begin
            TIME[L]:=0;
            setfillstyle(1,black);
            hidepointer;
            MISSES:=MISSES+1;
            bar(POSS[L,1],POSS[L,2],POSS[L,1]+XS,POSS[L,2]+YS);
            showpointer;
            KL:=L;
            NOI:=NOI-1;
            repeat
              POSS[KL,1]:=POSS[KL+1,1]; POSS[KL,2]:=POSS[KL+1,2]; TIME[KL]:=TIME[KL+1];
              KL:=KL+1;
            until KL>(NOI);
          end;
      until L>=NOI;
    end;
  end;
end;

procedure NEWITEM;
Begin
  X:=random(639-XS);
  Y:=random(250-YS);
  FLAG:=0;
  L:=0;
  repeat
    L:=L+1;
    if L<=NOI then begin
      if ((X>=POSS[L,1]) and (X<=(POSS[L,1]+XS))) or (((X+XS)>=POSS[L,1]) and ((X+XS)<=(POSS[L,1]+XS))) or
         ((X<=POSS[L,1]) and ((X+XS)>=(POSS[L,1]+XS))) then begin
        if ((Y>=POSS[L,2]) and (Y<=(POSS[L,2]+YS))) or (((Y+YS)>=POSS[L,2]) and ((Y+YS)<=(POSS[L,2]+YS))) or ((Y<=POSS[L,2])
              and ((Y+YS)>=(POSS[L,2]+YS))) then FLAG:=1;
      end;
    end;
  until (L>=NOI) or (FLAG=1);

  if FLAG=0 then begin
    NOI:=NOI+1; TIME[NOI]:=0; POSS[NOI,1]:=X; POSS[NOI,2]:=Y; hidepointer; putimage(X,Y,P^,normalput); showpointer;
  End;
end;


procedure CHOOSE;
begin
  case level of
    1:begin P:=@HOSTAGE; RATE:=2; MAX:=5; TM:=35; XS:=240; YS:=160; SC:=5; end;
    2:begin P:=@PIG; RATE:=3; MAX:=10; TM:=35;XS:=82; YS:=101; SC:=10; end;
    3:begin P:=@PLAYER; RATE:=4; MAX:=15; TM:=30;XS:=70; YS:=70; SC:=15; end;
    4:begin P:=@BARN; RATE:=4; MAX:=15; TM:=30;XS:=80; YS:=75; SC:=15; end;
    5:begin P:=@FISH2; RATE:=6; MAX:=20; TM:=25 ;XS:=70; YS:=40; SC:=20; end;
    6:begin P:=@BUS; RATE:=6; MAX:=20; TM:=25;XS:=75; YS:=35; SC:=20; end;
    7:begin P:=@CHICKEN; RATE:=8; MAX:=25; TM:=20;XS:=65; YS:=80; SC:=15; end;
    8:begin P:=@CACTUS;RATE:=8; MAX:=25; TM:=20; XS:=32; YS:=45; SC:=25; end;
    9:begin P:=@DINO; RATE:=10; MAX:=30; TM:=20;XS:=75; YS:=75; SC:=10; end;
    10:begin P:=@FISH1; RATE:=10; MAX:=30; TM:=20;XS:=75; YS:=25; SC:=20; end;
    11:begin P:=@FROG; RATE:=15; MAX:=35; TM:=20;Xs:=45; YS:=55; SC:=30; end;
    12:begin P:=@LADYBIRD; RATE:=15; MAX:=40; TM:=25;XS:=35; YS:=35; SC:=60; end;
  end;
end;

Procedure Game_Complete;
begin
  HidePointer;
  HI_CHECK;
  settextjustify(centertext,centertext);
  settextstyle(10,0,10);
  CTR:=0;
  repeat
    setcolor(random(15)); outtextxy(320,90,'Yes!'); Inc(CTR);
  until (CTR>200) or (keypressed);
  setfillstyle(1,black); bar(0,0,639,259);
  settextstyle(7,0,4);   setcolor(lightcyan);
  outtextxy(320,30,'You have completely conquered the');
  setcolor(lightblue);  outtextxy(320,60,'SHOOTING CHEDDARY');
  setcolor(lightgreen);
  outtextxy(320,90,'That makes you one of the most');
  setcolor(Andy);
  outtextxy(320,120,'alert and quick people in the world');
  setcolor(brown);
  outtextxy(320,150,'However, resign to the fact that you');
  setcolor(red);
  outtextxy(320,180,'will never attain the level of the');
  setcolor(lightred);
  outtextxy(320,210,'TOP GUNNER, whose reactions, and');
  setcolor(lightmagenta);
  outtextxy(320,240,'degree of alertness is unbeatable.....');
  setpointer(pCPG);
  showpointer;
  repeat
    if keypressed then repeat until readkey<>'';
  until not keypressed;
  repeat
    mouseinfo;
  until (keypressed) or (mouse.left) or (mouse.right);
  cleardevice;
  closegraph;
  clrscr;
  halt;
end;

begin
  findfirst('hitable.dat',anyfile,dirinfo);
  if doserror<>0 then begin
    Hi_Names[1]:='Chris'; Hi_Names[2]:='Wes'; Hi_Names[3]:='Tom';
    Hi_Names[4]:='Andy'; Hi_Names[5]:='Merrick';
    Hi_Scores[1]:=80; Hi_Scores[2]:=70;  Hi_Scores[3]:=60;
    Hi_Scores[4]:=50; Hi_Scores[5]:=40; WriteHi;
  end;

  level_name[1]:='Hostage Zone'; level_name[2]:='Pigs for prizes';
  level_name[3]:='Football Freak';level_name[4]:='Barn Busting';
  level_name[5]:='Something Fishy'; level_name[6]:='None for an hour then...';
  level_name[7]:='Chicken Tonight'; level_name[8]:='Prickly Problem';
  level_name[9]:='Jurassic Chedder';level_name[10]:='Nowhere is safe';
  level_name[11]:='Flying frogs'; level_name[12]:='Infestation';

  if paramstr(1)='/EGA' then begin GD:=ega; GM:=egahi; end
  else begin GD:=vga; GM:=vgamed; end;

  NOI:=0;  MISSES:=0;  CTT:=0;  CTR:=0;  CT:=0;  LEVEL:=1;
  font2;
  font5;
  font6;
  font7;
  font8;
  font10;
  egavga;
  initgraph(GD,GM,'');
  if graphresult<>grok then graphics_error;
  setfillstyle(1,black); bar(200,200,284,301);
  randomize; Initmouse; showpointer; readhi;
  repeat
    repeat
      TITLE;
    until FLAGS[7]=0;

    CT:=0; Hidepointer;  cleardevice; XX:=0;
    setpointer(pCross); showpointer;
    repeat
      SCREEN; SHOW_LEVELNAME;
      MISSES:=0; HITS:=0; CHEDDERS:=150; PEANUTS:=200;
      setmousexlimits(2,637); setmouseylimits(2,258);
      FLAGS[4]:=0; FLAGS[6]:=1;
      CHOOSE;
      TIMR:=510;

      repeat
        for abb:=1 to 75 do begin
          RNA:=random({333}20000);
          if (RNA<RATE) and (NOI<MAX) then NEWITEM;
          TIMECHK; DECTIME;
        end;
        Vwait; mouseinfo; updatestatus;
        if (MOUSE.LEFT) or (MOUSE.RIGHT) then SHOOT;
        if CTR<2 then Inc(CTR);
        if CTR=2 then begin CTR:=3; FLAGS[4]:=0; end;
        if keypressed then if readkey=chr(27) then begin timr:=0; jury:=7; end;
      until (TIMR<=0);

      hidepointer;
      setfillstyle(1,black); bar(0,0,639,260);
      showpointer;

      if JURY<>7 then begin
        JURY:=0;
        if HITS>MISSES then Inc(JURY);
        if SHOTS-MISSES>(LEVEL) then Inc(JURY);
        if MISSES<(LEVEL*2) then Inc(JURY);
        if SHOTS<RATE then JURY:=0;
        if FLAGS[8]=1 then JURY:=4;
      end;
      if JURY=7 then JURY:=0;
      if (JURY>=3) then begin
        Inc(LEVEL);
        if (LEVEL<=12) then begin
          HIDEPOINTER;
          settextjustify(centertext,centertext);
          settextstyle(10,0,4); setcolor(Andy); outtextxy(320,20,'You passed!');
          settextstyle(5,0,7); setcolor(lightcyan); outtextxy(320,100,'Click for next level'); SHOWPOINTER;
          DELAY(500);
          repeat
            mouseinfo;
          until (mouse.left) or (mouse.right) or (keypressed);
          if keypressed then begin
            if readkey='*' then Score:=Score+(Level*1000);
          end;
        end;
        if LEVEL>12 then Game_Complete;
      end;
      hidepointer;
      setfillstyle(1,black); bar(0,0,639,259);
      setcolor(Andy);
      settextjustify(centertext,centertext);
      settextstyle(10,0,7);
      CTR:=0;
      if JURY<3 then begin
        PEANUTS:=0;  CHEDDERS:=0;
        FLAGS[1]:=1; FLAGS[2]:=1; FLAGS[3]:=1; FLAGS[5]:=1; FLAGS[6]:=1;
        updatestatus;
        settextjustify(centertext,centertext); settextstyle(10,0,7);
        repeat
          CTR:=CTR+1;
          setcolor(random(15));
          outtextxy(320,60,'GAME'); outtextxy(320,170,'OVER!');
        until (CTR>200) or (keypressed);
      end;
      showpointer;
    until jury<3;
    hidepointer; cleardevice;
    HI_CHECK; SHOW_HISCORES;
    cleardevice; ShowPointer;
  until false;
End.
