Unit TD_KEY;

{Wes added the timer handler}

{Codes returned are normal scan codes, except as follows:
  100  Right CTRL    101  Keypad ENTER    102  Keypad /
  103  Right ALT     104  Grey Right      105  Grey Home
  106  Grey Up       107  Grey Page Up    108  Grey Left
  109  Grey End      110  Grey Down       111  Grey Page Down
  112  Grey Ins      113  Grey Del        114  Pause

    Note that with the Pause key, it will appear to have been
    released straight away, even if you hold onto it. To detect the
    use of PAUSE, set TK_KeyCount[114]:=0 and check it for a value
    greater than 0 }


Interface
  Uses
    Dos,CRT;
  Const
    TK_running: Boolean=False;
     KeyName : array[0..127] of string[4] =
     ('0','ESC','1','2','3','4','5','6','7','8','9','0','-','=','BK','TAB','Q','W','E','R','T',
      'Y','U','I','O','P','[',']','ENT','L-CT','A','S','D','F','G','H','J','K','L',';',
      '''','`','L-SH','#','Z','X','C','V','B','N','M',',','.','/','R-SH','N*','ALT',
      'SP','CPS','F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','N-L','S-L','N7',
      'N8','N9','N-','N4','N5','N6','N+','N1','N2','N3','N0','N.','87','88','\','F11','F12','89','90',
      'L-WI','R-WI','W-ME','94','95','96','97','98','99','R-CT','R-EN','N/','A-GR','RGT',
      'HME','UP','P-U','LFT','END','DWN','P-D','INS','DEL','114','115','116','117','118','119',
      '120','121','122','123','124','125','126','127');

  Var
    TK_KP: Array[0..127] of Boolean;
    TK_KeyCount: Array[0..127] of Byte;
    TK_Buffer: Array[0..255] of Byte;
    TK_BufInPos,TK_BufOutPos: Byte;


  Function TK_Keypressed: boolean;
  Function TK_ReadKey: byte;
  Procedure TK_Start;
  Procedure TK_End;


Implementation
  Var
    TK_WaitFlag: Byte;
    TK_OldInterrupt : Procedure;

{$F+,S-}
  Procedure TK_Interrupt; interrupt; {assembler;}
    Var
      keycode: Byte;
      onoff: Boolean;
    Begin
      Asm
        cli
        push ax
        xor ah,ah
        in al,60h
        mov keycode,al

        in al,$61
        or al,82h
        out $61,al
        and al,7fh
        out $61,al
        mov al,20h
        out 20h,al

        pop ax
        sti
      End;

      If Keycode=$E1 then TK_waitFlag:=2 else
      If Keycode=$E0 then TK_waitFlag:=1
        else begin

          onoff:=false;
          If Keycode>=$80 then
            begin
              dec(Keycode,$80);
              onoff:=true;
            end;

      if TK_waitFlag=3 then
        begin
          TK_WaitFlag:=0;
          If KeyCode=$45 then KeyCode:=114;
        End;

      if TK_waitFlag=2 then
        begin
          Tk_WaitFlag:=0;
          If KeyCode=$1D then TK_WaitFlag:=3;
        end;

      if TK_waitFlag=1 then
        begin
          TK_WaitFlag:=0;
          Case Keycode of
            $1d: KeyCode:=100;
            $1c: KeyCode:=101;
            $35: KeyCode:=102;
            $38: KeyCode:=103;
            $4d: KeyCode:=104;
            $47: KeyCode:=105;
            $48: KeyCode:=106;
            $49: KeyCode:=107;
            $4b: KeyCode:=108;
            $4f: KeyCode:=109;
            $50: KeyCode:=110;
            $51: KeyCode:=111;
            $52: KeyCode:=112;
            $53: KeyCode:=113;
          End;
        end;

      If TK_WaitFlag=0 then
        Begin
          If not onoff then
            begin
              TK_KP[keycode]:=True;
              If TK_KeyCount[keycode]<255 then Inc(TK_KeyCount[keycode]);
              TK_Buffer[TK_BufInPos]:=KeyCode;
              Inc(TK_BufInPos);
              if TK_BufInPos>255 then TK_BufInPos:=0;
              If TK_BufInPos=TK_BufOutPos then Inc(TK_BufOutPos);
              If TK_BufOutPos>255 then TK_BufOutPos:=0;

            end else
            begin
              TK_KP[keycode]:=False;
            end;
        End;
      End;
  End;
{$F-,S+}



  Function TK_Keypressed: boolean;
    Begin
      If TK_BufInPos=TK_BufOutPos then TK_Keypressed:=false
        else TK_Keypressed:=true;
    End;

  Function TK_ReadKey: byte;
    Begin
      Repeat until TK_Keypressed;
      TK_Readkey:=TK_Buffer[TK_BufOutPos];
      Inc(TK_BufOutPos);
      If TK_BufOutPos>255 then TK_BufOutPos:=0;
    End;

  Procedure TK_Start;
    Var
      tka: byte;
    Begin
      If TK_Running then
        Begin
          Sound(220);
          Delay(200);
          NoSound;
          Halt(1);
        End;

      TK_BufInPos:=0;
      TK_BufOutPos:=0;
      TK_Running:=True;
      TK_WaitFlag:=0;
      for tka:=0 to 255 do
        TK_Buffer[tka]:=0;


      for tka:=0 to 127 do
        Begin
          TK_KP[tka]:=False;
          TK_KeyCount[tka]:=0;
        End;

      GetIntVec($9,@TK_OldInterrupt);
      SetIntVec($9,Addr(TK_Interrupt));


    End;

  Procedure TK_End;
    Begin
      SetIntVec($9,@TK_OldInterrupt);

      mem[0:$417]:=0;
      mem[0:$418]:=0;
      TK_Running:=False;
    End;

End.