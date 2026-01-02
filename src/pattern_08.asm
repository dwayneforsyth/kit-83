;**********************************************************************
table_type_8 ; - 19 LED fader
;**********************************************************************

    var          delay1
    var          fad
    var          color


    incf         delay1,f

    movf         delay1,w         ; testing for 0
    btfss        STATUS,Z
    goto         cf8_loop2a

    movlw        TICK_VALUE     ; we are using timer0 for the counts, 0 through tick value is LED off.
    movwf        delay1 
   
;
;   select a pattern
;
    comf         fad,f
    movf         fad,w         ; testing for 0
    btfss        fad,0
    incf         color,f

    movlw        0xFD             ; testing for greater then 3 
    addwf        color,w
    btfsc        STATUS,C
    clrf         color

    nop
cf8_loop2a
    movf        delay1,w         ; fading up
    btfsc       fad,0
	comf        delay1,w         ; fading down

	movwf		 A5_A0_reg        ; 01
	movwf		 A2_A5_reg        ; 02
	movwf		 A5_A2_reg        ; 03
;	movwf		 A4_A5_reg        ; 04
	movwf		 A5_A4_reg        ; 05
	movwf	 	 A1_A5_reg        ; 06
	movwf		 A5_A1_reg        ; 07
        movwf		 A2_A0_reg        ; 08
	movwf	 	 A0_A2_reg        ; 09
	movwf		 A4_A0_reg        ; 10
	movwf		 A0_A4_reg        ; 11
	movwf	 	 A1_A0_reg        ; 12
;	movwf		 A0_A1_reg        ; 13
	movwf		 A4_A2_reg        ; 14
	movwf	 	 A2_A4_reg        ; 15 
	movwf		 A1_A2_reg        ; 16 
	movwf		 A2_A1_reg        ; 17 
	movwf		 A1_A4_reg        ; 18
	movwf		 A4_A1_reg        ; 19 
	movwf		 A0_A5_reg        ; 20 

    movfw       pspeed
    call        strobe_delay

    return
