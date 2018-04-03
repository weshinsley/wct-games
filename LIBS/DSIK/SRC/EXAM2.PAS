(*  exam3.pas - Digital Sound Interface Kit V1.01a example code

    Copyright 1993,94 Carlos Hasan
*)

program Example3;
uses Crt,Sound,Load,TS;

const
  PeriodTable : array [1..12*4] of word =
    { C   C#  D   D#  E   F   F#  G   G#  A   A#  B }
    ( 856,808,762,720,678,640,604,570,538,508,480,453,
      428,404,381,360,339,320,302,285,269,254,240,226,
      214,202,190,180,170,160,151,143,135,127,120,113,
      107,101,95,90,85,80,75,71,67,63,60,56 );

  KeyTable : array [1..12*3] of char =
      'ZSXDCVGBHNJMQ2W3ER5T6Y7UI9O0P';

var
  Card   : DSMCard;
  Sample : PDSMInst;
  Key    : Char;
  Note   : Integer;
  Chan   : Integer;
begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Sample := DSMLoadSample('DING.WAV',0);
  if Sample = nil then begin
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
  DSMSetupVoices(9,128);

  TSInit;
  TSSetRate(70);
  TSSetRoutine(DSMPoll);

  writeln;
  writeln('     C# D#    F# G# A#    C# D#    F# G# A#    C# D#   ');
  writeln('  ³ ³ ³³ ³ ³ ³ ³³ ³³ ³ ³ ³ ³³ ³ ³ ³ ³³ ³³ ³ ³ ³ ³³ ³ ³ ');
  writeln('  ³ ³ ³³ ³ ³ ³ ³³ ³³ ³ ³ ³ ³³ ³ ³ ³ ³³ ³³ ³ ³ ³ ³³ ³ ³ ');
  writeln('  ³ ³S³³D³ ³ ³G³³H³³J³ ³ ³2³³3³ ³ ³5³³6³³7³ ³ ³9³³0³ ³ ');
  writeln('  ³ ÀÂÙÀÂÙ ³ ÀÂÙÀÂÙÀÂÙ ³ ÀÂÙÀÂÙ ³ ÀÂÙÀÂÙÀÂÙ ³ ÀÂÙÀÂÙ ³ ');
  writeln('  ³ Z³ X³ C³ V³ B³ N³ M³ Q³ W³ E³ R³ T³ Y³ U³ I³ O³ P³ ');
  writeln('  ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ ');
  writeln('    C  D  E  F  G  A  B  C  D  E  F  G  A  B  C  D  E  ');
  writeln;
  writeln('    Press keys to play the sample and ESC to exit.     ');

  Chan := 0;
  repeat
    Key := UpCase(ReadKey);
    for Note := 1 to 12*3 do
      if Key = KeyTable[Note] then begin
        { play chord C-E-G }
        DSMPlaySample(Chan,Sample);
        DSMPlaySample(Chan+1,Sample);
        DSMPlaySample(Chan+2,Sample);
        DSMSetPeriod(Chan,PeriodTable[Note]);
        DSMSetPeriod(Chan+1,PeriodTable[Note+4]);
        DSMSetPeriod(Chan+2,PeriodTable[Note+7]);
        Chan := (Chan+3) mod 9;
      end;
  until Key = #27;

  TSDone;
  TSRestoreTime;

  DSMFreeSample(Sample);
  DSMDone;
end.
