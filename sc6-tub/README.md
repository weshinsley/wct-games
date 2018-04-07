# Shooting Cheddery VI - Shooting Teletubbery

Written by Wes, using Tom's libraries and DSIK, in late 1998, for my
friend and room-mate, Karim, who at that time was exhibiting what we
felt was an unhealthy attachment to the creatures involved in this
game. Therapy was surely required, and what therapy could be better
than an infinite supply of missiles?

Rich helped me with the graphics, and I had a bit of help from a 
world-class cellist, our flat-mate Matt, with the interesting musical
arrangement...

## The Plot

Shoot everything, and avoid everything. Get very big scores. And do it
quickly as there's a time limit that gets tighter.

## Game Options

* Up to eight players taking turns.
* You can change the start level.
* And choose how many lives you start with.

## Audio

A fairly wild arrangement of 90s electrosynth, with the appropriate theme
tune, and Dvorak's Humoresque. Again, the obvious choices. Created with
a bit of help from Matt Forbes, world renowned cellist. 

DosBox wires up the sound card quite well. Run SETUP.EXE, and choose Sound Blaster, 
I/O Port 220, IRQ 7 and DMA 1. (The defaults)

## Running

* Run DosBox.
* cd sc6-tub
* SETUP to configure sound
* TUB

## Compiling

* Compile the DSIK load unit, MOUSERMW, TD_256, TD_PCX and TD_KEY first.
* Load Pascal, File, Change directory to sc6-tub/SRC
* Options, Open TUB.TP
* Then File, Open, TUB.PAS. Check the GFX and AUDIO are correct, depending on whether you want to run in Pascal, or generate a release EXE.
* Alt+F9 to compile.
