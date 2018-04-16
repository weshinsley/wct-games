{*** SHOOTING CHEDDERY PART III  (C) 1995 Tom Doel ***}
{*** Revision 1, June 1996                         ***}
{$M 65520,0,655360}

program Chedder3;
uses crt,graph,dos,mouseRMW,TDfonts,ss_gfx0,ss_gfxA;
Type
  keyrec=record
    kleft,kright,kup,kdown,kCTRL,kALT,kSHIFT: boolean;
    end;
  Level_type= record
       Speed,Background_colour,Prob_gfx,Prob_per,num_gfx: integer;
       Length: Longint; Track: integer; Title: String[15];
    end;
  Gfx_Type= record
       Exist: Boolean; numb,xp,yp,wid,hei,xmov: integer; end;
    Graphics_type= record
       Exist,XMove: Boolean; Width,Height,XMDir: integer; name: string;
       File_Size:integer; end;
  Fade_Type= record
       Rval,Gval,Bval,Rinc,Binc,Ginc: real end;
  RGBRec = record
    RedVal, GreenVal, BlueVal : Integer;
    Colornum: integer;
    end;
var
  TMW: Byte;    {Timer Wait}
  KbdIntVec : Procedure;
  keydata: Keyrec;
  Pval: Byte;
  errorinc: real;
  levelspeed: integer;
  level,energy,gm,gd,xpos,ypos,a,xinc,dist,page,gwait: integer;
  s_level,s_score: string;
  DirInfo: SearchRec;
  P: array[0..9] of pointer;
  Ex: array[1..6] of pointer;
  SL,RH: pointer;
  f: file;
  c: char;
  score,memseg,memofs,size: longint;
  Moveleft,Moveright,Quit,cheat,invuln,MegaSlapFlag: Boolean;
  flags: array[1..10] of boolean;
  graphix: array[1..10] of gfx_type;
  t1,t2,t3,t4,m1,m2: integer;
  cs: array[0..15] of fade_type;
  d,e,megaslaps,slapometer,hnd_xspeed,old_mousex,old_mousey: integer;

  TimerDelay: Word;
  TimerIntVec : Procedure;
  hi_text,hi_text2: string;
  sta2,end2,startcol,endcol,b,numfads,code: integer;
  PLOGO: pointer;
  ml,mr,kp,st,qt,hs,hsflag: boolean;
  ch: char;
  g: text;
  t_1: word;
  ri,bi,gi,rn,bn,gn: real;
  ri2,bi2,gi2,rn2,bn2,gn2,t_inc,t_now,t_sin,t2_inc,t2_now: real;
  hi_scores: array[1..6] of longint;
  hi_names: array[1..6] of string[50];
  s_hi_scores: array[1..6] of string[20];
  mc,txtnum,delaytxt,timetxt,vtxt,hnd_xpos,hnd_hits: integer;
  hxp,hyp,hxs,hys: array[1..6] of longint;
  hinumber,maxx,maxy,minx,miny,mulx,muly: longint;
  stars: array[1..500,1..3] of longint;
  sze: integer;


