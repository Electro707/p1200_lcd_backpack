; PORTB pins
pinLcdE EQU 3
pinLcdRS EQU 5
pinLcdRW EQU 4

GLOBAL argA, argB
GLOBAL delayMsTick, delayUsTick
    
delayUs MACRO t
    MOVLW t
    MOVWF delayUsTick
    CALL delayUsCall
ENDM

delayMs MACRO t
    MOVLW t
    MOVWF delayMsTick
    CALL delayMsCall
ENDM

GLOBAL delayUsCall, delayMsCall