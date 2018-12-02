module l2_cache_control
(
    input clk,

    /* Signals from CPU */
    input mem_read,
    input mem_write,

    /* Signals from P-memory */
    input pmem_resp,

    /* Signals to P-memory */
    output logic pmem_read,
    output logic pmem_write,

    /* Signals to CPU */
    output logic mem_resp,

    /* Signal from Cache Datapath */
    input hit_0,
    input hit_1,
    input hit_2,
    input hit_3,
    input is_hit,

    input valid_out_0,
    input dirty_out_0,
    input valid_out_1,
    input dirty_out_1,

    input valid_out_2,
    input dirty_out_2,
    input valid_out_3,
    input dirty_out_3,
    input all_valid,

    input [2:0] lru_out,

    /* Signal send to Cache Datapath */
    output logic load_data_0,
    output logic load_tag_0,
    output logic load_valid_0,
    output logic load_dirty_0,

    output logic load_data_1,
    output logic load_tag_1,
    output logic load_valid_1,
    output logic load_dirty_1,

    output logic load_data_2,
    output logic load_tag_2,
    output logic load_valid_2,
    output logic load_dirty_2,

    output logic load_data_3,
    output logic load_tag_3,
    output logic load_valid_3,
    output logic load_dirty_3,

    output logic valid_in,
    output logic dirty_in,
    output logic [1:0] way_sel,

    output logic load_lru,
    output logic [2:0] lru_in,
    output logic [2:0] pmem_sel,
    output logic load_pmem_wdata,
    output logic data_sel
    );

enum int unsigned {
    /* All the states, needs to be modified for the final CP */
    // idle,    // Not really useful
    read_write,
    write_back,
    access_pmem
} state, next_state;

