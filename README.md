This project implements a 4-way Traffic Light Controller with Pedestrian Zebra Crossings in VHDL. The controller supports automatic mode with timed transitions and manual mode triggered via switches. It includes a fully working testbench for simulation.

## Features

- Controls traffic lights in 4 directions (North, South, East, West).
- Supports pedestrian (zebra) crossings for both N-S and E-W.
- Two operating modes:
  - Auto Mode (`mode = 0`): State machine cycles through all states with timers.
  - Manual Mode (`mode = 1`): Switches manually activate individual directions.
- Timers for long (30 cycles) and short (10 cycles) durations.
- Fully testable using `controller_tb.vhd`.

## Truth Table

| State | Description                         | Outputs                                     | Zebra        | Timer   |
|-------|-------------------------------------|---------------------------------------------|--------------|--------|
| 0     | E-W green                           | `green(3,2)=1`, rest red                    | `Zebra_NS_G` | Long   |
| 1     | E-W yellow (lane 3)                 | `yellow(3)=1`                               |              | Short  |
| 2     | E-W red + Zebra_NS off              |                                             | `Zebra_NS_R` | Long   |
| 3     | E-W yellow (lane 2)                 | `yellow(2)=1`                               |              | Short  |
| 4     | E-W red, N-S green (lane 3)         | `green(3)=1`                                |              | Long   |
| 5     | N-S yellow (lane 3)                 | `yellow(3)=1`                               |              | Short  |
| 6     | N-S green                           | `green(1,0)=1`                              | `Zebra_EW_G` | Long   |
| 7     | N-S yellow (lane 1)                 | `yellow(1)=1`                               |              | Short  |
| 8     | N-S red + Zebra_EW off              |                                             | `Zebra_EW_R` | Long   |
| 9     | E-W yellow (lane 0)                 | `yellow(0)=1`                               |              | Short  |
| 10    | E-W red, N-S green (lane 1)         | `green(1)=1`                                |              | Long   |
| 11    | N-S yellow (lane 1)                 | `yellow(1)=1`                               |              | Short  |

## Output
- RTL Schematic:
- Waveform Output:
