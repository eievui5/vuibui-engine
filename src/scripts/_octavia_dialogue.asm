
INCLUDE "include/players.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

SECTION "Octavia Dialogue", ROMX

OctaviaGeneric::
    pause
    jump_if wPlayerWaitLink.octavia, wActivePlayer, \
        .waitDialogue

.followDialogue
    octavia_text .followText
    question_branch .end
    call_function PlayerSetWaitLink.octavia
    end_script

.waitDialogue
    octavia_text .waitText
    question_branch .end
    set_pointer wPlayerWaitLink.octavia, PLAYER_OCTAVIA
.end
    end_script


.waitText
    say "Yeah? Do you\n"
    say "need something?\n"

    ask "Nevermind.\n"
    ask "Wait here."
    end_ask

.followText
    say "Whenever you're\n"
    say "ready.\n"

    ask "Not yet.\n"
    ask "Follow me."
    end_ask