Const
  Biggest_File=72560;
  mem_sizes:array[0..9] of integer=
    (9638,9526,9526,13446,8454,17958,6922,7062,2346,6214);

  text_num=23;
  Title_text: array[1..text_num] of string[50]=
    ('','WCT presents','SHOOTING CHEDDERY III','SLAPPING SLAPPERY',
     'idea by Chris, intro by Wes','programming & graphics by Tom',
     'Slap your way through 6 levels',
     'and destroy the Evil Hand to complete the game',
     'Controls: Use the cursor keys to move left/right',
     'Move the mouse to aim the hand',
     'press left for a slap or right for a super-slap',
     'You can only slap when slapometer reads zero',
     'Watch your energy: it goes down when you crash',
     'When it is zero, the game is over!',
     'a WCT production especially for Merrick',
     'aren''t we nice!','','isn''t this the most stupid',
     'game you''ve ever played?','','(C) WCT / WAISTWEAR 1995',
     '-that''s Tom, Wes and Chris',
     '');
  Title_colours: array[1..text_num] of integer=
     (14,14,11,10,11,11,14,14,10,10,14,14,15,15,14,14,15,11,11,15,14,14,15);

  Mez: Fillpatterntype=(0,68,108,84,68,68,0,0);
  Pas_Colors : array[0..15] of RGBRec =
  (( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 0),
   ( RedVal:27;GreenVal:27;BlueVal:27;ColorNum: 1),
   ( RedVal:33;GreenVal:33;BlueVal:33;ColorNum: 2),
   ( RedVal:39;GreenVal:39;BlueVal:39;ColorNum: 3),
   ( RedVal:45;GreenVal:45;BlueVal:45;ColorNum: 4),
   ( RedVal:51;GreenVal:51;BlueVal:51;ColorNum: 5),
   ( RedVal:57;GreenVal:57; BlueVal:57;ColorNum: 6),
   ( RedVal:63;GreenVal:63;BlueVal:63;ColorNum: 7),
   ( RedVal:26;GreenVal:26;BlueVal:26;ColorNum: 8),
   ( RedVal:0;GreenVal:18;BlueVal:18;ColorNum: 9),
   ( RedVal:0;GreenVal:27;BlueVal:27;ColorNum: 10),
   ( RedVal:0;GreenVal:36;BlueVal:36;ColorNum: 11),
   ( RedVal:0;GreenVal:45;BlueVal:45;ColorNum: 12),
   ( RedVal:0;GreenVal:54;BlueVal:54;ColorNum: 13),
   ( RedVal:0;GreenVal:63;BlueVal:63;ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:0;ColorNum: 15));
  Colours : array[0..15] of RGBRec = (
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 0),
   ( RedVal:31;GreenVal:0;BlueVal:0;ColorNum: 1),
   ( RedVal:0;GreenVal:31;BlueVal:0;ColorNum: 2),
   ( RedVal:31;GreenVal:31;BlueVal:0;ColorNum: 3),
   ( RedVal:0;GreenVal:0;BlueVal:31;ColorNum: 4),
   ( RedVal:31;GreenVal:0;BlueVal:31;ColorNum: 5),
   ( RedVal:0;GreenVal:31; BlueVal:31;ColorNum: 6),
   ( RedVal:47;GreenVal:47;BlueVal:47;ColorNum: 7),
   ( RedVal:31;GreenVal:31;BlueVal:31;ColorNum: 8),
   ( RedVal:63;GreenVal:0;BlueVal:0;ColorNum: 9),
   ( RedVal:0;GreenVal:63;BlueVal:0;ColorNum: 10),
   ( RedVal:63;GreenVal:63;BlueVal:0;ColorNum: 11),
   ( RedVal:0;GreenVal:0;BlueVal:63;ColorNum: 12),
   ( RedVal:63;GreenVal:0;BlueVal:63;ColorNum: 13),
   ( RedVal:0;GreenVal:63;BlueVal:63;ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:63;ColorNum: 15));
  Colours_alt : array[0..15] of RGBRec = (
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 0),
   ( RedVal:15;GreenVal:0;BlueVal:0;ColorNum: 1),
   ( RedVal:0;GreenVal:15;BlueVal:0;ColorNum: 2),
   ( RedVal:31;GreenVal:15;BlueVal:0;ColorNum: 3),
   ( RedVal:0;GreenVal:0;BlueVal:15;ColorNum: 4),
   ( RedVal:15;GreenVal:0;BlueVal:15;ColorNum: 5),
   ( RedVal:0;GreenVal:15; BlueVal:15;ColorNum: 6),
   ( RedVal:23;GreenVal:23;BlueVal:23;ColorNum: 7),
   ( RedVal:15;GreenVal:15;BlueVal:15;ColorNum: 8),
   ( RedVal:31;GreenVal:0;BlueVal:0;ColorNum: 9),
   ( RedVal:0;GreenVal:31;BlueVal:0;ColorNum: 10),
   ( RedVal:31;GreenVal:31;BlueVal:0;ColorNum: 11),
   ( RedVal:0;GreenVal:0;BlueVal:31;ColorNum: 12),
   ( RedVal:31;GreenVal:0;BlueVal:31;ColorNum: 13),
   ( RedVal:0;GreenVal:31;BlueVal:31;ColorNum: 14),
   ( RedVal:31; GreenVal:31; BlueVal:31;ColorNum: 15));
  sizeEXx=209; sizeEXy=134;
  Win_Colours : array[0..15] of RGBRec = (
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 0),
   ( RedVal:31;GreenVal:0;BlueVal:0;ColorNum: 1),
   ( RedVal:0;GreenVal:31;BlueVal:0;ColorNum: 2),
   ( RedVal:31;GreenVal:31;BlueVal:0;ColorNum: 3),
   ( RedVal:0;GreenVal:0;BlueVal:31;ColorNum: 4),
   ( RedVal:31;GreenVal:0;BlueVal:31;ColorNum: 5),
   ( RedVal:0;GreenVal:31; BlueVal:31;ColorNum: 6),
   ( RedVal:31;GreenVal:31;BlueVal:31;ColorNum: 7),
   ( RedVal:47;GreenVal:47;BlueVal:47;ColorNum: 8),
   ( RedVal:63;GreenVal:0;BlueVal:0;ColorNum: 9),
   ( RedVal:0;GreenVal:63;BlueVal:0;ColorNum: 10),
   ( RedVal:63;GreenVal:63;BlueVal:0;ColorNum: 11),
   ( RedVal:0;GreenVal:0;BlueVal:63;ColorNum: 12),
   ( RedVal:63;GreenVal:0;BlueVal:63;ColorNum: 13),
{   ( RedVal:0;GreenVal:63;BlueVal:63;ColorNum: 14),}
   ( RedVal:0;GreenVal:0;BlueVal:0;ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:63;ColorNum: 15));

   Level_data: array[1..7] of level_type=
   ((Speed:6;Background_colour:7;Prob_gfx:60;Prob_per:6;num_gfx:7;
        Length:3000;Track:2;Title:'Urban Zone'),
   (Speed:9;Background_colour:11;Prob_gfx:80;Prob_per:7;num_gfx:5;
        Length:4000;Track:4;Title:'Desert Zone'),
   (Speed:12;Background_colour:6;Prob_gfx:140;Prob_per:9;num_gfx:5;
        Length:5000;Track:6;Title:'Sky Zone'),
   (Speed:9;Background_colour:3;Prob_gfx:100;Prob_per:10;num_gfx:7;
        Length:4000;Track:8;Title:'Forest Zone'),
   (Speed:12;Background_colour:4;Prob_gfx:90;Prob_per:7;num_gfx:5;
        Length:7000;Track:10;Title:'Sea Zone'),
   (Speed:12;Background_colour:15;Prob_gfx:80;Prob_per:8;num_gfx:5;
        Length:8000;track:12;Title:'Arctic Zone'),

   (Speed:3;Background_colour:15;Prob_gfx:0;Prob_per:200;num_gfx:4;
        Length:0;track:14;Title:'Evil Hand'));

   hnd_ypos=280;
   Graphics_data: array[1..7,0..9] of graphics_type={0=Mez, 1,2_per, 3-9-gfx}
   (((Exist:True;XMove:True;Width:84;Height:128;XMDir:0;Name:'Urb_mez';File_Size:5682),
   (Exist:True;XMove:True;Width:82;Height:112;XMDir:0;Name:'Urb_Oz';File_Size:4978),
   (Exist:True;XMove:True;Width:92;Height:129;XMDir:0;Name:'Urb_Chr';File_Size:6246),
   (Exist:True;XMove:False;Width:77;Height:133;XMDir:0;Name:'Urb_Off';File_Size:5366),
   (Exist:True;XMove:False;Width:98;Height:77;XMDir:0;Name:'Urb_Hous';File_Size:4114),
   (Exist:True;XMove:False;Width:66;Height:64;XMDir:0;Name:'Urb_Cat';File_Size:2382),
   (Exist:True;XMove:True;Width:55;Height:63;XMDir:0;Name:'Urb_Dog';File_Size:1826),
   (Exist:True;XMove:True;Width:144;Height:47;XMDir:-1;Name:'Urb_Car';File_Size:3654),
   (Exist:True;XMove:False;Width:47;Height:62;XMDir:0;Name:'Urb_Plan';File_Size:1770),
   (Exist:True;XMove:True;Width:192;Height:59;XMDir:-1;Name:'Urb_Bus';File_Size:6206)),

   ((Exist:True;XMove:True;Width:89;Height:128;XMDir:0;Name:'Des_mez';File_Size:6198),
   (Exist:True;XMove:True;Width:90;Height:116;XMDir:0;Name:'Des_Wes';File_Size:5622),
   (Exist:True;XMove:True;Width:90;Height:118;XMDir:0;Name:'Des_Jef';File_Size:5718),
   (Exist:True;XMove:False;Width:165;Height:75;XMDir:0;Name:'Des_Pyr';File_Size:6390),
   (Exist:True;XMove:False;Width:126;Height:70;XMDir:0;Name:'Des_Rock';File_Size:4550),
   (Exist:True;XMove:False;Width:72;Height:88;XMDir:0;Name:'Des_Cac';File_Size:3566),
   (Exist:True;XMove:False;Width:98;Height:125;XMDir:0;Name:'Des_Sand';File_Size:6610),
   (Exist:True;XMove:False;Width:64;Height:113;XMDir:0;Name:'Des_Tree';File_Size:4110),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:96;Height:127;XMDir:0;Name:'Sky_Mez';File_Size:6662),
   (Exist:True;XMove:True;Width:97;Height:118;XMDir:0;Name:'Sky_Stu';File_Size:6194),
   (Exist:True;XMove:True;Width:112;Height:131;XMDir:0;Name:'Sky_Andy';File_Size:7926),
   (Exist:True;XMove:True;Width:149;Height:49;XMDir:-1;Name:'Sky_Plan';File_Size:3806),
   (Exist:True;XMove:True;Width:137;Height:51;XMDir:0;Name:'Sky_Cld';File_Size:3750),
   (Exist:True;XMove:True;Width:210;Height:63;XMDir:0;Name:'Sky_Clds';File_Size:6918),
   (Exist:True;XMove:True;Width:156;Height:83;XMDir:0;Name:'Sky_Bird';File_Size:6806),
   (Exist:True;XMove:True;Width:92;Height:145;XMDir:0;Name:'Sky_Kite';File_Size:7062),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:88;Height:126;XMDir:0;Name:'For_Mez';File_Size:6150),
   (Exist:True;XMove:True;Width:88;Height:122;XMDir:0;Name:'For_Wes';File_Size:5910),
   (Exist:True;XMove:True;Width:89;Height:124;XMDir:0;Name:'For_Gaz';File_Size:6054),
   (Exist:True;XMove:False;Width:166;Height:60;XMDir:0;Name:'For_Gras';File_Size:5214),
   (Exist:True;XMove:False;Width:172;Height:65;XMDir:0;Name:'For_Grs2';File_Size:5814),
   (Exist:True;XMove:False;Width:164;Height:84;XMDir:0;Name:'For_Tree';File_Size:7146),
   (Exist:True;XMove:False;Width:84;Height:109;XMDir:0;Name:'For_Tre2';File_Size:4846),
   (Exist:True;XMove:True;Width:68;Height:68;XMDir:0;Name:'For_Spid';File_Size:2490),
   (Exist:True;XMove:True;Width:66;Height:64;XMDir:1;Name:'For_Sqr';File_Size:2346),
   (Exist:True;XMove:False;Width:120;Height:96;XMDir:0;Name:'For_Leav';File_Size:6214)),

   ((Exist:True;XMove:True;Width:103;Height:106;XMDir:0;Name:'Sea_Mez';File_Size:5570),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Tom';File_Size:5998),
   (Exist:True;XMove:True;Width:104;Height:106;XMDir:0;Name:'Sea_Chr';File_Size:5998),
   (Exist:True;XMove:True;Width:115;Height:79;XMDir:1;Name:'Sea_Fish';File_Size:4806),
   (Exist:True;XMove:True;Width:215;Height:76;XMDir:1;Name:'Sea_Shar';File_Size:8430),
   (Exist:True;XMove:False;Width:262;Height:135;XMDir:0;Name:'Sea_Ship';File_Size:17958),
   (Exist:True;XMove:True;Width:80;Height:100;XMDir:0;Name:'Sea_jell';File_Size:4494),
   (Exist:True;XMove:False;Width:135;Height:75;XMDir:0;Name:'Sea_Tres';File_Size:5478),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:107;Height:171;XMDir:0;Name:'Arc_Mez';File_Size:9638),
   (Exist:True;XMove:True;Width:109;Height:169;XMDir:0;Name:'Arc_Ed';File_Size:9526),
   (Exist:True;XMove:True;Width:107;Height:169;XMDir:0;Name:'Arc_Ben';File_Size:9526),
   (Exist:True;XMove:False;Width:181;Height:72;XMDir:0;Name:'Arc_Peak';File_Size:9482),
   (Exist:True;XMove:False;Width:167;Height:95;XMDir:0;Name:'Arc_Tent';File_Size:8454),
   (Exist:True;XMove:False;Width:62;Height:106;XMDir:0;Name:'Arc_Tree';File_Size:3494),
   (Exist:True;XMove:False;Width:151;Height:90;XMDir:0;Name:'Arc_Iglo';File_Size:6922),
   (Exist:True;XMove:False;Width:128;Height:70;XMDir:0;Name:'Arc_Rock';File_Size:4834),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')),

   ((Exist:True;XMove:True;Width:107;Height:171;XMDir:0;Name:'Arc_Mez';File_Size:9638),
   (Exist:True;XMove:True;Width:192;Height:69;XMDir:0;Name:'Hnd_norm';File_Size:7006),
   (Exist:True;XMove:True;Width:192;Height:168;XMDir:0;Name:'Hnd_Hit';File_Size:6906),
   (Exist:True;XMove:False;Width:28;Height:23;XMDir:0;Name:'Hnd_litt';File_Size:390),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:''),
   (Exist:False;XMove:False;Width:0;Height:0;XMDir:0;Name:'')));

