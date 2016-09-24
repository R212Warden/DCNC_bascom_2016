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
$include "stepper.bas"
$include "values.bas"
$crystal = 16000000
$hwstack = 280
$swstack = 280
$framesize = 280
$baud = 38400

Dim Xstab As Long , Ystab As Long , Zstab As Long
Dim Xarea As Long , Yarea As Long
Dim Z_deviation(3) As Long
Dim Diagonal As Long , Tmp As Single

'*******************************************************************************
'This function knows 4 points that define polygon projected onto the workarea.
'Polygon is divided onto 2 parts, of which every has unique inclination,
'Function returns height of Z axis on cordinates Xstab,Ystab
'Problem appears to be passing from one plane to another, later about that...    :/
'*******************************************************************************

Declare Sub Arnulf_stabilize(byval Xarea As Long , Byval Yarea As Long)
Declare Sub Testz(byval Gx As Long , Byval Gy As Long)
Declare Function Arnulfize(byval Xstab As Long , Byval Ystab As Long , Byval Zstab As Long) As Long
Declare Sub Relocate(byval Stpp As Byte , Byval Steps As Long , Byval Dirc As Byte)
Config Portc.7 = Input

jmp ARNULF_done:

Macro Probe
While Pinc.7 = 1
   Call Stepper(2 , 1 , 1)
Wend
End Macro



Sub Arnulf_stabilize(byval Xarea As Long , Byval Yarea As Long)

Probe
Zpos = 0

Call Stepper(2 , 480 , 0)
Call Relocate(0 , Xarea , 0)

Probe
Z_deviation(1) = Zpos

Call Stepper(2 , 480 , 0)
Call Relocate(1 , Yarea , 0)

Probe
Z_deviation(2) = Zpos

Call Stepper(2 , 480 , 0)
Call Relocate(0 , Xarea , 1)

Probe
Z_deviation(3) = Zpos

Call Stepper(2 , 480 , 0)
Call Relocate(1 , Yarea , 1)

Diagonal = Xarea ^ 2
Yarea = Yarea ^ 2
Diagonal = Diagonal + Yarea
Tmp = Diagonal
Tmp = Sqr(tmp)

Diagonal = Tmp

Print "Plane cors:"
 Print Z_deviation(1)
 Print Z_deviation(2)
 Print Z_deviation(3)

End Sub

Sub Relocate(byref Stpp As Byte , Byref Steps As Long , Byref Dirc As Byte)
For Dull = 1 To Steps
   Call Stepper(stpp , 1 , Dirc)
   If Pinc.7 = 0 Then Call Stepper(2 , 480 , 0)
Next
Dull = 0
End Sub


Sub Testz(byref Gx As Long , Byref Gy As Long)
If Gx < 0 Then
   Gx = Gx * -1
   Xdir = 1
Elseif Gy < 0 Then
   Gy = Gy * -1
   Ydir = 1
End If

Call Relocate(0 , Xarea , Xdir)
Call Relocate(1 , Yarea , Ydir)
Probe

End Sub


Function Arnulfize(byval Xstab As Long , Byval Ystab As Long , Byval Zstab As Long) As Long

'*******************************************************************************
'This function knows 4 points that define polygon projected onto the workarea.
'Polygon is divided onto 2 parts, of which every has unique inclination.
'Function returns height of Z axis on cordinates Xstab,Ystab.
'Problem appears when passing from one plane to another, later about that...    :/
'*******************************************************************************
Dim Stb As Long , Iks As Single

If Xstab = Ystab Then                                       'Intersection line between 2 planes

Stb = Xstab * Ystab
Stb = Stb * 2
Tmp = Stb
Tmp = Sqr(tmp)
Stb = Tmp

Tmp = Z_deviation(2) / Diagonal
Tmp = Tmp * Stb
Tmp = Round(tmp)
Tmp = Tmp + Zstab
Arnulfize = Tmp

Elseif Xstab > Ystab Then                                   'Plane near abscissa

Tmp = Z_deviation(1) * Xstab
Tmp = Tmp / Xarea

Iks = Z_deviation(1) - Z_deviation(2)
Iks = Iks * Ystab
Iks = Iks / Yarea

Tmp = Tmp - Iks
Tmp = Round(tmp)
Tmp = Tmp + Zstab
Arnulfize = Tmp

Elseif Ystab > Xstab Then                                   'Plane near ordinate

Tmp = Z_deviation(3) * Ystab
Tmp = Tmp / Yarea

Iks = Z_deviation(3) - Z_deviation(2)
Iks = Iks * Xstab
Iks = Iks / Yarea

Tmp = Tmp - Iks
Tmp = Round(tmp)
Tmp = Tmp + Zstab
Arnulfize = Tmp

End If
End Function




























Arnulf_done: