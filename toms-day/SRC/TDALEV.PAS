program TDALEV;
uses crt,td_256,td_PCX,MOUSERMW,dos;
procedure TDAPAL; external; {$L TDAPAL.OBJ}
procedure H3 ; external; {$L H3.OBJ} procedure H4 ; external; {$L H4.OBJ}
procedure H1 ; external; {$L H1.OBJ} procedure H2 ; external; {$L H2.OBJ}
procedure F1 ; external; {$L F1.OBJ} procedure F2 ; external; {$L F2.OBJ}
Procedure G ; external; {$L G.OBJ} Procedure COSMIX ; external; {$L COSMIX.OBJ}
Procedure W ; external; {$L W.OBJ} Procedure WBL; external; {$L WBL.OBJ}
Procedure WBR; external; {$L WBR.OBJ} Procedure WTR; external; {$L WTR.OBJ}
Procedure WTL; external; {$L WTL.OBJ} Procedure MG; external; {$L MG.OBJ}
Procedure FMESS; external; {$L FMESS.OBJ}
const
  GTITLES : array[1..14] of string = ('Top hedge','Bottom hedge','Left hedge','Right hedge',
    'Top flower','Bottom flower','Grass','Mowed Grass','Mowed flowers','Water','Water top right','Water top left',
    'Water bottom left','Water bottom right');
  GPOINTERS : array[1..14] of pointer = (@H3,@H4,@H1,@H2,@F1,@F2,@G,@MG,@FMESS,@W,@WTR,@WTL,@WBL,@WBR);

  LEV_DIR = 'LEVELS\';

var SCREEN : array[1..40,1..20] of byte;
    MX,MY,GX,GY,DX,DY,NX,NY,OLDX,OLDY,X,Y : byte;
    f : FILE;
    ST,S : string;
    P : pointer;
    CH : char;
    L,MD,FLAG,CURRENT_SHAPE : byte;
    DirInfo: SearchRec;

Procedure GETPOS(TX,TY : integer);
  var ST : string;
begin
  mouseinfo;
  mouse.x:=mouse.x div 2;
  if TX=0 then X:=trunc((mouse.X+8)/8);
  if TY=0 then Y:=trunc((mouse.y+8)/8);
  if X<>OLDX then begin
    str(X,ST);
    t2_block(280,180,19,19,0);
    t2_write(280,180,ST,15);
  end;
  if Y<>OLDY then begin
    str(Y,ST);
    t2_block(300,180,19,19,0);t2_write(300,180,ST,15);
  end;
  if (TX<>0) or (TY<>0) then begin
    setmouseposition(2*((tx*8)-8),(tY*8)-8);
    X:=TX; Y:=TY;
  end;
  if (X<>OLDX) or (Y<>OLDY) then begin
    hidepointer;
    if (OLDX<255) and (OLDY<255) then begin
      T2_putpic((OLDX*8)-8,(OLDY*8)-8,GPOINTERS[SCREEN[OLDX,OLDY]]);
    end;
    OLDX:=X; OLDY:=Y;
    t2_block((X*8)-8,(Y*8)-8,7,1,15);
    t2_block((X*8)-8,(Y*8)-8,1,7,15);
    t2_block((X*8)-1,(Y*8)-8,1,7,15);
    t2_block((X*8)-8,(Y*8)-1,7,1,15);
    showpointer;
  end;
end;

