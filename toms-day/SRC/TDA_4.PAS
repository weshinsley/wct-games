unit TDA_4;
interface

procedure HOF;
procedure G1; procedure G2; procedure G3; procedure G4;
procedure G5; procedure G6; procedure G7; procedure G8;
procedure G9; procedure G10; procedure G11; procedure G12;
procedure G13; procedure G14; procedure G15; procedure G16;
procedure G17; procedure G18; procedure G19; procedure G20;
procedure G21; procedure G22; procedure G23; procedure G24;
procedure M1; procedure M2; procedure M3; procedure M4;
procedure M5; procedure M6; procedure M7; procedure M8;
procedure M9; procedure M10; procedure M11; procedure M12;
procedure M13; procedure M14; procedure M15; procedure M16;
procedure M17; procedure M18; procedure M19; procedure M20;
procedure M21; procedure M22; procedure M23; procedure M24;
procedure N1; procedure N2; procedure N3; procedure N4;
procedure N5; procedure N6; procedure N7; procedure N8;
procedure N9; procedure N10; procedure N11; procedure N12;

const
    MANIM : array[1..24] of pointer =
    (@M1,@M2,@M3,@M4,@M5,@M6,@M7,@M8,@M9,@M10,@M11,@M12,@M13,@M14,@M15,@M16,@M17,@M18,@M19,@M20,@M21,@M22,@M23,@M24);
    GANIM : array[1..24] of pointer =
    (@G1,@G2,@G3,@G4,@G5,@G6,@G7,@G8,@G9,@G10,@G11,@G12,@G13,@G14,@G15,@G16,@G17,@G18,@G19,@G20,@G21,@G22,@G23,@G24);
    NANIM : array[1..12] of pointer = (@N1,@N2,@N3,@N4,@N5,@N6,@N7,@N8,@N9,@N10,@N11,@N12);


implementation

Procedure HOF; external; {$L HOF.OBJ}
Procedure G1  ; external; {$L G1.OBJ}  Procedure G2  ; external; {$L G2.OBJ}
Procedure G3  ; external; {$L G3.OBJ}  Procedure G4  ; external; {$L G4.OBJ}
Procedure G5  ; external; {$L G5.OBJ}  Procedure G6  ; external; {$L G6.OBJ}
Procedure G7  ; external; {$L G7.OBJ}  Procedure G8  ; external; {$L G8.OBJ}
Procedure G9  ; external; {$L G9.OBJ}  Procedure G10 ; external; {$L G10.OBJ}
Procedure G11 ; external; {$L G11.OBJ} Procedure G12 ; external; {$L G12.OBJ}
Procedure G13 ; external; {$L G13.OBJ} Procedure G14 ; external; {$L G14.OBJ}
Procedure G15 ; external; {$L G15.OBJ} Procedure G16 ; external; {$L G16.OBJ}
Procedure G17 ; external; {$L G17.OBJ} Procedure G18 ; external; {$L G18.OBJ}
Procedure G19 ; external; {$L G19.OBJ} Procedure G20 ; external; {$L G20.OBJ}
Procedure G21 ; external; {$L G21.OBJ} Procedure G22 ; external; {$L G22.OBJ}
Procedure G23 ; external; {$L G23.OBJ} Procedure G24 ; external; {$L G24.OBJ}
Procedure M1  ; external; {$L M1.OBJ}  Procedure M2  ; external; {$L M2.OBJ}
Procedure M3  ; external; {$L M3.OBJ}  Procedure M4  ; external; {$L M4.OBJ}
Procedure M5  ; external; {$L M5.OBJ}  Procedure M6  ; external; {$L M6.OBJ}
Procedure M7  ; external; {$L M7.OBJ}  Procedure M8  ; external; {$L M8.OBJ}
Procedure M9  ; external; {$L M9.OBJ}  Procedure M10 ; external; {$L M10.OBJ}
Procedure M11 ; external; {$L M11.OBJ} Procedure M12 ; external; {$L M12.OBJ}
Procedure M13 ; external; {$L M13.OBJ} Procedure M14 ; external; {$L M14.OBJ}
Procedure M15 ; external; {$L M15.OBJ} Procedure M16 ; external; {$L M16.OBJ}
Procedure M17 ; external; {$L M17.OBJ} Procedure M18 ; external; {$L M18.OBJ}
Procedure M19 ; external; {$L M19.OBJ} Procedure M20 ; external; {$L M20.OBJ}
Procedure M21 ; external; {$L M21.OBJ} Procedure M22 ; external; {$L M22.OBJ}
Procedure M23 ; external; {$L M23.OBJ} Procedure M24 ; external; {$L M24.OBJ}
Procedure N1  ; external; {$L N1.OBJ}  Procedure N2  ; external; {$L N2.OBJ}
Procedure N3  ; external; {$L N3.OBJ}  Procedure N4  ; external; {$L N4.OBJ}
Procedure N5  ; external; {$L N5.OBJ}  Procedure N6  ; external; {$L N6.OBJ}
Procedure N7  ; external; {$L N7.OBJ}  Procedure N8  ; external; {$L N8.OBJ}
Procedure N9  ; external; {$L N9.OBJ}  Procedure N10 ; external; {$L N10.OBJ}
Procedure N11 ; external; {$L N11.OBJ} Procedure N12 ; external; {$L N12.OBJ}

end.