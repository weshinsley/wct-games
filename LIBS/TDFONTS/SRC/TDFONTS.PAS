Unit TDfonts;
{  ********************************************************************
   *********************** TDFONTS Version 2.0 ************************
   ********************************************************************
   **  Allows you to compile a program that uses the Turbo Pascal    **
   **  GRAPH unit, and include all the graphics driver files in the  **
   **  compiled program.                                             **
   **  This means that your program will not require the file        **
   **  EGAVGA.BGI or any *.CHR files                                 **
   **                                                                **
   **  Version 2 enhancements:
   **  You can now define which fonts you wish to use, thus saving   **
   **  on program size. To include all the fonts would add 135k to   **
   **  your program size.                                            **
   ********************************************************************
   **     (C) Tom Doel, WCT Software, July 1995, September 1996      **
   ********************************************************************
            Please see TDFONTS.TXT for important information!

   TDFONTS is designed for use with EGA and VGA graphics modes only.

   To use TDFONTS, put TDFONTS in the USES clause of your program.
   Then, at the start of the program, you must define which fonts
   you want to use.

 *  If you want all 10 fonts, simply put TDFinit as the first command
    in your program. That's it!

 *  If you want only some of the fonts, you must put several commands
    at the beginning of your program:

    EGAVGA           This includes the EGA/VGA graphics driver. You must
                     include this command.

    FONT1..FONT10    Turbo Pascal fonts are numbered from 1 to 10.
                     To include a font, put the FONTx command at the
                     beginning of your program, after the EGAVGA command,
                     where x is the number of the font you want,
                     numbered from 1 to 10.
                     Eg, if you want to use fonts 3, 6, and 10,
                     your program would start:

                          Begin
                            EGAVGA;
                            FONT3;
                            FONT6;
                            FONT10;
                            {Now the rest of the program
                          End;

   NB. Font 0 (DefaultFont) does not have to be declared.
}

Interface
  Uses Graph,TDF_1,TDF_2,CRT;
  Var TDF_GD,TDF_GM: Integer;

Procedure TDFinit;

Procedure EgaVga;
Procedure Font1;
Procedure Font2;
Procedure Font3;
Procedure Font4;
Procedure Font5;
Procedure Font6;
Procedure Font7;
Procedure Font8;
Procedure Font9;
Procedure Font10;

Procedure InitVGA( ModeNumber: Integer);



Implementation

Procedure EgaVgaDriverProc; external;
{$L EGAVGA.OBJ }

Procedure TDFerror;
  Var CH: Char;
  Begin
    TextMode(CO80);
    Writeln('TDFONTS error:');
    Writeln(GraphErrorMsg(GraphResult));
    While keypressed do ch:=readkey;
    Repeat until keypressed;
    Halt(1);
  End;

Procedure TDFinit;
begin

  if RegisterBGIdriver(@EGAVGADriverProc) < 0 then TDFerror;

  if RegisterBGIfont(@TriplexFontProc)    < 0 then TDFerror;
  if RegisterBGIfont(@SmallFontProc)      < 0 then TDFerror;
  if RegisterBGIfont(@SansSerifFontProc)  < 0 then TDFerror;
  if RegisterBGIfont(@GothicFontProc)     < 0 then TDFerror;

  if RegisterBGIfont(@ScriFontProc)       < 0 then TDFerror;
  if RegisterBGIfont(@SimpFontProc)       < 0 then TDFerror;
  if RegisterBGIfont(@TscrFontProc)       < 0 then TDFerror;
  if RegisterBGIfont(@LcomFontProc)       < 0 then TDFerror;

  if RegisterBGIfont(@EuroFontProc)       < 0 then TDFerror;
  if RegisterBGIfont(@BoldFontProc)       < 0 then TDFerror;

end;


Procedure EgaVga; Begin
    if RegisterBGIdriver(@EGAVGADriverProc) < 0 then TDFerror; End;

Procedure Font1;  Begin
    if RegisterBGIfont(@TriplexFontProc)    < 0 then TDFerror; End;

Procedure Font2;  Begin
    if RegisterBGIfont(@SmallFontProc)      < 0 then TDFerror; End;

Procedure Font3;  Begin
    if RegisterBGIfont(@SansSerifFontProc)  < 0 then TDFerror; End;

Procedure Font4;  Begin
    if RegisterBGIfont(@GothicFontProc)     < 0 then TDFerror; End;

Procedure Font5;  Begin
    if RegisterBGIfont(@ScriFontProc)       < 0 then TDFerror; End;

Procedure Font6;  Begin
    if RegisterBGIfont(@SimpFontProc)       < 0 then TDFerror; End;

Procedure Font7;  Begin
    if RegisterBGIfont(@TscrFontProc)       < 0 then TDFerror; End;

Procedure Font8;  Begin
    if RegisterBGIfont(@LcomFontProc)       < 0 then TDFerror; End;

Procedure Font9;  Begin
    if RegisterBGIfont(@EuroFontProc)       < 0 then TDFerror; End;

Procedure Font10; Begin
    if RegisterBGIfont(@BoldFontProc)       < 0 then TDFerror; End;

Procedure InitVGA( ModeNumber: Integer);
  Begin
    TDF_GD:=VGA;
    TDF_GM:=ModeNumber;
    InitGraph(TDF_GD,TDF_GM,'');
    If GraphResult<>grOK then TDFerror;
  End;

end.
