# Shooting Cheddery

Written by Wes and Tom, for Chris's 17th birthday in March 1995. Chris
happened to like peanuts and mini cheddars, which seemed ample reason to
write a game, based on Shooting Gallery which was doing the rounds at
that time. This was our first game, revised in June 1996 with [TDFonts](../LIBS/TDFONTS) I think, and then again
in 2000 to do something to do with the speed on faster Pentiums at that time.

## The Plot

Shoot everything. With either your peanut gun, or your mini-chedder
launcher, which both have limited ammo. Twelve levels of increasing pace, blowing
up various clip-art images.

## The Nonsense

It was a bright, summery, scorchingly hot winter day, in spring, and the
leaves were just starting to fall off the trees. The clouds rolled about, and
the rain flooded upwards. Icicles hung from the sky, and the snow smelt
like a cornish pasty.

It seemed like a fairly normal day to most people, however, few people knew
the reality behind what seemed so normal : only a select group of people had
any idea of the consequences of what was happening, in front of locked doors.

The secret conspiracy in fact existed only inside the locked brain, of a
man obsessed by something so deadly serious, that it became hysterically
amusing. In one man's bizarre imagination, came a profound case of
nutritionally induced paranoia. 

The man in question was being bombarded by unquestionably hideous obstacles
of life, which caused him to confront his nutritional disorder, and launch
every resource available at the opposition, in the hope that it might relieve
him from the inevitable consequences of not being relieved.

He started pelting the obstacles with the nearest things he could find : 
peanuts and mini-cheddars flooded fourth, and fifth, and perhaps even more,
into the enemies, each peanut removing one obstacle, but the man realised that
peanuts alone would not put an end to the onslaught of pigs, frogs, and things.

When the mini-cheddar was fired off, his nightmare became a havoc of exploding
cheese, wiping the floor with the opposition with gratuitous ease. Pelt your
opponents with peanuts, and eradicate them with edam. The choice is yours. 

Whatever you do, don't run out though, as starvation will probably cause the
hero of this heroic adventure to starve. Cutting off his food supply will
doubtlessly cause his demise, and we don't really want that to happen.

That man, was Chris. And you are he. He may not want to be you, and you may
not want to be him, but it could be worse: you could be Tom, and he could be 
Wes, so you've got it lightly. See if you can match the rippling performance of
the illustrious top gunner, Chris himself, in whose imagination this game
resides. (Although only on a contracted time-share basis, which Shooting
Cheddery has to pay him for.)

## Running

* `cd sc1-ched`
* `CHED`

## Compiling

* Compile the [MOUSERMW](../LIBS/MOUSERMW), [TDGRAPH](../LIBS/TDGRAPH) and [TDFONTS](../LIBS/TDFONTS) libraries.
* Load Pascal, File, Change directory to `sc1-ched\SRC`
* Options, Open `CHED.TP`
* If Pascal is not in `C:\TP`, change the Unit directories in Options, Directories. And Options, Save.
* File, Open, `CHEDDER1.PAS`
* Alt+F9 (Or Compile menu, Compile)

This will compile the main executable into the `TPU` folder - the other things 
that are run as part of the `CHED` batch file are a `PCX` file with automatic 
displayer (I forget how we made that - possibly it's an option in 
DeluxePaint?). And also an automatic text scroller that reads our text 
file of nonsense. I don't have source code for either of those - perhaps I
never did.

