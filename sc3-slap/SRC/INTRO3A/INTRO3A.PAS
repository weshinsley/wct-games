{$M 16384,0,655360}
program SLAPINT;
uses crt,graph,TDfonts,Ched3_I1,Ched3_I2,Ched3_I3,Ched3_i4,Ched3_I5,Ched3_I6;
var LP,GD,GM,L : integer;
    F : file;
    SC : array[1..16,1..9] of byte;
    P : pointer;
    ct,SIZE : integer;

    SX,SY,XC,YC,OXC,OYC : array[1..3] of integer;
    ANGLE : array[1..3] of real;
    ST,WCT : array[1..3] of pointer;
    mess,FLAG,A,B,C,Y : byte;

    CH: char;
    label ENDOFPROG;

const
  AG : real=(5/180);
procedure GETRGB(NR: byte; Var R,G,B :byte);
  begin
    Port[$3c7]:=Nr;
    r:=Port[$3c9];
    g:=Port[$3c9];
    b:=Port[$3c9];
  end;
Procedure SETRgb(nR,r,g,b:bYTE);
begin
     Port[$3c8]:=Nr;
     Port[$3c9]:=R;
     Port[$3c9]:=G;
     Port[$3c9]:=B;
End;
Procedure TDvw; assembler;
  asm
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwt

    @@nextv:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    cmp     ax,0
    jz      @@nextv

    @@vwt:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwt
  end;
Procedure VWait; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;
begin
  gD:=vga;
  GM:=vgahi; TDFinit;
  initgraph(GD,GM,'');
  GETRGB(1,A,B,C);
  writeln(A,'.',B,'.',C,'.');
  setrgb(1,0,0,0);
  setrgb(2,0,0,0);
  setrgb(3,0,0,0);
  setrgb(4,0,0,0);
  setrgb(5,0,0,0);
  setrgb(6,0,0,0);
  P:=@wctcol;
  putimage(177,120,P^,normalput);
  L:=0;
  repeat
    inc(L);
    if L<20 then setrgb(1,0,0,L);
    if L<30 then setrgb(2,0,0,L);
    if L<35 then setrgb(3,0,0,L);
    if L<45 then setrgb(4,0,0,L);
    if L<60 then setrgb(5,0,0,L);
    setrgb(6,0,0,l);
if keypressed then goto ENDOFPROG;
    delay(25);
  until (L=63);
  P:=@presents;
   putimage(252,290,P^,normalput);
  P:=@prod;
  L:=480;
  repeat
if keypressed then goto ENDOFPROG;
    putimage(229,L,P^,normalput);
    L:=L-3;
    VWAIT;
  until (L<=320);
  setcolor(0);
  L:=0;
  repeat
if keypressed then goto ENDOFPROG;
    L:=L+2;
    line(L,0,0,L);
    line(1079-L,0,0,1079-L)
  until (L>=1280);
  setrgb(1,0,0,0);
  setrgb(2,0,0,0);
  setrgb(3,0,0,0);
  setrgb(4,0,0,0);
  setrgb(5,0,0,0);
  setrgb(6,0,0,0);

  P:=@iii;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;
if keypressed then goto ENDOFPROG;

  P:=@iii2;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii3;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii4;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii5;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii6;
  putimage(150,260,P^,normalput);
  DELAY(75);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii6b;
  putimage(150,260,P^,normalput);
  vwait;

if keypressed then goto ENDOFPROG;
 P:=@iii7;
  putimage(150,260,P^,normalput);
  vwait;

if keypressed then goto ENDOFPROG;
P:=@title;
  putimage(145,0,P^,XorPUT);

   L:=0;
  repeat
if keypressed then goto ENDOFPROG;
    inc(L);
    setrgb(1,0,0,L);
    setrgb(2,0,L,0);
    setrgb(3,0,L,L);
    setrgb(4,L,0,0);
    setrgb(5,L,0,L);
    setrgb(6,L,L,0);
    delay(35);
  until (L>=42);
  delay(100);
  L:=0;
  repeat
if keypressed then goto ENDOFPROG;
    rectangle(L,L,639-L,480-L);
    inc(L); inc(L);
  until (L>640);
  l:=1;
  repeat
if keypressed then goto ENDOFPROG;
    rectangle(L,L,639-L,480-L);
    inc(L); INC(l);
  until (L>640);
if keypressed then goto ENDOFPROG;
  P:=@slippy;
  putimage(405,45,p^,normalput);
  putimage(65,240,P^,normalput);
  putimage(65,45,P^,normalput);
  putimage(235,240,P^,normalput);
  putimage(235,45,P^,normalput);

  putimage(405,240,P^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@slapping;
  putimage(72,0,p^,normalput);
 P:=@slappery;
  putimage(77,440,p^,normalput);
if keypressed then goto ENDOFPROG;
  delay(1000);
  cleardevice;
  GD:=vga;
  GM:=vgamed;
  initgraph(GD,GM,'S:\');
  setactivepage(0);
  setvisualpage(1);
  vwait;
  cleardevice;
if keypressed then goto ENDOFPROG;
  P:=@slsl;
  putimage(0,20,p^,normalput);
  putimage(350,20,p^,normalput);
  putimage(0,280,p^,normalput);
  putimage(350,280,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@www4;
  putimage(140,100,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@writby;
  putimage(230,200,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@cwandt;
  putimage(128,225,p^,normalput);
if keypressed then goto ENDOFPROG;
  setvisualpage(0);
  setactivepage(1);
  vwait;
  cleardevice;
 P:=@slsl;
  putimage(0,20,p^,normalput);
  putimage(350,20,p^,normalput);
  putimage(0,280,p^,normalput);
  putimage(350,280,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@www2;
  putimage(110,100,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@progby;
  putimage(190,200,p^,normalput);
if keypressed then goto ENDOFPROG;
  delay(1000);
  setactivepage(0);
  setvisualpage(1);
  vwait;
  cleardevice;
 P:=@slsl;
  putimage(0,20,p^,normalput);
  putimage(350,20,p^,normalput);
  putimage(0,280,p^,normalput);
  putimage(350,280,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@www1;
  putimage(95,100,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@wctintby;
  putimage(190,180,p^,normalput);
if keypressed then goto ENDOFPROG;
  delay(1000);
  setvisualpage(0);
  setactivepage(1);
  cleardevice;
 P:=@slsl;
  putimage(0,20,p^,normalput);
  putimage(350,20,p^,normalput);
  putimage(0,280,p^,normalput);
  putimage(350,280,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@www3;
  putimage(140,100,p^,normalput);
if keypressed then goto ENDOFPROG;
 P:=@byww;
  putimage(200,200,p^,normalput);
if keypressed then goto ENDOFPROG;
  delay(1000);
  setvisualpage(1);
  setactivepage(1);
  delay(1000);
 P:=@redhand;
  putimage(200,100,P^,xorput);
if keypressed then goto ENDOFPROG;
 P:=@pinkhand;
  putimage(200,200,P^,xorput);
if keypressed then goto ENDOFPROG;
  delay(1000);
  CLEARDEVICE;
  setactivepage(0);
  setvisualpage(0);
  cleardevice;
  ENDOFPROG:
  IF KEYPRESSED THEN CH:=readkey;
  closegraph;
  closegraph;
end.