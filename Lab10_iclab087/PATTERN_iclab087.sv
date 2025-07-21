/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab09: SystemVerilog Design and Verification 
File Name   : PATTERN.sv
Module Name : PATTERN
Release version : v1.0 (Release Date: April-2025)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
// `include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype.sv"
parameter DRAM_p_r = "../00_TESTBED/DRAM/dram.dat";
parameter PATNUM   = 4201;
`define CYCLE_TIME 12
`define SEED 123
integer Debug_mode =1'b0;
program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;
//================================================================
// parameters & integer
//================================================================

parameter DRAM_start_address=((65536+8*256)-1);
parameter DRAM_end_address=(65536+0);

real CYCLE = `CYCLE_TIME;
integer seed=`SEED;
integer i,j,k;
integer temp_for_random;
integer i_pat;
integer latency,total_latency;
integer Action_Operation_Mode;



reg[9*8:1]  reset_color        = "\033[1;0m";
reg[10*8:1] txt_red_prefix     = "\033[1;31m";
reg[10*8:1] txt_green_prefix   = "\033[1;32m";
reg[10*8:1] txt_yellow_prefix  = "\033[1;33m";
reg[10*8:1] txt_blue_prefix    = "\033[1;34m";
reg[10*8:1] txt_purple_prefix  = "\033[0;35m";
reg[10*8:1] txt_cyan_prefix    = "\033[0;36m";

reg[10*8:1] bkg_black_prefix  = "\033[40;1m";
reg[10*8:1] bkg_red_prefix    = "\033[41;1m";
reg[10*8:1] bkg_green_prefix  = "\033[42;1m";
reg[10*8:1] bkg_yellow_prefix = "\033[43;1m";
reg[10*8:1] bkg_blue_prefix   = "\033[44;1m";
reg[10*8:1] bkg_white_prefix  = "\033[47;1m";

reg [10*8:1] txt_reset_color   = "\033[0m";
//================================================================
// wire & registers 
//================================================================
logic [7:0] golden_DRAM [((65536+8*256)-1):(65536+0)];  // 32 box
// Number :8*256=2048   each number has 8 bit -> total_bits=2048*8=16384
// Each Dram_Data:32bit  16384/32 = 512 
// No.0 address=10000
// No.0 address=10004
//....
// No.255 address=107FB
// No.255 address=107FC


//================================================================
// class random
//================================================================

/**
 * Class representing a random action.
 */
class random_action;
    randc Action action_variable; //[randc SystemVerilog New Syntax] [Class_Name in usertype.sv file] [class_variable_name]
    constraint action_range{
        action_variable inside{Purchase, Restock, Check_Valid_Date};
    }
    function void set_seed(int seed);  //fixed the seed (result) when simulation ,easily to debug 
        this.srandom(seed);
    endfunction
endclass


class random_warning_message;
    randc Warn_Msg warning_message_variable; 
    constraint warning_message_range{
        warning_message_variable inside{No_Warn ,Date_Warn ,Stock_Warn, Restock_Warn};
    }
    function void set_seed(int seed);  
        this.srandom(seed);
    endfunction
endclass

class random_strategy_type;
    randc Strategy_Type strategy_type_variable; 
    constraint strategy_type_range{
        strategy_type_variable inside{Strategy_A ,Strategy_B ,Strategy_C ,Strategy_D ,Strategy_E ,Strategy_F ,Strategy_G ,Strategy_H};
    }
    function void set_seed(int seed);  
        this.srandom(seed);
    endfunction
endclass


class random_mode;
    randc Mode mode_variable;
    constraint mode_range{
        mode_variable inside{Single , Group_Order , Event};
    }
    function void set_seed(int seed);
        this.srandom(seed);
    endfunction

endclass
// ------------------ split line [above] is mode ------------------ //
/*
class random_mode_to_strategy;
    randc Order_Info order_info_variable;//[randc SystemVerilog New Syntax] [Class_Name in usertype.sv file] [class_variable_name]
    constraint order_info_range{
        order_info_variable.Mode_O  inside{Single , Group_Order , Event}; // Mode_O is the member in Order_Info class
        order_info_variable.Strategy_Type_O inside{Strategy_A ,Strategy_B ,Strategy_C ,Strategy_D ,Strategy_E ,Strategy_F ,Strategy_G ,Strategy_H};
    }

    function void set_seed(int seed);
        this.srandom(seed);
    endfunction

endclass
*/

