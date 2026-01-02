
#ifdef PATTERN16
#define BRIGHT1_lo 0x04
#define BRIGHT2_lo 0x0A
#define BRIGHT1_hi 0x40
#define BRIGHT2_hi 0xA0

;**********************************************************************
table_type_16
;**********************************************************************
;
;  1 bytes
;
;  ABBCCCCC
;
;  A = shire Right/Left
;  BB = two bit intensity to shift on
;  CCCCC = Number of shifts to loop
;
;  if CCCCC = 0x11111, specical case: turn all LEDs off.

    var t7count
    var t17_loop

    movlp        high get_next_pattern_entry
    call         get_next_pattern_entry
    movwf        in0

    call         get_next_pattern_entry
    movwf        in1
    movlp        high table_type_16

    movlw        b'00011111'
    andwf        in0,w
    movwf        t7count

    movlw        b'00011111'  ; if shiftcount is 31, then clear all LEDs
    subwf        t7count,w
    btfss        STATUS,Z
    goto         t7_loop_red
    
    clrf         in0           ; quick way to clear all the LEDS.
    clrf         in1
    clrf         in2
    clrf         in3
    clrf         in4
    clrf         in5
    movlp        high display_1bit
    call         display_1bit
    movlp        high table_type_16
    goto         t7_return

t7_loop_red
    btfsc        in0,7
    goto         t7_set19_red

    call red_up
    goto         t7_loop_green

t7_set19_red

    call red_down

t7_loop_green
    btfsc        in0,6
    goto         t7_set19_green

    call green_up

    goto         t7_loop_blue
;
;   set LED 19
t7_set19_green

    call green_down

t7_loop_blue

    btfsc        in0,5
    goto         t7_set19_blue

    call blue_up

    goto         t7_cont
;
;   set LED 19
t7_set19_blue
    call  blue_dowm
t7_cont
    movlp high strobe_delay
    movf         pspeed,w
    call         strobe_delay
    movlp high t7_cont
;
;   This is a quick hack, because without this button presses are not seen for minutes
;   This early exit might impact the pattern getting displayed.
;
    btfsc        button,0    ; if putton pressed show pattern id
    goto         t7_return

    btfsc        IR_in_good,0
    goto         t7_return

    decfsz       t7count,f
    goto         t7_loop_red

t7_return
    return

;**********************************************************************
red_up
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW A5_C1_reg   ; index = 13 R
    movwf        FSR0L

    movlw        HIGH A5_C1_reg   ; index = 13 R
    movwf        FSR0H

red_up_loop
    moviw        FSR0--        ; w = IND0, index--
    movwi        2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         red_up_loop
;
;   01 Red
;
    
    moviw        ++FSR0
    clrf         INDF0
    movlw        BRIGHT1
    btfsc        in1,6
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,7
    addwf        INDF0,f     ;01

    return

;**********************************************************************
red_down
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW C2_C3_reg   ; index = 02 R
    movwf        FSR0L

    movlw        HIGH C2_C3_reg   ; index = 02 R
    movwf        FSR0H

red_down_loop
    moviw        FSR0++        ; w = IND0, index++
    movwi        -.2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         red_down_loop
;
;   14 Red
;
    movlw        0x00
    movwi        --FSR0        
    clrf         INDF0
    movlw        BRIGHT1
    btfsc        in1,6
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,7
    addwf        INDF0,f     ;01

    return

;**********************************************************************
green_up
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW C4_C1_reg   ; index = 13 G
    movwf        FSR0L

    movlw        HIGH C4_C1_reg   ; index = 13 G
    movwf        FSR0H

green_up_loop
    moviw        FSR0--        ; w = IND0, index--
    movwi        2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         green_up_loop
;
;   01 Green
;
    movlw        0x00
    movwi        ++FSR0
    movlw        BRIGHT1
    btfsc        in1,4
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,5
    addwf        INDF0,f     ;01

    return

;**********************************************************************
green_down
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW C0_C3_reg   ; index = 02 Green
    movwf        FSR0L

    movlw        HIGH C0_C3_reg   ; index = 02 Green
    movwf        FSR0H

green_down_loop
    moviw        FSR0++        ; w = IND0, index++
    movwi        -.2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         green_down_loop
;
;   14 Green
;
    movlw        0x00
    movwi        --FSR0
    movlw        BRIGHT1
    btfsc        in1,4
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,5
    addwf        INDF0,f     ;01

    return


;**********************************************************************
blue_up
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW C2_C1_reg   ; index = 13 G
    movwf        FSR0L
    movlw        HIGH C2_C1_reg   ; index = 13 G
    movwf        FSR0H

blue_up_loop
    moviw        FSR0--        ; w = IND0, index--
    movwi        2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         blue_up_loop
;
;   01 blue
;
    movlw        0x00
    movwi        ++FSR0
    movlw        BRIGHT1
    btfsc        in1,2
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,3
    addwf        INDF0,f     ;01

    return


;**********************************************************************
blue_dowm
;**********************************************************************

    movlw        0x0d
    movwf        t17_loop

    movlw        LOW C4_C3_reg   ; index = 02 Blue
    movwf        FSR0L

    movlw        HIGH C4_C3_reg   ; index = 02 Blue
    movwf        FSR0H

blue_down_loop
    moviw        FSR0++        ; w = IND0, index++
    movwi        -.2[FSR0]        ; store w -> index+2

    decfsz       t17_loop,f
    goto         blue_down_loop
;
;   14 Green
;
    movlw        0x00
    movwi        --FSR0
    movlw        BRIGHT1
    btfsc        in1,2
    addwf        INDF0,f     ;01
    movlw        BRIGHT2
    btfsc        in1,3
    addwf        INDF0,f     ;01

    return
#endif

;
; These are down here for memory placement
;

#ifdef DISPLAY_1BIT_E
#include display_1bit_e_part2   ; RGB Stick Anode / cathode
#endif
    
#ifdef DISPLAY_1BIT_C12RGB
#include display_1bit_c12rgb_part2   ; RGB Stick Anode / cathode
#endif    

#ifdef PATTERN17
#include pattern_17_part2.asm
#endif

#ifdef PATTERN18
#include pattern_18.asm  
#endif

#ifdef PATTERN20
#include pattern_20.asm
#endif

#ifdef PATTERN21
#include pattern_21.asm
#endif

#ifdef C12
    ORG     0x800
#endif

#ifdef PATTERN27
#include "pattern_27.asm"
#endif

