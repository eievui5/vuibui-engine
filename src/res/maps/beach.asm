INCLUDE "map.inc"
INCLUDE "graphics.inc"
INCLUDE "tiledata.inc"
INCLUDE "players.inc"
INCLUDE "save.inc"
INCLUDE "scripting.inc"
INCLUDE "text.inc"

INCLUDE "res/maps/beach/beach.asm"

DEF INITIAL_WAIT EQU 60
DEF PONDER_WAIT EQU 60

SECTION "Beach scripts", ROMX
xBeachGetSpellScript::
	pause

	set_pointer wScriptVars + 0, INITIAL_WAIT
:   add_pointer wScriptVars + 0, -1
    branch wScriptVars + 0, 0, :+
    jump :-
:
	display_text .entranceBlocked

	set_pointer wScriptVars + 0, PONDER_WAIT
:   add_pointer wScriptVars + 0, -1
    branch wScriptVars + 0, 0, :+
    jump :-
:
	display_text .useFire

	set_pointer wPlayerEquipped.octavia, ITEM_FIRE_WAND
	set_pointer wItems.octavia, ITEMF_FIRE_WAND
	call_function ResetHUD

	end_script

.entranceBlocked
	say "The entrance\n"
	say "to this cave\n"
	say "is blocked..."
	end_text

.useFire
	say "Maybe I can\n"
	say "use that fire\n"
	say "spell again?"
	end_text
