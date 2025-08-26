" vim: et ts=2 sw=0 fdm=marker

" Basic settings {{{
colorscheme CandyPaper

set autochdir
set cindent
set clipboard=unnamed,unnamedplus
set cursorline number signcolumn=number
set expandtab tabstop=4 shiftwidth=0
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,gbk,gb18030,euc-jp,latin1
set fileformat=unix fileformats=unix,dos
set modeline
set scrolloff=5 sidescrolloff=20
set showtabline=2
set termguicolors
" __[option(windows)]__
"
" set shell=zsh.exe shellcmdflag=-c
" set winaltkeys=no
" __end__

let g:is_bash = 1

function s:jumpToLastPosition()
  let lastLine = line("'\"")
  if lastLine > 0 && lastLine <= line('$')
    normal! g`"
  endif
endfunction
autocmd BufReadPost * call s:jumpToLastPosition()
" }}}

" Status Line {{{
let s:EDITOR_MODE_TEXTS = {
      \ 'n': 'NORMAL',
      \ 'v': 'VISUAL',
      \ 'V': 'V-LINE',
      \ '': 'V-BLOCK',
      \ 'i': 'INSERT',
      \ 'R': 'REPLACE',
      \ 'c': 'COMMAND',
      \ }
function! s:editorModeText()
  let mode = mode()
  return s:EDITOR_MODE_TEXTS->get(mode(), 'MODE:' .. mode)
endfunction

function! s:cursorCharacterIndex()
  let column = getcurpos()[2]
  return strchars(strpart(getline('.'), 0, column-1)) + 1
endfunction

let s:SID = expand('<SID>')
function! s:customStatusLine()
  " FullFilePath
  return '%F %h%r%m%=' ..
        \ '[%l:%{' .. s:SID .. 'cursorCharacterIndex()}][%4.P]  ' ..
        \ '%y[%{&fenc}|%{&ff}]' ..
        \ '%10.([%{' .. s:SID .. 'editorModeText()}]%)'
endfunction

let &statusline = '%!' .. s:SID .. 'customStatusLine()'
" }}}

" Keymaps {{{
nnoremap Y y$
vnoremap <c-c> y
vnoremap p "_dgP
vnoremap P "_dgP
nnoremap <c-v> gP
vnoremap <c-v> "_dgP
inoremap <c-v> <c-r>+

nnoremap <silent><c-s> :update<cr>
inoremap <silent><c-s> <c-o>:update<cr>

nmap <up> gk
vmap <up> gk
imap <up> <c-o>gk
nmap <down> gj
vmap <down> gj
imap <down> <c-o>gj

vnoremap S <plug>Sneak_S
onoremap s <plug>Sneak_s
onoremap S <plug>Sneak_S

map <leader> <plug>(easymotion-prefix)
nnoremap <leader>s <plug>(easymotion-f2)
vnoremap <leader>s <plug>(easymotion-f2)
nnoremap <leader>S <plug>(easymotion-F2)
vnoremap <leader>S <plug>(easymotion-F2)

nnoremap <silent><f3> :NERDTreeToggle<cr>

nnoremap <silent><f4> :tabnew<cr>

nnoremap <silent><f12> :sp<cr><c-w>j:term<cr>
tnoremap <esc> <c-\><c-n>

function s:toggleWrap()
  if &wrap
    echo 'wrap = off'
    set nowrap
  else
    echo 'wrap = on'
    set wrap
  endif
endfunction
nnoremap <silent><m-z> :call <sid>toggleWrap()<cr>
" }}}

" Environment-dependent Overrides {{{
if exists('g:neovide')
  " __[option(windows)]__
  " set guifont=Fira\ Code\ Retina,Noto\ Sans\ SC:h11
  " __end__
  " __[option(linux)]__
  " set guifont=Fira\ Code\ Retina,Noto\ Sans\ CJK\ SC:h11
  " __end__
endif

if exists('g:vscode')
  set cmdheight=5
  set statusline=%F

  nmap j gj
  nmap k gk

  lua << EOF
    local vscode = require('vscode')
    local function mapToVscodeCall(key, cmd)
      vim.keymap.set('n', key, function() vscode.call(cmd) end, { silent = true })
    end
    mapToVscodeCall('zc', 'editor.fold')
    mapToVscodeCall('zo', 'editor.unfold')
    mapToVscodeCall('zC', 'editor.foldRecursively')
    mapToVscodeCall('zO', 'editor.unfoldRecursively')
    mapToVscodeCall('zM', 'editor.foldAll')
    mapToVscodeCall('zR', 'editor.unfoldAll')
EOF
endif
" }}}
