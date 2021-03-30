
INCLUDE "include/players.inc"
INCLUDE "include/scripting.inc"
INCLUDE "include/text.inc"

SECTION "Tiber Dialogue", ROMX

TiberGeneric::
    compare wPlayerWaitLink.tiber, wActivePlayer, :+, :++++
:   display_text .waitText
    question_branch :++, :+
:   set_pointer wPlayerWaitLink.tiber, PLAYER_TIBER
:   end_script

:   display_text .followText
    question_branch :++, :+
:   call_function PlayerSetWaitLink.tiber
:   end_script

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