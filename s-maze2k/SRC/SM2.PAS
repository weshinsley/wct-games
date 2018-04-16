{$m 65520,0,655360}
program SM2;
uses crt,dos,sound,load,td_256,td_pcx,newmaze,td_key;

const
  AUDIO = 'AUDIO\';
  GFX = 'GFX\';

var Font : array[33..126] of pointer;
  Height,Width : array[33..126] of byte;
  Card   : DSMCard;
  Module : PDSM;
  Music : PDSMMusicInfo;
  RunMe,MusOn : boolean;

  Smudges : array[1..11,1..4] of pointer;
  Backs : array[1..6,1..8,1..8] of pointer;
  Pieces : array[1..6,1..4] of pointer;
  Swap,Strip : pointer;
  PlLeft : array[1..6] of word;
  PlTop : array[1..6] of byte;
  GameKeys : array[1..6,1..6,1..5] of byte;
  Names : array[1..6] of string[10];
  Food : array[1..6] of integer;
  TLeft : array[1..6] of integer;
  Smudge : array[1..6,1..6] of byte;
  
  {Game Parameters}

  PX,PY : array[1..6] of byte; {Maze Co-ordinates of players}
  XSize,YSize : word;
  Sx,Sy : array[1..6] of word;
  Tog : array[1..6] of byte;
  GPlayers,GBackG,GType,GFlong,GHard : byte;

procedure WriteDefaultIni;
  var F : text;
begin
  assign(F,'sm2.ini');
  rewrite(F);
  writeln(F,'1P1K=108,104,106,110,113,1');
  writeln(F,'2P1K=30,32,17,31,16,1');
  writeln(F,'2P2K=108,104,106,110,113,3');
  writeln(F,'3P1K=30,32,17,31,16,1');
  writeln(F,'3P2K=108,104,106,110,113,3');
  writeln(F,'3P3K=75,77,72,76,82,5');
  writeln(F,'4P1K=30,32,17,31,16,1');
  writeln(F,'4P2K=36,38,23,37,22,3');
  writeln(F,'4P3K=108,104,106,110,113,5');
  writeln(F,'4P4K=75,77,72,76,82,7');
  writeln(F,'5P1K=30,32,17,31,16,1');
  writeln(F,'5P2K=33,35,20,34,19,3');
  writeln(F,'5P3K=36,38,23,37,22,5');
  writeln(F,'5P4K=108,104,106,110,113,7');
  writeln(F,'5P5K=75,77,72,76,82,9');
  writeln(F,'6P1K=30,32,17,31,16,1');
  writeln(F,'6P2K=33,35,20,34,19,3');
  writeln(F,'6P3K=36,38,23,37,22,5');
  writeln(F,'6P4K=39,43,26,40,25,7');
  writeln(F,'6P5K=108,104,106,110,113,9');
  writeln(F,'6P6K=75,77,72,76,82,11');
  writeln(F,'P1=MARK');
  writeln(F,'P2=DAVE');
  writeln(F,'P3=CHRIS');
  writeln(F,'P4=JOY');
  writeln(F,'P5=WES');
  writeln(F,'P6=MOAKSIE');
  writeln(F,'GPL=3');
  writeln(F,'GBA=1');
  writeln(F,'GTY=2');
  writeln(F,'GFL=2');
  writeln(F,'GDI=2');
  close(F);
end;

function GK(a,b : word) : string;
  var s,s2 : string;
begin
  str(GameKeys[a,b,1],s); s2:=s;
  str(GameKeys[a,b,2],s); s2:=s2+','+s;
  str(GameKeys[a,b,3],s); s2:=s2+','+s;
  str(GameKeys[a,b,4],s); s2:=s2+','+s;
  str(GameKeys[a,b,5],s); s2:=s2+','+s;
  str(Smudge[a,b],s); s2:=S2+','+s;
  GK:=s2;
end;

procedure WriteIni;
  var F : text;
      a,b : byte;
      S,S2 : string;
begin
  assign(F,'sm2.ini');
  rewrite(F);
  for a:=1 to 6 do begin
    for b:=1 to a do begin
      str(a,s);
      str(b,s2);
      writeln(F,S+'P'+S2+'K='+GK(a,b));
    end;
  end;
  for a:=1 to 6 do begin
    str(a,s);
    writeln(F,'P'+s+'='+Names[a]);
  end;
  str(GPlayers,S);
  writeln(F,'GPL='+S);
  str(GBackG,S);
  writeln(F,'GBA='+S);
  str(GType,S);
  writeln(F,'GTY='+S);
  str(GFlong,S);
  writeln(F,'GFL='+S);
  str(GHard,S);
  writeln(F,'GDI='+S);

  close(F);
end;

procedure ReadIni;
  var F : text;
      PNo,GNo : byte;
      S : string[45];
      code : integer;
begin
  assign(F,'SM2.INI');
  reset(F);
  repeat
    readln(F,S);
    if (s[2]='P') and (s[4]='K') then begin
      val(S[1],GNo,code);
      val(S[3],PNo,code);
      S:=copy(S,pos('=',S)+1,length(S));
      val(copy(S,1,pos(',',S)-1),GameKeys[GNo,PNo,1],code);
      S:=copy(S,pos(',',S)+1,length(S));
      val(copy(S,1,pos(',',S)-1),GameKeys[GNo,PNo,2],code);
      S:=copy(S,pos(',',S)+1,length(S));
      val(copy(S,1,pos(',',S)-1),GameKeys[GNo,PNo,3],code);
      S:=copy(S,pos(',',S)+1,length(S));
      val(copy(S,1,pos(',',S)-1),GameKeys[GNo,PNo,4],code);
      S:=copy(S,pos(',',S)+1,length(S));
      val(copy(S,1,pos(',',S)-1),GameKeys[GNo,PNo,5],code);
      S:=copy(S,pos(',',S)+1,length(S));
      val(S,Smudge[GNo,PNo],code);
    end;

    if (s[1]='P') then begin
      val(S[2],PNo,Code);
       Names[PNo]:=copy(S,pos('=',S)+1,length(S));
    end;
    
    if (copy(S,1,3)='GPL') then val(copy(S,5,length(S)),GPlayers,Code);
    if (copy(S,1,3)='GBA') then val(copy(S,5,length(S)),GBackG,Code);
    if (copy(S,1,3)='GTY') then val(copy(S,5,length(S)),GType,Code);
    if (copy(S,1,3)='GDI') then val(copy(S,5,length(S)),GHard,Code);
    if (copy(S,1,3)='GFL') then val(copy(S,5,length(S)),GFlong,Code);
  until eof(F);
  close(F);
end;

procedure LoadDefaults;
  var DirInfo : SearchRec;
begin
  findfirst('sm2.INI',Archive,DirInfo);
  if DosError<>0 then WriteDefaultIni;
  ReadIni;
end;

{ FONT ROUTINES }

procedure ClipChar(X1,Y1,X2,Y2 : word; i : byte);
begin
  getmem(Font[i], ((X2-X1)+1)*((Y2-Y1)+1)+6);
  t2_getpic(X1,Y1,(X2-X1)+1,(Y2-Y1)+1,Font[i]);
  Width[i]:=(X2-X1)+1;
  Height[i]:=(Y2-Y1)+1;
end;

procedure ClipCha(X1,Y1,Xs,Ys : word; i : byte);
begin
  getmem(Font[i], (Xs*Ys)+6);
  t2_getpic(X1,Y1,Xs,Ys,Font[i]);
  Width[i]:=Xs;
  Height[i]:=Ys;
end;

procedure LoadFont2;
begin
  ClipCha(37,1,10,13,65);  ClipCha(51,1,10,13,66);  ClipCha(64,1,10,13,67);
  ClipCha(78,1,10,13,68);  ClipCha(91,1,10,13,69);  ClipCha(105,1,10,13,70);
  ClipCha(118,1,10,13,71); ClipCha(132,1,9,13,72);  ClipCha(145,1,5,13,73);
  ClipCha(154,1,10,13,74); ClipCha(168,1,10,13,75); ClipCha(182,1,9,13,76);
  ClipCha(194,1,14,13,77); ClipCha(212,1,10,13,78); ClipCha(38,19,9,13,79);
  ClipCha(51,19,10,13,80); ClipCha(64,19,10,13,81); ClipCha(78,19,10,13,82);
  ClipCha(92,19,10,13,83); ClipCha(105,19,10,13,84);ClipCha(119,19,9,13,85);
  ClipCha(132,19,10,13,86);ClipCha(145,19,15,13,87);ClipCha(163,19,9,13,88);
  ClipCha(176,19,10,13,89);ClipCha(189,19,10,13,90);ClipCha(37,36,10,13,48);
  ClipCha(51,36,7,13,49);  ClipCha(64,36,9,13,50);  ClipCha(77,36,8,13,51);
  ClipCha(89,36,9,13,52);  ClipCha(103,36,8,13,53); ClipCha(116,36,9,13,54);
  ClipCha(129,36,9,13,55); ClipCha(142,36,9,13,56); ClipCha(155,36,9,13,57);
  ClipCha(1,90,19,25,33);  ClipCha(33,90,12,25,34); ClipCha(59,90,19,25,35);
  ClipCha(89,90,18,25,36); ClipCha(118,90,20,25,37); ClipCha(148,90,18,25,38);
  ClipCha(177,90,20,25,39); ClipCha(208,90,17,25,40); ClipCha(236,90,19,25,41);
  ClipCha(265,90,20,25,42);