class random_mode_to_strategy;
    randc Order_Info order_info_variable;
    constraint order_info_range{
        order_info_variable.Mode_O inside{Single , Group_Order , Event};
        (order_info_variable.Mode_O == Single      ) -> order_info_variable.Strategy_Type_O inside {Strategy_A ,Strategy_B ,Strategy_C ,Strategy_D ,Strategy_E ,Strategy_F ,Strategy_G ,Strategy_H};
        (order_info_variable.Mode_O == Group_Order ) -> order_info_variable.Strategy_Type_O inside {Strategy_A ,Strategy_B ,Strategy_C ,Strategy_D ,Strategy_E ,Strategy_F ,Strategy_G ,Strategy_H};
        (order_info_variable.Mode_O == Event       ) -> order_info_variable.Strategy_Type_O inside {Strategy_A ,Strategy_B ,Strategy_C ,Strategy_D ,Strategy_E ,Strategy_F ,Strategy_G ,Strategy_H};
    }
    function void set_seed(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_date;
    randc Date date_variable; // randc random cyclic 
    constraint date_range{
        date_variable.M inside {1,2,3,4,5,6,7,8,9,10,11,12};
        (date_variable.M == 1 ) -> date_variable.D inside {[1:31]}; //condition -> constrained condition 
        (date_variable.M == 2 ) -> date_variable.D inside {[1:28]};
        (date_variable.M == 3 ) -> date_variable.D inside {[1:31]};
        (date_variable.M == 4 ) -> date_variable.D inside {[1:30]};
        (date_variable.M == 5 ) -> date_variable.D inside {[1:31]};
        (date_variable.M == 6 ) -> date_variable.D inside {[1:30]};
        (date_variable.M == 7 ) -> date_variable.D inside {[1:31]};
        (date_variable.M == 8 ) -> date_variable.D inside {[1:31]};
        (date_variable.M == 9 ) -> date_variable.D inside {[1:30]};
        (date_variable.M == 10) -> date_variable.D inside {[1:31]};
        (date_variable.M == 11) -> date_variable.D inside {[1:30]};
        (date_variable.M == 12) -> date_variable.D inside {[1:31]};
    }
    function void set_seed(int seed);
        this.srandom(seed);
    endfunction
endclass
class random_data_no; // [no] means [Number]    , another name random_data_number 
    randc Data_No data_no_variable;
    constraint data_no_range{
        data_no_variable inside{[0:255]};
    }
    function void set_seed(int seed);
        this.srandom(seed);
    endfunction
endclass

class random_stock;
    randc Stock stock_variable;
    constraint stock_range{
        stock_variable inside{[0:4095]}; // 12bit 
    }
    function void set_seed(int seed);
        this.srandom(seed);
    endfunction
endclass





///////////////////////
random_action a1, a2;
Action action;

random_action random_action_obj1; //class class_variable
Action action_obj1;

random_mode_to_strategy random_mode_to_strategy_obj1;
Order_Info order_info_obj1 ;

random_date random_date_obj1;
Date date_obj1;

random_data_no random_data_no_obj1;
Data_No data_no_obj1;

random_stock random_stock_obj1;
Stock stock_Rose,stock_Lily,stock_Carnation,stock_Baby_Breath;

Data_Dir Dram_data;
Warn_Msg golden_warning_message;

Month corner_month;
Day corner_day;
//////////////////////
//================================================================
// initial
//================================================================
logic [20:0]purchase_no_warn,purchase_date_warn,purchase_stock_warn;
logic [20:0]restock_no_warn,restock_restock_warn;
logic [20:0]check_no_warn,check_date_warn;
initial $readmemh(DRAM_p_r, golden_DRAM);

initial begin
    void'($urandom(seed));
    reset_task;
    //dram_task;
    
    a1 = new;
    a2 = new;
    a1.set_seed(123);
    a2.set_seed(123);
    void'(a1.randomize());
    void'(a2.randomize());

    random_action_obj1          =new;
    random_mode_to_strategy_obj1=new;
    random_date_obj1            =new;
    random_data_no_obj1         =new;
    random_stock_obj1           =new;

    random_action_obj1          .set_seed(seed);
    random_mode_to_strategy_obj1.set_seed(seed);
    random_date_obj1            .set_seed(seed);
    random_data_no_obj1         .set_seed(seed);
    random_stock_obj1           .set_seed(seed);
    void'(random_action_obj1          .randomize());
    void'(random_mode_to_strategy_obj1.randomize());    
    void'(random_date_obj1            .randomize());    
    void'(random_data_no_obj1         .randomize());
    void'(random_stock_obj1           .randomize());

    purchase_no_warn      = 21'd0;
    purchase_date_warn    = 21'd0;
    purchase_stock_warn   = 21'd0;

    restock_no_warn       = 21'd0;
    restock_restock_warn  = 21'd0;

    check_no_warn         = 21'd0;
    check_date_warn       = 21'd0;
    $display("a1 = %s, a2 = %s", a1.action_variable.name(), a2.action_variable.name()); 
	for(i_pat=0 ; i_pat<PATNUM; i_pat=i_pat+1)begin 
        //Action_Operation_Mode=$urandom_range(seed)% 'd3;
        case(i_pat%14)
            0, 2, 8, 9, 10, 11, 12, 13: begin 
                Action_Operation_Mode = 0; 
                //$display("order_info_obj1.Strategy_Type_O=%d ,order_info_obj1.Mode_O=%d",order_info_obj1.Strategy_Type_O,order_info_obj1.Mode_O);
            end
            1, 4, 5: begin 
                Action_Operation_Mode = 1; 
            end
            3, 6, 7: begin 
                Action_Operation_Mode = 2; 
            end
        endcase
        
        
        input_task;
        wait_out_valid_task;
        check_answer_task;

        if(Debug_mode==1'b1)
            display_task;

        //$finish;
		$display("\033[0;34mPASS PATTERN NO.%4d, \033[m \033[0;32m Execution Cycle: %3d\033[m", i_pat, latency);
        if(Action_Operation_Mode==0)begin
        //$display("\nAction = Purchase , cycle=%d  ",latency); 
        //$display("  dram_address     =    %x,", dram_address);
        //$display("  Dram_data.Rose      =    %x,", Dram_data.Rose);
        //$display("  Dram_data.Lily      =    %x,", Dram_data.Lily);
        //$display("  Dram_data.Carnation =    %x,", Dram_data.Carnation);
        //$display("  Dram_data.Baby_Breath =  %x,", Dram_data.Baby_Breath);
        //$display("Strategy: %d, Mode: %d", inf.D.d_strategy[0], inf.D.d_mode[0]);
        //$display("golden_warning_message =%s",golden_warning_message.name());
            case(golden_warning_message)
            2'b00:purchase_no_warn   +=1;
            2'b01:purchase_date_warn +=1;
            2'b10:purchase_stock_warn+=1;
            endcase
        end
        else if(Action_Operation_Mode==1)begin
        //$display("\nAction = Restock , cycle=%d",latency);
        //$display("golden_warning_message =%s\n",golden_warning_message.name());
          case(golden_warning_message)
                2'b00: restock_no_warn        += 1;
                2'b11: restock_restock_warn   += 1;
        endcase
        end
        else begin
        //$display("\nAction = Check_Valid_Date , cycle=%d",latency);
        //$display("golden_warning_message =%s\n",golden_warning_message.name());
            case(golden_warning_message)
                2'b00: check_no_warn   += 1;
                2'b01: check_date_warn += 1;
            endcase
        end
        //repeat($urandom_range(0,3)) @(negedge clk);
	end
	//pass_task;
    
    //$display("%s",txt_purple_prefix);
    //$display("purchase_no_warn =%d ,purchase_date_warn   = %d,purchase_stock_warn=%d",purchase_no_warn,purchase_date_warn,purchase_stock_warn);
    //$display("restock_no_warn  =%d ,restock_restock_warn = %d"                       ,restock_no_warn, restock_restock_warn);
    //$display("check_no_warn    =%d ,check_date_warn      = %d"                       ,check_no_warn, check_date_warn);
    //$display("%s",reset_color);
	display_pass;
	$finish;
end
/*
task reset_task1; begin
		inf.rst_n = 1;

        inf.sel_action_valid = 0;
        inf.strategy_valid = 0;
        inf.mode_valid = 0;
        inf.date_valid = 0;
        inf.data_no_valid = 0;
        inf.restock_valid = 0;

        inf.D = 'bx;

		total_latency = 0;

		#(CYCLE/2.0) inf.rst_n = 0;
		#(CYCLE/2.0) inf.rst_n = 1;
		#(5*CYCLE);
        // #5;  inf.rst_n = 0; 
        // #20; inf.rst_n = 1;

		if(inf.out_valid !== 0 || inf.warn_msg !== 0 || inf.complete !== 0) begin
			$display("[ERROR] [Reset] Output signal should be 0 at %-12d ps  ", $time*1000);
			repeat(5) #(CYCLE);
			$finish;
		end

	end endtask
*/
task reset_task;begin
	//repeat($urandom_range(2,4)) @(negedge clk);
    inf.rst_n=1;
    inf.sel_action_valid=0;
    inf.strategy_valid=0;
    inf.mode_valid=0;
    inf.date_valid=0;
    inf.data_no_valid=0;
    inf.restock_valid=0;
    inf.D='bx;
    // Pattern Variable;
    total_latency =0;

    //#(CYCLE*2) inf.rst_n=0;
    //#(CYCLE*2) inf.rst_n=1;
    #(5) inf.rst_n=0;
    #(20) inf.rst_n=1;
    //#(CYCLE*1.0);
	if(inf.out_valid !=='b0 || inf.warn_msg !=='b0 || inf.complete !== 'b0)begin
        $display("************************************************************");  
        $display("                          FAIL!                           ");    
        $display("*  Output signals should be 0 after initial RESET at %8t *", $time); // %8t at least 8 bit width 
        $display("************************************************************");
        
        $finish;
    end
end endtask



task input_task;begin
    @(negedge clk);
    //repeat($urandom_range(1, 4)) @(negedge clk); //@(negedge clk)
    case(Action_Operation_Mode)
    0:action_task_Purchase        ;
    1:action_task_Restock         ;
    2:action_task_Check_Valid_Date;
    default:begin
        $display("[ERROR] [Action_Operation_Mode] isn't   ( 0 or 1 or 2 )  ");
        $finish;
    end
    endcase
    

end endtask



task action_task_Purchase;begin//2'b00
    
    inf.sel_action_valid=1'b1; 
    inf.D.d_act[0]=Purchase;
    action=Purchase;//Only use for Debug
    //i=random_action_obj1.randomize(); //class_variable
    //action_obj1=random_action_obj1.action_variable; //class_variable_member
    @(negedge clk);
    inf.sel_action_valid=1'b0;
    inf.D='bx;
    ////repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Strategy Type----------//
    case(i_pat%14)

        0:begin
        //i=random_mode_to_strategy_obj1.randomize();
        //order_info_obj1=random_mode_to_strategy_obj1.order_info_variable;
        order_info_obj1.Strategy_Type_O=Strategy_A;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_A;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        2:begin
         order_info_obj1.Strategy_Type_O=Strategy_B;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_B;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        8:begin
         order_info_obj1.Strategy_Type_O=Strategy_C;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_C;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        9:begin
         order_info_obj1.Strategy_Type_O=Strategy_D;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_D;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        10:begin
         order_info_obj1.Strategy_Type_O=Strategy_E;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_E;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        11:begin
         order_info_obj1.Strategy_Type_O=Strategy_F;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_F;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        12:begin
         order_info_obj1.Strategy_Type_O=Strategy_G;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_G;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
        13:begin
         order_info_obj1.Strategy_Type_O=Strategy_H;
        inf.strategy_valid=1'b1;
        inf.D.d_strategy[0]=Strategy_H;
        @(negedge clk);
        inf.strategy_valid=1'b0;
        inf.D='bx;
        //repeat($urandom_range(0,3)) @(negedge clk); //delay
        end
    endcase 
    //---------Mode----------//
    
    if((i_pat%42 >=0) && (i_pat%42 <=13))begin
            order_info_obj1.Mode_O=Single;
            inf.mode_valid=1'b1;
            inf.D.d_mode[0]=Single;
            @(negedge clk);
            inf.mode_valid=1'b0;
            inf.D='bx;
            //repeat($urandom_range(0,3)) @(negedge clk);
    end
    else if((i_pat%42 >=14) && (i_pat%42 <=27))begin
            order_info_obj1.Mode_O=Group_Order;
            inf.mode_valid=1'b1;
            inf.D.d_mode[0]=Group_Order;
            @(negedge clk);
            inf.mode_valid=1'b0;
            inf.D='bx;
            //repeat($urandom_range(0,3)) @(negedge clk);
        end
    else if((i_pat%42 >=28) && (i_pat%42 <=41))begin
            order_info_obj1.Mode_O=Event;
            inf.mode_valid=1'b1;
            inf.D.d_mode[0]=Event;
            @(negedge clk);
            inf.mode_valid=1'b0;
            inf.D='bx;
            //repeat($urandom_range(0,3)) @(negedge clk);
        end
    //---------Date---------//

    i=random_date_obj1.randomize();
    //date_obj1=random_date_obj1.date_variable;
    if(i_pat<=16)begin
        corner_month=4'b1100;   // 12/31 = December/thirty-first
        corner_day  =5'b11111;  // 12/31 = December/thirty-first
        date_obj1={corner_month,corner_day};  
    end
    else begin
        corner_month=4'b0001;   // 1/1 = January/First
        corner_day  =5'b000001; // 1/1 = January/First
        date_obj1={corner_month,corner_day};
    end
    inf.date_valid=1'b1;
    inf.D.d_date[0]=date_obj1;//inf.D.d_date[0]={date_obj1.M,date_obj1.D};
    @(negedge clk);
    inf.date_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------No. of data in DRAM---------//
    //i=random_data_no_obj1.randomize();
    if(i_pat<=16)begin
        data_no_obj1=i_pat;
    end
    else begin
        i=random_data_no_obj1.randomize();
        data_no_obj1=random_data_no_obj1.data_no_variable;
    end

    inf.data_no_valid=1'b1;
    inf.D.d_data_no[0]=data_no_obj1;
    @(negedge clk);
    inf.data_no_valid=1'b0;
    inf.D='bx;

end endtask

task action_task_Restock;begin
    inf.sel_action_valid=1'b1; 
    inf.D.d_act[0]=Restock; //Action_struct member
    action=Restock;//Only use for Debug
    @(negedge clk);
    inf.sel_action_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Date---------//
    i=random_date_obj1.randomize();
    date_obj1=random_date_obj1.date_variable;
    inf.date_valid=1'b1;
    inf.D.d_date[0]=date_obj1;//inf.D.d_date[0]={date_obj1.M,date_obj1.D};
    @(negedge clk);
    inf.date_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------No. of data in DRAM---------//
    if(i_pat<=16)begin
        data_no_obj1=i_pat;
    end
    else begin
        i=random_data_no_obj1.randomize();
        data_no_obj1=random_data_no_obj1.data_no_variable;
    end
    inf.data_no_valid=1'b1;
    inf.D.d_data_no[0]=data_no_obj1;
    @(negedge clk);
    inf.data_no_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Restock amount of Rose(stock_Rose)---------//  
    i=random_stock_obj1.randomize();
    stock_Rose=random_stock_obj1.stock_variable;
    inf.restock_valid=1'b1;
    inf.D.d_stock[0]=stock_Rose;
    @(negedge clk);
    inf.restock_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Restock amount of Lily(stock_Lily)---------// 
    i=random_stock_obj1.randomize();
    stock_Lily=random_stock_obj1.stock_variable;
    inf.restock_valid=1'b1;
    inf.D.d_stock[0]=stock_Lily;
    @(negedge clk);
    inf.restock_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Restock amount of Lily(stock_Carnation)---------// 
    i=random_stock_obj1.randomize();
    stock_Carnation=random_stock_obj1.stock_variable;
    inf.restock_valid=1'b1;
    inf.D.d_stock[0]=stock_Carnation;
    @(negedge clk);
    inf.restock_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Restock amount of Lily(stock_Baby_Breath)---------// 
    i=random_stock_obj1.randomize();
    stock_Baby_Breath=random_stock_obj1.stock_variable;
    inf.restock_valid=1'b1;
    inf.D.d_stock[0]=stock_Baby_Breath;
    @(negedge clk);
    inf.restock_valid=1'b0;
    inf.D='bx;

end endtask

task action_task_Check_Valid_Date;begin
    inf.sel_action_valid=1'b1; 
    inf.D.d_act[0]=Check_Valid_Date;
    action=Check_Valid_Date;//Only use for Debug
    @(negedge clk);
    inf.sel_action_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------Date---------//
    i=random_date_obj1.randomize();
    date_obj1=random_date_obj1.date_variable;
    inf.date_valid=1'b1;
    inf.D.d_date[0]=date_obj1;//inf.D.d_date[0]={date_obj1.M,date_obj1.D};
    @(negedge clk);
    inf.date_valid=1'b0;
    inf.D='bx;
    //repeat($urandom_range(0,3)) @(negedge clk); //delay 
    //---------No. of data in DRAM---------//
    if(i_pat<=16)begin
        data_no_obj1=i_pat;
    end
    else begin
        i=random_data_no_obj1.randomize();
        data_no_obj1=random_data_no_obj1.data_no_variable;
    end
    inf.data_no_valid=1'b1;
    inf.D.d_data_no[0]=data_no_obj1;
    @(negedge clk);
    inf.data_no_valid=1'b0;
    inf.D='bx;
end endtask

task wait_out_valid_task;begin
    latency=0;
    while(inf.out_valid !== 1)begin
        latency=latency+1;
        if(latency==1000)begin  
            $display("********************************************************");     
            $display("                          FAIL!                         ");
            $display("                  PATTERN NO.%4d 	                      ",i_pat);
            $display("*  The execution latency exceeded 1000 cycles at %8t   *", $time);
            $display("********************************************************");
            repeat (3) @(negedge clk);
            $finish;
        end
        @(negedge clk);
    end
    total_latency = total_latency + latency;
end endtask

integer dram_address;
logic [7:0] x0,x1,x2,x3;
logic [7:0] x4,x5,x6,x7;


logic [31:0]dram_1,dram_2;
logic [63:0]dram;
logic golden_complete;
task check_answer_task;begin
    dram_address=65536 + 8*data_no_obj1;
    //No.0 Addr =10000
    x0=golden_DRAM[dram_address+0];//[0]
    x1=golden_DRAM[dram_address+1];//[1]
    x2=golden_DRAM[dram_address+2];//[2]
    x3=golden_DRAM[dram_address+3];//[3]
    //No.0 Addr =10004
    x4=golden_DRAM[dram_address+4];//[0]
    x5=golden_DRAM[dram_address+5];//[1]
    x6=golden_DRAM[dram_address+6];//[2]
    x7=golden_DRAM[dram_address+7];//[3]

    //dram_1={x3,x2,x1,x0}; //wrong coding style ,but cause x is integer ;
    //dram_2={x7,x6,x5,x4}; //wrong coding style ,but cause x is integer ;
    dram_1={x3,x2,x1,x0};
    dram_2={x7,x6,x5,x4};
    dram={dram_2,dram_1};
    Dram_data.Rose         = dram_2[31:20]; // 12 bits
    Dram_data.Lily         = dram_2[19:8];  // 12 bits
    Dram_data.M            = dram_2[7:0];   // 8 bits
    Dram_data.Carnation    = dram_1[31:20]; // 12 bits
    Dram_data.Baby_Breath  = dram_1[19:8];  // 12 bits
    Dram_data.D            = dram_1[7:0];   // 8 bits
    case(Action_Operation_Mode)
    0:Purchase_task;
    1:Restock_task;
    2:Check_Valid_Date_task;
    endcase
end endtask


logic [9:0] Rose_require,Lily_require,Carnation_require,Baby_Breath_require;//1023
logic [11:0]new_Rose,new_Lily,new_Carnation,new_Baby_Breath; //4095 
logic [12:0]restock_Rose,restock_Lily,restock_Carnation,restock_Baby_Breath;//8195 [11:0]
task Purchase_task; begin
    Rose_require=0;
    Lily_require=0;
    Carnation_require=0;
    Baby_Breath_require=0;
    case({ order_info_obj1.Strategy_Type_O , order_info_obj1.Mode_O}) //concatenate
    {Strategy_A,Single     }:Rose_require=120;
    {Strategy_A,Group_Order}:Rose_require=480;
    {Strategy_A,Event      }:Rose_require=960;
    {Strategy_B,Single     }:Lily_require=120;
    {Strategy_B,Group_Order}:Lily_require=480;
    {Strategy_B,Event      }:Lily_require=960;
    {Strategy_C,Single     }:Carnation_require=120;
    {Strategy_C,Group_Order}:Carnation_require=480;
    {Strategy_C,Event      }:Carnation_require=960;
    {Strategy_D,Single     }:Baby_Breath_require=120;
    {Strategy_D,Group_Order}:Baby_Breath_require=480;
    {Strategy_D,Event      }:Baby_Breath_require=960;
    
    {Strategy_E,Single     }:begin Rose_require=60;  Lily_require=60;  end //50% to Rose, 50% to Lily
    {Strategy_E,Group_Order}:begin Rose_require=240; Lily_require=240; end //50% to Rose, 50% to Lily
    {Strategy_E,Event      }:begin Rose_require=480; Lily_require=480; end //50% to Rose, 50% to Lily

    {Strategy_F,Single     }:begin Carnation_require=60;  Baby_Breath_require=60;  end //50% to Carnation, 50% to Baby Breath
    {Strategy_F,Group_Order}:begin Carnation_require=240; Baby_Breath_require=240; end //50% to Carnation, 50% to Baby Breath
    {Strategy_F,Event      }:begin Carnation_require=480; Baby_Breath_require=480; end //50% to Carnation, 50% to Baby Breath

    {Strategy_G,Single     }:begin Rose_require=60;  Carnation_require=60;  end //50% to Rose, 50% to Carnation
    {Strategy_G,Group_Order}:begin Rose_require=240; Carnation_require=240; end //50% to Rose, 50% to Carnation
    {Strategy_G,Event      }:begin Rose_require=480; Carnation_require=480; end //50% to Rose, 50% to Carnation

    {Strategy_H,Single     }:begin Rose_require=30;  Lily_require=30;  Carnation_require=30;  Baby_Breath_require=30;  end //25% equally to all four types
    {Strategy_H,Group_Order}:begin Rose_require=120; Lily_require=120; Carnation_require=120; Baby_Breath_require=120; end //25% equally to all four types
    {Strategy_H,Event      }:begin Rose_require=240; Lily_require=240; Carnation_require=240; Baby_Breath_require=240; end //25% equally to all four types
    endcase
    //date_obj1.M,date_obj1.D

    //priority warning message
    if(date_obj1.M < Dram_data.M || (date_obj1.M === Dram_data.M && date_obj1.D < Dram_data.D)) begin// Month || (Month===Month , Day <Day )
        golden_warning_message = Date_Warn;
    end
    else begin
        case(order_info_obj1.Strategy_Type_O)
        Strategy_A: golden_warning_message=(Rose_require        >Dram_data.Rose)       ?Stock_Warn:No_Warn;
        Strategy_B: golden_warning_message=(Lily_require        >Dram_data.Lily)       ?Stock_Warn:No_Warn;
        Strategy_C: golden_warning_message=(Carnation_require   >Dram_data.Carnation)  ?Stock_Warn:No_Warn;
        Strategy_D: golden_warning_message=(Baby_Breath_require >Dram_data.Baby_Breath)?Stock_Warn:No_Warn;
        Strategy_E: golden_warning_message=(Rose_require        >Dram_data.Rose      || Lily_require        >Dram_data.Lily      )?Stock_Warn:No_Warn;
        Strategy_F: golden_warning_message=(Carnation_require   >Dram_data.Carnation || Baby_Breath_require>Dram_data.Baby_Breath)?Stock_Warn:No_Warn;
        Strategy_G: golden_warning_message=(Rose_require        >Dram_data.Rose      || Carnation_require   >Dram_data.Carnation )?Stock_Warn:No_Warn;
        Strategy_H: golden_warning_message=(Rose_require        >Dram_data.Rose || Lily_require        >Dram_data.Lily || Carnation_require   >Dram_data.Carnation || Baby_Breath_require>Dram_data.Baby_Breath)?Stock_Warn:No_Warn;
        endcase
    end
    if(golden_warning_message==No_Warn)
        golden_complete=1'b1;
    else
        golden_complete=1'b0;

    if(golden_complete==1'b1)begin
        new_Rose         = (Dram_data.Rose        -Rose_require      );
        new_Lily         = (Dram_data.Lily        -Lily_require      );    
        new_Carnation    = (Dram_data.Carnation   -Carnation_require );
        new_Baby_Breath  = (Dram_data.Baby_Breath-Baby_Breath_require);
        {golden_DRAM[dram_address+7],golden_DRAM[dram_address+6],golden_DRAM[dram_address+5],golden_DRAM[dram_address+4],golden_DRAM[dram_address+3],golden_DRAM[dram_address+2],golden_DRAM[dram_address+1],golden_DRAM[dram_address+0]}={new_Rose,new_Lily,4'b0,Dram_data.M,new_Carnation,new_Baby_Breath,3'b0,Dram_data.D};
    end
    if((inf.warn_msg !== golden_warning_message) | (inf.complete !== golden_complete)) begin
        $display("-----------------------------------------------------------------------------------");
        $display("                 PATTERN NO.%4d 	                               ", i_pat);
        $display("                 Wrong Answer                                    ");
        $display("%s           Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s           Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        $display("-----------------------------------------------------------------------------------");
        repeat (3) @(negedge clk);
        $finish;
    end

end endtask

task Restock_task;begin
    restock_Rose       = stock_Rose        +Dram_data.Rose       ;
    restock_Lily       = stock_Lily        +Dram_data.Lily       ;
    restock_Carnation  = stock_Carnation   +Dram_data.Carnation  ; 
    restock_Baby_Breath= stock_Baby_Breath +Dram_data.Baby_Breath;

    if(restock_Rose>4095 || restock_Lily>4095 || restock_Carnation>4095 || restock_Baby_Breath>4095)begin
        golden_warning_message=Restock_Warn;
    end
    else begin
        golden_warning_message=No_Warn;
    end
    if(golden_warning_message==No_Warn)
        golden_complete=1'b1;
    else
        golden_complete=1'b0;
  
    restock_Rose       =(restock_Rose       [12]==1'b1)? 'd4095: restock_Rose       [11:0];//>=4096 means[12]==1'b1 clamp to 4095
    restock_Lily       =(restock_Lily       [12]==1'b1)? 'd4095: restock_Lily       [11:0];//>=4096 means[12]==1'b1 clamp to 4095
    restock_Carnation  =(restock_Carnation  [12]==1'b1)? 'd4095: restock_Carnation  [11:0];//>=4096 means[12]==1'b1 clamp to 4095
    restock_Baby_Breath=(restock_Baby_Breath[12]==1'b1)? 'd4095: restock_Baby_Breath[11:0];//>=4096 means[12]==1'b1 clamp to 4095

    {golden_DRAM[dram_address+7],golden_DRAM[dram_address+6],golden_DRAM[dram_address+5],golden_DRAM[dram_address+4],golden_DRAM[dram_address+3],golden_DRAM[dram_address+2],golden_DRAM[dram_address+1],golden_DRAM[dram_address+0]}={restock_Rose[11:0],restock_Lily[11:0],4'b0,date_obj1.M,restock_Carnation[11:0],restock_Baby_Breath[11:0],3'b0,date_obj1.D};
    //check task;
    if((inf.warn_msg !== golden_warning_message) | (inf.complete !== golden_complete)) begin
        $display("-----------------------------------------------------------------------------------");
        $display("                 PATTERN NO.%4d 	                               ", i_pat);
        $display("                 Wrong Answer                                    ");
        $display("%s                 Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s                 Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        $display("-----------------------------------------------------------------------------------");
        repeat (3) @(negedge clk);
        $finish;
    end
end endtask


task Check_Valid_Date_task;begin
    if(date_obj1.M < Dram_data.M || (date_obj1.M === Dram_data.M && date_obj1.D < Dram_data.D)) begin// Month || (Month===Month , Day <Day )
        golden_warning_message = Date_Warn;
    end
    else begin
        golden_warning_message = No_Warn;
    end
    if(golden_warning_message==No_Warn)
        golden_complete=1'b1;
    else
        golden_complete=1'b0;
    if((inf.warn_msg !== golden_warning_message) | (inf.complete !== golden_complete)) begin
        $display("-----------------------------------------------------------------------------------");
        $display("                 PATTERN NO.%4d 	                               ", i_pat);
        $display("                 Wrong Answer                                    ");
        $display("%s                 Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s                 Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        $display("-----------------------------------------------------------------------------------");
        repeat (3) @(negedge clk);        
        $finish;
    end
end endtask

task display_task;begin
    case(Action_Operation_Mode)
    0:begin 
        $display("%s===================================================%s", reset_color, reset_color);
        $display("%s          Wrong Answer%s[Action]-> [Purchase]         %s", txt_red_prefix, txt_yellow_prefix, reset_color);
        $display("%s===================================================%s", reset_color, reset_color);
        //$display("                                                                   ");
        $display("%s               PATTERN NO.%4d        %s", txt_blue_prefix,i_pat, reset_color);
        $display("%s    Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s    Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        display_strategy_and_mode;
        display_date;
        display_Dram_info;
        $display("%sDram Require Flower   : Rose=%4d , Lily=%4d , Carnation=%4d, Baby_Breath=%4d %s",txt_green_prefix,Rose_require,Lily_require,Carnation_require,Baby_Breath_require,reset_color);
        if(golden_warning_message == No_Warn)
            $display("%sFlower Update to Dram : Rose=%4d , Lily=%4d , Carnation=%4d, Baby_Breath=%4d %s",txt_blue_prefix,new_Rose,new_Lily,new_Carnation,new_Baby_Breath,reset_color);
    end
    1:begin
        $display("%s===================================================%s", reset_color, reset_color);
        $display("%s          Wrong Answer%s[Action]-> [Restock]         %s", txt_red_prefix, txt_yellow_prefix, reset_color);
        $display("%s===================================================%s", reset_color, reset_color);
        //$display("                                                                   ");
        $display("%s               PATTERN NO.%4d        %s", txt_blue_prefix,i_pat, reset_color);
        $display("%s    Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s    Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        display_date;
        display_Dram_info;
             
        $display("%sRestock amount               : Rose=%4d , Lily=%4d , Carnation=%4d , Baby_Breath=%4d %s",
                     txt_green_prefix,
                     stock_Rose, stock_Lily,
                     stock_Carnation, stock_Baby_Breath,
                     reset_color);
        $display("%sRestock amount + Dram amount : Rose=%4d , Lily=%4d , Carnation=%4d , Baby_Breath=%4d %s",
                     txt_yellow_prefix  ,
                     restock_Rose       ,
                     restock_Lily       ,
                     restock_Carnation  ,
                     restock_Baby_Breath,
                     reset_color ); 
                    
        $display("%s================After Store to Dram================%s",reset_color,reset_color);        
        display_Dram_info;
    end
    2:begin
        $display("%s===================================================%s", reset_color, reset_color);
        $display("%s          Wrong Answer%s[Action]-> [Check Valid Date]         %s", txt_red_prefix, txt_yellow_prefix, reset_color);
        $display("%s===================================================%s", reset_color, reset_color);
        //$display("                                                                   ");
        $display("%s               PATTERN NO.%4d        %s", txt_blue_prefix,i_pat, reset_color);
        $display("%s    Golden Warning Message is : %d , Complete is : %d      %s",txt_red_prefix ,golden_warning_message, golden_complete,reset_color);
        $display("%s    Your   Warning Message is : %d , Complete is : %d      %s", txt_red_prefix,inf.warn_msg, inf.complete,reset_color);
        display_date;
        display_Dram_info;
    
    end
    endcase
    $display("\n%s===================Debug End======================\n\n%s",txt_red_prefix, reset_color);
    //$finish;
end endtask


task display_strategy_and_mode;begin
    case({ order_info_obj1.Strategy_Type_O , order_info_obj1.Mode_O}) //concatenate
        {Strategy_A,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_A,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_A,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_B,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_B,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_B,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_C,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_C,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_C,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_D,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_D,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_D,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_E,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_E,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_E,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_F,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_F,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_F,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_G,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_G,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_G,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_H,Single     }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_H,Group_Order}:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
        {Strategy_H,Event      }:begin
            $display("%s Golden Strategy  is : %d , Golden Mode is : %d      %s",txt_green_prefix ,order_info_obj1.Strategy_Type_O, order_info_obj1.Mode_O,reset_color);
        end
    endcase
end endtask
task display_date;begin
    $display("%s===================================================%s", reset_color, reset_color);
    $display("%s      Month = %2d , Day = %2d   %s",txt_blue_prefix,date_obj1.M,date_obj1.D,reset_color);
    //$display("%s===================================================%s", reset_color, reset_color);
end endtask
task display_Dram_info;begin
    //$display("%s===================================================%s", reset_color, reset_color);
    $display("%s      Dram No : %d         %s",txt_purple_prefix,data_no_obj1,reset_color);
    //$display("%s===================================================%s", reset_color, reset_color);
    $display("%s      Dram Address(Decimal)    : %6d ~ %6d      %s",txt_yellow_prefix,dram_address,dram_address+7,reset_color);
    $display("%s      Dram Address(Hexidecimal): %h ~ %h      %s",txt_green_prefix,dram_address,dram_address+7,reset_color);
    $display("%s===================================================%s", reset_color, reset_color);
    
    $display("%sDram: Rose=%4d , Lily=%4d , Carnation=%4d , Baby_Breath=%4d , %sMonth=%2d , Day=%2d  %s",
    txt_blue_prefix      ,
    Dram_data.Rose       ,
    Dram_data.Lily       ,
    Dram_data.Carnation  ,
    Dram_data.Baby_Breath,
    txt_purple_prefix    ,
    Dram_data.M          ,
    Dram_data.D          ,
    reset_color); 
end endtask


/*
task display_Dram_require_flower;begin
        $display("%s   Dram Require Flower : Rose=%4d , Lily=%4d , Carnation=%4d, Baby_Breath=%4d %s",
        txt_green_prefix,
        Rose_require,
        Lily_require,
        Carnation_require,
        Baby_Breath_require,
        reset_color);
end endtask*/
task display_pass;begin
    $display("\033[37m                                  .$&X.      x$$x              \033[32m      :BBQvi.");
    $display("\033[37m                                .&&;.X&$  :&&$+X&&x            \033[32m     BBBBBBBBQi");
    $display("\033[37m                               +&&    &&.:&$    .&&            \033[32m    :BBBP :7BBBB.");
    $display("\033[37m                              :&&     &&X&&      $&;           \033[32m    BBBB     BBBB");
    $display("\033[37m                              &&;..   &&&&+.     +&+           \033[32m   iBBBv     BBBB       vBr");
    $display("\033[37m                             ;&&...   X&&&...    +&.           \033[32m   BBBBBKrirBBBB.     :BBBBBB:");
    $display("\033[37m                             x&$..    $&&X...    +&            \033[32m  rBBBBBBBBBBBR.    .BBBM:BBB");
    $display("\033[37m                             X&;...   &&&....    &&            \033[32m  BBBB   .::.      EBBBi :BBU");
    $display("\033[37m                             $&...    &&&....    &&            \033[32m MBBBr           vBBBu   BBB.");
    $display("\033[37m                             $&....   &&&...     &$            \033[32m i7PB          iBBBBB.  iBBB");
    $display("\033[37m                             $&....   &&& ..    .&x                        \033[32m  vBBBBPBBBBPBBB7       .7QBB5i");
    $display("\033[37m                             $&....   &&& ..    x&+                        \033[32m :RBBB.  .rBBBBB.      rBBBBBBBB7");
    $display("\033[37m                             X&;...   x&&....   &&;                        \033[32m    .       BBBB       BBBB  :BBBB");
    $display("\033[37m                             x&X...    &&....   &&:                        \033[32m           rBBBr       BBBB    BBBU");
    $display("\033[37m                             :&$...    &&+...   &&:                        \033[32m           vBBB        .BBBB   :7i.");
    $display("\033[37m                              &&;...   &&$...   &&:                        \033[32m             .7  BBB7   iBBBg");
    $display("\033[37m                               && ...  X&&...   &&;                                         \033[32mdBBB.   5BBBr");
    $display("\033[37m                               .&&;..  ;&&x.    $&;.$&$x;                                   \033[32m ZBBBr  EBBBv     YBBBBQi");
    $display("\033[37m                               ;&&&+   .+xx;    ..  :+x&&&&&&&x                             \033[32m  iBBBBBBBBD     BBBBBBBBB.");
    $display("\033[37m                        +&&&&&&X;..             .          .X&&&&&x                         \033[32m    :LBBBr      vBBBi  5BBB");
    $display("\033[37m                    $&&&+..                                    .:$&&&&.                     \033[32m          ...   :BBB:   BBBu");
    $display("\033[37m                 $&&$.                                             .X&&&&.                  \033[32m         .BBBi   BBBB   iMBu");
    $display("\033[37m              ;&&&:                                               .   .$&&&                x\033[32m          BBBX   :BBBr");
    $display("\033[37m            x&&x.      .+&&&&&.                .x&$x+:                  .$&&X         $+  &x  ;&X   \033[32m  .BBBv  :BBBQ");
    $display("\033[37m          .&&;       .&&&:                      .:x$&&&&X                 .&&&        ;&     +&.    \033[32m   .BBBBBBBBB:");
    $display("\033[37m         $&&       .&&$.                             ..&&&$                 x&& x&&&X+.          X&x\033[32m     rBBBBB1.");
    $display("\033[37m        &&X       ;&&:                                   $&&x                $&x   .;x&&&&:                       ");
    $display("\033[37m      .&&;       ;&x                                      .&&&                &&:       .$&&$    ;&&.             ");
    $display("\033[37m      &&;       .&X                                         &&&.              :&$          $&&x                   ");
    $display("\033[37m     x&X       .X& .                                         &&&.              .            ;&&&  &&:             ");
    $display("\033[37m     &&         $x                                            &&.                            .&&&                 ");
    $display("\033[37m    :&&                                                       ;:                              :&&X                ");
    $display("\033[37m    x&X                 :&&&&&;                ;$&&X:                                          :&&.               ");
    $display("\033[37m    X&x .              :&&&  $&X              &&&  X&$                                          X&&               ");
    $display("\033[37m    x&X                x&&&&&&&$             :&&&&$&&&                                          .&&.              ");
    $display("\033[37m    .&&    \033[38;2;255;192;203m      ....\033[37m  .&&X:;&&+              &&&++;&&                                          .&&               ");
    $display("\033[37m     &&    \033[38;2;255;192;203m  .$&.x+..:\033[37m  ..+Xx.                 :&&&&+\033[38;2;255;192;203m  .;......    \033[37m                             .&&");
    $display("\033[37m     x&x   \033[38;2;255;192;203m .x&:;&x:&X&&.\033[37m              .             \033[38;2;255;192;203m .&X:&&.&&.:&.\033[37m                             :&&");
    $display("\033[37m     .&&:  \033[38;2;255;192;203m  x;.+X..+.;:.\033[37m         ..  &&.            \033[38;2;255;192;203m &X.;&:+&$ &&.\033[37m                             x&;");
    $display("\033[37m      :&&. \033[38;2;255;192;203m    .......   \033[37m         x&&&&&$++&$        \033[38;2;255;192;203m .... ......: \033[37m                             && ");
    $display("\033[37m       ;&&                          X&  .x.              \033[38;2;255;192;203m .... \033[37m                               .&&;                ");
    $display("\033[37m        .&&x                        .&&$X                                          ..         .x&&&               ");
    $display("\033[37m          x&&x..                                                                 :&&&&&+         +&X              ");
    $display("\033[37m            ;&&&:                                                                     x&&$XX;::x&&X               ");
    $display("\033[37m               &&&&&:.                                                              .X&x    +xx:                  ");
    $display("\033[37m                  ;&&&&&&&&$+.                                  :+x&$$X$&&&&&&&&&&&&&$                            ");
    $display("\033[37m                       .+X$&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$X+xXXXxxxx+;.                                   ");
    $display("\033[32m                                    Congratulations!");
    $display("\033[32m                                    total latency = %d \033[37m",total_latency);
end endtask;
endprogram
