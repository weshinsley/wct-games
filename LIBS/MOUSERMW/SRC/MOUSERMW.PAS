Unit MouseRMW;

Interface

  Uses Dos, Graph;

  Type MouseData = record
    X, Y : Integer;
    left, right : boolean;
    center : boolean;
  end;

  Const
    pArrow = 0;
    pHourGlass = 1;
    pAtari =2;
    pSights =3;
    pX = 4;
    pCross = 5;
    pBeerglass = 6;
    pCPG = 7;
    PCHED = 8;
    PCHOPPER1 = 9;
    PCHOPPER2 = 10;
    PCHOPPER3 = 11;
    PCHOPPER4 = 12;
    PINSERTER = 13;

  Var
    MouseButtons : Integer;
    Mouse : MouseData;

  Procedure InitMouse;
  Procedure ShowPointer;
  Procedure SetPointer( MP : Integer);
  Procedure HidePointer;
  Procedure MouseInfo;
  Procedure SetMousePosition ( X, Y : Integer );
  Function GetMouseDriverVersion : String;
  Procedure pshpPointer;
  Procedure pshpHourGlass;
  Procedure pshpAtari;
  Procedure pshpSights;
  Procedure pshpCross;
  Procedure pshpX;
  Procedure PshpCHOPPER1;
  Procedure PshpCHOPPER2;
  Procedure PshpCHOPPER3;
  Procedure PshpCHOPPER4;
  Procedure pshpCPG;
  Procedure pshpCHED;
  Procedure pshpINSERTER;
  Procedure pshpBeerGlass;
  Procedure SetMouseExclusion( X1, Y1, X2, Y2 : integer );
  Procedure SetMouseXLimits( X1, X2 : Word );
  Procedure SetMouseYLimits( Y1, Y2 : Word );
  Procedure SetMouseLimits( X1, Y1, X2, Y2 : Word );
  Procedure ResetMouseExclusion;


Implementation



Procedure InitMouse;

  var
    Regs : Registers;

Begin
  Regs.ax := 0;
  Intr($33,Regs);
  If Regs.ax <> $ffff then begin
    closegraph;
    write (' No Mouse Support. ');
    halt;
  end;
  MouseButtons := Regs.bx;
  if Regs.ax = 2525 then begin
    asm
      db 0;
      dec bp;
      db $6f;
      dw $7375;
      db $65;
      push dx;
      dec bp;
      push di;
      and [di],ch;
      and [si+$75],dl;
      dw $6272;
      db $6f;
      and [bx+si+$61],dl;
      dw $6373;
      dw $6c61;
      and [di+$6f],cl;
      dw $7375;
      db $65;
      and [di+$6e],dl;
      db $69;
      dw $3b74
      and [bp+si+$75],dl;
      dw $6570;
      dw $7472;
      and [bx+$6f],dl;
      dw $646f;
      sub al,$20;
      dec si;
      dw $766f;
      dw $6d65;
      dw $6562;
      dw $2072;
      daa;
      cmp [bp+di],si;
      db $2e;
      dw 0;
      dw 0;
    end;
  end;
End;




Procedure ShowPointer;

  var
    Regs : Registers;

Begin
  Regs.ax := 1;
  Intr($33,Regs);
End;

Procedure SetPointer (MP : integer);
  var
    Regs : Registers;

