module memory_controller #(
    // parameters
) (
    // ports
    input  logic        bus_read_vaild,
    output logic        bus_read_ready,
    input  logic [31:0] bus_read_address,
    output logic [31:0] bus_read_data,
    output logic [31:0] memory_read_address,
    input  logic [31:0] memory_read_data,
    input  logic        clock,
    input  logic        reset
);

logic bus_read_vaild_pos_edge;
edge_detect edge_detect_inst (
    .signal ( bus_read_vaild ),
    .pos_edge ( bus_read_vaild_pos_edge ),
    .clock ( clock ),
    .reset ( reset )
);

localparam
state_transmit = 1 << 1,
state_idle = 1 << 0;

logic [1:0] state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= state_idle;
        bus_read_data <= 0;
        bus_read_ready <= 0;
        memory_read_address <= 0;
    end else begin
        case (state)
            state_idle: begin
                if (bus_read_vaild_pos_edge) begin
                    state <= state_transmit;
                    memory_read_address <= bus_read_address;
                end
            end
            state_transmit: begin
                state <= state_idle;
                bus_read_ready <= 1;
                bus_read_data <= memory_read_data;
            end
            default: begin
                state <= state_idle;
            end
        endcase
    end
end

endmodule