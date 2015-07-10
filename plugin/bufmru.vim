" Reload and Compatibility Guard {{{1
" ============================================================================
" Reload protection.
if (exists('g:did_bufmru') && g:did_bufmru) || &cp || version < 700
    finish
endif
let g:did_bufmru = 1

" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" 1}}}


let s:bufmru_files = {}
let s:bufmru_entertime = reltime()

function! BufMRU_sort(b1, b2)
	let t1 = str2float(reltimestr(BufMRUTime(a:b1)))
	let t2 = str2float(reltimestr(BufMRUTime(a:b2)))
	return t1 == t2 ? 0 : t1 > t2 ? -1 : 1
endfunction

function! BufMRU_enter()
	let s:bufmru_entertime = reltime()
endfunction

function! BufMRU_leave()
	let totaltime = reltime(s:bufmru_entertime)
	let buf = bufnr("%")
	if totaltime[0] >= 1
		let s:bufmru_files[buf] = s:bufmru_entertime
	endif
endfunction

function! BufMRUTime(bufn)
	return has_key(s:bufmru_files, a:bufn) ? s:bufmru_files[a:bufn] : [0,0]
endfunction

function! BufMRUList()
	let bufs = range(1, bufnr("$")) "keys(s:bufmru_files)
	call sort(bufs, "BufMRU_sort")
	return bufs
endfunction

function! BufMRUShow()
	call BufMRU_leave()
	let bufs = BufMRUList()
	for buf in bufs
		let bufn = bufname(str2nr(buf))
		let buft = reltimestr(reltime(BufMRUTime(buf)))
		echom buf " | " buft "s | " bufn
	endfor
endfunction

function! BufMRUGo(inc)
	let list = BufMRUList()
	let i = list[(index(list, bufnr("%")) + a:inc) % len(list)]
	execute "buffer" i
endfunction

autocmd BufEnter * call BufMRU_enter()
autocmd BufLeave * call BufMRU_leave()

command! -nargs=0 BufMRU :call BufMRUShow()
command! -nargs=0 BufMRUNext :call BufMRUGo(1)
command! -nargs=0 BufMRUPrev :call BufMRUGo(-1)

