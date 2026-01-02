;**********************************************************************
qdelay
;**********************************************************************
    var qcount

    movwf       qcount
delay_loop2
    decfsz      qcount,1
    goto        delay_loop2
    return
                 
;**********************************************************************
delay
;**********************************************************************

    var         delay_count

;   movlw       0ffh
    movwf       delay_count
delay_loop
    nop
    decfsz      delay_count,1
    goto        delay_loop
    return

;**********************************************************************
next_pattern
;**********************************************************************
    incf         pattern,f
    movf         pattern,w
    sublw        NUM_TAB+1  ; max pattern?
    btfsc        STATUS,2   ; z bit check
    clrf         pattern    ; reset to zero
    movfw        pattern
    movwf        out_pattern
    clrf         pindex
    clrf         pindex1
    return

;**********************************************************************
past_pattern
;**********************************************************************
    decf         pattern,f
    movf         pattern,w
    addlw        1  ; max pattern?
    btfss        STATUS,2   ; z bit check
    goto         past_exit
    movlw        NUM_TAB
    movwf        pattern
    movwf        out_pattern
past_exit
    clrf         pindex
    clrf         pindex1
    return

;**********************************************************************
set_pattern         ;set pattern from IR
;**********************************************************************
; extra logic because all the different blinkes talk to each other, but
; do not have the same number of patterns. So if blinkie "A" sents a
; pattern 22 to blinkie "B" which only has 10 patterns, Blinkie "B"
; starts to show pattern 2. (22 % 10 a mod function.) But to make
; things fair in blinkie wars, it will transmit pattern 22 to other
; blinkies.
;**********************************************************************

    movfw        command
    movwf        pattern
    movwf        out_pattern
set_loop
    addlw        0xff-NUM_TAB
    btfss        STATUS, C
    goto         set_exit

    movlw        NUM_TAB
    subwf        pattern,f
    movfw        pattern
    goto         set_loop

set_exit
    clrf         pindex
    clrf         pindex1
    return

;**********************************************************************
strobe_delay
;**********************************************************************

    var          strobe_count

    movwf        strobe_count
strobe_delay1
    bcf          nextf,0

strobe_delay2
    btfss        nextf,0
    goto         strobe_delay2

    decfsz       strobe_count,f
    goto         strobe_delay1

    return

#ifdef FLIPBYTE
;**********************************************************************
flipbyte
;**********************************************************************
     var flip_in
     var flip_out
     var flip_lcount

     movwf       flip_in
     clrf        flip_out
     movlw       0x08
     movwf       flip_lcount
fbyte_loop
     bcf         STATUS, C
     rrf         flip_in,f
     rlf         flip_out,f

     decfsz      flip_lcount,f
     goto        fbyte_loop

     movfw       flip_out
     return
#endif

