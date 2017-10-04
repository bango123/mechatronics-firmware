// ------------------------------------------------
// Single Tick Version 
// ------------------------------------------------
module EncPeriodSingle(
    input wire clk,           // sysclk
    input wire clk_fast,      // count this clock between encoder ticks
    input wire reset,         // global reset signal
    input wire a,             // quad encoder line a
    input wire b,             // quad encoder line b
    input wire dir,           // dir from EncQuad
    output reg[31:0] period   // num of fast clock ticks
);

    wire a_up_tick;
    wire[21:0] a_up_latched;   // channel a up latched value
    wire[21:0] a_up_counter;   // channel a up free running counter
    wire a_up_dir_changed;
    wire a_up_overflow;
    
//------------------------------------------------------------------------------
// hardware description
//

EncPeriod EncPerUpA(clk_fast, reset,  a, dir, a_up_tick, a_up_latched, a_up_counter, a_up_dir_changed, a_up_overflow);

localparam[1:0] a_up = 2'b00;


// The following code returns the larger of (1) the most recent latched value (determined by mux)
// or (2) the free-running counter for the next expected encoder transition, based on direction, dir.
// Note that a direction change sets the free-running counter to overflow, so that will take priority
// over the latched value, which is reasonable behavior (i.e., a recent direction change should result
// in an estimated velocity of 0).
// From EncQuad.v:
//   dir 0 is A leading B  (cycle is Aup -> Bup -> Adown -> Bdown)
//   dir 1 is B leading A  (cycle is Bup -> Aup -> Bdown -> Adown)
always @(posedge clk_fast or negedge reset) begin
   if (reset == 0) begin
      period <= 32'd0;
   end
   else begin
      period <= {1'b1, dir, a_up_dir_changed, a_up, a_up_overflow, 4'd0, a_up_latched};
   end
end

endmodule
