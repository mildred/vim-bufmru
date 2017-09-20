
hi BufMRULightlineActive cterm=underline

let s:buffers = {}

function! s:dirname(path)
  return fnamemodify(a:path.'a', ':h')
endfunction

function! s:basename(path)
  return fnamemodify(a:path.'a', ':t')
endfunction

function! s:tailfile(path, num)
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

function! bufmru#lightline#buffer_name(buf, bufs)
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

function! bufmru#lightline#buffer_tag(buf, bufs, active)
  let name = bufmru#lightline#buffer_name(str2nr(a:buf), a:bufs)
  let name = substitute(name, '%', '%%', 'g')
  let name .= (getbufvar(a:buf, "&mod")?'*':'')
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
  return [a:buf.name, markup]
endfunction

function! bufmru#lightline#nr2superscript(nr)
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

function! bufmru#lightline#firstbuffer()
  let bufs = BufMRUList()
  let buf = bufnr('%')
  if bufs[0] == buf
    let [t, m] = bufmru#lightline#buffer_tag(buf, bufs, 1)
    return m
  else
    let [t, m] = bufmru#lightline#buffer_tag(buf, bufs, 1)
    return m
  endif
endfunction

function! bufmru#lightline#close()
  return '%0@bufmru#lightline#bufclose@ x %X'
endfunction

function! bufmru#lightline#initvars()
  let el = '…'
  let ellen = -1
  let seplen = 1
  let reserve = 0
  if exists('g:bufmru_lightline_ellipsis')
    let el = g:bufmru_lightline_ellipsis
  else
    let el = '…'
    let ellen = 1
  endif
  if exists('g:bufmru_lightline_ellipsis_len')
    let ellen = g:bufmru_lightline_ellipsis_len
  elseif ellen < 0
    let ellen = strlen(el)
  endif
  if exists('g:bufmru_lightline_sep_len')
    let seplen = g:bufmru_lightline_sep_len
  endif
  if exists('g:bufmru_lightline_reserve')
    let reserve = g:bufmru_lightline_reserve
  endif
  return [ el, ellen, seplen, reserve ]
endfunction

function! bufmru#lightline#buffers()
  let res = [[], [], []]
  let lens = [[], [], []]
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
    let [t, m] = bufmru#lightline#buffer_tag(buf, bufs, buf == active)
    let lens[i] += [ len(t)+2 ]
    let res[i] += [ ' '.m.' ' ]
    let first = 0
  endfor

  let [ ellipsis, ellen, seplen, reserve ] = bufmru#lightline#initvars()
  let seplen = 1
  let ellen1 = ellen + seplen
  let ellen2 = 2 * ellen1
  let res2 = [[], res[1], []]
  let width = &columns
  let maxw = width - reserve
  let curw = seplen
  for w in lens[1]
    let curw += w + seplen
  endfor
  let res200 = []
  let firstellipsis = 0
  if len(res[0]) > 0
    if curw+lens[0][0]+seplen+ellen2 < maxw
      let res200 += [ res[0][0] ]
      let curw += lens[0][0] + seplen
    else
      let res200 += [ ellipsis ]
      let curw += 1 + seplen
      let firstellipsis = 1
    endif
  endif
  let i = len(lens[0])-1
  while i >= 1 && curw+lens[0][i]+seplen+ellen2 < maxw
    let curw += lens[0][i] + seplen
    let res2[0] = [ res[0][i] ] + res2[0]
    let i = i - 1
  endwhile
  if i > 1 && !firstellipsis
    let curw += 1 + seplen
    let res2[0] = [ ellipsis ] + res2[0]
  endif
  let res2[0] = res200 + res2[0]
  let i = 0
  let lenres2 = len(lens[2])
  while i < lenres2 && curw+lens[2][i]+seplen+ellen1 < maxw
    let curw += lens[2][i] + seplen
    let res2[2] += [ res[2][i] ]
    let i = i + 1
  endwhile
  if i < lenres2
    let res2[2] += [ ellipsis ]
    let curw += 1 + seplen
  endif
  let g:bufmru_lightline_ellipsis_debug = 'maxw='.maxw.' curw='.curw.' width='.width.' reserve='.reserve

  return res2
endfunction

function! bufmru#lightline#bufgo(num, numclicks, mousebtn, modifiers)
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

function! bufmru#lightline#bufclose(num, numclicks, mousebtn, modifiers)
  let nr = bufnr('%')
  call bufmru#go(1)
  execute "bd" nr
endfunction

function! bufmru#lightline#tabnum()
  if tabpagenr('$') == 1
    return '' " no tabs
  endif
  let nr = tabpagenr()
  return '%0@bufmru#lightline#tabnum_click@ tab: '.nr.' %X'
endfunction

function! bufmru#lightline#tabnum_click(num, numclicks, mousebtn, modifiers)
  if a:mousebtn == 'r'
    tabprevious
  elseif a:mousebtn == 'm'
    tabclose
  elseif a:mousebtn == 'l'
    tabnext
  end
endfunction