end;

procedure UnLoadFont2;
  var i : byte;
begin
  for i:=65 to 90 do
    freemem(Font[i],(Width[i]*Height[i])+6);
  for i:=33 to 42 do
    freemem(Font[i],(Width[i]*Height[i])+6);
  for i:=48 to 57 do
    freemem(Font[i],(Width[i]*Height[i])+6);
end;

procedure LoadFont;
begin
  ClipChar(9,42,13,55,33);     ClipChar(15,42,19,55,34);
  ClipChar(23,42,30,55,35);    ClipChar(33,42,43,55,36);
  ClipChar(45,42,60,55,37);    ClipChar(61,42,74,55,38);
  ClipChar(75,42,77,55,39);    ClipChar(79,42,84,55,40);
  ClipChar(85,42,90,55,41);    ClipChar(94,42,100,55,42);
  ClipChar(103,42,111,55,43);  ClipChar(113,42,117,55,44);
  ClipChar(119,42,124,55,45);  ClipChar(127,42,130,55,46);
  ClipChar(131,42,136,55,47);  ClipChar(137,42,148,55,48);
  ClipChar(152,42,157,55,49);  ClipChar(162,42,173,55,50);
  ClipChar(175,42,186,55,51);  ClipChar(187,42,199,55,52);
  ClipChar(201,42,212,55,53);  ClipChar(214,42,224,55,54);
  ClipChar(226,42,236,55,55);  ClipChar(239,42,249,55,56);
  ClipChar(252,42,262,55,57);  ClipChar(265,42,268,55,58);
  ClipChar(271,42,275,55,59);  ClipChar(277,42,285,55,60);
  ClipChar(287,42,294,55,61);  ClipChar(297,42,304,55,62);
  ClipChar(306,42,316,55,63);  ClipChar(9,60,20,73,64);
  ClipChar(21,60,35,73,65);    ClipChar(36,60,46,73,66);
  ClipChar(48,60,57,73,67);    ClipChar(58,60,69,73,68);
  ClipChar(70,60,80,73,69);    ClipChar(81,60,90,73,70);
  ClipChar(91,60,102,73,71);   ClipChar(103,60,113,73,72);
  ClipChar(116,60,120,73,73);  ClipChar(121,60,130,73,74);
  ClipChar(131,60,143,73,75);  ClipChar(144,60,153,73,76);
  ClipChar(154,60,168,73,77);  ClipChar(170,60,181,73,78);
  ClipChar(183,60,193,73,79);  ClipChar(195,60,206,73,80);
  ClipChar(207,60,218,73,81);  ClipChar(219,60,231,73,82);
  ClipChar(232,60,242,73,83);  ClipChar(243,60,253,73,84);
  ClipChar(254,60,266,73,85);  ClipChar(267,60,278,73,86);
  ClipChar(279,60,294,73,87);  ClipChar(295,60,306,73,88);
  ClipChar(307,60,319,73,89);  ClipChar(9,79,19,93,90);
  ClipChar(21,79,26,93,91);    ClipChar(27,79,31,93,92);
  ClipChar(32,79,36,93,93);    ClipChar(39,79,46,93,94);
  ClipChar(48,79,56,93,95);    ClipChar(56,78,60,81,96);
  ClipChar(62,79,72,93,97);    ClipChar(73,79,83,93,98);
  ClipChar(85,79,93,93,99);   ClipChar(95,79,105,93,100);
  ClipChar(105,79,116,93,101); ClipChar(117,79,125,93,102);
  ClipChar(126,79,136,93,103); ClipChar(138,79,148,93,104);
  ClipChar(150,79,154,93,105); ClipChar(155,79,163,93,106);
  ClipChar(164,79,175,93,107); ClipChar(176,79,180,93,108);
  ClipChar(182,79,196,93,109); ClipChar(198,79,208,93,110);
  ClipChar(209,79,219,93,111); ClipChar(221,79,231,93,112);
  ClipChar(232,79,243,93,113); ClipChar(243,79,250,93,114);
  ClipChar(251,79,261,93,115); ClipChar(262,79,270,93,116);
  ClipChar(271,79,282,93,117); ClipChar(282,79,292,93,118);
  ClipChar(293,79,307,93,119); ClipChar(308,79,319,93,120);
  ClipChar(9,97,19,111,121);   ClipChar(21,97,31,111,122);
  ClipChar(32,97,38,111,123);  ClipChar(40,97,41,111,124);
  ClipChar(43,97,49,111,125);  ClipChar(51,97,57,111,126);
end;

procedure UnLoadGameGFX;
  var x,y,x1,y1 : byte;
begin
  for y:=0 to 10 do for x:=0 to 3 do freemem(Smudges[y+1,x+1],70);
  for x:=1 to 6 do for x1:=1 to 8 do for y1:=1 to 8 do freemem(Backs[x,x1,y1],70);
  for x:=1 to 6 do for y:=1 to 4 do freemem(Pieces[x,y],70);
  freemem(Swap,7686);
  freemem(Strip,366);
  UnloadFont2;
end;

procedure LoadGameGFX;
  var x,y,x1,y1 : byte;
begin
  t2_set_buf(1);
  Load_Pcx(GFX+'Sm2.pcx');
  LoadFont2;
  for y:=0 to 10 do for x:=0 to 3 do begin
    getmem(Smudges[y+1,x+1],70);
    t2_getpic((X*8),(Y*8),8,8,Smudges[y+1,x+1]);
  end;
  for x:=1 to 6 do begin
    for x1:=0 to 7 do for y1:=0 to 7 do begin
      getmem(Backs[x,x1+1,y1+1],70);
      t2_getpic(((x*48)-29)+(x1*8),150+(y1*8),8,8,Backs[x,x1+1,y1+1]);
    end;
  end;

  for x:=1 to 6 do for y:=1 to 4 do begin
    getmem(Pieces[x,y],70);
    t2_getpic(38+(x*9),42+(y*9),8,8,Pieces[x,y]);
  end;
  getmem(Swap,7686);
  getmem(Strip,366);
end;

function TWidth(s : string) : integer;
  var l,t : word;
begin
  t:=0;
  for l:=1 to length(s) do begin
    if (s[l]>='!') and (s[l]<='~') then t:=t+width[ord(s[l])];
    if (s[l]=' ') then t:=t+5;
  end;
  TWidth:=t;
end;

procedure Textxy(x,y1 : word; s : string);
  var l : byte;
      x1 : word;
      y : integer;
begin
  x1:=x; y:=0;
  for l:=1 to length(s) do begin
    if (s[l]>='!') and (s[l]<='~') then begin
      y:=0;
      if s[l]=';' then y:=3;
      if s[l]='[' then y:=1;
      if s[l]=']' then y:=1;
      t2_putpic(x1,y1-y,font[ord(s[l])]); x1:=X1+width[ord(s[l])];
    end;
    if s[l]=' ' then begin t2_block(x1,y1,4,14,0); x1:=X1+5; end;
  end;
end;

procedure CentreText(x,y : word; s : string);
begin
  Textxy(x-(TWidth(s) div 2),y,s);
end;

procedure TimerText(x,y : word; s : string);
  var W,i,h : word;
begin
  W:=0; h:=0;
  for i:=1 to length(S) do W:=W+Width[ord(s[i])-15]+1;
  for i:=1 to length(S) do begin
    t2_putpic(x-(w div 2)+h,y,Font[ord(s[i])-15]);
    h:=h+Width[ord(s[i])-15]+1;
  end;
end;

procedure UnLoadfont;
  var l : byte;
begin
  for l:=33 to 126 do begin
    freemem(Font[l],(Width[l]*Height[l])+6);
  end;
end;

{ GRAPHICS ROUTINES }

