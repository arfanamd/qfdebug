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
highlight QFDebug_err  term=none ctermbg=red   
highlight QFDebug_warn term=none ctermbg=yellow
highlight QFDebug_info term=none ctermbg=white 

# QFDebug sign
sign define QFDebug_err  numhl=QFDebug_err  culhl=QFDebug_err
sign define QFDebug_warn numhl=QFDebug_warn culhl=QFDebug_warn
sign define QFDebug_info numhl=QFDebug_info culhl=QFDebug_info

# QFDebug augroup & autocmd
# Open the QuickFix buffer at the bottom of current window and
# place all the signs on the corresponding line if there are any
# errors or warning returned after executing the ":make" command.
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
	var valid_list: list<dict<any>> = QFDebugParse()
	var sign_type: string = ""
	
	if len(valid_list) > 0
		for dbg in valid_list
			if dbg.type == 'E'
				sign_type = "QFDebug_err"
			elseif dbg.type == 'W'
				sign_type = "QFDebug_warn"
			else
				sign_type = "QFDebug_info"
			endif
			
			sign_place(0, "QFDebug", sign_type, dbg.bufnr, { 'lnum': dbg.lnum })
		endfor
		
		QFDebugBufOpen(valid_list[0]['bufnr'])
	endif
enddef

# Clear all placed signs.
def QFDebugUnsign()
	sign_unplace("QFDebug")
	QFDebugBufClose()
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
