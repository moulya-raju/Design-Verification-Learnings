module edge_detection(
	input logic clk,rst, d,
	output logic pos_edge, neg_edge
);

logic q;

always_ff@(posedge clk)
begin
	if(rst)
	  q <= 0;
	else
	  q <= d;
end

assign pos_edge = ~q & d;
assign neg_edge = ~d & q;

endmodule
