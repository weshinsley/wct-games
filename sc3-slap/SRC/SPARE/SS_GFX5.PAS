Unit ss_gfx5;

Interface
Procedure Sea_mez;
Procedure Sea_tom;
Procedure Sea_chr;
Procedure Sea_fish;
Procedure Sea_shar;
Procedure sea_ship;
Procedure sea_jell;
Procedure Sea_Tres;

Implementation
Procedure Sea_mez; external;
{$L Sea_mez.obj}

Procedure Sea_tom; external;
{$L Sea_Tom.obj}

Procedure Sea_chr; external;
{$L Sea_Chr.obj}

Procedure Sea_fish; external;
{$L Sea_Fish.obj}

Procedure Sea_shar; external;
{$L Sea_Shar.obj}

Procedure sea_ship; external;
{$L Sea_Ship.obj}

Procedure sea_jell; external;
{$L Sea_Jell.obj}

Procedure Sea_Tres; external;
{$L Sea_Tres.obj}

end.