procedure InitAud;
begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Module := DSMLoad(AUDIO+'Smudge.DSM',0);
  if Module = nil then begin
    case DSMStatus of
      ERR_NORAM:  writeln('Not enough system memory.');
      ERR_NODRAM: writeln('Not enough card memory.');
      ERR_NOFILE: writeln('File not found.');
      ERR_FORMAT: writeln('Invalid file format.');
      ERR_ACCESS: writeln('File damaged.');
    end;
    DSMDone;
    exit;
  end;
  DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
  DSMSetMusicVolume(255);
  DsmPlayMusic(Module);
  Music := DSMGetMusicInfo;
  muson:=true;
end;

procedure InitVid;
  var x,y : integer;
begin
  tk_start;
  t2_start(1);
  t2_set_buf(1);
  load_pcx(GFX+'P1-Font.pcx');
  LoadFont;
end;

procedure CloseVid;
begin
  t2_end;
  tk_end;
end;

procedure CloseAud;
  var x,y,x1,y1 : byte;
begin
  if muson then begin
    DSMStopMusic;
    DSMFree(Module);
    dsmdone;
  end;
  muson:=false;
end;

procedure UpdateOpts;
  var i : byte;
      W : integer;
      s : string;
begin
  dsmpoll;
  t2_vretrace;
  t2_block(0,0,319,124,0);
  str(GPlayers,s);
  CentreText(160,0,'PLAYERS :  '+s);
  CentreText(105,20,'<-');
  CentreText(152,20,'->');
  CentreText(199,20,'/\');
  CentreText(246,20,'\/');
  CentreText(293,20,'!');
  for i:=1 to GPlayers do begin
    W:=80-TWidth(Names[i]);
    if W<0 then W:=0;
    Textxy(W,20+(i*15),Names[i]);
    t2_block(83,19+(i*15),200,14,0);
    CentreText(105,20+(i*15),KeyName[GameKeys[GPlayers,i,1]]);
    CentreText(152,20+(i*15),KeyName[GameKeys[GPlayers,i,2]]);
    CentreText(199,20+(i*15),KeyName[GameKeys[GPlayers,i,3]]);
    CentreText(246,20+(i*15),KeyName[GameKeys[GPlayers,i,4]]);
    CentreText(293,20+(i*15),KeyName[GameKeys[GPlayers,i,5]]);
    t2_line(82,33+((i-1)*15),82,33+(i*15),50);
    t2_line(129,33+((i-1)*15),129,34+(i*15),50);
    t2_line(176,33+((i-1)*15),176,34+(i*15),50);
    t2_line(223,33+((i-1)*15),223,34+(i*15),50);
    t2_line(270,33+((i-1)*15),270,34+(i*15),50);
    t2_line(317,33+((i-1)*15),317,34+(i*15),50);
    t2_line(82,33+((i-1)*15),317,34+((i-1)*15),50);
    t2_line(82,33+(i*15),317,33+(i*15),50);
  end;
end;

procedure UpdateMinis;
  const Game : array[1..3] of string = ('Panic','Devour','Ultimate');
  const Scene : array[1..6] of string = ('Prairie','Ocean','Nova','Marble','Leaves','Bowels');
  const Flong : array[1..6] of string = ('Dull','Blue','Pear','Tomato','Banana','Velvet');
  const Diffi : array[1..5] of string = ('Fumey','Frusty','Frowzy','Foul','Fetid');
begin
  dsmpoll;
  t2_vretrace;
  t2_block(10,185,90,15,0);
  t2_block(230,185,89,15,0);
  t2_block(10,155,70,15,0);
  t2_block(240,155,89,15,0);
  Textxy(0,140,'Scene:');
  Textxy(0,170,'Flong:');
  TextXy(319-TWidth('Game:'),170,'Game:');
  Textxy(319-TWidth('Level:'),140,'Level:');
  Textxy(10,155,Scene[GBackG]);
  Textxy(10,185,Flong[GFLong]);
  Textxy(310-TWidth(Diffi[GHard]),155,Diffi[GHard]);
  Textxy(310-TWidth(Game[GType]),185,Game[Gtype]);
end;

procedure CHName(n : byte);
  var S : string;
      ch : byte;
begin
  t2_block(0,33+(15*(n-1)),80,14,0);
  t2_line(0,33+(15*n),80,33+(15*n),60);
  S:='';
  repeat
    dsmpoll;
    t2_vretrace;
    repeat until tK_Readkey<>0;
  until not tk_keypressed;
  repeat
    repeat
      dsmpoll;
      t2_vretrace;
    until tk_keypressed;
    ch:=tk_readkey;
    if (length(KeyName[ch])=1) and (((KeyName[ch]>='A') and (KeyName[ch]<='Z'))
      or ((KeyName[ch]>='0') and (KeyName[ch]<='9')))
      and (TWidth(S+KeyName[ch])<80) then S:=S+KeyName[ch];
    if (length(s)>0) and (ch=14) then begin
      s:=copy(s,1,length(S)-1);
    end;

    t2_block(0,33+(15*(n-1)),80,14,0);
    Textxy(80-TWidth(S),20+(n*15),S);
    t2_line(0,33+(15*n),80,33+(15*n),60);
  until (ch=28) or (ch=1);
  if (ch=28) and (S<>'') then NAmes[n]:=S;
end;

procedure CHKeys(n : byte);
  var a,b,i,r : byte;
      k : array[1..5] of byte;
      OK : boolean;
begin
  repeat
    if tk_keypressed then repeat
      dsmpoll;
      t2_vretrace;
    until tk_readkey<>0;
  until not tk_keypressed;

  for i:=1 to 5 do begin
    if r>1 then begin
      t2_line(82,33+(n*15),317,33+(n*15),50);
      t2_line(35+(i*47),33+(n*15),82+(i*47),33+(n*15),60);
      t2_block(36+(i*47),34+((n-1)*15),46,14,0);
      repeat
        repeat
          dsmpoll;
          t2_vretrace;
        until tk_keypressed;
        r:=tk_readkey;
        if r>1 then begin
          OK:=true;
          for a:=1 to GPlayers do
            for b:=1 to 5 do
              if (a<>n) and (GameKeys[GPlayers,a,b]=r) then OK:=false;
          if i>1 then
            for a:=1 to i-1 do
              if k[a]=r then OK:=false;
        end;
      until OK or (r=1);
      k[i]:=r;
      CentreText(58+(47*i),20+(n*15),KeyName[k[i]]);
      t2_line(82,n*15,317,n*15,50);
      t2_line(35+(i*47),33+(n*15),82+(i*47),33+(n*15),60);
    end;
  end;
  if r>1 then
    for i:=1 to 5 do
      GameKeys[GPlayers,n,i]:=k[i];
end;

procedure TitlePage;
  var Play : boolean;
      Changing : byte;
      P : pointer;
      ScanLine,Pane : pointer;
      LineNo : word; ScrollNo : byte;
      y,Toggle : byte;
      StripsS : array[0..29] of pointer;
      StripsM : array[0..66] of pointer;
      CountY,SineCount : word;
      SizeY,Step2,Step,SizeX : real;

      Sty,Top : integer;
  const ScrollText : array[1..101] of String[38] =
    ('Smudgelet''s Maze 2000',' ','**********','',
     'Press any key to play','','**********','',
     'On April 15th 1982, in a nuclear',
     'waste plant in Brenchley, a',
     'dreadful catastrophe of a highly',
     'implicational nature occurred.',
     '','A blockage in the waste disposal',
     'unit caused an unidentified mass','of crusty fossilised baked beans,',
     'brown gunk, green slime, some','odd socks, an anvil, assorted root',
     'vegetables, a defunct electric','hair curler, a bucket-load of',
     'rubber chickens, and three small','sweet saute potatoes, as grown',
     'on the Northern faces of','Mount Kilimanjaro to be left',
     'unattended in the open.','','Later that day, a freak storm',
     'ensued, and the dreadful mass','of conglomerated artefacts was',
     'struck by a bolt of lightning with','extreme power!','',
     'The components were fried, and','the hideous heap became molten.',
     'Within minutes, the horror was','enormified, as this rancid slagheap',
     'started to live and breathe! Out','of the bowels of Brenchley, a new',
     'monster had been made...','','THE INCREDIBLE MULK!','',
     '','but that''s another story.','','You are a Smudgelet: a low-life',
     'runt of a creature. To avoid being','eaten by wild mulk, Smudgelets',
     'grovel pathetically underground','in dark dank rank and skanky',
     'underground caverns, feeding on','the lice of the lesser-brained',
     'gutter-flong. Each cavern is a','complex labyrinth with one',
     'entry and exit. The only worry for','a smudgelet, is a dead end -',
     'having to go back through paths','already eaten, could be the end',
     'of a hungry smudgelet.','',
     'Your survival depends on your',
     'wits and quick thinking!','Good Luck!','','','',' - CREDITS -',
     '','','DESIGN, CODE, AUDIO, VISUAL','- Wes -','','','GFX AND KEYBOARD SUPPORT','- Tom -',
     '','','ADDITIONAL AUDIO DESIGN','- Tim -','','','ADDITIONAL CONCEPTUAL DESIGN','- Matt, Sam -','','','PLAY TESTERS',
     '- Wes, Rich, Matt, Tim, Olaf, Sam -','- Chris, Dave, Mark, Joy -',
     '','','','COPYRIGHT 2000','WCT ENTERTAINMENT','09-09-2000','','***','','','','','');
     NoLines : byte = 101;

begin
  t2_set_buf(1);
  yespalette;
  load_pcx(GFX+'P1-Font.pcx');
  getmem(P,24000);
  t2_getpic(0,0,319,30,P);
  t2_set_buf(0); t2_putpic(0,0,P);
  t2_set_buf(1);
  t2_getpic(0,133,319,67,P);
  t2_set_buf(0); t2_putpic(0,133,P); freemem(P,24000);

  {Init Story Scroll}

  LineNo:=0; ScrollNo:=0; getmem(ScanLine,330); getmem(Pane,30606);
  t2_set_buf(1); t2_block(0,0,319,30,0);
  Music^.OrderPosition:=$18;
  DSMSetMusicVolume(96);
  repeat
    {Scroll up}
    if Toggle>=3 then begin
      dsmpoll;
      t2_vretrace;
      t2_getpic(0,40,319,90,Pane);
      dsmpoll;
      t2_putpic(0,39,Pane);
      inc(ScrollNo);
      t2_set_buf(1);
      if ScrollNo=15 then begin {New Line of Characters in buffer}
        ScrollNo:=0;
        inc(LineNo); if LineNo>NoLines then LineNo:=1;
        t2_block(0,0,319,20,0);
        CentreText(160,0,ScrollText[LineNo]);
      end;
      dsmpoll;
      t2_getpic(0,ScrollNo,319,1,ScanLine);
      t2_set_buf(0);
      t2_putpic(0,129,ScanLine);
    end;
    dsmpoll;
    t2_vretrace;
    Toggle:=(Toggle mod 3) +1;
  until tk_keypressed;
  if tk_kp[1] then begin UnLoadFont; CloseAud; t2_end; tk_end; halt; end;
  freemem(ScanLine,330); freemem(Pane,30606);
  t2_set_buf(0);
  for LineNo:=0 to 29 do begin
    getmem(StripsS[LineNo],326);
    t2_getpic(1,LineNo,318,1,StripsS[LineNo]);
  end;
  for LineNo:=0 to 66 do begin
    getmem(StripsM[LineNo],326);
    t2_getpic(1,133+LineNo,318,1,StripsM[LineNo]);
  end;
  Step:=0; Top:=0; SineCount:=0;
  repeat
    inc(SineCount);
    Step:=130-(65*(1+cos(SineCount/18.5)));
    SizeY:=29-(15*(Step/130));
    CountY:=0;
    Sty:=29;
    repeat
      SizeX:=319/((1+(Step/130))+(0.4*((30-sty)/30)*(Step/130)));
      t2_block(0,trunc(30+Step)-CountY,319,1,0);
      t2_set_scale_size(trunc(SizeX),1);
      t2_scale_pic(160-trunc(SizeX/2),trunc(30+Step)-CountY,StripsS[StY]);
      Sty:=trunc(29-(29*(CountY/SizeY)));
      inc(CountY);
    until Sty<0;
    Top:=trunc((30+Step)-CountY);
    t2_block(0,Top,319,1,0);
    if Top>0 then dec(Top);
    t2_block(0,Top,319,1,0);
    if Top>0 then dec(Top);
    t2_block(0,Top,319,1,0);

    SizeY:=66-28*(Step/130);
    CountY:=0;
    Top:=trunc(133+28*(Step/130));
    Sty:=0;
    repeat
      SizeX:=319/((1+(Step/130))+(0.4*((sty)/66)*(Step/130)));
      t2_set_scale_size(trunc(SizeX),1);
      t2_block(0,Top+CountY,319,1,0);
      t2_scale_pic(160-trunc(SizeX/2),trunc(Top+CountY),StripsM[sty]);
      Sty:=trunc(66*(CountY/SizeY));
      inc(CountY);
    until Top+CountY>199;
    t2_block(0,199,319,1,0);
    dsmpoll;
    t2_vretrace;
  until SineCount>=60;
  for LineNo:=0 to 29 do freemem(StripsS[LineNo],326);
  for LineNo:=0 to 66 do freemem(StripsM[LineNo],326);

  repeat
    if tk_keypressed then repeat until tk_readkey<>0;
  until not tk_keypressed;
  UpdateOpts;
  UpdateMinis;
  Play:=false;
  Changing:=15;
  repeat
    if Changing=0 then t2_line(100,14,220,14,240)
    else if Changing=1 then t2_line(0,48,80,48,240)
    else if Changing=2 then t2_line(84,48,317,48,240)
    else if Changing=3 then t2_line(0,63,80,63,240)
    else if Changing=4 then t2_line(84,63,317,63,240)
    else if Changing=5 then t2_line(0,78,80,78,240)
    else if Changing=6 then t2_line(84,78,317,78,240)
    else if Changing=7 then t2_line(0,93,80,93,240)
    else if Changing=8 then t2_line(84,93,317,93,240)
    else if Changing=9 then t2_line(0,108,80,108,240)
    else if Changing=10 then t2_line(84,108,317,108,240)
    else if Changing=11 then t2_line(0,123,80,123,240)
    else if Changing=12 then t2_line(84,123,317,123,240)
    else if Changing=13 then t2_line(10,168,80,168,240)
    else if Changing=14 then t2_line(240,168,310,168,240)
    else if Changing=15 then t2_line(10,198,80,198,240)
    else if Changing=16 then t2_line(240,198,310,198,240)
    else if Changing=17 then begin
      t2_line(80,199,240,199,240);
      t2_line(80,143,240,143,240);
    end;
    dsmpoll;
    t2_vretrace;
    if Changing=0 then t2_line(100,14,220,14,0)
    else if Changing=1 then t2_line(0,48,80,48,0)
    else if Changing=2 then t2_line(84,48,317,48,50)
    else if Changing=3 then t2_line(0,63,80,63,0)
    else if Changing=4 then t2_line(84,63,317,63,50)
    else if Changing=5 then t2_line(0,78,80,78,0)
    else if Changing=6 then t2_line(84,78,317,78,50)
    else if Changing=7 then t2_line(0,93,80,93,0)
    else if Changing=8 then t2_line(84,93,317,93,50)
    else if Changing=9 then t2_line(0,108,80,108,0)
    else if Changing=10 then t2_line(84,108,317,108,50)
    else if Changing=11 then t2_line(0,123,80,123,0)
    else if Changing=12 then t2_line(84,123,317,123,50)
    else if Changing=13 then t2_line(10,168,80,168,0)
    else if Changing=14 then t2_line(240,168,310,168,0)
    else if Changing=15 then t2_line(10,198,80,198,0)
    else if Changing=16 then t2_line(240,198,310,198,0);
    UpdateMinis;
    if Changing=17 then begin
      t2_line(80,199,240,199,0);
      t2_line(80,143,240,143,0);
    end;
    if tk_keypressed then begin
      if tk_kp[108] then
        if Changing>0 then Changing:=Changing-1 else Changing:=17;
      if tk_kp[104] then
        Changing:=(Changing+1) mod 18;
      if tk_kp[106] then begin
        if Changing>1 then dec(Changing,2) else
        if Changing=1 then Changing:=16 else
        if Changing=0 then Changing:=17;
      end;
      if tk_kp[110] then begin
        if Changing<16 then inc(Changing,2) else
        if Changing=16 then Changing:=1 else
        if Changing=17 then Changing:=0;
      end;
      if tk_kp[110] or tk_kp[104] then begin
        if (Changing=3) and (Gplayers<2) then inc(Changing,2);
        if (Changing=4) and (GPlayers<2) then inc(Changing,2);
        if (Changing=5) and (GPlayers<3) then inc(Changing,2);
        if (Changing=6) and (GPlayers<3) then inc(Changing,2);
        if (Changing=7) and (GPlayers<4) then inc(Changing,2);
        if (Changing=8) and (GPlayers<4) then inc(Changing,2);
        if (Changing=9) and (GPlayers<5) then inc(Changing,2);
        if (Changing=10) and (GPlayers<5) then inc(Changing,2);
        if (Changing=11) and (GPlayers<6) then inc(Changing,2);
        if (Changing=12) and (GPlayers<6) then inc(Changing,2);
      end;
      if tk_kp[108] or tk_kp[106] then begin
        if (Changing=12) and (GPlayers<6) then dec(Changing,2);
        if (Changing=11) and (GPlayers<6) then dec(Changing,2);
        if (Changing=10) and (GPlayers<5) then dec(Changing,2);
        if (Changing=9) and (GPlayers<5) then dec(Changing,2);
        if (Changing=8) and (GPlayers<4) then dec(Changing,2);
        if (Changing=7) and (GPlayers<4) then dec(Changing,2);
        if (Changing=6) and (GPlayers<3) then dec(Changing,2);
        if (Changing=5) and (GPlayers<3) then dec(Changing,2);
        if (Changing=4) and (GPlayers<2) then dec(Changing,2);
        if (Changing=3) and (Gplayers<2) then dec(Changing,2);
      end;

      if tk_kp[1] then begin UnLoadFont; RunMe:=false; exit; end;
      if tk_kp[28] then begin
        if Changing=0 then begin GPlayers:=(GPlayers mod 6) + 1; UpdateOpts; end
        else if Changing=1 then begin CHName(1); UpdateOpts; end
        else if Changing=2 then begin CHKeys(1); UpdateOpts; end
        else if Changing=3 then begin CHName(2); UpdateOpts; end
        else if Changing=4 then begin ChKeys(2); UpdateOpts; end
        else if Changing=5 then begin CHName(3); UpdateOpts; end
        else if Changing=6 then begin CHKeys(3); UpdateOpts; end
        else if Changing=7 then begin ChName(4); UpdateOpts; end
        else if Changing=8 then begin CHKeys(4); UpdateOpts; end
        else if Changing=9 then begin ChName(5); UpdateOpts; end
        else if Changing=10 then begin CHKeys(5); UpdateOpts; end
        else if Changing=11 then begin ChName(6); UpdateOpts; end
        else if Changing=12 then begin CHName(6); UpdateOpts; end
        else if Changing=13 then begin GBackG:=(GBackG mod 6)+1; UpdateMinis; end
        else if Changing=14 then begin GHard:=(GHard mod 5)+1; UpdateMinis; end
        else if Changing=15 then begin GFlong:=(GFlong mod 6) +1; UpdateMinis; end
        else if Changing=16 then begin GType:=(GType mod 3) + 1; UpdateMinis; end
        else if Changing=17 then Play:=true;
        dsmpoll;
        t2_vretrace;
      end;
      if tk_keypressed then repeat until tk_readkey<>0;
      dsmpoll;
      t2_vretrace;
    end;
    dsmpoll;
    t2_vretrace;
  until Play;
  dsmpoll;
  UnLoadFont;
  WriteIni;
  RunMe:=true;
end;

procedure PrepareLeft(P,B : byte);
  var Iy : byte;
begin
  t2_set_buf(1);
  for Iy:=0 to 9 do begin
    if Map.Data[Sx[P]-1,Sy[P]+Iy,P]=1 then
      t2_putpic(P*8,Iy*8,Backs[B,((Sx[P]-1) mod 6)+1,((Sy[P]+Iy) mod 6)+1]);
    if Map.Data[Sx[P]-1,Sy[P]+Iy,P]=0 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,2]);
    if Map.Data[Sx[P]-1,Sy[P]+Iy,P]=2 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,3]);
    if Map.Data[Sx[P]-1,Sy[P]+Iy,P]=3 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,1]);
    if Map.Data[SX[P]-1,Sy[P]+Iy,P]=4 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,4]);
  end;
  t2_set_buf(0);
