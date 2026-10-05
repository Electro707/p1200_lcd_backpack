#include <xc.inc>
#include "uart.inc"

PSECT udata_bank1
tmpA:
    DS      1
uartRxFifoIn:
    DS	    1
uartRxFifoOut:
    DS	    1
uartTxFifoIn:
    DS	    1
uartTxFifoOut:
    DS	    1

; ok for these variables to live in any uart PSEC due to FSR usage
PSECT udata
uartTxFifo:
    DS	    RX_FIFO_SIZE
uartRxFifo:
    DS	    RX_FIFO_SIZE

PSECT code

addAndMaskFifoCnt MACRO reg, mask
    MOVF reg, w
    ADDLW 1
    ANDLW mask
    MOVWF reg
ENDM

uartFifoInit:
    BANKSEL(uartRxFifoIn)
    CLRF uartRxFifoIn
    CLRF uartRxFifoOut
    CLRF uartTxFifoIn
    CLRF uartTxFifoOut
    RETURN

uartTxByte:
    BANKSEL(uartTxFifoIn)
    MOVWF tmpA
    // find out where in the UART buffer we are at to index to
    MOVLW HIGH(uartTxFifo)	// move itteral, i.e address
    MOVWF FSR0H
    MOVLW LOW(uartTxFifo)		// move itteral, i.e address
    ADDWF LOW(uartTxFifoIn), w	// add input offset
    MOVWF FSR0L
    MOVF tmpA, w
    MOVWI 0[FSR0]
    ; increment and mask the IN counter
    addAndMaskFifoCnt uartTxFifoIn, TX_FIFO_MASK
    ; enable tx interrupt
    BANKSEL(PIE4)
    BSF PIE4, PIE4_TX1IE_POSN
    RETURN

txByteWait:
    BANKSEL(PIR4)
txByteWait_wait:                    ; wait loop for last UART sending
    BTFSS PIR4, PIR4_TX1IF_POSN
    goto txByteWait_wait
    BANKSEL(TX1REG)
    MOVWF TX1REG
    RETURN

// gets called when we received something from the ISR
// record unto a buffer until later
receivedUart:
    BANKSEL(uartRxFifoIn)
    // find out where in the UART buffer we are at to index to
    MOVLW HIGH(uartRxFifo)	// move itteral, i.e address
    MOVWF FSR0H
    MOVLW LOW(uartRxFifo)		// move itteral, i.e address
    ADDWF LOW(uartRxFifoIn), w	// add input offset
    MOVWF FSR0L
    // get the variable in W and store at FSR0
    BANKSEL(RC1REG)
    MOVF RC1REG, w
    MOVWI 0[FSR0]
    // increment the input buffer and AND with the mask
    BANKSEL(uartRxFifoIn)
    addAndMaskFifoCnt uartRxFifoIn, RX_FIFO_MASK
    RETURN

// 0 if there is nothing available, anything else if there is
// the Z flag can be checked for this
isRxUartAvailable:
    BANKSEL(uartRxFifoIn)
    MOVF uartRxFifoIn, w
    SUBWF uartRxFifoOut, w
    RETURN

// 0 if there is nothing available, anything else if there is
// the Z flag can be checked for this
isTxUartAvailable:
    BANKSEL(uartTxFifoIn)
    MOVF uartTxFifoIn, w
    SUBWF uartTxFifoOut, w
    RETURN

// gets the last byte in the W register
getUartRxFifo:
    BANKSEL(uartRxFifoIn)
    MOVLW HIGH(uartRxFifo)	    // move itteral, i.e address
    MOVWF FSR0H
    MOVLW LOW(uartRxFifo)		// move itteral, i.e address
    ADDWF LOW(uartRxFifoOut), w	// add input offset
    MOVWF FSR0L
    addAndMaskFifoCnt uartRxFifoOut, RX_FIFO_MASK
    MOVIW 0[FSR0]
    RETURN

; called by ISR service, used to put a byte to be transmitted out
putUartTx:
    BANKSEL(uartTxFifoOut)
    MOVLW HIGH(uartTxFifo)	    ; move itteral, i.e address
    MOVWF FSR0H
    MOVLW LOW(uartTxFifo)		; move itteral, i.e address
    ADDWF uartTxFifoOut, w	    ; add input offset
    MOVWF FSR0L
    addAndMaskFifoCnt uartTxFifoOut, TX_FIFO_MASK
    MOVIW 0[FSR0]
    BANKSEL(TX1REG)
    MOVWF TX1REG
    RETURN