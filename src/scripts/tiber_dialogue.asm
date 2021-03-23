
INCLUDE "include/bool.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

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
    display_text TiberWaitText
    question_branch :++, :+
:   set_pointer wPlayerWaiting.tiber, TRUE
:    end_script