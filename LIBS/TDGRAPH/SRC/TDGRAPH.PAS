unit TDgraph;
Interface
var
  Wbordercol,Wfillcol,Wpattern: word;
  Bbordercol,Bfillcol,Blightcol,Bshadcol,Btextcol: word;
  Bwidth,Blength,Bsthick,Blthick,Bfont,Bdir,Bsize: word;
  TBlightcol,TBshadcol,TBsthick,TBlthick,Bdelin,Bdelout: word;
  Xwidth,Xlength,Xthick: word;
  Xbordercol,Xfillcol,Xtextcol: word;

Procedure TDborder(bco:byte);
procedure msvw;
procedure TDsetwindowcolour(bcol,fcol,pat: word);
procedure TDdrawWindow(xc,yc,w,l: word);
procedure TDsetbuttoncolour(fcol,lightcol,shadowcol,bcol,textcol: word);
procedure TDsetbuttonsize(width,length,lightthick,shadthick: word);
procedure TDsetbuttonstyle(font,direction,size: word);
procedure TDsetbuttondelay(delin,delout: word);
procedure TDbuttonOut(xc,yc: word;tex: string);
procedure TDbuttonIn(axc,ayc: word; atex:string);
procedure TDbuttonClick(axc,ayc: word; atex: string);
procedure TDdrawBox(xp,yp: word; tex1,tex2: string);
procedure TDsetBoxSize(wid,len,thick: word);
procedure TDsetBoxColour(bord,fill,textc: word);
procedure TDsetBoxWidth(thick: word);

implementation

uses graph,crt;

Procedure TDborder(bco:byte); assembler; {Sets border colour}
asm
  mov ah,10h
  mov al,01h
  mov bh,bco
  int 10h
end;

procedure TDsetBoxsize(wid,len,thick: word);
begin
  Xwidth:=wid;
  Xlength:=len;
  Xthick:=thick;
end;

procedure TDsetBoxWidth(thick: word);
begin
  Xthick:=thick;
end;

procedure TDsetBoxColour(bord,fill,textc: word);
begin
  Xbordercol:=bord;
  Xfillcol:=fill;
  Xtextcol:=textc;
end;

procedure TDdrawBox(xp,yp: word;tex1,tex2: string);
var
   wid, len, thick,xps,yps,txp: word;
label 1;
begin
  xps:=xp; yps:=yp;
  wid:=xwidth; len:=Xlength; thick:=xthick;
  Setfillstyle(1,Xfillcol);
  bar(xp+thick,yp+thick,xp+wid-thick,yp+len-thick);
  setcolor(Xbordercol);
  1:line(xp,yp,xp+wid,yp);
  line(xp+wid,yp,xp+wid,yp+len);
  line(xp+wid,yp+len,xp,yp+len);
  line(xp,yp+len,xp,yp);
  dec(thick);
  inc(yp); inc(xp);
  wid:=wid-2; len:=len-2;
  if thick>0 then goto 1;
  Settextjustify(centertext,centertext);
  setcolor(xtextcol);
  txp:=xps+round((xwidth)/2);

  if tex2='' then outtextxy(txp,yps+round((xlength)/2),tex1);
  if tex2<>'' then begin outtextxy(txp,yps+round((xlength)/3),tex1);
  outtextxy(txp,yps+round(2*(xlength)/3),tex2); end;
 end;

Procedure MSVW; assembler;
  asm
    @@vwait:
    mov     dx,$3da
    in      ax,dx
    and     ax,8
    or      ax,ax
    jz      @@vwait
  end;

procedure TDsetbuttondelay(delin,delout: word);
begin
  Bdelin:=delin;
  Bdelout:=delout;
end;

procedure TDbuttonIn(axc,ayc: word; atex: string);
begin
  TBlightcol:=Blightcol;
  TBshadcol:=Bshadcol;
  TBsthick:=Bsthick;
  TBlthick:=Blthick;
  Blightcol:=TBshadcol;
  Bshadcol:=TBlightcol;
  Bsthick:=TBlthick;
  Blthick:=TBsthick;
  TDbuttonOut(axc,ayc,atex);
  Blightcol:=TBlightcol;
  Bshadcol:=TBshadcol;
  Bsthick:=TBsthick;
  Blthick:=TBlthick;
end;

procedure TDbuttonclick(axc,ayc: word; atex: string);
begin
  TBlightcol:=Blightcol;
  TBshadcol:=Bshadcol;
  TBsthick:=Bsthick;
  TBlthick:=Blthick;
  Blightcol:=TBshadcol;
  Bshadcol:=TBlightcol;
  Bsthick:=TBlthick;
  Blthick:=TBsthick;
  TDbuttonOut(axc,ayc,atex);
  delay(Bdelin);

  Blightcol:=TBlightcol;
  Bshadcol:=TBshadcol;
  Bsthick:=TBsthick;
  Blthick:=TBlthick;
  TDbuttonOut(axc,ayc,atex);
  delay(Bdelout);
end;

procedure TDsetwindowcolour(bcol,fcol,pat: word);
begin
  Wbordercol:=bcol;
  Wfillcol:=fcol;
  Wpattern:=pat;
end;

procedure TDsetbuttoncolour(fcol,lightcol,shadowcol,bcol,textcol: word);
begin
  Bbordercol:=bcol;
  Bfillcol:=fcol;
  Blightcol:=lightcol;
  Bshadcol:=shadowcol;
  Btextcol:=textcol;
end;

procedure TDsetbuttonsize(width,length,lightthick,shadthick: word);
begin
  Bwidth:=width;
  Blength:=length;
  Blthick:=lightthick;
  Bsthick:=shadthick;
