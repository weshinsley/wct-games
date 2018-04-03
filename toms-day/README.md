# Tom's Day Out

## Introduction

This is an inferior version of a game I had on the 8-bit Atari, Hovver Bovver. The plot is basically that you're lawn mower is broken, so 
you steal your neighbour's, and it turns out they don't like that, so they chase you. If you mow a flower-bed, a similarly homicidal
gardener comes to get you as well. And there's also your dog, who minds his own business for a while, but after a while gets bored and
starts attacking you as well. You can command him to chase the neighbour and gardener away if that's useful... and your mower overheats if 
you run over a dog, or just use it very consistently. 

Anyway, it was Tom's birthday, and I loved the original Hovver Bovver, so I had a go at a rewrite. It's rather less sophisticated and
subtle than the original, but there we are. Oh, and it has level editor, and you can include ponds. But the first levels are as best as
I could make out, authentic to the original.

## Compiling

* Get into the src directory, and load the .TP file. 
* The OBJect files are in obj, and the compiled DSIK library is in DSIK - both already setup in the project file.
* Load and compile each PAS file in src, leaving TDA.PAS and TDALEV.PAS til last.
* The TPU files, and the final two EXEs get put in the TPU folder; copy the EXEs to the toms-day parent, and they'll find the audio folder they want.
