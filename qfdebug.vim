vim9script
#--------------------------------------------------------------------
# Author:  arfanamd
# License: Released under the same license as Vim itself.
#
# Personal Vim Plugin (QFDebug).
#--------------------------------------------------------------------

if exists("g:QFDebug_loaded")
	finish
endif

g:QFDebug_loaded = true

# Display sign in the column "number". If the column number is
# not present, then behaves like "auto".
# See ":help signcolumn" for another options.
&signcolumn = "number"

# These color-sets are defined to differentiate between all debug
# enumeration states.
highlight QFDebug_err  cterm=none ctermfg=red   
highlight QFDebug_warn cterm=none ctermfg=yellow
highlight QFDebug_info cterm=none ctermfg=white 

# These "sign" will represent all debug enumeration styles.
sign define QFDebug_err  numhl=QFDebug_err  text==>
sign define QFDebug_warn numhl=QFDebug_warn text==>
sign define QFDebug_info numhl=QFDebug_info text==>

# Open the QuickFix window buffer at the bottom of current window
# and place all debug sign on the corresponding line.
augroup QFDebug
	autocmd!
	autocmd QuickFixCmdPre [^l]* call QFDebugUnsign()
	autocmd QuickFixCmdPost [^l]* call QFDebugSign()
	autocmd FileType qf call QFDebugBufInit()
augroup END

# Initialize QuickFix window buffer.
def QFDebugBufInit()
	&wrap = 1
	&relativenumber = 0
	&number = 0
enddef

# Filter valid recognized message types, e.g., error, warning and
# info from "getqflist()".
def QFDebugParse(): list<dict<any>>
	var parse_qflist: list<dict<any>>
	
	for debug in getqflist()
		if debug.bufnr >= 1 && debug.valid == 1
			add(parse_qflist, debug)
		else
			continue
		endif
	endfor
	
	return parse_qflist
enddef

# Place all the sign on the corresponding lines.
def QFDebugSign()
	var valid_list: list<dict<any>> = QFDebugParse()
	var sign_type: string = ""
	var e_c: number = 0
	var w_c: number = 0
	var i_c: number = 0
	
	if len(valid_list) > 0
		for dbg in valid_list
			if dbg.type == 'E' || dbg.type == 'e'
				sign_type = "QFDebug_err"
				e_c += 1
			elseif dbg.type == 'W' || dbg.type == 'w'
				sign_type = "QFDebug_warn"
				w_c += 1
			else
				sign_type = "QFDebug_info"
				i_c += 1
			endif
			
			sign_place(0, "QFDebug", sign_type, dbg.bufnr, {'lnum': dbg.lnum})
		endfor
		
		QFDebugBufOpen(valid_list[0]['bufnr'])
		setbufvar("", "&statusline",
			"%!g:QFDebugStatusLine(" .. i_c .. "," .. w_c .. "," .. e_c .. ")")
	endif
enddef

# Clear all placed sign.
def QFDebugUnsign()
	sign_unplace("QFDebug")
	QFDebugBufClose()
enddef

# Open QuickFix buffer window.
def QFDebugBufOpen(nr: number)
	silent! execute "copen 8"
	silent! execute nr .. "wincmd w"
enddef

# Close QuickFix buffer window.
def QFDebugBufClose()
	silent! execute "cclose"
enddef

# Generate "statusline" for QuickFix buffer window.
def g:QFDebugStatusLine(i: number, w: number, e: number): string
	var sl: string = "%#Normal#%#StatusLine# QuickFixDebug %="
	sl ..= "  Info: " .. i
	sl ..= "  Warn: " .. w
	sl ..= "  Error: " .. e
	sl ..= " %#Normal#"
	return sl
enddef

# vim:ft=vim:sw=2:ts=2
