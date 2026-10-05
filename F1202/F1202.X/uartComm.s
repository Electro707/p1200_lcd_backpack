#include <xc.inc>
#include "uart.inc"
#include "uartComm.inc"
#include "lcd.inc"

GLOBAL argA

ACK EQU		06h
NACK EQU		15h

ESCAPE	EQU	1Bh

FLAG_RECV_IS_ESCAPE	EQU	0

// enum for receiver state machine
RECV_STATE_NOP	    EQU	    0	    // not doing anything
RECV_STATE_CMD	    EQU	    1	    // received CMD, processing
RECV_STATE_WAIT_BYTE EQU    2	    // waiting for a byte(s) to process something

clearState MACRO
    CLRF receiveState
ENDM

txAck MACRO
    MOVLW ACK
    CALL uartTxByte
ENDM

txNack MACRO
    MOVLW NACK
    CALL uartTxByte
ENDM

PSECT udata_bank2
recvByte:
    DS	    1
receiveFlags:
    DS	    1
cmd:
    DS	    1
receiveState:
    DS	    1

PSECT code
GLOBAL cmd, recvByte, receiveState

; clears variables
processUartInit:
    BANKSEL(receiveFlags)
    CLRF receiveFlags
    CLRF cmd
    CLRF receiveState
    RETURN

; value to process, after escaping
deEscaped:
;    MOVF recvByte, w
;    CALL uartTxByte	    ; debug

    ; switch-case for the current state
    MOVLW RECV_STATE_CMD
    XORWF receiveState, w
    BTFSC ZERO
    GOTO deEscaped_recvCmd

    MOVLW RECV_STATE_WAIT_BYTE
    XORWF receiveState, w
    BTFSC ZERO
    GOTO deEscaped_waitByte

    RETURN

deEscaped_recvCmd:
    ; save CMD to register in case we need it later
    MOVF recvByte, w
    MOVWF cmd

    ; depending on the CMD, no other args are required
    MOVLW 0x10
    XORWF cmd, w
    BTFSC ZERO
    GOTO cmd_process_0x10

    MOVLW 0x11
    XORWF cmd, w
    BTFSC ZERO
    GOTO cmd_process_0x11

    MOVLW 0x13
    XORWF cmd, w
    BTFSC ZERO
    GOTO cmd_process_0x13

    ; at this point we have an invalid cmd, so return
    clearState
    txNack
    RETURN

cmd_process_0x10:
    // tell the LCD to go home
    clearState
    CALL lcdClear
    txAck
    RETURN
cmd_process_0x11:
    clearState
    CALL lcdHome
    txAck
    RETURN
cmd_process_0x13:
    // for this, we need 1 more byte to know what to write
    MOVLW RECV_STATE_WAIT_BYTE
    MOVWF receiveState
    RETURN

deEscaped_waitByte:
    // depending on the CMD, no other args are required
    MOVLW 0x13
    XORWF cmd, w
    BTFSC ZERO
    GOTO byte_process_0x13

    ; at this point we have an invalid cmd, so return
    clearState
    txNack
    RETURN

byte_process_0x13:
    ; don't clear receiveState, for as long as we are here, just continue
    ;	    writting to the display
;    clearState
    MOVF recvByte, w
    CALL lcdWrite
    txAck
    RETURN



processUart:
    CALL getUartRxFifo
    BANKSEL(recvByte)
    MOVWF recvByte
    ; if we previously received escape
    BTFSC receiveFlags, FLAG_RECV_IS_ESCAPE
    GOTO prevEscape
    GOTO noPrevEscape
prevEscape:
    ; wether we received it again or not, clear the last-receive escape flag
    BCF	receiveFlags, FLAG_RECV_IS_ESCAPE
    MOVLW ESCAPE
    XORWF recvByte, w
    ; if the receive byte is ESCAPE, treat it like a regular variable
    ; otherwise start the state machine from over
    BTFSS ZERO
    GOTO startNewCmd
    GOTO callDeEscaped
noPrevEscape:
    ; check if we received escape
    MOVLW ESCAPE
    XORWF recvByte, w
    ; if we received escape, keep track, otherwise treat like normal variable
    BTFSC ZERO
    GOTO recvEscape
    GOTO callDeEscaped

startNewCmd:
    MOVLW RECV_STATE_CMD
    MOVWF receiveState
    CALL deEscaped
    GOTO processUartEnd

recvEscape:
    BSF receiveFlags, FLAG_RECV_IS_ESCAPE
    GOTO processUartEnd

callDeEscaped:
    CALL deEscaped
    GOTO processUartEnd

processUartEnd:
    RETURN
