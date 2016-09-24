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
$include "ARNULF.bas"
$include "values.bas"
$include "functions.bas"

Declare Sub Interpret(byref Command As String * 16)



jmp incrg_parser_done


Sub Interpret(byref Command As String * 16)
Dull = Split(command , Coms(1) , " ")
Dull = 0
Substring = Coms(1)


'(
********************************************************************************
 - - - - -vars - - - - -

   Gx - x coordinate to function
   Gy - y coordinate to function
   Gz - z coordinate to function
   Cx - circ center x coordinate
   Cy - Circ Center Y Coordinate
   Radius - Radius Used By Circle Sub
   Xdir - Used To Determine Stepper Rot Dir
   Stpp - Stepper Id
   Steps - num of steps

 - - - - -commands - - - - -

   Asl - Returns Position To Uploader
   CIRC - draws circles and conic sections
   MOVR - relative movement in 3 axis
   MOVA - absolute movement in 3 axis
   MOVS - individual stepper movement for ind. stpp
   SRL - "relaxes" steppers
   SETHOME -sets xpos, ypos, zpos to 0

********************************************************************************
')


'++++++++++++++++++++++++++++++++++ GCOMMANDS ++++++++++++++++++++++++++++++++++


If Substring = "M03" Then                                   'CW
   Portc.4 = 1
   Portc.5 = 0
   Enable Icp1
   Print ";"
Elseif Substring = "M04" Then                               'CCW
   Portc.5 = 1
   Portc.4 = 0
   Enable Icp1
   Print ";"
                                                            'spindle norot
Elseif Substring = "M05" Then
   Portc.4 = 0
   Portc.5 = 0
   Disable Icp1
   Print ";"

Elseif Substring = "G04" Then
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_extended(dull)
   Next
   Waitms Dwell_duration

Elseif Substring = "G02" Or Substring = "G03" Then
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_normalset(dull)
      Call Gcode_extended(dull)
   Next
   Dull = 0

   '(
   If Absolute_coordinates = 1 Then
      If Getvalcheck.0 = 1 Then Gx = Gx - Xpos
      If Getvalcheck.1 = 1 Then Gy = Gy - Ypos
      If Getvalcheck.2 = 1 Then Gz = Gz - Zpos
      If Getvalcheck.3 = 1 Then Cx = Cx - Xpos
      If Getvalcheck.4 = 1 Then Cy = Cy - Ypos
      If Getvalcheck.5 = 1 Then Cz = Cz - Zpos
   End If
')

   Call Circle1(gx , Gy , Cx , Cy , Radius , Substring)
   Print ";"

Elseif Substring = "G90" Then
 Absolute_coordinates = 1
 Print ";"

Elseif Substring = "G91" Then
   Absolute_coordinates = 0
   Xpos = 0
   Ypos = 0
   Zpos = 0
   Print ";"

Elseif Substring = "G00" Or Substring = "G01" Then
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_normalset(dull)
   Next
   Dull = 0

   If Substring = "G00" Then Rapid_positioning = 1 Else Rapid_positioning = 0
   If Absolute_coordinates = 1 Then
      If Getvalcheck.0 = 1 Then Gx = Gx - Xpos
      If Getvalcheck.1 = 1 Then Gy = Gy - Ypos
      If Getvalcheck.2 = 1 Then Gz = Gz - Zpos
   End If

   If Arnulf_enable = 1 Then
      Gz = Arnulfize(gx , Gy , Gz)
   End If
   Print Gz
   Call Relative_goto(gx , Gy , Gz)
   Print ";"
End If
'+++++++++++++++++++++++++++++++ INCRG COMMANDS :D +++++++++++++++++++++++++++++

If Substring = "ECHO" Then
    _echo = 1
   Print ";"

Elseif Substring = "NOECHO" Then
   _echo = 0
   Print ";"

Elseif Substring = "GETCOR" Then
   Sqradius = Stepmm(xpos)
   Print "LX$" ; Sqradius
    Sqradius = Stepmm(ypos)
   Print "LY$" ; Sqradius
    Sqradius = Stepmm(zpos)
   Print "LZ$" ; Sqradius
   Print ";"

