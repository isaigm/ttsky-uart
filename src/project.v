/*
 * Copyright (c) 2026 Tu Nombre / Github User
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Este es el módulo superior (Top Module) compatible con la plantilla de Tiny Tapeout
module tt_um_uart_tx (
    input  wire [7:0] ui_in,    // Entradas dedicadas (mapeadas a byte_in)
    output wire [7:0] uo_out,   // Salidas dedicadas (uo_out[0] mapeada a bit_out)
    input  wire [7:0] uio_in,   // Bidireccionales: Entrada (uio_in[0] mapeada a start)
    output wire [7:0] uio_out,  // Bidireccionales: Salida
    output wire [7:0] uio_oe,   // Bidireccionales: Habilitación (0 = entrada, 1 = salida)
    input  wire       ena,      // Siempre en 1 cuando el diseño está activo, se puede omitir
    input  wire       clk,      // Reloj del sistema
    input  wire       rst_n     // Reset activo en bajo (low to reset)
);

    // Instancia del transmisor UART traducido anteriormente
    uart_tx #(
        .BAUD_RATE(9600),
        .CLK_FREQ(50000000)
    ) uart_tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(uio_in[0]),      // Usamos el primer pin bidireccional como entrada 'start'
        .byte_in(ui_in),        // Conectamos las 8 entradas dedicadas a 'byte_in'
        .bit_out(uo_out[0])     // Conectamos el bit de salida de datos a uo_out[0]
    );

    // Todos los pines de salida no utilizados deben asignarse a 0.
    assign uo_out[7:1] = 7'b0000000;
    assign uio_out     = 8'b00000000;
    assign uio_oe      = 8'b00000000; // Todos los pines bidireccionales configurados como entradas

    // Lista de todas las entradas no utilizadas para evitar warnings durante la síntesis
    wire _unused = &{1'b0, ena, uio_in[7:1]};

endmodule
