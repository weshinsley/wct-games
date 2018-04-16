(*  play.pas  - DSIK Module Player v1.02

    Copyright 1993,94 Carlos Hasan
*)

{_define UseTS}

program Play;

uses Dos,Sound,Load,TS;

const
  (* Keyboard constants *)
  kbEsc         = $001B;
  kbSpace       = $0020;
  kbPlus        = $002B;
  kbMinus       = $002D;
  kbLeft        = $4B00;
  kbRight       = $4D00;

const
  (* VGA 80x50 textmode constants *)
  VideoSeg      = $B800;
  VideoWidth    = 80;
  VideoHeight   = 50;

const
  (* VGA 8x8 Fonts *)
  Fonts: array [1..8*13] of byte = (
    $00,$e0,$e0,$e0,$e0,$e0,$e0,$00,
    $00,$ee,$ee,$ee,$ee,$ee,$ee,$00,
    $00,$00,$00,$00,$00,$00,$00,$ff,
    $ff,$00,$00,$00,$00,$00,$00,$00,
    $01,$01,$01,$01,$01,$01,$01,$01,
    $80,$80,$80,$80,$80,$80,$80,$80,
    $80,$00,$00,$00,$00,$00,$00,$00,
    $00,$00,$00,$00,$00,$00,$00,$01,
    $ff,$80,$80,$80,$80,$80,$80,$80,
    $01,$01,$01,$01,$01,$01,$01,$ff,
    $80,$c0,$e0,$f0,$f8,$fc,$fe,$ff,
    $01,$03,$07,$0f,$1f,$3f,$7f,$ff,
    $00,$1c,$3a,$3e,$3e,$1c,$00,$00
  );

const
  (* VGA RGB Palette *)
  Palette : array [1..3*16] of byte = (
    00,00,00,
    06,10,22,
    12,20,43,
    20,32,63,
    48,00,00,
    00,44,00,
    56,40,38,
    63,63,63,
    63,63,63,
    63,63,63,
    63,63,63,
    00,50,63,
    63,63,63,
    63,63,63,
    63,63,63,
    50,50,63 );

type
  TFrame = array [0..8] of word;

const
  frame1: TFrame =
    ( $2388,$028a,$208a,$2189,$2383,$2182,$2385,$2184,$2100 );

  frame2: TFrame =
    ( $2289,$2288,$2287,$2186,$2382,$2183,$2384,$2185,$2100 );

  frame3: TFrame =
    ( $2187,$2288,$2287,$2286,$2182,$2383,$2184,$2385,$0f00 );

  frame4: TFrame =
    ( $128b,$128a,$218a,$218b,$2383,$2182,$2385,$2184,$2100 );


(* Lowlevel VGA 80x50 TextMode routines *)
procedure SetTextMode; assembler;
asm
        mov     ax,0003h
        int     10h
end;

procedure SetTweakedMode; assembler;
asm
        push    ax
        push    bx
        push    dx

        mov     ax,0003h                { set 80x25x16 textmode }
        int     10h

        mov     ax,1112h                { set ROM 8x8 charset }
        mov     bl,00h                  { in the block zero }
        int     10h

        mov     dx,3C4h                 { sync reset while }
        mov     ax,0100h                { setting misc output }
        out     dx,ax

        mov     dx,3C2h                 { select the dot clock and }
        mov     al,63h                  { Horiz scanning rate }
        out     dx,al

        mov     dx,3C4h                 { select 8/9 dot clock }
        mov     ax,0101h
        out     dx,ax

        mov     dx,3C4h                 { undo reset }
        mov     ax,0300h                { (restart sequencer) }
        out     dx,ax

        mov     dx,3D4h                 { hide cursor }
        mov     ax,100Ah
        out     dx,ax
        mov     al,0Bh
        out     dx,ax

        pop     dx
        pop     bx
        pop     ax
end;

