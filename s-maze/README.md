# Smudgelet's Maze

Writte by Wes (with Tom's libraries and DSIK), for Mark's 14th birthday in
April 1996. (Mark is Chris's youngest brother). Smudgelet was one of many 
mostly affectionate nicknames for Chris's youngest brother Mark, the benefactor 
of this game. 

## The Plot

You try to escape from a maze while eating stuff in 
a time limit, possibly racing a friend, and possibly not going back on
your trail, while the pc speaker beeps irritatingly at you. It 
surprisingly worked decently on the Amstrad 8086 Mark had at the time.

## Game Types

* Two Player Duel - in which two places race to eat as much stuff as possible, 
and escape the maze before the time runs out. The best of three, with 
increasing maze sizes. A food chunk gets you a point; power-pills get you a 
bonus of 10 plus the next 50 chunks score double. Two points per spare second if
you escape, but if you don't escape, you get a big fat zero for that maze.

* Tricky Smudge - Single player, three mazes, but you can't revisit 
somewhere you've already eaten. Same scoring rules apply, but don't be 
tempted by the power cube that lures you into a dead end. Use the self-combust
key if you make that mistake...

* Smudging Duel - Like the tricky smudge, but with two players against each other.

* Ultimate Smidge - Like the tricky smudge, but with a big full screen maze to deal with.

## Audio

You can turn sound effects on and off. The 8086 we used didn't have a sound
card, so the speaker beeps a tense and deeply atmospheric tune while you plan. But
if you happen to not have an 8086, DosBox wires up the sound card quite well. Run
SETUP.EXE, and choose Sound Blaster, I/O Port 220, IRQ 7 and DMA 1. (The defaults)

## Running

* cd s-maze
* SETUP (if you need to configure sound)
* SM

## Compiling

* Compile the DSIK load unit and TDFonts.
* Load Pascal, File, Change directory to s-maze\src
* Options, Open SMUDGE.TP
* If Pascal is not in C:\TP, change the Unit directories in Options, Directories. And Options, Save.
* File, Open, SM.PAS
* Search for audiodir - and use '../AUDIO/' to run inside Pascal, or 'AUDIO/' for release.
* Alt+F9 (Or Compile menu, Compile)