end;

procedure PrepareRight(P,B : byte);
  var Iy : byte;
begin
  t2_set_buf(1);
  for Iy:=0 to 9 do begin
    if Map.Data[Sx[P]+12,Sy[P]+Iy,P]=1 then
      t2_putpic(P*8,Iy*8,Backs[B,((Sx[P]+12) mod 6)+1,((Sy[P]+Iy) mod 6)+1]);
    if Map.Data[Sx[P]+12,Sy[P]+Iy,P]=0 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,2]);
    if Map.Data[Sx[P]+12,Sy[P]+Iy,P]=2 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,3]);
    if Map.Data[Sx[P]+12,Sy[P]+Iy,P]=3 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,1]);
    if Map.Data[Sx[P]+12,Sy[P]+Iy,P]=4 then
      t2_putpic(P*8,Iy*8,Pieces[GFlong,4]);

  end;
  t2_set_buf(0);
end;

procedure PrepareUp(P,B : byte);
  var Ix : byte;
begin
  t2_set_buf(1);
  for Ix:=0 to 11 do begin
    if Map.Data[Sx[P]+Ix,Sy[P]-1,P]=1 then
      t2_putpic(Ix*8,100+(P*8),Backs[B,((Sx[P]+Ix) mod 6)+1,((Sy[P]-1) mod 6)+1]);
    if Map.Data[Sx[P]+Ix,Sy[P]-1,P]=0 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,2]);
    if Map.Data[Sx[P]+Ix,Sy[P]-1,P]=2 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,3]);
    if Map.Data[Sx[P]+Ix,Sy[P]-1,P]=3 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,1]);
    if Map.Data[Sx[P]+Ix,Sy[P]-1,P]=4 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,4]);
  end;
  t2_set_buf(0);