Begin
  Case Mp of
    pArrow:
      begin
        Regs.bx := 2;
        Regs.cx := 0;
        Regs.es := seg(PshpPointer);
        Regs.dx := ofs(PshpPointer);
      end;
    pHourGlass:
      begin
        Regs.bx := 7;
        Regs.cx := 8;
        Regs.es := seg(PshpHourGlass);
        Regs.dx := ofs(PshpHourGlass);
      end;
    pAtari:
      begin
        Regs.bx := 7;
        Regs.cx := 8;
        Regs.es := seg(Pshpatari);
        Regs.dx := ofs(Pshpatari);
      end;
    pSights:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpsights);
        regs.dx:= ofs(pshpsights);
      end;
     pX:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpx);
        regs.dx:= ofs(pshpx);
      end;
     pcross:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpcross);
        regs.dx:= ofs(pshpcross);
      end;
     pCPG:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:=seg(pshpCPG);
        Regs.dx:=ofs(pshpCPG);
      end;
     pBeerglass:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpbeerglass);
        regs.dx:= ofs(pshpbeerglass);
      end;
      pINSERTER:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:=seg(pshpinserter);
        regs.dx:=ofs(pshpinserter);
      end;
    pChopper1:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpchopper1);
        Regs.dx:= ofs(pshpChopper1);
      end;
    pChopper2:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpchopper2);
        Regs.dx:= ofs(pshpChopper2);
      end;
    pChopper3:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpchopper3);
        Regs.dx:= ofs(pshpChopper3);
      end;
      pChopper4:
      begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpchopper4);
        Regs.dx:= ofs(pshpChopper4);
      end;
     pChed:
       begin
        Regs.bx:=7;
        Regs.cx:=8;
        Regs.es:= seg(pshpChed);
        Regs.dx:= ofs(pshpChed);
      end;
   else
        begin
          Regs.bx := 2;
          Regs.cx := 0;
          Regs.es := seg(PshpPointer);
          Regs.dx := ofs(PshpPointer);
        end;
    end;
    Regs.ax := 9;
    Intr($33, Regs);
  End;

  Procedure HidePointer;

  var
    Regs : Registers;

Begin
  Regs.ax := 2;
  Intr($33,Regs);
End;

Procedure MouseInfo;

  var
    Regs : Registers;

Begin
  Regs.ax := 3;
  Intr($33,Regs);
  Mouse.X := Regs.CX;
  Mouse.Y := Regs.DX;
  Mouse.Left := ((Regs.BX and 1)>0);
  Mouse.Right := ((Regs.BX and 2)>0);
  Mouse.Center := ((Regs.BX and 4)>0);
End;

  Procedure SetMousePosition ( X, Y : Integer );

  var
    Regs : Registers;

Begin
  Regs.ax := 4;
  Regs.cx := x;
  Regs.dx := y;
  Intr($33,Regs);
End;

Function GetMouseDriverVersion : String;

  var
    Regs : Registers;

  Var
    Mj, Mn: Integer;
    Mjs, Mns : String;

Begin
  Regs.ax := $24;
  intr($33,Regs);
  Mj := ( Regs.Bx and $ff00 ) div 256;
  Mn := ( Regs.Bx and $ff );
  Str(Mn : 2, Mns);
  Str(Mj : 2, Mjs);
  GetMouseDriverVersion := Mjs + '.' + Mns;
End;



Procedure pshpPointer; assembler;

asm

  dw not 0011000000000000b
  dw not 0011100000000000b
  dw not 0011110000000000b
  dw not 0011111000000000b
  dw not 0011111100000000b
  dw not 0011111110000000b
  dw not 0011111111000000b
  dw not 0011111111100000b
  dw not 0011111111110000b
  dw not 0011111111110000b
  dw not 0011111110000000b
  dw not 0011111111000000b
  dw not 0011001111000000b
  dw not 0000000111100000b
  dw not 0000000111100000b
  dw not 0000000011000000b

  dw 0000000000000000b
  dw 0001000000000000b
  dw 0001100000000000b
  dw 0001110000000000b
  dw 0001111000000000b
  dw 0001111100000000b
  dw 0001111110000000b
  dw 0001111111000000b
  dw 0001111111100000b
  dw 0001111100000000b
  dw 0001101100000000b
  dw 0001000110000000b
  dw 0000000110000000b
  dw 0000000011000000b
  dw 0000000011000000b
  dw 0000000000000000b
end;