Elseif Substring = "GETRPM" Then
   Spindle_feedrate_tmp = Icr1
   Spindle_feedrate_tmp = 250000 / Spindle_feedrate_tmp
   Spindle_feedrate_tmp = Spindle_feedrate_tmp * 3000
   Print Spindle_feedrate_tmp
   Print ";"
Elseif Substring = "SETCOR" Then
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_normalset(dull)
   Next
   Dull = 0

   If Getvalcheck.0 = 1 Then Xpos = Gx
   If Getvalcheck.1 = 1 Then Ypos = Gy
   If Getvalcheck.2 = 1 Then Zpos = Gz

   Print ";"

Elseif Substring = "SRL" Then
   S1a = 0
   S1b = 0
   S1c = 0
   S1d = 0

   S2a = 0
   S2b = 0
   S2c = 0
   S2d = 0

   S3a = 0
   S3b = 0
   S3c = 0
   S3d = 0
   Print ";"

Elseif Substring = "SETHOME" Then
   Xpos = 0
   Ypos = 0
   Zpos = 0
   Print ";"
Elseif Substring = "PSUON" Then
   Portc.6 = 1
   Print ";"
Elseif Substring = "PSUOFF" Then
   Portc.6 = 0
   Print ";"
Elseif Substring = "GETINFO" Then
   Print "DCNC Projekt V1.8.7 Beta"
   Print "By R212Warden"
   Print "/w Arnulf V1.1"
   Print ""
   Print "Since 09.07.15 I roll,"
   Print "Who knows will karma take the toll."
   Print "Being too good surely is bad,"
   Print "but lots of power is really rad."
   ''(
   Print "DCNC Interpteter  Copyright (C) 2016  R212Warden"
   Print "This program comes with ABSOLUTELY NO WARRANTY; for details"
   Print "refer to the manual on page ##"
   Print "This is free software, and you are welcome to redistribute it."
   Print "under certain conditions; for details refer to the manual on page ##."
   '')
   Print ";"

Elseif Substring = "SAVECOR" Then
   Xes = Xpos
   Yes = Ypos
   Zes = Zpos
Print ";"

Elseif Substring = "ZNOHEAT" Then
   Z_axis_innacuracy = 1
Print ";"

Elseif Substring = "ZHEAT" Then
   Z_axis_innacuracy = 0
   Print ";"
Elseif Substring = "ARNULF" Then
   Rapid_positioning = 1
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_normalset(dull)
   Next
   Dull = 0
   Xarea = Gx
   Yarea = Gy
   Call Arnulf_stabilize(gx , Gy )
   Wait 1
   Print ";"
Elseif Substring = "ARNON" Then
   Arnulf_enable = 1
   Print ";"
Elseif Substring = "ARNOFF" Then
   Arnulf_enable = 0
   Print ";"
Elseif Substring = "HOMEZ" Then
   Rapid_positioning = 1
   Dull = 2
   For Dull = 2 To 6 Step 1
      Call Gcode_normalset(dull)
   Next
   Dull = 0
   Call Testz(gx , Gy )
   Print Zpos

   Print ";"
Elseif Substring = "MOVS" Then
    Rapid_positioning = 1
    Xdir = Val(coms(2))
    Stpp = Val(coms(3))
    Steps = Val(coms(4))
    Call Stepper(stpp , Steps , Xdir)
    Print ";"
Elseif Substring = "ARNHELP" Then
   Print "ARNULF V1.1"
   Print "Commands:"
   Print "ARNULF [Xarea] [Yarea]"
   Print "HOMEZ [X][Y]"
   Print "ARNON"
   Print "ARNOFF"
   Print "All cordinates absulute!"
   Print "All cordinates positive!"
Elseif Substring = "$DEBUG" Then
   Print Z_deviation(1)
   Print Z_deviation(2)
   Print Z_deviation(3)
   Print Xarea
   Print Yarea
   Print Diagonal
End If
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Gx = 0
Gy = 0
Gz = 0
Radius = 0
Cx = 0
Cy = 0
Getvalcheck = 00
Rapid_positioning = 0
End Sub




Incrg_parser_done: