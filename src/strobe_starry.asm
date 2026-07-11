;-------------------------------------------------------------------------------
display_cycle0
;-------------------------------------------------------------------------------
    MOVLW b'00001000'
    MOVWF Ax_dir

    bsf     Ax_dir,1  
    LedOut  A0_A2_reg,Ax_dir,2    ;LED A0-A2
    LedOut  A0_A4_reg,Ax_dir,4    ;LED A0-A4
    LedOut  A0_A5_reg,Ax_dir,5    ;LED A0-A5


    movf    Ax_dir,w      ;set portA direction
    BANKSEL TRISA
    movwf   TRISA

    BANKSEL PORTA
    movlw   b'00000001'
    movwf   PORTA

    decfsz  fcount,f
    goto    display_cycle0

    goto return_display_cycle

;-------------------------------------------------------------------------------
display_cycle1 ; BC BA BD BE
;-------------------------------------------------------------------------------
    MOVLW b'00001000'
    MOVWF Ax_dir

    LedOut  A1_A0_reg,Ax_dir,0    ;LED A1-A0
    LedOut  A1_A2_reg,Ax_dir,2    ;LED A1-A2
    LedOut  A1_A4_reg,Ax_dir,4    ;LED A1-A4
    LedOut  A1_A5_reg,Ax_dir,5    ;LED A1-A5

    movf    Ax_dir,w      ;set portA direction
    BANKSEL TRISA
    movwf   TRISA

    BANKSEL PORTA
    movlw   b'00000010'
    movwf   PORTA

    decfsz  fcount,f
    goto    display_cycle1

    goto return_display_cycle

;-------------------------------------------------------------------------------
display_cycle2 ; AB AC AD AE
;-------------------------------------------------------------------------------
    MOVLW b'00001000'
    MOVWF Ax_dir

    LedOut  A2_A0_reg,Ax_dir,0    ;LED A2-A0
    LedOut  A2_A1_reg,Ax_dir,1    ;LED A2-A1
    LedOut  A2_A4_reg,Ax_dir,4    ;LED A2-A4
    LedOut  A2_A5_reg,Ax_dir,5    ;LED A2-A5

    movf    Ax_dir,w      ;set portA direction
    BANKSEL TRISA
    movwf   TRISA

    BANKSEL PORTA
    movlw   b'00000100'
    movwf   PORTA

    decfsz  fcount,f
    goto    display_cycle2

    goto return_display_cycle

;-------------------------------------------------------------------------------
display_cycle3 ; DC 
;-------------------------------------------------------------------------------
    MOVLW b'00001000'
    MOVWF Ax_dir

    LedOut  A4_A0_reg,Ax_dir,0    ;LED     A4-A0
    LedOut  A4_A1_reg,Ax_dir,1    ;LED     A4-A1
    bsf     Ax_dir,2  
    bsf     Ax_dir,5  

    movf    Ax_dir,w      ;set portA direction
    BANKSEL TRISA
    movwf   TRISA

    BANKSEL PORTA
    movlw   b'00010000'
    movwf   PORTA

    decfsz  fcount,f
    goto    display_cycle3

    goto return_display_cycle

;-------------------------------------------------------------------------------
display_cycle4 ; C
;-------------------------------------------------------------------------------
    MOVLW b'00001000'
    MOVWF Ax_dir

    LedOut  A5_A0_reg,Ax_dir,0    ;LED A5-A0
    LedOut  A5_A1_reg,Ax_dir,1    ;LED A5-A1
    LedOut  A5_A2_reg,Ax_dir,2    ;LED A5-A2
    LedOut  A5_A4_reg,Ax_dir,4    ;LED A5-A4

    movf    Ax_dir,w      ;set portA direction
    BANKSEL TRISA
    movwf   TRISA

    BANKSEL PORTA
    movlw   b'00100000'
    movwf   PORTA

    decfsz  fcount,f
    goto    display_cycle4

    goto return_display_cycle