Procedure pshpChed; assembler;

  asm

  dw not 0000001111000000b
  dw not 0000111111110000b
  dw not 0001111010111000b
  dw not 0011101101111100b
  dw not 0011110111011100b
  dw not 0111011101011110b
  dw not 0110111011101110b
  dw not 0111101011101110b
  dw not 0111011011011110b
  dw not 0111110110111110b
  dw not 0111101101101110b
  dw not 0011110110111100b
  dw not 0011101101111100b
  dw not 0001111101111000b
  dw not 0000110101110000b
  dw not 0000001111000000b

  dw 0000001111000000b
  dw 0000111111110000b
  dw 0001111111111000b
  dw 0011111111111100b
  dw 0011111111111100b
  dw 0111111111111110b
  dw 0111111111111110b
  dw 0111111111111110b
  dw 0111111111111110b
  dw 0111111111111110b
  dw 0111111111111110b
  dw 0011111111111100b
  dw 0011111111111100b
  dw 0001111111111000b
  dw 0000111111110000b
  dw 0000001111000000b
end;

Procedure pshpChopper1; assembler;
asm
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000111111111111b
  dw not 0000000000100000b
  dw not 0000000000100000b
  dw not 0000001111111100b
  dw not 0010001111111110b
  dw not 0001111111111111b
  dw not 0010001111111111b
  dw not 0000000010000100b
  dw not 0000001111111111b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b

  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0001111111111111b
  dw  0000000001000000b
  dw  0000000001000000b
  dw  0000000111111100b
  dw  0010001000000010b
  dw  0001111000000001b
  dw  0010000111111110b
  dw  0000000010000100b
  dw  0000001111111111b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b

end;

Procedure PshpCPG; assembler;
asm
  dw not 0000000000000000b
  dw not 0011101111011110b
  dw not 0100001001010000b
  dw not 0100001001010000b
  dw not 0100001001010000b
  dw not 0100001111010000b
  dw not 0100001000010000b
  dw not 0100001000010000b
  dw not 0100001000010000b
  dw not 0100001000010110b
  dw not 0100001000010010b
  dw not 0100001000010010b
  dw not 0100001000010010b
  dw not 0100001000010010b
  dw not 0011101000011110b
  dw not 0000000000000000b

  dw  0000000000000000b
  dw  0011101111011110b
  dw  0100001001010000b
  dw  0100001001010000b
  dw  0100001001010000b
  dw  0100001111010000b
  dw  0100001000010000b
  dw  0100001000010000b
  dw  0100001000010000b
  dw  0100001000010110b
  dw  0100001000010010b
  dw  0100001000010010b
  dw  0100001000010010b
  dw  0100001000010010b
  dw  0011101000011110b
  dw  0000000000000000b
end;

Procedure pshpChopper2; assembler;
asm

  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000011111111110b
  dw not 0000000000100000b
  dw not 0000000000100000b
  dw not 0000000111111100b
  dw not 0000001111111110b
  dw not 0011111111111111b
  dw not 0000000111111110b
  dw not 0000000010000100b
  dw not 0000001111111111b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b

  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000011111111110b
  dw  0000000001000000b
  dw  0000000001000000b
  dw  0000000111111100b
  dw  0000001000000010b
  dw  0011111000000001b
  dw  0000000111111110b
  dw  0000000010000100b
  dw  0000001111111111b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b

end;

Procedure pshpChopper3; assembler;
asm
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000111111100b
  dw not 0000000000100000b
  dw not 0000000000100000b
  dw not 0000000111111100b
  dw not 0010001111111110b
  dw not 0001111111111111b
  dw not 0010000111111110b
  dw not 0000000010000100b
  dw not 0000001111111111b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b

  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000001111111000b
  dw  0000000001000000b
  dw  0000000001000000b
  dw  0000000111111100b
  dw  0010001000000010b
  dw  0001111000000001b
  dw  0010000111111110b
  dw  0000000010000100b
  dw  0000001111111111b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b

