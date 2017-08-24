BufMRU: Switch buffers in most recently used order
==================================================

Install this plugin using:

    Plug 'mildred/vim-bufmru'

Set the mapping:

    " Alt-B or Alt-Shift-B to navigate buffers in insert mode and normal mode
    imap <A-B> <C-O>:BufMRUPrev<CR>
    imap <A-b> <C-O>:BufMRUNext<CR>
    map <A-B> :BufMRUPrev<CR>
    map <A-b> :BufMRUNext<CR>
    nmap <Esc>B :BufMRUPrev<CR>
    nmap <Esc>b :BufMRUNext<CR>

    " Key above escape (on french keyboards) to commit current buffer as last
    " used
    map ² :BufMRUCommit<CR>

    " Tab and Shift-Tab in normal mode to navigate buffers
    map <Tab> :BufMRUNext<CR>
    map <S-Tab> :BufMRUPrev<CR>

You are supposed to be able to press multiple times the Alt-B or Alt-Shift-B
key sequences to get to the next file. Like many editors have Ctrl-Tab and
Ctrl-Shift-Tab.

The list is reordered with the current buffer put in front when you make use of
that buffer. This involves moving the cursor around, changing the buffer content
or switching to and back from insert mode.

This plugin works with [vim-airline](https://github.com/vim-airline/vim-airline/)
and has a very nice plugin for [lightline.vim](https://github.com/itchyny/lightline.vim/).

Don't forget this is a vim plugin and everything is in the documentation
[`:help bufmru.txt`](doc/bufmru.txt).

Note: I just learnt to use vim and created this plugin because I didn't find
anything suitable for me. This is my first vim plugin ever and can probably be
improved.

Hacking
=======

Regenerate documentation tags:

    :helptags doc
