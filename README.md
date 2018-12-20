# Sound Level Meter Application for Matlab

Matlab application with a GUI for displaying and calculating the continuous equivalent
sound pressure level of an audio signal for each third-octave frequency band between
20Hz-20kHz, as well as the global level.

## Getting Started

For starting the program, run src/Sound_Level_Meter.m.

Given an audio file and a reference file (at 94 dBSPL), it calculates
the equivalent Sound Pressure Level (Leq) for each third-octave
frequency band (from 20 to 20kHz).

It also plots the resulting
spectrum, as well as the temporal evolution of the signal in terms
of sound level (Logger). Both signals are also displayed.

It allows for calculations to be performed applying A, C, and Z
frequency weightings, as well as Slow (1s), fast (125ms), and
impulse (35ms) integration times.

Results can be exported, and upon doing so they will appear in
Values.xlsx

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
