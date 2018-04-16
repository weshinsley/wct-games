Unit CHED3_I3;
Interface

Procedure www2;
Procedure redhand;
Procedure www3;
Procedure www1;
Procedure pinkhand;

Implementation

Procedure www1; external;
{$L www1.obj}
Procedure www2; external;
{$L www2.obj}
Procedure www3; external;
{$L www3.obj}
Procedure pinkhand; external;
{$L pinkhand.obj}
Procedure redhand; external;
{$L redhand.obj}


end.