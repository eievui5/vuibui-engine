
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

; Used to finish a conversation with an ally
MACRO wait
    display_text PoppyWaitText
    question_branch :+ + 3, :+
:
    set_pointer wPoppyWaitMode, 1
    end_script
ENDM

SECTION "Poppy Dialogue", ROMX

PoppyGenericText:
    say "Yeah? You need\n"
    say "something?"
    end_text

PoppyWaitText:
    ask "Goodbye.\n"
    ask "Wait here."
    end_ask

PoppyGeneric::
    display_text PoppyGenericText
    wait