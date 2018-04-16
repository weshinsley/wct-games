unit berrybin;
interface

procedure R11; procedure R12; procedure R13; procedure R14; procedure R15;
procedure R16; procedure R17; procedure R18; procedure R19; procedure R1A;
procedure R1B; procedure R21; procedure R22; procedure R23; procedure R24;
procedure R25; procedure R26; procedure R27; procedure R28; procedure R29;
procedure R2A; procedure R2B; procedure R31; procedure R32; procedure R33;
procedure R34; procedure R35; procedure R36; procedure R37; procedure R38;
procedure R39; procedure R3A; procedure R3B; procedure R41; procedure R42;
procedure R43; procedure R44; procedure R45; procedure R46; procedure R47;
procedure R48; procedure R49; procedure R4A; procedure R4B; procedure R51;
procedure R52; procedure R53; procedure R54; procedure R55; procedure R56;
procedure R57; procedure R58; procedure R59; procedure R5A; procedure R5B;
procedure R61; procedure R62; procedure R63; procedure R64; procedure R65;
procedure R66; procedure R67; procedure R68; procedure R69; procedure R6A;
procedure R6B; procedure R71; procedure R72; procedure R73; procedure R74;
procedure R75; procedure R76; procedure R77; procedure R78; procedure R79;
procedure R7A; procedure R7B; procedure R81; procedure R82; procedure R83;
procedure R84; procedure R85; procedure R86; procedure R87; procedure R88;
procedure R89; procedure R8A; procedure R8B; procedure R91; procedure R92;
procedure R93; procedure R94; procedure R95; procedure R96; procedure R97;
procedure R98; procedure R99; procedure R9A; procedure R9B; procedure RA1;
procedure RA2; procedure RA3; procedure RA4; procedure RA5; procedure RA6;
procedure RA7; procedure RA8; procedure RA9; procedure RAA; procedure RAB;
procedure RB1; procedure RB2; procedure RB3; procedure RB4; procedure RB5;
procedure RB6; procedure RB7; procedure RB8; procedure RB9; procedure RBA;
procedure RBB; procedure RIBPAL; procedure SRIB; procedure TLeft; procedure TRight;
procedure BAN1; procedure BAN2; procedure BAN3; procedure BAN4; procedure BAN5;
procedure BIGBAN1; procedure BIGBAN2; procedure BIGBAN3; procedure BIGBAN4; procedure BIGBAN5;
procedure LASBAN1; procedure LASBAN2; procedure LASBAN3; procedure LASBAN4; procedure LASBAN5;
procedure SchPed; procedure Ic5; procedure Ic6; procedure Ic7; procedure MRFIZZ;
procedure IC8;

const BBMP : array[1..11,1..11] of pointer = ((@R11,@R21,@R31,@R41,@R51,@R61,@R71,@R81,@R91,@RA1,@RB1),
(@R12,@R22,@R32,@R42,@R52,@R62,@R72,@R82,@R92,@RA2,@RB2),(@R13,@R23,@R33,@R43,@R53,@R63,@R73,@R83,@R93,@RA3,@RB3),
(@R14,@R24,@R34,@R44,@R54,@R64,@R74,@R84,@R94,@RA4,@RB4),(@R15,@R25,@R35,@R45,@R55,@R65,@R75,@R85,@R95,@RA5,@RB5),
(@R16,@R26,@R36,@R46,@R56,@R66,@R76,@R86,@R96,@RA6,@RB6),(@R17,@R27,@R37,@R47,@R57,@R67,@R77,@R87,@R97,@RA7,@RB7),
(@R18,@R28,@R38,@R48,@R58,@R68,@R78,@R88,@R98,@RA8,@RB8),(@R19,@R29,@R39,@R49,@R59,@R69,@R79,@R89,@R99,@RA9,@RB9),
(@R1A,@R2A,@R3A,@R4A,@R5A,@R6A,@R7A,@R8A,@R9A,@RAA,@RBA),(@R1B,@R2B,@R3B,@R4B,@R5B,@R6B,@R7B,@R8B,@R9B,@RAB,@RBB));
      BANS : array[1..3,1..5] of pointer = ((@BAN1,@BAN2,@BAN3,@BAN4,@BAN5),(@BIGBAN1,@BIGBAN2,@BIGBAN3,@BIGBAN4,@BIGBAN5),
                                            (@LASBAN1,@LASBAN2,@LASBAN3,@LASBAN4,@LASBAN5));

