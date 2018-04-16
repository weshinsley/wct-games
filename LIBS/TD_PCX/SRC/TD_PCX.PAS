Unit TD_PCX;

{NEW BITS:

 Memory problem has been sorted out: memory is only allocated once.
 You must now use FREE_PCX_MEM to release the PCX memory buffer

 To bypass load palette, put NOPALETTE; in your program before
 caling LOAD_PCX;

 To load a palette later, use LOAD_PCX_PALETTE;

}

Interface
Uses TD_256;
Type PCX_Header=Record
                      Stuff1: Array[1..3] of Byte; {Type of encoding}
                      Bits_per_pixel: Byte;
                      x,y: Integer; {Upper left corner of image}
                      Width,Height: Integer; {Size}
                      Pixels_x,Pixels_y: Integer; {pixels in x and y directions}
                      EGA_Palette: Array[1..48] of Byte;
                      Stuff2: Byte; {reserved}
                      Number_colour_planes: Byte;{Number of planes in image}
                      Bytes_Per_Line: Integer;
                      Palette_Type: Integer; {ignore}
                      Nothing: Array[1..58] of Byte;
                End;

Const PCX_MEM: Boolean=False;
      PCX_PAL: Boolean=False;

Var A,Yp: integer;
    yco,xp,picture_width: word;
    pix1,pix2: Byte;
    Addr1,Addr2,heiei,adad1,adad2,bytesleft,segppic,ofsppic: word;
    tt1,tt2,fsze: longint;
    Pbuffer: Pointer;
    Fpiccy: File;
    Header: PCX_Header;
    PCXerror: Byte;
    BB: WORD;
    RGBSpace : array[0..255,1..3] of byte;

Procedure load_pcx(fname: string);
Procedure Load_PCX_Palette(Fname: String);
Procedure LOAD_Arr(fname : string);
Procedure NOPALETTE;
Procedure YESPALETTE;
Procedure PointPal(P : pointer);
Procedure PointPalArr(P : pointer);
Procedure Free_PCX_Mem;

Implementation

Procedure NOPALETTE;
begin PCX_PAL:=TRUE; end;

Procedure YESPALETTE;
begin PCX_PAL:=FALSE; end;

Procedure PointPal(P : pointer);
  var L : byte;
  begin
    for L:=0 to 255 do
    begin
      t2_setrgb(L,mem[seg(P^):Ofs(P^)+(L*3)],mem[seg(P^):Ofs(P^)+(L*3)+1],mem[seg(P^):Ofs(P^)+(L*3)+2]);
    end;
  end;

procedure PointPalArr(P : pointer);
  var L : byte;
  begin
    for L:=0 to 255 do
    begin
      RGBSpace[L,1]:=mem[seg(P^):Ofs(P^)+(L*3)];
      RGBSpace[L,2]:=mem[seg(P^):Ofs(P^)+(L*3)+1];
      RGBSpace[L,3]:=mem[seg(P^):Ofs(P^)+(L*3)+2];
    end;
  end;


Procedure LOAD_ARR(fname : string);
  var PALREAD : text;
      PALREADB : file;
      CONVERT : char;
      L,R,G,B   : byte;
  begin
    if copy(fname,length(fname)-2,3)='256' then
      begin
        assign(PALREAD,fname);
        reset(PALREAD);
        for L:=0 to 255 do
          begin
            read(PALREAD,CONVERT);
            R:=ord(CONVERT);
            read(PALREAD,CONVERT);
            G:=ord(CONVERT);
            read(PALREAD,CONVERT);
            B:=ord(CONVERT);
            RGBSpace[L,1]:=R; RGBSpace[L,2]:=G; RGBSpace[L,3]:=B;
          end;
        close(PALREAD);
      end;
    if (copy(fname,length(fname)-2,3)='PCX') or (copy(fname,length(fname)-2,3)='pcx') then
      begin
        assign(PALREADb,fname);
        reset(PALREADb,1);
        seek(Palreadb,filesize(Palreadb)-768);
        For A:=0 to 255 do begin
          BlockRead(Palreadb,R,1);
          BlockRead(Palreadb,G,1);
          BlockRead(Palreadb,B,1);
          RGBSpace[A,1]:=R; RGBSpace[A,2]:=G; RGBSpace[A,3]:=B;
        End;
      end;
  end;
Procedure Get_More_File;
begin
     if fsze>65528 then Blockread(Fpiccy,Pbuffer^,65528) else Blockread(Fpiccy,Pbuffer^,fsze);
     fsze:=fsze-65528; bytesleft:=65528;

     adad1:=seg(pbuffer^);
     adad2:=ofs(pbuffer^);
end;

