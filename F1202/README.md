# F1202 Detailed Document

This firmware is designed to run on a PIC16F18154 on a E1201 PCBA

## UART Protocol

This firmware speaks over 19200 8N1 serial.

This uses an escape frame sequence, with the escape key (0x1B) serving as the escape code.

Responses are ACK (0x06) for successful command execution, or NACK (0x15) for invalid commands or arguments

The fist byte is the command, which the following are available. Anything with a {N} means it's not implemented yet
- {N}0x01: Get firmware name
- 0x1x: LCD direct commands
    - 0x10: Clear and home
    - 0x11: Go home
    - {N}0x12: Set DRAM position
        - 1 byte argument
    - 0x13: Write to display
        - N byte, continuous
        - An ACK is sent every byte, and directly updates the LCD
    - {N}0x1A: Set CGRAM address
        - 1 byte
    - {N}0x1B: Set CGRAM data
        - 5 bytes
- {N}0x2x: Backlight commands
    - 0x20: Turn off backlight
    - 0x21: Turn on regular backlight
    - 0x22: Turn on RGB backlight
    - 0x23: Set regular (R) backlight PWM
        - 1 byte argument
    - 0x24: Set G backlight PWM
        - 1 byte argument
    - 0x25: Set B backlight PWM
        - 1 byte argument

## SPI Protocol

TODO

## I2C Protocol

TODO
