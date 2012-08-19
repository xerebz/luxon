;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
WinWait, Guild Wars, 
IfWinNotActive, Guild Wars, , WinActivate, Guild Wars, 
WinWaitActive, Guild Wars,
Send u
Sleep 500
Send {wheelup 5}
Send u
Sleep 500

;FileDelete, threshfail\*.*
FileDelete, debug.log
cashExpected := 0
factionExpected := 0
OnExit, ExitSub

Loop
{
;----
;main loop
;----
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Begin Farm Loop.`n, debug.log
;dump faction every 25 run attempts
Loop 25
{
WinWait, Guild Wars, 
IfWinNotActive, Guild Wars, , WinActivate, Guild Wars, 
WinWaitActive, Guild Wars, 
gosub, Farm
cashExpected += 150
factionExpected += 800
}
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Begin Farm Submit.`n, debug.log
gosub, SubmitFaction
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Begin Spawn Reset.`n, debug.log
gosub, ResetSpawn
;gosub, EmptyRunDebug
}


;----
;this function farms for luxon faction in archipelagos
;----

Farm:
{

;----
;get into archipelagos
;----

;walk back into portal
Send {s 2}q

;wait for map to settle
Sleep 5000 

;----
;setup for run
;----

;item spell prep
MouseClick, left,  261,  403
MouseClick, left,  262,  501
MouseClick, left,  260,  588
MouseClick, left,  269,  687
MouseClick, left,  259,  792
Sleep 500

;cast recall
Send /8
Sleep 500


;----
;start of run
;----

;open minimap
Send u
Sleep 500
Send {wheelup}

;send heroes up ramp
Send x
Sleep 500
MouseClick, left,  875,  331

;close minimap
Send u

;"Fall Back!" timer
Send 0
SetTimer, Fallback, 20000

;watchful intervention
Send 2
Sleep 1500
Send q

;prevent offensive spellcast
MouseClick, left,  262,  273
MouseClick, left,  255,  370
MouseClick, left,  259,  466
MouseClick, left,  260,  561
MouseClick, left,  258,  662
MouseClick, left,  256,  758

;"Incoming!" timer
Sleep 9000
Send {;}
SetTimer, Incoming, 20000

;wait for heroes to get up ramp
Sleep 2250

Send u
Sleep 500
;try one juke
Send x
Sleep 500
MouseClick, left,  798,  373
Send u


;----
;manage healing until recall triggers
;----

;wait for them to get to the hard part
Sleep 2500

;wait for hardest part to party heal
Sleep 3000
Send -1

;wait for heroes to be close enough
Sleep 750

;send heroes to base of cliff
Send u
Sleep 500
Send x
Sleep 500
MouseClick, left,  637,  238
;send frozen soil carrier to a safer location
Send j
Sleep 500
MouseClick, left,  671,  236
Send u

;dwarven stability
Sleep 7000
Send 6

;pious renewal, pious haste
Sleep 1000
Send 57

;wait for recall to trigger
Sleep 1750

;----
;get to quest giver, set up for the fight
;----

;follow heroes to base of cliff
Loop 26
{
Send {space}
Sleep 500
}

;stop speed boost timers
gosub, Speedboosts_off

;make haste
Send ]

;open minimap
Send u

;send the hero to follow up the cliff
Send o
Sleep 500
MouseClick, left,  739,  423

;send heroes to the arena
Send x
Sleep 500
MouseClick, left,  832,  408

;close minimap
Send u

;pious renewal, pious haste
Send 57

;follow hero up the cliff
Loop 30
{
Send {space}
Sleep 500
}

;edge of extinction
Send {[}

;open minimap
Send u

;send norgu back to the arena
Send o
Sleep 500
MouseClick, left,  886,  436

;close minimap
Send u

;speed boost norgu, prep panic
Send '{Insert}

;generous was tsungrai
MouseClick, left,  261,  403
MouseClick, left,  262,  501
MouseClick, left,  260,  588
MouseClick, left,  269,  687
MouseClick, left,  259,  792

;pious haste, renewal up ramp
Send q57
Sleep 1000

;fire attunement
MouseClick, left,  64,  410
MouseClick, left,  58,  497
MouseClick, left,  59,  603
MouseClick, left,  60,  689
MouseClick, left,  57,  787
Sleep 2000

;aura of restoration
MouseClick, left,  202,  787
MouseClick, left,  201,  692
MouseClick, left,  202,  595
MouseClick, left,  202,  503
MouseClick, left,  201,  400

;make sure frozen soil is down
Send {=}
;finish going up ramp
Sleep 2750

;talk to quest giver
Send .3
Sleep 750

Send {space}

;allow offensive spellcast
MouseClick, left,  205,  271
MouseClick, left,  208,  378
MouseClick, left,  209,  470
MouseClick, left,  204,  567
MouseClick, left,  202,  654
MouseClick, left,  207,  755

;glyph of immolation prep
;MouseClick, left,  112,  311
MouseClick, left,  117,  397
MouseClick, left,  123,  505
MouseClick, left,  115,  601
MouseClick, left,  115,  693
MouseClick, left,  114,  790
Sleep 1000

;----
;battle
;----

;start quest
MouseClick, left,  762,  544

;shroud of distress (protect from oni)
Send 4

;follow quest giver for 15 seconds
questDone := 0
SetTimer, questDoneCheck, 500
Sleep 250
Loop 55
{
	if questDone {
		break
	}
	Send {space}
	Sleep 500
}
if questDone {
	FormatTime, TimeString, T12, Time
	FileAppend, [%TimeString%] We found Accept: %Haystack2%, debug.log
} else {
	FormatTime, TimeString, T12, Time
	FileAppend, [%TimeString%] We ran out of time.`n, debug.log
}
SetTimer, questDoneCheck, off

