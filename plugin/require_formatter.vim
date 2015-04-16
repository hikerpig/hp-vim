if exists("g:loaded_require_formatter")
  finish
endif
let g:loaded_require_formatter = 1

"Function: :format
"Desc: align the require statement
"
func! s:format()
python << EOF

import vim
import re

# prepare
buffer = vim.current.buffer
vrange = vim.current.range
require_pattern = re.compile(r'(?P<left>\s*[\w\d_]+\s?)=\s*require(?P<right>[\w\d\"\'\s\(\)\-\/\.]+)')
assign_pattern = re.compile(r'(?P<left>\s*[\w\d_]+\s?)[=:]\s*(?P<right>[\w\d\"\'\s\(\)\-\/\.]+)')
g_pattern = require_pattern
g_matches = []
g_seperator = '='

vst = 0
vend = 0
start_mark = buffer.mark('<')
end_mark = buffer.mark('>')
if start_mark:
    vst = start_mark[0] - 1
    if end_mark:
        vend = end_mark[0]
cursor = vim.current.window.cursor
cend = cursor[0]
lines = buffer[0:]
g_start_line = 0
if vst and vend:
    if vend == cend:
        lines = buffer[vst:vend]
        g_start_line = vst
        g_pattern = assign_pattern
        g_seperator = re.compile('[=:]')
        #print 'vstart is', vst
        #print 'vend is', vend
        #print lines

def get_formated_line(text, left_len, seperator='='):
    """

    :text: {str}
    :left_len: {int}
    :returns: {str}

    """
    if hasattr(seperator, 'match'):
        match = seperator.search(text)
        if match:
            epos = match.start()
        else:
            return text
    else:
        epos = text.find(seperator)
    left_str = text[0:epos]
    remained = text[epos:]
    short_of_len = left_len - len(left_str)
    if short_of_len > 0:
        to_append = []
        for i in range(0, short_of_len):
            to_append.append(' ')
        to_append = ''.join(to_append)
        text = left_str + to_append + remained

    return text

def start(lines):
    max_left_len = 0
    matched_linenos = []
    for i, line in enumerate(lines):
        matches = g_pattern.match(line)
        if matches:
            matched_linenos.append(i)
            g_matches.append(matches)
            gp_dict = matches.groupdict()
            left = gp_dict.get('left')
            if not left[-1] == ' ':
              left += ' '
            left_len = len(left)
            max_left_len = max(max_left_len, left_len)

    for i in matched_linenos:
        line = lines[i]
        fl = get_formated_line(line, max_left_len, seperator=g_seperator)
        #print "formed_line is ", fl

        # replace the line
        real_lineno = i + g_start_line
        del buffer[real_lineno]
        buffer.append(fl, real_lineno)

# start
try:
    start(lines)
except Exception as exp:
    print exp

EOF
endfunc

" change this map if it conflicts with others
map <C-e> :echo <SID>format()<CR>

" 处于visual模式的时候会报range not allowed的错,
" vmap的时候先退出v模式"
vmap <C-e> <Esc>:echo <SID>format()<CR>
