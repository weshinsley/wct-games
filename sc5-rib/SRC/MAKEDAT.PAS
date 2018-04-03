program makedat;
var F : file;
    Lb : byte;
    L : integer;
    ch : char;
    Loadin : array[1..540] of byte;
begin
  assign(F,'RIBENA.DAT');
  rewrite(F,1);
  for L:=1 to 540 do Loadin[L]:=0;

  for Lb:=1 to 80 do
    begin
      ch:=chr(Lb);
      blockwrite(F,ch,1);
      blockwrite(F,Loadin,540);
    end;
  close(F);
end.