Procedure No_Gfx;
begin
  clrscr;
  writeln('*********************** ERROR *******************************');
  writeln(' graphics files not found- Chedder3 needs 7 LEVEL?.GFX files');
  writeln(' eg. LEVEL1.GFX, LEVEL2.GFX, ... , LEVEL7.GFX');
  writeln('*************************************************************');
  while keypressed do ch:=readkey;
  writeln('Press any key');
  repeat until keypressed;
  halt(0);
end;

Procedure Graphics_Error;
begin
  clrscr;
  writeln('*********************** ERROR *******************************');
  Writeln(' Error occurred during graphics initialisation');
  Writeln(' '+GraphErrorMsg(Graphresult));
  writeln(' You may not have VGA/EGA graphics.');
  writeln(' If you have EGA, try running CHEDDER3 /EGA');
  writeln('*************************************************************');
  while keypressed do ch:=readkey;
  writeln('Press any key');
  repeat until keypressed;
  SetIntVec($08,@TimerIntVec);
  SetIntVec($9,@KbdIntVec);
  halt(0);
end;

Procedure SETRgb(nR,r,g,b:bYTE);
begin
  Port[$3c8]:=Nr;
  Port[$3c9]:=R;
  Port[$3c9]:=G;
  Port[$3c9]:=B;
End;

Procedure Flip_page;
begin
  page:=1-page;
  setactivepage(page);
  setvisualpage(1-page);
end;

Procedure set_pas_cols;
begin
  for a:=0 to 15 do begin
    setpalette(a,a);
    setrgbpalette(a,pas_colors[a].redval,pas_colors[a].greenval,pas_colors[a].blueval);
  end;
end;

Procedure VWait; assembler;
  asm
   @@loop1:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    jz      @@loop3  {Not in retrace}

   @@loop2:
    mov     dx,$3da  {Retrace already started- wait for next}
    in      ax,dx
    and     ax,8
    jnz     @@loop2

   @@loop3:          {Wait until retrace}
    mov     dx,$3da
    in      ax,dx
    and     ax,8

    jz      @@loop3
  end;

Procedure load_hi_scores;
begin
  assign(g,'SLAPTAB.DAT');
  reset(g);
  for a:=1 to 6 do begin
    readln(g,hi_names[a]);
    readln(g,s_hi_scores[a]);
    Val(s_hi_scores[a],hi_scores[a],code);
    end;
  close(g);
end;

Procedure save_hi_scores;
begin
  assign(g,'SLAPTAB.DAT');
  rewrite(g);
  for a:=1 to 6 do begin
    writeln(g,hi_names[a]);
    writeln(g,s_hi_scores[a]);
    end;
  close(g);
end;

Procedure Hi_setup;
begin
  setbkcolor(black); cleardevice;
  flip_page;
  cleardevice;
  set_pas_cols;
  setrgbpalette(0,0,0,0);
  hi_text:='Hi-scores'; hi_text2:='serocS-iH';
  hinumber:=0;
  setfillstyle(1,0);
  a:=0;
  repeat
    inc(a);
    stars[a,1]:=round(random*640);
    stars[a,2]:=round(random*350);
    stars[a,3]:=round(random*10)+1;
  until a>=500;
  a:=0;
  repeat
    inc(a);
    hxp[a]:=30*(7-a); hyp[a]:=20*(7-a);
    hxs[a]:=10; hys[a]:=10;
  until a>=6;
  settextstyle(9,0,8);
  settextjustify(centertext,toptext);
  maxx:=550; maxy:=330;
  minx:=110; miny:=0;
  mulx:=-1; muly:=-1;
  t2_now:=0; t2_inc:=pi/20;
end;

Procedure view_hi_scores;
begin
  if keypressed then kp:=false else kp:=true;
  mouseinfo;
  if mouse.left then ml:=false else ml:=true;
  if mouse.right then mr:=false else mr:=true;
  repeat {<<<}
    a:=0;
    t2_now:=t2_now+t2_inc; if t2_now>=(2*pi) then t2_now:=t2_now-(2*pi);
    sze:=round(14*sin(t2_now));
    repeat
      inc(a);
      stars[a,1]:=stars[a,1]+(stars[a,3]*mulx);
      stars[a,2]:=stars[a,2]+(stars[a,3]*muly);
      if stars[a,1]<1 then stars[a,1]:=639;
      if stars[a,1]>639 then stars[a,1]:=1;
      if stars[a,2]<1 then stars[a,2]:=349;
      if stars[a,2]>349 then stars[a,2]:=1;
    until (a>=100);
    a:=0;
    repeat
      inc(a);
      hxp[a]:=hxp[a]+hxs[a];
      hyp[a]:=hyp[a]+hys[a];
      if hxp[a]<minx then begin hxp[a]:=minx-(hxp[a]-minx); hxs[a]:=-hxs[a];
        if a=1 then mulx:=-mulx; end;
      if hyp[a]<miny then begin hyp[a]:=miny-(hyp[a]-miny); hys[a]:=-hys[a];
        if a=1 then muly:=-muly; end;
      if hxp[a]>maxx then begin hxp[a]:=maxx-(hxp[a]-maxx); hxs[a]:=-hxs[a];
        if a=1 then mulx:=-mulx; end;
      if hyp[a]>maxy then begin hyp[a]:=maxy-(hyp[a]-maxy); hys[a]:=-hys[a];
        if a=1 then muly:=-muly; end;
    until (a>=6);
    a:=0;
    page:=1-page;
    setvisualpage(1-page);
    setactivepage(page);
    vwait;
    cleardevice;

    repeat
      inc(a);
      putpixel(stars[a,1],stars[a,2],trunc((stars[a,3]-1)/2)+2);
      if (a<7) then begin
        if (hinumber=0) then setcolor(15-a);
        if (a=hinumber) then setcolor(14);
        if (a<>hinumber) and (hinumber<>0) then setcolor(10);
        settextstyle(9,0,1);
        setusercharsize(8+(7-a)*2,30,(7-a)+7,40);
        outtextxy(hxp[a],hyp[a],hi_names[a]+' '+s_hi_scores[a]);
      end;
    until (a>=100);
    settextstyle(6,0,1);
    setcolor(15);
    if sze>=0 then begin
      setusercharsize(4*sze,30,30,15);
      outtextxy(320,120,hi_text);
    end else begin
      setusercharsize(4*(-sze),30,30,15); outtextxy(320,120,hi_text2);
    end;
    mouseinfo;
    if not mouse.left then ml:=true;
    if not mouse.right then mr:=true;
    if not keypressed then kp:=true;
    if (keypressed and not kp) then ch:=readkey;
  until (keypressed and kp) or (mouse.left and ml) or (mouse.right and mr);