Function Get_Next: byte;
begin
     Get_Next:=Mem[adad1:adad2];
     inc(adad2);
     dec(bytesleft);
     if adad2>65534 then begin
       adad1:=adad1+256; adad2:=adad2-65528;
     end;
     if bytesleft<=0 then get_more_file
end;

Procedure Get_PCX_Palette;
Var Rv,Gv,Bv: Byte;
begin
     seek(Fpiccy,filesize(Fpiccy)-768);
     For A:=0 to 255 do begin
         BlockRead(Fpiccy,Rv,1);
         BlockRead(Fpiccy,Gv,1);
         BlockRead(Fpiccy,Bv,1);
         t2_SetRGB(A,round((Rv/256)*63),round((Gv/256)*63),round((Bv/256)*63));
     End;
end;

Procedure Load_PCX_Palette(Fname: String);
begin
  Assign(Fpiccy,Fname);
  Reset(Fpiccy,1);
  Get_PCX_Palette;
  Close(Fpiccy);
end;


Procedure NextY; assembler;
     asm
        mov dx,0
        mov xp,dx

        mov dx,yp
        inc dx
        mov yp,dx

        mov dx,heiei
        inc dx
        mov heiei,dx

        mov dx,yco
        add dx,320
        mov yco,dx
end;

Procedure AT2_Horiz_Line(wid: Word; Cv: byte); assembler;
asm
        push ds

        mov es,T2_Bseg

        mov al,Cv
        mov ah,al

        mov di,Xp
        add di,yco
        mov cx,wid

        cld
        rep stosb

        pop ds
end;
Procedure AT2_Dot(Cv:Byte); assembler;
asm
        mov di,yco
        add di,xp

        mov es,T2_Bseg

        mov al,Cv
        mov [es:di],al
end;


Procedure load_pcx(fname: string);
begin

     PCXerror:=0;
     Assign(Fpiccy,fname); reset(Fpiccy,1);

     if not t2_running then begin
        PCXerror:=2; close(Fpiccy); exit; end;
     Blockread(Fpiccy,Header,128);

     picture_width:=header.bytes_per_line-1;
     tt1:=picture_width; tt2:=header.height;

     If header.stuff1[3]<>1 then begin
        PCXerror:=1; close(Fpiccy); exit; end;

 If not PCX_PAL then Get_Pcx_Palette;

     Xp:=0; Yp:=0; HEIEI:=0; yco:=T2_Bofs;

     If Not PCX_MEM then begin
       PCX_MEM:=True;
       getmem(pbuffer,65528); end;


     adad1:=seg(pbuffer^); adad2:=ofs(pbuffer^);
     fsze:=(filesize(Fpiccy)-768-128); seek(Fpiccy,128);
     if fsze>65534 then Blockread(Fpiccy,Pbuffer^,65528)
        else Blockread(Fpiccy,Pbuffer^,fsze);

     bytesleft:=65528; if fsze<65528 then bytesleft:=fsze;
     fsze:=fsze-65528; if fsze<0 then fsze:=0;

     pix1:=get_Next;

     Repeat

     If pix1<192 then begin
asm
  mov di,yco
  add di,xp
  mov es,T2_Bseg
  mov al,pix1
  mov [es:di],al

  mov di,xp
  inc di
  mov xp,di
end;
          If Xp>(picture_width) then NextY;
          End
       Else Begin
          asm
             mov ah,pix1
             sub ah,192
             mov pix1,ah
          end;
          pix2:=get_next;
          if pix1>0 then begin

             if (xp+pix1)>(picture_width) then begin

asm
        push ds

        mov bl,pix1;
        xor bh,bh
        mov ax,xp
        add ax,bx
        sub ax,picture_width
        mov bb,ax

        mov es,T2_Bseg

        mov al,pix2
        mov ah,al

        mov di,Xp
        add di,yco
        mov cl,pix1
        xor ch,ch
        add cx,1
        sub cx,bb

        cld
        rep stosb

        pop ds
end;
                nexty;
asm
        push ds

        mov es,T2_Bseg

        mov al,pix2
        mov ah,al

        mov di,Xp
        add di,yco
        mov cx,bb

        cld
        rep stosb

        pop ds
end;


             end else
asm
        push ds

        mov es,T2_Bseg

        mov al,pix2
        mov ah,al

        mov di,Xp
        add di,yco
        mov cl,pix1
        xor ch,ch

        cld
        rep stosb

        mov al,pix1
        xor ah,ah
        mov di,xp
        add di,ax
        mov xp,di

        pop ds
end;
          End;
       End;

     pix1:=get_next;

     Until ((heiei>Header.height) or (YP>199 ));

     Close(Fpiccy);
{     Dispose(P);}
end;

Procedure Free_PCX_Mem;
  begin
    Freemem(Pbuffer,65528);
    PCX_MEM:=False;
  end;

End.
