
INCLUDE "include/graphics.inc"
INCLUDE "include/players.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

; TODO: Remove this hard-coded bank test.
SECTION "Tiber Dialogue", ROMX, BANK[2]

TiberGeneric::
    pause
    jump_if wPlayerWaitLink.tiber, wActivePlayer, \
        .waitDialogue

.followDialogue
    tiber_text .followText
    question_branch .end
    call_function PlayerSetWaitLink.tiber
    end_script

.waitDialogue
    tiber_text .waitText
    question_branch .end
    set_pointer wPlayerWaitLink.tiber, PLAYER_TIBER
.end
    end_script


.waitText
    say "What do you\n"
    say "need?\n"

    ask "Nothing.\n"
    ask "Wait here."
    end_ask

.followText
    say "Come on, let's\n"
    say "go.\n"

    ask "Not yet.\n"
    ask "Follow me."
    end_ask
