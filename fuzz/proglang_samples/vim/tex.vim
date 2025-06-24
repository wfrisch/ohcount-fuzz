" simple LaTeX ftplugin: problem: mappings only work if filedir = workdir
if exists("b:did_my_tex_ftplugin")
  finish
endif
let b:did_my_tex_ftplugin = 1

let b:tex_flavor = 'pdflatex'
compiler tex

" map <F3> :w<CR>:!pdflatex %<CR>
" map <F4> :w<CR>:!evince %<.pdf &<CR>

setlocal makeprg=pdflatex\ \-file\-line\-error\ \-interaction=nonstopmode\ $*\\\|\ grep\ \-E\ '\\w+:[0-9]{1,4}:\\\ '
setlocal errorformat=%f:%l:\ %m
map <buffer> <F3> :w<CR>:make %<<CR>
map <buffer> <F4> :!evince %<.pdf &<CR>