procedure SetTextFont(var FontData; First,Count:word); assembler;
asm
        push    ax
        push    bx
        push    cx
        push    dx
        push    bp
        push    es

        mov     ax,1100h                { load charset with reset }
        mov     bx,0800h
        mov     cx,[Count]
        mov     dx,[First]
        les     bp,[FontData]
        int     10h

        pop     es
        pop     bp
        pop     dx
        pop     cx
        pop     bx
        pop     ax
end;

procedure SetPalette(var Palette; Count:word); assembler;
const
  Index : array [0..15] of byte = ( 0,1,2,3,4,5,20,7,56,57,58,59,60,61,62,63 );
asm
        push    ax
        push    cx
        push    dx
        push    si
        push    di
        push    ds
        push    es

        lea     di,[Index]
        les     si,[Palette]
        mov     cx,[Count]
        mov     dx,3c8h
@@0:    mov     al,[di]
        out     dx,al
        inc     dx
        mov     al,[es:si]
        out     dx,al
        mov     al,[es:si+1]
        out     dx,al
        mov     al,[es:si+2]
        out     dx,al
        dec     dx
        add     si,3
        inc     di
        loop    @@0

        pop     es
        pop     ds
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     ax
end;

procedure DrawChar(X,Y:integer; C:char; Color:byte; Count:word); assembler;
asm
        push    di
        push    es

        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ax,VideoSeg
        mov     es,ax
        mov     ah,[Color]
        mov     al,[C]
        mov     cx,[Count]
        cld
        rep     stosw

        pop     es
        pop     di
end;

procedure DrawText(X,Y:integer; Text:PChar; Color:Byte; Max:word); assembler;
asm
        push    si
        push    di
        push    ds
        push    es

        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ax,VideoSeg
        mov     es,ax
        mov     ah,[Color]
        mov     cx,[Max]
        lds     si,[Text]

@0:     mov     al,[ds:si]
        test    al,al
        je      @1
        mov     [es:di],ax
        add     di,2
        inc     si
        dec     cx
        jg      @0

@1:     mov     al,20h
        test    cx,cx
        jle     @3
@2:     mov     [es:di],ax
        add     di,2
        loop    @2

@3:     pop     es
        pop     ds
        pop     di
        pop     si
end;

procedure DrawNum(X,Y:integer; Num:word; Color:byte); assembler;
asm
        push    si
        push    di
        push    es

        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ax,VideoSeg
        mov     es,ax
        mov     bh,[Color]
        mov     ax,[Num]
        aam
        or      al,30h
        mov     bl,al
        mov     [es:di+4],bx
        mov     al,ah
        aam
        or      al,30h
        mov     bl,al
        mov     [es:di+2],bx
        mov     al,ah
        aam
        or      al,30h
        mov     bl,al
        mov     [es:di],bx

        pop     es
        pop     di
        pop     si
end;

procedure DrawNum2(X,Y:integer; Num:word; Color:byte); assembler;
asm
        push    si
        push    di
        push    es

        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ax,VideoSeg
        mov     es,ax
        mov     bh,[Color]
        mov     ax,[Num]
        aam
        or      al,30h
        mov     bl,al
        mov     [es:di+2],bx
        mov     al,ah
        aam
        or      al,30h
        mov     bl,al
        mov     [es:di],bx

        pop     es
        pop     di
        pop     si
end;

procedure DrawNote(X,Y:integer; Note:word); assembler;
const
  Notes: array [1..3*13] of char = 'שששC-?C#?D-?D#?E-?F-?F#?G-?G#?A-?A#?B-?';
asm
        push    si
        push    di
        push    es

        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     ax,VideoSeg
        mov     es,ax
        mov     cx,3
        lea     si,[Notes]
        mov     ax,[Note]
        dec     ax
        jl      @0
        xor     dx,dx
        mov     bx,12
        div     bx
        add     si,dx
        add     dx,dx
        add     si,dx
        add     si,3
        or      al,30h
        mov     [ds:si+2],al
