Unit TD_256;

{
   ********************************************************************
   ************************ TD-256 Version 2.0 ************************
   ********************************************************************
   **  Graphical interface for Turbo Pascal, tested on versions 6,7  **
   **         For VGA Graphics Card, using 256-colour mode 13h       **
   **                                                                **
   **          (C) September 1995, (C) August 1996 Tom Doel          **
   ********************************************************************
   ** Distributed by WCT Software for the Public Domain, +FREEWARE+  **
   **                                                                **
   ** THIS SOFTWARE CAN BE DISTRIBUTED FREELY, PROVIDED NO CHARGE IS **
   ** MADE AND THE PROGRAM IS NOT ALTERED IN ANY WAY.                **
   **                                                                **
   ** Changing English spellings in this program to American         **
   ** equivalents, eg. CENTRE to CENTER, is STRICTLY PROHIBITED.     **
   ********************************************************************
}

Interface

  Type
    T2_RGBS= Array[0..255,1..3] of byte;

    T2_Font_Header=
      Record
        TD2F_File: string[16];
        Font_version: Byte;
        Font_Name: String[15];
        Char_Height: Byte;
        Char_Width: Array[1..95] of Byte;
        Char_Pointers: Array[1..95] of word;
      End;

    PCX_Header=
      Record
        Manufacturer      : Byte;    { Always 10 for PCX files             }
        Version           : Byte;    { Always 5 for new PCX files          }
                                     { 0=redundant, 2=with palette         }
                                     { 3=no palette, 4=Windows, no palette }
        Encoding          : Byte;    { Always 1 for PCX                    }
        Bits_Per_Pixel    : Byte;    { Number of bits per pixel per plane  }
                                     { Can be 1,2,4 or 8                   }
                                     { 1 for 16-colour images, 8 for 256   }
        X_Min             : Integer; { Usually 0, X-coordinate             }
        Y_Min             : Integer; { Usually 0, Y-coordinate             }
        X_Max             : Integer; { Note this is relative to X_MIN      }
        Y_Max             : Integer; { Note this is relative to Y_MIN      }
        H_Resolution      : Integer; { Resolution in DPI, but usually      }
                                     { contains the width of the picture   }
        V_Resolution      : Integer; { Resolution in DPI, but usually      }
                                     { contains the height of the picture  }
        Colour_Palette    : Array[0..15,1..3] of Byte;
                                     { Colour palette for <=16 colours     }
        Reserved          : Byte;    { Reserved for video mode, set at 0   }
        Number_Planes     : Byte;    { The number of planes                }
        Bytes_Per_Line    : Integer; { Bytes per line per plane            }
        Palette_Type      : Integer; { Normally 1 for black and white or   }
                                     { colour, 2 for greyscale images      }
        H_screen          : Integer; { Horizontal screen resolution        }
                                     { Not used in many PCX files          }
        V_Screen          : Integer; { Vertical screen resolution          }
                                     { Not used in many PCX files          }
        Reserved_Block    : Array[74..127] of Byte;
      End;


  Const
    T2_Version                    ='TD-256 (C) Tom Doel Version 2.0 (C) 8/1996';
    T2_Style: Array[1..4] of Byte = (0,0,0,0);
    T2_Pic  : Array[1..3] of Byte = (0,0,0);
    T2_Running         : Boolean  = False;
    T2_Maximum_Buffers            = 6;
    T2_FontNum: Byte              = 1;
    Text_Left                     = 0;
    Text_Right                    = 1;
    Text_Centre                   = 2;
    Text_Top                      = 0;
    Text_Bottom                   = 1;
    Text_Italic                   = 2;
    Text_Slant                    = 1;
    Text_Normal                   = 0;
    Text_Bold                     = 1;
    T2_Stype: Byte=0;
    T2_Sratios: Array[1..4] of word=(1,1,1,1);
    T2_SSwid: Word=0;
    T2_SShei: Word=0;

  Var

    SPseg,SPofs,SPwid,SPhei,SSwid,SShei: Word;
    T2_RGB_Vals            : T2_RGBS;
    T2_Buffer_RGBS         : Array[0..5] of T2_RGBS;
    T2_Buffers             : Array[0..5] of Pointer;
    T2_Seg_Buf,T2_Ofs_Buf  : Array[0..5] of Word;
    T2_Fonts               : Array[1..10] of Pointer;
    T2_Font_Headers        : Array[1..10] of T2_Font_Header;
    p2                     : Pointer;
    a,b,c,d,gg,hh,tmp,tmp2 : Integer;

    T2_Old_Mode,T2_Num_Buffers,T2_Current_Buffer,charnum,wwid,coln,
    T2_RGB_Red,T2_RGB_Green,T2_RGB_Blue : Byte;

    T2_Bseg,T2_Bofs,pseg,pofs,posit,off,wdd,wdd2,hii,segg : Word;
    T_Seg,T_Ofs            : Word;
    T_A,T_B,T_C,T_D        : Integer;


  Procedure T2_Start(Number_Buffers: Byte);
  Procedure T2_End;
  Procedure T2_Vretrace;

  Procedure T2_Set_Buf(Buffer_Number: Byte);
  Procedure T2_Copy(Buf_Dest: Byte; y1,hei: Word);

  Procedure T2_Scroll(Hval,Vval: integer);
  Procedure T2_HW_Scroll(xv,yv: word);

  Procedure T2_SetRGB(Num,Rv,Gv,Bv: Byte);
  procedure T2_GetRGB(Num: byte; var Rv,Gv,Bv : byte);

  Procedure T2_Set_BlockRGB(NumStart: Byte;Totalnum: Word);
  Procedure T2_Get_BlockRGB(NumStart: Byte;Totalnum: Word);

  Procedure T2_Set_Font(Fntn: Byte);
  Procedure T2_Set_Style(bol,ital,justify,yjustify: Byte);
  Procedure T2_Write(xpos,ypos: integer; txt: string; col: Byte);
  function T2_WidthChar(Ch : char) : byte;


  Procedure T2_Load_Font(fname: String;Fontnum: byte);
  Procedure T2_User_Font(Var Font_Address: Pointer; Fontnum: byte);

  Procedure T2_Block(Xv,Yv,wid,ttt: Word; Cv: byte);
  Procedure T2_Band(y1,hei: Word; col: byte);

  Procedure T2_Dot(Xv,Yv:Word; Cv:Byte);
  Function  T2_GetDot(Xv,Yv:Word):Byte;

  Procedure T2_Line(x1,y1,x2,y2: word; col:byte);
  Procedure T2_Horiz_Line(Xv,Yv,wid: Word; Cv: byte);
  Procedure T2_Vert_Line(Xv,Yv,Hei:Word; Cv:Byte);

  Procedure T2_PutPic(Xv,Yv: Integer; Pp: Pointer);
  Procedure T2_GetPic(Xv,Yv,Wdd,hii: Integer; Pp: Pointer);
  Procedure T2_PutBakPic(Xv,Yv: Integer; Pp: Pointer);
  Procedure T2_PutBakGetPic(Xv,Yv: Integer; Pp: Pointer);
  Procedure T2_ReplacePic(Xv,Yv: Integer; Pp: Pointer);

  Procedure T2_Set_Pic(BakCol,justify,yjustify: Byte);
  Procedure T2_Set_Scale_Size(wid,hei: word);
  Procedure T2_Set_Scale_Ratio(x1,x2,y1,y2: Word);
  Procedure T2_Scale_Pic(xv,yv: Word; pp: pointer);

  Function  T2_GetPicSize(Xv1,Xv2,Yv1,Yv2: word): word;
  Function  T2_GetWidth(Pp: Pointer): word;
  Function  T2_GetHeight(Pp: Pointer): word;



