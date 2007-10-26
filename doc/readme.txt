
The spre (SuperPre) is a syntax plugin for the text that contains several
programing language.  The text can be converted to HTML.  This is useful for
writing programming notes or creating web pages.

Installation:
  :set runtimepath+=/path/to/spre

Usage:
  To use spre syntax
    :set ft=spre

  To convert spre file to HTML
    :SPHtml

  To convert non spre (normal) file to HTML
    :SPToHtml
  (<html> header is not added)

Spre Syntax:

  ## comment

  #pre [filetype] [attr]
    ...
  #end

  #macro
    vim script
  #end

  !! comment

  !pre [filetype] [attr]
    ...
  !end

  !macro
    vim script
  !end

  #macro block is executed when converting HTML.  This block is executed as
  function and the block is replaced with the result of the function.  The
  result should be string or list.  If no value is returned, block is just
  deleted.  #macro block can also be used to create attr dictionary for #pre
  block.

  [attr] is VimL dictionary, used for HTML conversion.
  Following key can be used:
    'macro' : function()
      Preprocessor for this block.
      Used as "call attr.macro()" in the temporary block buffer.

    'tag' : 'name'    (default 'pre')
      Tag name for this block.

    'colorscheme' : 'name'
      Used as "execute 'colorscheme ' . name"

    'modeline' : 'options'
      Used as "execute 'setl ' . options".
      e.g. {'modeline':'list number'}

    'point' : [[lnum, vcol, width, hlname], ...]
      Highlight the character (e.g. for Cursor).  "width" is width of beam
      cursor (vertical line).  0 for block cursor.
      e.g. {'point':[[3,4,2,"Cursor"]]} (2px)
           {'point':[[3,4,0,"Cursor"]]} (block)

    'class' : 'css class' (default 'filetype')
      Class attribute for this tag.

    'filetype' : 'filetype' [readonly]
      This attribute is set by spre.

Example:

## comment

#pre c
#include <stdio.h>
int main() {
  printf("hello, world\n");
  return 0;
}
#end

#pre python {"colorscheme":"desert"}
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
#macro
" You can use Vim script as embedded macro.
return "<h1>Example to make HTML</h1>"
#end

## comment is removed from result.

#pre c {"colorscheme":"evening"}
/* This section will be <pre class="c">...</pre> */
int func(int n) {
  return func(n);
}
#end

#macro
let s:attr = {}
let s:attr.colorscheme = "desert"
let s:attr.tag = "div"
let s:attr.class = "c main"
let s:attr.modeline = "list number"
#end
#pre c s:attr
/* This section will be <div class="c main">...</div> */
int main(int argc, char **argv) {
  return 0;
}
#end

#macro
return readfile(expand("%:p:h") . "/footer.txt")
#end
</body>
</html>

If you want to highlight HTML tag outside of spre macro:
  :set ft=html.spre
Spre will work as additional syntax.