@0:     mov     al,[ds:si]
        mov     [es:di],al
        add     di,2
        inc     si
        loop    @0

        pop     es
        pop     di
        pop     si
end;

procedure DrawFrame(XLeft,YTop,XRight,YBottom:Integer; const Frame:TFrame); assembler;
asm
        push    si
        push    di
        push    ds
        push    es

        lds     si,[Frame]
        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[YTop]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[XLeft]
        add     ax,ax
        mov     di,ax
        mov     bx,[XRight]
        sub     bx,[XLeft]
        dec     bx
        jl      @0
        mov     dx,[YBottom]
        sub     dx,[YTop]
        dec     dx
        jl      @0
        cld
        push    di
        mov     ax,[si+2*0]
        stosw
        mov     ax,[si+2*4]
        mov     cx,bx
        rep     stosw
        mov     ax,[si+2*1]
        stosw
        pop     di
        add     di,2*VideoWidth
@1:     push    di
        mov     ax,[si+2*6]
        stosw
        mov     ax,[si+2*8]
        mov     cx,bx
        rep     stosw
        mov     ax,[si+2*7]
        stosw
        pop     di
        add     di,2*VideoWidth
        dec     dx
        jne     @1
        mov     ax,[si+2*2]
        stosw
        mov     ax,[si+2*5]
        mov     cx,bx
        rep     stosw
        mov     ax,[si+2*3]
        stosw

@0:     pop     es
        pop     ds
        pop     di
        pop     si
end;

procedure DrawMeter(X,Y:integer; Count:word); assembler;
asm
        push    di
        push    es

        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax
        mov     dx,[Count]
        cmp     dx,32
        jle     @0
        mov     dx,32
@0:     mov     cx,dx
        shr     cx,1
        cld
        mov     ax,0B81h
        rep     stosw
        mov     cx,dx
        test    cx,1
        je      @1
        inc     cx
        mov     ax,0B80h
        stosw
@1:     neg     cx
        add     cx,32
        shr     cx,1
        xor     ax,ax
        rep     stosw

        pop     es
        pop     di
end;

procedure DrawBar(X,Y:integer; Count:word); assembler;
asm
        push    di
        push    es

        mov     ax,VideoSeg
        mov     es,ax
        mov     ax,[Y]
        mov     dx,VideoWidth
        mul     dx
        add     ax,[X]
        add     ax,ax
        mov     di,ax

        mov     dx,[Count]
        cmp     dx,24
        jle     @0
        mov     dx,24
@0:     mov     cx,dx
        shr     cx,1
        cld
        mov     ax,0681h
        rep     stosw
        mov     cx,dx
        test    cx,1
        je      @1
        inc     cx
        mov     ax,0680h
        stosw

@1:     mov     dx,[Count]
        cmp     dx,32
        jle     @2
        mov     dx,32
@2:     mov     cx,dx
        cmp     cx,24
        jle     @3
        sub     cx,24
        shr     cx,1
        cld
        mov     ax,0481h
        rep     stosw
        mov     cx,dx
        test    cx,1
        je      @3
        inc     cx
        mov     ax,0480h
        stosw

@3:     neg     cx
        add     cx,32
        shr     cx,1
        xor     ax,ax
        rep     stosw

        pop     es
        pop     di
end;

(* Lowlevel Keyboard routines *)
function Keypressed: boolean; assembler;
asm
        mov     ah,01h
        int     16h
        mov     ax,0
        je      @0
        mov     ax,1
@0:
end;

function ReadKey: word; assembler;
asm
        mov     ah,00h
        int     16h
        test    al,al
        je      @0
        xor     ah,ah
@0:
end;

var
    Path   : PathStr;
    Dir    : DirStr;
    Name   : NameStr;
    Ext    : ExtStr;
    Card   : DSMCard;
    Module : PDSM;
    Music  : PDSMMusicInfo;
    Error,Volume,Key,I,J,N : Integer;
