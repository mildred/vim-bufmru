
function bufmru#lightline#buffers()
  let res = ''
  let bufs = BufMRUList()
  for buf in bufs
    let name = bufname(str2nr(buf))
    if name == ""
      let name = "[no name]"
    endif
    let name = substitute(name, '%', '%%', 'g')
    "let res = res . "%" . buf . "@bufmru#lightline#bufgo@" . buf . " " . name . "%X  "
    let res = res . buf . " " . name . "  "
  endfor
  return res
endfunction

function bufmru#lightline#bufgo(num, numclicks, mousebtn, modifiers)
  execute "buffer" num
endfunction

