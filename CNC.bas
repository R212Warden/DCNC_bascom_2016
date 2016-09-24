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

Config Pind.0 = Input
Config Portd.1 = Output
Config Portd.5 = Output
Config Portd.4 = Output
Config Pind.0 = Input

Config Portd.2 = Input                                      'int0
Config Portd.3 = Output                                     'output cts signal, uC is DCE
Cts Alias Portd.3
Rts Alias Portd.2

Config Timer1 = Pwm , Pwm = 10 , Compare A Pwm = Clear Up , Prescale = 64
Compare1a = 1024


Enable Interrupts
Disable Icp1
On Icp1 Speed_regulation

$include "stepper.bas"
$include "incrg_parser.bas"
$include "values.bas"
$include "functions.bas"
$include "ARNULF.bas"

Arnulf_enable = 1
Xpos = Xes
Ypos = Yes
Zpos = Zes

''(
Z_deviation(1) = 34
Z_deviation(2) = 25
Z_deviation(3) = -39
Xarea = 9600
Yarea = 9600
Diagonal = 13576
'')

Spindle_speed = 3000                                        'rpm
Feedrate = 3125                                             '200 mm/min

Config Serialin = Buffered , Size = 24 , Bytematch = 13

Print "Ready"

Do
If _interpret = 1 Then
   cli
   Clear Serialin
   Delchars Command , 13
   If _echo = 1 Then Print Command
   Interpret Command
   If Z_axis_innacuracy = 1 Then
      S3a = 0
      S3b = 0
      S3c = 0
      S3d = 0
   End If
   Command = ""
   Reset _interpret
   'Waitms 100
   Print "%"
   sei
   Cts = 0
End If
Waitms 50
Loop
End


Speed_regulation:

If Spindle_period > Icr1 And Compare1a > 170 Then
   Compare1a = Compare1a + 5
End If

If Spindle_period < Icr1 And Compare1a < 1000 Then
   Compare1a = Compare1a - 5
End If

Return

Serial0charmatch:
Dull2 = 1
Cts = 1
For Dull2 = 1 To _rs_bufcountr0
   Commandtmp = Chr(_rs232inbuf0(dull2))
   Command = Command + Commandtmp
Next
Dull2 = 0
Set _interpret
Return