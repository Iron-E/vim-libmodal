let s:barModeCombos = {
\	'zf': 'split',
\	'zfo': 'vsplit',
\	'zfc': 'tabnew'
\}

echom '.' | echom '.' | echom '.' | echom '.' | echom '.' | echom '.' | echom '.'
call libmodal#Enter('BAR', s:barModeCombos)
