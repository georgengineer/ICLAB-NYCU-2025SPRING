module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

wire dout_hand_shake;
assign sidle = (~sreq)&&(~sack); //if sreq==0 && sack==0   sidle=IDLE;
assign dout_hand_shake=(~dbusy) &&(dreq) &&(~dack);



/////////      instantiation           //////////////
NDFF_syn NDFF_SYNC_Source     (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn NDFF_SYNC_Destination(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));
/////////      instantiation           //////////////

//sreq signal 
always@(posedge sclk or negedge rst_n)begin
    if(!rst_n)begin
        sreq<=0;
    end
    else if(sack==0 && sready==1)begin //if previous output will give me sready signal , which means previous output can transmit value
        sreq<=1'b1;
    end
    else if(sack==1)begin //if source_acknowledge is 1 ,which means the destination received value
        sreq<=1'b0;
    end
    else begin
        sreq<=sreq;
    end
end

//dack
always@(posedge dclk or negedge rst_n)begin
    if(!rst_n)begin
        dack<=0;
    end
    else if(dreq==1 && dbusy==0)begin
        dack<=1'b1;
    end 
    else if(dreq==0)begin
        dack<=1'b0;
    end
    else begin
        dack<=dack;
    end

end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)begin
        dvalid <= 1'b0;
    end
    else if(dout_hand_shake)begin
        dvalid <= 1'b1;
    end
    else begin
        dvalid <= 1'b0;
    end
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)begin
        dout <= 'd0;
    end
    else if(dout_hand_shake)begin
        dout <= din;
    end
    else begin
        dout <= dout;
    end
end






endmodule