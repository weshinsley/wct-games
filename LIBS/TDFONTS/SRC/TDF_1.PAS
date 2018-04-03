Unit TDF_1;

{ To be used with the unit TDFONTS.PAS

  This unit allows you to compile a program with all the font files
  and the VGA/EGA graphics driver in one .EXE.
  Normally you would have to keep .CHR and  VGAEGA.BGI files in the
  startup directory for the program to work.
  To use, simply put TDfonts in the  USES clause and put TDFinit as
  the first command in the program.

  (C) WCT/Tom Doel   July 1995
  Based on Borland's BGILINK demo, supplied with Turbo Pascal 6
                                                                     }

interface
procedure TriplexFontProc;
procedure SmallFontProc;
procedure SansSerifFontProc;
procedure GothicFontProc;
procedure ScriFontProc;

implementation

procedure TriplexFontProc; external;
{$L TRIP.OBJ}

procedure SmallFontProc; external;
{$L LITT.OBJ }

procedure SansSerifFontProc; external;
{$L SANS.OBJ}

procedure GothicFontProc; external;
{$L GOTH.OBJ}

procedure ScriFontProc; external;
{$L SCRI.OBJ}



end.
