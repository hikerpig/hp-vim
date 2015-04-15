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
lines = buffer[0:]
require_pattern = re.compile(r'(?P<left>\s*[\w\d_]+\s?)=\s*require(?P<right>[\w\d\"\'\s\(\)\-\/]+)')
g_matches = []

def get_formated_line(text, left_len):
    """@todo: Docstring for get_formated_line

    :text: {str}
    :left_len: {int}
    :returns: {str}

    """
    epos = text.find('=')
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
        matches = require_pattern.match(line)
        if matches:
            matched_linenos.append(i)
            g_matches.append(matches)
            gp_dict = matches.groupdict()
            left = gp_dict.get('left')
            left_len = len(left)
            max_left_len = max(max_left_len, left_len)

    for i in matched_linenos:
        line = lines[i]
        fl = get_formated_line(line, max_left_len)
        #print "formed_line is ", fl
        # replace the line
        del buffer[i]
        buffer.append(fl, i)

# start
try:
  start(lines)
except Exception as exp:
  print exp

EOF
endfunc

" change this map if it conflicts with others
map <C-e> :echo <SID>format()<CR>