end;
Procedure pshpChopper4; assembler;
asm
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000001110000b
  dw not 0000000000100000b
  dw not 0000000000100000b
  dw not 0000000111111100b
  dw not 0000001111111110b
  dw not 0011111111111111b
  dw not 0000000111111110b
  dw not 0000000010000100b
  dw not 0000001111111111b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b
  dw not 0000000000000000b

  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000011100000b
  dw  0000000001000000b
  dw  0000000001000000b
  dw  0000000111111100b
  dw  0000001000000010b
  dw  0011111000000001b
  dw  0000000111111110b
  dw  0000000010000100b
  dw  0000001111111111b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
  dw  0000000000000000b
end;


Procedure pshpHourGlass; assembler;
asm

  dw not 0001111111111000b
  dw not 0000001111000000b
  dw not 0000111111110000b
  dw not 0001111111111000b
  dw not 0011111111111100b
  dw not 0111111111111110b
  dw not 0111111111111110b
  dw 0
  dw 0
  dw 0
  dw 0
  dw not 0111111111111110b
  dw not 0111111111111110b
  dw not 0011111111111100b
  dw not 0001111111111000b
  dw not 0000111111110000b

  dw 0000111111110000b
  dw 0000000110000000b
  dw 0000001111000000b
  dw 0000111001110000b
  dw 0001100101011000b
  dw 0011010110001100b
  dw 0011000110101100b
  dw 0110100110000110b
  dw 0110001111010110b
  dw 0110101111000110b
  dw 0110100110000110b
  dw 0011000000101100b
  dw 0011010001001100b
  dw 0001100100011000b
  dw 0000111001110000b
  dw 0000001111000000b
end;

Procedure pshpSIGHTS; assembler;
asm
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000001000100000b
  dw not 0000010000010000b
  dw not 0111100000001111b
  dw not 0000000000000000b
  dw not 0111100000001111b
  dw not 0000010000010000b
  dw not 0000001000100000b
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000000101000000b
  dw not 0000000101000000b

  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000001000100000b
  dw 0000010000010000b
  dw 0111100000001111b
  dw 0000000000000000b
  dw 0111100000001111b
  dw 0000010000010000b
  dw 0000001000100000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
end;

Procedure pshpCross; assembler;
asm

  dw not 0000011111110000b
  dw not 0000011111110000b
  dw not 0000011111110000b
  dw not 0000001111100000b
  dw not 0000001111100000b
  dw not 0111001111100111b
  dw not 0111111111111111b
  dw not 0111111111111111b
  dw not 0111111111111111b
  dw not 0111111111111111b
  dw not 0111111111111111b
  dw not 0111001111100111b
  dw not 0000001111100000b
  dw not 0000011111110000b
  dw not 0000011111110000b
  dw not 0000011111110000b

  dw 0000001111100000b
  dw 0000001000100000b
  dw 0000001101100000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0111000101000111b
  dw 0101111101111101b
  dw 0100000000000001b
  dw 0101111101111101b
  dw 0111000101000111b
  dw 0000000101000000b
  dw 0000000101000000b
  dw 0000001101100000b
  dw 0000001000100000b
  dw 0000001111100000b

end;

Procedure pshpX; assembler;
asm
  dw not 0111100000001111b
  dw not 0111110000011111b
  dw not 0111111000111111b
  dw not 0111111000111111b
  dw not 0011111101111110b
  dw not 0011111111111110b
  dw not 0001111111111100b
  dw not 0001111111111100b
  dw not 0001111111111100b
  dw not 0001111111111100b
  dw not 0011111111111110b
  dw not 0011111101111110b
  dw not 0111111000111111b
  dw not 0111111000111111b
  dw not 0111110000011111b
  dw not 0111110000011111b

  dw 0000000000000000b
  dw 0111000000000111b
  dw 0011100000001110b
  dw 0011100000001110b
  dw 0001110000011100b
  dw 0001110000011100b
  dw 0000111000111000b
  dw 0000111000111000b
  dw 0000111111111000b
  dw 0000111000111000b
  dw 0001110000011100b
  dw 0001110000011100b
  dw 0011100000001110b
  dw 0011100000001110b
  dw 0111000000000111b
  dw 0000000000000000b
end;

Procedure pshpAtari; assembler;

