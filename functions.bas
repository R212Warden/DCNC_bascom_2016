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
$include "stepper.bas"
'$include "ARNULF.bas"

Declare Sub Relative_goto(byref Gx As Long , Byref Gy As Long , Byref Gz As Long )
Declare Sub Circle1(byref Gx As Long , Byref Gy As Long , Cx As Long , Cy As Long , Radius As Long , Substring As String)
Declare Function Mmstep(byref Conves As Single) As Long
Declare Function Stepmm(byref Conves As Long) As Single
Declare Sub Gcode_normalset(byref Dull As Word)
Declare Sub Gcode_extended(byref Dull As Word)

jmp fundone

Sub Relative_goto(byref Gx As Long , Byref Gy As Long , Byref Gz As Long )

   If Gx < 0 Then Xdir = 1 Else Xdir = 0
   If Gy < 0 Then Ydir = 1 Else Ydir = 0
   If Gz < 0 Then Zdir = 1 Else Zdir = 0
   If Gx = 0 And Gy = 0 And Gz = 0 Then Jmp Norot1


   Gx = Abs(gx)
   Gy = Abs(gy)
   Gz = Abs(gz)


   If Gx = 0 And Gy = 0 Then Jmp Movz
   If Gx = 0 And Gz = 0 Then Jmp Movy
   If Gz = 0 And Gy = 0 Then Jmp Movx

   3dlenght = Gx * Gx
   3dcounter = Gy * Gy
   3dlenght = 3dlenght + 3dcounter
   3dcounter = Gz * Gz
   3dlenght = 3dlenght + 3dcounter
   Xmratio = 3dlenght
   Ymratio = Sqr(xmratio)
   3dlenght = Round(ymratio)

   Ymratio = 0
   Xmratio = 0
   Zmratio = 0
   3dcounter = 0

   If Gx > 0 Then Xmratio = Gx / 3dlenght
   If Gy > 0 Then Ymratio = Gy / 3dlenght
   If Gz > 0 Then Zmratio = Gz / 3dlenght

   For 3dcounter = 1 To 3dlenght
      Error = Error + Xmratio
      Errory = Errory + Ymratio
      Errorz = Errorz + Zmratio
      While Error >= 0.5
         Call Stepper(0 , 1 , Xdir)
         Decr Error
      Wend
      While Errory >= 0.5
         Call Stepper(1 , 1 , Ydir)
         Decr Errory
      Wend
      While Errorz >= 0.5
         Call Stepper(2 , 1 , Zdir)
         Decr Errorz
      Wend
   Next

   jmp norot1
   Movx:
      Call Stepper(0 , Gx , Xdir)
   jmp norot1
   Movy:
      Call Stepper(1 , Gy , Ydir)
   jmp norot1
   Movz:
      Call Stepper(2 , Gz , Zdir)

Norot1:
End Sub

Function Mmstep(byref Conves As Single)
   Conves = Conves * 96
   Mmstep = Round(conves)
End Function

Function Stepmm(byref Conves As Long)
   Stepmm = Conves / 96
End Function


Sub Circle1(byref Gx As Long , Byref Gy As Long , Cx As Long , Radius As Long , Substring As String )       ' (end, , center,radius(opt))
Local Tmp As Long , Tmp3 As Long
Local Alpha As Single
If Substring = "G02" Then                                   'CW
'add tmp there(ptt)
'(
Alpha = Tmp3 ^ 2
Tmp = Tmp ^ 2
Tmp = Tmp * 2
Alpha = Tmp3 - Tmp                                          ' (Tmp^3 - 2tmp^2)
Tmp = Tmp / -2
Alpha = Alpha / Tmp
Alpha = Cos(alpha)
')


Radius = Radius

Else                                                        'CCW

End If

End Sub

Sub Gcode_normalset(byref Dull As Word)
   If Left(coms(dull) , 1) = "X" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Gx = Mmstep(subval)
      Getvalcheck.0 = 1
   Elseif Left(coms(dull) , 1) = "Y" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Gy = Mmstep(subval)
      Getvalcheck.1 = 1
   Elseif Left(coms(dull) , 1) = "Z" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Gz = Mmstep(subval)
      Getvalcheck.2 = 1
   Elseif Left(coms(dull) , 1) = "S" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Spindle_speed = Subval

      Spindle_feedrate_tmp = 250000 / Spindle_speed
      Spindle_period = Spindle_feedrate_tmp

   Elseif Left(coms(dull) , 1) = "F" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Feedrate = Subval

      Spindle_feedrate_tmp = 8 * Feedrate
      Spindle_feedrate_tmp = 5 / Spindle_feedrate_tmp
      Spindle_feedrate_tmp = Spindle_feedrate_tmp * 1000000
      Feedrate = Spindle_feedrate_tmp

   End If
End Sub

Sub Gcode_extended(byref Dull As Word)
   If Left(coms(dull) , 1) = "I" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Cx = Mmstep(subval)
      Getvalcheck.3 = 1
   Elseif Left(coms(dull) , 1) = "J" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Cy = Mmstep(subval)
      Getvalcheck.4 = 1
   Elseif Left(coms(dull) , 1) = "P" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Dwell_duration = Mmstep(subval)
      Getvalcheck.6 = 1
   Elseif Left(coms(dull) , 1) = "R" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Radius = Mmstep(subval)
      Getvalcheck.7 = 1
   Elseif Left(coms(dull) , 1) = "S" Then
      Delchar Coms(dull) , 1
      Subval = Val(coms(dull))
      Spindle_speed = Subval
   End If
End Sub









Fundone: