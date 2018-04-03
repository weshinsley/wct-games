unit TDA_3;
interface
Procedure GMOVR;

Procedure D1;  Procedure D2;  Procedure D3;   Procedure D4;
Procedure D5;  Procedure D6;  Procedure D7;   Procedure D8;
Procedure D9;  Procedure D10; Procedure D11;  Procedure D12;
Procedure D13; Procedure D14; Procedure D15;  Procedure D16;
procedure D17; procedure D18; procedure D19; procedure D20;
procedure D21; procedure D22; procedure D23; procedure D24;

Procedure H1; Procedure H2; Procedure H3; Procedure H4;
Procedure F1; Procedure F2;
Procedure G; Procedure MG;
Procedure TDAPAL; Procedure DEADPAL;

Procedure FMESS;

Procedure W;   Procedure WBL ; procedure WBR ; Procedure WTL ;
Procedure WTR ; Procedure COSMIX ;
const
    GPOINTERS : array[1..14] of pointer = (@H3,@H4,@H1,@H2,@F1,@F2,@G,@MG,@FMESS,@W,@WTR,@WTL,@WBL,@WBR);
    DANIM : array[1..24] of pointer =
    (@D1,@D2,@D3,@D4,@D5,@D6,@D7,@D8,@D9,@D10,@D11,@D12,@D13,@D14,@D15,@D16,@D17,@D18,@D19,@D20,@D21,@D22,@D23,@D24);

implementation




Procedure D1  ; external; {$L D1.OBJ}  Procedure D2  ; external; {$L D2.OBJ}
Procedure D3  ; external; {$L D3.OBJ}  Procedure D4  ; external; {$L D4.OBJ}
Procedure D5  ; external; {$L D5.OBJ}  Procedure D6  ; external; {$L D6.OBJ}
Procedure D7  ; external; {$L D7.OBJ}  Procedure D8  ; external; {$L D8.OBJ}
Procedure D9  ; external; {$L D9.OBJ}  Procedure D10 ; external; {$L D10.OBJ}
Procedure D11 ; external; {$L D11.OBJ} Procedure D12 ; external; {$L D12.OBJ}
Procedure D13 ; external; {$L D13.OBJ} Procedure D14 ; external; {$L D14.OBJ}
Procedure D15 ; external; {$L D15.OBJ} Procedure D16 ; external; {$L D16.OBJ}
Procedure D17 ; external; {$L D17.OBJ} Procedure D18 ; external; {$L D18.OBJ}
Procedure D19 ; external; {$L D19.OBJ} Procedure D20 ; external; {$L D20.OBJ}
Procedure D21 ; external; {$L D21.OBJ} Procedure D22 ; external; {$L D22.OBJ}
Procedure D23 ; external; {$L D23.OBJ} Procedure D24 ; external; {$L D24.OBJ}
Procedure H3  ; external; {$L H3.OBJ}  Procedure H4  ; external; {$L H4.OBJ}
Procedure H1  ; external; {$L H1.OBJ}  Procedure H2  ; external; {$L H2.OBJ}
Procedure F1  ; external; {$L F1.OBJ}  Procedure F2  ; external; {$L F2.OBJ}
Procedure G   ; external; {$L G.OBJ}   Procedure MG  ; external; {$L MG.OBJ}
Procedure GMOVR; external; {$L GMOVR.OBJ}
Procedure TDAPAL; external; {$L TDAPAL.OBJ} Procedure DEADPAL; external; {$L DEADPAL.OBJ}
Procedure FMESS ; external; {$L FMESS.OBJ}
Procedure W   ; external; {$L W.OBJ}   Procedure WBL ; external; {$L WBL.OBJ}
Procedure WBR ; external; {$L WBR.OBJ} Procedure WTL ; external; {$L WTL.OBJ}
Procedure WTR ; external; {$L WTR.OBJ}
Procedure COSMIX ; external; {$L COSMIX.OBJ}

end.