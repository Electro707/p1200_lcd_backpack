# P1200 - LCB Backpack
# WIP

![.misc/IMG_1996.jpg](Image of board on an LCD during development)
*Image of board on an LCD during development*

This project is for a generic LCD backpack, similar to the many ones out there, with some distinct features that lead me to build my own:

- Negative voltage for the LCD Bias
    - This was the biggest reason I made this project, as I had an older LCD that wouldn't work unless the LCD is biased to -2v. This is OK as most LCDs can be biased to -9v below VCC, I think?
- Both 5v and 3.3v power and data compatibility
- UART, SPI, and I2C protocols
- The ability to offload some functionality to this backpack, such as animations on the LCD

# Project Structure:

- E1201: The KiCAD PCB files
- F1202: The firmware folder
- Release: All locked in files

# PCB Jumper and Notes

TODO: this section

# PCB Errata
The ERRATA's for the latest revision PCB can be found in [`ERRATA.md`](ERRATA.md)

# Firmware
The [firmware for this project](F1202/) is targeted towards the MCU on board (PIC16F18155).

To use the project, open it up in MPLAB IDE (v6.35 used), with PIC-AS 4.00 (comes with XC8) and device pack `PIC16F1xxxx_DFP==1.31.465` (other version should be OK, noted for repeatability).

The project is written in assembly.
Why? Why not?
This was mostly for my learning of writing an entire firmware in bare assembly and getting familiar with the PIC architecture. I found it fun.

More info on the firmware, including the communication protocol, can be found in [F1202/README.md](F1202/README.md)

# License
This project is licensed under [GPLv3](LICENSE.md)**

** This excludes the files in `E1201/SparkFun-Qwiic.pretty`, as they [came from the Sparkfun](https://www.sparkfun.com/qwiic)
