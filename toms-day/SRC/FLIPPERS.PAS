unit FLIPPERS;
interface
uses td_256,crt;
var
    R1C,G1C,B1C : array[0..255] of real;
    RGB_SHIFT : array[0..255,1..3] of real;
    R2c,G2c,B2c : array[0..255] of byte;

Procedure SCREEN_FLIP2(DEST : byte;RGB_ALTER : boolean; avoid : boolean);
implementation

procedure CLEARBUF;
begin
  inline($fa);
  memw[$40:$1A]:=memw[$40:$1C];
  inline($fb);
end;

procedure DO_RGB;
  var DOR : byte;
begin
  for DOR:=0 to 255 do begin
    R1C[DOR]:=R1C[DOR]+RGB_SHIFT[DOR,1];
    G1C[DOR]:=G1C[DOR]+RGB_SHIFT[DOR,2];
    B1C[DOR]:=B1C[DOR]+RGB_SHIFT[DOR,3];
    T2_setrgb(DOR,trunc(R1C[DOR]),trunc(G1C[DOR]),trunc(B1C[DOR]));
  end;
end;

Procedure SCREEN_FLIP2(DEST : byte;RGB_ALTER : boolean; avoid : boolean);
var STEPS,R,L1,l2 : integer;
    P : pointer;
    DOT_GRID : array[1..1000,1..2] of byte;
    GONE : array[1..40,1..25] of byte;
    TOG,L3 : byte;
    L : integer;
    GP : pointer;

begin
  TOG:=0;
  randomize;
  repeat
    R:=random(5)+1;
  until not avoid or (R<5);

  if RGB_ALTER then {Calculate RGB shift values} begin
    if R=1 then STEPS:=160;
    if R=2 then STEPS:=140;
    if R=3 then STEPS:=167;
    IF R=4 then STEPS:=160;
    if R=5 then STEPS:=140;
    for L1:=0 to 255 do begin
      RGB_SHIFT[L1,1]:=(R2C[L1]-R1C[L1])/STEPS;
      RGB_SHIFT[L1,2]:=(G2C[L1]-G1C[L1])/STEPS;
      RGB_SHIFT[L1,3]:=(B2C[L1]-B1C[L1])/STEPS;
    end;
  end;
  if R=1 then {Two way fill} begin
    L1:=0; L2:=0;
    getmem(P,326);
    repeat
      t2_set_buf(DEST); t2_getpic(L1,0,1,200,P);
      t2_set_buf(0); t2_putpic(L1,0,P);
      inc(L1,1);
      t2_set_buf(DEST); t2_getpic(320-L1,0,1,200,P);
      t2_set_buf(0); t2_putpic(320-L1,0,P);
      inc(L1,1);
      t2_set_buf(DEST); t2_getpic(0,l2,320,1,P);
      t2_set_buf(0); t2_putpic(0,L2,P);
      inc(L2,1); if L2>200 then L2:=198;
      if (RGB_ALTER) then DO_RGB;
      clearbuf;
    until L1>=320;
    freemem(P,326);
  end;

  if R=2 then {Shrinking rectangle} begin
    L1:=0;
    L2:=0;
    getmem(P,326);
    repeat
      t2_set_buf(DEST); t2_getpic(L1,0,1,200,P);
      t2_set_buf(0); t2_putpic(L1,0,P);
      t2_set_buf(DEST); t2_getpic(319-L1,0,1,200,P);
      t2_set_buf(0); t2_putpic(319-L1,0,P);
      t2_set_buf(DEST); t2_getpic(0,L1,320,1,P);
      t2_set_buf(0); t2_putpic(0,L1,P);
      t2_set_buf(DEST); t2_getpic(0,199-L1,320,1,P);
      t2_set_buf(0); t2_putpic(0,199-L1,P);
      inc(L1);
      if (RGB_ALTER) then DO_RGB;
      clearbuf;
    until L1=140;
    freemem(P,326);
  end;

  if R=3 then {DisSolve} begin
    for L:=1 to 40 do for L1:=1 to 25 do GONE[L,L1]:=0;
    for L:=0 to 999 do begin
      repeat
        L1:=random(40); L2:=random(25);
      until GONE[L1+1,L2+1]=0;
      GONE[L1+1,L2+1]:=1; DOT_GRID[L+1,1]:=L1; DOT_GRID[L+1,2]:=L2;
    end;
    getmem(GP,70);
    for L:=1 to 1000 do begin
      T2_SET_BUF(DEST); T2_getpic(DOT_GRID[L,1]*8,DOT_GRID[L,2]*8,8,8,GP);
      T2_SET_BUF(0); t2_putpic(DOT_GRID[L,1]*8,DOT_GRID[L,2]*8,GP);
      inc(TOG); if TOG=6 then TOG:=0;
      if (RGB_ALTER) and (TOG=0) then DO_RGB;
      clearbuf;
    end;
    freemem(GP,70);
  end;
 
  if R=4 then {Rotary flip} begin
    L1:=160; L2:=100;
    getmem(P,166);
    repeat
      t2_set_buf(DEST); t2_getpic(L1,0,1,100,P);
      t2_set_buf(0); t2_putpic(L1,0,P);
      t2_set_buf(DEST); t2_getpic(319-L1,100,1,100,p);
      t2_set_buf(0); t2_putpic(319-L1,100,P);
      t2_set_buf(DEST);  t2_getpic(160,L2,160,1,P);
      t2_set_buf(0); t2_putpic(160,L2,P);
      t2_set_buf(DEST); t2_getpic(0,200-L2,160,1,P);
      t2_set_buf(0); t2_putpic(0,200-L2,P);
      inc(l1);
      if L2<200 then inc(l2);
      if RGB_ALTER then DO_RGB;
      clearbuf;
     until L1=320;
     freemem(P,166);
   end;
   if R=5 then  {ZOOM!} begin
     getmem(P,65520);
     t2_set_buf(DEST); t2_getpic(0,0,320,200,P);
     t2_set_buf(0);
     L1:=0; L2:=0;
     repeat
       inc(L1,2); inc(L2,2); if L2>200 then begin L2:=200; inc(L1); END;
       t2_set_scale_size(L1,L2);
       t2_vretrace;
       t2_scale_pic(160-(L1 div 2),100-(L2 div 2),P);
       if RGB_ALTER then DO_RGB;
     until L1>=320;
   freemem(P,65520);
   END;
end;

end.