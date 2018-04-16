Unit CHED3_I2;
Interface

Procedure Presents;
Procedure Prod;
Procedure www4;
Procedure writby;
Procedure cwandt;
Procedure Slippy;

Implementation

Procedure Presents; external;
{$L Presents.obj}
Procedure Slippy; external;
{$L Slippy.obj}
Procedure Prod; external;
{$L Prod.obj}
Procedure www4; external;
{$L www4.obj}
Procedure writby; external;
{$L writby.obj}
Procedure cwandt; external;
{$L cwandt.obj}

end.