asm
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0000110110110000b
  dw not 0001100110011000b
  dw not 0001100110011000b
  dw not 0111000110001110b
  dw not 0011000110001100b
  dw not 0110000110000110b
  dw not 0100000110000010b

  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000010110100000b
  dw 0000100110010000b
  dw 0000100110010000b
  dw 0001000110001000b
  dw 0001000110001000b
  dw 0010000110000100b
  dw 1100000110000011b
end;

Procedure pshpBeerGlass;assembler;
asm

  dw not 0000000000000000b
  dw not 0110000000001100b
  dw not 0110010010001100b
  dw not 0111101101011100b
  dw not 0110000000101100b
  dw not 0110000000001111b
  dw not 0110010001001101b
  dw not 0110111000001101b
  dw not 0110010000001101b
  dw not 0110000000001101b
  dw not 0110000010001101b
  dw not 0110000111001101b
  dw not 0110000010001111b
  dw not 0110100000001100b
  dw not 0110000000001100b
  dw not 0111111111111100b

  dw 1110000000001110b
  dw 1110000000001110b
  dw 1110010010001110b
  dw 1111101101011110b
  dw 1110000000101110b
  dw 1110000000001111b
  dw 1110010001001111b
  dw 1110111000001111b
  dw 1110010000001111b
  dw 1110000000001111b
  dw 1110000010001111b
  dw 1110000111001111b
  dw 1110000010001111b
  dw 1110100000001110b
  dw 1110000000001110b
  dw 1111111111111110b
end;

Procedure pshpINSERTER; assembler;
asm

  dw not 0111111111111111b
  dw not 0000000000000000b
  dw not 0111111111111111b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000000110000000b
  dw not 0000111111110000b
  dw not 0000011111100000b
  dw not 0000001111000000b
  dw not 0000000110000000b
  dw not 0000000000000000b

  dw 0111111111111111b
  dw 0100000000000001b
  dw 0111111111111111b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000001111000000b
  dw 0000111111110000b
  dw 0001111111111000b
  dw 0000111111110000b
  dw 0000011111100000b
  dw 0000001111000000b
  dw 0000000110000000b
end;

Procedure SetMouseExclusion( X1, Y1, X2, Y2 : integer );

  var
    Regs : Registers;
    smxxq1, smxxq2, smxyq1, smxyq2 :integer;

Begin
  If x1 < x2 then begin
    smxxq1 := x1;
    smxxq2 := x2;
  end else begin
    smxxq2 := x1;
    smxxq1 := x2;
  end;

  If y1 < y2 then begin
    smxyq1 := y1;
    smxyq2 := y2;
  end else begin
    smxyq2 := y1;
    smxyq1 := y2;
  end;

  Regs.ax := $10;
  Regs.cx := smxxq1;
  Regs.dx := smxyq1;
  Regs.di := smxxq2;
  Regs.si := smxyq2;
  Intr($33,Regs);
End;

Procedure ResetMouseExclusion;

var
  Regs : Registers;

Begin
  Regs.ax := 2;
  Intr($33,Regs);
  Regs.ax := 1;
  Intr($33,Regs);
End;



Procedure SetMouseXLimits( X1, X2 : Word );

  var
    Regs : Registers;

Begin
  Regs.ax := 7;
  Regs.cx := x1;
  Regs.dx := x2;
  Intr($33,Regs);
End;



Procedure SetMouseYLimits( Y1, Y2 : Word );

  var
    Regs : Registers;

Begin
  Regs.ax := 8;
  Regs.cx := y1;
  Regs.dx := y2;
  Intr($33,Regs);
End;



Procedure SetMouseLimits( X1, Y1, X2, Y2 : Word );

  var
    Regs : Registers;

Begin
  Regs.ax := 7;
  Regs.cx := x1;
  Regs.dx := x2;
  Intr($33,Regs);
  Regs.ax := 8;
  Regs.cx := y1;
  Regs.dx := y2;
  Intr($33,Regs);
End;

Begin
end.