# DSIK (Digital Sound Interface Kit)

(C) 1994 Carlos Hasan

## DSIK online and this repo

DSIK was a popular library for playing sound in the 1990s, available for both C
and Pascal. Places you can find it online include...

* [Shareware C 2.05](http://www.dcee.net/Files/Programm/Sound/dsik205.arj)
* [Shareware C 2.05](http://ftp.lanet.lv/ftp/mirror/x2ftp/msdos/programming/mxlibs/dsik205.zip)
* [Shareware C 1.01a](http://ftp.lanet.lv/ftp/mirror/x2ftp/msdos/programming/wgt/dsik_c.zip)
* [Shareware Pascal 1.01a](http://ftp.lanet.lv/ftp/mirror/x2ftp/msdos/programming/wgt/dsik_pas.zip)

The shareware version is limited to four channels, and I've not been able to find the unrestricted
version online, for either C or Pascal. However, in the early 2000s, I mailed the author Carlos Hasan,
and asked if I could still pay for a registered version of the Pascal version. He kindly replied by
sending me the full version without requesting payment - by that time, most of the computing world
had moved on from MS-DOS games already.

In the spirit of that, I have included in this repo what Carlos freely mailed me in this repo, unchanged,
(including the licence which officially states that I shouldn't be giving this away - not in 1994 at least).
I have attempted to contact Carlos on all previous emails to ask formal permission for this, but I've not
been able to track me down. I hope that after some 20 years, this is a reasonable thing to do for the sake
of preservation of memories, and of good software. But if anyone (including Carlos) should find this page
and prefer me to do something different, I am very willing to do so.

I do not, unfortunately, have any code for the C version, beyond those you can download online from the
links above.

## Compiling

I needed to recompile `LOAD.PAS`, as I think the TPUs compiled with the
original download were for an earlier version of Pascal. The remainder
does not need compiling - and actually cannot be, as we're missing some
of the objects. But that won't be a problem for using the library.

* In DosBox, run Turbo Pascal, and...
* File, Change directory to `LIBS/DSIK/SRC`
* Options, Open `DSIK.TP`
* File, Open `LOAD.PAS`
* and compile with ALT+F9.
* You now have a suitable version of `LOAD.TPU` in `LIBS/DSIK/TPU`

## Usage

See the original documentation in `DOCS`, and the examples in `SRC`, as well as 
the places I use this in the games.