Implementation

  Procedure CLI; inline($FA);
  Procedure STI; inline($FB);

  Procedure T2_Start(Number_Buffers: Byte);
    Begin
      T2_Running:=true;

      If Number_Buffers>T2_Maximum_Buffers
        then Number_Buffers:=T2_Maximum_Buffers;
      T2_Num_Buffers:=Number_Buffers;

      T2_Buffers[0]:=Ptr($a000,$0000);
      T2_Seg_Buf[0]:=Seg(T2_Buffers[0]^);
      T2_Ofs_Buf[0]:=Ofs(T2_Buffers[0]^);

      T2_Current_Buffer:=0;
      T2_Bseg:=T2_Seg_Buf[T2_Current_Buffer];
      T2_Bofs:=T2_Ofs_Buf[T2_Current_Buffer];

      If Number_Buffers>0 then begin
        For T_A:=1 to Number_Buffers Do Begin
          Getmem(T2_Buffers[T_A],65520);
          T2_Seg_Buf[T_A]:=seg(T2_Buffers[T_A]^);
          T2_Ofs_Buf[T_A]:=ofs(T2_Buffers[T_A]^);
        End;
      End;


      Asm
        mov ah,$0f
        int $10
        mov T2_Old_Mode,al
        mov ah,$00
        mov al,$13
        int $10
      End;

  End;


  Procedure T2_End;
    Begin
      For T_A:=1 to T2_Num_Buffers do freemem(T2_Buffers[T_A],65520);
      Asm
        mov ah,$00
        mov al,T2_Old_Mode
        int $10
      End;
    End;

Procedure T2_vretrace; assembler;
  asm
   @@loop1:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    jz      @@loop3  {Not in retrace}

   @@loop2:
    mov     dx,$3da  {Retrace already started- wait for next}
    in      ax,dx
    and     ax,8
    jnz     @@loop2

   @@loop3:          {Wait until retrace}
    mov     dx,$3da
    in      ax,dx
    and     ax,8

    jz      @@loop3
  end;

  Procedure T2_Set_Buf(Buffer_Number: Byte);
    Begin
      T2_Current_Buffer:=Buffer_Number;
      T2_Bseg:=T2_Seg_Buf[T2_Current_Buffer];
      T2_Bofs:=T2_Ofs_Buf[T2_Current_Buffer];
    End;

Procedure T2_Copy(Buf_Dest: Byte; y1,hei: Word); {assembler;}
begin
     T_Seg:=T2_seg_buf[Buf_Dest];
     T_Ofs:=T2_ofs_buf[Buf_Dest];
asm
   push ds

   mov ax,Y1
   mov bx,ax
   shl ax,8
   shl bx,6
   add ax,bx

   mov di,T_Ofs
   add di,ax
   mov es,T_Seg
   mov si,T2_Bofs
   add si,ax

   mov ax,Hei
   mov bx,ax
   shl ax,8
   shl bx,6
   add ax,bx
   shr ax,1

   mov cx,ax
   mov ds,T2_Bseg
   cld
   rep movsw
   pop ds
end;
end;

