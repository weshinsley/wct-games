Program Slap;
uses crt,graph,mouseRMW,{u_vga,}TDgraph;
var
  l,num_graphics,xpos,ypos,old_xpos,old_ypos,mez_wid,mez_len: integer;
  background_colour,score,level,energy,dist,x_mov,scr_val,fine: integer;
  grnum,new2,new4,new5,a,gnum,gx,gy,gw,gl,gm,gd,code,b: integer;
  hi_text,hi_text2,s_score,s_level: string;
  graphics: array[1..12{<<<num_graphics>>>},1..10] of integer;
  graphics_data: array[1..12{<<<num_graphics>>>},1..10,1..10] of integer;
  P_mez: pointer;
  level_data: array[1..12,1..10] of integer;
  flags: array[1..10] of integer;
  f: text;
  sl: file;
  hi_scores: array[1..6] of longint;
  hi_names: array[1..6] of string[50];
  s_hi_scores: array[1..6] of string[20];
  ch: char;
   hxp,hyp,hxs,hys: array[1..6] of longint;
   hinumber,maxx,maxy,minx,miny,mulx,muly: longint;
   x,i,jjj : byte;
   sze,szd: integer;
   stars: array[1..500,1..3] of longint;
   v,w,u: longint;
   tt,tinc: real;


{const: graphics_data[level,graphicnumber,1-wid,2-len]
        level_data[level,...]}

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

Procedure TDvw; assembler;
  asm
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwt

    @@nextv:
    in      ax,dx
    and     ax,8
    or      ax,ax
    jnz     @@nextv

    @@vwt:
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwt
  end;


Procedure Vwait; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;
Procedure load_hi_scores;
begin
  assign(f,'C:\SLAPTAB.DAT');
  reset(f);
  for a:=1 to 6 do begin
    readln(f,hi_names[a]);
    readln(f,s_hi_scores[a]);
    Val(s_hi_scores[a],hi_scores[a],code);
    end;
  close(f);
end;

Procedure save_hi_scores;
begin
  assign(f,'C:\SLAPTAB.DAT');
  rewrite(f);
  for a:=1 to 6 do begin
    writeln(f,hi_names[a]);
    writeln(f,s_hi_scores[a]);
    end;
  close(f);
end;


Function check_crash(x1,y1,w1,l1,x2,y2,w2,l2: integer): boolean;
begin
  check_crash:=false;

  if ( (y1 <= y2) and ( (y1+l1) >= y2 ) )
    or ( ( y1 <= (y2+l2) ) and ( (y1+l1) >= (y2+l2) ) ) then begin
  if ( (x1 <= x2) and ( (x1+w1) >= x2 ) )
    or ( ( x1 <= (x2+w2) ) and ( (x1+w1) >= (x2+w2) ) ) then check_crash:=true;
  end;

end;

Procedure erase_mez;
begin
  setfillstyle(1,black); bar(old_xpos,old_ypos,xpos+mez_wid,ypos+mez_len);
end;

Procedure draw_mez;
begin
  putimage(xpos,ypos,P_mez^,normalput);
end;

Procedure sroll_up(no_lines: integer);
var
  dest:word;
begin
  dest:=$100*no_lines;
  {call gfxfx2 procedure}
  setfillstyle(1,background_colour);
  bar(0,320-no_lines,320,320);
end;

Procedure status_update;
var
  s_score: string;
begin
  str(score,s_score);
  outtextxy(10,1,'SCORE:');
  outtextxy(50,1,s_score);
  outtextxy(150,1,'ENERGY:');
  setfillstyle(1,lightmagenta);
  bar(200,1,energy,19);
end;

Procedure check_distance;
begin
  inc(dist);
  if dist>(1000{level_data[1,1]}) then flags[1]:=1;
end;

Procedure get_keys;
var
  ch: char;
begin
  old_xpos:=xpos; old_ypos:=ypos;
  if keypressed then begin
  ch:=readkey;
  if ch=chr(27) then flags[3]:=1; {quit}
  if ((ch='o') and (xpos>x_mov)) then xpos:=xpos-x_mov;
  if (ch='p') and (xpos<6400-x_mov) then xpos:=xpos+x_mov;
end; end;

Procedure graphics_loop;
var
  rand_num,aa: integer;
begin
  for aa:=1 to scr_val do begin
  inc(fine); if fine>level_data[level,2] then begin
    fine:=fine-level_data[level,2]; flags[4]:=1;
    {new graphic!} inc(grnum);
    rand_num:=round(int(random*level_data[level,{pr}1]))+1;
    if rand_num<6 then begin graphics[grnum,1]:=rand_num;
      new2:=round(int(random*(320-graphics_data[level,rand_num,1{xpos}])));
      graphics[grnum,2]:=new2;
      new4:=graphics_data[level,rand_num,1{width}];
      graphics[grnum,4]:=new4;
      new5:=graphics_data[level,rand_num,2{length}];
      graphics[grnum,5]:=new5;
      graphics[grnum,3]:=320;
    end;


  for a:=1 to num_graphics do begin
  gnum:=graphics[a,1]; if gnum<>0 then begin
  gx:=graphics[a,2]; gy:=graphics[a,3];
  gw:=graphics[a,4]; gl:=graphics[a,5];
  if (flags[4]=1) and (a<>grnum) and (gnum<10) then begin
  if check_crash(gx,gy,gw,gl,new2,320,new4,new5) then begin

{    if ((gy+gl)>319) and (((gx<new2) and ((gx+gw)>new2)) or
      ((gx<(new2+new4)) and ((gx+gw)>(new2+new4))) then begin}
      flags[4]:=0; graphics[grnum,1]:=0; end; end; {}end;{}


  graphics[a,3]:=gy;
  {check fire, crash, update pictures, add new pictures}
end; end; end; {end of aa}
end;

Procedure game_loop;
begin
for a:=1 to num_graphics do graphics[a,1]:=0;
for a:=1 to 10 do flags[a]:=0;
energy:=200;
grnum:=1;
xpos:=320;
old_xpos:=320;
old_ypos:=150;
ypos:=150;
level:=1;
dist:=0; x_mov:=10;
gd:=vga; gm:=vgamed; initgraph(gd,gm,'c:\exe');
cleardevice;
{initgraph for u_vga 256col}


settextstyle(2,0,5); settextjustify(lefttext,toptext);
str(level,s_level);
scr_val:=10+10*level;

repeat
  erase_mez; {scroll_up(scr_val);}
{  graphics_loop;}
  draw_mez; status_update;
  check_distance; get_keys;
until (flags[2]=1) or (energy<1) or (flags[3]=1); {win, die, quit}
end;

Procedure Title_Defaults;
begin
tt:=0; tinc:=pi/19; i:=1;
jjj:=0;
settextjustify(centertext,centertext);
settextstyle(2,horizdir,6);
setvisualpage(0);
setactivepage(1);
{tdborder(lightblue);}
setbkcolor(blue);
v:=320;
i:=0;
tinc:=20;
tt:=20;
end;


Procedure title_screen;
begin
  repeat
  repeat
    if (tt<0) or (tt>200) then tinc:=-tinc;
    jjj:=1-jjj;
    setactivepage(jjj);
    tt:=tt+tinc;
{    w:=290+round(sin(tt)*40);}
{    u:=round(sin(tt*2)*300);}

{    settextjustify(centertext,centertext);
    setcolor(red);
    settextstyle(5,horizdir,3);
    setusercharsize(16,10,10,10);
{    setfillpattern(fa[i],lightmagenta);}
{    bar(0,0,640,350);
{    outtextxy(320,240,'by Tom and Wes');
    settextstyle(10,horizdir,7);
    if jjj=0 then setcolor(lightcyan) else setcolor(magenta);
    outtextxy(320,280,'WaistWear');
    setfillstyle(1,yellow);
    bar(0,w-8,640,w+12);
    setcolor(red);
    line(0,w-8,640,w-8);
    line(0,w+12,640,w+12);
    mouseinfo;
    setcolor(lightmagenta);
    settextstyle(2,horizdir,6);
    outtextxy(v,w,'Click: left to start, right for hi-scores, press [ESC] to quit');
    setcolor(WHITE);
    settextstyle(7,horizdir,5);
    setusercharsize(3,1,abs(u),100);
    if u>0 then settextjustify(centertext,bottomtext) else
    settextjustify(centertext,toptext);
    outtextxy(320,60,'Shooting');
    if u<0 then settextjustify(centertext,bottomtext) else
    settextjustify(centertext,toptext);
    outtextxy(320,170,'Chundery');}
    tdvw;
    setvisualpage(jjj);
    cleardevice;
    settextstyle(7,horizdir,5);
    setusercharsize(round(tt),80,round(tt),120);
    setcolor(lightmagenta);
    outtextxy(320,20,'Slapping');
    setusercharsize(300-round(tt),80,300-round(tt),120);
    setcolor(lightgreen);
    outtextxy(320,70,'Slappery');

    settextstyle(5,horizdir,3);
    setusercharsize(round(u/2),80,1,1);
    setcolor(lightred);
{    outtextxy(320,200,'by Tom, Chris and Wes');}


  mouseinfo;
  until (keypressed) or (mouse.left) or (mouse.right);
  if keypressed then ch:=readkey;
  if mouse.left then ch:='s';
  if mouse.right then ch:='h';
  until (ch='h') or (ch='s') or (ch=chr(27));
end;

Procedure Hi_setup;
begin
  setbkcolor(black); cleardevice;
  hi_text:='Hi-scores'; hi_text2:='Waistwear';
  hinumber:=0;
  setfillstyle(1,0);
  a:=0;
  repeat
    inc(a);
    stars[a,1]:=round(random*640);
    stars[a,2]:=round(random*350);
    stars[a,3]:=round(random*20)+1;
  until a>=500;
  a:=0;
  repeat
    inc(a);
    hxp[a]:=30*(7-a); hyp[a]:=20*(7-a);
    hxs[a]:=10; hys[a]:=10;
  until a>=6;
  settextstyle(9,0,8);
  settextjustify(centertext,toptext);
  x:=0; sze:=14; szd:=-1;
  maxx:=580; maxy:=330;
  minx:=70; miny:=0;
  mulx:=-1; muly:=-1;
end;


Procedure view_hi_scores;
begin
  repeat {<<<}
    x:=1-x;
    setactivepage(x);
    a:=0;
    sze:=sze+szd;
    if sze<-14 then szd:=1;
    if sze>14 then szd:=-1;
    repeat
      inc(a);
      stars[a,1]:=stars[a,1]+(stars[a,3]*mulx);
      stars[a,2]:=stars[a,2]+(stars[a,3]*muly);
      if stars[a,1]<1 then stars[a,1]:=639;
      if stars[a,1]>639 then stars[a,1]:=1;
      if stars[a,2]<1 then stars[a,2]:=349;
      if stars[a,2]>349 then stars[a,2]:=1;
    until (a>=100);
a:=0;
    repeat
      inc(a);
      hxp[a]:=hxp[a]+hxs[a];
      hyp[a]:=hyp[a]+hys[a];
      if hxp[a]<minx then begin hxp[a]:=minx-(hxp[a]-minx); hxs[a]:=-hxs[a];
        if a=1 then mulx:=-mulx; end;
      if hyp[a]<miny then begin hyp[a]:=miny-(hyp[a]-miny); hys[a]:=-hys[a];
        if a=1 then muly:=-muly; end;
      if hxp[a]>maxx then begin hxp[a]:=maxx-(hxp[a]-maxx); hxs[a]:=-hxs[a];
        if a=1 then mulx:=-mulx; end;
      if hyp[a]>maxy then begin hyp[a]:=maxy-(hyp[a]-maxy); hys[a]:=-hys[a];
        if a=1 then muly:=-muly; end;
    until (a>=6);
a:=0;
TDvw;
cleardevice;
repeat
inc(a);
      putpixel(stars[a,1],stars[a,2],white);
      if (a<7) then begin
      if (a=hinumber) or (hinumber=0) then setcolor(15-a) else setcolor(lightgray);
      setusercharsize(10+(7-a),25,10,30);
      outtextxy(hxp[a],hyp[a],hi_names[a]+' '+s_hi_scores[a]);
      end;
    until (a>=100);
    setcolor(lightgreen);
    if sze>=0 then begin setusercharsize(4*sze,50,30,30);
    outtextxy(320,120,hi_text); end else begin
    setusercharsize(4*(-sze),50,30,30); outtextxy(320,120,hi_text2);
    end;
{    TDvw;}
    setvisualpage(x);


  until (keypressed) or (mouse.left) or (mouse.right);
end;

procedure game_over;
begin
end;

Function input_hi_name: string;
var
  hin: string;
  c: char;
begin
  hi_text:='New hi-score'; hi_text2:='Enter your name';
  hin:='';
repeat
  repeat
  hi_names[hinumber]:=hin+'<';
  view_hi_scores;
  until keypressed;
  c:=readkey;
if (c>=' ') and (c<='}') and (length(hin)<50) then hin:=hin+c;
if (c=chr(8)) and (length(hin)>1) then hin:=copy(hin,1,length(hin)-1);
until c=chr(13);
input_hi_name:=hin;
  hi_text:='Hi-scores'; hi_text2:='Waistwear';
end;

Procedure Check_hi_scores;
begin
  hinumber:=0; flags[10]:=0;
  repeat
    inc(hinumber);
    if score>hi_scores[hinumber] then begin
      flags[10]:=1;
      if hinumber<6 then begin
        for b:=6 downto hinumber+1 do begin
          hi_names[b]:=hi_names[b-1];
          s_hi_scores[b]:=s_hi_scores[b-1];
          hi_scores[b]:=hi_scores[b-1];
          end;
        end;
      hi_scores[hinumber]:=score;
      Str(score,s_hi_scores[hinumber]);
      hi_names[hinumber]:=input_hi_name;
      save_hi_scores;
      hinumber:=0;
      end;
  until (hinumber>5) or (flags[10]<>0);
end;


{program loop}
begin
  gd:=vga; gm:=vgamed; initgraph(gd,gm,'p:\tp\bgi');
  setbkcolor(black); cleardevice;
  load_hi_scores;
  title_defaults;
  assign(sl,'n:\slap\tinyslap.bin');
  reset(sl,1);
  getmem(P_mez,filesize(sl));
  blockread(sl,P_Mez^,filesize(sl));
  close(sl);
{  ch:='s';}

repeat
  title_screen;
  if ch='h' then begin
    hi_setup;
    view_hi_scores;
    cls;
    ch:='h';
    end;
  if ch='s' then begin
{    game_loop;}
     score:=4000;
{    game_over;}
    hi_setup;
    check_hi_scores;
    view_hi_scores;
    cls;
    ch:='s';
    end;
until ch=chr(27);
closegraph;
textcolor(lightmagenta);
textbackground(black);
clrscr;
writeln('(C) Waistwear June 1995: Tom, Wes, Chris.');
textcolor(lightgray);
halt(0);
end.
                                                                     