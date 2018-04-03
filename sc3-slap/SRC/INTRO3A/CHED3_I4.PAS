Unit CHED3_I4;
Interface

Procedure WCTcol;
Procedure byww;
Procedure progby;
Procedure wctintby;

Implementation

Procedure progby; external;
{$L progby.obj}
Procedure wctcol; external;
{$L wctcol.obj}
Procedure wctintby; external;
{$L wctintby.obj}
Procedure byww; external;
{$L byww.obj}


end.