end;

procedure TDsetbuttonstyle(font,direction,size: word);
begin
  Bfont:=font;
  Bdir:=direction;
  Bsize:=size;
end;

procedure TDbuttonOut(xc,yc: word; tex: string);
begin
  setfillstyle(1,bfillcol);
  bar(xc,yc,xc+bwidth,yc+blength);
  setcolor(Bbordercol);
  line(xc,yc,xc,yc+Blength);
  line(xc,yc,xc+Bwidth,yc);
  line(xc+Bwidth,yc,xc+Bwidth,yc+Blength);
  line(xc,yc+Blength,xc+Bwidth,yc+Blength);
  line(xc+Blthick,yc+Bsthick,xc+Bwidth-Bsthick,yc+Bsthick);
  line(xc+Blthick,yc+Bsthick,xc+Blthick,yc+Blength-Blthick);
  line(xc+Bwidth-Bsthick,yc+Bsthick,xc+Bwidth-Bsthick,yc+Blength-Blthick);
  line(xc+Blthick,yc+Blength-Blthick,xc+Bwidth-Bsthick,yc+Blength-Blthick);
  line(xc,yc,xc+Blthick,yc+Bsthick);
  line(xc+Bwidth,yc,xc+Bwidth-Bsthick,yc+Bsthick);
  line(xc,yc+Blength,xc+Blthick,yc+Blength-Blthick);
  line(xc+Bwidth,yc+Blength,xc+Bwidth-Bsthick,yc+Blength-Blthick);
  setfillstyle(1,Blightcol);
  floodfill(xc+1,yc+round(Blength/2),Bbordercol);
  floodfill(xc+round(Bwidth/2),yc+Blength-1,Bbordercol);
  setfillstyle(1,Bshadcol);
  floodfill(xc+Bwidth-1,yc+round(Blength/2),Bbordercol);
  floodfill(xc+round(Bwidth/2),yc+1,Bbordercol);
  setfillstyle(1,Bfillcol);
  floodfill(xc+round(Bwidth/2),yc+round(Blength/2),Bbordercol);
  setcolor(Btextcol);
  settextstyle(Bfont,Bdir,Bsize);
  settextjustify(centertext,centertext);
  outtextxy(xc+Blthick+round((Bwidth-Bsthick-Blthick)/2),yc-4+Bsthick+round((Blength-Bsthick-Blthick)/2),tex);
end;

procedure TDdrawWindow(xc,yc,w,l: word);
begin
  setcolor(Wbordercol);
  line(xc+5,yc,xc+w-5,yc);
  line(xc+5,yc+1,xc+w-5,yc+1);
  line(xc+5,yc+l,xc+w-5,yc+l);
  line(xc+5,yc+l-1,xc+w-5,yc+l-1);
  line(xc,yc+5,xc,yc+l-5);
  line(xc+1,yc+5,xc+1,yc+l-5);
  line(xc+w,yc+5,xc+w,yc+l-5);
  line(xc+w-1,yc+5,xc+w-1,yc+l-5);
  putpixel(xc+1,yc+4,Wbordercol);
  putpixel(xc+1,yc+3,Wbordercol);
  putpixel(xc+2,yc+2,Wbordercol);
  putpixel(xc+3,yc+1,Wbordercol);
  putpixel(xc+4,yc+1,Wbordercol);
  putpixel(xc+2,yc+3,Wbordercol);
  putpixel(xc+2,yc+4,Wbordercol);
  putpixel(xc+3,yc+2,Wbordercol);
  putpixel(xc+4,yc+2,Wbordercol);
  putpixel(xc+w-1,yc+4,Wbordercol);
  putpixel(xc+w-1,yc+3,Wbordercol);
  putpixel(xc+w-2,yc+2,Wbordercol);
  putpixel(xc+w-3,yc+1,Wbordercol);
  putpixel(xc+w-4,yc+1,Wbordercol);
  putpixel(xc+w-2,yc+3,Wbordercol);
  putpixel(xc+w-2,yc+4,Wbordercol);
  putpixel(xc+w-3,yc+2,Wbordercol);
  putpixel(xc+w-4,yc+2,Wbordercol);
  putpixel(xc+1,yc+l-4,Wbordercol);
  putpixel(xc+1,yc+l-3,Wbordercol);
  putpixel(xc+2,yc+l-2,Wbordercol);
  putpixel(xc+3,yc+l-1,Wbordercol);
  putpixel(xc+4,yc+l-1,Wbordercol);
  putpixel(xc+2,yc+l-3,Wbordercol);
  putpixel(xc+2,yc+l-4,Wbordercol);
  putpixel(xc+3,yc+l-2,Wbordercol);
  putpixel(xc+4,yc+l-2,Wbordercol);
  putpixel(xc+w-1,yc+l-4,Wbordercol);
  putpixel(xc+w-1,yc+l-3,Wbordercol);
  putpixel(xc+w-2,yc+l-2,Wbordercol);
  putpixel(xc+w-3,yc+l-1,Wbordercol);
  putpixel(xc+w-4,yc+l-1,Wbordercol);
  putpixel(xc+w-2,yc+l-3,Wbordercol);
  putpixel(xc+w-2,yc+l-4,Wbordercol);
  putpixel(xc+w-3,yc+l-2,Wbordercol);
  putpixel(xc+w-4,yc+l-2,Wbordercol);
  setfillstyle(Wpattern,Wfillcol);
  floodfill(xc+5,yc+5,Wbordercol);
end;

end.