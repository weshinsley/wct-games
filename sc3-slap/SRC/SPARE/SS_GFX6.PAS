Unit ss_gfx6;

Interface
Procedure Arc_mez;
Procedure Arc_ed;
Procedure Arc_Ben;
Procedure Arc_Peak;
Procedure Arc_Tent;
Procedure Arc_Tree;
Procedure Arc_Iglo;
Procedure Arc_Rock;

Implementation
Procedure Arc_mez; external;
{$L Arc_mez.obj}

Procedure Arc_Ed; external;
{$L Arc_Ed.obj}

Procedure Arc_Ben; external;
{$L Arc_Ben.obj}

Procedure Arc_Peak; external;
{$L Arc_Peak.obj}

Procedure Arc_Tent; external;
{$L Arc_Tent.obj}

Procedure Arc_Tree; external;
{$L Arc_Tree.obj}

Procedure Arc_Iglo; external;
{$L Arc_Iglo.obj}

Procedure Arc_Rock; external;
{$L Arc_Rock.obj}

end.
