module text_select_rom (
    input  logic [5:0] PixelX,
    input  logic [5:0] PixelY,
    output logic [5:0] Data
);

    logic [47:0] data = 48'b00000000000000000000000000000111110101010000000;
    logic [5:0] bitmapIdx;
    logic [125:0] bitmap;
    logic [2:0] color;

    localparam bit [125:0] BITMAPS [38] = '{


        // <--- FILE: ASSETS\TEXT\SELECT\SELECT.PNG --->

        //tile 0, VRAM 48'b000000000000000000000000000001111101010100000000
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001000000000000000000000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001010010010010010010010010010010010010010001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b001001001001001001001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000,
        126'b000000000000000000001001001001001001001001001001001001001001001001001001001001001001001001000000000000000000000000000000000000
    
    };

    always_comb
    begin
        bitmapIdx = PixelY;
        bitmap    = BITMAPS[bitmapIdx];
        color     = bitmap[3*(41-PixelX) +: 3];
        Data      = data[6*color+0 +: 6];
    end

endmodule
