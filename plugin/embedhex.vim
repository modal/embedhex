"embedhex.vim
"Author:    Timothy Dahlin
"License:   Same terms as Vim itself (see |license| by typing :h license)
"
"Intent:
"
"This plugin is designed to implement features similar to EMACS Intel Hex Modes.
"http://www.emacswiki.org/emacs/intel-hex-mode.el
"
"Plan is to extend it across several common file types used in the embedded
"space.
"
"Requirements:
"   -Vim compiled with +python
"   -Python dll
"   -VIM Version > 7.2
"
"Relevant Resources:
"   Intel Hex Record
"   http://en.wikipedia.org/wiki/Intel_HEX
"
"   Motorola SRecord
"   http://en.wikipedia.org/wiki/SREC_(file_format)
"
"   Tektronix Extended HEX
"   http://en.wikipedia.org/wiki/Tektronix_extended_HEX
"
"   More
"   http://www.xilinx.com/support/answers/476.htm

"Thanks:
"homekevin on the vim irc #freenode channel
"
"Suggestions:
"   Email them
"
"------------------------------------------------------------------------------
"Source:
"------------------------------------------------------------------------------
if !has("python")
    finish
endif

"if &cp || exists("g:loaded_embedhex")
"    finish
"endif

let g:loaded_embedhex = "v0001"

if !exists("g:embedhex_cs_continue")
    let embed_cs_continue = 0
endif

function! <SID>CalcIntelHexChecksum() range
python << EOF

def calcintelhex():
    import vim
    #a = vim.current.line
    start = int(vim.eval("a:firstline"))
    end = int(vim.eval("a:lastline"))
    #print start, " ", end
    for line in xrange(start-1, end):
        a = vim.current.buffer[line]
        rec_len_t = len(a)          #Length of Line
        if rec_len_t == 0:
            #cursor_loc = vim.current.window.cursor
            #print "ERROR:  Empty Line  Line#", cursor_loc[0]
            print "ERROR:  Empty Line  Line#", line+1
            if "1" == vim.eval("g:embed_cs_continue"): continue
            return
        elif a[0] != ':':
            print "ERROR:  Invalid start of record character => ", a[0], " Line#", line+1
            if "1" == vim.eval("g:embed_cs_continue"): continue
            return
        else:
            pass

        rec_len = int(a[1:3], 16)   #Intel Record Length in Bytes

        if (rec_len*2 + 9) > rec_len_t:
            print "ERROR:  Minimum Record Length Failed  Line#", line+1
            if "1" == vim.eval("g:embed_cs_continue"): continue
            return

        checksum = 0
        for ele in xrange((2*rec_len+9)/2):
            checksum += int(a[(2*ele + 1):(2*ele + 3)],16)

        checksum = "%02X" % (0xff & (~checksum + 1))
        #temp_str = "%02X" % temp
        #address = int(a[3:7])
        #rec_type = int(a[7:9])

        vim.current.buffer[line] = a[0:9+(2*rec_len)] + checksum

calcintelhex()
EOF
endfunction

function! CalcSRecordChecksum() range
"FIXME
python << EOF
def calc_srec_cs():
    import vim
    a = vim.current.line
    rec_len_t = lan(a)

    if rec_len_t == 0:
        print "ERROR: Empty Line"
        return
    elif a[0] not in ['s', 'S']:
        print "ERROR:  Invalid start of record character"
    else:
        pass

    rec_type = a[1]

    if rec_type in ['1', '2', '3']:
        address_bytes = int(rec_type)+1
    elif rec_type == "0":
        address_bytes = 2
    elif rec_type == "5":
        address_bytes = 2
    elif rec_type in ['7', '8', '9']:
        address_bytes = 11-int(rec_type)
        bc = 12-int(rec_type)
    else:
        print "ERROR: Unknown record type => ", rec_type
        return

    byte_count = a[2:4]
    nibble_count = int(a[2:4])*2
    address = a[4:2*addressbytes+5]

    #min_len =
    #Decode Record Type

    #Minimum length is 8 before checksum

calc_srec_cs()
EOF
endfunction

function! CalcTekHextChecksum() range
"FIXME
"Normal Tektronix
endfunction

function! CalcTekExtHexChecksum() range
"FIXME
"extended tektronix
"%LLTCS8AAAAAAAA
"LL excludes percent length field type and checksum
"T is either 6 or 8, 8 is termination record
"CS is the sum of all nibbles excluding the CS
endfunction

function! CalcAutoChecksum() range
"Calls checksum routine based upon 1st character in first line?
endfunction

"------------------------------------------------------------------------------
"User Defined Commands:
"------------------------------------------------------------------------------
"http://www.adp-gmbh.ch/vim/user_commands.html

command! -range -nargs=0 CalcIntelHexChecksum <line1>,<line2>call <SID>CalcIntelHexChecksum()
"command! -range -nargs=0 CalcSRecordChecksum <line1>,<line2>call <SID>CalcSRecordChecksum()
"command! -range -nargs=0 CalcTekExtHexChecksum <line1>,<line2>call <SID>CalcTekExtHexChecksum()
"command! -range -nargs=0 CalcTekHextChecksum <line1>,<line2>call <SID>CalcTekHextChecksum()
