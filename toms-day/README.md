# Tom's Day Out

Written by Wes (with Tom's usual libraries), for Tom's 18th birthday, Summer
1996. This is an inferior version of a game I had on the 8-bit Atari, Hovver Bovver. The plot is basically that you're lawn mower is broken, so 
you steal your neighbour's, and it turns out they don't like that, so they chase you. If you mow a flower-bed, a similarly homicidal
gardener comes to get you as well. And there's also your dog, who minds his own business for a while, but after a while gets bored and
starts attacking you as well. You can command him to chase the neighbour and gardener away if that's useful... and your mower overheats if 
you run over a dog, or just use it very consistently. 

It's rather less sophisticated and subtle than the original, but there we 
are. Oh, and it has level editor, and you can include ponds. But the first levels are as best as
I could make out, authentic to the original.

## Audio

Hmm.

## The Level Editor

* *Up/Down arrows* to select the object to put on the grid.
* Point and click to place objects.
* **G** to choose starting positions of all the characters.
* **L** to load a particular level file. eg "level1"
* **S** to save the screen to a level file. eg "level12"

## Running

* Run DosBox
* cd toms-day
* TDA  for the game
* TDALEV  for the level editor
## Compiling

* Compile the DSIK load unit, MOUSERMW, TD_256, TD_PCX and TD_KEY first.
* Load Pascal, File, Change directory to toms-day/SRC
* Options, Open TDA.TP
* Then File, Open, FLIPPERS.PAS. ALT-F9 to compile, ALT-F3 to close.
* Repeat for TDA_2.PAS, TDA_3.PAS, TDA_4.PAS.
* Repeat for TDALEV.PAS, but check the constant LEV_DIR - if running from the SRC folder, prefix with "../" - but not for release EXE.
* Finally, compile TDA.PAS - but check that the constants AUDIO_DIR, GFX_DIR, and LEV_DIR are set. For running in the SRC folder, prefix with '../' - but not for release EXE.