end;

procedure PrepareDown(P,B : byte);
  var Ix : byte;
begin
  t2_set_buf(1);
  for Ix:=0 to 11 do begin
    if Map.Data[Sx[P]+Ix,Sy[P]+10,P]=1 then
      t2_putpic(Ix*8,100+(P*8),Backs[B,((Sx[P]+Ix) mod 6)+1,((Sy[P]+10) mod 6)+1]);
    if Map.Data[Sx[P]+Ix,Sy[P]+10,P]=0 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,2]);
    if Map.Data[Sx[P]+Ix,Sy[P]+10,P]=2 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,3]);
    if Map.Data[Sx[P]+Ix,Sy[P]+10,P]=3 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,1]);
    if Map.Data[Sx[P]+Ix,Sy[P]+10,P]=4 then
      t2_putpic(Ix*8,100+(P*8),Pieces[GFlong,4]);

  end;
  t2_set_buf(0);
end;

procedure ScrollLeft(Pl,A,OffSet,Back,Plm : integer);
  var temp : integer;
begin
  temp:=(PlLeft[pl]-(OffSet-a))+(px[pl]-Sx[pl])*8;
  t2_putpic(temp,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+A+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[PlM,Pl],(1+Tog[Pl]) div 2]);
  t2_getpic(PlLeft[Pl]+A,PlTop[Pl],96-A,80,Swap);
  t2_putpic(PlLeft[Pl],PlTop[Pl],Swap);
  t2_set_buf(1);
  t2_getpic((pl*8)+(OffSet)-A,0,A,100,Strip);
  t2_set_buf(0);
  t2_putpic((PlLeft[Pl]+96)-A,PlTop[Pl],Strip);
  dec(Tog[pl]);
  if Tog[pl]=0 then Tog[pl]:=8;
end;

procedure ScrollUp(Pl,A,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,(PlTop[Pl]-(OffSet-A))+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,A+PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+Tog[pl]) div 2]);
  t2_getpic(PlLeft[Pl],PlTop[Pl]+A,96,80-A,Swap);
  t2_putpic(PlLeft[Pl],PlTop[Pl],Swap);
  t2_set_buf(1);
  t2_getpic(0,100+(pl*8)+(OffSet)-A,96,A,Strip);
  t2_set_buf(0);
  t2_putpic(PlLeft[Pl],PlTop[Pl]+(80-A),Strip);
  dec(Tog[pl]);
  if Tog[pl]=0 then Tog[pl]:=8;
end;

procedure ScrollDown(Pl,A,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(OffSet-A)+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]-A+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+Tog[pl]) div 2]);
  t2_getpic(PlLeft[Pl],PlTop[Pl],96,80-A,Swap);
  t2_putpic(PlLeft[Pl],PlTop[Pl]+A,Swap);
  t2_set_buf(1);
  t2_getpic(0,100+(pl*8)+(8-Offset),96,A,Strip);
  t2_set_buf(0);
  t2_putpic(PlLeft[Pl],PlTop[Pl],Strip);
  Tog[pl]:=(Tog[pl] mod 8)+1;
end;

