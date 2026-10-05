; PIC16F18155 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FEXTOSC = OFF         ; External Oscillator Selection bits (Oscillator not enabled)
  CONFIG  RSTOSC = HFINTOSC_16MHz; Reset Oscillator Selection bits (HFINTOSC (1MHz))
  CONFIG  CLKOUTEN = OFF        ; Clock Out Enable bit (CLKOUT function is disabled; i/o or oscillator function on OSC2)
  CONFIG  CSWEN = ON            ; Clock Switch Enable bit (Writing to NOSC and NDIV is allowed)
  CONFIG  VDDAR = HI            ; VDD Range Analog Calibration Selection bit (Internal analog systems are calibrated for operation between VDD = 2.3 - 5.5V)
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)

; CONFIG2
  CONFIG  MCLRE = EXTMCLR       ; Master Clear Enable bit (If LVP = 0, MCLR pin is MCLR; If LVP = 1, RA3 pin function is MCLR)
  CONFIG  PWRTS = PWRT_64       ; Power-up Timer Selection bits (PWRT set at 64 ms)
  CONFIG  LPBOREN = OFF         ; Low-Power BOR Enable bit (ULPBOR disabled)
  CONFIG  BOREN = OFF           ; Brown-out Reset Enable bits (Brown-out Reset enabled, SBOREN bit is ignored)
  CONFIG  DACAUTOEN = OFF       ; DAC Buffer Automatic Range Select Enable bit (DAC Buffer reference range is determined by the REFRNG bit)
  CONFIG  BORV = HI             ; Brown-out Reset Voltage Selection bit (Brown-out Reset Voltage (VBOR) is set to 2.85V)
  CONFIG  ZCD = OFF             ; ZCD Disable bit (ZCD module is disabled; ZCD can be enabled by setting the ZCDSEN bit of ZCDCON)
  CONFIG  PPS1WAY = OFF         ; PPSLOCKED One-Way Set Enable bit (The PPSLOCKED bit can be set and cleared as needed (unlocking sequence is required))
  CONFIG  STVREN = ON           ; Stack Overflow/Underflow Reset Enable bit (Stack Overflow or Underflow will cause a reset)
  CONFIG  DEBUG = ON            ; Background Debugger (background debugger enabled)

; CONFIG3
  CONFIG  WDTCPS = WDTCPS_3     ; WDT Period Select bits (Divider ratio 1:256)
  CONFIG  WDTE = OFF            ; WDT Operating Mode bits (WDT Disabled, SEN is ignored)
  CONFIG  WDTCWS = WDTCWS_6     ; WDT Window Select bits (window always open (100%); no software control; keyed access required)
  CONFIG  WDTCCS = LFINTOSC     ; WDT Input Clock Select bits (WDT reference clock is the 31.0 kHz LFINTOSC)

; CONFIG4
  CONFIG  BBSIZE = BB512        ; Boot Block Size Selection bits (512 words boot block size)
  CONFIG  BBEN = OFF            ; Boot Block Enable bit (Boot Block disabled)
  CONFIG  SAFEN = OFF           ; Storage Area Flash (SAF) Enable bit (SAF disabled)
  CONFIG  WRTAPP = OFF          ; Application Block Write Protection bit (Application Block is NOT write protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot Block is NOT write protected)
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration Register is NOT write protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is NOT write protected)
  CONFIG  WRTSAF = OFF          ; Storage Area Flash (SAF) Write Protection bit (SAF is NOT write protected)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (Low Voltage programming enabled. MCLR/Vpp pin function is MCLR. MCLRE Configuration bit is ignored)

; CONFIG5
  CONFIG  CP = OFF              ; Program Flash Memory Code Protection bit (Program Flash Memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM code protection is disabled)


