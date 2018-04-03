program RIBEDIT;
uses td_256,dos,mousermw,crt,BerryBin,BerryB2;
var  RGBS : array[0..255,1..3] of byte;
     Berrys : array[0..17,0..9,1..4] of byte;
     CopyB : array[0..17,0..9,1..4] of byte;
     LowerLimit : byte;
procedure FCopy;
 var X,Y,Z : byte;
  begin
    for X:=0 to 17 do
      for Y:=0 to 9 do
        for Z:=1 to 4 do
          CopyB[X,Y,Z]:=Berrys[X,Y,Z];
  end;
procedure FEmpty;
 var X,Y,Z : byte;
  begin
    for X:=0 to 17 do
      for Y:=0 to 9 do
        for Z:=1 to 4 do
          CopyB[X,Y,Z]:=0;
  end;

procedure FPaste;
 var X,Y,Z : byte;
  begin
    for X:=0 to 17 do
      for Y:=0 to 9 do
        for Z:=1 to 4 do
          Berrys[X,Y,Z]:=CopyB[X,Y,Z];
  end;

procedure CLEARBUF;
  begin
    inline($fa);
    memw[$40:$1A]:=memw[$40:$1C];
    inline($fb);
  end;

procedure WriteLevel(LNo : byte);
  var LoadIn : array[1..540] of byte;
      X,Y : byte;
      Count,L : integer;
      F,F2 : file;
  begin
    assign(F,'RIBENA.DAT');
    assign(F2,'RIB2.DAT');
    reset(F,1);
    rewrite(F2,1);
    for L:=1 to 80 do
      begin
        blockread(F,D,1);
        blockread(F,Loadin,540);
        if L=Lno then
          begin
            Count:=1; X:=0; Y:=0;
              repeat
                Loadin[Count]:=Berrys[X,Y,1];
                Loadin[Count+1]:=Berrys[X,Y,3];
                Loadin[Count+2]:=Berrys[X,Y,4];
                inc(Count,3);
                inc(X);
                if X=18 then begin X:=0; inc(Y); end;
              until Count>=541;
          end;
      blockwrite(F2,D,1);
      blockwrite(F2,LoadIn,540);
    end;
    close(F);
    close(F2);
    erase(F);
    rename(F2,'RIBENA.DAT');
  end;

Procedure ReadLevel(LNo : byte);
  var LoadIn : array[1..540] of char;
      X,Y,D : byte;
      L : integer;
      F : file;
      DirInfo : SearchRec;
  begin
    X:=0; Y:=0; D:=0;
    findfirst('RIBENA.DAT',Archive,DirInfo);
    if DosError<>0 then begin t2_end; writeln('Missing level data - fatal error! Sorry - not enough data to run the game.');
                                     writeln('See accompanying text file on contacting us, and downloading WCT freeware.');
                                     writeln; halt; end;
    assign(F,'RIBENA.DAT');
    reset(F,1);
    for L:=1 to LNo do
      begin
        blockread(F,D,1);
        blockread(F,LoadIn,540);
{        blockread(F,LoadIn[2],1);}
      end;
    L:=1; X:=0; Y:=0;
      repeat
        Berrys[X,Y,1]:=ord(Loadin[L]);
        Berrys[X,Y,2]:=0;
        Berrys[X,Y,3]:=ord(Loadin[L+1]);
        Berrys[X,Y,4]:=ord(Loadin[L+2]);
        inc(L,3);
        inc(X);
        if X=18 then begin X:=0; inc(Y); end;
      until L>=541;
    close(F);
  end;

function LitCon(Ch : CHar) : byte;
  begin
    LitCon:=pos(upcase(ch),'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ');
  end;

procedure LittleText(X : integer; Y : byte; S : string);
  var L : byte;
      Ix : integer;
      St : string[80];
  begin
    Ix:=X; St:=s;
    for L:=1 to length(ST) do
      begin
        if (St[1]<>' ') and (ST[1]<>'.') and (ST[1]<>',') AND (ST[1]<>'-') then
          begin
            t2_putpic(Ix,Y+FOfs[LitCon(ST[1])],Alpha[LitCon(ST[1])]);
            Ix:=Ix+Wid[LitCon(St[1])];
          end;
        if St[1]=' ' then IX:=Ix+4;
        if St[1]='.' then
          begin
            t2_dot(IX+1,Y+7,15); t2_dot(IX+2,Y+7,15);
            t2_dot(Ix+1,Y+6,15); t2_dot(IX+2,Y+6,15);
            t2_dot(Ix,Y+6,8); t2_dot(Ix,Y+7,8);
            t2_dot(Ix+1,Y+8,8); t2_dot(Ix+2,Y+8,8); inc(Ix,5);
          end;
        if St[1]=',' then
          begin
            t2_dot(IX+1,Y+7,15); t2_dot(IX+2,Y+7,15);
            t2_dot(Ix+2,Y+6,15); t2_dot(IX+3,Y+6,15);
            t2_dot(Ix+1,Y+6,8); t2_dot(Ix,Y+7,8);
            t2_dot(Ix+1,Y+8,8); t2_dot(Ix+2,Y+8,8); inc(Ix,5);
          end;
        if St[1]='-' then
          begin
            t2_line(IX+1,y+5,ix+4,y+5,15);
            t2_line(IX+1,y+6,Ix+5,y+6,8);
            t2_dot(Ix,y+5,8);
            inc(Ix,6);
          end;
      St:=copy(St,2,length(st)-1);
      end;
  end;

