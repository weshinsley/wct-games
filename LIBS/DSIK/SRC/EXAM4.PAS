(*  exam4.pas - Digital Sound Interface Kit V1.01a example code

    Copyright 1993,94 Carlos Hasan
*)

program Example;
uses Crt,Sound,Load,TS;


var
  Card   : DSMCard;
  Module : PDSM;
  Sample : PDSMInst;
  Volume : Integer;
  TmrCnt : Word;
  Secs   : Word;

procedure MyTimer; far;
begin
  inc(TmrCnt);
  DSMPoll;
end;

begin
  if DSMLoadSetup(Card) then begin
    writeln('Please run SETUP.EXE to configure.');
    exit;
  end;
  if DSMInit(Card) then begin
    writeln('Error Initializing the Sound System.');
    exit;
  end;
  Module := DSMLoad('64MANIA.DSM',0);
  Sample := DSMLoadSample('DING.WAV',0);
  if (Module = nil) or (Sample = nil) then begin
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
  writeln('Playing music.');

  { Play music using channels 0,1,2 and sound effect in channel 3 }
  DSMSetupVoices(4,Module^.Song.MasterVolume);
  DSMPlayMusic(Module);

  TSInit;
  TSSetRate(100);
  TSSetRoutine(MyTimer);

  for Volume := 0 to 64 do begin
    DSMSetMusicVolume(Volume);
    Delay(5);
  end;

  Secs := 0;
  while not keypressed do begin
    { Play sample every second }
    if TmrCnt >= 100 then begin
      DSMPlaySample(3,Sample);
      dec(TmrCnt,100);
      inc(Secs);
      Write('Timer: ',(Secs div 60):2,':',(Secs mod 60):2,#13);
    end;
  end;

  for Volume := 64 downto 0 do begin
    DSMSetMusicVolume(Volume);
    Delay(5);
  end;

  DSMStopMusic;
  DSMFreeSample(Sample);
  DSMFree(Module);

  TSDone;
  TSRestoreTime;

  DSMDone;
end.
