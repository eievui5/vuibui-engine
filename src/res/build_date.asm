
SECTION "Build date", ROM0

    DB "Built "
BuildDate::
    DB __ISO_8601_UTC__
    DB 0
