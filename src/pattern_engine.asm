;**********************************************************************
setup_pattern_table
;**********************************************************************
   var tbl_hi
   var tbl_low
   var pattern_temp
; New code optimized for new pics   DDF enhancement

  movlw        HIGH MasterTable
  movwf        FSR1H
  movlw        LOW MasterTable
  movwf        FSR1L
  incf         pattern,w
  movwf        pattern_temp

loop
  MOVIW FSR1++
  movwf tbl_hi
  MOVIW FSR1++
  movwf tbl_low
  DECFSZ pattern_temp,1
  goto loop

  movfw tbl_low
  movwf FSR1L
  movfw tbl_hi
  bsf   tbl_hi,7  ;set bit 7 high      (microchip example does not have this?)
  movwf FSR1H
  return

;**********************************************************************
get_next_pattern_entry
;**********************************************************************
;
;  rewrite for new chips using indirect addressing of program flash DDF BUG!!
;


#ifndef NOEEPROM
;   if hi address is 0xf0 pattern is in eeprom.
    movlw        0xf0
    subwf        tbl_hi,w
    btfss        STATUS,Z
    goto         in_mem

;   table in eeprom
    movfw        tbl_low
    addwf        pindex,w

    call         read_eeprom
    
    incfsz       pindex,f
    goto         greturn1
    incf         pindex1,f
    goto         greturn1
#endif

;   table in program memory

in_mem

    MOVIW FSR1++

greturn1
    return


#ifdef DEAD
;**********************************************************************
get_next_pattern_entry_old ; obs code now using IND1 to lookup table entries.
;**********************************************************************
    var          pclath_save
    var          temp2

#ifndef NOEEPROM
;   if hi address is 0x21 pattern is in eeprom   ; This could be F000 now DDF BUG!!
    movlw        0xf0
    subwf        tbl_hi,w
    btfss        STATUS,Z
    goto         glabel1

;   table in eeprom
    movfw        tbl_low
    addwf        pindex,w

    call         read_eeprom
    
    goto         greturn
#endif

;   table in program memory

glabel1

    bcf          INTCON, GIE      ; disable INTs
    movfw        PCLATH
    movwf        pclath_save

    movfw        tbl_hi
    addwf        pindex1,w
    movwf        offset_hi

    bcf          STATUS,C
    movfw        tbl_low
    addwf        pindex,w
    movwf        offset_low

    btfsc        STATUS,C
    incf         offset_hi,f
    call         jump_address

    movwf        temp2
    movfw        pclath_save
    movwf        PCLATH
    movfw        temp2
    bsf          INTCON, GIE      ; enable INTs

greturn
    incfsz       pindex,f
    goto         gskip
    incf         pindex1,f
gskip
    return
#endif

#ifndef NOEEPROM
#ifdef NEWEEPROM
;**********************************************************************
write_eeprom
;   expects EEPROM address and data in pindex and input
;   makes sure previous write (if any) has completed before proceeding
;**********************************************************************

;    return
    
;    BANKSEL NVMCON1
;    btfsc   NVMCON1,WR       ;wait for WR to clear
;    goto    $-1
    
    BANKSEL NVMCON1
    bsf     NVMCON1,NVMREGS

;   select address eeprom starts at 0x70
    BANKSEL NVMADRH
    movlw   0x70
    movwf   NVMADRH
    movf    pindex,w        ;set address
    movwf   NVMADRL
    
    movf    input,w         ;set data
    movwf   NVMDATL
    
;   unlock 
    BANKSEL NVMCON1
    bsf     NVMCON1,WREN     ;enable writes
    movlw   0x55            ;EECON2 = 0x55  ;unlock sequence
    bcf     INTCON, GIE      ; disable INTs
    movwf   NVMCON2
    movlw   0xAA            ;EECON2 = 0xAA  ;unlock sequence
    movwf   NVMCON2
    bsf     NVMCON1,WR       ;initiate a write cycle
    bsf     INTCON, GIE      ; enable INT

    MOVLB 0x00  ; move back to page 0 ram
    
    return    
#else
;**********************************************************************
write_eeprom
;   expects EEPROM address and data in pindex and input
;   makes sure previous write (if any) has completed before proceeding
;**********************************************************************
    BANKSEL EECON1

    btfsc   EECON1,WR       ;wait for WR to clear
    goto    $-1

    bcf     INTCON, GIE     ;disable INTs
    bsf     EECON1,WREN     ;enable writes
    BANKSEL EEADR
    movf    pindex,w        ;set address
    movwf   EEADR
    movf    input,w         ;set data
    movwf   EEDAT
    BANKSEL EECON1
    movlw   0x55            ;EECON2 = 0x55  ;unlock sequence
    movwf   EECON2
    movlw   0xAA            ;EECON2 = 0xAA  ;unlock sequence
    movwf   EECON2
    bsf     EECON1,WR       ;initiate a write cycle
    bsf          INTCON, GIE      ; enable INT

    MOVLB 0x00
    return
#endif __16F18324
    
