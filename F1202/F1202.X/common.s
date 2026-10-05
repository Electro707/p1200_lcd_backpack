#include <xc.inc>
#include "common.inc"

PSECT code
; delays by N cycle, where each cycle, in a 16Mhz system, is 250nS
; the cycle number is written in argA
; The way this is written (4 cycles per loop), and due to the 250nS instruction
; clock, this just to happens to track uS plus a 4 cycle overhead, so (W+1)uS
delayUsCall:
    DECF delayUsTick, f
    BTFSS ZERO
    GOTO delayUsCall
    RETURN

; uses the 1mS ISR for time keeping
delayMsCall:
    MOVF delayMsTick, f	    ; check zero
    BTFSS ZERO
    GOTO delayMsCall
    RETURN