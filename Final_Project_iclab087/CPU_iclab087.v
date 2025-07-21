//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/




// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;//[3:0]    fixed 4'b0000
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;//[31:0]   
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;//[2:0]    fixed 3'b001  
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;//[1:0]    fixed 2'b01
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;//[6:0]    
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;//[0:0]   
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;//[0:0]     
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;//[15:0]
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;//[0:0]      
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;//[0:0]     
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;//[0:0]      
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;//[3:0]  
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;//[1:0]  
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;//[0:0]       
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;//[0:0]       
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;//[7:0]   fixed {4'b0000,4'b0000};
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;//[63:0]  OK
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;//[13:0]  OK
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;//[5:0]   fixed {3'b001,3'b001};
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;//[3:0]   fixed {2'b01,2'b01};
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;//[1:0]    
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;//[1:0]   OK
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;//[7:0]  
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;//[31:0] 
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;//[3:0]  //unuse 
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;//[1:0]  
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;//[1:0]  
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;//[1:0]  
// -----------------------------

//        AXI {  Instration , Data  } First part is Instration ,Second part is Data 
//####################################################
//                     AXI_General 
//####################################################

reg [31:0]araddr_instration;
reg [31:0]araddr_data;
wire[63:0]araddr_concatenate={araddr_instration[31:0],araddr_data[31:0]};
reg arvalid_m_inf_instration;
reg arvalid_m_inf_data;
wire arready_m_inf_instration;
wire arready_m_inf_data;

reg rready_m_inf_instration;
reg rready_m_inf_data;


//AR_DATA
assign arid_m_inf   = {4'b0000,4'b0000};
assign arlen_m_inf  = {7'd127,7'd127};// 63:127 bound problem
assign arsize_m_inf = {3'b001,3'b001};
assign arburst_m_inf= {2'b01,2'b01};

assign araddr_m_inf = {araddr_instration[31:0],araddr_data[31:0]};
assign arvalid_m_inf= {arvalid_m_inf_instration,arvalid_m_inf_data};
assign arready_m_inf_instration = arready_m_inf[1];
assign arready_m_inf_data       = arready_m_inf[0];

//AW_DATA
assign awid_m_inf    = 4'b0000;
assign awsize_m_inf  = 3'b001;
assign awburst_m_inf = 2'b01;
assign awlen_m_inf = 0;


reg [31:0] awaddr_m_inf_data;
//reg [6:0]  awlen_m_inf_data;
reg awvalid_m_inf_data;
assign awvalid_m_inf = awvalid_m_inf_data;
assign awaddr_m_inf = awaddr_m_inf_data;

//W_DATA;
reg [15:0]wdata_m_inf_data;
reg wlast_m_inf_data;
reg wvalid_m_inf_data;
assign wdata_m_inf=wdata_m_inf_data;
assign wlast_m_inf=wlast_m_inf_data;
assign wvalid_m_inf=wvalid_m_inf_data;

//B_DATA;
reg bready_m_inf_data;
assign bready_m_inf=bready_m_inf_data;
assign rready_m_inf ={rready_m_inf_instration,rready_m_inf_data};

/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;

reg [3:0]current_state,next_state;

//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################


//=======================================================
//                   Memory Control Reg 
//=======================================================
//[                 *** INSTRATION ***                  ] 
reg SRAM_WEB_instration;
reg  [7:0] SRAM_ADDRESS_instration;
reg [15:0] SRAM_INPUT_instration;
reg [15:0] SRAM_OUTPUT_instration;
reg [15:0] SRAM_OUTPUT_instration_reg;
//[                   *** DATA ***                      ] 
reg SRAM_WEB_data;
reg  [6:0] SRAM_ADDRESS_data;
reg [15:0] SRAM_INPUT_data;
reg [15:0] SRAM_OUTPUT_data;
reg [15:0] SRAM_OUTPUT_data_reg;
reg SRAM_127_or_255_flag;

//wire SRAM_127_or_255_flag; //check if the instration vector is 127 or 255
//assign SRAM_127_or_255_flag=(SRAM_ADDRESS_instration==7'd127)?1'b1:1'b0;
reg [31:0]rdata_m_inf_buffer;
reg [1:0]rvalid_m_inf_reg;
reg rlast_m_inf_reg;
reg [2:0]SRAM_counter;
reg [2:0]ID_counter;
reg [3:0]DRAM_counter;
reg [1:0]wait_sram_out_lookup;
reg signed [10:0]program_counter;

reg store_flag;
reg write_back_flag;
assign write_back_flag=(DRAM_counter==10 && store_flag);
reg fsm_delay;


reg rlast_data_reg;
reg rlast_data_reg2;