;**********************************************************************
read_eeprom
;   expects EEPROM address in W
;   returns EEPROM data in W
;   makes sure previous write (if any) has completed before proceeding
;**********************************************************************
#ifdef NEWEEPROM
    
    movwf   FSR0L         ; set indirect pointer to word
    movlw   0x70
    movwf   FSR0H         ; set indirect pointer to word
    moviw   0[FSR0]
    return
#else 
    bcf     INTCON, GIE      ; disable INTs

    BANKSEL EECON1
    btfsc   EECON1,WR       ;wait for WR to clear
    goto    $-1

    bcf     EECON1,WREN     ;disable writes
    BANKSEL EEADR
    movwf   EEADR           ;EEADR = W
    BANKSEL EECON1
    bcf     EECON1,7        ;clear EEPGD
    bsf     EECON1,RD       ;initiate a read cycle
    BANKSEL EEDAT
    movf    EEDAT,w         ;W = EEDAT

    BANKSEL INTCON
    bsf          INTCON, GIE      ; enable INT
    return
#endif ; __16F18324
#endif ; NOEEPROM

#ifndef NOEEPROM    
;**********************************************************************
read_demo_mode
;**********************************************************************

    movlw        LOW demo_store
    call         read_eeprom
    movwf        demo_mode
    return
#endif
    
;**********************************************************************
toggle_demo
;**********************************************************************
#ifndef NOEEPROM
    call         read_demo_mode
#endif
    
    btfss        demo_mode,0          ;
    goto         tdemo_on

;   toggle off
    bcf          demo_mode,0
    goto         tdemo_cont

tdemo_on
    bsf          demo_mode,0

tdemo_cont
    movlw        LOW demo_store
    movwf        pindex
    movfw        demo_mode
    movwf        input
#ifndef NOEEPROM
    call         write_eeprom
#endif
    
;    call         display_pattern_id
;    call         display_pattern_id
    return


;**********************************************************************
pattern_driver
;**********************************************************************

    var pattern
    var tbltype
    var in0
    var in1
    var in2
#if (MAX_IN_STORE > 3)
    var in3
#if (MAX_IN_STORE > 4)
    var in4
    var in5
#if (MAX_IN_STORE > 6)
    var in6
    var in7
    var in8
    var in9
#if (MAX_IN_STORE > 0x0a)
    var ina
    var inb
    var inc
    var ind
    var ine
    var inf
    var in10
    var in11
    var in12
#if (MAX_IN_STORE > d'19')
   var in13
   var in14
   var in15
   var in16
#if (MAX_IN_STORE > d'22')
   var in17
   var in18
   var in19
   var in1a
   var in1b
   var in1c
   var in1d
   var in1e
   var in1f
#endif ; 22
#endif ; 19
#endif ; 10
#endif ; 6
#endif ; 4
#endif ; 3

    var speed
    var pspeed
    var demo_mode
    var psize

    ; need to be able to access from page1 & page2 for eeprom read/write
    var_all_bank pindex          ; pattern index
    var_all_bank pindex1         ; pattern index
    var_all_bank input

ptop
    call         setup_pattern_table

    clrf         pindex
    clrf         pindex1

;   load the table type  
    call         get_next_pattern_entry
    movwf        tbltype
    bcf          tbltype,7     ; using top bit for demo mode.

;   load the speed (someday this will be a table type 1 only thing.)
    call         get_next_pattern_entry
    movwf        pspeed
    incf         pspeed,f          ; adjust so 0 is fastest, not treated like speed 256

; load the table size
    call         get_next_pattern_entry ;4rgb
    movwf        psize                  ;4rgb

ploop0
button_check
; ploop1
    
    banksel      button
    movfw        button      ; if any putton pressed show pattern id
    btfsc        STATUS,Z     
    goto         ploop2    

;    call         display_pattern_id
    call         display_pattern_id
    call         display_pattern_id
    call         display_pattern_id
    
ploop1a

    btfsc        button,1    ; if button 1 pressed inc pattern
    goto         ploop1up

    goto         ptop

ploop1up
    call         next_pattern
    call         display_pattern_id
    call         display_pattern_id
    goto         ploop1a

ploop1down
    call         past_pattern
    call         display_pattern_id
    call         display_pattern_id
    goto         ploop1a

ploop2
#ifdef PATTERN1
    movlw        0x01              ; pattern1
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_1
#endif

#ifdef PATTERN2
    movlw        0x02              ; pattern2
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_2
#endif

#ifdef PATTERN3
    movlw        0x03              ; pattern3
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_3
#endif

#ifdef PATTERN4
    movlw        0x04              ; pattern4
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_4
#endif

#ifdef PATTERN5
    movlw        0x05              ; pattern5
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_5
#endif

#ifdef PATTERN6
    movlw        0x06              ; pattern6
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_6
#endif

#ifdef PATTERN7
    movlw        0x07              ; pattern7
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_7
#endif

#ifdef PATTERN8
    movlw        0x08              ; pattern8
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_8
#endif

#ifdef PATTERN9
    movlw        0x09              ; pattern9
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_9
#endif

#ifdef PATTERN10
    movlw        0x0A              ; pattern10
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_10
#endif

#ifdef PATTERN11
    movlw        0x0B              ; pattern11
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_11
#endif

