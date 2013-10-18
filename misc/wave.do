onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_data
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_ctrl
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_wr
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_rdy
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_data_0
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_ctrl_0
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_wr_0
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_rdy_0
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_data_2
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_ctrl_2
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_wr_2
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/in_rdy_2
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/reset
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/clk
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_ctrl
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_data
add wave -noupdate -format Literal -radix hexadecimal -expand /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/rd_en
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/cur_queue_plus1
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/cur_queue
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/cur_queue_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/state
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/state_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_ctrl_prev
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_ctrl_prev_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_ctrl_sel
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/fifo_out_data_sel
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_data_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_ctrl_next
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/out_wr_next
add wave -noupdate -format Logic -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/eop
add wave -noupdate -format Literal -radix binary /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/cur_weight
add wave -noupdate -format Literal -radix binary /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/cur_weight_next
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/queue_weight
add wave -noupdate -format Literal -radix hexadecimal /testbench/u_board/nf2_top/nf2_core/user_data_path/input_arbiter/queue_weight_sel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5343137 ps} 0}
configure wave -namecolwidth 185
configure wave -valuecolwidth 125
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {28409850 ps}
