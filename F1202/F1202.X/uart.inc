RX_FIFO_SIZE	EQU	32		    // must be power of 2
RX_FIFO_MASK	EQU	(RX_FIFO_SIZE-1)
TX_FIFO_SIZE	EQU	32		    // must be power of 2
TX_FIFO_MASK	EQU	(TX_FIFO_SIZE-1)

; uartFifoInit
;   Initializes any UART related FIFO variables and whatnot
;
GLOBAL uartFifoInit

; receivedUart
;   Gets called in ISR service to receive the byte from peripheral, and
;   puts it in the receive FIFO
GLOBAL receivedUart

; isRxUartAvailable
;   Sets the Z register if there isn't any bytes to be read out from the FIFO
; Returns: not-zero if there is any bytes to be read. Uses the Z register, so
;          it should be checked immediatly after this is called
GLOBAL isRxUartAvailable

; getUartRxFifo
;   Gets the last received UART character from the FIFO
;
; NOTE: Must check isRxUartAvailable before calling this
;
; Returns: The last received value in the W register
GLOBAL getUartRxFifo

; txByteWait
;   Sends a byte directly, no FIFO
;   Was used manually, to remove at some point
;
; Args:
;   w - the byte to send out (no fifo)
;
GLOBAL txByteWait

; uartTxByte
;   Sends a UART byte
;
; Args:
;   w - the byte to send out
;
GLOBAL uartTxByte

; isTxUartAvailable
;   Sets the Z register depending if we have something available to transmit
GLOBAL isTxUartAvailable

; putUartTx
;   Call this to put a TX from the FIFO unto the output registere
GLOBAL putUartTx