begin
  t2_start(0);
  MX:=20; MY:=20; NX:=1; NY:=1; DX:=40; DY:=1; MD:=0; GX:=20; GY:=1;
  P:=@COSMIX;
  t2_user_font(P,1);
  t2_set_font(1);
  P:=@TDAPAL;
  for L:=0 to 255 do begin
    t2_Setrgb(L,mem[seg(P^):Ofs(P^)+(L*3)],mem[seg(P^):Ofs(P^)+(L*3)+1],mem[seg(P^):Ofs(P^)+(L*3)+2]);
  end;
  for X:=1 to 40 do for Y:=1 to 20 do begin
    SCREEN[X,Y]:=7;
    t2_putpic(((X-1)*8),((Y-1)*8),GPOINTERS[SCREEN[X,Y]]);
  end;
  CURRENT_SHAPE:=7;
  T2_SET_STYLE(0,0,0,0);
  t2_write(20,180,GTITLES[CURRENT_SHAPE],14);
  t2_putpic(200,181,GPOINTERS[CURRENT_SHAPE]);
  t2_write(0,165,'Arrow keys, L = load, S = save, G = game setup, Q = quit',12);
  X:=0; Y:=0; OLDX:=255; OLDY:=255;
  showpointer;
  setmouseposition(0,0); setmousexlimits(0,626); setmouseylimits(0,156);
  repeat
    GETPOS(0,0);
    if ((mouse.left) and (SCREEN[X,Y]<>CURRENT_SHAPE)) then begin
      SCREEN[X,Y]:=CURRENT_SHAPE;
      hidepointer;
      T2_putpic((X*8)-8,(Y*8)-8,GPOINTERS[SCREEN[X,Y]]);
      OLDX:=X+1; if OLDX>40 then OLDX:=X-1;
      showpointer;
    end;
    if ((mouse.right) and (SCREEN[X,Y]<>7)) then begin
      SCREEN[X,Y]:=7;
      hidepointer;
      T2_putpic((X*8)-8,(Y*8)-8,GPOINTERS[SCREEN[X,Y]]);
      OLDX:=X+1;
      showpointer;
    end;

    if keypressed then begin
      ch:=upcase(readkey);
      if ch=chr(0) then ch:=upcase(readkey);
      if ch=chr(72) then dec(CURRENT_SHAPE);
      if ch=chr(80) then inc(CURRENT_SHAPE);
      if ch='Q' then begin
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Really quit ? (Have you saved?)',15);
        ch:=upcase(readkey);
        if ch='Y' then begin
          t2_end;
          halt;
        end;
      end;
      if ch='G' then begin
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Define initial position of mower (not Tom)',15);
        getpos(MX,MY);
        repeat
          GETPOS(0,0);
        until (mouse.left) and (SCREEN[X,Y]>=5) and (SCREEN[X,Y]<=9);
        MX:=X; MY:=Y;
        repeat
          mouseinfo;
        until not (mouse.left);
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Which way does Tom face? (Arrow key)',15);
        repeat
          if keypressed then repeat until readkey<>'';
        until not keypressed;
        ch:=upcase(Readkey); if ch=chr(0) then ch:=upcase(readkey);
        if ch=CHR(72) then MD:=0;
        if ch=chr(75) then MD:=3;
        if ch=chr(80) then MD:=2;
        if ch=chr(77) then MD:=1;
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Define initial position of neighbour',15);
        GETPOS(NX,NY);
        repeat
          GETPOS(0,0);
        until (mouse.left) and (SCREEN[X,Y]>=5) and (SCREEN[X,Y]<=9) and ((X<>MX) or (Y<>MY));
        NX:=X; NY:=Y;
        repeat
          mouseinfo;
        until not (mouse.left);
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Define initial position of psycho-gardener',15);
        GETPOS(GX,GY);
        repeat
          GETPOS(0,0);
        until (mouse.left) and (SCREEN[X,Y]>=7) and (SCREEN[X,Y]<=9) and ((X<>NX) or (Y<>NY)) and ((X<>MX) or (Y<>MY));
        GX:=X; GY:=Y;
        repeat
          mouseinfo;
        until not (mouse.left);
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Define initial position of CYBER-DOG',15);
        GETPOS(DX,DY);
        repeat
          GETPOS(0,0);
        until (mouse.left) and (SCREEN[X,Y]>=7) and (SCREEN[X,Y]<=9)
           and ((X<>NX) or (Y<>NY)) and ((X<>MX) or (Y<>MY)) and ((X<>GX) or (Y<>GY));
        DX:=X; DY:=Y;
        repeat
          mouseinfo;
        until not (mouse.left);
      end;
      if ch='L' then begin
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Lose current page ? (Have you saved?)',15);
        ch:=upcase(readkey);
        if ch='Y' then begin
          t2_block(0,180,320,20,0);
          t2_write(20,180,'Filename ? ',14);
          FLAG:=0;
          S:='';
          repeat
            repeat until keypressed;
            ch:=readkey;
            if ch=chr(0) then ch:=readkey;
            if (ch=chr(8)) and (length(S)>0) then S:=copy(S,1,length(S)-1);
            if (ch=chr(27)) then FLAG:=1;
            if (ch=chr(13)) then FLAG:=2;
            if (FLAG=0) and (ch<>chr(8)) THEN s:=s+ch;
            t2_block(100,180,220,20,0);
            t2_write(100,180,S,15);
          until FLAG<>0;
          if FLAG=2 then begin
            t2_block(100,180,220,20,0);
            if pos('.',S)=0 then S:=S+'.TDA';
            {$I-}
            FindFirst(LEV_DIR+S, Archive, DirInfo);
            {$I+}
            if doserror=0 then begin
              assign(F,LEV_DIR+S);
              reset(F,1);
              blockread(F,CH,1); st:=ch;
              blockread(F,CH,1); st:=st+ch;
              blockread(F,CH,1); st:=st+ch;
              blockread(F,CH,1); st:=st+ch;
              if ST='@TDA' then begin
                hidepointer;
                for X:=1 to 40 do for Y:=1 to 20 do begin
                  blockread(F,CH,1);
                  SCREEN[X,Y]:=ord(CH);
                  t2_putpic(((X-1)*8),((Y-1)*8),GPOINTERS[SCREEN[X,Y]]);
                  OLDX:=255; OLDY:=255;
                end;
                showpointer;
                blockread(F,CH,1); MX:=ord(CH);
                blockread(F,CH,1); MY:=ord(CH);
                blockread(F,CH,1); MD:=ord(CH);
                blockread(F,CH,1); NX:=ord(CH);
                blockread(F,CH,1); NY:=ord(CH);
                blockread(F,CH,1); GX:=ord(CH);
                blockread(F,CH,1); GY:=ord(CH);
                blockread(F,CH,1); DX:=ord(CH);
                blockread(F,CH,1); DY:=ord(CH);
                close(F);
              end;
              if ST<>'@TDA' then begin
                t2_write(100,180,'Error - invalid file!',15);
                repeat until keypressed;
              end;
            end;
            if doserror<>0 then begin
              t2_write(100,180,'File not found',15);
              repeat until keypressed;
            end;
          end;
        end;
        FLAG:=0;
      end;
      if ch='S' then begin
        t2_block(0,180,320,20,0);
        t2_write(20,180,'Filename ? ',14);
        FLAG:=0;
        S:='';
        repeat
          repeat until keypressed;
          ch:=readkey;
          if ch=chr(0) then ch:=readkey;
          if (ch=chr(8)) and (length(S)>0) then S:=copy(S,1,length(S)-1);
          if (ch=chr(27)) then FLAG:=1;
          if (ch=chr(13)) then FLAG:=2;
          if (FLAG=0) and (ch<>chr(8)) THEN s:=s+ch;
          t2_block(100,180,220,20,0);
          t2_write(100,180,S,15);
        until FLAG<>0;
        if FLAG=2 then begin
          t2_block(100,180,220,20,0);
          if pos('.',S)=0 then S:=S+'.TDA';
          {$I-}
          FindFirst(LEV_DIR+S, Archive, DirInfo);
          {$I+}
          if doserror=0 then begin
            t2_write(100,180,'File exists - overwrite?',4);
            ch:=upcase(readkey);
            if ch<>'Y' then FLAG:=0;
          end;
          if FLAG=2 then begin
            assign(F,LEV_DIR+S);
            rewrite(F,1);
            CH:='@'; blockwrite(F,CH,1);
            CH:='T'; blockwrite(F,CH,1);
            CH:='D'; blockwrite(F,CH,1);
            CH:='A'; blockwrite(F,CH,1);
            for X:=1 to 40 do for Y:=1 to 20 do begin
              CH:=CHR(SCREEN[X,Y]);
              blockwrite(F,CH,1);
            end;
            CH:=chr(MX); blockwrite(F,CH,1);
            CH:=chr(MY); blockwrite(F,CH,1);
            CH:=chr(MD); blockwrite(F,CH,1);
            CH:=chr(NX); blockwrite(F,CH,1);
            CH:=chr(NY); blockwrite(F,CH,1);
            CH:=chr(GX); blockwrite(F,CH,1);
            CH:=chr(GY); blockwrite(F,CH,1);
            CH:=chr(DX); blockwrite(F,CH,1);
            CH:=chr(DY); blockwrite(F,CH,1);
            close(F);
            if (SCREEN[MX,MY]<5) or (SCREEN[MX,MY]>9) or
               (SCREEN[NX,NY]<5) or (SCREEN[NX,NY]>9) or
               (SCREEN[GX,GY]<7) or (SCREEN[GX,GY]>9) or
               (SCREEN[DX,DY]<7) or (SCREEN[DX,DY]>9) then
            begin
              t2_block(100,180,220,20,0);
              T2_write(100,180,'Note : GAME SETUP is invalid!',12);
              repeat
                if keypressed then repeat until readkey<>'';
              until not keypressed;
              repeat until readkey<>'';
            end;
          end;
        end;
        FLAG:=0;
      end;
      If CURRENT_SHAPE=15 then CURRENT_SHAPE:=14;
      if CURRENT_SHAPE=0 then CURRENT_SHAPE:=1;
      t2_block(0,180,320,20,0);
      t2_write(20,180,GTITLES[CURRENT_SHAPE],14);
      t2_putpic(200,181,GPOINTERS[CURRENT_SHAPE]);
    end;
  until false;
end.