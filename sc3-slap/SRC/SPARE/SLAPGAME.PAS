Program SlapGame;
uses dos,crt,graph,mouseRMW;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal : Integer;
    Colornum: integer;
    end;
  Level_type= record
       Speed,Background_colour,Prob_gfx,Prob_per,num_gfx: integer;
       Length: Longint; Track: integer; Title: String[15];
    end;
  Gfx_Type= record
       Exist: Boolean; numb,xp,yp,wid,hei,xmov: integer; end;
    Graphics_type= record
       Exist,XMove: Boolean; Width,Height,XMDir: integer; name: string; end;
  Fade_Type= record
       Rval,Gval,Bval,Rinc,Binc,Ginc: real end;

var
   level,energy,gm,gd,xpos,ypos,a,b,xinc,dist,page,gwait: integer;
   s_level,s_score: string;
   P: array[0..9] of pointer;
   Ex: array[1..6] of pointer;
   SL: pointer;
   f: file;
   c: char;
   score,memseg,memofs,size: longint;
   Moveleft,Moveright,Quit: Boolean;
   flags: array[1..10] of boolean;
   graphix: array[1..10] of gfx_type;
   t1,t2,t3,t4,m1,m2: integer;
   cs: array[0..15] of fade_type;
   d,e,megaslaps,slapometer{,sizeEXx,sizeEXy}: integer;
   KbdIntVec: pointer;
