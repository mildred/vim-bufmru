function! bufmru#sort(b1, b2)
	let t1 = str2float(reltimestr(BufMRUTime(a:b1)))
	let t2 = str2float(reltimestr(BufMRUTime(a:b2)))
	return t1 == t2 ? 0 : t1 > t2 ? -1 : 1
endfunction

function! bufmru#enter()
	let s:bufmru_entertime = reltime()
	if ! s:going
		call bufmru#save("enter()")
	endif
	let s:going = 0
	call bufmru#autocmd()
endfunction

function! bufmru#save(reason)
	"echo "save(" a:reason ")"
	let g:bufmru_reason = a:reason
	let i = bufnr("%")
	let s:going = 0
	if buflisted(i)
		let oldVal = BufMRUTime(i)
		let s:bufmru_files[i] = s:bufmru_entertime
		if reltimestr(oldVal) != reltimestr(s:bufmru_entertime)
			silent doautocmd User BufMRUChange
			if get(g:, 'airline#extensions#tabline#enabled', 0)
				call airline#extensions#tabline#buflist#invalidate()
			endif
			if !empty(get(g:, 'lightline', {}))
				call lightline#update()
			end
			" Change currect buffer to force updating the airline buffer list
			if bufnr("$") > 1
				" Toggle showing the tabline off and on to refresh it
				let stl=&showtabline
				set showtabline=0
				let &showtabline=stl
			endif
		endif
	endif
	"unmap <CR>
endfunction

function! bufmru#save_change(reason, timeout)
	let totaltime = str2float(reltimestr(reltime(s:bufmru_entertime)))
	if totaltime > a:timeout
		call bufmru#save(a:reason)
	endif
endfunction

function! bufmru#leave()
	let totaltime = str2float(reltimestr(reltime(s:bufmru_entertime)))
	if totaltime >= 1.0
		call bufmru#save("leave()")
	endif
endfunction

function! BufMRUTime(bufn)
	return has_key(s:bufmru_files, a:bufn) ? s:bufmru_files[a:bufn] : s:bufmru_starttime
endfunction

function! BufMRUList()
	let bufs = range(1, bufnr("$"))
	let res = []
	call sort(bufs, "bufmru#sort")
	for nr in bufs
		if buflisted(nr)
			call add(res, nr)
		endif
	endfor
	return res
endfunction

function! bufmru#show()
	call bufmru#save("show()")
	let bufs = BufMRUList()
	for buf in bufs
		let bufn = bufname(str2nr(buf))
		let buft = reltimestr(reltime(BufMRUTime(buf)))
		echom buf " | " buft "s | " bufn
	endfor
endfunction

function! bufmru#go(inc)
	"call bufmru#leave()
	let list = BufMRUList()
	let idx = index(list, bufnr("%"))
	let i = list[((idx < 0 ? 0 : idx) + a:inc) % len(list)]
	let s:going = 1
	call bufmru#noautocmd()
	execute "buffer" i
	"call bufmru#save("go")
	"noremap <CR> :BufMRUCommit<CR><CR>
endfunction


function! bufmru#init()
	let s:bufmru_files = {}
	let s:bufmru_starttime = reltime()
	let s:bufmru_entertime = s:bufmru_starttime
	let s:going = 0

	call bufmru#autocmd()
endfunction

function bufmru#noautocmd()
	augroup bufmru_buffers
		autocmd!
		autocmd BufEnter * call bufmru#enter()
	augroup END
endfunction

function bufmru#autocmd()
	augroup bufmru_buffers
		autocmd!
		autocmd BufEnter * call bufmru#enter()
		"autocmd BufLeave * call bufmru#leave()
		"autocmd InsertEnter,InsertLeave * call bufmru#save("InsertEnter,InsertLeave")
		autocmd InsertEnter * call bufmru#save("InsertEnter")
		autocmd InsertLeave * call bufmru#save("InsertLeave")
		autocmd TextChanged * call bufmru#save("TextChanged")
		autocmd TextChangedI * call bufmru#save("TextChangedI")
 		"autocmd CursorHold,CursorHoldI * call bufmru#save("CursorHold,CursorHoldI")
		"autocmd CursorMoved * call bufmru#save_change("CursorMoved", 0.1)
		autocmd CursorMovedI * call bufmru#save_change("CursorMovedI", 0.1)
	augroup END
endfunction

