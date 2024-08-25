vim9script
# --------------------------------------------------------------
# Author:  arfanamd
# Plugin:  QFDebug
# License: Distributed under the same license as Vim itself.
# See ":help license" in Vim.
# --------------------------------------------------------------

if exists("g:QFDebug_loaded")
	finish
endif

g:QFDebug_loaded = true

# Make the signs appear inline with the line numbers.
# See ":help signcolumn" for another options.
set signcolumn=number

# QFDebug color scheme
highlight QFDebug_err  ctermfg=0160 term=none 
highlight QFDebug_warn ctermfg=0215 term=none
highlight QFDebug_info ctermfg=0248 term=none

# QFDebug sign
sign define QFDebug_err  numhl=QFDebug_err  text=\ ⚑
sign define QFDebug_warn numhl=QFDebug_warn text=\ ⚑
sign define QFDebug_info numhl=QFDebug_info text=\ ⚑

# QFDebug augroup & autocmd
# Open the QuickFix buffer at the bottom of current window and place
# signs on the corresponding line if there are any errors or warning
# returned after executing the ":make" command.
augroup QFDebug
	autocmd!
	autocmd QuickFixCmdPre [^l]* call QFDebugUnsign()
	autocmd QuickFixCmdPost [^l]* call QFDebugSign()
augroup END

# Filter only the valid recognized error or warning messages lists
# from the "getqflist()" function.
def QFDebugParse(): list<dict<any>>
	var parse_qflist: list<dict<any>>
	
	for debug in getqflist()
		if debug.bufnr >= 0 && debug.valid == 1
			add(parse_qflist, debug)
		else
			continue
		endif
	endfor
	
	return parse_qflist
enddef

# Place the signs on the corresponding lines.
def QFDebugSign()
	var sign_track: number = 0
	var sign_place: string = ""
	var valid_list: list<dict<any>> = QFDebugParse()
	
	if len(valid_list) > 0
		for debug in valid_list
			sign_track += 1
			sign_place = "sign place " .. sign_track .. " line=" .. debug.lnum
			
			if debug.type == 'E'
				sign_place ..= " name=QFDebug_err"
			elseif debug.type == 'W'
				sign_place ..= " name=QFDebug_warn"
			else
				sign_place ..= " name=QFDebug_info"
			endif
			
			sign_place ..= " group=QFDebug buffer=" .. debug.bufnr
			silent! execute sign_place
		endfor
		
		call QFDebugBufOpen(valid_list[0]['bufnr'])
	endif
enddef

# Clear all placed signs.
def QFDebugUnsign()
	silent! execute "sign unplace * group=QFDebug"
	call QFDebugBufClose()
enddef

# Open QuickFix buffer.
def QFDebugBufOpen(nr: number)
	silent! execute "copen 8"
	silent! execute nr .. "wincmd w"
enddef

# Close QuickFix buffer.
def QFDebugBufClose()
	silent! execute "cclose"
enddef

# vim:ft=vim:sw=2:ts=2
