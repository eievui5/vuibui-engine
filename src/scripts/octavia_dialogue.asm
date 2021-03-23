
INCLUDE "include/bool.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

SECTION "Octavia Dialogue", ROMX

OctaviaGenericText:
    say "Yeah? You need\n"
    say "something?"
    end_text

OctaviaWaitText:
    ask "Nevermind.\n"
    ask "Wait here."
    end_ask

OctaviaFollowText:
    ask "Not yet.\n"
    ask "Follow me."
    end_ask

OctaviaGeneric::
    display_text OctaviaGenericText
    ; TODO: implement a `goto` script function
    branch wPlayerWaiting.octavia, :+, :++++
:   display_text OctaviaWaitText
    question_branch :++, :+
:   set_pointer wPlayerWaiting.octavia, TRUE
:   end_script

:    display_text OctaviaFollowText
    question_branch :++, :+
:   set_pointer wPlayerWaiting.octavia, FALSE
:   end_script