end;

{$F+,S-}
procedure TimerHandler; interrupt;
begin
  If TimerDelay<20 then Inc(TimerDelay);
  inline ($9C);
  TimerIntVec;
end;
{$F-,S+}

{$F+,S-}
procedure Keyclick; interrupt;
begin
  Pval:=Port[$60];
  if Pval < $80 then begin
    if Pval=$1D then keydata.kCTRL:=true
    else if Pval=$10 then keydata.kCTRL:=true
    else if Pval=$38 then keydata.kALT:=true
    else if Pval=$2A then keydata.kSHIFT:=true
    else if Pval=$36 then keydata.kSHIFT:=true
    else if Pval=$48 then keydata.kUP:=true
    else if Pval=$50 then keydata.kDOWN:=true
    else if Pval=$4B then keydata.kLEFT:=true
    else if Pval=$4D then keydata.kRIGHT:=true
  end else begin
    Dec(Pval,$80);
    if Pval=$1D then keydata.kCTRL:=false
    else if Pval=$10 then keydata.kCTRL:=false
    else if Pval=$38 then keydata.kALT:=false
    else if Pval=$2A then keydata.kSHIFT:=false
    else if Pval=$36 then keydata.kSHIFT:=false
    else if Pval=$48 then keydata.kUP:=false
    else if Pval=$50 then keydata.kDOWN:=false
    else if Pval=$4B then keydata.kLEFT:=false
    else if Pval=$4D then keydata.kRIGHT:=false;
  end;
  inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  KbdIntVec;
end;
{$F-,S+}

Function input_hi_name: string;
var
  hin: string;
  c: char;
begin
  hi_text:='New hi-score'; hi_text2:='Enter your name';
  hin:='';
  repeat
    repeat
      hi_names[hinumber]:=hin+'<';
      view_hi_scores;
    until keypressed;
    c:=readkey;
    if (c>=' ') and (c<='}') and (length(hin)<50) then hin:=hin+c;
    if (c=chr(8)) and (length(hin)>0) then hin:=copy(hin,1,length(hin)-1);
  until c=chr(13);
  input_hi_name:=hin;
  hi_text:='Hi-scores'; hi_text2:='serocs-iH';
end;

Procedure Check_hi_scores;
begin
  hinumber:=0; hsflag:=false;
  repeat
    inc(hinumber);
    if score>hi_scores[hinumber] then begin
      hsflag:=true;
      if hinumber<6 then begin
        for b:=6 downto hinumber+1 do begin
          hi_names[b]:=hi_names[b-1];
          s_hi_scores[b]:=s_hi_scores[b-1];
          hi_scores[b]:=hi_scores[b-1];
        end;
      end;
      hi_scores[hinumber]:=score;
      Str(score,s_hi_scores[hinumber]);
      hi_names[hinumber]:=input_hi_name;
      save_hi_scores;
    end;
  until (hinumber>5) or (hsflag=true);
  hinumber:=0;
end;

Procedure Dp_colours;
var
   i:integer;
begin
for i := 0 to 15 do
  with Colours[i] do begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
    setpalette(i,i);
  end;
end;

Procedure Windows_colours;
var
   i:integer;
begin
for i := 0 to 15 do
  with Win_Colours[i] do begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
    setpalette(i,i);
  end;
end;

Procedure Windows_colours2;
var
   i:integer;
begin
for i := 0 to 15 do
  with Win_Colours[i] do begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
  end;
end;

Procedure Draw_Mez;
begin
  Putimage(xpos,ypos,P[0]^,orput);
end;

Procedure get_graphics(levnum: integer);
begin
  assign(f,'level'+s_level+'.gfx');
  reset(f,1);
  for a:=0 to 9 do begin
    if graphics_data[levnum,a].exist then begin
      Blockread(f,P[a]^,graphics_data[levnum,a].file_size);
    end;
  end;
  close(f);
end;

Procedure Mem_Err;
begin
  clrscr;
  writeln('*********************** ERROR *******************************');
  writeln(' Not enough memory to load graphics files.');
  writeln(' If you are running Windows, try quitting,');
  writeln(' Otherwise, try rebooting and don''t load any TSRs');
  writeln('*************************************************************');
  while keypressed do ch:=readkey;
  writeln('Press any key');
  repeat until keypressed;
  SetIntVec($08,@TimerIntVec);
  SetIntVec($9,@KbdIntVec);
  halt(0);
end;

Procedure get_memory;
var  bb: integer;
begin
  for a:=0 to 9 do begin
    if MaxAvail<mem_sizes[a] then begin
      if a<>0 then begin
        for bb:=a-1 downto 0 do freemem(p[a],mem_sizes[a]);
      end;
      mem_err;
    end;
    getmem(p[a],mem_sizes[a]);
  end;
end;

Procedure free_memory;
begin
  for a:=0 to 9 do freemem(p[a],mem_sizes[a]);
end;

Procedure Stats_Update;
begin
  str(score,s_score);
  settextstyle(2,0,5); settextjustify(lefttext,centertext);
  setcolor(12);
  outtextxy(5,5,'LEVEL '+s_level+'          ENERGY:');
  outtextxy(5,20,'SCORE: '+s_score);
  outtextxy(400,5,'MEGASLAPS:');
  outtextxy(127,20,'DISTANCE:');
  outtextxy(392,20,'SLAPOMETER:');
  setfillstyle(6,9);
  bar(200,2,200+round(1.5*energy),12);
  if slapometer>0 then bar(480,18,480+slapometer*15,28);
  if megaslaps>0 then bar(480,2,480+30*megaslaps,12);
  if dist<level_data[level].length then
    bar(200,18,350-round(150/level_data[level].length*dist),28);
end;

Procedure All_back_fade(fadeinto,numfads: integer);
begin
  setactivepage(page);
  setvisualpage(page);
  stats_update;
  setcolor(12);
  settextjustify(centertext,centertext);
  settextstyle(1,0,14);
  if not flags[5] then begin
    outtextxy(320,80,'GAME');
    outtextxy(320,180,'OVER');
  end else begin
    outtextxy(320,80,'WELL');
    outtextxy(320,180,'DONE');
  end;
  for b:=0 to 15 do begin
    cs[b].rval:=Win_colours[b].redval;
    cs[b].gval:=Win_colours[b].greenval;
    cs[b].bval:=win_colours[b].blueval;
    if b=0 then begin
      e:=level_data[level].background_colour;
      cs[b].rval:=Win_colours[e].redval;
      cs[b].gval:=Win_colours[e].greenval;
      cs[b].bval:=Win_colours[e].blueval;
    end;
    Setpalette(b,b);
    cs[b].rinc:=(Win_colours[fadeinto].RedVal-cs[b].rval)/numfads;
    cs[b].ginc:=(Win_colours[fadeinto].GreenVal-cs[b].gval)/numfads;
    cs[b].binc:=(Win_colours[fadeinto].BlueVal-cs[b].bval)/numfads;
  end;

  d:=0;
  repeat
    inc(d);
    Vwait;
    for b:=0 to 15 do begin
      if b<>fadeinto then
        setrgb{palette}(b,round(cs[b].rval),round(cs[b].gval),round(cs[b].bval));
      cs[b].rval:=cs[b].rval+cs[b].rinc;
      cs[b].gval:=cs[b].gval+cs[b].ginc;
      cs[b].bval:=cs[b].bval+cs[b].binc;
    end;
  until d>=numfads+1;
  setbkcolor(fadeinto);
  vwait;
  cleardevice;
  flip_page;
