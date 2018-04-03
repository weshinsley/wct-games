#께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
#                     Digital Sound Interface Kit (DSIK)
#                      Version 1.01a  June 14th, 1994
#                      Pascal Examples Makefile Script
#
#                      Copyright 1993,94 Carlos Hasan
#께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

# Borland Pascal Include and Library directories
BIN = c:\bp\bin
INC = c:\bp\include
LIB = c:\bp\units

# Borland C, Turbo Assembler and Turbo Link Path and Options
PC = $(BIN)\bpc.exe
AS = $(BIN)\tasm.exe
POPT = -I$(INC) -U$(LIB) -M -$G+
AOPT = -ml -m -q -t -DPASCAL

# Makefile Target
target : exam1.exe exam2.exe exam3.exe setup.exe
    @echo Done.

# Implicit Rules for Pascal and ASM source files
.pas.exe :
    $(PC) $(POPT) $<

.asm.obj :
    $(AS) $(AOPT) $<

# Examples
exam1.exe : exam1.pas ts.tpu load.tpu sound.tpu

exam2.exe : exam2.pas ts.tpu load.tpu sound.tpu

exam3.exe : exam3.pas ts.tpu load.tpu sound.tpu

setup.exe : setup.pas


