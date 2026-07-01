module tt_um_uart_tx 
#(  
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ  = 50000000,
    parameter TOTAL_CYCLES = CLK_FREQ / BAUD_RATE 
)
(
    input  wire       clk,
    input  wire       rst_n,       
    input  wire       start,
    input  wire [7:0] byte_in, 
    output reg        bit_out
);

   
    localparam IDLE = 2'b00;
    localparam TX   = 2'b01;
    localparam STOP = 2'b10;
    
    reg [1:0] status;
    reg [$clog2(TOTAL_CYCLES):0] cnt;
    reg [3:0] bit_idx;  
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            status  <= IDLE;
            bit_out <= 1'b1;
            cnt     <= 0;
            bit_idx <= 0;
        end else begin
            case (status)
                IDLE: begin
                    bit_out <= 1'b1; 
                    if (start) begin
                        status  <= TX;
                        bit_out <= 1'b0; 
                        cnt     <= 0;
                        bit_idx <= 0;
                    end
                end
                
                TX: begin
                    if (cnt == TOTAL_CYCLES - 1) begin
                        cnt <= 0; 
                        
                        if (bit_idx == 4'd8) begin
                            status  <= STOP;
                            bit_out <= 1'b1; 
                        end else begin
                            bit_out <= byte_in[bit_idx];
                            bit_idx <= bit_idx + 1'b1;
                        end
                    end else begin
                        cnt <= cnt + 1'b1; 
                    end
                end
                
                STOP: begin
               
                    if (cnt == TOTAL_CYCLES - 1) begin
                        status <= IDLE;
                        cnt    <= 0;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end
                
                default: status <= IDLE; 
            endcase
        end
    end
endmodule
