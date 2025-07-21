/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
NYCU Institute of Electronic
2025 Spring IC Design Laboratory 
Lab10: SystemVerilog Coverage & Assertion
File Name   : CHECKER.sv
Module Name : CHECKER
Release version : v1.0 (Release Date: May-2025)
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/

`include "Usertype.sv"

module Checker(input clk, INF.CHECKER inf);
import usertype::*;
//Color Declaration 
reg[10*8:1] bkg_red_prefix    = "\033[41;1m";
reg[9*8:1]  reset_color        = "\033[1;0m";

class Strategy_and_mode;
    Strategy_Type f_type;
    Mode f_mode;
endclass

Strategy_and_mode fm_info = new();

/*
always_comb begin
    if(inf.strategy_valid)
        fm_info.f_type = inf.D.d_strategy[0];
    if(inf.mode_valid)
        fm_info.f_mode = inf.D.d_mode[0];
end*/
always_ff @(posedge clk)begin
    if(inf.strategy_valid)
        fm_info.f_type = inf.D.d_strategy[0];
    if(inf.mode_valid)
        fm_info.f_mode = inf.D.d_mode[0];
end
parameter NUM_STRATEGY_TYPE = 100;
parameter NUM_MODE          = 100;
parameter NUM_CROSS         = 100;
parameter NUM_WARN_MSG      = 10;
parameter NUM_ACTION        = 300;
parameter NUM_AUTO_BIN_MAX  = 32;

// SPEC1: Strategy coverage
covergroup coverage_SPEC1@(posedge clk iff (inf.strategy_valid));
    option.per_instance = 1;
    option.at_least = NUM_STRATEGY_TYPE;

    coverpoint fm_info.f_type {
        bins strategy_type_obj[] = {[Strategy_A:Strategy_H]};
    }
endgroup

// SPEC2: Mode coverage
covergroup coverage_SPEC2@(posedge clk iff (inf.mode_valid));
    option.per_instance = 1;
    option.at_least = NUM_MODE;

    coverpoint fm_info.f_mode {
        bins mode_obj[] = {Single, Group_Order, Event};
    }
endgroup

// SPEC3: Cross coverage of strategy and mode
covergroup coverage_SPEC3@(posedge clk iff (inf.mode_valid));
    option.per_instance = 1;
    option.at_least = NUM_CROSS;

    /*class_strategy: coverpoint fm_info.f_type {
        bins strategy_obj1[] = {Strategy_A, Strategy_B, Strategy_C, Strategy_D,
                                Strategy_E, Strategy_F, Strategy_G, Strategy_H};
    }
    class_mode: coverpoint fm_info.f_mode {
        bins mode_obj1[] = {Single, Group_Order, Event};
    }*/
    //class_strategy_and_mode: 
    cross fm_info.f_type, fm_info.f_mode;
endgroup

/*
covergroup coverage_SPEC3 @(posedge clk iff (inf.mode_valid));
    option.per_instance = 1;
    option.at_least = NUM_CROSS;
    cross fm_info.f_type, fm_info.f_mode;
endgroup*/
// SPEC4: Warn message coverage
covergroup coverage_SPEC4@(posedge clk iff (inf.out_valid));
    option.per_instance = 1;
    option.at_least = NUM_WARN_MSG;

    coverpoint inf.warn_msg {
        bins warn_msg_obj1[] = {No_Warn, Date_Warn, Stock_Warn, Restock_Warn};
    }
endgroup

// SPEC5: Action transitions
covergroup coverage_SPEC5@(posedge clk iff (inf.sel_action_valid));
    option.per_instance = 1;
    option.at_least = NUM_ACTION;

    coverpoint inf.D.d_act[0] {
        bins action[] = ([Purchase:Check_Valid_Date] => [Purchase:Check_Valid_Date]);
    }
endgroup

// SPEC6: Restock values
covergroup coverage_SPEC6@(posedge clk iff (inf.restock_valid));
    option.per_instance = 1;
    option.at_least = 1;

    coverpoint inf.D.d_stock[0] {
        option.auto_bin_max = NUM_AUTO_BIN_MAX;
    }
endgroup

// Instantiate coverage groups
coverage_SPEC1 coverage_spec1 = new();
coverage_SPEC2 coverage_spec2 = new();
coverage_SPEC3 coverage_spec3 = new();
coverage_SPEC4 coverage_spec4 = new();
coverage_SPEC5 coverage_spec5 = new();
coverage_SPEC6 coverage_spec6 = new();


/*
covergroup converage_SPEC4(@posedge clk iff inf.out_valid);
    option.per_instance=1;
    option.at_least=1;
    coverpoint inf.warn_msg[1:0]{
        bins warn_msg_0 ={No_Warn};     //2'b00
        bins warn_msg_1 ={Date_Warn};   //2'b01
        bins warn_msg_2 ={Stock_Warn};  //2'b10
        bins warn_msg_3 ={Restock_Warn};//2'b11
    }
endgroup */



/*
covergroup converage_SPEC1(@posedge clk iff inf.mode_valid); //coverage_SPEC1 is the covergroup_mode_name
    option.per_instance = 1;
    //option.auto_bin_max = 1;
    option.at_least = 1;
    C1: coverpoint temp1 {
         bins temp2[]={3'd0,3'd1,3'd2,3'd3};
    }

    C2: coverpoint temp2

    mix: cross C1,C2;

endgroup
*/
sequence strategy_valid_check;
    inf.strategy_valid;
endsequence 

sequence mode_valid_check;
    inf.mode_valid;
endsequence 

sequence date_valid_check;
    inf.date_valid;
endsequence 

sequence data_no_valid_check;
   inf.data_no_valid;
endsequence 
sequence restock_valid_check;
    inf.restock_valid ;
endsequence 

sequence purchase_mode;
    ##[1:4] strategy_valid_check 
    ##[1:4] mode_valid_check 
    ##[1:4] date_valid_check 
    ##[1:4]data_no_valid_check;
endsequence

sequence restock_mode;
    ##[1:4] date_valid_check 
    ##[1:4] data_no_valid_check

    ##[1:4] restock_valid_check 
    ##[1:4] restock_valid_check 
    ##[1:4] restock_valid_check 
    ##[1:4] restock_valid_check;
endsequence 

sequence check_valid_date_mode;
    ##[1:4] date_valid_check 
    ##[1:4] data_no_valid_check;
endsequence

property Assertion_1_reset; @(posedge inf.rst_n) 1 |-> @(posedge clk) 
    //output 
    (inf.out_valid === 0 && inf.complete === 0 && inf.warn_msg  === 0 )&&
    //valid  
    //(inf.sel_action_valid === 0) &&(inf.strategy_valid === 0) &&(inf.mode_valid === 0)&&
    //(inf.date_valid === 0)&&(inf.data_no_valid === 0)&&(inf.restock_valid === 0)&&
    //AXI 
    
    (inf.AR_VALID   === 0 && inf.AR_ADDR  === 0 && 
     inf.R_READY    === 0 && 
     inf.AW_VALID   === 0 && inf.AW_ADDR  === 0 &&
     inf.W_VALID    === 0 && inf.W_DATA   === 0 &&
     inf.B_READY    === 0);

endproperty

Assertion_1:assert property(Assertion_1_reset) // All outputs signals (including AFS.sv) should be zero after reset
    else begin
    
        $display("\n%sAssertion 1 is violated%s\n",bkg_red_prefix,reset_color);
        $fatal;
    end

///     ================Purchase============         ///
property Assertion_2_Purchase;@(posedge clk)
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Purchase) ##0 purchase_mode |-> ##[0:1000] inf.out_valid;

endproperty

Assertion_2_1:assert property(Assertion_2_Purchase) //[Purchase] Latency should be less than 1000 cycles for each operation
    else begin

        $display("\n%sAssertion 2 is violated%s\n",bkg_red_prefix,reset_color);
        $fatal;
    end


///     ===============Restock=================         ///
property Assertion_2_Restock;@(posedge clk)       //[Restock] Latency should be less than 1000 cycles for each operation
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Restock) ##0 restock_mode |-> ##[0:1000] inf.out_valid;

endproperty

Assertion_2_2:assert property(Assertion_2_Restock)
    else begin

        $display("\n%sAssertion 2 is violated%s\n",bkg_red_prefix,reset_color);
        $fatal;
    end
//////////////////////////////////////////////////////////////
property Assertion_2_Check_Valid_Date;@(posedge clk)
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Check_Valid_Date) ##0 check_valid_date_mode |-> ##[0:1000] inf.out_valid;

endproperty


Assertion_2_3:assert property(Assertion_2_Check_Valid_Date)  //[Check_Valid_Date] Latency should be less than 1000 cycles for each operation
    else begin

        $display("\n%sAssertion 2 is violated%s\n",bkg_red_prefix,reset_color);
        $fatal;
    end

//Combine property && assertion
Assertion_3_output_zero_check: assert property (   //If action is completed (complete=1), warn_msg should be 2’b0 (No_Warn). 
    @(negedge clk)
    (inf.complete===1 && inf.out_valid !==0) |-> (inf.warn_msg ===2'b00)
    )
else begin
    $display("\n%sAssertion 3 is violated%s\n",bkg_red_prefix,reset_color);
    //$display("Assertion_3 is violated at time %t", $time);
    //$display("Expected inf.complete = 1 , inf.out_valid = 1 , inf.warn_msg = No_Warn(2'b00) ");
    //$display("Your     inf.complete = %0d , inf.out_valid = %0d , inf.warn_msg = 2'b%02b ",inf.complete, inf.out_valid, inf.warn_msg);
    $fatal;
end


Assertion_4_Purchase: assert property(
    @(posedge clk) 
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Purchase) |-> purchase_mode
    )
else begin
    $display("\n%sAssertion 4 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end
Assertion_4_Restock: assert property(
    @(posedge clk) 
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Restock) |-> restock_mode
    )
else begin
    $display("\n%sAssertion 4 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end

Assertion_4_Check_Date_Valid: assert property(
    @(posedge clk) 
    (inf.sel_action_valid ===1 & inf.D.d_act[0] === Check_Valid_Date) |-> check_valid_date_mode
    )
else begin
    $display("\n%sAssertion 4 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end

property Assertion_5_none_overlap;
    @(posedge clk)
    $onehot0({inf.sel_action_valid, inf.strategy_valid, inf.mode_valid, //one of the signal can be 1 ,other will be zero,   or all the signals are zero 
              inf.date_valid, inf.data_no_valid, |inf.restock_valid});
endproperty

Assertion_5_Not_Overlap: assert property (Assertion_5_none_overlap)
else begin
    $display("\n%sAssertion 5 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end

//Combine property && assertion
//   use =>  because we want to check whether the out_valid overlap?
Assertion_6_Out_valid_only_one_cycle: assert property (
    @(posedge clk)
        inf.out_valid |=> !inf.out_valid
    )
else begin
    $display("\n%sAssertion 6 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end



property Assertion_7_one_to_four_cycle;
    @(posedge clk) (inf.out_valid===1) ##(1) !inf.out_valid |-> ##[0:3] inf.sel_action_valid; 
endproperty
Assertion_7_next_operation: assert property(Assertion_7_one_to_four_cycle)
else begin
    $display("\n%sAssertion 7 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end

Assertion_8_Month:assert property (
    @(posedge clk) (inf.date_valid===1) |-> (inf.D.d_date[0].M inside {[1:12]})
    )
else begin
    $display("\n%sAssertion 8 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end

Assertion_8_Month_28: assert property (
    @(posedge clk)
    (inf.date_valid === 1 && inf.D.d_date[0].M === 2) |-> (inf.D.d_date[0].D inside {[1:28]})
)
else begin
    $display("\n%sAssertion 8 is violated%s\n", bkg_red_prefix, reset_color);
    $fatal;
end


Assertion_8_Month_30: assert property (
    @(posedge clk)
    (inf.date_valid === 1 &&
     (inf.D.d_date[0].M === 4 || inf.D.d_date[0].M === 6 ||
      inf.D.d_date[0].M === 9 || inf.D.d_date[0].M === 11))
    |-> (inf.D.d_date[0].D inside {[1:30]})
)
else begin
    $display("\n%sAssertion 8 is violated%s\n", bkg_red_prefix, reset_color);
    $fatal;
end

Assertion_8_Month_31: assert property (
    @(posedge clk)
    (inf.date_valid === 1 &&
     (inf.D.d_date[0].M === 1 || inf.D.d_date[0].M === 3 ||
      inf.D.d_date[0].M === 5 || inf.D.d_date[0].M === 7 ||
      inf.D.d_date[0].M === 8 || inf.D.d_date[0].M === 10 ||
      inf.D.d_date[0].M === 12))
    |-> (inf.D.d_date[0].D inside {[1:31]})
)
else begin
    $display("\n%sAssertion 8 is violated%s\n", bkg_red_prefix, reset_color);
    $fatal;
end





property Assertion_9_AW_check;
    @(posedge clk) (inf.AR_VALID === 1) |-> !(inf.AW_VALID);
endproperty
assert property(Assertion_9_AW_check) 
else begin
    $display("\n%sAssertion 9 is violated%s\n",bkg_red_prefix,reset_color);
    $fatal;
end



/*
property ASSERT_3;
    @(negedge clk) ((inf.out_valid !== 0) & (inf.complete === 1)) |-> inf.warn_msg === No_Warn; 
endproperty
assert property(ASSERT_3)                   else begin $display("%0s", bkg_red_prefix); $display(" Assertion 3 is violated "); $display("%0s", reset_color); $fatal; end
*/




endmodule