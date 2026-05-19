// rectgen.sv

// if you don't want borders, just use inrect as your signal for "draw pixel" and ignore the onborder output
module rectgen (
    input logic [9:0] x, y,
    left, top, right, bot,
    output logic inrect, onborder
);

    // check if x and y are inside the rectangle
    always_comb inrect = (x >= left && x < right && y >= top && y < bot);

    // check if x and y are on the border
    always_comb onborder = inrect && ((x == left) || (x == right - 1) || (y == top) || (y == bot - 1));

endmodule
