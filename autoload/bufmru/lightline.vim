
function bufmru#lightline#buffer_name(buf)
  let name = bufname(str2nr(a:buf))
  if name == ''
    let name = '[no name]'
  endif
  return name
endfunction

function bufmru#lightline#buffer_tag(buf)
  let name = bufmru#lightline#buffer_name(str2nr(a:buf))
  let name = substitute(name, '%', '%%', 'g')
  let text = bufmru#lightline#nr2superscript(a:buf) . name
  let markup = '%' . a:buf . '@bufmru#lightline#bufgo@' . text . '%T  '
  "if a:buf == bufnr('%')
  "  let markup = '%' . a:buf . '*' . markup . ''
  "endif
  return markup
endfunction

function bufmru#lightline#nr2superscript(nr)
  let res = ""
  let conv = {
        \ '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
        \ '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'
        \ }
  for digit in split(a:nr, '\zs')
    let res = res . conv[digit]
  endfor
  return res
endfunction

function bufmru#lightline#firstbuffer()
  let bufs = BufMRUList()
  let buf = bufnr('%')
  if bufs[0] == buf
    return bufmru#lightline#buffer_tag(buf)
    return ''
  else
    return bufmru#lightline#buffer_tag(buf)
  endif
endfunction

function bufmru#lightline#buffers()
  let res = ''
  let bufs = BufMRUList()
  let first = 1
  for buf in bufs
    if first && buf == bufnr('%')
      continue
    endif
    let res = res . bufmru#lightline#buffer_tag(buf)
    let first = 0
  endfor
  return ['', res, '']
endfunction

function bufmru#lightline#bufgo(num, numclicks, mousebtn, modifiers)
  execute "buffer" a:num
endfunction

