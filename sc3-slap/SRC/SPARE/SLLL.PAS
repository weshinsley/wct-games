Program Slll;
uses crt,graph,tdgraph,u_vga;
var
   gm,gd,scrn: integer;
   ch:char;
procedure moveup; assembler;
asm
  push ds
  mov es,u_vidseg
  mov ds,u_vidseg
  mov di,0000h
  mov si,$0140
  mov cx,$ffff
  rep movsw
  pop ds
end;
begin
     gd:=vga; gm:=vgamed; initgraph(gd,gm,'');
     setcolor(green);
     line(100,100,200,200);
     repeat until keypressed; ch:=readkey;
     moveup;
     repeat until keypressed; ch:=readkey;


end.