end;

Procedure back_fade(startcol,endcol,numfads: integer);
var
   ri,bi,gi,rn,bn,gn: real;
begin
  stats_update;
  setcolor(9);
  settextjustify(centertext,centertext);
  settextstyle(10,0,7);
  outtextxy(320,150,'GET READY!');
  rn:=Win_colours[startcol].redval;
  gn:=Win_colours[startcol].greenval;
  bn:=Win_colours[startcol].blueval;
  setrgb{palette}(0,round(rn),round(gn),round(bn));
  Setpalette(0,0);
  ri:=(Win_colours[endcol].RedVal-rn)/numfads;
  gi:=(Win_colours[endcol].GreenVal-gn)/numfads;
  bi:=(Win_colours[endcol].BlueVal-bn)/numfads;
  b:=0;
  setvisualpage(page);
  repeat
    inc(b);
    Vwait;
    setrgb{palette}(0,round(rn),round(gn),round(bn));
    rn:=rn+ri; bn:=bn+bi; gn:=gn+gi;
  until b>=numfads+1;
  setbkcolor(endcol);
end;


Procedure Clear_off_Slappa_we_dont_want_you_here;
begin
  ypos:=ypos+10;
  setactivepage(1-page);
  setvisualpage(page);
  cleardevice;
  Stats_update;
  settextstyle(7,0,4);
  settextjustify(centertext,centertext);
  if not flags[5] then begin
    setcolor(10);
    outtextxy(320,100,'Congratulations!');
    outtextxy(320,140,'You passed that level');
  end else begin
    setcolor(1);
    outtextxy(320,100,'You destroyed');
    outtextxy(320,140,'The Evil Hand!');
  end;
  Putimage(xpos,ypos-10,P[0]^,xorput);

  setvisualpage(1-page); setactivepage(page);
  cleardevice;
  Stats_update;
  settextstyle(7,0,4);
  settextjustify(centertext,centertext);
  setcolor(10);
  if not flags[5] then begin
    outtextxy(320,100,'Congratulations!');
    outtextxy(320,140,'You passed that level');
  end else begin
    outtextxy(320,100,'You destroyed');
    outtextxy(320,140,'The Evil Hand!');
  end;
  Putimage(xpos,ypos,P[0]^,xorput);

  repeat
    ypos:=ypos+10;
    page:=(1-page);
    setactivepage(page);
    setvisualpage(1-page);
    Vwait;
    Putimage(xpos,ypos-20,P[0]^,xorput);
    if ypos<350 then Putimage(xpos,ypos,P[0]^,xorput);
  until ypos>=355;
  cleardevice;
end;

Procedure Scroll_Mez_On;
begin
  ypos:=ypos-20;
  cleardevice;
  Stats_update;
  settextstyle(3,0,4);
  settextjustify(centertext,centertext);
  setcolor(13);
  outtextxy(320,100,'Level '+s_level);
  outtextxy(320,140,level_data[level].title);
  Putimage(xpos,ypos+10,P[0]^,xorput);

  page:=1-page;
  setvisualpage(1-page); setactivepage(page);
  cleardevice;
  Stats_update;
  settextstyle(3,0,4);
  settextjustify(centertext,centertext);
  setcolor(13);
  outtextxy(320,100,'Level '+s_level);
  outtextxy(320,140,level_data[level].title);
  Putimage(xpos,ypos,P[0]^,xorput);

  repeat
    ypos:=ypos-10;
    page:=(1-page);
    setactivepage(page);
    setvisualpage(1-page);
    Vwait;
    if ypos<335 then Putimage(xpos,ypos+20,P[0]^,xorput);
    Putimage(xpos,ypos,P[0]^,xorput);
  until ypos<=40;
end;

Function check_crash(x1,y1,w1,l1,x2,y2,w2,l2: integer): boolean;
begin
  check_crash:=false;
  If ( x2<=(x1+w1) ) and ( (x2+w2)>=x1)
  and ( y2<=(y1+l1) ) and ( (y2+l2)>=y1) then check_crash:=true;
end;

Procedure Draw_Graphics;
begin
  for b:=1 to 10 do begin
    if graphix[b].exist then begin
      if graphix[b].numb<3 then begin
        if graphix[b].xp<xpos then graphix[b].xp:=graphix[b].xp+
          round(TMW*level_data[level].track/3);
        if graphix[b].xp>xpos then graphix[b].xp:=graphix[b].xp-
          round(TMW*level_data[level].track/3);
      end;
      graphix[b].xp:=graphix[b].xp+round((levelspeed/2)*graphix[b].xmov);
      graphix[b].yp :=graphix[b].yp-levelspeed;
      if graphix[b].yp<0 then graphix[b].exist:=false
      else begin
        if graphix[b].numb>9 then begin
          if graphix[b].xp-round((sizeEXx-graphix[b].wid)/2)<=0 then
            putimage(0,graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);
          if graphix[b].xp>=(639-sizeEXx) then
            putimage(639-sizeEXx,
                graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);
          if (graphix[b].xp-round((sizeEXx-graphix[b].wid)/2)>0) and (graphix[b].xp<640-sizeEXx) then
            putimage(graphix[b].xp-round((sizeEXx-graphix[b].wid)/2),
                graphix[b].yp-round((sizeEXy-graphix[b].hei)/2),
                EX[graphix[b].numb-9]^,orput);

          inc(graphix[b].numb);
          if graphix[b].numb>15 then graphix[b].exist:=false;
        end else
          putimage(graphix[b].xp,graphix[b].yp,P[graphix[b].numb]^,orput);
      end;
    end;
  end;
end;

Procedure Check_Slap;
begin
  if (getpixel(mouse.x,mouse.y)+getpixel(mouse.x+m1,mouse.y)+
  getpixel(mouse.x+round(m1/2),mouse.y+round(m2/2))+
    getpixel(mouse.x+m1,mouse.y+m2)+getpixel(mouse.x,mouse.y+m2))>0 then begin
    b:=0;
    repeat
      inc(b);
      if graphix[b].exist and (graphix[b].numb<10) then begin
        if check_crash(mouse.x,mouse.y,m1,m2,graphix[b].xp,graphix[b].yp,
            graphix[b].wid,graphix[b].hei) then begin
              graphix[b].numb:=10;
              score:=score+20;
        end;
      end;
    until b>9;
  end;
end;

Procedure Check_Slap_EHG;
begin
  if (getpixel(mouse.x,mouse.y)+getpixel(mouse.x+m1,mouse.y)+
    getpixel(mouse.x+m1,mouse.y+m2)+getpixel(mouse.x,mouse.y+m2))>0 then begin
    b:=0;
    repeat
      inc(b);
      if graphix[b].exist and (graphix[b].numb<10) then begin
        if check_crash(mouse.x,mouse.y,m1,m2,graphix[b].xp,graphix[b].yp,
                graphix[b].wid,graphix[b].hei) then begin
          graphix[b].numb:=15;
          score:=score+20;
        end;
      end;
    until b>9;

    if check_crash(mouse.x,mouse.y,m1,m2,hnd_xpos,hnd_ypos,
        graphics_data[7,1].width,graphics_data[7,1].height) then begin
      dec(hnd_hits); flags[6]:=true;
      if hnd_hits<1 then flags[5]:=true;
    end;
  end;
end;

