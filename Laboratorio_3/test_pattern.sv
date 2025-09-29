// test_pattern.sv – barras de color para verificar HS/VS y RGB
module test_pattern(
  input  logic        video_on,
  input  logic [9:0]  x, y,
  output logic [7:0]  R, G, B
);
  always_comb begin
    if (!video_on) begin
      R = 8'h00; G = 8'h00; B = 8'h00;
    end else begin
      case (x[9:7])                   // 8 barras verticales
        3'b000: begin R=8'hFF; G=8'h00; B=8'h00; end // rojo
        3'b001: begin R=8'h00; G=8'hFF; B=8'h00; end // verde
        3'b010: begin R=8'h00; G=8'h00; B=8'hFF; end // azul
        3'b011: begin R=8'hFF; G=8'hFF; B=8'h00; end // amarillo
        3'b100: begin R=8'hFF; G=8'h00; B=8'hFF; end // magenta
        3'b101: begin R=8'h00; G=8'hFF; B=8'hFF; end // cian
        3'b110: begin R=8'hFF; G=8'hFF; B=8'hFF; end // blanco
        default:begin R=8'h20; G=8'h20; B=8'h20; end // gris
      endcase
    end
  end
endmodule
