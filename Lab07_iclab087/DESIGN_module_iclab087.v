module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		seed_out  <= 0;
		out_valid <= 0;
	end
	else begin
		seed_out  <= (in_valid && out_idle)? seed_in : seed_out;
		out_valid <= (in_valid && out_idle);
	end
end


endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output reg out_valid;
output [31:0] rand_num;
output reg busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

parameter IDLE = 2'd0;
parameter LOAD_SEED = 2'd1;
parameter GENERATING = 2'd2;

reg [1:0] current_state, next_state;
reg [31:0] mid_result, next_mid_result;
reg [31:0] rand_result;

function [31:0] xorshift;
    input [31:0] x;
    begin
        x = x ^ (x << 13);
        x = x ^ (x >> 17);
        x = x ^ (x << 5);
        xorshift = x;
    end
endfunction


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end


always @ (*) begin
    next_state = current_state;
    case (current_state)
        IDLE:         if (in_valid)        next_state = LOAD_SEED;
        LOAD_SEED:                         next_state = GENERATING;
        GENERATING:   if (clk2_fifo_flag1) next_state = IDLE;
    endcase
end


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        mid_result <= 32'd0;
    else
        mid_result <= next_mid_result;
end


always @ (*) begin
    next_mid_result = mid_result;
    case (current_state)
        LOAD_SEED:   next_mid_result = seed;
        GENERATING:    if (!fifo_full)
                        next_mid_result = xorshift(mid_result);
    endcase
end


assign rand_num = xorshift(mid_result);


always @ (*) begin
    if (current_state == GENERATING && !fifo_full) begin
        busy = 1;
        out_valid = 1;
    end 
	else begin
        busy = 0;
        out_valid = 0;
    end
end

endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
input fifo_clk3_flag3;
input fifo_clk3_flag4;

reg [8:0] counter;
assign fifo_rinc = ~fifo_empty;

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        counter <= 9'd0;
    else begin
        case (fifo_clk3_flag2)
            1'b1: begin
                if (counter < 9'd256)
                    counter <= counter + 9'd1;
                else
                    counter <= 9'd0;
            end
            default: counter <= 9'd0;
        endcase
    end
end


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        out_valid <= 1'b0;
    else begin
        out_valid <= (fifo_clk3_flag2 && counter < 9'd256);
    end
end


always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)
        rand_num <= 32'd0;
    else begin
        case (fifo_clk3_flag2)
            1'b1: begin
                if (counter < 9'd256)
                    rand_num <= fifo_rdata;
                else
                    rand_num <= 32'd0;
            end
            default: rand_num <= 32'd0;
        endcase
    end
end



endmodule