Const
  sizeEXx=209; sizeEXy=134;
  Win_Colours : array[0..15] of RGBRec = (
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 0),
   ( RedVal:31;GreenVal:0;BlueVal:0;ColorNum: 1),
   ( RedVal:0;GreenVal:31;BlueVal:0;ColorNum: 2),
   ( RedVal:31;GreenVal:31;BlueVal:0;ColorNum: 3),
   ( RedVal:0;GreenVal:0;BlueVal:31;ColorNum: 4),
   ( RedVal:31;GreenVal:0;BlueVal:31;ColorNum: 5),
   ( RedVal:0;GreenVal:31; BlueVal:31;ColorNum: 6),
   ( RedVal:31;GreenVal:31;BlueVal:31;ColorNum: 7),
   ( RedVal:47;GreenVal:47;BlueVal:47;ColorNum: 8),
   ( RedVal:63;GreenVal:0;BlueVal:0;ColorNum: 9),
   ( RedVal:0;GreenVal:63;BlueVal:0;ColorNum: 10),
   ( RedVal:63;GreenVal:63;BlueVal:0;ColorNum: 11),
   ( RedVal:0;GreenVal:0;BlueVal:63;ColorNum: 12),
   ( RedVal:63;GreenVal:0;BlueVal:63;ColorNum: 13),
{   ( RedVal:0;GreenVal:63;BlueVal:63;ColorNum: 14),}
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:63;ColorNum: 15));


   Level_data: array[1..6] of level_type=
   ((Speed:2;Background_colour:7;Prob_gfx:25;Prob_per:1;num_gfx:7;
        Length:2000;Track:2;Title:'Urban Zone'),
   (Speed:4;Background_colour:11;Prob_gfx:50;Prob_per:1;num_gfx:5;
        Length:3000;Track:4;Title:'Desert Zone'),
   (Speed:6;Background_colour:6;Prob_gfx:75;Prob_per:2;num_gfx:5;
        Length:4000;Track:6;Title:'Sky Zone'),
   (Speed:22;Background_colour:3;Prob_gfx:100;Prob_per:2;num_gfx:7;
        Length:5000;Track:8;Title:'Forest Zone'),
   (Speed:26;Background_colour:4;Prob_gfx:125;Prob_per:3;num_gfx:5;
        Length:6000;Track:10;Title:'Sea Zone'),
   (Speed:30;Background_colour:15;Prob_gfx:150;Prob_per:3;num_gfx:5;
        Length:7000;track:12;Title:'Arctic Zone'));


   Graphics_data: array[1..6,0..9] of graphics_type={0=Mez, 1,2_per, 3-9-gfx}
   (((Exist:True;XMove:True;Width:84;Height:128;XMDir:0;Name:'Urb_mez'),
   (Exist:True;XMove:True;Width:82;Height:112;XMDir:0;Name:'Urb_Oz'),
   (Exist:True;XMove:True;Width:92;Height:129;XMDir:0;Name:'Urb_Chr'),
   (Exist:True;XMove:False;Width:77;Height:133;XMDir:0;Name:'Urb_Off'),
   (Exist:True;XMove:False;Width:98;Height:77;XMDir:0;Name:'Urb_Hous'),
   (Exist:True;XMove:False;Width:66;Height:64;XMDir:0;Name:'Urb_Cat'),
   (Exist:True;XMove:True;Width:55;Height:63;XMDir:0;Name:'Urb_Dog'),
   (Exist:True;XMove:True;Width:144;Height:47;XMDir:-1;Name:'Urb_Car'),
   (Exist:True;XMove:False;Width:47;Height:62;XMDir:0;Name:'Urb_Plan'),
   (Exist:True;XMove:True;Width:192;Height:59;XMDir:-1;Name:'Urb_Bus')),

   ((Exist:True;XMove:True;Width:89;Height:128;XMDir:0;Name:'Des_mez'),
   (Exist:True;XMove:True;Width:90;Height:116;XMDir:0;Name:'Des_Wes'),
   (Exist:True;XMove:True;Width:90;Height:118;XMDir:0;Name:'Des_Jef'),
   (Exist:True;XMove:False;Width:165;Height:75;XMDir:0;Name:'Des_Pyr'),
   (Exist:True;XMove:False;Width:126;Height:70;XMDir:0;Name:'Des_Rock'),
   (Exist:True;XMove:False;Width:72;Height:88;XMDir:0;Name:'Des_Cac'),
   (Exist:True;XMove:False;Width:98;Height:125;XMDir:0;Name:'Des_Sand'),
   (Exist:True;XMove:False;Width:64;Height:113;XMDir:0;Name:'Des_Tree'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:96;Height:127;XMDir:0;Name:'Sky_Mez'),
   (Exist:True;XMove:True;Width:97;Height:118;XMDir:0;Name:'Sky_Stu'),
   (Exist:True;XMove:True;Width:95;Height:117;XMDir:0;Name:'Sky_Ben'),
   (Exist:True;XMove:True;Width:253;Height:103;XMDir:-1;Name:'Sky_Plan'),
   (Exist:True;XMove:True;Width:137;Height:51;XMDir:0;Name:'Sky_Cld'),
   (Exist:True;XMove:True;Width:210;Height:63;XMDir:0;Name:'Sky_Clds'),
   (Exist:True;XMove:True;Width:156;Height:83;XMDir:0;Name:'Sky_Bird'),
   (Exist:True;XMove:True;Width:92;Height:145;XMDir:0;Name:'Sky_Kite'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:88;Height:126;XMDir:0;Name:'For_Mez'),
   (Exist:True;XMove:True;Width:88;Height:122;XMDir:0;Name:'For_Wes'),
   (Exist:True;XMove:True;Width:89;Height:124;XMDir:0;Name:'For_Gaz'),
   (Exist:True;XMove:False;Width:166;Height:60;XMDir:0;Name:'For_Gras'),
   (Exist:True;XMove:False;Width:172;Height:65;XMDir:0;Name:'For_Grs2'),
   (Exist:True;XMove:False;Width:164;Height:84;XMDir:0;Name:'For_Tree'),
   (Exist:True;XMove:False;Width:84;Height:109;XMDir:0;Name:'For_Tre2'),
   (Exist:True;XMove:True;Width:68;Height:68;XMDir:0;Name:'For_Spid'),
   (Exist:True;XMove:True;Width:66;Height:64;XMDir:-1;Name:'For_Sqr'),
   (Exist:True;XMove:False;Width:120;Height:96;XMDir:0;Name:'For_Leav')),

   ((Exist:True;XMove:True;Width:103;Height:106;XMDir:0;Name:'Sea_Mez'),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Tom'),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Chr'),
   (Exist:True;XMove:True;Width:115;Height:79;XMDir:-1;Name:'Sea_Fish'),
   (Exist:True;XMove:True;Width:215;Height:76;XMDir:0;Name:'Sea_Shar'),
   (Exist:True;XMove:False;Width:262;Height:135;XMDir:0;Name:'Sea_Ship'),
   (Exist:True;XMove:True;Width:80;Height:100;XMDir:0;Name:'Sea_jell'),
   (Exist:True;XMove:False;Width:135;Height:75;XMDir:0;Name:'Sea_Tres'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:107;Height:171;XMDir:0;Name:'Arc_Mez'),
   (Exist:True;XMove:True;Width:109;Height:169;XMDir:0;Name:'Arc_Ed'),
   (Exist:True;XMove:True;Width:107;Height:169;XMDir:0;Name:'Arc_Ben'),
   (Exist:True;XMove:False;Width:181;Height:72;XMDir:0;Name:'Arc_Peak'),
   (Exist:True;XMove:False;Width:167;Height:95;XMDir:0;Name:'Arc_Tent'),
   (Exist:True;XMove:False;Width:62;Height:106;XMDir:0;Name:'Arc_Tree'),
   (Exist:True;XMove:False;Width:151;Height:90;XMDir:0;Name:'Arc_Iglo'),
   (Exist:True;XMove:False;Width:128;Height:70;XMDir:0;Name:'Arc_Rock'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')));

Procedure Vwait; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;



Procedure Windows_colours;
var
   i:integer;
begin
for i := 0 to 15 do
  with Win_Colours[i] do
    begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
    setpalette(i,i); end;
end;

Procedure Windows_colours2;
var
   i:integer;
begin
for i := 0 to 15 do
  with Win_Colours[i] do
    begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
{    setpalette(i,i);} end;
end;

Procedure Draw_Mez;
begin
     Putimage(xpos,ypos,P[0]^,orput);
end;

Procedure get_graphics(levnum: integer);
begin
     for a:=0 to 9 do begin
     if graphics_data[levnum,a].exist then begin
        Assign(f,'c:\slap\'+graphics_data[levnum,a].name+'.bin');
        reset(f,1);
        Getmem(p[a],filesize(f));
        Blockread(f,P[a]^,filesize(f));
        close(f);
     end;
     end;
end;

Procedure Stats_Update;
begin
     str(score,s_score);
     settextstyle(2,0,5); settextjustify(lefttext,centertext);
     setcolor(12);
     outtextxy(5,5,'LEVEL '+s_level+'          ENERGY:');
{     outtextxy(410,5,'DISTANCE:');
     outtextxy(155,20,'SLAPOMETER:');
     outtextxy(400,20,'MEGASLAPS:');}
     outtextxy(5,20,'SCORE: '+s_score);
     outtextxy(400,5,'MEGASLAPS:');
     outtextxy(127,20,'DISTANCE:');
     outtextxy(392,20,'SLAPOMETER:');
     setfillstyle(6,9);
     bar(200,2,200+round(1.5*energy),12);
     if slapometer>0 then bar(480,18,480+slapometer*15,28);
     if megaslaps>0 then bar(480,2,480+30*megaslaps,12);
     if dist<level_data[level].length then
        bar(200,18,350-round(150/level_data[level].length*dist),28);
{     if slapometer>0 then bar(250,18,250+slapometer*15,28);
     if megaslaps>0 then bar(480,18,480+30*megaslaps,28);
     if dist<level_data[level].length then
        bar(480,2,630-round(150/level_data[level].length*dist),12);}
end;

Procedure All_back_fade(fadeinto,numfads: integer);
begin
     setactivepage(page);
     setvisualpage(page);
     stats_update;
     setcolor(12);
     settextjustify(centertext,centertext);
     settextstyle(1,0,14);
     outtextxy(320,80,'GAME');
     outtextxy(320,180,'OVER');
     for b:=0 to 15 do begin
     cs[b].rval:=Win_colours[b].redval;
     cs[b].gval:=Win_colours[b].greenval;
     cs[b].bval:=win_colours[b].blueval;
     if b=0 then begin
     e:=level_data[level].background_colour;
     cs[b].rval:=Win_colours[e].redval;
     cs[b].gval:=Win_colours[e].greenval;
     cs[b].bval:=Win_colours[e].blueval; end;
     Setpalette(b,b);
     cs[b].rinc:=(Win_colours[fadeinto].RedVal-cs[b].rval)/numfads;
     cs[b].ginc:=(Win_colours[fadeinto].GreenVal-cs[b].gval)/numfads;
     cs[b].binc:=(Win_colours[fadeinto].BlueVal-cs[b].bval)/numfads; end;
     d:=0;
     repeat inc(d);
     Vwait;
     for b:=0 to 15 do begin
     if b<>fadeinto then
     setrgbpalette(b,round(cs[b].rval),round(cs[b].gval),round(cs[b].bval));
     cs[b].rval:=cs[b].rval+cs[b].rinc;
     cs[b].gval:=cs[b].gval+cs[b].ginc;
     cs[b].bval:=cs[b].bval+cs[b].binc;
     end;
     until d>=numfads+1;
     setbkcolor(fadeinto);
end;

Procedure back_fade(startcol,endcol,numfads: integer);
var
   ri,bi,gi,rn,bn,gn: real;
begin
     stats_update;
     setcolor(9);
     settextjustify(centertext,centertext);
     settextstyle(10,0,7);
     outtextxy(320,150,'GET READY!');
     rn:=Win_colours[startcol].redval;
     gn:=Win_colours[startcol].greenval;
     bn:=Win_colours[startcol].blueval;
     setrgbpalette(0,round(rn),round(gn),round(bn));
     Setpalette(0,0);
     ri:=(Win_colours[endcol].RedVal-rn)/numfads;
     gi:=(Win_colours[endcol].GreenVal-gn)/numfads;
     bi:=(Win_colours[endcol].BlueVal-bn)/numfads;
     b:=0;
     setvisualpage(page);
     repeat inc(b);
     Vwait;
     setrgbpalette(0,round(rn),round(gn),round(bn));
     rn:=rn+ri; bn:=bn+bi; gn:=gn+gi;
     until b>=numfads+1;
     setbkcolor(endcol);
end;


Procedure Clear_off_Slappa_we_dont_want_you_here;
begin
     ypos:=ypos+10;
     setactivepage(1-page); setvisualpage(page);
     cleardevice;
     Stats_update;
     settextstyle(7,0,4);
     settextjustify(centertext,centertext);
     setcolor(10);
     outtextxy(320,100,'Congratulations!');
     outtextxy(320,140,'You passed that level');
     Putimage(xpos,ypos-10,P[0]^,xorput);

     setvisualpage(1-page); setactivepage(page);
     cleardevice;
     Stats_update;
     settextstyle(7,0,4);
     settextjustify(centertext,centertext);
     setcolor(10);
     outtextxy(320,100,'Congratulations!');
     outtextxy(320,140,'You passed that level');
     Putimage(xpos,ypos,P[0]^,xorput);

     repeat
     ypos:=ypos+10;
     page:=(1-page);
     setactivepage(page);
     setvisualpage(1-page);
     Vwait;
     Putimage(xpos,ypos-20,P[0]^,xorput);
     if ypos<350 then Putimage(xpos,ypos,P[0]^,xorput);
     until ypos>=355;
     page:=1-page;
     Setactivepage(page);
     setvisualpage(1-page);
     cleardevice;
end;

Procedure Scroll_Mez_On;
begin
     ypos:=ypos-20;
     setactivepage(1-page); setvisualpage(page);
     cleardevice;
     Stats_update;
     settextstyle(3,0,4);
     settextjustify(centertext,centertext);
     setcolor(13);
     outtextxy(320,100,'Level '+s_level);
     outtextxy(320,140,level_data[level].title);
     Putimage(xpos,ypos+10,P[0]^,xorput);

     setvisualpage(1-page); setactivepage(page);
     cleardevice;
     Stats_update;
     settextstyle(3,0,4);
     settextjustify(centertext,centertext);
     setcolor(13);
     outtextxy(320,100,'Level '+s_level);
     outtextxy(320,140,level_data[level].title);
     Putimage(xpos,ypos,P[0]^,xorput);

     repeat
     ypos:=ypos-10;
     page:=(1-page);
     setactivepage(page);
     setvisualpage(1-page);
     Vwait;
     if ypos<335 then Putimage(xpos,ypos+20,P[0]^,xorput);
     Putimage(xpos,ypos,P[0]^,xorput);
     until ypos<=40;
     Page:=1-page;
     Setactivepage(page);
     setvisualpage(1-page);
     cleardevice;
end;

Procedure Free_mem_graphics;
begin
     for a:=0 to 9 do if graphics_data[level,a].exist then
         Freemem(p[a],sizeof(p[a]));
end;

Function check_crash(x1,y1,w1,l1,x2,y2,w2,l2: integer): boolean;
begin
  check_crash:=false;

  If ( x2<=(x1+w1) ) and ( (x2+w2)>=x1)
 and ( y2<=(y1+l1) ) and ( (y2+l2)>=y1) then check_crash:=true;

end;

Procedure Draw_Graphics;
begin
     for b:=1 to 10 do begin
     if graphix[b].exist then begin
        if graphix[b].numb<3 then begin
if graphix[b].xp<xpos then graphix[b].xp:=graphix[b].xp+level_data[level].track;
if graphix[b].xp>xpos then graphix[b].xp:=graphix[b].xp-level_data[level].track;
        end;
        graphix[b].xp:=graphix[b].xp+level_data[level].speed*graphix[b].xmov;
        graphix[b].yp :=graphix[b].yp-level_data[level].speed;
        if graphix[b].yp<0 then graphix[b].exist:=false
        else begin
        if graphix[b].numb>9 then begin
        if graphix[b].xp-round((sizeEXx-graphix[b].wid)/2)<=0 then
           putimage(0,graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);
        if graphix[b].xp>=(639-sizeEXx) then
           putimage(639-sizeEXx,
                graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);
        if (graphix[b].xp-round((sizeEXx-graphix[b].wid)/2)>0) and (graphix[b].xp<640-sizeEXx) then
           putimage(graphix[b].xp-round((sizeEXx-graphix[b].wid)/2),
                graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);

        inc(graphix[b].numb); if graphix[b].numb>15 then
             graphix[b].exist:=false; end
        else
        putimage(graphix[b].xp,graphix[b].yp,P[graphix[b].numb]^,orput);
        end;
     end; end;
end;

Procedure Check_Slap;
begin
     if (getpixel(mouse.x,mouse.y)+getpixel(mouse.x+m1,mouse.y)+
     getpixel(mouse.x+m1,mouse.y+m2)+getpixel(mouse.x,mouse.y+m2))>0 then begin
             b:=0; repeat inc(b);
             if graphix[b].exist and (graphix[b].numb<10) then begin
             if check_crash(mouse.x,mouse.y,m1,m2,graphix[b].xp,graphix[b].yp,
                graphix[b].wid,graphix[b].hei) then begin
                     {graphix[b].exist:=false;}
                     graphix[b].numb:=10; score:=score+20; end;
             end;
             until b>9;
        end;
end;

Procedure Check_Mez_Crash;
begin
     if (getpixel(xpos,ypos+t2)+getpixel(xpos+t1,ypos+t2)+
     getpixel(xpos+t3,ypos+t2)+getpixel(xpos+2*t3,ypos+t2)+
     getpixel(xpos,ypos+t4)+getpixel(xpos,ypos+2*t4)+
     getpixel(xpos+t1,ypos+t4)+getpixel(xpos+t1,ypos+2*t4))>0 then begin
             b:=0; repeat inc(b);
        if graphix[b].exist and (graphix[b].numb<10) then begin
             if check_crash(xpos,ypos,t1,t2,graphix[b].xp,graphix[b].yp,
                graphix[b].wid,graphix[b].hei) then begin
                     graphix[b].numb:=12;
                     {graphix[b].exist:=false;} energy:=energy-10; end;
        end;
             until b>9;
        end;
end;

Procedure New_Graphic;
begin
     flags[2]:=false; flags[3]:=false;
     if gwait>0 then gwait:=gwait-level_data[level].speed;
     if (gwait<1) and (dist<level_data[level].length-350) then begin
{     if (random*200)<level_data[level].prob_gfx then begin}
      IF random(10)<7 then begin
        flags[2]:=true; b:=0; repeat inc(b);
        if not graphix[b].exist then begin
           flags[3]:=true; graphix[b].exist:=true; graphix[b].xp:=random(640);
           graphix[b].yp:=350;
           graphix[b].numb:=3+random(level_data[level].num_gfx);
           graphix[b].wid:=graphics_data[level,graphix[b].numb].width;
           graphix[b].hei:=graphics_data[level,graphix[b].numb].height;
           gwait:=graphix[b].hei; graphix[b].xmov:=0;
           if graphics_data[level,graphix[b].numb].XMove
           then begin graphix[b].xmov:=round(int(random(5)))-2;
           if graphics_data[level,b].XMDir<>0 then
           graphix[b].xmov:=graphics_data[level,b].XMDir*abs(graphix[b].xmov);
           end; end;
        until (b>9) or (flags[3]);
     end {}else begin
  {   if (not flags[2]) and ((random*200)<level_data[level].prob_per) then begin}
        b:=0; repeat inc(b);
        if not graphix[b].exist then begin
           flags[3]:=true; graphix[b].exist:=true; graphix[b].xp:=random(640);
           graphix[b].yp:=350;
           graphix[b].numb:=1+random(2);
           graphix[b].wid:=graphics_data[level,graphix[b].numb].width;
           graphix[b].hei:=graphics_data[level,graphix[b].numb].height;
           gwait:=graphix[b].hei; graphix[b].xmov:=0;
           end;
        until (b>9) or (flags[3]);
     end; end;
end;

Procedure Game_loop;
begin
     page:=0;
     setactivepage(page); setvisualpage(1-page);
     level:=1;
     setbkcolor(4);
     cleardevice;
     ypos:=345;
     level:=0;
     repeat
     inc(level); slapometer:=0;
     str(level,s_level);
     xpos:=280; xinc:=10; dist:=0;
     back_fade(getbkcolor,level_data[level].background_colour,200);
     setbkcolor(level_data[level].background_colour);
     get_graphics(level);
     Scroll_Mez_on;
     for b:=1 to 10 do graphix[b].exist:=false;
     t1:=graphics_data[level,0].width; t2:=graphics_data[level,0].height;
     t3:=round(t1/3); t4:=round(t2/3);

     Repeat
     setactivepage(page);
     setvisualpage(1-page);
     page:=(1-page);
     dist:=dist+level_data[level].speed;
     mouseinfo;
     if mouse.left then begin if slapometer<1 then check_slap;
     if slapometer<10 then slapometer:=slapometer+2; {end;}
     if slapometer>10 then slapometer:=10; end
     else if slapometer>0 then dec(slapometer);

     if (mouse.right) and (megaslaps>0) then begin
     dec(megaslaps); for b:=1 to 10 do begin
        if (graphix[b].exist) and (graphix[b].numb<10) then begin
           graphix[b].numb:=10; score:=score+5; end;
        end; end;

     if keypressed then begin
          c:=readkey;
          if keypressed then c:=readkey;
          if c=' ' then dist:=level_data[level].length;
          if (ord(c)=75){(port[$60]=$4b)} and (xpos>20) then xpos:=xpos-20;
          if (ord(c)=77){(port[$60]=$4d)} and (xpos<(620-graphics_data[level,0].width)) then
             xpos:=xpos+20;
          if c=chr(27) then flags[1]:=true; end;
     Vwait;
     cleardevice;
     Draw_Graphics;
     Check_Mez_Crash;
     Draw_Mez;
     Stats_update;
     New_Graphic;
     Putimage(mouse.x,mouse.y,SL^,xorput);

     until (dist>level_data[level].length) or (flags[1]) or (energy<1);
if energy<1 then begin
for e:=3 to 7 do begin
     setactivepage(page);
     setvisualpage(1-page);
     page:=(1-page);
     dist:=dist+level_data[level].speed;
     Vwait;
     cleardevice;
     Draw_Graphics;
     New_graphic;
     if e<7 then begin
     if xpos-round((sizeEXx-graphics_data[level,0].width)/2)<=0 then
     Putimage(0,ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
     if xpos>=(639-sizeEXx) then
     Putimage(639-sizeEXx,ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
     if (xpos-round((sizeEXx-graphics_data[level,0].width)/2)>0) and (xpos<639-sizeEXx) then
     Putimage(xpos-round((sizeEXx-graphics_data[level,0].width)/2),
     ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
     end;
     Stats_update;
end;
     setactivepage(page);
     setvisualpage(1-page);
     page:=(1-page);
end;
     if dist>level_data[level].length then
        Clear_off_Slappa_we_dont_want_you_here;
     Free_mem_graphics;
until (flags[1]) or (energy<1) or
           ((level=6) and (dist>level_data[level].length));
end;

begin
randomize;
gd:=vga; gm:=vgamed; initgraph(gd,gm,'C:\exe');
initmouse; setmouselimits(0,0,610,349);
m1:=20; m2:=22;
assign(f,'c:\slap\slaphand.bin');
reset(f,1);
getmem(SL,filesize(f));
blockread(f,SL^,filesize(f));
close(f);
for b:=1 to 6 do begin
    str(b,s_score);
    assign(f,'c:\slap\slap_ex'+s_score+'.bin');
    reset(f,1);
    getmem(EX[b],filesize(f));
    blockread(f,EX[b]^,filesize(f));
    close(f);
end;
Windows_colours;
for a:=1 to 10 do flags[a]:=false;
score:=0; energy:=100; megaslaps:=5;
game_loop;

all_back_fade(4,12);
freemem(SL,sizeof(SL));
for b:=1 to 6 do freemem(EX[b],sizeof(ex[b]));
delay(100);
end.