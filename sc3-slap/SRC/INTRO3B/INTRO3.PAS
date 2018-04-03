
{$define cpu386}

program creditscroll;
uses u_vga,u_mdx,u_kb;
const
  lines=102;
  txt:array[0..lines-1] of string[30]=(
   {.........|.........|.........|}
    '',
    'Legend tells of the Evil Hand-',

    'a dark force (well, sort of',
    'reddish actually) that has, in',
    'times past, slapped its way',
    'through civilisation, turning',
    'everything or everyone in its',
    'wake to evil and creating',
    'anarchy.',
    '',
    'Its home is in the desolate',
    'Arctic wasteland; there it has',
    'resided since the dawn of time',
    'planning its ultimate conquest',
    '-the destruction of the',
    'universe...',
    '',
    '...That was until, many years',
    'ago, it was buried deep',
    'beneath the ice and snow after',
    'an unfortunate skiing accident',
    '',
    'There the Hand resided for',
    'centuries, its power ebbing,',
    'its life force draining...',
    'Until an expedition, sent out',
    'to uncover the secrets of the',
    'arctic found the hand,',
    'lifeless in its residing place',
    '',
    'On that fateful day,',
    '25th June 1978, they removed',
    'the Evil Hand and transported',
    'it to an archaelogical museum',
    'somewhere in the midst of a',
    'large city, either ignorant',
    'or sceptical of the legend.',
    'It remained there, forgotten,',
    'still powerless, waiting for',
    'a new era...',
    '',
    '...That was then, this is now:',
    'Now the Hand has regenerated',
    'its power; 17 years to the',
    'day it was uncovered, it broke',
    'from its storage place and set',
    'about on its mission again to',
    'destroy all justice, turn good',
    'to evil, destroy civilisation',
    'with anarchy and force',
    'everyone to eat Pot Noodles.',
    '',
    'There is only one man brave',
    'enough to stop him-',
    'but he is on holiday in Spain',
    'so Merrick will have to do.',
    'The safety of the world now',
    'resided entirely on Merrick;',
    'only he had the slapping power',
    'to counter the Hand''s evil',
    'desires and destroy it so that',
    'it could never rise again.',
    '',
    'Mez courageously decided to',
    'hang around for a few months',
    'and see what would happen.',
    '',
    'Eventually, after the Hand''s',
    'power seemed unstoppable by',
    'any conventional means,',
    'Merrick decided to act.',
    '',
    'He must follow the Evil Hand',
    'across six areas of the world',
    'and, when he catches up with',
    'it, slap it out of existance.',
    'But beware: Everything and',
    'everyone caught in the Hand''s',
    'wake has turned against him;',
    'affected by the evil influence',
    'they could destroy Merrick',
    'easily if he does not defend',
    'himself.',
    '',
    'YOU are Merrick (sorry!)',
    'You must guide him through',
    'safely, always keeping one',
    'step behind the Hand, until',
    'you will battle it back in its',
    'Arctic Lair: this will be',
    'the final showdown; the',
    'battle between Good and Evil,',
    'the War of the Slaps...',
    'GOOD LUCK!',
    '','','','','','','','');

procedure moveup(n: word); assembler;
asm
  push ds
  mov es,u_vidseg
  mov ds,u_vidseg
  xor di,di
  mov di,$000
  mov si,n
{$ifdef cpu386}
  mov cx,255*256/4
  db $66; rep movsw
{$else}
  mov cx,255*256/2
  rep movsw
{$endif}
  pop ds
end;


var i,j,slidx,b,txtidx:byte;
begin
  mdx_setmodex(mdx_256x256c,256);
  getfont(font8x8);
  txtidx:=0; slidx:=0;
  repeat
    for b:=1 to 4 do begin
    for i:=1 to length(txt[txtidx]) do for j:=0 to 7 do
      if ((mem[seg(font^):ofs(font^)+ord(txt[txtidx][i])*8+slidx] shl j) and 128)<>0 then
        mem[u_vidseg:$fe00+i*8+(256-8*length(txt[txtidx])) div 2+j]:=32+round(txtidx/2)+slidx+j;
    vretrace;
    vretrace;
     moveup($100);
     end;
    slidx:=(1+slidx) mod 8;
    if slidx=0 then txtidx:=(1+txtidx) mod lines;
  until keypressed;
  setvideo(u_lm);
end.
