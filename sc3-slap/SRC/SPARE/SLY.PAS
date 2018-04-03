program Mez;
uses u_vga,u_mdx,u_kb,crt,graph;
var
   gm,gd,x,fg,cpu386:integer;
   mu: longint;
   ch: char;
Procedure MSVW; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;
procedure moveup(uval:word); assembler;
asm
  push ds
  mov es,u_vidseg
  mov ds,u_vidseg
  xor di,di
  mov di,0000h
  mov si,uval
{$ifdef cpu386}
  mov cx,65535
  db $66; rep movsw
{$else}
  mov cx,65535
  rep movsw
{$endif}
  pop ds
end;
begin
gd:=vga; gm:=vgamed;
initgraph(gd,gm,'');
{repeat until keypressed;}
setfillstyle(0,0); mu:=1;


repeat
moveup($0140*mu); {vga256-$100}
setfillstyle(0,0);
bar(0,349-mu,640,350);
msvw;
ch:=chr(0);
if keypressed then ch:=readkey;
if ch='q' then inc(mu);
if (ch='a') and (mu>0) then dec(mu);
if ch='p' then outtextxy(300,150,'Hello');
if mu<>0 then begin
   setcolor(black);
{   bar(0,0,640,351);}
   for fg:=1 to 1 do begin
      setcolor(blue);
   line(0,200,640,200); end;

end;
until ch=' ';
end.