Procedure Check_Mez_Crash;
begin
  if (getpixel(xpos,ypos+t2)+getpixel(xpos+t1,ypos+t2)+
       getpixel(xpos+t3,ypos+t2)+getpixel(xpos+2*t3,ypos+t2)+
       getpixel(xpos+t3 div 2,ypos+t2)+getpixel(xpos+t3+t3 div 2,ypos+t2)+
       getpixel(xpos,ypos+t4)+getpixel(xpos,ypos+2*t4)+
       getpixel(xpos+t1,ypos+t4)+getpixel(xpos+t1,ypos+2*t4))>0 then begin
    b:=0;
    repeat
      inc(b);
      if graphix[b].exist and (graphix[b].numb<10) then begin
        if check_crash(xpos,ypos,t1,t2,graphix[b].xp,graphix[b].yp,
               graphix[b].wid,graphix[b].hei) then begin
          if level<7 then graphix[b].numb:=12
                     else graphix[b].numb:=15;
          if not invuln then energy:=energy-10;
        end;
      end;
    until b>9;
  end;
end;

Procedure New_Graphic;
var probtot,d: integer;
begin
  flags[2]:=false;
  flags[3]:=false;
  probtot:=random(200);
  if (dist<level_data[level].length-350)
      and (probtot<(TMW*level_data[level].prob_gfx/3+TMW*level_data[level].prob_per/3))
      then begin
    if probtot<TMW*level_data[level].prob_gfx/3 then begin
      flags[2]:=true;
      b:=0;
      repeat
        inc(b);
        if not graphix[b].exist then begin
          flags[3]:=true;
          graphix[b].exist:=true;
          graphix[b].xp:=random(640);
          graphix[b].yp:=350;
          graphix[b].numb:=3+random(level_data[level].num_gfx);
          graphix[b].wid:=graphics_data[level,graphix[b].numb].width;
          graphix[b].hei:=graphics_data[level,graphix[b].numb].height;
          gwait:=graphix[b].hei;
          graphix[b].xmov:=0;
          if graphics_data[level,graphix[b].numb].XMove then begin
            graphix[b].xmov:=round(int(random(5)))-2;
            if graphics_data[level,graphix[b].numb].XMDir<>0 then
              graphix[b].xmov:=graphics_data[level,graphix[b].numb].XMDir*abs(graphix[b].xmov);
              graphix[b].xp:=320+random(320-graphix[b].wid)*(-graphics_data[level,graphix[b].numb].xmdir);
          end;
          for d:=1 to 10 do begin
            if (d<>b) and (graphix[d].exist) then begin
              if check_crash(graphix[b].xp,graphix[b].yp,graphix[b].wid,
                graphix[b].hei,graphix[d].xp,graphix[d].yp,graphix[d].wid,
                graphix[d].hei) then graphix[b].exist:=false;
            end;
          end;
        end;
      until (b>9) or (flags[3]);
    end else begin
      b:=0;
      repeat
        inc(b);
        if not graphix[b].exist then begin
          flags[3]:=true;
          graphix[b].exist:=true;
          graphix[b].xp:=random(640);
          graphix[b].yp:=350;
          graphix[b].numb:=1+random(2);
          graphix[b].wid:=graphics_data[level,graphix[b].numb].width;
          graphix[b].hei:=graphics_data[level,graphix[b].numb].height;
          gwait:=graphix[b].hei;
          graphix[b].xmov:=0;
          for d:=1 to 10 do begin
            if (d<>b) and (graphix[d].exist) then begin
              if check_crash(graphix[b].xp,graphix[b].yp,graphix[b].wid,
                graphix[b].hei,graphix[d].xp,graphix[d].yp,graphix[d].wid,
                graphix[d].hei) then graphix[b].exist:=false;
            end;
          end;
        end;
      until (b>9) or (flags[3]);
    end;
  end;
end;

Procedure New_Graphic_EHG;
begin
  b:=0;
  flags[3]:=false;
  if gwait>0 then gwait:=gwait-levelspeed;
  if gwait<1 then begin
    repeat
      inc(b);
      if not graphix[b].exist then begin
        flags[3]:=true;
        graphix[b].exist:=true;
        graphix[b].xp:=hnd_xpos;
        graphix[b].yp:=hnd_ypos+20;
        graphix[b].numb:=3;
        graphix[b].wid:=graphics_data[7,3].width;
        graphix[b].hei:=graphics_data[7,3].height;
        gwait:=graphix[b].hei;
        graphix[b].xmov:=0;
      end;
    until (flags[3]) or (b>9);
  end;
end;

Procedure Quick_Cls(pagenum: byte);
begin
  If pagenum=0 then
    asm
      push ds
      mov ax,$A000
      mov es,ax
      xor di,di
      mov cx,28000
      mov ah,0
      rep stosb
      pop ds

    end else asm
      push ds
      mov ax,$A800
      mov es,ax
      xor di,di
      mov cx,28000
      mov ah,0
      rep stosb
      pop ds
    end;
end;

Procedure Evil_Hand_Game;
var tewid,fl6_wait,timeel: integer;
begin
  hnd_hits:=20; hnd_xpos:=235; hnd_xspeed:=30; fl6_wait:=0; gwait:=0;
  for b:=1 to 10 do graphix[b].exist:=false;
  flags[5]:=false;
  flags[6]:=false;
  level:=7;
  str(level,s_level);
  get_graphics(7); timeel:=0;
  for a:=1 to 10 do graphix[a].exist:=false;
  levelspeed:=level_data[level].speed;
  TMW:=1; TimerDelay:=0;

  Repeat
    hnd_xpos:=hnd_xpos+round(TMW*hnd_xspeed/3);
    if hnd_xpos<0 then begin
      hnd_xspeed:=-hnd_xspeed; hnd_xpos:=-hnd_xpos;
    end;
    tewid:=639-graphics_data[7,1].width;
    if hnd_xpos>tewid then begin
      hnd_xspeed:=-hnd_xspeed; hnd_xpos:=tewid-(hnd_xpos-tewid);
    end;
    page:=(1-page);
    setactivepage(page);
    setvisualpage(1-page);
    mouseinfo;
    if mouse.left then begin
      if slapometer<1 then check_slap_EHG;
      if slapometer<10 then slapometer:=slapometer+2;
      if slapometer>10 then slapometer:=10;
    end else if slapometer>0 then dec(slapometer);

    If (Not mouse.right) then Megaslapflag:=False;
    if (mouse.right) and (megaslaps>0) and (not megaslapflag) then begin
      Megaslapflag:=true;
      dec(megaslaps);
      for b:=1 to 10 do begin
        if (graphix[b].exist) and (graphix[b].numb<10) then begin
          graphix[b].numb:=15;
          score:=score+5;
        end;
      end;
    end;

    c:='#';
    if keypressed then begin
      c:=readkey;
      while keypressed do c:=readkey;
      if c=chr(27) then flags[1]:=true;
      if Keydata.kLEFT and (xpos>20) then xpos:=xpos-10*TMW;
      if Keydata.kRIGHT and (xpos<(620-graphics_data[6,0].width)) then
        xpos:=xpos+10*TMW;
    end;

    Repeat
      Vwait;
      TMW:=TimerDelay;
    Until TMW>0;

    TimerDelay:=0;
    levelspeed:=trunc(TMW*level_data[level].speed/3);
    errorinc:=errorinc+(TMW*level_data[level].speed/3)-levelspeed;
    While errorinc>=1 do begin
      errorinc:=errorinc-1;
      Inc(levelspeed);
    end;

    Quick_CLS(page);
    Draw_Graphics;
    Check_Mez_Crash;
    Draw_Mez;
    Stats_update;
    if not flags[5] then begin
      if flags[6] then begin
        flags[6]:=false;  Putimage(hnd_xpos,hnd_ypos,P[2]^,orput);
      end else begin
        Putimage(hnd_xpos,hnd_ypos,P[1]^,orput);
      end;
      New_Graphic_EHG;
    end;

    if timeel<30 then begin
      inc(timeel); setcolor(random(15)); settextstyle(7,0,6);
      settextjustify(centertext,centertext);
      outtextxy(320,180,'Slap the evil hand!');
    end;

    Putimage(mouse.x,mouse.y,SL^,xorput);

    if (flags[5]) and (fl6_wait=0) then begin
      for b:=1 to 10 do begin
        if (graphix[b].exist) and (graphix[b].numb<10) then begin
          graphix[b].numb:=15; score:=score+20;
        end;
      end;

      graphix[10].exist:=true; graphix[10].numb:=10; fl6_wait:=10;
      graphix[10].xp:=hnd_xpos; graphix[10].yp:=hnd_ypos;
      graphix[10].wid:=graphics_data[7,1].width;
      graphix[10].hei:=graphics_data[7,1].height;
      score:=score+200;
    end;
    if fl6_wait>0 then dec(fl6_wait);
  until ((fl6_wait<1) and flags[5]) or (flags[1]) or (energy<1);
