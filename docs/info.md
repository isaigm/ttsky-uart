## How it works

This project is a hardware-based **UART Transmitter (TX)** that serializes an 8-bit parallel input into a standard asynchronous serial stream. 

### Internal Architecture
The design is controlled by a Finite State Machine (FSM) with three states:
1. **IDLE**: The transmitter is idle, holding the serial output (`bit_out`) HIGH. It waits for the `start` signal to transition to HIGH.
2. **TX**: Once triggered, it generates a START bit (LOW) for one baud period, followed by the 8 data bits of `byte_in` (sent LSB first, Least Significant Bit). A configurable counter (`cnt`) ensures each bit is held for the precise number of clock cycles calculated by the formula: 
   $$\text{TOTAL\_CYCLES} = \frac{\text{CLK\_FREQ}}{\text{BAUD\_RATE}}$$
3. **STOP**: After transmitting the 8 data bits, the state machine transitions to STOP, driving the output HIGH for one full baud period to signal the end of the frame, before returning to IDLE.

### Signal Mapping to Tiny Tapeout Wrapper
In a typical Tiny Tapeout wrapper (`tt_um_...`), the ports of this module can be mapped as follows:
* `clk` and `rst_n` connect directly to the global clock and active-low reset.
* `byte_in[7:0]` maps to the dedicated input pins `ui_in[7:0]`.
* `start` can map to one of the bidirectional pins configured as input (e.g., `uio_in[0]`).
* `bit_out` maps to the first dedicated output pin `uo_out[0]`.

---

## How to test

You can test the transmitter using a simulation tool (such as Cocotb, Verilator, or ModelSim) or directly on the physical hardware using the Tiny Tapeout demo board.

### Simulation Test
1. Set the clock frequency and baud rate parameters to match your testbench environment.
2. Apply a system reset by pulsing `rst_n` LOW, then pull it HIGH.
3. Apply an 8-bit character (for example, ASCII 'A' which is `0x41` or `8'b01000001`) to the `byte_in` inputs.
4. Pulse the `start` pin HIGH for at least one clock cycle.
5. Monitor `bit_out`. You should observe:
   * 1 bit-period of LOW (Start Bit).
   * 8 bit-periods showing the data bits: `1`, `0`, `0`, `0`, `0`, `0`, `1`, `0` (LSB first).
   * 1 bit-period of HIGH (Stop Bit).

### Hardware Test
1. Power up the Tiny Tapeout demo board and ensure the clock is running at the configured frequency (e.g., 50 MHz or the frequency selected during synthesis).
2. Set the input DIP switches (`ui_in[7:0]`) to the binary value of the ASCII character you want to send.
3. Trigger the transmission by momentarily driving the `start` pin HIGH (using a push-button or an external signal).
4. Capture the output on `uo_out[0]` using a logic analyzer or oscilloscope to verify the timing and bit sequence.

---

## External hardware

To interface this digital design with a computer or external devices, you can use the following hardware:

* **USB-to-UART Converter**: A standard module (based on chips like FT232RL, CP2102, or CH340) to bridge the chip's output with a PC.
  * Connect the Ground (GND) of the converter to the GND of the Tiny Tapeout board.
  * Connect the **RX** pin of the converter to the **`uo_out[0]`** pin (serial output) of the Tiny Tapeout board.
* **Serial Terminal Emulator**: Software on your PC (such as PuTTY, Tera Term, Minicom, or the Arduino Serial Monitor) configured to:
  * Speed: `9600` baud (or the custom baud rate defined in your configuration).
  * Data bits: `8`.
  * Parity: `None`.
  * Stop bits: `1`.
* **Logic Analyzer or Oscilloscope**: Optional, but recommended for visually measuring the baud rate and checking the waveform integrity.
