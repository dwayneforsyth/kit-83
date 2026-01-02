;**********************************************************************
table_type_12
;**********************************************************************
;
    var  p12_count

    movlw        LOW in0       ; shift down in1f->in0
    movwf        FSR0L
    movlw        HIGH in0
    movwf        FSR0H

    movlw        0x03

    movwf        p12_count

p12_loop
    call         gen_random
    call         gen_random
    call         gen_random
    call         gen_random
    call         gen_random

    movwi        FSR0++

    decfsz       p12_count,f
    goto         p12_loop

    movfw        pspeed
    call         display_1bit

    movfw        pspeed
    call         display_1bit

    return
