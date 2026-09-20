module IFU #(
	parameter int XLEN = 32,
	parameter logic [XLEN-1:0] RESET_PC = '0
) (
	input  logic             clk,
	input  logic             rst,

	// Instruction-memory request interface.
	output logic [XLEN-1:0]  imem_addr,
	output logic             imem_valid,
	input  logic [31:0]      imem_rdata,
	input  logic             imem_ready,

	// Pipeline control.
    output logic             mem_stall,
    output logic             mem_flush,
    output logic             branch_taken,
    input  logic             stall,
    input  logic             cpu_stall,
    input  logic             branch_flush,
    input  logic             branch_pc,

	// Instruction supplied to the decode stage.
	output logic [XLEN-1:0]  instruction_pkt,
	output logic [XLEN-1:0]  instruction_pc,
	output logic             instruction_valid
);

	logic [XLEN-1:0] pc;
    logic [XLEN-1:0] buf_1;
    logic [XLEN-1:0] buf_2;

    // TODO: Implement branch prediction and flush logic.

	assign imem_addr  = pc;
	assign imem_valid = !rst && !cpu_stall && !redirect_valid;

	always_ff @(posedge clk) begin
		if (rst) begin
			pc                <= RESET_PC;
			instruction_pkt   <= '0;
			instruction_pc    <= '0;
			instruction_valid <= 1'b0;
        end else if (!cpu_stall && !mem_stall && imem_ready) begin
			instruction_pkt   <= imem_rdata;
			instruction_pc    <= pc;
			instruction_valid <= 1'b1;
			pc                <= pc + XLEN'(4);
		end else if (!stall && !cpu_stall) begin
			instruction_valid <= 1'b0;
		end
	end

endmodule
