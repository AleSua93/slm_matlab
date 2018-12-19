# Sound Level Meter application for Matlab (with GUI)

Given an audio file and a reference file (at 94 dBSPL), it calculates
the equivalent Sound Pressure Level (Leq) for each third-octave
frequency band (from 20 to 20kHz). 

It also plots the resulting spectrum, as well as the temporal evolution of the signal in terms
of sound level (Logger). Finally, it displays both signals.


It allows for calculations to be performed applying A, C, and Z
frequency weightings, as well as Slow (1s), fast (125ms), and
impulse (35ms) integration times. 


Results can be exported, and upon doing so they will appear in
Values.xlsx
