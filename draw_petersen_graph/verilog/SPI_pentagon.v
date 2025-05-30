module SPI_pentagon(
    input wire i_rst,
    input wire i_clk,
    input wire i_start,
    output wire o_mosi,
    output wire o_dc,
    output wire o_cs,
    output wire o_done
);

    parameter DELAY  = 2_700_000; 

    parameter X1 = 9'd120;
    parameter Y1 = 9'd46;

    parameter X2 = 9'd225;
    parameter Y2 = 9'd122;

    parameter X3 = 9'd185;
    parameter Y3 = 9'd245;

    parameter X4 = 9'd55;
    parameter Y4 = 9'd245;

    parameter X5 = 9'd15;
    parameter Y5 = 9'd122;

    reg [2:0] r_state = 0;
    reg       r_line_start = 0;
    reg       r_line2_start = 0;
    reg       r_horizontal_start = 0;
    reg r_done = 0;
    reg [8:0] r_x1;
    reg [8:0] r_y1;
    reg [8:0] r_x2;
    reg [8:0] r_y2;
    reg [8:0] r_x1_2;
    reg [8:0] r_y1_2;
    reg [8:0] r_x2_2;
    reg [8:0] r_y2_2;

    wire w_line_done;
    wire w_line_mosi;
    wire w_line_dc;
    wire w_line_cs;
    wire w_line2_done;
    wire w_line2_mosi;
    wire w_line2_dc;
    wire w_line2_cs;
    wire w_horizontal_done;
    wire w_horizontal_mosi;
    wire w_horizontal_dc;
    wire w_horizontal_cs;


    assign o_mosi = (r_state == 3) ? w_horizontal_mosi :
                    (r_state == 1  || r_state == 5) ? w_line_mosi :
                    (r_state == 2 || r_state == 4) ? w_line2_mosi : 0; 
    assign o_dc =   (r_state == 3) ? w_horizontal_dc :
                    (r_state == 1 || r_state == 5) ? w_line_dc :
                    (r_state == 2 || r_state == 4) ? w_line2_dc : 0; 
    assign o_cs =   (r_state == 3) ? w_horizontal_cs :
                    (r_state == 1 || r_state == 5) ? w_line_cs :
                    (r_state == 2 || r_state == 4) ? w_line2_cs : 1; 
    assign o_done = r_done;

    SPI_horizontal # (
        .DELAY (DELAY)
    ) spi_horizontal (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_horizontal_start),
        .i_x1       (r_x1),
        .i_x2       (r_x2),
        .i_y        (r_y1),
        .o_mosi     (w_horizontal_mosi),
        .o_dc       (w_horizontal_dc),
        .o_cs       (w_horizontal_cs),
        .o_done     (w_horizontal_done)
    );

    SPI_line # (
        .DELAY (DELAY)
    ) spi_line (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_line_start),
        .i_x1 (r_x1),
        .i_x2 (r_x2),
        .i_y1 (r_y1),
        .i_y2 (r_y2),
        .o_mosi     (w_line_mosi),
        .o_dc       (w_line_dc),
        .o_cs       (w_line_cs),
        .o_done     (w_line_done)
    );

    SPI_line2 # (
        .DELAY (DELAY)
    ) spi_line2 (
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (r_line2_start),
        .i_x1 (r_x1_2),
        .i_x2 (r_x2_2),
        .i_y1 (r_y1_2),
        .i_y2 (r_y2_2),
        .o_mosi     (w_line2_mosi),
        .o_dc       (w_line2_dc),
        .o_cs       (w_line2_cs),
        .o_done     (w_line2_done)
    );

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            r_state <= 0;
            r_line_start <= 0;
            r_horizontal_start <= 0;
            r_done <= 0;
            r_x1 <= X1;
            r_y1 <= Y1;
            r_x2 <= X2;
            r_y2 <= Y2;
            r_x1_2 <= X1;
            r_y1_2 <= Y1;
            r_x2_2 <= X2;
            r_y2_2 <= Y2;
        end else begin
            case (r_state)
                0: begin
                    r_done <= 0;
                    if (i_start) begin
                        r_state <= 1;
                        r_line_start <= 1;
                        r_x1 <= X1;
                        r_y1 <= Y1;
                        r_x2 <= X2;
                        r_y2 <= Y2;
                    end
                end
                1: begin
                    r_line_start <= 0;
                    if (w_line_done) begin
                        r_state <= 2;
                        r_line2_start <= 1;
                        r_x1_2 <= X2;
                        r_y1_2 <= Y2;
                        r_x2_2 <= X3;
                        r_y2_2 <= Y3;
                    end 
                end
                2: begin
                    r_line2_start <= 0;
                    if (w_line2_done) begin
                        r_state <= 3;
                        r_horizontal_start <= 1;
                        r_x1 <= X4;
                        r_x2 <= X3;
                        r_y1 <= Y3;
                    end 
                end
                3: begin
                    r_horizontal_start <= 0;
                    if (w_horizontal_done) begin
                        r_state <= 4;
                        r_line2_start <= 1;
                        r_x1_2 <= X5;
                        r_y1_2 <= Y5;
                        r_x2_2 <= X4;
                        r_y2_2 <= Y4;
                    end 
                end
                4: begin
                    r_line2_start <= 0;
                    if (w_line2_done) begin
                        r_state <= 5;
                        r_line_start <= 1;
                        r_x1 <= X5;
                        r_y1 <= Y5;
                        r_x2 <= X1;
                        r_y2 <= Y1;
                    end 
                end
                5: begin
                    r_line_start <= 0;
                    if (w_line_done) begin
                        r_state <= 0;
                        r_done <= 1;
                    end 
                end
            endcase
        end
    end

endmodule