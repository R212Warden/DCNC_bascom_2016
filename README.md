# DCNC_bascom_2016
A CNC uploader written in BASIC
0.
------------------------------------------------------------
1.Intro
2.Compatibility
3.Comments, file naming
------------------------------------------------------------
1.
This is a source for CNC controller written in basic. Source should be readable enough but bascom compiler makes that hard, because
math operations have to be wrtitten like this:
//////////////////////////
Stb = Xstab * Ystab
Stb = Stb * 2
Tmp = Stb
Tmp = Sqr(tmp)
Stb = Tmp
\\\\\\\\\\\\\\\\\\\\\\\\\
-------------------------------------------------------------
2.
The HEX included is for Atmega32 @ 16MHz, 38.4k baud.
Code should support most 40pin mega uCs with more than 16k flash.
This code doesnt fit on atmega16, but it can fit if you remove "Arnulf", remove few lines and it will work.
------------------------------------------------------------
3.
This source includes 6 files alongside old unused ones that i kept in case of screwups.

CNC.bas - Main file, contains UART interrupt, definitions and main loop.
functions.bas - Contains code for linear translation in 3 axes, and incomplete code for circles that i gave up on...
incrg_parser.bas - Gcode parser, but contains specific commands dubbed "incrg", named in the same fashion as "c++", but in BASIC language (incr g)
stepper.bas - Stepper stuff, pins...
values.bas - Nearly all values used by this source. Unsorted, some are commented, note 6 bytes for stepper sequence.
ARNULF.bas - ARea NuLiFier, shortened to "ARNULF" is my attempt at compensation for workarea imperfections. Works but it needs
            some work. Tends to accumulate error, USE WITH CAUTION.

Code is commented at some points, but most of it should be pretty straightforward.
------------------------------------------------------------
