Program SlapGame;
uses crt,graph,mouseRMW;
type
  RGBRec = record
    RedVal, GreenVal, BlueVal : Integer;
    Colornum: integer;
    end;
  Level_type= record
       Speed,Background_colour,Prob_gfx,Prob_per: integer;
       Length: Longint;
    end;
    Graphics_type= record
       Exist: Boolean; Width,Height: integer; name: string; end;
var
   gm,gd,ox,oy,a,b: integer;
   s_mx,s_my: string;
   P: pointer;
   f: file;
   c: char;
Const
  Colours : array[0..15] of RGBRec = (
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
   ( RedVal:0;GreenVal:63;BlueVal:63;ColorNum: 14),
   ( RedVal:63; GreenVal:63; BlueVal:63;ColorNum: 15));


   Level_data: array[1..6] of level_type=
   ((Speed:1;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500),
   (Speed:2;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500),
   (Speed:3;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500),
   (Speed:4;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500),
   (Speed:5;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500),
   (Speed:6;Background_colour:darkgray;Prob_gfx:10;Prob_per:10;Length:500));


   Graphics_data: array[1..6,0..9] of graphics_type={0=Mez, 1,2_per, 3-9-gfx}
   (((Exist:True;Width:83;Height:128;Name:'Urb_mez'),
   (Exist:True;Width:84;Height:112;Name:'Urb_Oz'),
   (Exist:True;Width:92;Height:130;Name:'Urb_Chr'),
   (Exist:True;Width:67;Height:74;Name:'Urb_Off'),
   (Exist:True;Width:96;Height:77;Name:'Urb_Hous'),
   (Exist:True;Width:67;Height:65;Name:'Urb_Cat'),
   (Exist:True;Width:55;Height:63;Name:'Urb_Dog'),
   (Exist:True;Width:141;Height:49;Name:'Urb_Car'),
   (Exist:True;Width:45;Height:63;Name:'Urb_Plan'),
   (Exist:True;Width:63;Height:76;Name:'Urb_Bus')),

   ((Exist:True;Width:89;Height:129;Name:'Des_mez'),
   (Exist:True;Width:89;Height:116;Name:'Des_Wes'),
   (Exist:True;Width:91;Height:120;Name:'Des_Jef'),
   (Exist:True;Width:164;Height:76;Name:'Des_Pyr'),
   (Exist:True;Width:127;Height:70;Name:'Des_Rock'),
   (Exist:True;Width:33;Height:45;Name:'Des_Cac'),
   (Exist:True;Width:97;Height:128;Name:'Des_Sand'),
   (Exist:True;Width:62;Height:81;Name:'Des_Tree'),
   (Exist:False;Width:0;Height:0;Name:''),
   (Exist:False;Width:0;Height:0;Name:'')),

   ((Exist:True;Width:95;Height:127;Name:'Sky_Mez'),
   (Exist:True;Width:96;Height:112;Name:'Sky_Stu'),
   (Exist:True;Width:95;Height:119;Name:'Sky_Ben'),
   (Exist:True;Width:118;Height:78;Name:'Sky_Plan'),
   (Exist:True;Width:137;Height:53;Name:'Sky_Cld'),
   (Exist:True;Width:207;Height:63;Name:'Sky_Clds'),
   (Exist:True;Width:80;Height:51;Name:'Sky_Bird'),
   (Exist:True;Width:89;Height:146;Name:'Sky_Kite'),
   (Exist:False;Width:0;Height:0;Name:''),
   (Exist:False;Width:0;Height:0;Name:'')),

   ((Exist:True;Width:89;Height:128;Name:'For_Mez'),
   (Exist:True;Width:87;Height:122;Name:'For_Wes'),
   (Exist:True;Width:88;Height:124;Name:'For_Gaz'),
   (Exist:True;Width:164;Height:61;Name:'For_Gras'),
   (Exist:True;Width:172;Height:67;Name:'For_Grs2'),
   (Exist:True;Width:162;Height:82;Name:'For_Tree'),
   (Exist:True;Width:81;Height:110;Name:'For_Tre2'),
   (Exist:True;Width:69;Height:68;Name:'For_Spid'),
   (Exist:True;Width:68;Height:65;Name:'For_Sqr'),
   (Exist:True;Width:120;Height:98;Name:'For_Leav')),

   ((Exist:True;Width:102;Height:105;Name:'Sea_Mez'),
   (Exist:True;Width:105;Height:105;Name:'Sea_Tom'),
   (Exist:True;Width:104;Height:106;Name:'Sea_Chr'),
   (Exist:True;Width:57;Height:39;Name:'Sea_Fish'),
   (Exist:True;Width:64;Height:25;Name:'Sea_Shar'),
   (Exist:True;Width:261;Height:137;Name:'Sea_Ship'),
   (Exist:True;Width:47;Height:54;Name:'Sea_jel'),
   (Exist:True;Width:134;Height:73;Name:'Sea_Tres'),
   (Exist:False;Width:0;Height:0;Name:''),
   (Exist:False;Width:0;Height:0;Name:'')),

   ((Exist:True;Width:107;Height:171;Name:'Arc_Mez'),
   (Exist:True;Width:108;Height:169;Name:'Arc_Ed'),
   (Exist:True;Width:103;Height:169;Name:'Arc_Ben'),
   (Exist:True;Width:111;Height:73;Name:'Arc_Peak'),
   (Exist:True;Width:185;Height:107;Name:'Arc_Tent'),
   (Exist:True;Width:27;Height:68;Name:'Arc_Tree'),
   (Exist:True;Width:150;Height:90;Name:'Arc_Iglo'),
   (Exist:True;Width:127;Height:70;Name:'Arc_Rock'),
   (Exist:False;Width:0;Height:0;Name:''),
   (Exist:False;Width:0;Height:0;Name:'')));

Procedure Vwait; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;
Procedure Windows_colours;
var
   i:integer;
begin
for i := 0 to 15 do
  with Colours[i] do
    begin
    SetRGBPalette(i, RedVal, GreenVal, BlueVal);
    setpalette(i,i); end;
end;

begin
gd:=vga; gm:=vgamed; initgraph(gd,gm,'C:\exe');
Windows_colours;
for a:=1 to 6 do begin
for b:=0 to 9 do begin
if graphics_data[a,b].exist then begin
  assign(F,'c:\slap\'+graphics_data[a,b].name+'.bin');
  reset(F,1);
  getmem(P,filesize(F));
  blockread(F,P^,filesize(F));
  close(F);
Putimage(0,0,P^,normalput);
settextstyle(2,0,5);
setfillstyle(1,black);
ox:=0; oy:=0;
{setwritemode(xorput);
line(0,oy,639,oy);
line(ox,0,ox,349);}
repeat
Vwait;
mouseinfo;
if (mouse.x<>ox) or (mouse.y<>oy) then begin
hidepointer;
{setwritemode(xorput);
line(0,oy,639,oy);
line(ox,0,ox,349);}
bar(400,0,640,100);
Str(mouse.x,s_mx);
Str(mouse.y,s_my);
setwritemode(normalput);
outtextxy(410,20,'X:'+s_mx+' Y:'+s_my);
ox:=mouse.x; oy:=mouse.y;
{setwritemode(xorput);
line(0,oy,639,oy);
line(ox,0,ox,349);}
end;

until keypressed;
c:=readkey;
Freemem(P,sizeof(p));
end; cleardevice;
end; end;
end.