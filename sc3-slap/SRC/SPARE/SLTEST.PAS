program slaptest;
uses crt,graph;
var
   gm,gd:integer;
   a,b: longint;
   c: char;
begin
     gm:=vgamed; gd:=vga; initgraph(gd,gm,'');
     for a:=$fff to $b400 do begin
     for b:=$00 to $ff do begin
     mem[a:b]:=round(int(random*255)); {delay(10);}
     end; end;
{     c:=readkey;}
{     for a:=$a000 to $b400 do begin
     for b:=$00 to $ff do begin
     mem[a:b]:=1; {delay(10);}
{     c:=readkey;}
{     end; end;}
end.