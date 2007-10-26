
" Do not check b:current_syntax, so that spre can be combined with other
" syntax (e.g. set ft=html.spre)
" if exists("b:current_syntax")
"   finish
" endif

let s:cpo_save = &cpo
set cpo&vim

function! s:Setup()
  if exists("b:current_syntax")
    let current_syntax_save = b:current_syntax
  endif

  hi link MacroTag Macro
  hi link MacroComment Comment

  " comment
  syntax match MacroComment /^[#!]\{2}.*$/

  let syn_list = {}
  let syn_list["spre"] = 1
  let syn_list["vim"] = 1
  let loaded = {}

  let pos = getpos('.')
  silent g/\v^[#!]%(pre)\s+\w+>/let syn_list[matchstr(getline('.'), '\v^[#!]%(pre)\s+\zs[0-9A-Za-z_.]+>')] = 1
  call setpos('.', pos)

  " pre
  syntax region MacroPre matchgroup=MacroTag start=/\v^\z([#!])%(pre)>.*$/ end=/^\z1end\>/ keepend extend fold
  for syn in keys(syn_list)
    let group = []
    for ft in split(syn, '\.')
      if ft == "spre"
        call extend(group, ["MacroComment", "MacroPre", "MacroSpre"])
      elseif !has_key(loaded, ft)
        unlet! b:current_syntax
        silent! execute printf('syntax include @G%s syntax/%s.vim', ft, ft)
        call add(group, "@G" . ft)
        let loaded[ft] = 1
      endif
    endfor
    execute printf('syntax region MacroPre matchgroup=MacroTag start=/\v^\z([#!])%(pre)\s+%s>.*$/ end=/^\z1end\>/ contains=%s keepend extend fold', escape(syn, "."), join(group, ","))
  endfor

  " macro
  syntax region MacroPre matchgroup=MacroTag start=/\v^\z([#!])%(macro)>.*$/ end=/^\z1end\>/ contains=@Gvim keepend extend fold

  let b:current_syntax = "spre"

  if exists("current_syntax_save")
    let b:current_syntax = current_syntax_save
  endif
endfunction

call s:Setup()

let &cpo = s:cpo_save
unlet s:cpo_save

