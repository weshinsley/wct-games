Unit SS_GFX2;

Interface
Procedure des_mez;
Procedure des_wes;
Procedure des_jef;
Procedure des_pyr;
Procedure des_rock;
Procedure des_cac;
Procedure des_sand;
Procedure des_tree;

Implementation
Procedure des_mez; external;
{$L des_mez.obj}
Procedure des_wes; external;
{$L des_wes.obj}
Procedure des_jef; external;
{$L des_jef.obj}
Procedure des_pyr; external;
{$L des_pyr.obj}
Procedure des_rock; external;
{$L des_rock.obj}
Procedure des_cac; external;
{$L des_cac.obj}
Procedure des_sand; external;
{$L des_sand.obj}
Procedure des_tree; external;
{$L des_tree.obj}
end.

