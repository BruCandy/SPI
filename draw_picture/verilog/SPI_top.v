module SPI_top(
    input wire i_clk,
    input wire i_rst,
    output wire o_mosi,
    output wire o_cs,
    output wire o_dc,
    output wire o_rst,
    output wire o_clk
);

    parameter DELAY  = 2_700_000; 
    parameter WIDTH  = 240;
    parameter HEIGHT = 320;

    reg [2:0] r_state = 0;
    reg       r_init_start = 0;
    reg       r_clear_start = 0;
    reg       r_picture_start = 0;

    wire w_init_done;
    wire w_init_mosi;
    wire w_init_dc;
    wire w_init_cs;
    wire w_clear_done;
    wire w_clear_mosi;
    wire w_clear_dc;
    wire w_clear_cs;
    wire w_picture_done;
    wire w_picture_mosi;
    wire w_picture_dc;
    wire w_picture_cs;

    assign w_rst = ~i_rst;
    assign o_rst = i_rst;
    assign o_clk = i_clk;

    assign o_mosi = (r_state == 1) ? w_init_mosi :
                    (r_state == 2) ? w_clear_mosi :
                    (r_state == 3) ? w_picture_mosi : 0; 
    assign o_dc =   (r_state == 1) ? w_init_dc :
                    (r_state == 2) ? w_clear_dc :
                    (r_state == 3) ? w_picture_dc : 0; 
    assign o_cs =   (r_state == 1) ? w_init_cs :
                    (r_state == 2) ? w_clear_cs :
                    (r_state == 3) ? w_picture_cs : 1; 

    SPI_init # (
        .DELAY (DELAY)
    )spi_init(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_init_start),
        .o_mosi     (w_init_mosi),
        .o_dc       (w_init_dc),
        .o_cs       (w_init_cs),
        .o_done     (w_init_done)
    );

    SPI_clear # (
        .DELAY  (DELAY),
        .WIDTH  (WIDTH),
        .HEIGHT (HEIGHT)
    ) spi_clear(
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_clear_start),
        .o_mosi     (w_clear_mosi),
        .o_dc       (w_clear_dc),
        .o_cs       (w_clear_cs),
        .o_done     (w_clear_done)
    );

    SPI_picture # (
        .DELAY (DELAY)
    ) spi_picture (
        .i_rst      (w_rst),
        .i_clk      (i_clk),
        .i_start    (r_picture_start),
        .o_mosi     (w_picture_mosi),
        .o_dc       (w_picture_dc),
        .o_cs       (w_picture_cs),
        .o_done     (w_picture_done)
    );

    always @(posedge i_clk or posedge w_rst) begin
        if (w_rst) begin
            r_state <= 0;
            r_init_start <= 0;
            r_clear_start <= 0;
            r_picture_start <= 0;
        end else begin
            case (r_state)
                0: begin
                    r_init_start <= 1;
                    r_state <= 1;
                end
                1: begin
                    r_init_start <= 0;
                    if (w_init_done) begin
                        r_state <= 2;
                        r_clear_start <= 1;
                    end
                end
                2: begin
                    r_clear_start <= 0;
                    if (w_clear_done) begin
                        r_state <= 3;
                        r_picture_start <= 1;
                    end 
                end
                3: begin
                    r_picture_start <= 0;
                    if (w_picture_done) begin
                        r_state <= 4;
                    end 
                end
                4: begin
                    // もう一度実行する場合はリセットボタンを押す
                end
            endcase
        end
    end

endmodule