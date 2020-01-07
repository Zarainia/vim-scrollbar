# vim-scrollbar
Adding a scrollbar to terminal vim using "signs". Inspired by https://github.com/lornix/vim-scrollbar, which, for some reason, doesn't work for me at all. This works by updating on a timer, so it'll work for any motion without changing keybindings, with the tradeoff of being less smooth (requires Vim 8 due to the timer function). You can set the update frequency to balance smoothness with slowing other things down (I can actually set the timer pretty low without noticing any slowdowns, but there are diminishing returns and it still jumps around a bit when scrolling using the mouse). 

## Settings

Set the amount of time between updates (default is 100):

~~~vim
let g:scroll_bar_update_time=100
~~~

Set the scrollbar thumb and line symbols (defaults are `#` for the thumb and `|` for the line):

~~~vim
g:scroll_bar_thumb_char = '#'
g:scroll_bar_line_char = '|'
" use '│' for a continuous line
~~~

Set the scrollbar colours (default is red):

~~~vim
hi Scrollbar_Thumb guibg=red guifg=red ctermbg=1 ctermfg=1
hi Scrollbar_Line guibg=NONE guifg=red ctermbg=NONE ctermfg=1
~~~

## Limitations

As mentioned above, scrolling continuously can be jumpy. Marks are also not placed on soft-wrapped lines, so there will be a gap in the scrollbar and the scrollbar size will not be right. 

