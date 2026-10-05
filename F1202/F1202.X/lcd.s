#include <xc.inc>
#include "common.inc"
#include "lcd.inc"

PSECT udata_bank0
; used in write_lcd
scratchA:
    DS 1
scratchB:
    DS 1

; set boundary so that we only need to add to FSR0L witout worrying about MSB
PSECT data,delta=2,reloc=128
; Each 7 bytes is a single symbol, this has 8 symbols
customChar_clock:
    DB 0x00, 0x0e, 0x11, 0x15, 0x15, 0x0e, 0x00
    DB 0x00, 0x0e, 0x11, 0x15, 0x19, 0x0e, 0x00
    DB 0x00, 0x0e, 0x11, 0x1d, 0x11, 0x0e, 0x00
    DB 0x00, 0x0e, 0x19, 0x15, 0x11, 0x0e, 0x00
    DB 0x00, 0x0e, 0x15, 0x15, 0x11, 0x0e, 0x00
    DB 0x00, 0x0e, 0x13, 0x15, 0x11, 0x0e, 0x00
    DB 0x00, 0x0e, 0x11, 0x17, 0x11, 0x0e, 0x00
    DB 0x00, 0x0e, 0x11, 0x15, 0x13, 0x0e, 0x00

PSECT code,delta=2
; used exclusivally with finding the index into an animated custom character
; supports up to 10 animation, add as needed
lcdCharMultiplyTable:
    BRW
    RETLW 0
    RETLW 7
    RETLW 14
    RETLW 21
    RETLW 28
    RETLW 35
    RETLW 42
    RETLW 49
    RETLW 56
    RETLW 63

PSECT lcd,global,class=CODE,delta=2

; assume we are in bank 0
waitForBF:
    COMF TRISA, f	    ; set portA to input to read the busy pin
    BSF LATB, pinLcdRW
    BCF LATB, pinLcdRS
    NOP
waitForBFLoop:
    BCF LATB, pinLcdE
    NOP
    BSF LATB, pinLcdE
    NOP
    BTFSC PORTA, 6	   ; we SHOULD be reading bit 7, but hardware bugs....
    GOTO waitForBFLoop
    ; revert back to writing mode
    BCF LATB, pinLcdE
    BCF LATB, pinLcdRW
    CLRF TRISA
    RETURN


; uses 0x20 in Bank 0 as scratch register
; uses 0x21 in Bank 0 as scratch register
; assumes input is in W register
; assumes we are already in bank0 (for IO)
write_lcd:
    BCF LATB, pinLcdE
    ; operate a hack where we flip bits 7 and 6, due to issue in hardware
    ; who said nothing can be fixed with software?? (seriously this is a poopy hw bug)
    MOVWF scratchA
    MOVWF scratchB
    MOVLW 0xC0
    ANDWF scratchA, f
    RLF scratchA, f
    BTFSC CARRY
    BSF scratchA, 6
    MOVLW 0x3F
    ANDWF scratchB, w
    IORWF scratchA, w
    ; end of hack
    MOVWF LATA
    BSF LATB, pinLcdE
    NOP
    BCF LATB, pinLcdE
    NOP
    CALL waitForBF
    RETURN

lcdInit:
    BANKSEL(LATB)
    ; set to always write data
    BCF LATB, pinLcdRW
    BCF LATB, pinLcdRS
    ; wait for LCD module to initalize
    CALL waitForBF
    delayMs 20
    ; init lcd
    MOVLW 0x30
    CALL write_lcd
    delayMs 10
    MOVLW 0x30
    CALL write_lcd
    delayMs 10
    MOVLW 0x30
    CALL write_lcd
    delayMs 10
    MOVLW 0x06
    CALL write_lcd
    MOVLW 0x0C
    CALL write_lcd
    RETURN

lcdClear:
    BANKSEL(LATB)
    MOVLW 0x01
    CALL write_lcd
    delayMs 50
    RETURN

lcdHome:
    BANKSEL(LATB)
    MOVLW 0x02
    CALL write_lcd
    delayMs 50
    RETURN

; set what to write in W reg
lcdWrite:
    BANKSEL(LATB)
    BSF LATB, pinLcdRS
    CALL write_lcd
    RETURN

; set the DDRAM in argA
lcdSetDDRAMAddr:
    ; mask input and set bit 7
    MOVLW 0x7F
    ANDWF argA, f
    BSF argA, 7
    MOVF argA, w
    BANKSEL(LATB)
    BCF LATB, pinLcdRS
    CALL write_lcd
    RETURN

; store the lcd custom char index in argA
; store the index into the clock in argB
lcdLoadClockChar:
    MOVLW 0x80 | HIGH(customChar_clock)
    MOVWF FSR0H
    MOVF argB, w
    CALL lcdCharMultiplyTable
    MOVWF argB
    MOVLW LOW(customChar_clock)
    ADDWF argB, w
    MOVWF FSR0L
    ; the lcd character index is already in argA per this call
    CALL lcdLoadCustomChar
    RETURN
    

; set the character index on the LCD in argA
; set the start of the 5 characters in ROM in FSR0
lcdLoadCustomChar:
    BANKSEL(LATB)
    ; set the address
    BCF LATB, pinLcdRS
    ; right shift 3 timers
    LSRF argA, f
    LSRF argA, f
    LSRF argA, f
    MOVLW 0x3F    
    ANDWF argA, f
    BSF argA, 6
    MOVF argA, w
    CALL write_lcd
    ; write the 7 bytes of data
    ; as we are done with argA, re-use that for a counter
    MOVLW (7-1)
    MOVWF argA
lcdLoadCustomChar_loop:
    BSF LATB, pinLcdRS
    MOVIW FSR0++
    CALL write_lcd
    delayUs 10
    DECF argA
    BTFSS ZERO
    GOTO lcdLoadCustomChar_loop
    ; clear the cursor
    BSF LATB, pinLcdRS
    CLRW
    CALL write_lcd
    delayUs 10
    RETURN