procedure ScrollRight(Pl,A,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(OffSet-A)+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]-A+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+Tog[pl]) div 2]);
  t2_getpic(PlLeft[Pl],PlTop[Pl],96-A,80,Swap);
  t2_putpic(PlLeft[Pl]+A,PlTop[Pl],Swap);
  t2_set_buf(1);
  t2_getpic((pl*8)+(8-OffSet),0,A,80,Strip);
  t2_set_buf(0);
  t2_putpic(PlLeft[Pl],PlTop[Pl],Strip);
  Tog[pl]:=(Tog[pl] mod 8)+1;
end;

procedure SmudgeLeft(Pl,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic((PlLeft[Pl]-OffSet)+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+tog[pl]) div 2]);
  dec(Tog[pl]);
  if Tog[pl]=0 then Tog[pl]:=8;
end;

procedure SmudgeUp(Pl,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,(PlTop[Pl]-OffSet)+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+tog[pl]) div 2]);
  dec(Tog[pl]);
  if Tog[pl]=0 then Tog[pl]:=8;
end;

procedure SmudgeDown(Pl,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+OffSet+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+Tog[pl]) div 2]);
  Tog[pl]:=(Tog[pl] mod 8)+1;
end;

procedure SmudgeRight(Pl,OffSet,Back,Plm : integer);
begin
  t2_putpic(PlLeft[Pl]+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Pieces[GFlong,3]);
  t2_putpic(PlLeft[Pl]+OffSet+(Px[Pl]-Sx[Pl])*8,PlTop[Pl]+(Py[Pl]-Sy[Pl])*8,Smudges[Smudge[Plm,Pl],(1+Tog[pl]) div 2]);
  Tog[pl]:=(Tog[pl] mod 8)+1;
end;

procedure FirstPlot(Pl,Back,Plm : byte);
  var Ix,Iy : byte;
begin
  t2_set_buf(0);
  if (PX[Pl]>6) and (PX[Pl]<XSize-6) then Sx[Pl]:=Px[Pl]-6;
  if Px[Pl]>=XSize-6 then Sx[Pl]:=XSize-6;
  if Px[Pl]<=6 then Sx[Pl]:=0;
  if (PY[Pl]>5) and (PY[Pl]<YSize-5) then Sy[Pl]:=Py[Pl]-5;
  if PY[Pl]>=YSize-5 then Sy[Pl]:=YSize-5;
  if PY[Pl]<=5 then Sy[Pl]:=1;
  for Ix:=Sx[Pl] to SX[Pl]+11 do
    for Iy:=Sy[Pl] to Sy[Pl]+9 do begin
      if Map.Data[Ix,Iy,Pl]=1 then
        t2_putpic(PlLeft[Pl]+8*(Ix-Sx[Pl]),PlTop[Pl]+8*(Iy-Sy[Pl]),Backs[Back,(Ix mod 6)+1,(Iy mod 6)+1]);
      if Map.Data[Ix,Iy,Pl]=0 then
        t2_putpic(PlLeft[Pl]+8*(Ix-Sx[Pl]),PlTop[Pl]+8*(Iy-Sy[Pl]),Pieces[GFlong,2])
  end;
  t2_putpic(Plleft[Pl]+8*(Map.XEntrance-Sx[Pl]),PlTop[Pl]+8*
    (Map.YEntrance-Sy[Pl]),Smudges[Smudge[Plm,Pl],(1+Tog[Pl]) div 2]);
  Map.Data[Map.XEntrance,Map.YEntrance,Pl]:=2;
  Map.Data[Map.XExit,Map.YExit,Pl]:=4;
end;

procedure Game(Players : byte);
  var P : byte;
      ch : char;
      SmMove,SmDir : array[1..6] of byte;
      ScMove,ScDir : array[1..6] of byte;
      Alive : array[1..6] of byte;
      Speed : array[1..6] of byte;
      Order : array[1..6] of byte;
      Gone : array[1..6] of boolean;
      BackGr : byte;
      r : real;
      Time,Deaths,Escapes,i,max,j,CZ : byte;
      St : string;
      CX,Cy,Cx2,Cy2,hr,m,sec,h,oldsec,left,top,xs,ys : word;
      F : text;
