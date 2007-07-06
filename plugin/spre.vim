
command! -bar -range=% SPHtml call s:SPHtml(<line1>, <line2>)

function! s:SPHtml(line1, line2)
  let lines = getline(a:line1, a:line2)
  new
  call append(1, lines)
  silent 1delete _
  setl expandtab
  retab
  setl ft=spre foldmethod=syntax
  " remove comment
  folddoopen if getline('.') =~ '^[#!]\{2}' | delete _ | endif
  " convert spre text
  folddoclosed call s:DoConvert()
endfunction

function! s:DoConvert()
  call append(line('.') - 1, s:Pre(foldclosed('.'), foldclosedend('.')))
  silent execute printf("%d,%ddelete _", foldclosed('.'), foldclosedend('.'))
endfunction

function! s:Pre(start, end)
  let lines = getline(a:start + 1, a:end - 1)
  let [_0, punct, name, ft, color; _] = matchlist(getline(a:start), '\v^(.)(\w+)%(\s+(\w+))?%(\s+(\w+))?')
  return s:ToHtml(lines, name, ft, color)
endfunction

function! s:ToHtml(lines, tag, ft, color)
  let save_colors_name = get(g:, "colors_name", "")
  if a:color != ""
    execute "colorscheme " . a:color
  endif

  new         " open tmp buffer
  call append(1, a:lines)
  silent 1delete _
  let &ft = a:ft
  let null = []
  let html_use_css_save = get(g:, 'html_use_css', null)
  let html_no_pre_save = get(g:, 'html_no_pre', null)
  unlet! g:html_use_css
  unlet! g:html_no_pre
  TOhtml      " open TOhtml buffer
  if html_use_css_save isnot null
    let g:html_use_css = html_use_css_save
  endif
  if html_no_pre_save isnot null
    let g:html_no_pre = html_no_pre_save
  endif
  let [_0, bg, fg; _] = matchlist(getline(search('<body')), 'bgcolor="\([^"]*\)" text="\([^"]*\)"')
  silent 1,/<body/delete _
  silent /<\/body>/,$delete _
  silent %s@<font color="\([^"]*\)">@<span style="color: \1">@ge
  silent %s@</font>@</span>@ge
  silent %s@<br\s*/\?>@@ge
  silent %s@&nbsp;@ @ge
  let lines = getline(1, '$')
  bwipeout!   " close TOhtml buffer
  bwipeout!   " close tmp buffer

  if a:color != "" && save_colors_name != ""
    execute "colorscheme " . save_colors_name
  endif

  let class = (a:ft == "") ? "" : printf(' class="%s"', a:ft)
  let style = (a:color == "") ? "" :  printf(' style="color: %s; background-color: %s;"',fg, bg)
  let lines[0] = printf('<%s%s%s>', a:tag, class, style) . lines[0]
  let lines[-1] = lines[-1] . printf('</%s>', a:tag)
  return lines
endfunction

