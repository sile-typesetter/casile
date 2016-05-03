highlight Double ctermbg=blue guibg=blue
highlight Single ctermbg=cyan guibg=cyan
highlight Stars ctermbg=green guibg=green
highlight Verse ctermbg=red guibg=red

call matchadd("Double", "“")
call matchadd("Double", "”")
call matchadd("Single", "‘")
call matchadd("Single", "’ ")
call matchadd("Stars", "*")
call matchadd("Verse", "_")
