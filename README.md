BufMRU: Switch buffers in most recently used order
==================================================

Install this plugin using:

    Plugin 'mildred/vim-bufmru'

Set the mapping:

    map <A-B>  :BufMRUPrev<CR>
    map <A-b>  :BufMRUNext<CR>
    map <Esc>B :BufMRUPrev<CR>
    map <Esc>b :BufMRUNext<CR>

You are supposed to be able to press multiple times the Alt-B or Alt-Shift-B
key sequences to get to the next file. Like many editors have Ctrl-Tab and
Ctrl-Shift-Tab.

Sometimes, it doesn't work as the new file you switch to is pushed to the
beginning of the list before you can continue to the next element of the list.

You can use this plugin with my fork of
[vim-airline](https://github.com/mildred/vim-airline/)

