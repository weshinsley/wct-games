# TwitTris

Written by Wes (with Tom's usual libraries), for Jon's 21st birthday. We'd
wanted to write a Tetris clone for a while. Tom wrote an early version 
where the whole screen rotated as you played, but I think we thought the
pixel problems of playing 320x200 made it not as attractive as we'd hoped.

## Game Options

* Normal tetris rules. Speed gradually rises.
* You can accelerate bricks downwards; they don't drop all the way in one press. (I like it that way).
* Up to three players at once
* Decide whether you want nasties, where other players removing rows causes yours to be shunted upwards.
* You can choose clockwise or anticlockwise piece rotation!
* You can preview a piece too.

## Audio

A bit like the music to various Holiday Programs on the BBC on the 90s.
Run `SETUP` to set up the sound. Sound Blaster, I/O Port 220, IRQ 7 and DMA 1
(the defaults) work nicely for me.

## Running

* Run DosBox
* `cd twittris`
* `SETUP` if you need to setup sound.
* `TWITTRIS`

## Compiling

* Compile the [DSIK](../LIBS/DSIK) `load` module, [TD_256](../LIBS/TD_256), [TD_PCX](../LIBS/TD_PCX) and [TD_KEY](../LIBS/TD_KEY) first.
* Load Pascal, File, Change directory to toms-day/SRC
* Options, Open `TWIT.TP`
* Then File, Open, `TWITTRIS.PAS`
* Check `AUDIO_DIR` and `GFX_DIR` are set correctly; prefix with `../` if you want to run from the SRC folder, otherwise don't prefix.
* Compile with ALT+F9.