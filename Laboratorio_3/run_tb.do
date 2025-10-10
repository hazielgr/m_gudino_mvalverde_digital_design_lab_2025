vlib work
vlog -sv +acc \
  mem_board.sv \
  mem_fsm.sv \
  autopick.sv \
  scoreboard.sv \
  tb_mem_fsm.sv

# Lanza la simulación en modo GUI
vsim work.tb_mem_fsm

# Agrega señales principales a la ventana de ondas
add wave sim:/tb_mem_fsm/fsm_state
add wave sim:/tb_mem_fsm/cur_player
add wave sim:/tb_mem_fsm/reveal_pulse
add wave sim:/tb_mem_fsm/pair_mark_pulse
add wave sim:/tb_mem_fsm/gameover
add wave sim:/tb_mem_fsm/sb_score_j1
add wave sim:/tb_mem_fsm/sb_score_j2

run -all
