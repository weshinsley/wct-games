# Smudgelet's Maze 2000

|             |                       |
|-------------|-----------------------|
| **Game**    | Smudgelet's Maze 2000 |
| **Author**  | Wes                   |
| **Date**    | April 2000            |
| **Reason**  | Mark's 18th birthday  |

## Introduction

Mark the Smudgelet was now 4 years older, had grown considerably taller 
than me, and had a computer with colour and sound. I thought I'd
try a scrolling maze game for lots of players, and turn the original
speaker bleeping tune into something more epic...

## The Bizarre Plot

On April 15th 1982, in a nuclear waste plant in Brenchley, a
dreadful catastrophe of a highly implicational nature occurred. A 
blockage in the waste disposal unit caused an unidentified mass 
of crusty fossilised baked beans, brown gunk, green slime, some
odd socks, an anvil, assorted root vegetables, a defunct electric 
hair curler, a bucket-load of rubber chickens, and three small
sweet saute potatoes, as grown on the Northern faces of Mount 
Kilimanjaro to be left unattended in the open.

Later that day, a freak storm ensued, and the dreadful mass 
of conglomerated artefacts was struck by a bolt of lightning with
extreme power! The components were fried, and the hideous heap became 
molten. Within minutes, the horror was enormified, as this rancid 
slagheap started to live and breathe! Out of the bowels of Brenchley, 
a new monster had been made... **THE INCREDIBLE MULK!**

But that's another story. You are a Smudgelet: a low-life runt of a 
creature. To avoid being eaten by wild mulk, Smudgelets, grovel 
pathetically underground in dark dank rank and skanky underground 
caverns, feeding on the lice of the lesser-brained gutter-flong. Each 
cavern is a complex labyrinth with one entry and exit. The only worry 
for a smudgelet, is a dead end - having to go back through paths 
already eaten, could be the end of a hungry smudgelet.

Your survival depends on your wits and quick thinking! Good Luck!

## Game Options

* You can choose how many players you'd like, between 1 and 6, and then edit
the names and keys for each player. (The keys are left, right, up, down, and 
self-combust, as in the original Smudgelet). Six players simultaneously on a
keyboard is somewhat experimental. And quite cosy.

* There are many different terrains in Brenchley, and you can choose which one
your game takes place in: Ocean, Nova, Marble, Leaves or, for the brave, the 
bowels of Brenchley.

* Different flavours of Flong exist: Blue(berry), tomato, banana, velvet, or 
dull flong. 

* There are five levels of maze: Fumey, Frusty, Frowzy, Foul and Fetid.

* Three Game types affect who might win in a multiplayer game: Devour, in which
(as long as you escape), the one who eats the most wins; Panic, in which 
you're rewarded for escaping fastest, and Ultimate is like Panic, except 
you can't go back to a square you've already visited. 

## Audio

The music is somewhat inspired from the original 8086 Smudgelet's Maze, and
adds to the panic of the situation... DosBox wires up the sound card quite 
well. Run SETUP.EXE, and choose Sound Blaster, I/O Port 220, IRQ 7 and DMA 1. 
(The defaults)

## Running

* cd s-maze2k
* SETUP (if you need to configure sound)
* SM2

## Compiling

* Compile the DSIK load unit, TD_256, TD_PCX, TD_KEY first.
* Load Pascal, File, Change directory to s-maze2k\src
* Options, Open SM2K.TP
* File, Open, NEWMAZE.PAS, Alt+F9 to compile, Alt+F3 to close.
* File, Open, SM2.PAS
* At the top, set AUDIO and GFX to '..\AUDIO\' and '..\GFX\' to run inside 
Pascal, or just 'AUDIO\' and 'GFX\' for the release executable.
* Alt+F9 (Or Compile menu, Compile)

