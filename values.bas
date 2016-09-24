'(
    DCNC Interpreter. BASIC Gcode interpreter and CNC controller.
    Copyright (C) 2016  R212Warden

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
')


$regfile = "m32def.dat"
$crystal = 16000000
$hwstack = 256
$swstack = 256
$framesize = 256
$baud = 38400

Dim Xpos As Long , Ypos As Long , Zpos As Long
Dim Xes As Eram Long , Yes As Eram Long , Zes As Eram Long
Dim Command As String * 32 , Substring As String * 8 , Coms(6) As String * 8 , Subval As Single , Commandtmp As String * 1
Dim Xchar As Byte , Ychar As Byte , Zchar As Byte
Dim Stpp As Byte , Steps As Long
Dim Z_axis_enum As Long

Dim _echo As Bit , _interpret As Bit , _pause As Bit
Dim Buffer(32) As Byte
Dim Dull2 As Byte , Asl_timeout As Word

Dim Dirc As Byte

Dim Halfstep1a As Byte , Halfstep2a As Byte , Halfstep3a As Byte , Halfstep1b As Byte , Halfstep2b As Byte , Halfstep3b As Byte
Dim Halfstep1 As Byte , Halfstep2 As Byte , Halfstep3 As Byte
Dim Mc1 As Bit , Mc2 As Bit , Mc3 As Bit
Halfstep1a = &B11001100
Halfstep2a = &B11001100
Halfstep3a = &B11001100
Halfstep1b = &B11001100
Halfstep2b = &B11001100
Halfstep3b = &B11001100


'++++++++++++++++++++++ GCODE VALS +++++++++++++++++++++++++

Dim Absolute_coordinates As Bit : Absolute_coordinates = 1
Dim Arnulf_enable As Bit
Dim Rapid_positioning As Bit
Dim Spindle_speed As Long , Spindle_period As Word , Spindle_feedrate_tmp As Single
Dim Getvalcheck As Byte                                     '0-X;1-Y;2-Z; 3-I;4-J; 5-[NONE];6-P;7-R;
Dim Dwell_duration As Long
Dim Feedrate As Long
Dim Z_axis_innacuracy As Byte : Z_axis_innacuracy = 1



'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





Dim Gx As Long , Gy As Long , Gz As Long 
'Dim Deltax As Long , Deltay As Long , Deltaz As Long
Dim Xdir As Byte , Ydir As Byte , Zdir As Byte
Dim Xmratio As Single , Ymratio As Single , Zmratio As Single
'Dim Rnd_ratioxy As Integer , Rnd_ratiozy As Integer
Dim 3dlenght As Long , 3dcounter As Long

Dim Error As Single , Errory As Single , Errorz As Single

Dim Dull As Word
'Dim A As Bit , B As Bit , C As Bit , D As Bit

'----------------------------------------------
'CIRCLE VARS
'Dim Rad As Single
Dim Radius As Long , Sqradius As Single , Circumference As Long

Dim Cx As Long , Cy As Long
'Dim Tmp1 As Long , Tmp2 As Single , Tmp3 As Single , Tmp4 As Single , Tmp5 As Single , Tmp6 As Single , Tmp7 As Long

jmp values_end
'----------------------------------------------





Values_end: