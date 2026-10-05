# F1202 Notes

> These are notes I wrote down when developing the firmware. Some of them may be handy, some not ¯\_(ツ)_/¯

Each cycle in our system is 250nS (16 Mhz / 4)

according to hd444780:
- the data setup time 80nS, so 1 cycle is ok.
- PWEH is 230nS, so best to have another NOP if we are running back-to-back commands with no data change, but shouldn't be needed
- Setup time is 60nS, so more than enough for 1 cycle

We are using the busy pin, so that is the waiting mechanism in our system.

When writing data, there is a 4uS delay on top of the BUSY pin going LOW due to tADD, so that has to be done manually. Would result in 16 NOPs.
