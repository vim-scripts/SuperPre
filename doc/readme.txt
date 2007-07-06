
The spre (SuperPre) is a syntax plugin for the text that contains
several programing language.  The text can be converted to HTML using
2html.vim.  This is useful for writing programming notes or creating web
pages.

Installing:
  :set runtimepath+=/path/to/spre

Usage:
  To use spre syntax
  :set ft=spre

  To convert spre file to HTML
  :SPHtml

Spre Syntax:

  ## comment

  #pre [filetype] [colorscheme]
    ...
  #end

  !! comment

  !pre [filetype] [colorscheme]
    ...
  !end

Example:

## comment

#pre c
#include <stdio.h>
int main() {
  printf("hello, world\n");
  return 0;
}
#end

#pre python desert
# specifying colorscheme will effect when converting HTML.
def func():
  print "This is Python!"
#end

Please try to set filetype to 'spre' on this file.
#pre vim
  :set runtimepath+=/path/to/spre
  :set ft=spre
#end

Syntax is not updated automatically when editing file.  Set ft=spre
after adding new #pre macro.

:SPHtml command does not append <html> or other tags.  It works like a C
macro.  Example to make HTML:
<html>
<head>
<title>example</title>
</head>
<body>
<h1>Example to make HTML</h1>
## comment is removed from result.
#pre c
/* This section become <pre class="c">...</pre> */
int func(int n) {
  return func(n);
}
#end
</body>
</html>

If you want to highlight HTML tag outside of spre macro, set the
filetype to 'html' and source spre.vim.
  :set ft=html
  :unlet b:current_syntax
  :runtime syntax/spre.vim

