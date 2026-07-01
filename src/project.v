
`default_nettype none

// Chip integrado: RX + LEDs + TX (eco)
// Comportamiento:
//   - Recibe un byte por la línea serial RX (ui_in[0]).
//   - Los 8 LEDs (uo_out) muestran el último byte recibido.
//   - El chip hace ECO: retransmite ese mismo byte por la línea TX (uio_out[0]).
//
// Mapeo de pines:
//   ui_in[0]    -> línea RX (entrada serial desde PuTTY)
//   uo_out[7:0] -> 8 LEDs (patrón del último byte recibido)
//   uio_out[0]  -> línea TX (salida serial hacia PuTTY)
//   uio_oe[0]=1 -> configura uio[0] como SALIDA (para el TX)
//   los demás uio quedan como entrada (oe=0)

module tt_um_uart_echo (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    // ---- Señales internas ----
    wire       rx_valid;      // pulso: el RX recibió un byte
    wire [7:0] rx_byte;       // el byte recibido
    wire       tx_busy;       // alto mientras el TX transmite
    wire       tx_serial;     // la línea serial de salida del TX

    reg  [7:0] led_reg;       // registro que maneja los LEDs
    reg        tx_start;      // pulso para disparar el TX

    // ---- Instancia del RX ----
    uart_rx #(
        .BAUD_RATE(9600),
        .CLK_FREQ(50000000)
    ) rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .bit_in(ui_in[0]),        // línea RX
        .data_valid(rx_valid),
        .byte_out(rx_byte)
    );

    // ---- Instancia del TX ----
    uart_tx #(
        .BAUD_RATE(9600),
        .CLK_FREQ(50000000)
    ) tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(tx_start),
        .byte_in(rx_byte),        // el TX transmite el byte que recibió el RX
        .bit_out(tx_serial),
        .busy(tx_busy)
    );

    // ---- Registro de LEDs ----
    // Captura el byte recibido cuando rx_valid pulsa; mantiene entre bytes.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led_reg <= 8'b0;
        else if (rx_valid)
            led_reg <= rx_byte;
    end

   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_start <= 1'b0;
        else begin
            tx_start <= 1'b0;                 
            if (rx_valid && !tx_busy)
                tx_start <= 1'b1;               
        end
    end

    // ---- Conexiones a pines ----
    assign uo_out    = led_reg;                  // LEDs = último byte recibido
    assign uio_out   = {7'b0, tx_serial};        // uio[0] = línea TX, resto 0
    assign uio_oe    = 8'b00000001;              // uio[0] como SALIDA, resto entrada

    // ---- Entradas no usadas ----
    // Usadas: ui_in[0] (RX). Sin usar: ena, ui_in[7:1], uio_in[7:0] completo.
    wire _unused = &{1'b0, ena, ui_in[7:1], uio_in[7:0]};

endmodule