end;

Procedure Slap_Slap;
begin
  if mouse.left then begin
    if slapometer<1 then check_slap;
    if slapometer<10 then slapometer:=slapometer+2; {end;}
    if slapometer>10 then slapometer:=10;
  end else if slapometer>0 then begin
    dec(slapometer);
  end;

  If (Not mouse.right) then Megaslapflag:=False;
  if (mouse.right) and (megaslaps>0) and (not megaslapflag) then begin
    megaslapflag:=true;
    dec(megaslaps);
    for b:=1 to 10 do begin
      if (graphix[b].exist) and (graphix[b].numb<10) then begin
        graphix[b].numb:=10;
        score:=score+5;
      end;
    end;
  end;
end;

Procedure Game_loop;
begin
  errorinc:=0;
  setactivepage(page); setvisualpage(1-page);
  level:=0;  {<<<<<<<<<<<}
  setbkcolor(4);
  cleardevice;
  ypos:=345;
  repeat
    inc(level); slapometer:=0; megaslaps:=megaslaps+2; invuln:=false;
    if megaslaps>5 then megaslaps:=5;
    str(level,s_level);
    xpos:=280; xinc:=10; dist:=0;
    back_fade(getbkcolor,level_data[level].background_colour,200);
    setbkcolor(level_data[level].background_colour);
    get_graphics(level);
    Scroll_Mez_on;
    for b:=1 to 10 do graphix[b].exist:=false;
    t1:=graphics_data[level,0].width; t2:=graphics_data[level,0].height;
    t3:=round(t1/3); t4:=round(t2/3);
    levelspeed:=level_data[level].speed;
    TMW:=1; TimerDelay:=0;
    While keypressed do c:=readkey;

    Repeat
      page:=(1-page);
      setactivepage(page);
      setvisualpage(1-page);
      dist:=dist+levelspeed;

      c:='@';
      if keypressed then begin
        c:=readkey;
        while keypressed do c:=readkey;
        if cheat then begin
          if c='l' then dist:=level_data[level].length;
          if c='e' then energy:=100;
          if c='m' then megaslaps:=5;
          if (c='i') then begin
            if invuln then invuln:=false else invuln:=true;
          end;
        end;
      end;
      if KeyData.KLEFT{(ord(c)=75)} and (xpos>20) then xpos:=xpos-10*TMW;
      if KeyData.KRIGHT{(ord(c)=77)} and (xpos<(620-graphics_data[level,0].width)) then
        xpos:=xpos+10*TMW;
      if c=chr(27) then flags[1]:=true;

      slap_slap;

      Repeat
        Vwait;
        TMW:=TimerDelay;
      Until TMW>0;
      TimerDelay:=0;
      levelspeed:=trunc(TMW*level_data[level].speed/3);
      errorinc:=errorinc+(TMW*level_data[level].speed/3)-levelspeed;
      While errorinc>=1 do begin
        errorinc:=errorinc-1;
        Inc(levelspeed);
      end;

      Quick_Cls(page);
      Draw_Graphics;
      Check_Mez_Crash;
      Draw_Mez;
      Stats_update;
      New_Graphic;
      old_mousex:=mouse.x; old_mousey:=mouse.y;
      mouseinfo;
      Putimage(mouse.x,mouse.y,SL^,xorput);
      slap_slap;
    until (dist>level_data[level].length) or (flags[1]) or (energy<1);

    if energy<1 then begin
      for e:=3 to 7 do begin
        page:=(1-page);
        setactivepage(page);
        setvisualpage(1-page);
        dist:=dist+levelspeed;

        Repeat
          Vwait;
          TMW:=TimerDelay;
        Until TMW>0;
        TimerDelay:=0;
        levelspeed:=trunc(TMW*level_data[level].speed/3);
        errorinc:=errorinc+(TMW*level_data[level].speed/3)-levelspeed;
        While errorinc>=1 do begin
          errorinc:=errorinc-1;
          Inc(levelspeed);
        end;

        cleardevice;
        Draw_Graphics;
        New_graphic;
        if e<7 then begin
          if xpos-round((sizeEXx-graphics_data[level,0].width)/2)<=0 then
            Putimage(0,ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
          if xpos>=(639-sizeEXx) then
            Putimage(639-sizeEXx,ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
          if (xpos-round((sizeEXx-graphics_data[level,0].width)/2)>0) and (xpos<639-sizeEXx) then
            Putimage(xpos-round((sizeEXx-graphics_data[level,0].width)/2),
            ypos-round((sizeEXy-graphics_data[level,0].height)/2),EX[e]^,orput);
        end;
        Stats_update;
      end;
      page:=(1-page);
      setactivepage(page);
      setvisualpage(1-page);
    end;
    if (dist>level_data[level].length) and (energy>0) then begin
      if level=6 then Evil_hand_game;
      if energy>0 then Clear_off_Slappa_we_dont_want_you_here;
    end;

  until (flags[1]) or (energy<1) or (flags[5]);
end;

Procedure Game_complete;
var
  tg_time: array[1..8] of real;
  tg_inc: array[1..8] of real;
  h1_spd,h2_spd,h1_pos,h2_pos,h1_yp,h2_yp: array[1..10] of integer;
const
  tg_string: array[1..8] of string[1]=
  ('s','l','a','p','p','i','n','g');
begin
  RH:=@hnd_litt;
  for a:=1 to 10 do begin
    h1_spd[a]:=random(15)+5; h2_spd[a]:=random(15)+5;
    h1_pos[a]:=random(640); h2_pos[a]:=random(640);
    h1_yp[a]:=90+random(150);h2_yp[a]:=90+random(150);
  end;
  setfillstyle(9,4);
  settextjustify(centertext,centertext);
  bar(0,0,639,349);
  flip_page;
  windows_colours;
  setbkcolor(4);
  cleardevice;
  for a:=1 to 8 do begin
    tg_time[a]:=random(100)*(pi/2)/100;
    tg_inc[a]:=random(100)*(pi/32)/100+pi/32;
  end;
  setcolor(13);
  settextstyle(3,0,5);
  outtextxy(320,15,'Conslapulations!');
  setcolor(lightcyan);
  settextstyle(7,0,5);
  outtextxy(320,60,'You have Completed');
  setcolor(lightgreen);
  settextstyle(1,0,9);
  outtextxy(320,285,'SLAPPERY');
  setactivepage(1-page);
  cleardevice;
  setcolor(5);
  settextstyle(3,0,5);
  outtextxy(320,15,'Conslapulations!');
  setcolor(lightcyan);
  settextstyle(7,0,5);
  outtextxy(320,60,'You have Completed');
  setcolor(lightgreen);
  settextstyle(1,0,9);
  outtextxy(320,285,'SLAPPERY');
  setcolor(15);
  settextstyle(6,0,8);
  if keypressed then kp:=false else kp:=true;
  mouseinfo;
  if mouse.left then ml:=false else ml:=true;
  if mouse.right then mr:=false else mr:=true;
  repeat
    page:=1-page;
    setactivepage(page);
    setvisualpage(1-page);
    vwait;
    bar(0,90,639,265);
    for a:=1 to 10 do begin
      h1_pos[a]:=h1_pos[a]+h1_spd[a];
      if h1_pos[a]>640 then h1_pos[a]:=0;
      h2_pos[a]:=h2_pos[a]-h2_spd[a];
      if h2_pos[a]<0 then h2_pos[a]:=640;
      putimage(h2_pos[a],h2_yp[a],RH^,orput);
      putimage(h1_pos[a],h1_yp[a],SL^,orput);
    end;
    for a:=1 to 8 do begin
      tg_time[a]:=tg_time[a]+tg_inc[a];
      if tg_time[a]>pi then tg_time[a]:=tg_time[a]-pi;
      outtextxy(50+60*a,204-round(sin(tg_time[a])*100),tg_string[a]);
    end;
    mouseinfo;
    if not mouse.left then ml:=true;
    if not mouse.right then mr:=true;
    if not keypressed then kp:=true;
  until (keypressed and kp) or (mouse.left and ml) or (mouse.right and mr);
  if keypressed then ch:=readkey;
end;

Procedure Game_Start;
begin
  setmouselimits(0,0,610,349);
  m1:=20; m2:=22;
  SL:=@SLAPHAND;
  EX[1]:=@EXPL_1;
  EX[2]:=@EXPL_2;
  EX[3]:=@EXPL_3;
  EX[4]:=@EXPL_4;
  EX[5]:=@EXPL_5;
  EX[6]:=@EXPL_6;

  Windows_colours;
  for a:=1 to 10 do flags[a]:=false;
  score:=0; energy:=100; megaslaps:=5;
  game_loop;
  all_back_fade(4,{20}256);
  if flags[5] then game_complete;
  delay(100);
end;

begin
  findfirst('level1.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level2.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level3.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level4.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level5.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level6.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;
  findfirst('level7.gfx',anyfile,dirinfo);
  if doserror<>0 then No_Gfx;

  With keydata do begin
    kleft:=false; kright:=false; kup:=false; kdown:=false;
    kSHIFT:=false; kALT:=false; kCTRL:=false;
  end;
  Timerdelay:=0;
  GetIntVec($08,@TimerIntVec);
  SetIntVec($08,Addr(TimerHandler));
  GetIntVec($9,@KbdIntVec);
  SetIntVec($9,Addr(Keyclick));
  findfirst('SLAPTAB.dat',anyfile,dirinfo);
  if doserror<>0 then begin
    Hi_Names[1]:='Chris'; Hi_Names[2]:='Wes'; Hi_Names[3]:='Tom';
    Hi_Names[4]:='Andy'; Hi_Names[5]:='Merrick'; Hi_Names[6]:='Ben';
    Hi_Scores[1]:=80; Hi_Scores[2]:=70;  Hi_Scores[3]:=60;
    Hi_Scores[4]:=50; Hi_Scores[5]:=40; Hi_Scores[6]:=30;
    S_Hi_Scores[1]:='80'; S_Hi_Scores[2]:='70'; S_Hi_Scores[3]:='60';
    S_Hi_Scores[4]:='50'; S_Hi_Scores[5]:='40'; S_Hi_Scores[6]:='30';
    Save_Hi_Scores;
  end;
  cheat:=false; invuln:=false;
  if paramstr(1)='/WCT' then cheat:=true;
  get_memory;
  clrscr;
  page:=0; load_hi_scores;
  if paramstr(1)='/EGA' then begin gm:=egahi; gd:=ega; end
  else begin gm:=vgamed; gd:=vga; end;

  egavga;
  initgraph(gd,gm,'');
  if graphresult<>grok then graphics_Error;

  font1;
  font2;
  font3;
  font6;
  font7;
  font8;
  font9;
  font10;
  setactivepage(page); setvisualpage(1-page);
  randomize;  PLOGO:=@waistpic;
  for a:=0 to 15 do setpalette(a,a);
  mc:=13; initmouse;
  repeat
    cleardevice;
    flip_page;
    dp_colours;
    ml:=true; mr:=true; kp:=true;
    st:=false; qt:=false; hs:=false;
    if keypressed then kp:=false;
    mouseinfo;
    if mouse.left then ml:=false;
    if mouse.right then mr:=false;
    setfillpattern(mez,8);
    setrgbpalette(0,colours_alt[12].redval,colours_alt[12].greenval,colours_alt[12].blueval);
    startcol:=12; endcol:=random(14)+1;
    sta2:=mc;
    numfads:=50;
    settextstyle(8,0,5);
    settextjustify(centertext,centertext);
    bar(0,0,639,349);
    putimage(0,200,PLOGO^,copyput);
    outtextxy(320,170,'by Chris, Wes & Tom');
    flip_page;
    bar(0,0,639,349);
    putimage(0,200,PLOGO^,copyput);
    outtextxy(320,170,'by Chris, Wes & Tom');
    txtnum:=2; delaytxt:=40; vtxt:=0; timetxt:=0; t_now:=0;
    t_inc:=pi/16.5;
    repeat
      rn:=colours_alt[startcol].redval;
      gn:=colours_alt[startcol].greenval;
      bn:=colours_alt[startcol].blueval;
      setrgb{palette}(0,round(rn),round(gn),round(bn));
      Setpalette(0,0);
      ri:=(colours_alt[endcol].Redval-rn)/numfads;
      gi:=(colours_alt[endcol].GreenVal-gn)/numfads;
      bi:=(colours_alt[endcol].BlueVal-bn)/numfads;
      b:=0;
      repeat
        inc(b);
        inc(timetxt);
        vtxt:=vtxt+8;
        if timetxt>delaytxt then begin
          timetxt:=0;
          inc(txtnum);
          if txtnum>text_num then txtnum:=2;
          vtxt:=0;
        end;
        page:=1-page;
        setvisualpage(1-page);
        setactivepage(page);
        Vwait;
        bar(230,0,410,160);
        t_now:=t_now+t_inc;
        if vtxt<42 then t_now:=t_now+t_inc;
        if t_now>=pi then t_now:=t_now-pi;
        t_sin:=sin(t_now);
        t_1:=round(t_sin*30);
        settextjustify(centertext,centertext);
        settextstyle(6,0,5);
        setusercharsize(20,12,20,10);
        setcolor(14);
        if cheat then
          outtextxy(320,40-t_1,'Cheaty')
        else
          outtextxy(320,40-t_1,'Slapping');
        outtextxy(320,80+t_1,'Slappery');

        if vtxt<42 then begin
          bar(10,290,619,339);
          settextstyle({6}9,0,6);
          setcolor(title_colours[txtnum]);
          if vtxt>32 then setusercharsize(20,40,vtxt-8,50) {20}
          else setusercharsize(20,40,vtxt,50);
          settextjustify(centertext,bottomtext);
          outtextxy(320,330,title_text[txtnum]);
          if vtxt<32 then setusercharsize(20,40,30-vtxt,50);
          settextjustify(centertext,toptext);
          setcolor(title_colours[txtnum-1]);
          if vtxt<32 then outtextxy(320,290,title_text[txtnum-1]);
        end;
        setrgb{palette}(0,round(rn),round(gn),round(bn));
        rn:=rn+ri; bn:=bn+bi; gn:=gn+gi;
        if not keypressed then kp:=true;
        mouseinfo;
        if not mouse.left then ml:=true;
        if not mouse.right then mr:=true;
        if keypressed then begin
          ch:=readkey;
          if kp then begin
            if ch='s' then st:=true
            else if ch='h' then hs:=true
            else if ch='%' then begin
              if cheat then cheat:=false else cheat:=true;
            end;
            if ch=chr(27) then qt:=true;
          end;
        end;
        if (mouse.left) and ml then st:=true;
        if (mouse.right) and mr then hs:=true;
      until (b>=numfads+1) or st or qt or hs;
      if (b>=numfads+1) then begin
        startcol:=endcol; endcol:=random(14)+1;
        sta2:=end2; end2:=random(14)+1;
      end;
    until st or qt or hs;

    if qt then begin
      SetIntVec($08,@TimerIntVec);
      SetIntVec($9,@KbdIntVec);
      free_memory;
      closegraph; textcolor(lightgray);
      textbackground(black); writeln('WCT SOFTWARE International');
      halt(0);
    end;

    if hs then begin
      hi_setup;
      view_hi_scores;
    end;

    if st then begin
      cleardevice;
      flip_page;
      cleardevice;
      Game_Start;
      cleardevice;
      flip_page;
      cleardevice;
      hi_setup;
      check_hi_scores;
      view_hi_scores;
    end;
  until false;
end.
