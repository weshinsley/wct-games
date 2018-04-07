# The WCT Games Collection

## Introduction

This curious archive, is a collection of games a couple of friends and I wrote in our mis-spent youth. They are 16-bit DOS games, written in Turbo 
pascal, and assembler for 386 or earlier. The third member of the trio was Chris, who I don't think we coaxed to do any actual programming, but
whose mini-cheddar eating habit (apparently) formed the plot-lines of these early games. In a time were computer games were forbidden from our
school facilities, these were generally personalised birthday presents for our mates, each one taking some habit, food preference or
other observable features and extrapolating it to a dramatic and absurd extent.

Windows XP I believe removed support for executables like these, so DosBox is probably the best way. You might also be able to 
get them running from a DOS boot disk, although I'm not sure whether modern audio chips will emulate old Soundblaster cards in the way these
games need. Anyway, for those who might enjoy a nostalgic and somewhat bizarre trip into our teenage minds, here are the games, complete with 
source code that appears to still compile in Turbo Pascal. 

It's ok, you don't have to thank me.

## Running them

The games run fairly well in DosBox, although not quite as pixel-smooth as they were on native hardware, probably due to the nature
of emulation, and maybe the artefacts of scaling the original screen resolution. But, they are close enough. (for what?)

* Install [DosBox](https://www.dosbox.com/download.php?main=1)
* Experiences may vary; the settings I use on a Lenovo Z580 are the defaults, except for:-
  * fullscreen=true
  * fulldouble=false - this is indeed very slow for me.
  * output=surface
  * machine=svga_s3
  * core=dynamic - and then I adjust manually with Ctrl+F12
  * cputype=auto
  * cycles=40000
  * mount c c:\Files\DosBox
  * c:

## Compiling (if you want)

All the games are compiled, and you can run the EXEs in each folder. If you are anxious to compile them yourself, you'll need Turbo Pascal 7 
which is available these days by googling. 
* Run the extended version (ie, BIN\TPX.EXE, not BIN\TURBO.EXE), as these games need more than 640k to compile. 
* File, Change Directory, to the SRC folder of the game (or library) you want to compile.
* Options, Open the Project Preferences (.TP) file, to set the paths, includes, and compiler options.
* File, Open, each .PAS file that needs compiling, and Compile (Alt+F9). TPUs and EXEs arrive in the TPU folder.
* To run code inside Pascal, you may need to adjust path variables (eg, AUDIO_DIR, GFX_DIR) near the top of the code, and prefix with '..\')

## External Libraries

* [**DSIK**](LIBS/DSIK) - we used the Digital Sound Interface Kit (C) 1994 Carlos Hasan, for playing MOD-like music files, and sound effects. This was a 
very cool library which supported 4-channel MODs in the shareware version, and 16-channel in the registered version. I don't know where
Carlos is now on the internet, but there are places you can google to download the full package. The music for all games started out as a
MOD file, and was converted into a DSM file for DSIK. You can convert it back again with [OpenMPT](https://openmpt.org/download) if that's 
the sort of thing you'd want to do.

## Our own Libraries

Almost all of the other clever library stuff was written by Tom:-

* [**TDGRAPH**](LIBS/TDGRAPH) provides useful drawing routines for GUIs.
* [**TDFONTS**](LIBS/TDFONTS) allows Pascal's BGI and CHR (graphics and font) files to be included as objects in an executable. 
* [**TD_256**](LIBS/TD_256) sets up the pretty mode 13h, (320x200 with 256 colours)
* [**TD_PCX**](LIBS/TD_PCX) works with PCX files, which we started clipping graphics from, rather than objectising them.
* [**TD_KEY**](LIBS/TD_KEY) sets up a proper keyboard handler for multiple keys at once.

And one more:

* [**MOUSERMW**](LIBS/MOUSERMW) provided all the mouse clicking and icon routines. This was written by a school friend Rupert Wood, a year above us, 
who did some very good programming and gave us a lot of help getting started. I wonder where he is now...

## The Games

* [**Oh Wessy**](oh-wessy/) - Tom's variant of Oh Mummy
* [**Shooting Cheddery**](sc1-ched) - in which you shoot random objects with mini-cheddars.
* [**Shooting Chundery**](sc2-chun) - in which you shoot drops of acid vom that are falling from outer space.
* [**Slapping Slappery**](sc3-slap) - in which you slap things scrolling up at you while driving various vehicles.
* [**Shooting Shrubbery**](sc4-shrb) - a multi-screen adventure game with Monty Python influences.
* [**Shooting Ribenaberry**](sc5-rib) - like Breakout, but with ribenaberries. And an adjustably bendy banana obviously.
* [**Shooting Teletubbery**](sc6-tub) - in which you shoot various characters and accumulate huge scores.
* [**Smudgelet's Maze**](s-maze/) - a big-maze escape game for up to 2-players, to run on an Amstrad 8086.
* [**Smudgelet's Maze 2000**](s-maze2k/) - a scrolling version of Smudgelet's Maze with dramatic music for up to 6 players theoretically.
* [**Tom's Day Out**](toms-day/)- a lawn-mowing game inspired by Hovver Bovver.
* [**Twittris**](twittris/) - a Tetris clone for up to 3 players.
