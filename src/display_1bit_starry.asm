;**********************************************************************
display_1bit ; 20 LEDs
;**********************************************************************

    movwf        speed              ;w has the speed/delay

	clrf		 A0_A2_reg        ; 00
    btfsc        in0,7
	comf		 A0_A2_reg,f

	clrf		 A4_A0_reg        ; 01
    btfsc        in0,6
	comf		 A4_A0_reg,f

	clrf		 A5_A2_reg        ; 02
    btfsc        in0,5
	comf		 A5_A2_reg,f

	clrf		 A5_A0_reg        ; 03
    btfsc        in0,4
	comf		 A5_A0_reg,f

	clrf		 A2_A4_reg        ; 04
    btfsc        in0,3
	comf		 A2_A4_reg,f

	clrf	 	 A1_A4_reg        ; 05
    btfsc        in0,2
	comf	 	 A1_A4_reg,f

	clrf		 A5_A4_reg        ; 06
    btfsc        in0,1
	comf		 A5_A4_reg,f

	clrf		 A0_A5_reg        ; 07
    btfsc        in0,0
	comf		 A0_A5_reg,f
 
	clrf	 	 A4_A1_reg        ; 08
    btfsc        in1,7
    comf         A4_A1_reg,f

	clrf		 A1_A5_reg        ; 09
    btfsc        in1,6
	comf		 A1_A5_reg,f

	clrf		 A0_A4_reg        ; 10
    btfsc        in1,5
	comf		 A0_A4_reg,f
 
	clrf	 	 A2_A5_reg        ; 11
    btfsc        in1,4
	comf	 	 A2_A5_reg,f

	clrf		 A2_A1_reg        ; 12
    btfsc        in1,3
    comf         A2_A1_reg,f

	clrf		 A1_A2_reg        ; 13
    btfsc        in1,2
	comf		 A1_A2_reg,f

	clrf	 	 A2_A0_reg        ; 14
    btfsc        in1,1
	comf	 	 A2_A0_reg,f

	clrf		 A5_A1_reg        ; 15
    btfsc        in1,0
	comf		 A5_A1_reg,f

	clrf		 A1_A0_reg        ; 16
    btfsc        in2,7
	comf		 A1_A0_reg,f

    movf         speed,w
    call         strobe_delay

    return