begin
    writeln('DSIK Module Player V1.02  Copyright 1993,94 Carlos Hasan');

    (* Get Command Line Parameters *)
    if ParamCount < 1 then begin
        writeln('Usage: PLAY file[.dsm]');
        exit;
    end;
    fsplit(ParamStr(1),Dir,Name,Ext);
    if Ext = '' then Ext := '.DSM';
    Path := Dir + Name + Ext;

    (* Sound Card configuration *)
    if DSMLoadSetup(Card) then begin
        writeln('Please run SETUP.EXE to configure.');
        exit;
    end;

    (* Initialize the Sound System *)
    if DSMInit(Card) then begin
        writeln('Error Initializing the Sound System.');
        exit;
    end;

    (* Load Module File *)
    Module := DSMLoad(Path,0);
    if Module = nil then begin
        case (DSMStatus) of
            ERR_NORAM:  writeln('Not enough system memory.');
            ERR_NODRAM: writeln('Not enough card memory.');
            ERR_NOFILE: writeln('File not found (',Path,').');
            ERR_FORMAT: writeln('Invalid file format.');
            ERR_ACCESS: writeln('File damaged.');
        end;
        DSMDone;
        exit;
    end;

    (* Setup Text Screen *)
    SetTweakedMode;
    SetPalette(Palette,sizeof(Palette) div 3);
    SetTextFont(Fonts,$80,sizeof(Fonts) shr 3);

    (* Draw Panel *)
    DrawFrame(1,0,78,49,frame1);
    DrawChar(4,1,#130,$21,72);
    DrawChar(4,2,#131,$23,72);
    DrawChar(4,4,#130,$21,72);
    DrawChar(4,5,#131,$23,72);
    DrawText(5,3,'DSIK Module Player Version 1.02     Copyright (C) 1993,94 Carlos Hasan',$2b,70);

    (* Draw InfoBox *)
    DrawChar(10,6,#135,$21,1);
    DrawChar(11,6,#130,$21,39);

    DrawChar(10,7,#132,$21,1);
    DrawChar(11,7,#032,$05,39);
    DrawChar(50,7,#138,$20,1);

    DrawChar(10,8,#132,$21,1);
    DrawChar(11,8,#032,$05,8);
    DrawChar(15,8,#047,$05,1);
    DrawChar(19,8,#132,$03,1);
    DrawChar(20,8,#131,$23,25);
    DrawChar(45,8,#138,$02,1);
    DrawChar(46,8,#032,$05,4);
    DrawChar(50,8,#132,$03,1);

    DrawChar(10,9,#132,$21,1);
    DrawChar(11,9,#032,$05,3);
    DrawChar(14,9,#132,$03,1);
    DrawChar(15,9,#131,$23,5);
    DrawChar(45,9,#132,$21,1);
    DrawChar(46,9,#032,$05,4);
    DrawChar(50,9,#132,$03,1);

    DrawChar(11,10,#131,$23,4);
    DrawChar(46,10,#131,$23,5);

    DrawFrame(59,6,76,9,frame3);

    DrawText(5,7,'Song:',$21,5);
    DrawText(4,8,'Order:',$21,6);
    DrawText(6,9,'Row:',$21,4);
    DrawText(37,9,'Pattern:',$21,8);
    DrawText(53,7,'Played',$21,6);
    DrawText(53,8,'Volume',$21,6);

    (* Put SongName *)
    DrawText(12,7,Module^.Song.SongName,$05,38);
    N := Module^.Song.NumChannels;

    (* Draw TrackBox *)
    DrawFrame(03,11,76,16+N,frame3);
    DrawFrame(04,12,75,15+N,frame4);

    DrawFrame(11,13,23,14+N,frame3);
    DrawFrame(24,13,54,14+N,frame3);
    DrawFrame(55,13,72,14+N,frame3);

    DrawFrame(06,13,07,14+N,frame2);
    DrawFrame(10,13,11,14+N,frame2);

    for I := 1 to N do begin
        DrawNum2(8,13+I,I,$21);
    end;

    (* Draw SamplesBox *)
    J := 2*(28-N);
    if J > Module^.Song.NumSamples then J := Module^.Song.NumSamples;
    J := succ(J) shr 1;

    DrawFrame(03,17+N,76,20+N+J,frame2);
    DrawFrame(04,18+N,75,19+N+J,frame3);

    for I := 0 to pred(J) do begin
        DrawNum2(06,19+N+I,I+1,$0f);
        DrawNum2(41,19+N+I,I+J+1,$0f);
        if Module^.Inst[I] <> nil then
            DrawText(09,19+N+I,Module^.Inst[I]^.SampleName,$0b,28);
        if Module^.Inst[I+J] <> nil then
            DrawText(44,19+N+I,Module^.Inst[I+J]^.SampleName,$0b,28);
    end;

    (* Start Playing Music *)
    DSMSetupVoices(Module^.Song.NumChannels,Module^.Song.MasterVolume);
    DSMPlayMusic(Module);
    Music := DSMGetMusicInfo;
    Volume := 255;

    (* Setup the timer service *)
{$ifdef UseTS}
    TSInit;
    TSSetRate(70);
    TSSetRoutine(DSMPoll);
{$endif}

    Key := 0;
    while Key <> kbEsc do begin

        (* Poll Music System *)
{$ifndef UseTS}
        DSMPoll;
{$endif}

        (* Update InfoBox *)
        if Music^.BreakFlag = PB_NONE then begin
            DrawNum(12,8,Music^.OrderPosition,$05);
            DrawNum(16,8,Music^.OrderLength,$05);
            DrawNum2(12,9,Music^.PatternRow,$05);
            DrawNum(47,9,Music^.PatternNumber,$05);
            DrawMeter(60,7,(32*Music^.OrderPosition+(Music^.PatternRow shr 1)) div Music^.OrderLength);
            DrawMeter(60,8,Volume shr 3);
        end;

        (* Update TrackBox *)
        for i := 0 to Pred(N) do with Music^.Tracks[i] do begin
            if Lo(NoteEvent) <> 0 then DrawChar(5,14+i,#140,$25,1)
            else DrawChar(5,14+i,#140,$21,1);
            DrawNote(13,14+i,Note);
            DrawNum2(17,14+i,Sample,$0f);
            DrawNum2(20,14+i,Volume,$0f);
            if Sample <> 0 then
                DrawText(26,14+i,Module^.Inst[Pred(Sample)]^.SampleName,$0f,28);
            DrawBar(56,14+i,EQBar shr 1);
        end;

        (* Dispatch Keyboard *)
        if keypressed then begin
            Key := Readkey;
            case Key of
                kbPlus:
                if (Volume <= 247) then begin
                    inc(Volume,8);
                    DSMSetMusicVolume(Volume);
                end;

                kbMinus:
                if (Volume >= 8) then begin
                    dec(Volume,8);
                    DSMSetMusicVolume(Volume);
                end;

                kbSpace:
                case (DSMGetMusicStatus) of
                    PS_PLAYING: DSMStopMusic;
                    PS_STOPPED: DSMPlayMusic(Module);
                end;

                kbLeft:
                begin
                    dec(Music^.OrderPosition);
                    Music^.PatternRow := 0;
                    Music^.BreakFlag := PB_JUMP;
                end;

                kbRight:
                begin
                    inc(Music^.OrderPosition);
                    Music^.PatternRow := 0;
                    Music^.BreakFlag := PB_JUMP;
                end;
            end;
        end;
    end;

    (* Done timer service and restore time *)
{$ifdef UseTS}
    TSDone;
    TSRestoreTime;
{$endif}

    (* Stop Playing and Free Module *)
    DSMStopMusic;
    DSMFree(Module);

    (* Shutdown Music System *)
    DSMDone;

    (* Clear the Text Screen *)
    SetTextMode;
end.