function GetStrHi(x : integer; y : byte) : string;
  var S : string[25];
      L : byte;
      ch : char;
  begin
    S:='';
    clearbuf;
    hidepointer;
    repeat
      t2_block(x,y,108,20,0);
      LittleText(X,Y,S+'-');
      Clearbuf;
      repeat
        if not keypressed then ch:=chr(0);
        if keypressed then ch:=upcase(Readkey);
      until ((ch>='A') and (ch<='Z')) or ((ch>='0') and (ch<='9')) or (ch=' ') or (ch=chr(13)) or (ch=chr(8));
      if (ch<>chr(13)) and (ch<>chr(8)) then S:=S+ch;
      if (ch=chr(8)) and (length(S)>0) then S:=copy(S,1,length(S)-1);
      if (length(S)>12) then S:=copy(S,1,12);
    until ch=chr(13);
    GetStrHi:=S;
    showpointer;
  end;


procedure StatusPanel(Ca,Cb,Cc,Lev : byte);
var Hits : string[15];
    Xb,Yb : byte;
  begin
    t2_block(0,0,65,169,0);
    LittleText(0,0,'STATUS');
    LittleText(0,25,'1.');
    if Ca>0 then
      begin
        XB:=(ca div 11)+1;
        YB:=(ca mod 11)+1;
        if ca<=11 then Xb:=1;
        t2_putpic(20,20,BBMP[Xb,Yb]);
      end;
    if Cb=0 then LittleText(0,40,'2.PERM');
    if Cb=1 then LittleText(0,40,'2.EXPLODE');
    if Cb=2 then LittleText(0,40,'2.DEC-EXP');
    if Cb=3 then LittleText(0,40,'2.INC-EXP');
    str(Cc,Hits);
    hits:='3.HITS-'+hits;
    LittleText(0,55,hits);
    str(Lev,Hits);
    Hits:='LEVEL '+Hits;
    LittleText(0,160,hits);
    LittleText(0,85,'S-SAVE');
    LittleText(0,100,'L-LOAD');
    LittleText(0,115,'C-COPY');
    LittleText(0,130,'P-PASTE');
    LittleText(0,145,'X-CLRBUF');
  end;

procedure DrawScreen;
  var Xb,Yb,X,Y : byte;

  begin
    hidepointer;
    for X:=0 to 17 do
      for Y:=0 to 9 do
        begin
          if Berrys[X,Y,1]<>0 then
            begin
              XB:=(Berrys[X,Y,1] div 11)+1;
              YB:=(Berrys[X,Y,1] mod 11)+1;
              if Berrys[X,Y,1]<=11 then Xb:=1;
              t2_putpic(66+(X*14),1+(Y*14),BBMP[Xb,Yb]);
            end;
          if Berrys[X,Y,1]=0 then t2_block(66+(X*14),1+(Y*14),14,14,0);
        end;
    showpointer;
  end;

function Centre(S : string) : byte;
  var W : integer;
      L : byte;
  begin
    W:=0;
    for L:=1 to length(S) do
      begin
        if (S[L]<>' ') and (S[L]<>'-') and (S[L]<>'.') and (S[L]<>',') then
          W:=W+Wid[LitCon(S[L])];
        if (S[L]=' ') or (S[L]='.') or (S[L]=',') then W:=W+4;
        if S[L]='-' then W:=W+6;
      end;
    Centre:=160-trunc(W/2);
  end;

procedure RibPalette;
  var P : pointer;
      L : byte;
  begin
    P:=@RIBPAL;
    for L:=0 to 255 do
      begin
        RGBs[L,1]:=mem[seg(P^):Ofs(P^)+(L*3)];
        RGBS[L,2]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
        RGBS[L,3]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
      end;
  end;

procedure NoFadein;
  var L : byte;
  begin
    for L:=0 to 255 do
      t2_setrgb(L,RGBs[L,1],RGBs[L,2],RGBS[L,3]);
    end;