{Procedure T2_Fast_Pcx(Buffer: Pointer;
begin
  ad1:=seg(p^); ad2:=ofs(p^);
  ad3:=$a000; ad4:=00;
  asm
    push ds
    mov bx,64000;

    mov di,ad4
    mov es,ad3
    mov si,ad2
    mov ds,ad1
    xor ch,ch

@@loop1:
    lodsb
    cmp al,192
    jae @@repbytes

    stosb
    dec bx
    jnz @@loop1


    jmp @@end

@@repbytes:
    and al,63
    mov cl,al
    sub bx,cx
    lodsb
    cld
    rep stosb

    or bx,bx
    jnz @@loop1

@@end:
    pop ds

  end;
end;
}



  Procedure T2_Band(y1,hei: Word; col: byte); assembler;
    Asm
      mov ax,Y1
      mov bx,ax
      shl ax,8
      shl bx,6
      add ax,bx

      mov di,T2_Bofs
      add di,ax

      mov ax,Hei
      mov bx,ax
      shl ax,8
      shl bx,6
      add ax,bx
      shr ax,1

      mov cx,ax
      mov ah,col
      mov al,ah

      mov es,T2_Bseg
      cld
      rep stosw
   end;


  Procedure T2_SetRGB(Num,Rv,Gv,Bv: byte); Assembler;
    Asm
      mov dx,$3c8
      mov al,num
      out dx,al
      mov dx,$3c9
      mov al,Rv
      out dx,al
      mov al,Gv
      out dx,al
      mov al,Bv
      out dx,al
    End;


  Procedure T2_Set_BlockRGB(NumStart: Byte;Totalnum: Word);
    Begin
      T_Seg:=Seg(T2_RGB_Vals[NumStart]);
      T_Ofs:=Ofs(T2_RGB_Vals[NumStart]);
      If (TotalNum>0) and (NumStart+TotalNum<=256) then
      Asm
        push ds

        mov dx,$3C8
        mov al,NumStart
        out dx,al

        mov dx,$3c9
        mov ax,TotalNum
        mov cx,ax
        add cx,ax
        add cx,ax

        mov si,T_Ofs
        mov ds,T_seg

        @@RepLoop:
          lodsb
          out dx,al

        loop @@RepLoop

        pop ds
      End;

    End;

  Procedure T2_Get_BlockRGB(NumStart: Byte;Totalnum: Word);
    Begin
      T_Seg:=Seg(T2_RGB_Vals[NumStart]);
      T_Ofs:=Ofs(T2_RGB_Vals[NumStart]);
      If (TotalNum>0) and (NumStart+TotalNum<=256) then
      Asm
        mov dx,$3C7
        mov al,NumStart
        out dx,al

        mov dx,$3c9
        mov ax,TotalNum
        mov cx,ax
        add cx,ax
        add cx,ax

        mov di,T_Ofs
        mov es,T_Seg

        @@RepLoop:
          in al,dx
          stosb

        loop @@RepLoop

      End;
    End;

  procedure T2_GetRGB2(Num: byte);
  assembler;
    Asm
      mov dx,$3c7
      mov al,Num
      out dx,al

      mov dx,$3c9
      in al,dx
      mov t2_rgb_red,al
      jmp @@l1

    @@l1:
      in al,dx
      mov t2_rgb_green,al
      jmp @@l2

    @@l2:
      in al,dx
      mov t2_rgb_blue,al
   End;

procedure t2_getrgb(Num: byte; var Rv,Gv,Bv : byte);
  begin
    t2_Getrgb2(Num);
    Rv:=t2_rgb_red;
    Gv:=t2_rgb_green;
    bv:=t2_rgb_blue;
  end;

Procedure T2_Load_Font(fname: String;Fontnum: byte);
  var f:file;
begin
  if (fontnum>0) and (fontnum<11) then begin
    Assign(f,fname);
    reset(f,1);
    Getmem(T2_Fonts[Fontnum],filesize(f)-sizeof(t2_font_header));
    BlockRead(f,Addr(T2_Font_Headers[Fontnum])^,sizeof(T2_Font_Header));
    BlockRead(f,T2_Fonts[Fontnum]^,filesize(f)-sizeof(T2_font_header));
    Close(f);
  end;
end;

Procedure T2_User_Font(Var Font_Address: Pointer; Fontnum: byte);
begin
  if (fontnum>0) and (fontnum<11) then begin
    Move(Font_Address^,T2_Font_Headers[Fontnum],sizeof(T2_Font_Header));
    T2_Fonts[Fontnum]:=Ptr(Seg(Font_Address^),ofs(Font_Address^)
      +Sizeof(T2_Font_Header));

{    Getmem(T2_Fonts[Fontnum],filesize(f)-sizeof(font_header));
    BlockRead(f,Addr(T2_Font_Headers[Fontnum])^,sizeof(Font_Header));
    BlockRead(f,T2_Fonts[Fontnum]^,filesize(f)-sizeof(font_header));
    Close(f);}
  end;
end;

Procedure T2_Set_Font(Fntn: Byte);
begin
  If (fntn>0) and (fntn<11) then
    T2_FontNum:=fntn;
end;


function T2_WidthChar(Ch : char) : byte;
  var charnum : byte;
begin
  charnum:=ord(ch)-32;
  if (charnum>=1) and (charnum<=95) then begin
    T2_WidthChar:=T2_Font_Headers[T2_FontNum].char_width[charnum];
  end else begin T2_WidthChar:=0; end;
end;

Procedure T2_WriteChar(xp,yp: integer;bld,ital: byte);
 var
     power2: word;
     sseg,sofs: word;
     tta: word;
begin
  If yp<200 then begin

  sseg:=T2_Bseg; {sofs:=T2_Bofs;}
   {$R-}
  sofs:=yp;
  sofs:=round(T2_Bofs+(xp)+(sofs*320));
   {$R+}
  tta:=0;
  If ital>0 then Inc(sofs,round(T2_Font_Headers[T2_Fontnum].char_height/ital));
  if charnum=0 then wwid:=T2_Font_Headers[T2_FontNum].char_width[1] else begin

  posit:=T2_Font_Headers[T2_Fontnum].char_pointers[charnum];
  power2:=1;
  wwid:=T2_Font_Headers[T2_FontNum].char_width[charnum];
  a:=0; b:=0;


  d:=mem[pseg:pofs+posit];



  repeat

  repeat

  if ((d and power2)>0) {and (b+xp>=0) and (b+xp<320)}
   and (a+yp>=0)
   then begin
    asm
      mov es,sseg
      mov di,sofs
      mov al,coln
      mov ah,bld
      mov bx,b
      mov cx,power2

      push bx
      add bx,xp
      cmp bx,0
      jl  @@skip1
      cmp bx,320
      jge @@skip1

      mov [es:di],al

      or ah,ah
      jz @@skip1

      mov [es:di+1],al

    @@skip1:
     pop bx
{
     shl cx,1}

{     cmp ch,128
     jbe @@skip2
     mov ch,1}


   @@skip2:

     mov power2,cx
    end;
{    mem[sseg:sofs]:=coln;
    If bld>0 then mem[sseg:sofs+1]:=coln;}
    end;

  power2:=(power2 shl 1);
  if power2>128 then begin
    power2:=1; inc(posit);
    d:=mem[pseg:pofs+posit]; end;
  inc(b); inc(sofs);

    until (b>wwid);

    inc(a); b:=0; inc(sofs,319-wwid);
    If ital>0 then begin
      inc(tta);
      If tta>ital then begin
        Dec(sofs); tta:=0;
      end;
    end;

    until (a>=T2_Font_Headers[T2_Fontnum].char_height) or (a+yp>=200);


    end; end;
end;

Procedure OT2_WriteChar(xp,yp: integer;bld,ital: byte);
 var
     power2: word;
     sseg,sofs: word;
     tta: word;
begin
  If yp<200 then begin

  sseg:=T2_Bseg; {sofs:=T2_Bofs;}
   {$R-}
  sofs:=yp;
  sofs:=round(T2_Bofs+(xp)+(sofs*320));
   {$R+}
  tta:=0;
  If ital>0 then Inc(sofs,round(T2_Font_Headers[T2_Fontnum].char_height/ital));
  if charnum=0 then wwid:=T2_Font_Headers[T2_FontNum].char_width[1] else begin

  posit:=T2_Font_Headers[T2_Fontnum].char_pointers[charnum];
  power2:=1;
  wwid:=T2_Font_Headers[T2_FontNum].char_width[charnum];
  a:=0; b:=0;


  d:=mem[pseg:pofs+posit];



  repeat

  repeat

  if ((d and power2)>0) and (b+xp>=0) and (b+xp<320)
   and (a+yp>=0)
   then begin
    mem[sseg:sofs]:=coln;
    If bld>0 then mem[sseg:sofs+1]:=coln;
    end;

  power2:=(power2 shl 1);
  if power2>128 then begin
    power2:=1; inc(posit);
    d:=mem[pseg:pofs+posit]; end;
  inc(b); inc(sofs);

    until (b>wwid);

    inc(a); b:=0; inc(sofs,319-wwid);
    If ital>0 then begin
      inc(tta);
      If tta>ital then begin
        Dec(sofs); tta:=0;
      end;
    end;

    until (a>=T2_Font_Headers[T2_Fontnum].char_height) or (a+yp>=200);


    end; end;
end;

Procedure T2_Write(xpos,ypos: integer; txt: string; col: Byte);
begin
  coln:=col;
  pseg:=seg(T2_Fonts[T2_Fontnum]^);
  pofs:=ofs(T2_Fonts[T2_Fontnum]^);
  hh:=0;

  for gg:=1 to length(txt) do begin
    if (ord(txt[gg])<32) or (ord(txt[gg])>125) then txt[gg]:=' ';
    charnum:=ord(txt[gg])-32;
    inc(hh);
    If charnum=0 then Inc(hh,T2_Font_Headers[T2_FontNum].char_width[1])
      else
        Inc(hh,T2_Font_Headers[T2_Fontnum].char_width[charnum]);
    end;

  If (T2_style[3]=1) then dec(xpos,hh);
  If (T2_Style[3]=2) then dec(xpos,round(hh/2));

  hh:=T2_Font_Headers[T2_Fontnum].char_height;
  If (T2_Style[4]=1) then dec(ypos,hh);
  If (T2_Style[4]=2) then dec(ypos,round(hh/2));

  for gg:=1 to length(txt) do begin
    charnum:=ord(txt[gg])-32;

    T2_writechar(xpos,ypos,T2_Style[1],T2_Style[2]);
    inc(xpos,wwid+1);

    end;

end;

  Procedure T2_Set_Style(bol,ital,justify,yjustify: Byte);
    Begin
      T2_style[1]:=bol;
      T2_style[2]:=ital;
      T2_style[3]:=justify;
      T2_style[4]:=yjustify;
    End;

{Procedure T2_Write(Xc,Yc,Cv:Byte; Txt: String);
Var TS,OS: Word;
Begin
     Txt:=Txt+'$'; TS:=Seg(Txt); OS:=Ofs(Txt)+1;
     Asm
        push ds
        mov ah,$02
        mov bh,$00
        mov dl,Xc
        mov dh,Yc
        int $10

        mov ah,$09
        mov ds,TS
        mov dx,OS
        int $21
        pop ds
     End;
End;}

Procedure T2_Line(x1,y1,x2,y2: word; col:byte);
  var d2x,dy,mem_start,temp: word;
      temp1,temp2,y_inc: integer;
begin
  y_inc:=320;
  if (x2<x1) then begin
    temp:=x2; x2:=x1; x1:=temp;
    temp:=y2; y2:=y1; y1:=temp; end;

  mem_start:=(y1 shl 8)+(y1 shl 6) +x1+T2_Bofs;
  d2x:=x2-x1; temp1:=y1; temp2:=y2;

  dy:=abs(temp2-temp1); if temp1>temp2 then y_inc:=-320;

  if (d2x>dy) then begin

    if y_inc=320 then asm
       mov dx,dy
       mov si,d2x
       mov cx,si
       xor bx,bx
       mov es,T2_Bseg
       mov di,mem_start
       xor ah,ah
       mov al,col

      @@rept:
       mov [es:di],al
       add bx,dx
       cmp bx,si
       jng @@cont

       sub bx,si
       add di,320

      @@cont:
       inc di
       loop @@rept
    end else asm
       mov dx,dy
       mov si,d2x
       mov cx,si
       xor bx,bx
       mov es,T2_Bseg
       mov di,mem_start
       xor ah,ah
       mov al,col

      @@rept:
       mov [es:di],al
       add bx,dx
       cmp bx,si
       jng @@cont

       sub bx,si
       sub di,320

      @@cont:
       inc di
       loop @@rept
    end;

  end else begin

    if y_inc=320 then asm
       mov dx,dy
       mov si,d2x
       mov cx,dx
       mov bx,400
       mov es,T2_Bseg
       mov di,mem_start
       xor ah,ah
       mov al,col

      @@rept:
       mov [es:di],al
       add bx,si
       cmp bx,400
       jng @@cont

       sub bx,dx
       inc di

      @@cont:
       add di,320
       loop @@rept

  end else asm
       mov dx,dy
       mov si,d2x
       mov cx,dx
       mov bx,400
       mov es,T2_Bseg
       mov di,mem_start
       xor ah,ah
       mov al,col

      @@rept:
       mov [es:di],al
       add bx,si
       cmp bx,400
       jng @@cont

       sub bx,dx
       inc di

      @@cont:
       sub di,320
       loop @@rept
  end;

end;
end;



  Procedure T2_Block(Xv,Yv,wid,ttt: Word; Cv: byte); Assembler;
    Asm
      push ds

      mov ax,Yv
      mov bx,ax
      shl ax,8
      shl bx,6
      add ax,bx
      shr ax,4
      add ax,T2_Bseg

      mov bx,ttt
      cmp ttt,0
      jz @@skip

      push bx
      mov dx,ax
      mov es,dx
      push dx

      mov al,Cv
      mov ah,al

      mov di,Xv
      add di,T2_Bofs
      push di
      mov cx,wid
      push cx
    @@ennnd:
      mov es,dx
      cld
      rep stosb

      pop cx
      pop di

      pop dx

      add dx,20
      pop bx
      dec bx

      push bx
      push dx
      push di
      push cx

      cmp bx,0
      jnz  @@ennnd

      pop cx
      pop di
      pop dx
      pop bx

    @@skip:
      pop ds

  End;


Procedure T2_Horiz_Line(Xv,Yv,wid: Word; Cv: byte); assembler;
asm
        push ds

        mov ax,Yv
        mov bx,ax
        shl ax,8
        shl bx,6
        add ax,bx
        shr ax,4
        add ax,T2_Bseg

        mov es,ax

        mov al,Cv
        mov ah,al

        mov di,Xv
        add di,T2_Bofs
        mov cx,wid

        cld
        rep stosb

        pop ds
end;

Procedure T2_Vert_Line(Xv,Yv,Hei:Word; Cv:Byte); assembler;
asm
        mov di,Yv
        mov bx,di
        shl di,8
        shl bx,6
        add di,bx
        add di,Xv
        add di,T2_Bofs

        mov cx,Hei
        mov es,T2_Bseg
        mov al,Cv

@@reploop:
        mov [es:di],al
        add di,320
        dec cx
        cmp cx,0
        jnz @@reploop
end;

Procedure T2_Dot(Xv,Yv:Word; Cv:Byte); assembler;
asm
        mov di,Yv
        mov bx,di
        shl di,8
        shl bx,6
        add di,bx
        add di,Xv
        add di,T2_Bofs

        mov es,T2_Bseg

        mov al,Cv
        mov [es:di],al
end;

Function T2_GetDot(Xv,Yv:Word):Byte;
var temp1: byte;
begin
     asm
        mov di,Yv
        mov bx,di
        shl di,8
        shl bx,6
        add di,bx
        add di,Xv
        add di,T2_Bofs

        mov ax,T2_Bseg
        mov es,ax

        mov al,[es:di]
        mov temp1,al
end;
t2_GetDot:=temp1;
end;


Procedure T2_Scroll(Hval,Vval: integer);
var xy,yy: word;
begin
  Hval:=-hval; Vval:=-Vval;
  if (Vval>-1000) then begin
    if (Vval<0) or ( (Vval=0) and (hval>0) ) then begin
      xy:=abs(hval+1000); yy:=-Vval;
  Asm
   push ds
   mov es,T2_Bseg
   mov ax,yy
   mov bx,ax
   shl ax,8
   shl bx,6
   add ax,bx
   mov si,ax
   add si,xy
   add si,T2_Bofs
   sub si,1000

   mov di,0
   mov cx,32000
   mov ds,T2_Bseg
   cld
   rep movsw
   pop ds
  end;
End else begin
      xy:=abs(hval+1000); yy:=Vval;
  Asm
   push ds
   mov es,T2_Bseg

   mov ax,yy
   mov bx,ax
   shl ax,8
   shl bx,6
   add ax,bx
   mov si,64000
   sub si,ax
   add si,xy
   sub si,1000
   add si,T2_Bofs

   mov di,64000
   mov cx,32000
   mov ds,T2_Bseg
   std
   rep movsw
   pop ds
  end;
End;

end;

End;

  Procedure T2_HW_Scroll(xv,yv: word);
    var S_Offset,tpx: Word;
    Begin
      tpx:=xv+yv*320;
      T2_Buffers[0]:=Ptr($A000,tpx);
      If T2_Current_Buffer=0 then T2_Bofs:=tpx;

      S_Offset:= yv shl 4 + yv shl 6 + xv div 4;

      Repeat until Port[$3da] and 8 = 0;

      cli;
      portw[$3d4]:= $0c + hi(S_Offset) shl 8;
      portw[$3d4]:= $0d + lo(S_Offset) shl 8;
      sti;

      Repeat until Port[$3da] and 8 = 8;

      cli;
      port[$3c0]:=$33;
      port[$3c0]:=(XV mod 4) shl 1;
      sti;


    end;


Procedure T2_PutPic(Xv,Yv: Integer; Pp: Pointer);
    Var
      Draw_wid,Pic_Wid,Pic_Hei: Word; Draw_hei: byte;
    Begin
       T_seg:=Seg(pp^);
      T_Ofs:=Ofs(pp^)+6;
      Pic_Wid:=memw[T_Seg:T_Ofs-6];
      Pic_Hei:=memw[T_Seg:T_Ofs-4];

      Case T2_Pic[2] of
        1: Xv:=Xv-Pic_Wid;
        2: Xv:=Xv-Pic_Wid DIV 2;
      end;

      Case T2_Pic[3] of
        1: Yv:=Yv-Pic_Hei;
        2: Yv:=Yv-Pic_Hei DIV 2;
      end;

      If (Xv+Pic_Wid>0) and (Xv<320) and (Yv+Pic_Hei>0) and (Yv<200) then
        Begin
          Draw_Wid:=Pic_Wid;
          Draw_Hei:=Pic_Hei;

          If Xv<0 then
            Begin
              Draw_Wid:=Draw_Wid+Xv;
              T_Ofs:=T_Ofs-Xv;
              Xv:=0;
            End;

          If (Xv+Draw_Wid>319) then
            Begin
              Draw_Wid:=320-Xv;
            End;

          If Yv<0 then
            Begin
              Draw_Hei:=Draw_Hei+Yv;
              T_Ofs:=T_Ofs-Yv*Pic_Wid;
              Yv:=0;
            End;

          If (Yv+Draw_Hei>199) then
            Begin
              Draw_Hei:=200-Yv;
            End;

          Asm
            push ds
            push bp

            mov es,T2_Bseg
            mov di,Yv
            mov ax,di
            shl di,8
            shl ax,6
            add di,ax
            add di,Xv
            add di,T2_Bofs

            mov bx,Draw_Wid
            mov si,T_Ofs

            mov dx,320
            sub dx,bx

            mov ah,draw_hei

            mov ds,T_Seg
            mov bp,pic_wid
            sub bp,bx

          @@loop1:
            mov cx,bx
            cld
            rep movsb

            add di,dx
            add si,bp

            dec ah
            jnz @@loop1

            pop bp
            pop ds
          End;
        End;

    End;


  Procedure T2_PutBakPic(Xv,Yv: Integer; Pp: Pointer);
    Var
      Draw_wid,Pic_Wid,Pic_Hei: Word; Draw_hei,Bak_Col: Byte;
    Begin
      T_seg:=Seg(pp^);
      T_Ofs:=Ofs(pp^)+6;
      Pic_Wid:=memw[T_Seg:T_Ofs-6];
      Pic_Hei:=memw[T_Seg:T_Ofs-4];

      Case T2_Pic[2] of
        1: Xv:=Xv-Pic_Wid;
        2: Xv:=Xv-Pic_Wid DIV 2;
      end;

      Case T2_Pic[3] of
        1: Yv:=Yv-Pic_Hei;
        2: Yv:=Yv-Pic_Hei DIV 2;
      end;

      If (Xv+Pic_Wid>0) and (Xv<320) and (Yv+Pic_Hei>0) and (Yv<200) then
        Begin
          Draw_Wid:=Pic_Wid;
          Draw_Hei:=Pic_Hei;

          If Xv<0 then
            Begin
              Draw_Wid:=Draw_Wid+Xv;
              T_Ofs:=T_Ofs-Xv;
              Xv:=0;
            End;

          If (Xv+Draw_Wid>319) then
            Begin
              Draw_Wid:=320-Xv;
            End;

          If Yv<0 then
            Begin
              Draw_Hei:=Draw_Hei+Yv;
              T_Ofs:=T_Ofs-Yv*Pic_Wid;
              Yv:=0;
            End;

          If (Yv+Draw_Hei>199) then
            Begin
              Draw_Hei:=200-Yv;
            End;

          Bak_Col:=T2_Pic[1];

          Asm
            push ds
            push bp

            mov es,T2_Bseg
            mov di,Yv
            mov ax,di
            shl di,8
            shl ax,6
            add di,ax
            add di,Xv
            add di,T2_Bofs

            mov bx,Draw_Wid
            mov si,T_Ofs

            mov ah,draw_hei
            mov dl,bak_Col

            mov ds,T_Seg
            mov bp,pic_wid
            sub bp,bx

          @@loop1:
            mov cx,bx

          @@loop2:
            mov al,[ds:si]
            cmp al,dl
            jz @@skipwrite

            mov [es:di],al

          @@skipwrite:
            inc si
            inc di
            dec cx
            jnz @@loop2


            add di,320
            sub di,bx
            add si,bp

            dec ah
            jnz @@loop1

            pop bp
            pop ds
          End;
        End;

    End;


  Procedure T2_PutBakGetPic(Xv,Yv: Integer; Pp: Pointer);
    Var
      Draw_wid,Pic_Wid,Pic_Hei,Get_Ofs: Word; Draw_hei,Bak_Col: Byte;
    Begin
      T_seg:=Seg(pp^);
      T_Ofs:=Ofs(pp^)+6;
      Pic_Wid:=memw[T_Seg:T_Ofs-6];
      Pic_Hei:=memw[T_Seg:T_Ofs-4];

      Get_Ofs:=Pic_Wid*Pic_Hei+6;
      memw[T_Seg:T_Ofs-6+Get_Ofs]:=Pic_Wid;
      memw[T_Seg:T_Ofs-4+Get_Ofs]:=Pic_Hei;

      Case T2_Pic[2] of
        1: Xv:=Xv-Pic_Wid;
        2: Xv:=Xv-Pic_Wid DIV 2;
      end;

      Case T2_Pic[3] of
        1: Yv:=Yv-Pic_Hei;
        2: Yv:=Yv-Pic_Hei DIV 2;
      end;

      If (Xv+Pic_Wid>0) and (Xv<320) and (Yv+Pic_Hei>0) and (Yv<200) then
        Begin
          Draw_Wid:=Pic_Wid;
          Draw_Hei:=Pic_Hei;

          If Xv<0 then
            Begin
              Draw_Wid:=Draw_Wid+Xv;
              T_Ofs:=T_Ofs-Xv;
              Xv:=0;
            End;

          If (Xv+Draw_Wid>319) then
            Begin
              Draw_Wid:=320-Xv;
            End;

          If Yv<0 then
            Begin
              Draw_Hei:=Draw_Hei+Yv;
              T_Ofs:=T_Ofs-Yv*Pic_Wid;
              Yv:=0;
            End;

          If (Yv+Draw_Hei>199) then
            Begin
              Draw_Hei:=200-Yv;
            End;

          Bak_Col:=T2_Pic[1];

          Asm
            push ds
            push bp

            mov es,T2_Bseg
            mov di,Yv
            mov ax,di
            shl di,8
            shl ax,6
            add di,ax
            add di,Xv
            add di,T2_Bofs

            mov dx,Draw_Wid
            mov si,T_Ofs

            mov cl,draw_hei
            push cx
            mov ah,bak_Col
            mov bx,Get_Ofs

            mov ds,T_Seg
            mov bp,pic_wid
            sub bp,dx

          @@loop1:
            mov cx,dx

          @@loop2:
            mov al,[es:di]
            mov [ds:si+bx],al

            mov al,[ds:si]
            cmp al,ah

            jz @@skipwrite

            mov [es:di],al

          @@skipwrite:
            inc si
            inc di
            dec cx
            jnz @@loop2


            add di,320
            sub di,dx
            add si,bp

            pop cx
            dec cl
            push cx
            jnz @@loop1

            pop cx
            pop bp
            pop ds
          End;
        End;

    End;

  Procedure T2_ReplacePic(Xv,Yv: Integer; Pp: Pointer);
    Var P2: Pointer;
    Begin
      P2:=Ptr(Seg(Pp^),Ofs(Pp^)+T2_GetWidth(Pp)*T2_GetHeight(Pp)+6);
      T2_PutPic(Xv,Yv,P2);
    End;

{  Procedure T2_PutGetPic(Xv,Yv: Integer; Pp: Pointer);
    Var
      Draw_wid,Pic_Wid,Pic_Hei,Get_ofs: Word; Draw_hei: Byte;
    Begin
      T_seg:=Seg(pp^);
      T_Ofs:=Ofs(pp^)+6;
      Pic_Wid:=memw[T_Seg:T_Ofs-6];
      Pic_Hei:=memw[T_Seg:T_Ofs-4];
      Get_Ofs:=Pic_Wid*Pic_Hei+6;

      If (Xv+Pic_Wid>0) and (Xv<320) and (Yv+Pic_Hei>0) and (Yv<200) then
        Begin
          Draw_Wid:=Pic_Wid;
          Draw_Hei:=Pic_Hei;

          If Xv<0 then
            Begin
              Draw_Wid:=Draw_Wid+Xv;
              T_Ofs:=T_Ofs-Xv;
              Xv:=0;
            End;

          If (Xv+Draw_Wid>319) then
            Begin
              Draw_Wid:=320-Xv;
            End;

          If Yv<0 then
            Begin
              Draw_Hei:=Draw_Hei+Yv;
              T_Ofs:=T_Ofs-Yv*Pic_Wid;
              Yv:=0;
            End;

          If (Yv+Draw_Hei>199) then
            Begin
              Draw_Hei:=200-Yv;
            End;

          Asm
            push ds
            push bp

            mov es,T2_Bseg
            mov di,Yv
            mov ax,di
            shl di,8
            shl ax,6
            add di,ax
            add di,Xv
            add di,T2_Bofs

            mov bx,Draw_Wid
            mov si,T_Ofs

            mov dx,320
            sub dx,bx

            mov ah,draw_hei

            mov ds,T_Seg
            mov bp,pic_wid
            sub bp,bx

          @@loop1:
            mov cx,bx
            cld
            rep movsb

            add di,dx
            add si,bp

            dec ah
            jnz @@loop1

            pop bp
            pop ds
          End;
        End;

    End;}


  Procedure T2_GetPic(Xv,Yv,Wdd,hii: Integer; Pp: Pointer);
    Var
      Draw_wid,Pic_Wid,Pic_Hei: Word; Draw_hei: Byte;
    Begin
      T_seg:=Seg(pp^);
      T_Ofs:=Ofs(pp^)+6;
      Pic_Wid:=Wdd;
      Pic_Hei:=hii;

      Case T2_Pic[2] of
        1: Xv:=Xv-Pic_Wid;
        2: Xv:=Xv-Pic_Wid DIV 2;
      end;

      Case T2_Pic[3] of
        1: Yv:=Yv-Pic_Hei;
        2: Yv:=Yv-Pic_Hei DIV 2;
      end;

      memw[T_Seg:T_Ofs-6]:=Pic_Wid;
      memw[T_Seg:T_Ofs-4]:=Pic_Hei;


      If (Xv+Pic_Wid>0) and (Xv<320) and (Yv+Pic_Hei>0) and (Yv<200) then
        Begin
          Draw_Wid:=Pic_Wid;
          Draw_Hei:=Pic_Hei;

          If Xv<0 then
            Begin
              Draw_Wid:=Draw_Wid+Xv;
              T_Ofs:=T_Ofs-Xv;
              Xv:=0;
            End;

          If (Xv+Draw_Wid>319) then
            Begin
              Draw_Wid:=320-Xv;
            End;

          If Yv<0 then
            Begin
              Draw_Hei:=Draw_Hei+Yv;
              T_Ofs:=T_Ofs-Yv*Pic_Wid;
              Yv:=0;
            End;

          If (Yv+Draw_Hei>199) then
            Begin
              Draw_Hei:=200-Yv;
            End;

          Asm
            push ds
            push bp

            mov si,Yv
            mov ax,si
            shl si,8
            shl ax,6
            add si,ax
            add si,Xv
            add si,T2_Bofs

            mov bx,Draw_Wid
            mov di,T_Ofs

            mov dx,320
            sub dx,bx

            mov ah,draw_hei

            mov es,T_Seg
            mov ds,T2_Bseg

            mov bp,pic_wid
            sub bp,bx

          @@loop1:
            mov cx,bx
            cld
             rep movsb

            add si,dx
            add di,bp

            dec ah
            jnz @@loop1

            pop bp
            pop ds
          End;
        End;

    End;


  Procedure T2_Set_Scale_Size(wid,hei: word);
    Begin
      T2_Stype:=0;
      T2_SSwid:=wid;
      T2_SShei:=hei;
    End;

  Procedure T2_Set_Scale_Ratio(x1,x2,y1,y2: Word);
    Begin
      T2_Stype:=1;
      T2_SSwid:=0;
      T2_SShei:=0;
      T2_Sratios[1]:=x1;
      T2_Sratios[2]:=x2;
      T2_Sratios[3]:=y1;
      T2_Sratios[4]:=y2;

    End;

  Procedure T2_Set_Pic(BakCol,justify,yjustify: Byte);
    Begin
      T2_Pic[1]:=Bakcol;
      T2_Pic[2]:=Justify;
      T2_Pic[3]:=Yjustify;
    End;

  Procedure T2_Scale_Pic(xv,yv: Word; pp: pointer);
    Var
      T1,T2,T3,T4,ScOfs: Word;
    Begin
      SPwid:=T2_GetWidth(pp);
      SPhei:=T2_GetHeight(pp);

      Case T2_Stype of
        0:Begin
            If T2_SSwid=0 then SSwid:=SPwid else SSWid:=T2_SSwid;
            If T2_SShei=0 then SShei:=SPhei else SShei:=T2_SShei;
          End;
        1:Begin
            If T2_Sratios[1]=0 then T1:=SPwid else T1:=T2_Sratios[1];
            If T2_Sratios[2]=0 then T2:=SPwid else T2:=T2_Sratios[2];
            If T2_Sratios[3]=0 then T3:=SPhei else T3:=T2_Sratios[3];
            If T2_Sratios[4]=0 then T4:=SPhei else T4:=T2_Sratios[4];
            SSwid:=Round(T1*SPwid/T2);
            SShei:=Round(T3*SPhei/T4);
          End;
        End;

      Case T2_Pic[2] of
        0: Scofs:=0;
        1: Scofs:=SSwid;
        2: Scofs:=SSwid shr 1;
      end;

      Case T2_Pic[3] of
        1: Inc(Scofs,SShei*320);
        2: Inc(Scofs,(SShei div 2)*320);
      end;

      SPseg:=Seg(Pp^);
      SPofs:=Ofs(Pp^)+6;

      asm
        push bp
        push ds

        mov di,Yv
        mov bx,di
        shl di,8
        shl bx,6
        add di,bx
        add di,Xv
        add di,T2_Bofs
        sub di,Scofs

        mov cx,SSwid
        mov dx,SPwid
        mov es,T2_Bseg
        mov si,SPofs
        mov bp,SPhei
        mov ds,SPseg

        mov bx,0
        mov ax,1
        push ax

      @@skip6:
        pop ax
        pop ds
        push ds
        push ax
        add bx,SShei
        mov ds,SPseg

      @@skip4:
        cmp bx,bp
        jb  @@skip5

        sub bx,bp

        push bx
        mov bx,0
        mov ax,1
        push ax

      @@skip3:
        add bx,cx
        lodsb

      @@skip1:
        cmp bx,dx
        jb  @@skip2

        sub bx,dx
        stosb

        jmp @@skip1

      @@skip2:
        pop ax
        inc ax
        push ax

        cmp ax,dx
        jbe @@skip3

        add di,320
        sub di,cx
        sub si,dx

        pop ax
        pop bx

        jmp @@skip4

      @@skip5:
        add si,dx

        pop ax
        inc ax
        push ax

        cmp ax,bp
        jbe @@skip6

        pop ax
        pop ds
        pop bp

      end;


    End;

  Function T2_GetPicSize(Xv1,Xv2,Yv1,Yv2: Word): word;
    Begin

      T2_GetPicSize:=(abs(Xv2-Xv1)+1)*(abs(Yv2-Yv1)+1)+6;

    End;

  Function T2_GetWidth(Pp: Pointer): word;
    Begin
      T2_GetWidth:=memw[seg(Pp^):ofs(Pp^)];
    End;

  Function T2_GetHeight(Pp: Pointer): word;
    Begin
      T2_GetHeight:=memw[seg(Pp^):ofs(Pp^)+2];
    End;

End.