implementation

procedure R11; external;{$L R11.OBJ} procedure R21; external;{$L R21.OBJ}
procedure R31; external;{$L R31.OBJ} procedure R41; external;{$L R41.OBJ}
procedure R51; external;{$L R51.OBJ} procedure R61; external;{$L R61.OBJ}
procedure R71; external;{$L R71.OBJ} procedure R81; external;{$L R81.OBJ}
procedure R91; external;{$L R91.OBJ} procedure RA1; external;{$L RA1.OBJ}
procedure RB1; external;{$L RB1.OBJ} procedure R12; external;{$L R12.OBJ}
procedure R22; external;{$L R22.OBJ} procedure R32; external;{$L R32.OBJ}
procedure R42; external;{$L R42.OBJ} procedure R52; external;{$L R52.OBJ}
procedure R62; external;{$L R62.OBJ} procedure R72; external;{$L R72.OBJ}
procedure R82; external;{$L R82.OBJ} procedure R92; external;{$L R92.OBJ}
procedure RA2; external;{$L RA2.OBJ} procedure RB2; external;{$L RB2.OBJ}
procedure R13; external;{$L R13.OBJ} procedure R23; external;{$L R23.OBJ}
procedure R33; external;{$L R33.OBJ} procedure R43; external;{$L R43.OBJ}
procedure R53; external;{$L R53.OBJ} procedure R63; external;{$L R63.OBJ}
procedure R73; external;{$L R73.OBJ} procedure R83; external;{$L R83.OBJ}
procedure R93; external;{$L R93.OBJ} procedure RA3; external;{$L RA3.OBJ}
procedure RB3; external;{$L RB3.OBJ} procedure R14; external;{$L R14.OBJ}
procedure R24; external;{$L R24.OBJ} procedure R34; external;{$L R34.OBJ}
procedure R44; external;{$L R44.OBJ} procedure R54; external;{$L R54.OBJ}
procedure R64; external;{$L R64.OBJ} procedure R74; external;{$L R74.OBJ}
procedure R84; external;{$L R84.OBJ} procedure R94; external;{$L R94.OBJ}
procedure RA4; external;{$L RA4.OBJ} procedure RB4; external;{$L RB4.OBJ}
procedure R15; external;{$L R15.OBJ} procedure R25; external;{$L R25.OBJ}
procedure R35; external;{$L R35.OBJ} procedure R45; external;{$L R45.OBJ}
procedure R55; external;{$L R55.OBJ} procedure R65; external;{$L R65.OBJ}
procedure R75; external;{$L R75.OBJ} procedure R85; external;{$L R85.OBJ}
procedure R95; external;{$L R95.OBJ} procedure RA5; external;{$L RA5.OBJ}
procedure RB5; external;{$L RB5.OBJ} procedure R16; external;{$L R16.OBJ}
procedure R26; external;{$L R26.OBJ} procedure R36; external;{$L R36.OBJ}
procedure R46; external;{$L R46.OBJ} procedure R56; external;{$L R56.OBJ}
procedure R66; external;{$L R66.OBJ} procedure R76; external;{$L R76.OBJ}
procedure R86; external;{$L R86.OBJ} procedure R96; external;{$L R96.OBJ}
procedure RA6; external;{$L RA6.OBJ} procedure RB6; external;{$L RB6.OBJ}
procedure R17; external;{$L R17.OBJ} procedure R27; external;{$L R27.OBJ}
procedure R37; external;{$L R37.OBJ} procedure R47; external;{$L R47.OBJ}
procedure R57; external;{$L R57.OBJ} procedure R67; external;{$L R67.OBJ}
procedure R77; external;{$L R77.OBJ} procedure R87; external;{$L R87.OBJ}
procedure R97; external;{$L R97.OBJ} procedure RA7; external;{$L RA7.OBJ}
procedure RB7; external;{$L RB7.OBJ} procedure R18; external;{$L R18.OBJ}
procedure R28; external;{$L R28.OBJ} procedure R38; external;{$L R38.OBJ}
procedure R48; external;{$L R48.OBJ} procedure R58; external;{$L R58.OBJ}
procedure R68; external;{$L R68.OBJ} procedure R78; external;{$L R78.OBJ}
procedure R88; external;{$L R88.OBJ} procedure R98; external;{$L R98.OBJ}
procedure RA8; external;{$L RA8.OBJ} procedure RB8; external;{$L RB8.OBJ}
procedure R19; external;{$L R19.OBJ} procedure R29; external;{$L R29.OBJ}
procedure R39; external;{$L R39.OBJ} procedure R49; external;{$L R49.OBJ}
procedure R59; external;{$L R59.OBJ} procedure R69; external;{$L R69.OBJ}
procedure R79; external;{$L R79.OBJ} procedure R89; external;{$L R89.OBJ}
procedure R99; external;{$L R99.OBJ} procedure RA9; external;{$L RA9.OBJ}
procedure RB9; external;{$L RB9.OBJ} procedure R1A; external;{$L R1A.OBJ}
procedure R2A; external;{$L R2A.OBJ} procedure R3A; external;{$L R3A.OBJ}
procedure R4A; external;{$L R4A.OBJ} procedure R5A; external;{$L R5A.OBJ}
procedure R6A; external;{$L R6A.OBJ} procedure R7A; external;{$L R7A.OBJ}
procedure R8A; external;{$L R8A.OBJ} procedure R9A; external;{$L R9A.OBJ}
procedure RAA; external;{$L RAA.OBJ} procedure RBA; external;{$L RBA.OBJ}
procedure R1B; external;{$L R1B.OBJ} procedure R2B; external;{$L R2B.OBJ}
procedure R3B; external;{$L R3B.OBJ} procedure R4B; external;{$L R4B.OBJ}
procedure R5B; external;{$L R5B.OBJ} procedure R6B; external;{$L R6B.OBJ}
procedure R7B; external;{$L R7B.OBJ} procedure R8B; external;{$L R8B.OBJ}
procedure R9B; external;{$L R9B.OBJ} procedure RAB; external;{$L RAB.OBJ}
procedure RBB; external;{$L RBB.OBJ} procedure RIBPAL; external; {$L RIBPAL.OBJ}
procedure Srib; external; {$L srib.obj} procedure TLeft; external; {$L Tleft.obj} procedure TRight; external; {$L TRight.obj}
procedure Ban1; external; {$L Ban1.obj} procedure Ban2; external; {$L Ban2.obj}
procedure Ban3; external; {$L Ban3.obj} procedure Ban4; external; {$L Ban4.obj}
procedure Ban5; external; {$L Ban5.obj} procedure BigBan1; external; {$L BigBan1.obj}
procedure BigBan2; external; {$L BigBan2.obj} procedure BigBan3; external; {$L BigBan3.obj}
procedure BigBan4; external; {$L BigBan4.obj} procedure BigBan5; external; {$L BigBan5.obj}
procedure lasBan1; external; {$L LasBan1.obj} procedure LasBan2; external; {$L LasBan2.obj}
procedure LasBan3; external; {$L LasBan3.obj} procedure LasBan4; external; {$L LasBan4.obj}
procedure LasBan5; external; {$L LasBan5.obj} procedure SchPed; external; {$L SchPed.obj}
procedure IC5; external; {$L IC5.obj} procedure IC6; external; {$L IC6.OBJ}
procedure IC7; external; {$L IC7.obj} procedure MRFIZZ; external; {$L MRFIZZ.OBJ}
procedure IC8; external; {$L IC8.obj}




end.