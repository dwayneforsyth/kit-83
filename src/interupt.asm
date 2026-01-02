    var nextf                    ; flags for timing loops
;                                  bit 0 is one display cycle (890 usec)
;                                  bit 1 is about 1 minute
    var dcycle                   ; stobe counter [0-3]
    var count1                   ; lower bit counter
    var count2                   ; higher bit counter.


;
;   set tick interupt to 889ms for IR RC5 protocal 1/2 digit.
;   an Interupt every 889us /w 8mhz internal osc
;

#define  TICK_VALUE   D'35'
; #define TMR0 TMR0L
    
    BANKSEL TMR0
    movlw       TICK_VALUE
    movwf       TMR0                       
;
;   increment the stobe and duration counters
;
    BANKSEL  dcycle
    incf     dcycle,f

    movlw    STROBE_LINES
    subwf    dcycle,w
    btfsc    STATUS,C
    clrf     dcycle

    bsf      nextf,0

    incfsz      count1,f
    goto        skip1

    incfsz      count2,f
    goto        skip1

#ifdef LONGER_DELAY
    var         count3
    incfsz      count3,f
    goto        skip1
#endif

    bsf         nextf,1

skip1
#ifdef ENABLE_IR
    movf        scount,w                    ; F22
    addlw       0                           ; F23
    btfsc       STATUS,Z                    ; F24
    goto        send_nothing                ; F25

    btfss       tx_1,0                      ; F26
    goto        send_zero                   ; F27

;--------------------------------------------------------------------------------------
send_one  ; we are slaming the 36K IR siginal, its like a busy wait!
;--------------------------------------------------------------------------------------
    var repeat
#ifdef RGB5
    BANKSEL TRISA
;               543210
    movlw   b'00001111'      ;set A4 & A5 led to output
    movwf   TRISA
    BANKSEL 0
#define IRBIT 5
#define IRPORT PORTA
#else
#ifdef GATOR
    BANKSEL TRISA
    movlw   b'00011010'      ;set A4 & A5 led to output
    movwf   TRISA
    BANKSEL 0
#define IRBIT 4
#define IRPORT PORTA
#else
#ifdef S19
#ifndef S20
    banksel TRISA
    movlw   b'00011010'      ;set A0 & A5 led to output
    movwf   TRISA
    banksel PORTA
#endif
#define IRBIT 0
#define IRPORT PORTA
#else
#ifdef C12
    BANKSEL TRISB
    movlw   b'11011011'      ;set B2 & B5 led to output
    movwf   TRISB
    BANKSEL PORTB
#define IRBIT 2              
#define IRPORT PORTB
#else
#ifdef M8X16
#define IRBIT 1              
#define IRPORT PORTC
#else
#ifdef M3X3
    setbank1
    movlw   b'00111001'      ;set A1 & A2 led to output
    movwf   TRISA
    setbank0
#define IRBIT 1
#define IRPORT PORTA
#else
#ifdef SRGB
#define IRBIT 1
#define IRPORT PORTA
#else
#define IRBIT 4
#define IRPORT PORTA
#endif
#endif
#endif
#endif
#endif
#endif
#endif

    banksel     IRPORT
    clrf        IRPORT
    bsf         IRPORT,IRBIT                     ; A01

    call        get_next_tx_bit             ; 2 + 11 cycles  A04-A16
;    mult_nop d'9' ; A17-A25
    movlw       01h
    call        qdelay           ; 6 + (1 * 3) = 9 ; A17-A25
    nop

    movlw           0x1E                    ; C26  (23)
    movwf           repeat                  ; C27
repeat_loop
    bcf         IRPORT,IRBIT                         ; D01

;    mult_nop d'26' ; D02-D27
    movlw       07h
    call        qdelay           ; 6 + (7 * 3) = 27 ; D02-D27

    bsf         IRPORT,IRBIT                         ; E01  (27)

;    mult_nop d'23' ; E02-E24
    movlw       06h              ; 6+(6 * 3) = 22 ; E02-E24
    call qdelay

    decfsz      repeat,f                    ; E25      (24)
    goto        repeat_loop                    ; E26/E27

    bcf         IRPORT,IRBIT
    goto        exit_tx

;--------------------------------------------------------------------------------------
send_zero  ; we are going to release all the CPU time to the main line for display.
;--------------------------------------------------------------------------------------

    call        get_next_tx_bit             ; 2 + 11 cycles  A04-A16
    goto        drive_main_leds
#endif
;--------------------------------------------------------------------------------------
send_nothing ; Drive the main LEDs.
;--------------------------------------------------------------------------------------


;    call        read_ir_in
;#ifdef DEDICATED_BUTTON
    call        read_button_in
;   clrf        button
;   btfss       PORTA,2          ; 2
;   bsf         button,0         ; 3
;   btfss       PORTA,4          ; 2
;   bsf         button,1         ; 3
;#endif
#ifdef SRGB_mtouch
    call read_mtouch_in
#endif
;   goto        drive_main_leds   

