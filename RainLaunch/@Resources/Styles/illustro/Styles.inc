[Variables]
fontName=Trebuchet MS
textSize=8
colorText=255,255,255
inputColor=0,0,0

;===== Styles =====
[styleTitle]
StringAlign=CENTER
StringCase=UPPER
StringStyle=BOLD
StringEffect=SHADOW
FontEffectColor=0,0,0,50
FontColor=#colorText#
FontFace=#fontName#
FontSize=10
AntiAlias=1
ClipString=1

[styleLeftText]
StringAlign=LEFT
StringCase=NONE
StringStyle=BOLD
StringEffect=SHADOW
FontEffectColor=0,0,0,20
FontColor=#colorText#
FontFace=#fontName#
FontSize=#textSize#
AntiAlias=1
ClipString=1

[styleSeperator]
SolidColor=255,255,255,15

;===== Meters =====
[meterBackground]
Meter=IMAGE
ImageName=#@#Styles\illustro\Background1Line.png

[meterTitle]
Meter=STRING
MeterStyle=styleTitle
X=100
Y=12
W=190
H=18
Text="Run"

[OutputMeter]
Meter=String
MeterStyle=styleLeftText
Text=#Output#
X=10
Y=40
W=190
H=14
ToolTipText=Left click to Run.#CRLF#Right click to copy output to the clipboard.
LeftMouseUpAction=!CommandMeasure InputText "ExecuteBatch 1"
RightMouseUpAction=!SetClip """#Output#"""
DynamicVariables=1

[meterSeperator]
Meter=IMAGE
MeterStyle=styleSeperator
X=10
Y=52
W=190
H=1