procedure PlotCo(Xi,Yi : byte);
  var X,Y : string[2];
      T : string;
  begin
    str(Xi,X); str(Yi,Y);
    t2_block(0,184,146,16,0);
    LittleText(0,184,'X-'+X);
    LittleText(23,184,'Y-'+Y);
    if Berrys[Xi,Yi,3]=0 then T:='perm';
    if Berrys[Xi,Yi,3]=1 then T:='exp';
    if Berrys[Xi,Yi,3]=2 then T:='D-E';
    if Berrys[Xi,Yi,3]=3 then T:='I-E';
    if Berrys[Xi,Yi,1]=0 then T:='zero';
    LittleText(46,184,'Type-'+T);
    str(Berrys[Xi,Yi,4],X);
    if (Berrys[Xi,Yi,3]=0) or (Berrys[Xi,Yi,1]=0) then X:='z';
    LittleText(106,184,'Hits-'+X);
  end;
procedure Editor;
  var Lev,Ca,Cb,Cc : byte;
  code : integer;
  Levs : string;
  ch : char;
  CoX,CoY : shortint;
  begin
    Lev:=21;
    RibPalette; NoFadeIn; CA:=1; CB:=1; CC:=1;
    ReadLevel(Lev);
    LittleText(150,184,'SHOOTING RIBENABERRY LEVEL EDITOR');
    StatusPanel(Ca,Cb,Cc,Lev);
    DrawScreen;
    showpointer;
    clearbuf;
    repeat
      t2_vretrace;
      if keypressed then
        begin
          ch:=upcase(readkey);
          if ch=chr(27) then begin t2_end; halt; end;
          if ch='1' then inc(Ca); if Ca>=12 then Ca:=0;
          if ch='2' then inc(Cb); if Cb>=4 then Cb:=0;
          if ch='3' then inc(Cc); if Cc>=20 then Cc:=1;
          if ch='C' then
            begin
              hidepointer;
              LittleText(60,160,'COPYING');
              FCopy;
              t2_vretrace;
              t2_block(60,160,259,14,0);
              showpointer;
              DrawScreen;
            end;
          if ch='X' then
            begin
              hidepointer;
              LittleText(60,160,'EMPTYING');
              FEmpty;
              t2_vretrace;
              t2_block(60,160,259,14,0);
              showpointer;
              DrawScreen;
            end;
          if ch='P' then
            begin
              hidepointer;
              LittleText(60,160,'PASTING');
              FPaste;
              t2_vretrace;
              t2_block(60,160,259,14,0);
              showpointer;
              DrawScreen;
            end;
          if ch='S' then
            begin
              hidepointer;
              LittleText(60,160,'SAVING');
              WriteLevel(lev);
              t2_block(60,160,259,14,0);
              showpointer;
              DrawScreen;
            end;
          if ch='L' then
            begin
              hidepointer;
              LittleText(60,160,'LEVEL NO.');
              Levs:=GetStrHi(160,160);
              val(Levs,Lev,code);
              t2_block(60,160,259,14,0);
              if Lev>80 then Lev:=80;
              if Lev<LowerLimit then Lev:=LowerLimit;
              if (Lev<=80) and (Lev>=LowerLimit) then
                begin
                  LittleText(60,160,'LOADING');
                  ReadLevel(lev);
                  t2_block(60,160,259,14,0);
                  DrawScreen;
                end;
              showpointer;
            end;
          StatusPanel(Ca,Cb,Cc,Lev);
        end;
        mouseinfo;
        mouse.x:=mouse.x div 2;
        CoX:=(mouse.x-66) div 14;
        CoY:=(mouse.y-1) div 14;
      if (CoX>=0) and (CoY>=0) and (CoX<=17) and (CoY<=9) then PlotCo(CoX,CoY);
      if mouse.left or mouse.right then
        begin
          if CoX<0 then CoX:=0;
          if CoY<0 then CoY:=0;
          if CoX>17 then CoX:=17;
          if CoY>9 then CoY:=9;
          Berrys[CoX,CoY,1]:=Ca; if mouse.right then Berrys[CoX,CoY,1]:=0;
          Berrys[CoX,CoY,2]:=0;
          Berrys[CoX,CoY,3]:=Cb;
          Berrys[CoX,CoY,4]:=cc;
          DrawScreen;
        end;

    until false;
end;

begin
  LowerLimit:=21;
  if paramstr(1)='/MOOSE' then LowerLimit:=1;
  initmouse;
  t2_start(0);
  setmouseposition(150,50);
  setmousexlimits(110,639);
  setmouseylimits(0,180);
  Editor;
end.