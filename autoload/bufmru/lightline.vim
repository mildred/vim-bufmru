
hi BufMRULightlineActive cterm=underline

let s:buffers = {}

function s:dirname(path)
  return fnamemodify(a:path.'a', ':h')
endfunction

function s:basename(path)
  return fnamemodify(a:path.'a', ':t')
endfunction

function s:tailfile(path, num)
  let num = a:num - 1
  let name = fnamemodify(a:path, ':t')
  let path = fnamemodify(a:path, ':h')
  while num > 0
    let name = fnamemodify(path, ':t') . '/' . name
    let path = fnamemodify(path, ':h')
    let num = num - 1
  endwhile
  return name
endfunction

function bufmru#lightline#buffer_name(buf, bufs)
  if has_key(s:buffers, a:buf)
    return s:buffers[a:buf]['name']
  endif
  let path = bufname(str2nr(a:buf))
  if path == ''
    return '[no name]'
  endif

  let conflicts = 1
  let tailnum = 1
  while conflicts
    let conflicts = 0
    let name = s:tailfile(path, tailnum)
    for b in a:bufs
      if b == a:buf
        continue
      endif
      let bpath = bufname(str2nr(b))
      let bname = s:tailfile(bpath, tailnum)
      if bname == name
        let conflicts = conflicts + 1
        if has_key(s:buffers, b)
          if s:buffers[b]['size'] < tailnum
            remove(s:buffers, b)
          endif
        endif
      endif
    endfor
    let tailnum = tailnum + 1
  endwhile

  let s:buffers[a:buf] = { 'name': name, 'size': tailnum }
  return name
endfunction

let g:bufmru_lightline_highlight = 'LightlineLeft_tabline_0'
let g:bufmru_lightline_highlight_active = 'LightlineLeft_tabline_tabsel_0'

function bufmru#lightline#buffer_tag(buf, bufs, active)
  let name = bufmru#lightline#buffer_name(str2nr(a:buf), a:bufs)
  let name = substitute(name, '%', '%%', 'g')
  "if a:active
  "  let name = '['.name.']'
  "endif
  let text = bufmru#lightline#nr2superscript(a:buf) . name
  let markup = '%' . a:buf . '@bufmru#lightline#bufgo@' . text . '%T'
  "if a:active
  "  let markup = '%#' . g:bufmru_lightline_highlight_active . '#' . markup . '%#' . g:bufmru_lightline_highlight . '#'
  "else
  "  let markup = '%#' . g:bufmru_lightline_highlight . '#' . markup
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
    return bufmru#lightline#buffer_tag(buf, bufs, 1)
    return ''
  else
    return bufmru#lightline#buffer_tag(buf, bufs, 1)
  endif
endfunction

function bufmru#lightline#close()
  return '%0@bufmru#lightline#bufclose@ x %X'
endfunction

function bufmru#lightline#buffers()
  let res = [[], [], []]
  let bufs = BufMRUList()
  let first = 1
  let active = bufnr('%')
  let i = 0
  for buf in bufs
    "if first && buf == bufnr('%')
    "  continue
    "endif
    if buf == active && i < 2
      let i = 1
    elseif buf != active && i == 1
      let i = 2
    endif
    let res[i] += [ ' '.bufmru#lightline#buffer_tag(buf, bufs, buf == active).' ' ]
    let first = 0
  endfor
  "return join(res, ' '.g:lightline.subseparator.left.' ')
  return res
  return [join(res[0], '  ').' ', ' '.join(res[1], '  ').' ', ' '.join(res[2], '  ')]
endfunction

function bufmru#lightline#bufgo(num, numclicks, mousebtn, modifiers)
  let active = bufnr('%')
  if a:mousebtn == 'm'
    if active == a:num
      call bufmru#go(1)
    end
    execute "bd" a:num
  else
    execute "buffer" a:num
  end
endfunction

function bufmru#lightline#bufclose(num, numclicks, mousebtn, modifiers)
  let nr = bufnr('%')
  call bufmru#go(1)
  execute "bd" nr
endfunction

