"Function: HP#ToggleCursorColumn
"Desc:
"
func! HP#ToggleCursorColumn()
  if !exists("g:cusorcolumn_existed")
    let g:cusorcolumn_existed = 0
  endif
  if g:cusorcolumn_existed
    echo 'has cursorcolumn existed, set nocursorcolumn'
    let g:cusorcolumn_existed = 0
    set nocursorcolumn
  else
    echo 'no cursorcolumn existed, set cursorcolum'
    let g:cusorcolumn_existed = 1
    set cursorcolumn
  endif
endfunc

nmap ,cl <Esc>:call HP#ToggleCursorColumn()<cr>

