
SECTION "Header", ROM0[$100]
	di
	jp EntryPoint
	ds $150 - $104, 0

SECTION "Entry point", ROM0

EntryPoint:
	jp Main