;----
;end of run
;----

;accept reward
MouseClick, left,  784,  532
Sleep 500

;repeat until accepted
Loop
{
Haystack := GetOCR(720,527,50,20,"activeWindow")
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Expected "Accept": OCR returned %Haystack%, debug.log
;if InStr(Haystack, "threshold") {
;	FormatTime, TimeString,, hhmmss
;	FileCopy, in.jpg, threshfail\in%TimeString%.jpg
;}
if !Haystack OR InStr(Haystack, "cc")
	MouseClick, left,  784,  532
else
{
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] We broke on %Haystack%, debug.log
break
}
Sleep 500
}

;resign
Send {enter}/resign{enter}
Sleep 2500
;close any blocking windows
MouseClick, left,  918,  299
Sleep 250
MouseClick, left,  916,  318
Sleep 250
MouseClick, left,  918,  300
Sleep 500
MouseClick, left,  763,  458
Sleep 4500

}
return







SubmitFaction:
{
;----
;this function goes to eredon, dumps all the faction, and returns to jade flats
;----

;go to eredon terrace
Send m
Sleep 2000
MouseClick, left,  1082,  404
Sleep, 1500
MouseClick, left,  1082,  404
Sleep, 1500
MouseClick, left,  1082,  404
Sleep, 1500
MouseClick, left,  891,  669
Sleep 7000

;go to faction rewarder
Send 9{space}
Sleep 5000
Send .{space}
Sleep 5000

;if anything fails, don't allchat
Send {#}{enter}
Sleep 1000

Haystack := GetOCR(674,  263, 135,  20, "activeWindow")
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Expecting 'Luxon': OCR returned %Haystack%, debug.log
IfInString, Haystack, Luxon
{
	;turn in faction
	MouseClick, left,  778,  545
	Sleep 500
	Haystack := GetOCR(574,  376, 170,  17, "activeWindow")
	IfInString, Haystack, Loyalty
	{
		MouseClick, left,  690,  500
		Sleep 500
		Send, Exergic{SPACE}Pan
		Sleep 500
		Loop
		{
			Haystack := GetOCR(574,  376, 170,  17, "activeWindow")
			FormatTime, TimeString, T12, Time
			FileAppend, [%TimeString%] Expecting 'Loyalty': OCR returned %Haystack%, debug.log
			IfNotInString, Haystack, Loyalty, break
			MouseClick, left,  871,  648
			Sleep 500
		}
	}
}

;go back to jade flats
Sleep 2000
Send m
Sleep 2000
MouseClick, left,  1196,  424
Sleep, 1500
MouseClick, left,  1008,  488
Sleep, 1500
MouseClick, left,  909,  415
Sleep, 1500
MouseClick, left,  707,  678
Sleep 9000
}
Return







ResetSpawn:
{
;----
;this function uses an OCR library to go towards archipelagos, then reset the spawn
;----

;try first flag post
Send 9
#Include OCR.ahk
Sleep 750
fuckedUp := 0 
Loop {
Haystack := GetOCR(721,  51, 146,  13, "activeWindow")
if Haystack
	break
fuckedUp++
if fuckedUp > 20
	{
		FileAppend, [%TimeString%] We done gone 'head and fucked up.`n, debug.log
		break
	}
FileAppend, [%TimeString%] Warning: Reset spawn OCR was blank.`n, debug.log
}
if Haystack contains h,s,ga,pel,el,ip,ch,a5
{
;debug log, save all matches
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Expecting 'Archipelagos': OCR returned %Haystack%, debug.log
;if it matched, this is the right pole, go to it
Send {space}
Sleep 10000
}
else if Haystack contains M,ng,H
{
	;go back to jade flats
	FileAppend, [%TimeString%] Got stuck in Eredon, headed to Jade Flats`n, debug.log
	Sleep 2000
	Send m
	Sleep 2000
	MouseClick, left,  1196,  424
	Sleep, 1500
	MouseClick, left,  1008,  488
	Sleep, 1500
	MouseClick, left,  909,  415
	Sleep, 1500
	MouseClick, left,  707,  678
	Sleep 9000
	gosub, ResetSpawn
}
else
{
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Expecting 'The Jade Quarry': OCR returned %Haystack%, debug.log
;assuming it failed,  go to the other flag
Send 9{space}
Sleep 15000
}

;point camera towards flag
Send {d down}
Send {d up}
Sleep 50
Send {d down}
Send {d up}
Sleep 250

;turn to the right a bit
Send {d down}
Sleep 700
Send {d up}

;go out to archipelagos
Send q
Sleep 7000

;go back to jade flats to reset the spawn
Send {s 2}q
Sleep 7000
}
return

EmptyRunDebug:
{
;walk back into portal
Send {s 2}q

;wait for map to settle
Sleep 8500

;resign
MouseClick, left,  918,  299
Send {enter}/resign{enter}
Sleep 4000
MouseClick, left,  763,  458
Sleep 7000
}
return





Speedboosts_off:
 {
   settimer, Fallback, off
   settimer, Incoming, off
}
return

;"Fall Back!"
Fallback:
 {
   Send 0
 }
return

;"Incoming!"
Incoming:
 {
   Send {;}
 }
return

questDoneCheck:
 {
   Haystack2 := GetOCR(720,527,50,15,"activeWindow")
	IfInString, Haystack2, cc
	{
		questDone := 1
	}
 }
return

ExitSub:
FormatTime, TimeString, T12, Time
FileAppend, [%TimeString%] Cash Expected: %cashExpected%g`n, debug.log
FileAppend, [%TimeString%] Faction Expected: %factionExpected%`n, debug.log
ExitApp