// File used for writing the module of write eviction buffer
module write_evict_buffer(
    input clk,

    // Connections between cache and the write eviction buffer
    input cmem_read,
    input cmem_write,
    input [31:0] cmem_address,
    input [255:0] cmem_wdata,
    output logic [255:0] cmem_rdata,
    output logic cmem_resp,

    // Connections between write eviction buffer and the 'physical memory' seen by WB
    output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] pmem_address,
    output logic [255:0] pmem_wdata,
    input [255:0] pmem_rdata,
    input logic pmem_resp
);

// Defining some of the logic signals
logic load_data_addr;
logic source_sel, addr_sel;
logic [31:0] addr_out;


// Instantiation of some of the modules that we need
register #(.width(256)) data_reg(
    .clk,
    .load(load_data_addr),
    .in(cmem_wdata),
    .out(pmem_wdata)
);

register addr_reg(
    .clk,
    .load(load_data_addr),
    .in(cmem_address),
    .out(addr_out)
);

mux2 #(.width(256)) read_data_mux
(
    .sel(source_sel),
    .a(pmem_wdata),
    .b(pmem_rdata),
    .f(cmem_rdata)
);

mux2 addr_mux
(
    .sel(addr_sel),
    .a(addr_out),
    .b(cmem_address),
    .f(pmem_address)
);

// Start of the Control of the Write Eviction Buffer
enum int unsigned{
    empty,
    full,
    evict
} state, next_state;

always_ff @(posedge clk)
    begin
    state <= next_state;
end


always_comb begin
    next_state = state;

    case(state)
        empty: begin
            if (cmem_write) begin
                next_state = full;
            end
            else begin
                next_state = empty;
            end
        end

        full: begin
            if (cmem_read) begin
                next_state = full;
            end
            else begin
                next_state = evict;
            end
        end

        evict: begin
            if (pmem_resp) begin
                next_state = empty;
            end
            else begin
                next_state = evict;
            end
        end
	endcase
end

// Declaring all signals related to differnt states
always_comb begin
    load_data_addr = 0;
    cmem_resp = 0;
    pmem_read = 0;
    pmem_write = 0;
    source_sel = 0;
    addr_sel = 0;

    case (state)
        empty: begin
            cmem_resp = (cmem_read&pmem_resp) | cmem_write;
            pmem_read = cmem_read;
            pmem_write = 0;
            load_data_addr = cmem_write;
            addr_sel = 1;   // Select cmem_address
            source_sel = 1;
        end

        full: begin
            if (cmem_read) begin
                // If the data that we want to read is inside the buffer
                if (cmem_address == addr_out) begin
                    cmem_resp = 1;
                    source_sel = 0;
                    pmem_read = 0;
                    pmem_write = 0;
                end

                // If the data is not in the WB but we want to read
                else begin
                    cmem_resp = pmem_resp;
                    source_sel = 1;
                    addr_sel = 1;   // select cmem_address
                    pmem_read = 1;
                    pmem_write = 0;
                end
            end
            else begin
                cmem_resp = 0;
                pmem_read = 0;
                pmem_write = 0;
                // addr_sel = 1;   // select cmem_address
                load_data_addr = 0;
            end
        end

        evict: begin
                cmem_resp = 0;
                pmem_read = 0;
                pmem_write = 1;
                addr_sel = 0;   // select addr reg
                load_data_addr = 0;
        end
	endcase
end

endmodule : write_evict_buffer