always_comb
begin : state_actions
    /* Default output assignments */
    pmem_read = 1'b0;
    pmem_write = 1'b0;

    mem_resp = 1'b0;

    load_data_0 = 1'b0;
    load_tag_0 = 1'b0;
    load_valid_0 = 1'b0;
    load_dirty_0 = 1'b0;

    load_data_1 = 1'b0;
    load_tag_1 = 1'b0;
    load_valid_1 = 1'b0;
    load_dirty_1 = 1'b0;

    load_data_2 = 1'b0;
    load_tag_2 = 1'b0;
    load_valid_2 = 1'b0;
    load_dirty_2 = 1'b0;

    load_data_3 = 1'b0;
    load_tag_3 = 1'b0;
    load_valid_3 = 1'b0;
    load_dirty_3 = 1'b0;

    load_lru = 1'b0;
    way_sel = 2'b00;
    valid_in = 1'b0;
    dirty_in = 1'b0;
    lru_in = 3'b000;

    pmem_sel = 3'b000;
    data_sel = 1'b0;
    load_pmem_wdata = 1'b0;

    case(state)
        // idle: // waiting for responses
        /*******************************/
        /* LRU Bits:  L2    L1     L0  */
        /* WAY:      C/D   A/B   AB/CD */
        /*******************************/

        /**************************/
        /* WAY Notation: A B C D  */
        /* WAY Number:   0 1 2 3  */
        /**************************/
        read_write: begin
            if (mem_read == 1)
                //read
                if (hit_0 == 1) begin   // If Way A hits
                    way_sel = 2'b00;
                    mem_resp = 1;
                    lru_in = {lru_out[2],2'b00};
                    load_lru = 1;
                end

                else if (hit_1 == 1) begin  // If Way B hits
                    way_sel = 2'b01;
                    mem_resp = 1;
                    lru_in = {lru_out[2],2'b10};
                    load_lru = 1;
                end

                else if (hit_2 == 1) begin  // If Way C hits
                    way_sel = 2'b10;
                    mem_resp = 1;
                    lru_in = {1'b0, lru_out[1], 1'b1};
                    load_lru = 1;
                end

                else if (hit_3 == 1) begin  // If Way D hits
                    way_sel = 2'b11;
                    mem_resp = 1;
                    lru_in = {1'b1, lru_out[1], 1'b1};
                    load_lru = 1;
                end

                else begin      // If we missed
                    way_sel = 2'b00;
                    mem_resp = 0;
                    lru_in = 3'b000;
                    load_lru = 0;
                end

            /* If we need to write data */
            else if (mem_write == 1) begin
                if (hit_0 == 1) begin   // If Way A hits
                    way_sel = 2'b00;
                    mem_resp = 1;
                    lru_in = {lru_out[2],2'b00};
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_0 = 1;
                    data_sel = 1;   // load data
                    load_data_0 = 1;
                end

                else if (hit_1 == 1) begin  // If Way B hits
                    way_sel = 2'b01;
                    mem_resp = 1;
                    lru_in = {lru_out[2],2'b10};
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_1 = 1;
                    data_sel = 1;   // load data
                    load_data_1 = 1;
                end

                else if (hit_2 == 1) begin  // If Way C hits
                    way_sel = 2'b10;
                    mem_resp = 1;
                    lru_in = {1'b0, lru_out[1], 1'b1};
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_2 = 1;
                    data_sel = 1;   // load data
                    load_data_2 = 1;
                end

                else if (hit_3 == 1) begin  // If Way D hits
                    way_sel = 2'b11;
                    mem_resp = 1;
                    lru_in = {1'b1, lru_out[1], 1'b1};
                    load_lru = 1;
                    dirty_in = 1;   // set dirty bit
                    load_dirty_3 = 1;
                    data_sel = 1;   // load data
                    load_data_3 = 1;
                end

                else begin     // Not read nor write
                end
            end
        end

        access_pmem: begin
            pmem_read = 1;
            valid_in = 1;

            if (lru_out[1] == 1'b1 && lru_out[0] == 1'b1) begin     // Accessing Cache Way A
                way_sel = 2'b00;
                load_data_0 = 1;
                load_tag_0 = 1;
                load_valid_0 = 1;
            end

            else if (lru_out[1] == 1'b0 && lru_out[0] == 1'b1) begin     // Accessing Cache Way B
                way_sel = 2'b01;
                load_data_1 = 1;
                load_tag_1 = 1;
                load_valid_1 = 1;
            end

            else if (lru_out[2] == 1'b1 && lru_out[0] == 1'b0) begin     // Accessing Cache Way C
                way_sel = 2'b10;
                load_data_2 = 1;
                load_tag_2 = 1;
                load_valid_2 = 1;
            end

            else if (lru_out[2] == 1'b0 && lru_out[0] == 1'b0) begin     // Accessing Cache Way D
                way_sel = 2'b11;
                load_data_3 = 1;
                load_tag_3 = 1;
                load_valid_3 = 1;
            end

            else begin
            /* Do Nothing */
            end
        end

        write_back: begin
            load_pmem_wdata = 1'b1;
            if (lru_out[1] == 1'b1 && lru_out[0] == 1'b1) begin
                way_sel = 2'b00;
                pmem_sel = 3'b001;
                pmem_write = 1;
                dirty_in = 0;
                load_dirty_0 = 1;
            end

            else if (lru_out[1] == 1'b0 && lru_out[0] == 1'b1) begin
                way_sel = 2'b01;
                pmem_sel = 3'b010;
                pmem_write = 1;
                dirty_in = 0;
                load_dirty_1 = 1;
            end

            else if (lru_out[2] == 1'b1 && lru_out[0] == 1'b0) begin
                way_sel = 2'b10;
                pmem_sel = 3'b011;
                pmem_write = 1;
                dirty_in = 0;
                load_dirty_2 = 1;
            end

            else if (lru_out[2] == 1'b0 && lru_out[0] == 1'b0) begin
                way_sel = 2'b11;
                pmem_sel = 3'b100;
                pmem_write = 1;
                dirty_in = 0;
                load_dirty_3 = 1;
            end
            else begin  // Should not be here
            end
        end

        /* Default state, in case accessing by mistake */
        default: ;
    endcase
end

always_comb
begin : next_state_logic
     next_state = state;

     case (state)
        read_write: begin
            if (mem_read || mem_write) begin
                if (is_hit == 1) begin// If there is a hit in Cache Way, looping
                    next_state = read_write;
                end

                // else if (valid_out_0 == 1 && valid_out_1 == 1 && valid_out_2 == 1 && valid_out_3 == 1) begin /* If all ways are valid */
                else if (all_valid == 1) begin
                    if ((dirty_out_0 == 1) && (lru_out[1] == 1'b1) && (lru_out[0] == 1'b1)) begin // Need use Cache Way A and it is dirty
                        next_state = write_back;
                    end

                    else if ((dirty_out_1 == 1) && (lru_out[1] == 1'b0) && (lru_out[0] == 1'b1)) begin    // Need to write back Way B
                        next_state = write_back;
                    end

                    else if ((dirty_out_2 == 1) && (lru_out[2] == 1'b1) && (lru_out[0] == 1'b0)) begin    // Need to write back Way C
                        next_state = write_back;
                    end

                    else if ((dirty_out_3 == 1) && (lru_out[2] == 1'b0) && (lru_out[0] == 1'b0)) begin    // Need to write back Way D
                        next_state = write_back;
                    end

                    else begin
                        next_state = access_pmem;	// Stay conflicted for now
                    end
                end

                else begin
                    next_state = access_pmem;
                end
            end
        end

        access_pmem: begin
            if (pmem_resp == 0) // If the memory is not ready, loop
                next_state = access_pmem;
            else
                next_state = read_write;
        end

        write_back: begin
            if (pmem_resp == 0) // If the memory is not ready, loop
                next_state = write_back;
            else
                next_state = access_pmem;
        end

        default: next_state = read_write;
     endcase
end

always_ff @(posedge clk)
begin: next_state_assignment
    /* Assignment of next state on clock edge */
    state <= next_state;
end

endmodule : l2_cache_control
