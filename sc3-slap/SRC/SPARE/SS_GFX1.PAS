Unit SS_GFX1;

Interface
Procedure Urb_mez;
Procedure Urb_oz;
Procedure Urb_chr;
Procedure Urb_off;
Procedure Urb_hous;
Procedure Urb_cat;
Procedure Urb_dog;
Procedure urb_car;
Procedure Urb_plan;
Procedure Urb_bus;

Implementation
Procedure Urb_mez; external;
{$L urb_mez.obj}
Procedure Urb_oz; external;
{$L urb_oz.obj}
Procedure Urb_chr; external;
{$L urb_chr.obj}
Procedure Urb_off; external;
{$L urb_off.obj}
Procedure Urb_hous; external;
{$L urb_hous.obj}
Procedure Urb_cat; external;
{$L urb_cat.obj}
Procedure Urb_dog; external;
{$L urb_dog.obj}
Procedure urb_car; external;
{$L urb_car.obj}
Procedure Urb_plan; external;
{$L urb_plan.obj}
Procedure Urb_bus; external;
{$L urb_bus.obj}


{   ((Exist:True;XMove:True;Width:89;Height:128;XMDir:0;Name:'Des_mez'),
   (Exist:True;XMove:True;Width:90;Height:116;XMDir:0;Name:'Des_Wes'),
   (Exist:True;XMove:True;Width:90;Height:118;XMDir:0;Name:'Des_Jef'),
   (Exist:True;XMove:False;Width:165;Height:75;XMDir:0;Name:'Des_Pyr'),
   (Exist:True;XMove:False;Width:126;Height:70;XMDir:0;Name:'Des_Rock'),
   (Exist:True;XMove:False;Width:72;Height:88;XMDir:0;Name:'Des_Cac'),
   (Exist:True;XMove:False;Width:98;Height:125;XMDir:0;Name:'Des_Sand'),
   (Exist:True;XMove:False;Width:64;Height:113;XMDir:0;Name:'Des_Tree'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:96;Height:127;XMDir:0;Name:'Sky_Mez'),
   (Exist:True;XMove:True;Width:97;Height:118;XMDir:0;Name:'Sky_Stu'),
   (Exist:True;XMove:True;Width:95;Height:117;XMDir:0;Name:'Sky_Ben'),
   (Exist:True;XMove:True;Width:253;Height:103;XMDir:-1;Name:'Sky_Plan'),
   (Exist:True;XMove:True;Width:137;Height:51;XMDir:0;Name:'Sky_Cld'),
   (Exist:True;XMove:True;Width:210;Height:63;XMDir:0;Name:'Sky_Clds'),
   (Exist:True;XMove:True;Width:156;Height:83;XMDir:0;Name:'Sky_Bird'),
   (Exist:True;XMove:True;Width:92;Height:145;XMDir:0;Name:'Sky_Kite'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:88;Height:126;XMDir:0;Name:'For_Mez'),
   (Exist:True;XMove:True;Width:88;Height:122;XMDir:0;Name:'For_Wes'),
   (Exist:True;XMove:True;Width:89;Height:124;XMDir:0;Name:'For_Gaz'),
   (Exist:True;XMove:False;Width:166;Height:60;XMDir:0;Name:'For_Gras'),
   (Exist:True;XMove:False;Width:172;Height:65;XMDir:0;Name:'For_Grs2'),
   (Exist:True;XMove:False;Width:164;Height:84;XMDir:0;Name:'For_Tree'),
   (Exist:True;XMove:False;Width:84;Height:109;XMDir:0;Name:'For_Tre2'),
   (Exist:True;XMove:True;Width:68;Height:68;XMDir:0;Name:'For_Spid'),
   (Exist:True;XMove:True;Width:66;Height:64;XMDir:-1;Name:'For_Sqr'),
   (Exist:True;XMove:False;Width:120;Height:96;XMDir:0;Name:'For_Leav')),

   ((Exist:True;XMove:True;Width:103;Height:106;XMDir:0;Name:'Sea_Mez'),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Tom'),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Chr'),
   (Exist:True;XMove:True;Width:115;Height:79;XMDir:-1;Name:'Sea_Fish'),
   (Exist:True;XMove:True;Width:215;Height:76;XMDir:0;Name:'Sea_Shar'),
   (Exist:True;XMove:False;Width:262;Height:135;XMDir:0;Name:'Sea_Ship'),
   (Exist:True;XMove:True;Width:80;Height:100;XMDir:0;Name:'Sea_jell'),
   (Exist:True;XMove:False;Width:135;Height:75;XMDir:0;Name:'Sea_Tres'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:107;Height:171;XMDir:0;Name:'Arc_Mez'),
   (Exist:True;XMove:True;Width:109;Height:169;XMDir:0;Name:'Arc_Ed'),
   (Exist:True;XMove:True;Width:107;Height:169;XMDir:0;Name:'Arc_Ben'),
   (Exist:True;XMove:False;Width:181;Height:72;XMDir:0;Name:'Arc_Peak'),
   (Exist:True;XMove:False;Width:167;Height:95;XMDir:0;Name:'Arc_Tent'),
   (Exist:True;XMove:False;Width:62;Height:106;XMDir:0;Name:'Arc_Tree'),
   (Exist:True;XMove:False;Width:151;Height:90;XMDir:0;Name:'Arc_Iglo'),
   (Exist:True;XMove:False;Width:128;Height:70;XMDir:0;Name:'Arc_Rock'),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')));}
end.
