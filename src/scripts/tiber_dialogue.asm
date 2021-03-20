
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

; Used to finish a conversation with an ally
MACRO wait
    display_text TiberWaitText
    question_branch :+ + 3, :+
:
    set_pointer wTiberWaitMode, 1
    end_script
ENDM

SECTION "Tiber Dialogue", ROMX

TiberGenericText:
    say "Yeah? You need\n"
    say "something?"
    end_text

TiberWaitText:
    ask "Goodbye.\n"
    ask "Wait here."
    end_ask

TiberGeneric::
    display_text TiberGenericText
    wait