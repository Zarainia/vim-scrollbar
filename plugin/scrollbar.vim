if (has('gui') || exists('g:loaded_scrollbar')) " only load for term version and if not loaded yet
	finish
endif

let g:loaded_scrollbar = 1

function RemoveScrollbar() " remove the scrollbar signs
	for i in range(1, winheight('%'))
		silent! sign unplace 806
		silent! sign unplace 807
	endfor
endfunction

function UpdateScrollbar() " update scrollbar location
	let total_lines = line('$') " total lines
	let buffer_top = line('w0') - 1 " first visible line (subtract 1 because line numbers start at 1)

	if (g:scroll_bar_last_textlength == total_lines && g:scroll_bar_last_line == buffer_top) " only update if it's changed since last time
		return
	endif

	let buffer_bottom = line('w$') " last visible line
	let text_length = winheight('%') " total screen height
	let scrollbar_length = max([float2nr(round((str2float(text_length) / str2float(total_lines)) * str2float(text_length))), 1]) " length is by percentage of lines visible (minimum = 1)

	let bar_start = float2nr(round(str2float(buffer_top) / str2float(total_lines) * text_length)) + 1 " position is by percentage location
	let actual_start = bar_start + buffer_top " actual line location of bar
	let bar_end = bar_start + scrollbar_length " end at scrollbar_length after start
	let actual_end = bar_end + buffer_top " actual line location of bar

	" clamping
	if (actual_start + scrollbar_length > total_lines)
		let actual_end = total_lines
		let actual_start = total_lines - scrollbar_length
	endif

	call RemoveScrollbar() " remove old signs

	for i in range(buffer_top, buffer_bottom)
		if (i >= actual_start && i <= actual_end) " thumb if it's between the scrollbar positions, line otherwise
			silent! execute ":sign place 806 line=" . i . " name=sbthumb"
		else
			silent! execute ":sign place 807 line=" . i . " name=sbline"
		endif
	endfor

	let g:scroll_bar_last_line = buffer_top " save the previous location
	let g:scroll_bar_last_textlength = text_length
endfunction

function ScrollUpdate(timer) " timer function
	call UpdateScrollbar()
endfunction

fun! ScrollbarGrab() " function called when scrollbar dragged
	if getchar()=="\<leftrelease>" || v:mouse_col!=1
		return|en
	while getchar()!="\<leftrelease>"
		let pos=1+(v:mouse_lnum-line('w0'))*line('$')/winheight(0)
		call cursor(pos,1)
	endwhile
endfun

function ScrollbarOff()
	call timer_stop(g:scroll_timer)
	call RemoveScrollbar()
	nunmap <LeftMouse>
	iunmap <LeftMouse>
	let g:scroll_bar_showing = 0
endfunction

function ScrollbarOn()
	let g:scroll_timer = timer_start(g:scroll_bar_update_time, "ScrollUpdate", {'repeat': -1})
	if g:scroll_bar_draggable
		nnoremap <silent> <leftmouse> <leftmouse>:call ScrollbarGrab()<cr>
		inoremap <silent> <leftmouse> <leftmouse><c-o>:call ScrollbarGrab()<cr>
	endif
	let g:scroll_bar_showing = 1
endfunction

function ToggleScrollbar() " toggle scrollbar display
	if g:scroll_bar_showing
		call ScrollbarOn()
	else
		call ScrollbarOff()
	endif
endfunction

let g:scroll_bar_update_time = get(g:, 'scroll_bar_update_time', 100) " default update time: 100ms
let g:scroll_bar_thumb_char = get(g:, 'scroll_bar_thumb_char', '+') " default scrollbar thumb symbol: +
let g:scroll_bar_line_char = get(g:, 'scroll_bar_line_char', '|') " default scrollbar line symbol: |
let g:scroll_bar_draggable = get(g:, 'scroll_bar_draggable', 1) " whether scrollbar is draggable (default: true)
let g:scroll_bar_autostart = get(g:, 'scroll_bar_autostart', 1) " whether to start the scrollbar immediately (default: true)

let g:scroll_bar_last_line = 0 " previous first visible line
let g:scroll_bar_last_textlength = 0 " previous text length
let g:scroll_bar_showing = 0 " whether scrollbar is showing

" define the signs
execute 'sign define sbthumb text=' . g:scroll_bar_thumb_char . ' texthl=Scrollbar_Thumb'
execute 'sign define sbline text=' . g:scroll_bar_line_char . ' texthl=Scrollbar_Line'

if ! hlexists('Scrollbar_Thumb') " highlighting
	hi Scrollbar_Thumb guibg=red guifg=red ctermbg=1 ctermfg=1
endif
if ! hlexists('Scrollbar_Line')
	hi Scrollbar_Line guibg=NONE guifg=red ctermbg=NONE ctermfg=1
endif

command ToggleScrollbar call ToggleScrollbar() " add the command
command ScrollbarOn call ScrollbarOn()
command ScrollbarOff call ScrollbarOff()

if g:scroll_bar_autostart
	ScrollbarOn
endif

