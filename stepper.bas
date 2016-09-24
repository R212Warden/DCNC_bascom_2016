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
$include "values.bas"

Config Porta = Output
Config Portc = Output

S1a Alias Porta.0
S1b Alias Porta.1
S1c Alias Porta.2
S1d Alias Porta.3

S2a Alias Porta.4
S2b Alias Porta.5
S2c Alias Porta.6
S2d Alias Porta.7

S3a Alias Portc.0
S3b Alias Portc.1
S3c Alias Portc.2
S3d Alias Portc.3

Declare Sub Stepper(byval Stpp As Byte , Byval Steps As Long , Byval Dirc As Byte)


jmp stepper_done


Sub Stepper(byval Stpp As Byte , Byval Steps As Long , Byval Dirc As Byte)
If Steps = 0 Then Jmp Norot

Do
If Dirc = 0 Then
   If Stpp = 0 Then
      If Mc1 = 1 Then
         Rotate Halfstep1a , Left
      Else
         Rotate Halfstep1b , Left
      End If
      Halfstep1 = Halfstep1a And Halfstep1b
      S1a = Halfstep1.0
      S1b = Halfstep1.1
      S1c = Halfstep1.2
      S1d = Halfstep1.3
      Incr Xpos
      Toggle Mc1
   Elseif Stpp = 1 Then
      If Mc2 = 1 Then
         Rotate Halfstep2a , Left
      Else
         Rotate Halfstep2b , Left
      End If
      Halfstep2 = Halfstep2a And Halfstep2b
      S2a = Halfstep2.0
      S2b = Halfstep2.1
      S2c = Halfstep2.2
      S2d = Halfstep2.3
      Incr Ypos
      Toggle Mc2
   Elseif Stpp = 2 Then
      If Mc3 = 1 Then
         Rotate Halfstep3a , Left
      Else
         Rotate Halfstep3b , Left
      End If
      Halfstep3 = Halfstep3a And Halfstep3b
      S3a = Halfstep3.0
      S3b = Halfstep3.1
      S3c = Halfstep3.2
      S3d = Halfstep3.3
      Incr Zpos
      Toggle Mc3
   End If
Else
   If Stpp = 0 Then
      If Mc1 = 0 Then
         Rotate Halfstep1a , Right
      Else
         Rotate Halfstep1b , Right
      End If
      Halfstep1 = Halfstep1a And Halfstep1b
      S1a = Halfstep1.0
      S1b = Halfstep1.1
      S1c = Halfstep1.2
      S1d = Halfstep1.3
      Decr Xpos
      Toggle Mc1
   Elseif Stpp = 1 Then
      If Mc2 = 0 Then
         Rotate Halfstep2a , Right
      Else
         Rotate Halfstep2b , Right
      End If
      Halfstep2 = Halfstep2a And Halfstep2b
      S2a = Halfstep2.0
      S2b = Halfstep2.1
      S2c = Halfstep2.2
      S2d = Halfstep2.3
      Decr Ypos
      Toggle Mc2
   Elseif Stpp = 2 Then
      If Mc3 = 0 Then
         Rotate Halfstep3a , Right
      Else
         Rotate Halfstep3b , Right
      End If
      Halfstep3 = Halfstep3a And Halfstep3b
      S3a = Halfstep3.0
      S3b = Halfstep3.1
      S3c = Halfstep3.2
      S3d = Halfstep3.3
      Decr Zpos
      Toggle Mc3
   End If
End If

If Rapid_positioning = 1 Then Waitus 3125 Else Waitus Feedrate

Decr Steps
If Steps = 0 Then Exit Do
Loop
Norot:
End Sub

Stepper_done: