Program Slap;
uses crt,graph,mouseRMW,u_vga;
var
  num_graphics,xpos,ypos,old_xpos,old_ypos,mez_wid,mez_len: integer;
  background_colour,score,level,energy,dist,x_mov,scr_val,fine: integer;
  grnum,new2,new4,new5,a,gnum,gx,gy,gw,gl,gm,gd: integer;
  s_score,s_level: string;
  graphics: array[1..12{<<<num_graphics>>>},1..10] of integer;
  graphics_data: array[1..12{<<<num_graphics>>>},1..10,1..10] of integer;
  P_mez: pointer;
  level_data: array[1..12,1..10] of integer;
  flags: array[1..10] of integer;
{const: graphics_data[level,graphicnumber,1-wid,2-len]
        level_data[level,...]}


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
{  putimage(xpos,ypos,^P_mez,normalput);}
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
  if dist>(level_data[1,1]) then flags[1]:=1;
end;

Procedure get_keys;
var
  ch: char;
begin
  old_xpos:=xpos; old_ypos:=ypos;
  if keypressed then begin
  ch:=readkey;
  if ch=chr(27) then flags[3]:=1; {quit}
  if ((ch=chr(8)) and (xpos>x_mov)) then xpos:=xpos-x_mov;
  if (ch=chr(9)) and (xpos<320-x_mov) then xpos:=xpos+x_mov;
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

begin
for a:=1 to num_graphics do graphics[a,1]:=0;

grnum:=1;
xpos:=320;
old_xpos:=320;
old_ypos:=150;
ypos:=150;
level:=1;
dist:=0;
gd:=vga; gm:=vgamed; initgraph(gd,gm,'');
{initgraph for u_vga 256col}


settextstyle(2,0,5); settextjustify(lefttext,toptext);
str(level,s_level);
scr_val:=10+10*level;

repeat
  erase_mez; {scroll_up(scr_val);}
  graphics_loop;
  draw_mez; status_update;
  check_distance; get_keys;
until (flags[2]=1) or (energy<1) or (flags[3]=1); {win, die, quit}



end.                                                                   