begin
  if tk_keypressed then repeat
    if tk_keypressed then repeat until tk_readkey<>0;
  until not tk_keypressed;
  gettime(hr,m,sec,h);
  oldSec:=sec;
  dsmpoll;
  LoadGameGFX;
  dsmpoll;
  BackGr:=GBackg;
  t2_set_buf(0);
  t2_band(0,200,0);
  t2_set_buf(1);
  t2_band(0,200,0);
  load_pcx_palette(GFX+'sm2.pcx');
  if GHard=5 then begin XSize:=79; YSize:=59; end
  else if GHard=4 then begin XSize:=69; YSize:=49; end
  else if GHard=3 then begin XSize:=59; YSize:=39; end
  else if GHard=2 then begin XSize:=49; YSize:=29; end
  else if GHard=1 then begin XSize:=39; YSize:=19; end;
  dsmpoll;
  Create(XSize,YSize);
  t2_set_buf(0);
  t2_block(0,0,320,200,0);
  xs:=320 div (XSize+1);
  ys:=192 div (YSize+1);
  left:=(320-(xs*(xsize-1))) div 2;
  top:=8+((192-(ys*(ysize))) div 2);
  for cx:=0 to XSize-1 do
    for cy:=0 to YSize do
      if Map.Data[Cx+1,Cy,1]<>1 then t2_block((cx*xs)+left,(cy*ys)+top,xs,ys,101);
  t2_block(((Map.XExit-1)*xs)+left,(Map.YExit*ys)+top,xs,ys,152);
  t2_block(((Map.XEntrance-1)*xs)+left,(Map.YEntrance*ys)+top,xs,ys,152);
  Time:=10;

  repeat
    for i:=1 to GPlayers do
      t2_putpic(i*20,0,Smudges[Smudge[GPlayers,i],1+(Time mod 4)]);
    if TK_Keypressed then for i:=1 to GPlayers do begin
      if TK_KP[GameKeys[GPlayers,i,1]] then begin cx:=tk_readkey; Smudge[GPlayers,i]:=Smudge[GPlayers,i]-1; end;
      if Smudge[GPlayers,i]=0 then Smudge[Gplayers,i]:=11;
      if TK_KP[GameKeys[GPlayers,i,2]] then begin cx:=tk_readkey; Smudge[GPlayers,i]:=(Smudge[GPlayers,i] mod 11)+1; end;
      if TK_KP[57] then Time:=0;
      if TK_KP[1] then begin UnloadGameGfx; exit; end;
    end;
    dsmpoll;
    gettime(hr,m,sec,h);
    WriteIni;
    if (sec<>oldsec) and (Time>=0) then begin
      if Time>0 then dec(Time);
      OldSec:=sec;
      t2_block(270,0,49,13,0);
      str(Time,st);
      CentreText(295,0,st);
    end;
  until Time=0;
  CloseAud;
  InitAud;
  Deaths:=0; Time:=120; Escapes:=0;
  t2_block(0,0,320,200,0);
  repeat
    if tk_keypressed then repeat until tk_readkey<>0;
  until not tk_keypressed;

  if Players=1 then begin PLleft[1]:=112; PlTop[1]:=40;
                          Cx:=130; Cy:=140; Cz:=2; Cx2:=60; Cy2:=25; end
  else if Players=2 then begin Plleft[1]:=44; PlLeft[2]:=180; PlTop[1]:=40; PlTop[2]:=40;
                              Cx:=130; Cy:=130; Cz:=2; Cx2:=60; Cy2:=25; end
  else if Players=3 then begin PlLeft[1]:=3; PlLeft[2]:=111; PlLeft[3]:=219; PlTop[1]:=60; PlTop[2]:=60; PlTop[3]:=60;
                            Cx:=130; Cy:=150; Cz:=2; Cx2:=60; Cy2:=25; end
  else if Players=4 then begin PlLeft[1]:=34; PlLeft[2]:=190; PlLeft[3]:=34; PlLeft[4]:=190;
                            PLTop[1]:=15; PLTop[2]:=15; PLTop[3]:=113; PLTop[4]:=113;
                            Cx:=130; Cy:=85; Cz:=2; Cx2:=60; Cy2:=25; end
  else if Players=5 then begin PlLeft[1]:=3; PlLeft[2]:=111; PlLeft[3]:=219; PlLeft[4]:=24; PlLeft[5]:=200;
                            PlTop[1]:=13; PlTop[2]:=13; PlTop[3]:=13; PlTop[4]:=107; PlTop[5]:=107;
                            Cx:=130; Cy:=141; Cx2:=60; Cy2:=25; Cz:=2; end
  else if Players=6 then begin PlLeft[1]:=3; PlLeft[2]:=111; PlLeft[3]:=219;
                            PlTop[1]:=13; PlTop[2]:=13; PlTop[3]:=13;
                            PlLeft[4]:=3; PlLeft[5]:=111; PlLeft[6]:=219;
                            PlTop[4]:=107; PlTop[5]:=107; PlTop[6]:=107;
                            Cx:=140; Cy:=188; Cx2:=40; Cy2:=12; Cz:=1; end;

  for P:=1 to Players do begin
    Tog[P]:=3;
    PX[P]:=Map.XEntrance; PY[P]:=Map.YEntrance;
    Alive[P]:=0;
    SmDir[P]:=0; ScDir[P]:=0;
    SmMove[P]:=0; ScMove[P]:=0;
    FirstPlot(P,BackGr,Players);
    CentreText(PlLeft[p]+48,PlTop[p]-13,Names[P]);
    Speed[P]:=1; Food[p]:=0; TLeft[p]:=0;
  end;
  t2_block(Cx,Cy,Cx2,Cy2,0);
  str(Time,st);
  if Cz=1 then CentreText(Cx+(CX2 div 2),Cy,st);
  if Cz<>1 then TimerText(Cx+(Cx2 div 2),Cy,st);

  repeat
    for P:=1 to Players do begin
      if (SmDir[P]=0) and (ScDir[P]=0) and (Alive[P]=0) then begin
        if (TK_KP[GameKeys[Players,P,1]]) and (((Map.Data[Px[P]-1,Py[P],P]<>1) and (GType<=2)) or
               (((Map.Data[Px[P]-1,Py[P],P]=0) or (Map.Data[Px[P]-1,Py[P],P]=4))and (Gtype=3))) then
        begin
          if (Px[P]<Sx[P]+7) and (Sx[P]>0) then begin
            ScDir[P]:=1;
            ScMove[P]:=0;
            PrepareLeft(P,BackGr);
          end else begin
            SmDir[P]:=1;
            SmMove[P]:=0;
          end;
        end else if TK_KP[GameKeys[Players,P,2]] and (((Map.Data[Px[P]+1,Py[P],P]<>1) and (GType<=2)) or
            (((Map.Data[Px[P]+1,Py[P],P]=0) or (Map.Data[Px[P]+1,Py[P],P]=4)) and (Gtype=3))) then
        begin
          if (Px[P]>Sx[P]+5) and (Sx[P]<XSize-10) then begin
            ScDir[P]:=2;
            ScMove[P]:=0;
            PrepareRight(P,BackGr);
          end else begin
            SmDir[P]:=2;
            SmMove[P]:=0;
          end;
        end else if TK_KP[GameKeys[Players,P,3]] {Up} and (((Map.Data[Px[P],Py[P]-1,P]<>1) and (GType<=2)) or
            (((Map.Data[Px[P],Py[P]-1,P]=0) or (Map.Data[Px[P],Py[P]-1,P]=4))and (Gtype=3))) then
        begin
          if (Py[P]<Sy[P]+5) and (Sy[P]>1) then begin
            ScDir[P]:=3;
            ScMove[P]:=0;
            PrepareUp(P,BackGr);
          end else begin
            SmDir[P]:=3;
            SmMove[P]:=0;
          end;
        end else if TK_KP[GameKeys[Players,P,4]] {Down} and (((Map.Data[Px[P],Py[P]+1,P]<>1) and (GType<=2)) or
            (((Map.Data[Px[P],Py[P]+1,P]=0) or (Map.Data[Px[P],Py[P]+1,P]=4)) and (Gtype=3))) then
        begin
          if (Py[P]>Sy[P]+3) and (Sy[P]<YSize-8) then begin
            ScDir[P]:=4;
            ScMove[P]:=0;
            PrepareDown(P,BackGr);
          end else begin
            SmDir[P]:=4;
            SmMove[P]:=0;
          end;
        end else if (Px[P]=Map.XExit) and (Py[P]=Map.YExit) then begin
          inc(Escapes);
          TLeft[P]:=Time;
          Alive[P]:=2;
          t2_block(PlLeft[P],PlTop[P],96,80,0);
          for i:=0 to 11 do begin
            t2_putpic(PlLeft[P]+(i*8),PlTop[P],Smudges[Smudge[GPLayers,P],1]);
            t2_putpic(PlLeft[P]+(i*8),PlTop[P]+72,Smudges[Smudge[GPLayers,P],1]);
          end;
          for i:=0 to 2 do begin
            t2_putpic(PlLeft[P],PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],1]);
            t2_putpic(PlLeft[P]+88,PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],3]);
          end;
          for i:=7 to 9 do begin
            t2_putpic(PlLeft[P],PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],2]);
            t2_putpic(PlLeft[P]+88,PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],4]);
          end;
          r:=trunc(random(100)/5);

          if r=0 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'YOU');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'ESCAPED'); end
          else if r=1 then CentreText(PlLeft[P]+48,PlTop[P]+30,'AWESOME')
          else if r=2 then CentreText(PlLeft[P]+48,PlTop[P]+30,'AMAZING')
          else if r=3 then CentreText(PlLeft[P]+48,PlTop[P]+30,'FREEDOM')
          else if r=4 then CentreText(PlLeft[P]+48,PlTop[P]+30,'INCREDIBLE')
          else if r=5 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'ABOVE');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'AVERAGE'); end
          else if r=6 then CentreText(PlLeft[P]+48,PlTop[P]+30,'FANTASTIC')
          else if r=7 then CentreText(PlLeft[P]+48,PlTop[P]+30,'INSPIRING')
          else if r=8 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'POETRY IN');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'MOTION'); end
          else if r=9 then CentreText(PlLeft[P]+48,PlTop[P]+30,'SPARKLING')
          else if r=10 then CentreText(PlLeft[P]+48,PlTop[P]+30,'DAZZLING')
          else if r=11 then CentreText(PlLeft[P]+48,PlTop[P]+30,'EXCELLENT')
          else if r=12 then CentreText(PlLeft[P]+48,PlTop[P]+30,'MAGNIFICENT')
          else if r=13 then CentreText(PlLeft[P]+48,PlTop[P]+30,'IMPRESSIVE')
          else if r=14 then CentreText(PlLeft[P]+48,PlTop[P]+30,'BRILLIANT')
          else if r=15 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'GOOD');
                             CentreText(PlLeft[P]+48,PlTop[P]+38,'WORK'); end
          else if r=16 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'PRIZE');
                             CentreText(PlLeft[P]+48,PlTop[P]+38,'WINNER'); end
          else if r=17 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'SMOOTH');
                             CentreText(PlLeft[P]+48,PlTop[P]+38,'MOVER'); end
          else if r=18 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'NICELY');
                             CentreText(PlLeft[P]+48,PlTop[P]+38,'DONE'); end
          else if r=19 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'GOOD');
                             CentreText(PlLeft[P]+48,PlTop[P]+38,'JOB'); end;
        end;

        if TK_KP[GameKeys[Players,P,5]] {Eat Yourself} then begin
          Alive[P]:=1; TLeft[P]:=0;
          t2_block(PlLeft[P],PlTop[P],96,80,0);
          r:=trunc(random(100)/5);
          for i:=0 to 11 do begin
            t2_putpic(PlLeft[P]+(i*8),PlTop[P],Smudges[Smudge[GPLayers,P],1]);
            t2_putpic(PlLeft[P]+(i*8),PlTop[P]+72,Smudges[Smudge[GPLayers,P],1]);
          end;
          for i:=0 to 2 do begin
            t2_putpic(PlLeft[P],PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],1]);
            t2_putpic(PlLeft[P]+88,PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],3]);
          end;
          for i:=7 to 9 do begin
            t2_putpic(PlLeft[P],PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],2]);
            t2_putpic(PlLeft[P]+88,PlTop[P]+(i*8),Smudges[Smudge[GPLayers,P],4]);
          end;
          if r=0 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'COMPETENCE');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'VICTIM'); end
          else if r=1 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'EX');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'SMUDGE'); end
          else if r=2 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'SNUFFED');
                              CentreText(PlLeft[P]+48,PlTop[P]+38,'IT'); end
          else if r=3 then CentreText(PlLeft[P]+48,PlTop[P]+30,'PATHETIC')
          else if r=4 then CentreText(PlLeft[P]+48,PlTop[P]+30,'LOSER')
          else if r=5 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'NICE');
                              CentreText(PlLeft[P]+48,PlTop[P]+38,'TRY'); end
          else if r=6 then CentreText(PlLeft[P]+48,PlTop[P]+30,'DEAD')
          else if r=7 then CentreText(PlLeft[P]+48,PlTop[P]+30,'STARVED')
          else if r=8 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'OH');
                              CentreText(PlLeft[P]+48,PlTop[P]+38,'DEAR'); end
          else if r=9 then CentreText(PlLeft[P]+48,PlTop[P]+30,'OOPS')
          else if r=10 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'NO');
                               CentreText(PlLeft[P]+48,PlTop[P]+38,'HOPER'); end
          else if r=11 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'TOTAL');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'PANTS'); end
          else if r=12 then CentreText(PlLeft[P]+48,PlTop[P]+30,'DREADFUL')
          else if r=13 then CentreText(PlLeft[P]+48,PlTop[P]+30,'SHOCKING')
          else if r=14 then CentreText(PlLeft[P]+48,PlTOp[P]+30,'PANTS')
          else if r=15 then begin CentreTexT(PlLeft[P]+48,PlTop[P]+25,'BRAIN');
                            CentreText(PlLeft[P]+48,PlTop[P]+38,'DEAD'); end
          else if r=16 then CentreText(PlLeft[P]+48,PlTop[P]+30,'EXPIRED')
          else if r=17 then CentreText(PlLeft[P]+48,PlTop[P]+30,'DIGESTED')
          else if r=18 then begin CentreText(PlLeft[P]+48,PlTop[P]+25,'POOR');
                               CentreText(PlLeft[P]+48,PlTop[P]+38,'SHOW'); end
          else if r=19 then CentreText(PlLeft[P]+48,PlTop[P]+30,'IMBECILE');
          inc(Deaths);
        end;
      end;

      gettime(hr,m,sec,h);
      if (sec<>oldsec) then begin
        dec(Time);
        OldSec:=sec;
        t2_block(Cx,Cy,Cx2,Cy2,0);
        str(Time,st);
        if Cz=1 then CentreText(Cx+(CX2 div 2),Cy,st);
        if Cz<>1 then TimerText(Cx+(Cx2 div 2),Cy,st);
      end;
      if ((ScDir[P]>0) or (SmDir[P]>0)) and (Alive[P]=0) then begin
        if (ScDir[P]>0) then begin
          inc(ScMove[P],Speed[P]);
          if ScDir[P]=1 then ScrollRight(P,Speed[P],ScMove[P],BackGr,Players);
          if ScDir[P]=2 then ScrollLeft(P,Speed[P],ScMove[P],BackGr,Players);
          if ScDir[P]=3 then ScrollDown(P,Speed[P],ScMove[P],BackGr,Players);
          if ScDir[P]=4 then ScrollUp(P,Speed[P],ScMove[P],BackGr,Players);
          if ScMove[P]>=8 then begin
            if ScDir[P]=1 then begin dec(Px[P]); dec(Sx[P]); end;
            if ScDir[P]=2 then begin inc(Px[P]); inc(Sx[P]); end;
            if ScDir[P]=3 then begin dec(Py[P]); dec(Sy[P]); end;
            if ScDir[P]=4 then begin inc(Py[P]); inc(Sy[P]); end;
            ScDir[P]:=0;
            ScMove[P]:=0;
            if Map.Data[Px[P],Py[P],P]<>2 then inc(Food[P]);
            Map.Data[Px[P],Py[P],P]:=2;
          end;
        end;
        if (SmDir[P]>0) then begin
          inc(SmMove[P],Speed[P]);
          if SmDir[P]=1 then SmudgeLeft(P,SmMove[P],BackGr,Players);
          if SmDir[P]=2 then SmudgeRight(P,SmMove[P],BackGr,Players);
          if SmDir[P]=3 then SmudgeUp(P,SmMove[P],BackGr,Players);
          if SmDir[P]=4 then SmudgeDown(P,SmMove[P],BackGr,Players);
          if SmMove[P]>=8 then begin
            if SmDir[P]=1 then dec(Px[P]);
            if SmDir[P]=2 then inc(Px[P]);
            if SmDir[P]=3 then dec(Py[P]);
            if SmDir[P]=4 then inc(Py[P]);
            if Map.Data[Px[P],Py[P],P]<>2 then inc(Food[P]);
            Map.Data[Px[P],Py[P],P]:=2;
            if Py[P]<1 then Py[P]:=1;
            if Py[P]>YSize then Py[P]:=YSize;
            SmDir[P]:=0;
            SmMove[P]:=0;
          end;
        end;
      end;
    end;
    dsmpoll;
    t2_vretrace;
  until tk_kp[1] or (Deaths+Escapes=GPlayers) or (Time=0);

  if Music^.OrderPosition<$15 then begin
    Music^.OrderPosition:=$15;
    Music^.PatternRow:=0;
    Music^.BreakFlag:=PB_Jump;
  end;

  t2_block(0,0,320,200,0);
  CentreText(90,0,'SMUDGELET'); CentreText(90,13,'NAME');
  CentreText(185,0,'LICE'); CentreText(185,13,'EATEN');
  CentreText(274,0,'SPARE'); CentreText(274,13,'SECONDS');
  if GPlayers=6 then begin t2_line(0,198,319,198,219); t2_line(0,199,319,199,220); end;
  if GPlayers>=5 then begin t2_line(0,171,319,170,219); t2_line(0,172,319,171,220); end;
  if GPlayers>=4 then begin t2_line(0,143,319,143,219); t2_line(0,144,319,144,220); end;
  if GPlayers>=3 then begin t2_line(0,115,319,115,219); t2_line(0,116,319,116,220); end;
  if GPlayers>=2 then begin t2_line(0,87,319,87,219); t2_line(0,88,319,88,220); end;
  t2_line(0,59,319,59,219); t2_line(0,60,319,60,220);
  t2_line(40,0,40,60+((GPlayers-1)*28),239); t2_line(41,0,41,60+((GPlayers-1)*28),240);
  t2_line(230,0,230,60+((GPlayers-1)*28),239); t2_line(231,0,231,60+((GPlayers-1)*28),240);
  t2_line(318,0,318,60+((GPlayers-1)*28),239); t2_line(319,0,319,60+((GPlayers-1)*28),240);
  t2_line(0,27,319,27,219); t2_line(0,28,319,28,220);
  t2_line(140,0,140,60+((GPlayers-1)*28),239); t2_line(141,0,141,60+((GPlayers-1)*28),240);

  for i:=1 to GPlayers do begin
    Gone[i]:=false;
  end;
  if GType=2 then {DEVOUR - Order first in terms of food!}
  for i:=1 to GPlayers do begin
    max:=0;
    for j:=1 to GPlayers do
      if (max=0) and (not Gone[j]) then max:=j;
    for j:=1 to GPlayers do
      if (((Food[j]>Food[max]) and ((TLeft[j]>0) or (TLeft[max]=0)) or
        ((Food[j]=Food[max]) and (TLeft[j]>=TLeft[max]))) and (not Gone[j])) then max:=j;
    Order[i]:=max;
    Gone[max]:=true;
  end;
  if GType<>2 then {PANIC - Speed through the maze!} {And Ultimate}
  for i:=1 to GPlayers do begin
    max:=0;
    for j:=1 to GPlayers do
      if (max=0) and (not Gone[j]) then max:=j;
    for j:=1 to GPlayers do
      if ((TLeft[j]>TLeft[max]) or ((TLeft[j]=TLeft[max]) and (Food[j]>=Food[max]))) and (not Gone[j]) then max:=j;
    Order[i]:=max;
    Gone[max]:=true;
  end;
  for i:=1 to GPlayers do begin
    str(i,st);
    TimerText(20,5+(28*i),st);
    CentreText(90,10+(28*i),Names[Order[i]]);
    str(Food[Order[i]],st);
    CentreText(185,10+(28*i),st);
    str(TLeft[Order[i]],st);
    if TLeft[Order[i]]>0 then CentreText(274,10+(28*i),st);
    if TLeft[Order[i]]=0 then CentreText(274,10+(28*i),'LOST');
  end;
  if not tk_kp[1] then begin
    repeat
      if tk_keypressed then repeat until tk_readkey<>0;
      dsmpoll;
      t2_vretrace;
    until not tk_keypressed;
  end;
  repeat
    dsmpoll;
    t2_vretrace;
  until tk_keypressed;
  CloseAud;
  UnloadGameGfx;
end;

begin
  repeat
    LoadDefaults;
    InitAud;
    InitVid;
    TitlePage;
    if RunMe then Game(GPlayers);
    repeat
      if tk_keypressed then repeat until tk_readkey<>0;
    until not tk_keypressed;
    CloseVid;
  until false;
end.
