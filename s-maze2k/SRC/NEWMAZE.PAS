{$r-} { Increases speed a marginal amount }
unit NewMaze;

interface
  uses Crt,Sound;

  var xMax,yMax,SMax : integer;
      NoWalls : integer;
  type
    tMap = record
      Data : array[0..81, 0..61, 1..6] of byte;
      xEntrance, yEntrance : Byte;
      xExit, yExit : Byte;
    end;

    var Map : tMap;

    type tSeed = record
      x, y, Dir : Byte;
      Valid : Boolean;
    end;


  procedure Create(x,y : integer);

implementation

{ Generates the map }
procedure GenerateMap(var Map : tMap);
var Seeds : array[1..2270] of tSeed;

{ Reports TRUE if any seeds are "unsprouted" }
function NoSeeds : Boolean;
var i : Word;
    FoundSeeds : Boolean;
begin
  FoundSeeds := False;
  for i := 1 to sMax do begin
    if Seeds[i].Valid then FoundSeeds :=True;
  end;
  NoSeeds := not FoundSeeds;
end;

{ "Plant" a seed }
procedure AddSeed(x, y, Dir : Byte);
var i : Word;
begin
  i := 0;
  repeat
    Inc(i);
  until (i = sMax) or not Seeds[i].Valid;
  if Seeds[i].Valid then begin
    WriteLn('Error: Out of seed space!');
    Halt;
  end else begin
    Seeds[i].x := x;
    Seeds[i].y := y;
    Seeds[i].Dir := Dir;
    Seeds[i].Valid := True;
  end;
end;

{ "Sprout" a seed }
procedure Sprout;
var i : Word;
begin
  repeat
    i := Random(sMax) + 1;
  until Seeds[i].Valid;
  with Seeds[i] do begin
    case Dir of
      0: begin { up }
        if Map.Data[x, y - 2,1]=0 then
          begin
            AddSeed(x, y - 2, 1);
            AddSeed(x, y - 2, 2);
            AddSeed(x, y - 2, 3);
            Map.Data[x, y - 1, 1] := 1;
            Map.Data[x, y - 2, 1] := 1;
            inc(NoWalls,2);

          end;
        end;
      1: begin { down }
        if Map.Data[x, y + 2,1 ]=0 then
          begin
            AddSeed(x, y + 2, 0);
            AddSeed(x, y + 2, 2);
            AddSeed(x, y + 2, 3);
            Map.Data[x, y + 1, 1 ] := 1;
            Map.Data[x, y + 2, 1 ] := 1;
            inc(NoWalls,2);

          end;
        end;
      2: begin { left }
        if Map.Data[x - 2, y,1]=0 then
          begin
            AddSeed(x - 2, y, 0);
            AddSeed(x - 2, y, 1);
            AddSeed(x - 2, y, 3);
            Map.Data[x - 1, y,1] := 1;
            Map.Data[x - 2, y,1] := 1;
            inc(NoWalls,2);

          end;
        end;
      3: begin { right }
        if Map.Data[x + 2, y,1] = 0 then
          begin
            AddSeed(x + 2, y, 0);
            AddSeed(x + 2, y, 1);
            AddSeed(x + 2, y, 2);
            Map.Data[x + 1, y,1] := 1;
            Map.Data[x + 2, y,1] := 1;
            inc(NoWalls,2);

          end;
        end;
     end;
  end;
  Seeds[i].Valid := False;
end;

var x, y : Byte;
DrawCount : Byte;

begin
  FillChar(Map, SizeOf(Map), 0); { Zero out map }
  FillChar(Seeds, SizeOf(Seeds), 0); { Erase seeds }
                                   { Draw border }
  with Map do begin
    for x := 1 to xMax do begin
      Data[x,0,1] :=1;
      Data[x,yMax+1,1] :=1;
      Data[x, 1,1] := 1;
      Data[x, yMax,1] := 1;
    end;
    for y := 1 to yMax do begin
      Data[1, y,1] := 1;
      Data[xMax, y,1] := 1;
    end;
{ Map entrance }
    yEntrance := 1;
    xEntrance := (Random(yMax div 2) + 1)* 2;
    Data[xEntrance, yEntrance,1] := 0;
                                      { Map exit }
    yExit := yMax;
    xExit := (Random(yMax div 2) + 1) *2;
    Data[xExit, yExit,1] := 0;
{ Add a couple of seeds in the middle (islands) }
    AddSeed((Random(xMax div 2) + 1) * 2 + 1, (Random(yMax div 2) + 1) * 2 + 1,Random(4));
    AddSeed((Random(xMax div 2) + 1) * 2+ 1, (Random(yMax div 2) + 1) * 2 + 1,Random(4));
{ Add seeds around the edges, about every 4 units }
    for DrawCount := 1 to (2 * xMax + 2 * yMax) div 4 do begin
      case Random(4) of
        0: AddSeed((Random(xMax div 2) + 1) * 2 + 1, 1, 1); { top, going down }
        1: AddSeed((Random(xMax div 2) + 1) * 2 + 1, yMax, 0); { bottom, going up }
        2: AddSeed(1, (Random(yMax div 2) + 1) * 2 + 1, 3); { left, going right}
        3: AddSeed(xMax, (Random(yMax div 2) + 1) * 2 + 1, 2); { right, going left }
        end;
      end;
    end;
    DrawCount := 0;
    repeat
      Inc(DrawCount);
      if DrawCount = 100 then begin
        DrawCount := 0;
{        DrawMap(Map);}
      end;
      if KeyPressed then begin
      while KeyPressed do ReadKey;
{      DrawMap(Map);}
    end;
    dsmpoll;
    Sprout;
  until NoSeeds;
{  DrawMap(Map);}
end;

procedure Create(x,y : integer);
  var i,j,k : word;
      F : text;
begin
  repeat
    Randomize;
    NoWalls:=0;
    XMax:=x;
    YMax:=y;
    sMax := (xMax - 3) * (yMax - 3) div 2;
    GenerateMap(Map);
    dsmpoll;
  until NoWalls<(X*y);
  dsmpoll;
  for i:=2 to 6 do
    for j:=0 to 81 do
      for k:=0 to 61 do
        Map.Data[j,k,i]:=Map.Data[j,k,1];
  end;
end.