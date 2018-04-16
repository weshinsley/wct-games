unit berryb2;

interface



procedure SCBAR; procedure IC1; procedure IC2; procedure IC3; procedure IC4;
procedure f0; procedure f1; procedure fe; procedure fm; procedure fu;
procedure f7; procedure ff; procedure fn; procedure fv;
procedure f8; procedure fg; procedure fo; procedure fw;
procedure f2; procedure f9; procedure fh; procedure fp; procedure fx;
procedure f3; procedure fa; procedure fi; procedure fq; procedure fy;
procedure f4; procedure fb; procedure fj; procedure fr; procedure fz;
procedure f5; procedure fc; procedure fk; procedure fs;
procedure f6; procedure fd; procedure fl; procedure ft;
const Alpha : array[1..36] of pointer = (@fa,@fb,@fc,@fd,@fe,@ff,@fg,@fh,@fi,@fj,@fk,@fl,@fm,
@fn,@fo,@fp,@fq,@fr,@fs,@ft,@fu,@fv,@fw,@fx,@fy,@fz,@F0,@f1,@F2,@F3,@F4,@f5,@F6,@F7,@f8,@f9);
  Wid : array[1..36] of byte = (6,6,6,6,6,6,6,6,2,2,5,2,6,6,6,6,6,6,6,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6);
 FOfs : array[1..36] of byte = (3,0,3,0,3,3,3,0,1,1,0,0,3,3,3,3,3,3,3,0,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0);


implementation

procedure SCBAR; external; {$L Scbar.obj} procedure IC1; external; {$L IC1.OBJ}


procedure IC2; external; {$L IC2.obj} procedure IC3; external; {$L IC3.obj}
procedure IC4; external; {$L IC4.obj}
procedure f0; external; {$L f0.obj} procedure fi; external; {$L fi.obj}
procedure f1; external; {$L f1.obj} procedure fj; external; {$L fj.obj}
procedure f2; external; {$L f2.obj} procedure fk; external; {$L fk.obj}
procedure f3; external; {$L f3.obj} procedure fl; external; {$L fl.obj}
procedure f4; external; {$L f4.obj} procedure fm; external; {$L fm.obj}
procedure f5; external; {$L f5.obj} procedure fn; external; {$L fn.obj}
procedure f6; external; {$L f6.obj} procedure fo; external; {$L fo.obj}
procedure f7; external; {$L f7.obj} procedure fp; external; {$L fp.obj}
procedure f8; external; {$L f8.obj} procedure fq; external; {$L fq.obj}
procedure f9; external; {$L f9.obj} procedure fr; external; {$L fr.obj}
procedure fa; external; {$L fa.obj} procedure fs; external; {$L fs.obj}
procedure fb; external; {$L fb.obj} procedure ft; external; {$L ft.obj}
procedure fc; external; {$L fc.obj} procedure fu; external; {$L fu.obj}
procedure fd; external; {$L fd.obj} procedure fv; external; {$L fv.obj}
procedure fe; external; {$L fe.obj} procedure fw; external; {$L fw.obj}
procedure ff; external; {$L ff.obj} procedure fx; external; {$L fx.obj}
procedure fg; external; {$L fg.obj} procedure fy; external; {$L fy.obj}
Procedure fh; external; {$L fh.obj} procedure fz; external; {$L fz.obj}


end.