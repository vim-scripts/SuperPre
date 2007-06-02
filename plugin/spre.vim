
command! -bar -range=% SPHtml call SPHtml(<line1>, <line2>)

function! SPHtml(line1, line2)
  let lines = getline(a:line1, a:line2)
  new
  call append(0, lines)
  setl ft=spre expandtab foldmethod=syntax
  retab
  %foldclose
  let header = []
  let i = 1
  while 1
    while i <= line('$') && getline(i) !~ '^[#!]\{2}' && foldlevel(i) == 0
      let i += 1
    endwhile
    if i > line('$')
      break
    endif
    let start = i
    if getline(i) =~ '^[#!]\{2}'
      let end = i
      let lines = []
    elseif foldlevel(i) > 0
      let end = foldclosedend(i)
      let lines = s:Pre(start, end)
    endif
    call append(end, lines)
    silent! execute printf("%d,%ddelete_", start, end)
    let i = start + len(lines)
  endwhile
endfunction

function! s:Pre(start, end)
  let lines = getline(a:start + 1, a:end - 1)
  let [_0, punct, name, ft, color; _] = matchlist(getline(a:start), '\v^(.)(\w+)%(\s+(\w+))?%(\s+(\w+))?')
  return s:ToHtml(lines, name, ft, color)
endfunction

function! s:ToHtml(lines, tag, ft, color)
  let lines = a:lines
  new
  let save_colors_name = get(g:, "colors_name", "")
  if a:color != ""
    execute "colorscheme " . a:color
  endif
  call append(1, lines)
  silent! 1delete _
  let &ft = a:ft
  TOhtml
  call search('<body')
  let [_0, bg, fg; _] = matchlist(getline('.'), 'bgcolor="\([^"]*\)" text="\([^"]*\)"')
  silent! 1,/<body/delete _
  silent! /<\/body>/,$delete _
  silent! %s@<font color="\([^"]*\)">@<span style="color: \1">@g
  silent! %s@</font>@</span>@g
  silent! %s@<br\s*/\?>@@g
  silent! %s@&nbsp;@ @g
  if a:color != "" && save_colors_name != ""
    execute "colorscheme " . save_colors_name
  endif
  let lines = getline(1, '$')
  bwipeout!
  bwipeout!
  if a:ft == ""
    let class = ""
  else
    let class = printf(' class="%s"', a:ft)
  endif
  if a:color == ""
    let style = ""
  else
    let style = printf(' style="color: %s; background-color: %s;"',fg, bg)
  endif
  return [printf('<%s%s%s>', a:tag, class, style)] + lines + [printf("</%s>", a:tag)]
endfunction

