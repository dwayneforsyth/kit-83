;**********************************************************************
;   Copyright (C) 2005,2006,2007 Dwayne Forsyth
;                                 
;   This program is free software; you can redistribute it and/or
;   modify it under the terms of the GNU General Public License
;   as published by the Free Software Foundation; either version 2
;   of the License, or (at your option) any later version.
; 
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program; if not, write to the
; 
;      Free Software Foundation, Inc.
;      51 Franklin Street, Fifth Floor
;      Boston, MA  02110-1301, USA.
;
;**********************************************************************

;**********************************************************************
table_type_28
;**********************************************************************
;
;     0         1         2
;  AAAAAAAB BBBBBBBB  BEDDDDDD
;  
;  AAAA AAA - stars - dipper
;  B BBBB BBBB B - Streat lights
;  E - instant on/off flag
;  DD DDDD = cycle counter

    call         get_next_pattern_entry
    movwf        in0

    call         get_next_pattern_entry
    movwf        in1

    call         get_next_pattern_entry
    movwf        in2


;   collected the 6 bits for the delay counter

    clrf         p2count
    
    btfsc        in2,5
    bsf          p2count,7

    btfsc        in2,4
    bsf          p2count,6

    btfsc        in2,3
    bsf          p2count,5

    btfsc        in2,2
    bsf          p2count,4

    btfsc        in2,1
    bsf          p2count,3

    btfsc        in2,0
    bsf          p2count,2

;   check the instant on/off flag.
    movfw        p2count
    btfsc        in2,6
    call         display_1bit

p20_loop
;   run through the up/down bits.

;Star 1
    movlw        high A0_A2_reg
    movwf        FSR0H
    movlw        low A0_A2_reg
    movwf        FSR0L

    btfsc        in0,7
    call         p18_led_up
    btfss        in0,7
    call         p18_led_down

;Star 2
    movlw        high A4_A0_reg
    movwf        FSR0H
    movlw        low A4_A0_reg
    movwf        FSR0L

    btfsc        in0,6
    call         p18_led_up
    btfss        in0,6
    call         p18_led_down

;Star 3
    movlw        high A5_A2_reg
    movwf        FSR0H
    movlw        low A5_A2_reg
    movwf        FSR0L

    btfsc        in0,5
    call         p18_led_up
    btfss        in0,5
    call         p18_led_down

;Star 4
    movlw        high A5_A0_reg
    movwf        FSR0H
    movlw        low A5_A0_reg
    movwf        FSR0L

    btfsc        in0,4
    call         p18_led_up
    btfss        in0,4
    call         p18_led_down
 
;Star 5
    movlw        high A2_A4_reg
    movwf        FSR0H
    movlw        low A2_A4_reg
    movwf        FSR0L

    btfsc        in0,3
    call         p18_led_up
    btfss        in0,3
    call         p18_led_down


;Star 6
    movlw        high A1_A4_reg
    movwf        FSR0H
    movlw        low A1_A4_reg
    movwf        FSR0L

    btfsc        in0,2
    call         p18_led_up
    btfss        in0,2
    call         p18_led_down


;Star 7
    movlw        high A5_A4_reg
    movwf        FSR0H
    movlw        low A5_A4_reg
    movwf        FSR0L

    btfsc        in0,1
    call         p18_led_up
    btfss        in0,1
    call         p18_led_down
 
;Street lamp 1
    movlw        high A0_A5_reg
    movwf        FSR0H
    movlw        low A0_A5_reg
    movwf        FSR0L

    btfsc        in0,0
    call         p18_led_up
    btfss        in0,0
    call         p18_led_down

;Street lamp 2
    movlw        high A4_A1_reg
    movwf        FSR0H
    movlw        low A4_A1_reg
    movwf        FSR0L

    btfsc        in1,7
    call         p18_led_up
    btfss        in1,7
    call         p18_led_down


;Street lamp 3
    movlw        high A1_A5_reg
    movwf        FSR0H
    movlw        low A1_A5_reg
    movwf        FSR0L

    btfsc        in1,6
    call         p18_led_up
    btfss        in1,6
    call         p18_led_down
 
;Street lamp 4
    movlw        high A0_A4_reg
    movwf        FSR0H
    movlw        low A0_A4_reg
    movwf        FSR0L

    btfsc        in1,5
    call         p18_led_up
    btfss        in1,5
    call         p18_led_down

;Street lamp 5
    movlw        high A2_A5_reg
    movwf        FSR0H
    movlw        low A2_A5_reg
    movwf        FSR0L

    btfsc        in1,4
    call         p18_led_up
    btfss        in1,4
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;Street lamp 6
    movlw        high A2_A1_reg
    movwf        FSR0H
    movlw        low A2_A1_reg
    movwf        FSR0L

    btfsc        in1,3
    call         p18_led_up
    btfss        in1,3
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;Street lamp 7
    movlw        high A1_A2_reg
    movwf        FSR0H
    movlw        low A1_A2_reg
    movwf        FSR0L

    btfsc        in1,2
    call         p18_led_up
    btfss        in1,2
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;Street lamp 8
    movlw        high A2_A0_reg
    movwf        FSR0H
    movlw        low A2_A0_reg
    movwf        FSR0L

    btfsc        in1,1
    call         p18_led_up
    btfss        in1,1
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;Street lamp 9
    movlw        high A5_A1_reg
    movwf        FSR0H
    movlw        low A5_A1_reg
    movwf        FSR0L

    btfsc        in1,0
    call         p18_led_up
    btfss        in1,0
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;Street lamp 10
    movlw        high A1_A0_reg
    movwf        FSR0H
    movlw        low A1_A0_reg
    movwf        FSR0L

    btfsc        in2,7
    call         p18_led_up
    btfss        in2,7
    call         p18_led_down

    movf         pspeed,w
    call         strobe_delay

;   This is a quick hack, because without this button presses are not seen for minutes
;   This early exit might impact the pattern getting displayed.
;
    btfsc        button,1    ; if putton pressed show pattern id
    goto         t20_exit

    btfsc        IR_in_good,0
    goto         t20_exit

    decfsz       p2count,f
    goto         p20_loop

t20_exit
    return

;**********************************************************************
p18_led_up
;**********************************************************************

    incf        INDF0,f
    btfsc       STATUS,Z
    comf        INDF0,f
    return

;**********************************************************************
p18_led_down
;**********************************************************************

    movf        INDF0,f
    btfss       STATUS,Z
    decf        INDF0,f
    return

