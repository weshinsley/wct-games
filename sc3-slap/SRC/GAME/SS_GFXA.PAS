Unit SS_GFXA;
Interface

Procedure WAISTPIC;
Procedure SLAPHAND;
Procedure EXPL_1;
Procedure HND_LITT;

Implementation

Procedure WAISTPIC; external;
{$L WAIST.OBJ}

Procedure SLAPHAND; external;
{$L SLAPHAND.OBJ}

Procedure EXPL_1; external;
{$L SLAP_EX1.OBJ}

Procedure HND_LITT; external;
{$L HND_LITT.OBJ}


end.