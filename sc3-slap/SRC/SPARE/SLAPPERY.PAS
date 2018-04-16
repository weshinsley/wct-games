program Slappery;
uses crt,graph;{,u_vga,u_mdx{,u_kb};










{procedure scroll_up;
begin
asm
  push ds
  mov es,u_vidseg
  mov ds,u_vidseg
  xor di,di
  mov si,0100h
{<<$ifdef cpu386}
{  mov cx,255*256/4
  db $66; rep movsw
{<<<$else}
 { mov cx,255*256/2
  rep movsw}
{<<<$endif}
{  pop ds
end; end;
begin
{  mdx_setmodex(mdx_256x256c,256);}
{  setvideo(1);
  mdx_cls;
  getfont(font8x8);
  mdx_writetxt('Hello',0,100,yellow);
  repeat
    mdx_putpixel(200,200,yellow);
    vga_line(0,100,320,100,blue);
until keypressed;
end.