;--------------------------------------------------------------------------------------
drive_main_leds ; Drive the main LEDs.
;--------------------------------------------------------------------------------------
	var fcount

#include <LED_storage.asm>

#ifndef M8X16
    var_all_bank Ax_dir
#endif
#ifdef C19
    var_all_bank Cx_dir
#endif
#ifdef CAFFEINE
    var_all_bank Cx_dir
#endif
#ifdef BADGE_G2
    var_all_bank Cx_dir
#endif
#ifdef SRGB
    var_all_bank Cx_dir
#endif
#ifdef C12RGB
    var_all_bank Cx_dir
#endif
#ifdef M5X7
    var_all_bank Cx_dir
#endif
#ifdef M7X8
    var_all_bank Cx_dir
#endif
#ifdef C12
    var_all_bank Bx_dir
#endif

;
; This is the number of times the display logic should cycle before exiting. It's been hand timed from the
; start of the interupt to the end to be around 800usec. This leaves 90 usec for the main loop.
; The 19 stick has an extra display line strobe cycle.
;

    movlw   DELAYTIMER
    movwf   fcount

#ifdef C19
    movlw   b'00101000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir
    clrf    Cx_dir          ;set LED matrix pins to input (tri-stated)
#else
#ifdef D10
    movlw   b'00101000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir
#else
#ifdef SRGB
#ifdef SRGB_mtouch
    movlw   b'00111011'     ;mtouch has A0,A1 and A4 as inputs.
#else
    movlw   b'00111000'     ;set LED matrix pins to input (tri-stated)
#endif
    movwf   Ax_dir
    clrf    Cx_dir          ;set LED matrix pins to input (tri-stated)
#else
#ifdef C12
    clrf    Ax_dir     ;set LED matrix pins to input (tri-stated)
    clrf    Bx_dir
#else
#ifdef BADGE_G2
    movlw   b'11111000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir    ; A0,A1,A2
    movwf   Cx_dir    ; C0,C1,C2
#else
#ifdef M5X7
    movlw   b'00101000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir    ; A3,A5 inputs
    clrf    Cx_dir
#else
#ifdef M7X8
    movlw   b'00001000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir    ; A3 inputs
    clrf    Cx_dir
#else
#ifdef CAFFEINE
    movlw   b'00001100'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir    ; A2,A3 inputs
    clrf    Cx_dir
#else
#ifdef C12RGB
    movlw   b'00010100'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir
    clrf    Cx_dir          ;set LED matrix pins to input (tri-stated)
#else    
#ifndef M8X16
    movlw   b'00001000'     ;set LED matrix pins to input (tri-stated)
    movwf   Ax_dir
#endif ; not M8X16
#endif ; C12RGB
#endif ; Caffeine
#endif ; M7x8
#endif ; M5x7
#endif ; BADGE_G2
#endif ; C12
#endif ; SRGB
#endif ; D10
#endif ; C19


;    call    get_state_tbl_hi_address
;    call    get_state_tbl_low_address
;    call    go_state_table
;    call    set_max_state

;   turn off the LEDs
    banksel      PORTA
    clrf         PORTA

    banksel      dcycle
    movfw        dcycle
    brw
    goto         display_cycle0
    goto         display_cycle1
    goto         display_cycle2
#if ( STROBE_LINES > 3 )
    goto         display_cycle3
#if ( STROBE_LINES > 4 )
    goto         display_cycle4
#if ( STROBE_LINES > 5 )
    goto         display_cycle5
#if ( STROBE_LINES > 6 )
    goto         display_cycle6
#if ( STROBE_LINES > 7 )
    goto         display_cycle7
#if ( STROBE_LINES > 8 )
    goto         display_cycle8
#if ( STROBE_LINES > 9 )
    goto         display_cycle9
    goto         display_cycle10
    goto         display_cycle11
#if ( STROBE_LINES > 0x0c )
    goto         display_cycle12
    goto         display_cycle13
    goto         display_cycle14
    goto         display_cycle15
#endif ; 0x0c
#endif ; 9
#endif ; 8
#endif ; 7
#endif ; 6
#endif ; 5
#endif ; 4
#endif ; 3
return_display_cycle
;--------------------------------------------------------------------------------------
exit_tx
;--------------------------------------------------------------------------------------

    banksel    PORTA
    clrf       PORTA
#ifndef __12F1822
#ifndef __16F1824
#ifndef __16F1454
#ifndef __16F18324
#ifndef __16F18313
    clrf       PORTB
#endif
#endif
#endif
#endif
#endif
#ifdef __16F1824
    clrf       PORTC
#endif

;   clear timer0 interupt

#ifdef __16F18324
    BANKSEL     PIR0
    bcf         PIR0,TMR0IF
#else
#ifdef __16F18313
        BANKSEL     PIR0
    bcf         PIR0,TMR0IF
#else
    bcf         INTCON,TMR0IF
#endif
#endif
    
; restore state, return form interupt

exit_int
    retfie                  ; return from interrupt