#ifdef PATTERN12
    movlw        0x0C              ; pattern12
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_12
#endif

#ifdef PATTERN13
    movlw        0x0D              ; pattern13
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_13
#endif

#ifdef PATTERN14
    movlw        0x0E              ; pattern14
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_14
#endif

#ifdef PATTERN15
    movlw        0x0F              ; pattern15
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_15
#endif

#ifdef PATTERN16
    movlw        0x10              ; pattern16
    subwf        tbltype,w
    MOVLP    high table_type_16
    btfsc        STATUS,Z
    call         table_type_16
    MOVLP    high pattern_driver
#endif

#ifdef PATTERN17
    movlw        0x11              ; pattern17
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_17
#endif

#ifdef PATTERN18
    movlw        0x12              ; pattern18
    subwf        tbltype,w
    MOVLP    high table_type_18
    btfsc        STATUS,Z
    call         table_type_18
    MOVLP    high pattern_driver
#endif

#ifdef PATTERN19
    movlw        0x13              ; pattern19
    subwf        tbltype,w
    MOVLP    high table_type_19
    btfsc        STATUS,Z
    call         table_type_19
    MOVLP    high pattern_driver
#endif

#ifdef PATTERN20
    movlw        0x14              ; pattern20
    subwf        tbltype,w
    MOVLP    high table_type_20
    btfsc        STATUS,Z
    call         table_type_20
    MOVLP    high pattern_driver
#endif

#ifdef PATTERN21
    movlw        0x15              ; pattern21
    subwf        tbltype,w
    MOVLP    high table_type_21
    btfsc        STATUS,Z
    call         table_type_21
    MOVLP    high pattern_driver
#endif

#ifdef PATTERN22
    movlw        0x16              ; pattern22
    subwf        tbltype,w
    PAGESEL      table_type_22
    btfsc        STATUS,Z
    call         table_type_22
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN23
    movlw        0x17              ; pattern23
    subwf        tbltype,w
    PAGESEL      table_type_23
    btfsc        STATUS,Z
    call         table_type_23
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN24
    movlw        0x18              ; pattern24
    subwf        tbltype,w
    PAGESEL      table_type_24
    btfsc        STATUS,Z
    call         table_type_24
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN25
    movlw        0x19              ; pattern25
    subwf        tbltype,w
    PAGESEL      table_type_25
    btfsc        STATUS,Z
    call         table_type_25
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN26
    movlw        0x1a              ; pattern26
    subwf        tbltype,w
    PAGESEL      table_type_26
    btfsc        STATUS,Z
    goto         table_type_26     ; to save stack we use "goto" to pattern_return
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN27
    movlw        0x1b              ; pattern27
    subwf        tbltype,w
    PAGESEL      table_type_27
    btfsc        STATUS,Z
    goto         table_type_27     ; to save stack we use "goto" to pattern_return
    PAGESEL      pattern_driver
#endif

#ifdef PATTERN28
    movlw        0x1c              ; pattern28
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_28
#endif

#ifdef PATTERN29
    movlw        0x1d              ; pattern29
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_29
#endif

#ifdef PATTERN30
    movlw        0x1e              ; pattern30
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_30
#endif
#ifdef PATTERN31
    movlw        0x1f              ; pattern31
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_31
#endif
#ifdef PATTERN32
    movlw        0x20              ; pattern32
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_32
#endif
#ifdef PATTERN33
    movlw        0x21              ; pattern33
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_33
#endif
#ifdef PATTERN34
    movlw        0x22              ; pattern34
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_34
#endif
#ifdef PATTERN35
    movlw        0x23              ; pattern35
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_35
#endif
#ifdef PATTERN36
    movlw        0x24              ; pattern36
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_36
#endif
#ifdef PATTERN37
    movlw        0x25              ; pattern37
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_37
#endif
#ifdef PATTERN38
    movlw        0x26              ; pattern38
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_38
#endif
#ifdef PATTERN39
    movlw        0x27              ; pattern39
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_39
#endif
#ifdef PATTERN40
    movlw        0x28              ; pattern40
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_40
#endif
#ifdef PATTERN41
    movlw        0x29              ; pattern40
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_41
#endif
    #ifdef PATTERN42
    movlw        0x2A              ; pattern40
    subwf        tbltype,w
    btfsc        STATUS,Z
    call         table_type_42
#endif

pattern_return

;   count down till next pattern change
    btfss       nextf,1
    goto        ploop3

    bcf         nextf,1
    btfss       demo_mode,0
    goto        ploop2a

    call        next_pattern
    goto        ptop
   
ploop2a
ploop3
    decfsz  psize,f     ;check for end of pattern (4rgb)
    goto    ploop0

    goto        ptop

#define BRIGHT1 0x10
#define BRIGHT2 0x50

#ifdef RANDOM

;**********************************************************************
gen_random
;**********************************************************************

   var     random

   RLF     random,W
   RLF     random,W
   BTFSC   random,4
   XORLW   1
   BTFSC   random,5
   XORLW   1
   BTFSC   random,3
   XORLW   1
   MOVWF   random
   return
#endif
