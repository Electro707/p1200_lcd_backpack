PROCESSOR 16F18155

// config statements should precede project file includes.
#include "mcuConfig.inc"
#include <xc.inc>
#include "common.inc"
#include "lcd.inc"
#include "uart.inc"
#include "uartComm.inc"

PSECT udata_bank0
lcdAnimUpdateTrig:
    DS 1
lcdClockAnimCnt:
    DS 1
PSECT udata_shr
delayMsTick:
    DS 1
delayUsTick:
    DS 1
argA:
    DS 1
argB:
    DS 1

PSECT resetVec,global,class=CODE,delta=2
resetVec:
    goto main

PSECT interuptVec,global,class=CODE,delta=2
interuptVec:
    ; check if we came from
    BANKSEL(PIR0)
    BTFSC PIR0, PIR0_TMR0IF_POSN
    GOTO isr_timer0
    GOTO isr_check_next1
isr_timer0:
    BCF PIR0, PIR0_TMR0IF_POSN	    ; clear isr flag
    ; lcd interrupt service
    BANKSEL(lcdAnimUpdateTrig)
    MOVF lcdAnimUpdateTrig, f
    BTFSS ZERO
    DECF lcdAnimUpdateTrig
    ; delay timer service
    MOVF delayMsTick, f
    BTFSS ZERO
    DECF delayMsTick

isr_check_next1:
    ; check if we came from UART
    BANKSEL(PIR4)
    BTFSC PIR4, PIR4_RC1IF_POSN
    CALL receivedUart
    GOTO isr_check_next2	// both on conditional and after call

isr_check_next2:
    BANKSEL(PIR4)
    BTFSC PIR4, PIR4_TX1IF_POSN
    GOTO isr_uart_tx
    GOTO isr_end
isr_uart_tx:
    CALL isTxUartAvailable
    BTFSS ZERO
    GOTO isr_uart_tx_available
    GOTO isr_uart_tx_noAvailable
isr_uart_tx_available:
    CALL putUartTx
    GOTO isr_end
isr_uart_tx_noAvailable:
    ; disable tx interrupt if we have no other thing to send
    BANKSEL(PIE4)
    BCF PIE4, PIE4_TX1IE_POSN
    GOTO isr_end

isr_end:
    RETFIE


PSECT code

initGPIO:
    ;--- Analog Select ---
    BANKSEL(ANSELA)
    CLRF ANSELA     ; set all to digital
    CLRF ANSELB     ; set all to digital
    CLRF ANSELC     ; set all to digital
    ;--- LAT and TRIS ---
    BANKSEL(TRISA)
    CLRF LATA
    CLRF TRISA      ; set to all output
    CLRF LATB
    CLRF TRISB      ; set to all output
    CLRF LATB
    BCF	TRISC, TRISC_TRISC6_POSN	    // Uart TX as output
    ;--- PPS ---
    BANKSEL(RX1PPS)
    MOVLW  00010111B	   // RC7 to RX1
    MOVWF RX1PPS
    BANKSEL(RC6PPS)
    MOVLW  13h		   // TX1 to RC6
    MOVWF RC6PPS
    RETURN

initUart:
    BANKSEL(TX1STA)
    MOVLW   20h         ; low speed, enable TX
    MOVWF TX1STA
    MOVLW   12	        ; for 19200 baud
    CLRF SP1BRGH
    MOVWF SP1BRGL
    MOVLW   90h         ; enable serial, enable rx
    MOVWF RC1STA
    ; enable interrupts
    BANKSEL(PIE4)
    BSF PIE4, PIE4_RC1IE_POSN
    RETURN

initMsTimer:
    BANKSEL(T0CON0)
    MOVLW 0b01000101	; Focs / 4, sync, 1/32 prescaler
    MOVWF T0CON1
    MOVLW 125		; for a 1mS tick
    MOVWF TMR0H
    BSF T0CON0, T0CON0_EN_POSN	   ; enable timer
    ; enable interrupt
    BANKSEL(PIE0)
    BSF PIE0, PIE0_TMR0IE_POSN
    RETURN

main:
    CALL initGPIO
    CALL initUart
    CALL initMsTimer

    CALL processUartInit
    CALL uartFifoInit
    
    BANKSEL(lcdAnimUpdateTrig)
    CLRF lcdAnimUpdateTrig
    CLRF lcdClockAnimCnt
    
    ; enable global interrupts
    ; must be done before LCD init due to delay used
    BANKSEL(INTCON)
    BSF INTCON, INTCON_PEIE_POSN
    BSF INTCON, INTCON_GIE_POSN

    CALL lcdInit
    CALL lcdClear

    CLRF argA
    CLRF argB
    CALL lcdLoadClockChar
  
    CLRF argA
    CALL lcdSetDDRAMAddr
    
    CALL lcdClear

    // abc test
    MOVLW 0x41
    CALL lcdWrite
    MOVLW 0x42
    CALL lcdWrite
    MOVLW 0x43
    CALL lcdWrite
    MOVLW 0x44
    CALL lcdWrite
    MOVLW 0x00
    CALL lcdWrite

    ; test, send out a byte
;    MOVLW 40h
;    CALL uartTxByte
    ; CALL txByteWait
    ; MOVLW 5ah
    ; CALL txByteWait
    ; MOVLW 0xa5h
    ; CALL txByteWait
    ; MOVLW 20h
    ; CALL txByteWait

loop:
    CALL isRxUartAvailable
    BTFSS ZERO
    // we have something on UART, get it
    CALL processUart
    
    BANKSEL(lcdAnimUpdateTrig)
    MOVF lcdAnimUpdateTrig, f
    BTFSC ZERO
    GOTO lcd_trig
    GOTO after_lcd_trig
lcd_trig:
    INCF lcdClockAnimCnt
    MOVLW 0b111
    ANDWF lcdClockAnimCnt, w
    MOVWF argB
    MOVWF lcdClockAnimCnt
    CLRF argA
    CALL lcdLoadClockChar
    
    // load next time
    MOVLW   250
    MOVWF lcdAnimUpdateTrig
after_lcd_trig:
    NOP 
    
    CLRWDT
    GOTO loop

END resetVec