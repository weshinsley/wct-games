Program Slap2;
uses crt,graph,egavgain;
var
   gm,gd: integer;
   add: longint;
   a,b,c,d,e,f,g: byte;
   x,y,z,w,u: longint;
   mems: array[0..1000,0..15] of byte;
   ch: char;
begin
     tdfinit;
     gd:=vga; gm:=vgamed; initgraph(gd,gm,'');
     cleardevice;
     setcolor(white); setfillstyle(1,255);
setvisualpage(0);
{     bar(0,0,639,1);}
line(0,0,639,0);
{     line(0,349,640,349);
{     setcolor(white);}
{     line(0,0,640,0);
     {setbkcolor(black);}
{     cleardevice;}
{     line(0,0,0,10);}
     repeat until keypressed;
     add:=59080{<$a000}{-1750}{+1267}{round((640*350)/8/16)-5};  {a000=40960, 42710}

{z:=0;
for x:=$0000 to $ffff do begin
for y:=$00 to $0f do begin
if mem[x:y]=0 then z:=0;
if mem[x:y]=255 then inc(z);
if z>(640*350/8) then halt(0);
end; end;}


     for x:=0 to 1000 do begin
     for y:=0 to 15 do mems[x,y]:=mem[add+x:$00+y]; end;
     closegraph;
     for x:=0 to 1000 do begin
     for y:=0 to 15 do begin
     {if mems[x,y]<>255 then} begin writeln(x+add,':',y,' ',mems[x,y]);
     {ch:=readkey;}delay(0); end; end; end;


end.