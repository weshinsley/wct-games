Unit CHED3_I5;
Interface

Procedure slappery;
Procedure slapping;

Implementation

Procedure slapping; external;
{$L slapping.obj}
Procedure slappery; external;
{$L slappery.obj}

end.