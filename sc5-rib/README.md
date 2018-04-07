# Shooting Cheddery V - Shooting Ribenaberry

The first of our mode 13h games, which I think existed in preliminary 
form sometime in 1996, but was finished properly in April 1998, during 
our 2nd year of our undergrad studies. Tom had written some new PCX and 
256-colour mode libraries, while Wes learned to use MOD files and sound 
effects, and put the game together, for our ribena-loving friend Ben's 
birthday - which one I'm no longer sure. Based on Breakout and Arkanoid 
type games, with an adjustably bendy bat, and some extra gadgets falling 
out of the sky. Of course.

## The Nonsense

The year is 2027. The Ribena Crisis has raged for over 20 years. The
Ribenaberry colony, who were placed in exotic Penge for its climatic
suitability, mysteriously vanished in 2007 and up until now remained
officially lost. Just a few hours ago, their situation was uncovered
in the intolerable environment which is Milton Keynes. It is **VITAL**
to free them as soon as possible. The entire colony are very heavily
comatosed, and will require a violent awakening to ever produce very
tasty fruity drinks ever again.....

You are veteran commando Ben Brooks, ribena guru since 1997, who had
escaped a similar ribena based coma, publicised in The Cheddar, June
1996. Your weapons are the two most suited, and technologically fine
tuned devices in the world, precision made for this exact mission.

```
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$            $               $                                     $
$       XX   $ W-C-T         $    An adjustably bendably banana    $
$        XX  $ International $ capable of springing a spherical    $
$        XX  $ Bendable      $ object to a speed of over twenty    $
$       XX   $ Banana        $ metres per second  Geometrically    $
$     XXX    $ Liberation    $ exactified to absolute precision    $
$  XXXX      $ Enforcer      $ for comatosed fruity liberations    $
$            $               $                                     $
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$            $               $                                     $
$    OOOO    $ Spherical     $    Incredibly bouncy:- free from    $
$  OOOOOOOO  $ Cheddar       $ all forms of friction, due to an    $
$  OOOOOOOO  $ With          $ amazing new invention known as a    $
$  OOOOOOOO  $ Industrial    $ Bernoulli Enhancement Neurobrain    $
$  OOOOOOOO  $ Steel         $ (BEN) - armed with a small shock    $
$    OOOO    $ Housing       $ device for waking fruits in coma    $
$            $               $                                     $
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
```

So.. you, Ben have been launched to Milton Keynes, observing all the
necessary health regulations, to liberate the berries, with your kit
of weapons above. Most berries need just one scwish-hit to be awoken
from their coma. Others may require several charges from the scwish,
and some sad cases will be permanently vegatated, after twenty years
of cruel conditions. WCT are desparately working as we speak, making
enhancements to aid your mission; there's the Fluffly Latex Bendable
Banana Laser Enhancement (FLIBBLE), also the new Gigantic Inflatible
Bendy Banana Elongation Reactor (GIBBER), and other developing tools
to aid your progress. Good luck commando.

## Game Options

* Push O from the title page to set options.
  * You can turn sounds on and off.
  * You can choose starting level by password.
  * The password for the level 21 - the first user-editable level is BLOBALOB.
  * You can set the ball speed from 1-7
  * You can have up to 8 players playing in turn
  * You can set the name of each player.
* Push G from the title page to read the plot.
* Push H from the title page for hi-scores
* Push P from the title page to play.
* During the game:
  * Mouse moves the banana.
  * Cursor up/down bends the banana.
  * Cursor left/right chooses which gadget (if any) to use.
  * Left mouse button activates some gadgets
  * Right mouse button doubles the speed if you get bored.

## Audio

Epic music in DSIK - and also some sound effects produced by Wes and his
flatmates in London. DosBox wires up the sound card quite 
well. Run SETUP.EXE, and choose Sound Blaster, I/O Port 220, IRQ 7 and DMA 1. 
(The defaults)

## The Level Editor

You can edit levels 21 onwards in the RIBENA.DAT file. Run RIBEDIT.EXE and
use the following keys...
* **1** - Choose berry colour.
* **2** - What do berries do when you hit them:
  * **explode**: fall out of the sky.
  * **perm**: nothing at all.
  * **inc-exp**: increase in colour value.
  * **dec-exp**: decrease in colour value.
* **3** - How many hits before berry falls out.
* **s** - Save current level
* **l** - Load a specific level
* **c** - Copy current level into buffer
* **p** - Paste buffer onto current level
* **x** - Clear level.
* **esc** - Quit.

## Running

* Run DosBox.
* cd sc5-rib
* SETUP (if you need to configure sound)
* RIBENA (for the game)
* RIBEDIT (for the level editor)

## Compiling

* Compile the DSIK load unit, MOUSERMW, TD_256, TD_PCX and TD_KEY first.
* Load Pascal, File, Change directory to sc5-rib/SRC
* Options, Open RIBENA.TP
* Then File, Open, BERRYBIN.PAS, Alt+F9 to compile, Alt+F3 to close.
* Repeat for BERRYB2.PAS, and RIBEDIT.PAS
* For RIBENA.PAS, search for AUDIO_DIR - set to '../AUDIO/' to test inside Pascal, or 'AUDIO/' for release.
* Then compile RIBENA.PAS.
* Ignore MAKEDAT.PAS, unless you'd like to create a brand new level file.
