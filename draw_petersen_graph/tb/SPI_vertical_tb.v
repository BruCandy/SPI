module SPI_vertical_tb();
    reg i_clk = 1'b1;
    reg i_rst = 0;
    reg i_start = 0;
    wire o_mosi;
    wire o_dc;
    wire o_cs;
    wire o_done;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, SPI_vertical_tb);
    end

    SPI_vertical # (
        .DELAY  (20),
        .X      (5 ),
        .Y1     (5 ),
        .Y2     (10)
    ) spi_vertical(
        .i_rst      (i_rst),
        .i_clk      (i_clk),
        .i_start    (i_start),
        .o_mosi     (o_mosi),
        .o_dc       (o_dc),
        .o_cs       (o_cs),
        .o_done     (o_done)
    );

    always #10 begin
        i_clk <= ~i_clk;
    end

    initial begin
        i_rst <= 1'b1; #10;
        i_rst <= 1'b0; #30;

        i_start <= 1; #10;
        i_start <= 0; #10;
        
        // wait (o_done == 1'b1);   

        #100000;

        // i_rst <= 1'b1; #10;
        // i_rst <= 1'b0; #30;

        // i_start <= 1; #10;
        // i_start <= 0; #10;
        
        // wait (o_done == 1'b1);  

        // #1000;


        $finish;
    end
endmodule