;**********************************************************************
table_type_6
;**********************************************************************
;
;  3 bytes
;
;  AAAAAAAA AAAAAAAA AAADDDDD
;
;  A = 19 bits of LED
;  DDDDD = a repeat counter.

    var p2count

    call         get_next_pattern_entry
    movwf        in0
  
    call         get_next_pattern_entry
    movwf        in1

    call         get_next_pattern_entry
    movwf        in2

    movlw        b'00001111'

    andwf        in2,w
    movwf        p2count
    incf         p2count,f
    rlf          p2count,f
    rlf          p2count,f

p2loop
    movfw        pspeed
    call         display_1bit

    decfsz       p2count,f
    goto         p2loop

    return

