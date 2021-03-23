
INCLUDE "include/bool.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

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
    display_text PoppyWaitText
    question_branch :++, :+
:   set_pointer wPlayerWaiting.poppy, TRUE
:    end_script