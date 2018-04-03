Unit TDF_2;

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

procedure SimpFontProc;
procedure TscrFontProc;
procedure LcomFontProc;
procedure EuroFontProc;
procedure BoldFontProc;

implementation

procedure SimpFontProc; external;
{$L SIMP.OBJ}

procedure TscrFontProc; external;
{$L TSCR.OBJ }

procedure LcomFontProc; external;
{$L LCOM.OBJ }

procedure EuroFontProc; external;
{$L EURO.OBJ}

procedure BoldFontProc; external;
{$L BOLD.OBJ}

end.
