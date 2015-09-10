BufMRU: Switch buffers in most recently used order
==================================================

Install this plugin using:

    Plugin 'mildred/vim-bufmru'

Set the mapping:

    imap <A-B> <Esc>:BufMRUPrev<CR>
    imap <A-b> <Esc>:BufMRUNext<CR>
    map <A-B>  :BufMRUPrev<CR>
    map <A-b>  :BufMRUNext<CR>
    map <Esc>B :BufMRUPrev<CR>
    map <Esc>b :BufMRUNext<CR>

You are supposed to be able to press multiple times the Alt-B or Alt-Shift-B
key sequences to get to the next file. Like many editors have Ctrl-Tab and
Ctrl-Shift-Tab.

The list is reordered with the current buffer put in front when you make use of
that buffer. This involves moving the cursor around, changing the buffer content
or switching to and back from insert mode.

You can use this plugin with my fork of
[vim-airline](https://github.com/mildred/vim-airline/)

Note: I just learnt to use vim and created this plugin because I didn't find
anything suitable for me. This is my first vim plugin ever and can probably be
improved.
