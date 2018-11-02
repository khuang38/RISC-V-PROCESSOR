module arbiter (
    input clk,

    // Signals for instruction cache
    output logic i_resp,
    input i_write,
    input i_read,
    input [255:0] i_wdata,
    input [31:0] i_addr,
    output logic [255:0] i_rdata,

    // Signals for data cache
    output logic d_resp,
    input d_write,
    input d_read,
    input [255:0] d_wdata,
    input [31:0] d_addr,
    output logic [255:0] d_rdata,

    input          pmem_resp,
    input [255:0]  pmem_rdata,
    output logic   pmem_read,
    output logic   pmem_write,
    output logic [31:0] pmem_address,
    output logic [255:0] pmem_wdata
);

// Signal assignments
assign pmem_wdata = d_wdata;
assign i_rdata = pmem_rdata;
assign d_rdata = pmem_rdata;

logic addr_sel;

// Instantiation of a mux module inside the arbiter
mux2 cache_addr_mux
(
    .sel(addr_sel),
    .a(i_addr),
    .b(d_addr),
    .f(pmem_address)
);

// Defining the states for arbiter
enum int unsigned{
    null_state,
    i_cache,
    d_cache
} state, next_state;

always_ff @(posedge clk)
    begin
    state <= next_state;
    end

// Declaring all the states transitions
always_comb begin
    next_state = state;

    case(state)
        null_state: begin
            if (i_read) begin
                next_state = i_cache;
            end
            else if (d_read || d_write) begin
                next_state = d_cache;
            end
            else begin
                next_state = null_state;
            end
        end

        i_cache: begin
            if (pmem_resp) begin
                next_state = null_state;
            end
            else begin
                next_state = i_cache;
            end
        end

        d_cache: begin
            if (pmem_resp) begin
                next_state = null_state;
            end
            else begin
                next_state = d_cache;
            end
        end
	endcase
end

// Declaring all the signals inside each state
always_comb begin
    addr_sel = 0;
    pmem_read = 0;
    pmem_write = 0;
    i_resp = 0;
    d_resp = 0;

    // Definition inside states
    case (state)
        null_state: begin
            ;
        end

        i_cache: begin
            addr_sel = 0;
            pmem_read = i_read;
            pmem_write = 0;
            i_resp = pmem_resp;
            d_resp = 0;
        end

        d_cache: begin
            addr_sel = 1;
            pmem_read = d_read;
            pmem_write = d_write;
            i_resp = 0;
            d_resp = pmem_resp;
        end
	endcase
end


endmodule : arbiter