//FUNCTION CODE
reg [2:0] opcode;
reg [3:0] rs;
reg [3:0] rt;
reg [3:0] rd;
reg       func;
reg signed [4:0] immediate;
reg [12:0] address;
reg signed[15:0]rs_data;
reg signed[15:0]rt_data;
reg signed[15:0]rd_data;
wire signed[15:0]add_out;
wire signed[15:0]minud_out;
wire signed[31:0]mul_out;
wire signed[15:0]common_add;
assign add_out   = rs_data+rt_data;
assign minus_out = rs_data-rt_data;
DW02_mult_2_stage #(16,16) mult_2_inst(.A(rs_data), .B(rt_data), .TC(1'b1), .CLK(clk), .PRODUCT(mul_out));
wire top_bound_instration; // small number
wire down_bound_instration;// big number
wire top_bound_data;
wire down_bound_data;
assign common_add=(opcode[2]==1'b1)?(program_counter+immediate):(opcode[1]==1'b1)?(rs_data+immediate):(rs_data+rt_data);
reg [2:0]top_address_instration;
reg [2:0]down_address_instration;
reg [4:0]top_address_data;
reg [4:0]down_address_data;
reg rlast_m_data,rlast_m_data2;
wire [31:0]pp_8to0;
wire [31:0]pp_7to0;
wire [31:0]pp_6to0;
assign pp_8to0={common_add[8],8'b0};
assign pp_7to0={common_add[7],7'b0};
wire [31:0]common;
assign common=common_add[11:7];
//assign top_bound_instration  = (program_counter[8] != top_address_instration[1]  && program_counter[7] == top_address_instration[0] )? 1'b1: 1'b0;
//assign down_bound_instration = (program_counter[8] != down_address_instration[1] && program_counter[7] == down_address_instration[0])? 1'b1: 1'b0;
reg update;
reg [3:0]bound;
wire signed[31:0]shift_commond_add=(common_add<<1);
assign top_bound_data  = (bound != (shift_commond_add[11:8])) && (update==0 && (current_state==11 ||current_state==12))? 1'b1: 1'b0;
assign down_bound_data = (bound != (shift_commond_add[11:8])) && (update==0 && (current_state==11 ||current_state==12))? 1'b1: 1'b0;


 reg  [2:0]   instruction_low_half_tag;
 reg  [2:0]   instruction_high_half_tag;
 wire    high_cache_miss; 
 wire    low_cache_miss;

 always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
   instruction_high_half_tag <= 3'b000; //high==down
  end else if (program_counter[7]) begin
   instruction_high_half_tag <= program_counter[10:8];
  end
 end

 always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
   instruction_low_half_tag <= 3'b000;//low==top
  end
  else if ( ~program_counter[7]) begin
   instruction_low_half_tag <= program_counter[10:8];
  end
 end

 assign low_cache_miss  = program_counter[10:8] != instruction_low_half_tag;
 assign high_cache_miss = program_counter[10:8] != instruction_high_half_tag;
 assign instruction_cache_miss = program_counter[7]?  (high_cache_miss) : (low_cache_miss);
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        top_address_instration<=2'b00;
        down_address_instration<=2'b01;
    end
    else begin
        if(top_bound_instration)begin
            top_address_instration<=top_address_instration+1'b1;
            down_address_instration<=down_address_instration+1'b1;
        end
        if(down_bound_instration)begin
            top_address_instration<=top_address_instration-1'b1;
            down_address_instration<=down_address_instration-1'b1;
        end
    end
end
*/

wire [3:0]program_counter_10_7_addone;
wire [3:0]program_counter_6_0;
wire [3:0]program_counter_10_7;
assign program_counter_6_0=program_counter[6:0];
assign program_counter_10_7=program_counter[10:7];
assign program_counter_10_7_addone=program_counter[10:7]+1'b1;
reg top_down_flag;
wire [6:0]common_add_7bit;
assign common_add_7bit=common_add[6:0];
wire [2:0]opcode_debug;
wire [3:0]rs_debug,rt_debug;
wire func_debug;

assign opcode_debug=3'b000;
assign rs_debug=4'd1;
assign rt_debug=4'd2;
assign rd_debug=4'd3;
assign func_debug=1'b0;

//observation for [debug]
wire [7:0]program_counter_8bit;
assign program_counter_8bit=program_counter[7:0];
wire [10:0]address_11bit;
assign address_11bit=address[11:1];
wire [7:0]jump_8bit;
assign jump_8bit=SRAM_OUTPUT_instration_reg[8:1];

/* wrong
always @(*) begin
    opcode    = SRAM_OUTPUT_instration_reg[15:13];
    rs        = SRAM_OUTPUT_instration_reg[12:9];
    rt        = SRAM_OUTPUT_instration_reg[8:5];
    rd        = SRAM_OUTPUT_instration_reg[4:1];
    func      = SRAM_OUTPUT_instration_reg[0];
    immediate = SRAM_OUTPUT_instration_reg[4:0];
    address   = SRAM_OUTPUT_instration_reg[12:0];
end
*/

assign opcode    = SRAM_OUTPUT_instration_reg[15:13];
assign rs        = SRAM_OUTPUT_instration_reg[12:9];
assign rt        = SRAM_OUTPUT_instration_reg[8:5];
assign rd        = SRAM_OUTPUT_instration_reg[4:1];
assign func      = SRAM_OUTPUT_instration_reg[0];
assign immediate = SRAM_OUTPUT_instration_reg[4:0];
assign address   = SRAM_OUTPUT_instration_reg[12:0];


//      [  DEBUG MODE ]
/*
assign opcode    = opcode_debug;
assign rs        = rs_debug;
assign rt        = rt_debug;
assign rd        = rd_debug;//SRAM_OUTPUT_instration_reg[4:1];
assign func      = func_debug;
assign immediate = SRAM_OUTPUT_instration_reg[4:0];
assign address   = SRAM_OUTPUT_instration_reg[12:0];
*/



parameter                IDLE=0;//Idle
parameter      INITIALIZATION=1;//Idle
parameter GET_DRAM_FIRST     =2;
parameter GET_DRAM_SECOND    =3;
parameter GET_DRAM_THIRD     =4;
parameter GET_DRAM_FOURTH    =5;

parameter INSTRATION_FETCH   =5;//IF

parameter ID                 =5;//instration decoder     
parameter EXE                =6;//execute claculate 
parameter SET_LESS_THAN      =7;
parameter MULT               =8;
parameter LOAD               =11;
parameter STORE              =12;
parameter WRITE_TO_DRAM      =13;
parameter BRANCH             =9;
parameter JUMP               =10;
parameter MEM                =5;//memory access
parameter SRAM_OUT_RANGE     =6;//sram out of range reload from DRAM
parameter WRITE_BACK_PREPARE =7;
parameter WRITE_BACK_IN_DRAM =8;
parameter SRAM_INITIALIZATION=15;//sram initialization


//FSM
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        current_state<=SRAM_INITIALIZATION;//9
    end
    else begin
        current_state<=next_state;
    end
end
always@(*)begin
    case(current_state)
        IDLE:begin
                next_state=INITIALIZATION;
        end
        INITIALIZATION:begin//1
            if(!SRAM_127_or_255_flag && rlast_m_inf &&rlast_m_inf_reg)
                next_state=4;
            else if(SRAM_counter==3 && rlast_m_inf &&rlast_m_inf_reg)
                next_state=4;
            else if(!SRAM_127_or_255_flag && rlast_m_inf==2'b11)
                next_state=4;
            else if(rlast_m_inf==2'b11)
                next_state=IDLE;
            else if(SRAM_127_or_255_flag && (rlast_m_inf[1]==1'b1||rlast_m_inf[0]==1'b1))
                next_state=GET_DRAM_FIRST;//2
            else 
                next_state=INITIALIZATION;
        end
        GET_DRAM_FIRST:begin//2
            if(SRAM_counter==3 && rlast_m_inf!=0)
                next_state=4;
            else if(rlast_m_inf[1]==1'b1||rlast_m_inf[0]==1'b1)
                next_state=0;
            else 
                next_state=GET_DRAM_FIRST;
        end
        GET_DRAM_SECOND:begin//3
            if(SRAM_counter==3 && rlast_m_inf!=0)
                next_state=4;
            else 
                next_state=GET_DRAM_SECOND;

        end
        GET_DRAM_THIRD:begin//4
            if(SRAM_counter==2) //affect SRAM_ADDRESS_data
                next_state=ID;
            else
                next_state=GET_DRAM_THIRD;
        end
        ID:begin//5
            case(opcode)
            3'b000:begin //ADD SUB
                if(ID_counter==4)
                    next_state=EXE;
                else 
                    next_state=ID;
            end
            3'b001:begin
                if(ID_counter==4)
                    next_state=EXE; //set_less_than
                else 
                    next_state=ID;
            end
            3'b010:begin
                if(ID_counter==6)
                    next_state=LOAD;   //11
                else 
                    next_state=ID;
            end
            3'b011:begin
                if(ID_counter==3)
                    next_state=STORE;   //12
                else 
                    next_state=ID;

            end
            3'b100:begin //branch condition
                if(ID_counter==4)
                    next_state=BRANCH;
                else 
                    next_state=ID;
            
            end
            3'b101:begin//jump
                if(ID_counter==3)
                    next_state=JUMP;
                else 
                    next_state=ID;
            end
            default:next_state=ID;
            endcase
        end


        //GET_DRAM_DATA: next_state=(rlast_m_inf==2'b11 )?IDLE:1;  
        //2:      next_state=(wait_sram_out_lookup==3)?3:2;
        //2:      next_state=2;
        //3:      next_state=3;
        //4:      next_state=5;
        6:begin
           if(instruction_cache_miss)
                next_state=0;
            else
                next_state=5;
        end
        
        LOAD:begin//11
            if(instruction_cache_miss)
                next_state=0;
            else if(top_bound_data ||down_bound_data)
                next_state=14;
            else
                next_state=5;
        end
        STORE:begin//12
            if(store_flag)
                next_state=WRITE_TO_DRAM;
            else
                next_state=5;
        end
        BRANCH:begin
            if(instruction_cache_miss)
                next_state=0;
            else
                next_state=5;
        end
        JUMP:begin//10
            if(instruction_cache_miss)
                next_state=0;
            else
                next_state=5;
        end
        WRITE_TO_DRAM:begin //13
            if(bvalid_m_inf==1'b1)
                next_state=5;
            else 
                next_state=13;
        end
        14:begin
             if(rlast_m_data==1'b1)
                 next_state=5;
             else 
                next_state=14;
        end
        default:next_state=0;
    endcase
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rlast_m_data<=0;
    end
    else if(rlast_m_inf[0]==1'b1)begin
        rlast_m_data<=1'b1;
    end 
    else begin
        rlast_m_data<=0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rlast_m_data2<=0;
    end
    else begin
        rlast_m_data2<=rlast_m_data;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        store_flag<=0;
    end
    else if(current_state==13)begin
        store_flag<=0;
    end
    else if(next_state>5 && opcode==3'b011)begin
        store_flag<=1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        fsm_delay<=0;
    end
    else if(current_state==11)begin
        fsm_delay<=1'b1;
    end
    else begin
        fsm_delay<=0;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        bound<=0;
    end
    else if((top_bound_data || down_bound_data)&&(current_state==11))begin
        bound<=shift_commond_add[11:8];
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        top_address_data <=5'b00000;
        down_address_data<=5'b00001;
    end

    else if((top_bound_data || down_bound_data)&&(current_state==11))begin
        top_address_data<=common_add[11:7];
        down_address_data<=common_add[11:7]+1'b1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        top_down_flag<=0;
    end
    else if(instruction_cache_miss)begin
        top_down_flag<=top_down_flag+1'b1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        update<=1'b0;
    end
    else if((top_bound_data || down_bound_data)&&(current_state==11))begin
        update<=1'b1;
    end
    else if(current_state==11)begin
        update<=1'b0;
    end
end
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r0<=0;
    end
    else if(opcode[2]==1'b0 && opcode[1]==1'b0 && rd==0)begin
        core_r0<=rd_reg;
    end
    else if(opcode[2]==1'b0 && opcode[1]==1'b1 && opcode[0]==1'b0 &&rt==0)begin
        core_r0<=sram_out_reg;
    end
    else begin
        core_r0<=core_r0;
    end
end*/
//[                 *** core ***                  ] 

// core_r0
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r0<=0;
    end
    else if (current_state==6 && rd==0 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r0<=mul_out[15:0];
        else
            core_r0<=rd_data;
    end
    else if (current_state==11 && rt==0)begin
        core_r0<=SRAM_OUTPUT_data_reg;
    end
end

// core_r1
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r1<=0; 
    end
    else if (current_state==6 && rd==1 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r1<=mul_out[15:0]; 
        else
            core_r1<=rd_data; 
    end
    else if (current_state==11 && rt==1)begin 
        core_r1<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r2
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r2<=0; 
    end
    else if (current_state==6 && rd==2 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r2<=mul_out[15:0]; 
        else
            core_r2<=rd_data; 
    end
    else if (current_state==11 && rt==2)begin 
        core_r2<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r3
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r3<=0; 
    end
    else if (current_state==6 && rd==3 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r3<=mul_out[15:0]; 
        else
            core_r3<=rd_data; 
    end
    else if (current_state==11 && rt==3)begin 
        core_r3<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r4
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r4<=0; 
    end
    else if (current_state==6 && rd==4 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r4<=mul_out[15:0]; 
        else
            core_r4<=rd_data; 
    end
    else if (current_state==11 && rt==4)begin 
        core_r4<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r5
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r5<=0; 
    end
    else if (current_state==6 && rd==5 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r5<=mul_out[15:0]; 
        else
            core_r5<=rd_data; 
    end
    else if (current_state==11 && rt==5)begin 
        core_r5<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r6
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r6<=0; 
    end
    else if (current_state==6 && rd==6 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r6<=mul_out[15:0]; 
        else
            core_r6<=rd_data; 
    end

    else if (current_state==11 && rt==6)begin 
        core_r6<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r7
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r7<=0; 
    end
    else if (current_state==6 && rd==7 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r7<=mul_out[15:0]; 
        else
            core_r7<=rd_data; 
    end
    else if (current_state==11 && rt==7)begin 
        core_r7<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r8
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r8<=0; 
    end
    else if (current_state==6 && rd==8 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r8<=mul_out[15:0]; 
        else
            core_r8<=rd_data; 
    end
    else if (current_state==11 && rt==8)begin 
        core_r8<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r9
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r9<=0; 
    end
    else if (current_state==6 && rd==9 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r9<=mul_out[15:0]; 
        else
            core_r9<=rd_data; 
    end
    else if (current_state==11 && rt==9)begin 
        core_r9<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r10
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r10<=0; 
    end
    else if (current_state==6 && rd==10 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r10<=mul_out[15:0]; 
        else
            core_r10<=rd_data; 
    end
    else if (current_state==11 && rt==10)begin 
        core_r10<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r11
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r11<=0; 
    end
    else if (current_state==6 && rd==11 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r11<=mul_out[15:0]; 
        else
            core_r11<=rd_data; 
    end
    else if (current_state==11 && rt==11)begin 
        core_r11<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r12
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r12<=0; 
    end
    else if (current_state==6 && rd==12 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r12<=mul_out[15:0]; 
        else
            core_r12<=rd_data; 
    end
    else if (current_state==11 && rt==12)begin 
        core_r12<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r13
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r13<=0; 
    end
    /*else if (next_state==9)begin
        core_r13<=rt_data;
    end*/
    else if (current_state==6 && rd==13 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r13<=mul_out[15:0]; 
        else
            core_r13<=rd_data; 
    end
    else if (current_state==11 && rt==13)begin 
        core_r13<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r14
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r14<=0; 
    end
    else if (current_state==6 && rd==14 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r14<=mul_out[15:0]; 
        else
            core_r14<=rd_data; 
    end

    else if (current_state==11 && rt==14)begin 
        core_r14<=SRAM_OUTPUT_data_reg; 
    end
end

// core_r15
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r15<=0; 
    end
    else if (current_state==6 && rd==15 &&opcode!=3'b010)begin
        if(opcode==3'b001 && func==1)
            core_r15<=mul_out[15:0]; 
        else
            core_r15<=rd_data; 
    end
    /*else if((top_bound_data||down_bound_data)&& (current_state==11) )
        core_r15<=core_r15;*/
    else if (current_state==11 && rt==15 )begin 
        core_r15<=SRAM_OUTPUT_data_reg; 
    end
end

/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r1<=0;

    end
    else if(current_state==4)begin
        core_r1<=99;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        core_r2<=0;

    end
    else if(current_state==4)begin
        core_r2<=100;
    end
end*/





always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        rs_data <= 16'd0;
    end
    else if (current_state==5 &&ID_counter==3)begin
        rs_data <= get_core_temp(rs);
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        rt_data <= 16'd0;
    end
    else if (current_state==5 &&ID_counter==3)begin
        rt_data <= get_core_temp(rt);
    end
end

function signed [15:0] get_core_temp;
    input [3:0] rs_or_rt;
    begin
        case (rs_or_rt)
            4'd0 :   get_core_temp = core_r0;
            4'd1 :   get_core_temp = core_r1;
            4'd2 :   get_core_temp = core_r2;
            4'd3 :   get_core_temp = core_r3;
            4'd4 :   get_core_temp = core_r4;
            4'd5 :   get_core_temp = core_r5;
            4'd6 :   get_core_temp = core_r6;
            4'd7 :   get_core_temp = core_r7;
            4'd8 :   get_core_temp = core_r8;
            4'd9 :   get_core_temp = core_r9;
            4'd10:   get_core_temp = core_r10;
            4'd11:   get_core_temp = core_r11;
            4'd12:   get_core_temp = core_r12;
            4'd13:   get_core_temp = core_r13;
            4'd14:   get_core_temp = core_r14;
            4'd15:   get_core_temp = core_r15;
            default: get_core_temp = 16'd0;
        endcase
    end
endfunction
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        rd_data<=16'b0;
    end
    else if(ID_counter==4 && opcode==3'b000)begin //ADD , SUB
        if(!func) //opcode_func 000_0
            rd_data<=common_add;//   rs_data+rt_data
        else
            rd_data<=rs_data-rt_data;
    end
    else if(ID_counter==4 && opcode==3'b001)begin //Set less than ,Mult
        if(!func)begin
            if(rs_data<rt_data)
                rd_data<=16'b1;
            else 
                rd_data<=16'b0;
        end
        //else begin
        //    rd_data<=mul_out;
        //end
    end
    else if(current_state==5 && opcode==3'b010)begin //Load
            rd_data<=SRAM_OUTPUT_data_reg;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        program_counter<=0 ;//11bit   //debug  <=0
    end
    else if (next_state == 9) begin
        if (opcode == 3'b100) begin
            if (rs_data == rt_data)
                program_counter <= common_add + 1; // branch taken
            else
                program_counter <= program_counter + 1; // branch not taken
        end 
        else begin
            program_counter <= program_counter + 1;
        end
    end
    else if(next_state==10 && opcode==3'b101)begin
        program_counter<=address[11:1]; //jump
    end

    else if((top_bound_data || down_bound_data)&&(current_state==11))begin
        program_counter<=program_counter-1'b1;
    end
    else if(next_state==6||next_state==9||next_state==10|| next_state==11 ||next_state==12)
        program_counter<=program_counter+1'b1; //branch on eqaul condition2
        
end

//[                 *** SRAM ***                  ] 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin

    end
    else begin
        
    end
end


//[instration]web control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_WEB_instration<=1'b1; //1 is read , 0 is write
    end
    else if(rvalid_m_inf_reg[1]==1'b1)begin
        SRAM_WEB_instration<=1'b0;
    end
    else begin 
        SRAM_WEB_instration<=1'b1;
    end
end
//[instration]address control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_ADDRESS_instration<=8'b1111_1111;//8'1b111_1111 = 8'd255
    end
    else if(instruction_cache_miss)
        if(program_counter[7:0]>127)
            SRAM_ADDRESS_instration<=8'b0111_1111;
        else
            SRAM_ADDRESS_instration<=8'b1111_1111; 
    else if(rvalid_m_inf_reg[1]==1'b1)begin
        SRAM_ADDRESS_instration<=SRAM_ADDRESS_instration+1'b1;
    end
    else if((top_bound_data || down_bound_data)&&(current_state==11))begin
        SRAM_ADDRESS_instration<=SRAM_ADDRESS_instration;
    end
    //else if(current_state==6||current_state==9|| current_state==10 ||current_state==11||current_state==12)begin
    else if(current_state==6||current_state==9 ||current_state==11||current_state==12)begin
        SRAM_ADDRESS_instration<=program_counter[7:0];
    end
    else if(current_state==4 &&next_state==5 && SRAM_127_or_255_flag==0)begin
        SRAM_ADDRESS_instration<=program_counter[7:0];
    end
    else if(current_state==10)begin //jump
        SRAM_ADDRESS_instration<=SRAM_OUTPUT_instration_reg[8:1];
    end
    else if(current_state==4 &&next_state==5 && SRAM_127_or_255_flag==1)begin
        SRAM_ADDRESS_instration<=0;
    end



    //else 
     //  SRAM_ADDRESS_instration<=program_counter[7:0];
end

//[data]address control 789
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_ADDRESS_data<=7'b111_1111; //7'b111_1111 = 7'd127
    end
    else if((top_bound_data || down_bound_data)&&(current_state==11))
        SRAM_ADDRESS_data<=7'b111_1111;
    else if(rvalid_m_inf_reg[0]==1'b1)begin
        SRAM_ADDRESS_data<=SRAM_ADDRESS_data+1'b1;
    end
    else if(update && ID_counter==3 && current_state==5 )begin
        SRAM_ADDRESS_data<=common_add[6:0];
    end
    else if(!update && ID_counter==4 && current_state==5 )begin//11 //load
        SRAM_ADDRESS_data<=common_add[6:0]; //common_add 16bit
    end
    /*else if(ID_counter==4 && current_state==5 )begin//11 //load
        SRAM_ADDRESS_data<=common_add[6:0]; //common_add 16bit
    end*/
    else if(current_state==4 &&next_state==5)begin
        SRAM_ADDRESS_data<=program_counter;
    end

    else if(current_state==STORE)begin//12              //store
        SRAM_ADDRESS_data<=common_add[6:0]; //common_add 16bit
    end
    else if(current_state==4 &&next_state==5)begin
        SRAM_ADDRESS_data<=program_counter;
    end

end



//[instration]input control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_INPUT_instration<=16'b0;
    end
    else if(rvalid_m_inf_reg[1]==1'b1)begin
        SRAM_INPUT_instration<=rdata_m_inf_buffer[31:16];
    end
end
//[instration]output control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_OUTPUT_instration_reg<=0;
    end
    else begin
        SRAM_OUTPUT_instration_reg<=SRAM_OUTPUT_instration;
    end
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rlast_data_reg<=0;
    end
    else if(rlast_m_inf[0]==1'b1)begin
        rlast_data_reg<=rlast_m_inf[0];
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rlast_data_reg2<=0;
    end
    else if(rlast_data_reg==1'b1)begin
        rlast_data_reg2<=1;
    end
end

//[data]web data
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_WEB_data<=1'b1; //1 is read , 0 is write
    end
    else if(rvalid_m_inf_reg[0]==1'b1 &&rlast_data_reg2==1'b0)begin
        SRAM_WEB_data<=1'b0;
    end
    else if(current_state==STORE)begin
        if(top_bound_data||down_bound_data)
            SRAM_WEB_data<=1'b1; 
        else
            SRAM_WEB_data<=1'b0; 
    end
    else if(current_state==14 && rvalid_m_inf_reg[0]==1'b1)begin
        /*if(update)
            SRAM_WEB_data<=1'b1; 
        else */
            SRAM_WEB_data<=1'b0; 
    end
    else begin
        SRAM_WEB_data<=1'b1;
    end
    
end

//[data]input control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_INPUT_data<=16'b0;
    end
    else if(rvalid_m_inf_reg[0]==1'b1)begin
        SRAM_INPUT_data<=rdata_m_inf_buffer[15:0];
    end
    else if(current_state==STORE)begin
        SRAM_INPUT_data<=rt_data;
    end
end
//[data]output control
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_OUTPUT_data_reg<=0;
    end
    else begin
        SRAM_OUTPUT_data_reg<=SRAM_OUTPUT_data;
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        SRAM_127_or_255_flag<=1'b1;
    end
    else if(current_state==4 && next_state==5)begin
        SRAM_127_or_255_flag<=1'b0;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        SRAM_counter<=0;
    end
    else if (current_state==ID)begin
        SRAM_counter<=0;
    end
    else if(current_state==GET_DRAM_THIRD )begin //4
        SRAM_counter<=SRAM_counter+1'b1;
    end
    else if(next_state==GET_DRAM_THIRD )begin //4
        SRAM_counter<=0;
    end

    else if(rlast_m_inf==2'b11)begin
        SRAM_counter<=SRAM_counter+2'b11;
    end
    else if(rlast_m_inf!=0)begin
        SRAM_counter<=SRAM_counter+1'b1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        DRAM_counter<=0;
    end
    else if(next_state==6 ||next_state==9|| next_state==10 ||next_state==11||next_state==12)begin
        DRAM_counter<=DRAM_counter+1'b1;
    end
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        ID_counter<=0;
    end
    else if(next_state==6 ||next_state==9|| next_state==10 ||next_state==11||next_state==12)begin
        ID_counter<=0;
    end
    else if(next_state==5)begin
        ID_counter<=ID_counter+1'b1;
    end
end










//////////////////////////////////////////////////////////////////            AXI            ////////////////////////////////// 
//rdata_m_inf_buffer receive rdata_m_inf
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rdata_m_inf_buffer<=32'b0;
    end
    else begin
        rdata_m_inf_buffer<=rdata_m_inf;
    end
end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rvalid_m_inf_reg<=2'b0;
    end 
    else begin
        rvalid_m_inf_reg<=rvalid_m_inf;
    end
end

//araddr_instration
always@(posedge clk or negedge rst_n)begin //12'd256 12'h0100
    if(!rst_n)begin
        araddr_instration<=32'h00001000;
    end
    else if((instruction_cache_miss)&&(next_state==0))begin
        araddr_instration<={16'b0000,4'b0001, program_counter[10:7], 4'b0000,4'b0000}; //32'h0000_1X00 X=program_counter[10:7]
    end
    /*else if(top_down_flag && next_state==0)begin
        araddr_instration<={16'b0000,4'b0001, program_counter_10_7_addone, 4'b0000,4'b0000}; //32'h0000_1X00 X=program_counter[10:7]
    end*/
    else if(next_state==0 && current_state==1)begin
        araddr_instration<=32'h00001100;
    end
    else if(next_state==0 && SRAM_counter==1)begin
        araddr_instration<=32'h00001100;
    end
    
end

//araddr_data
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        araddr_data<=32'h00001000;
    end
    else if((top_bound_data||down_bound_data)&&(current_state==11))begin
        araddr_data<={16'b0000,4'b0001, shift_commond_add[11:8], 4'b0000,4'b0000};
    end
    else if(next_state==0 && current_state==1)begin
        araddr_data<=32'h00001000;
    end
    else if(next_state==0 && SRAM_counter==1)begin
        araddr_data<=32'h00001000;
    end
end
       

//arvalid_m_inf_instration
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        arvalid_m_inf_instration<=1'b0;
    end 
    else if(arready_m_inf[1]==1'b1)
        arvalid_m_inf_instration<=1'b0;
    else if(SRAM_counter>1)
        arvalid_m_inf_instration<=arvalid_m_inf_instration;
    else if(next_state==0)
        arvalid_m_inf_instration<=1'b1;


        
end

always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin 
        arvalid_m_inf_data<=1'b0;
    end
    else if(arready_m_inf[0]==1'b1)
        arvalid_m_inf_data<=1'b0;
    else if(SRAM_counter>1)
        arvalid_m_inf_data<=arvalid_m_inf_data;
    else if(next_state==0)
        arvalid_m_inf_data<=1'b1;
    else if((top_bound_data||down_bound_data)&& (current_state==11) )
        arvalid_m_inf_data<=1'b1;

end
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rready_m_inf_instration<=1'b0;
    end
    else if(arready_m_inf[1]==1'b1)begin
        rready_m_inf_instration<=1'b1;
    end
    else if(rlast_m_inf[1]==1'b1)
        rready_m_inf_instration<=1'b0;
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        rready_m_inf_data<=1'b0;
    end
    else if(arready_m_inf[0]==1'b1)begin
        rready_m_inf_data<=1'b1;
    end
    else if(rlast_m_inf[0]==1'b1)
        rready_m_inf_data<=1'b0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        rlast_m_inf_reg<=1'b0;
    end
    else if(next_state==4)begin
        rlast_m_inf_reg<=1'b0;
    end
    else if(rlast_m_inf!=0)begin
        rlast_m_inf_reg<=rlast_m_inf_reg+1'b1;
    end
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        awvalid_m_inf_data<=1'b0;
    end
    else if(awready_m_inf)begin
        awvalid_m_inf_data<=1'b0;
    end
    else if(current_state==12) begin
        awvalid_m_inf_data<=1'b1;
    end

end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        awaddr_m_inf_data<=32'b0;
    end
    
    else if(current_state==12) begin
        awaddr_m_inf_data<=common_add*2+32'h1000;
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        wvalid_m_inf_data <= 0;
    else if(wlast_m_inf && wready_m_inf)
        wvalid_m_inf_data <= 0;
    else if(awready_m_inf) 
        wvalid_m_inf_data <= 1;
end


always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        wlast_m_inf_data <= 0;
    else if(wlast_m_inf && wready_m_inf)
        wlast_m_inf_data <= 0;
    else if(awready_m_inf)
        wlast_m_inf_data <= 1;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        wdata_m_inf_data <= 16'b0;  //assign wdata_m_inf = wdata_data;  //Data write in DRAM
    else if(next_state==13)
        wdata_m_inf_data <= rt_data;
end
// bready_data
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        bready_m_inf_data <= 0;
    else if(wready_m_inf)
        bready_m_inf_data <= 1;
    else if(bvalid_m_inf)
        bready_m_inf_data <= 0;
end

//output 
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        IO_stall <= 1;
    /*else if(current_state==11)begin
        if((top_bound_data||down_bound_data) && !update)
            IO_stall <= 1;
        else     
            IO_stall <= 0;
    end*/
    else if(current_state==11)begin
        if(top_bound_data||down_bound_data)
            IO_stall<=1'b1;
        else if(update)
            IO_stall<=1'b0;
        else 
            IO_stall<=0;
    end
    else if(current_state==6||current_state==9||current_state==10)
        IO_stall <= 0;
    else if(bvalid_m_inf)
        IO_stall <= 0;
    else 
        IO_stall <= 1;
end


/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        IO_stall <= 1;

    else 
        IO_stall <= 1;
end*/
SRAM_256X16_one INSTRATION_instance(.CK(clk), .WEB(SRAM_WEB_instration), .OE(1'b1), .CS(1'b1), .A(SRAM_ADDRESS_instration), .DI(SRAM_INPUT_instration), .DO(SRAM_OUTPUT_instration));
SRAM_128X16_one DATA_instance      (.CK(clk), .WEB(SRAM_WEB_data      ), .OE(1'b1), .CS(1'b1), .A(SRAM_ADDRESS_data      ), .DI(SRAM_INPUT_data      ), .DO(SRAM_OUTPUT_data      ));





endmodule

module SRAM_256X16_one(
    input             CK,
    input             WEB,
    input             OE,
    input             CS,
    input      [7:0]  A,   // Address: 256 locations
    input      [15:0] DI,  // Data input: 16 bits
    output     [15:0] DO   // Data output: 16 bits
);

SRAM_256X16 SRAM_256X16_inst(
    // Address connections
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]),
    .A4(A[4]), .A5(A[5]), .A6(A[6]), .A7(A[7]),

    // Data input connections
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),

    // Data output connections
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),

    // Control signals
    .CK(CK),
    .WEB(WEB),
    .OE(OE),
    .CS(CS)
);

endmodule

module SRAM_128X16_one( 
    input             CK,
    input             WEB,
    input             OE,
    input             CS,
    input      [6:0]  A,   // Address: 128 locations (7-bit)
    input      [15:0] DI,  // Data input: 16 bits
    output     [15:0] DO   // Data output: 16 bits
);

SRAM_128X16 SRAM_128X16_inst(
    // Address connections (7 bits)
    .A0(A[0]), .A1(A[1]), .A2(A[2]), .A3(A[3]),
    .A4(A[4]), .A5(A[5]), .A6(A[6]),

    // Data input connections
    .DI0(DI[0]),   .DI1(DI[1]),   .DI2(DI[2]),   .DI3(DI[3]),
    .DI4(DI[4]),   .DI5(DI[5]),   .DI6(DI[6]),   .DI7(DI[7]),
    .DI8(DI[8]),   .DI9(DI[9]),   .DI10(DI[10]), .DI11(DI[11]),
    .DI12(DI[12]), .DI13(DI[13]), .DI14(DI[14]), .DI15(DI[15]),

    // Data output connections
    .DO0(DO[0]),   .DO1(DO[1]),   .DO2(DO[2]),   .DO3(DO[3]),
    .DO4(DO[4]),   .DO5(DO[5]),   .DO6(DO[6]),   .DO7(DO[7]),
    .DO8(DO[8]),   .DO9(DO[9]),   .DO10(DO[10]), .DO11(DO[11]),
    .DO12(DO[12]), .DO13(DO[13]), .DO14(DO[14]), .DO15(DO[15]),

    // Control signals
    .CK(CK),
    .WEB(WEB),
    .OE(OE),
    .CS(CS)
);

endmodule

















