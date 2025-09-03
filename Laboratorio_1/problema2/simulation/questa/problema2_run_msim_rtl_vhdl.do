transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema2/restador_1bit.vhd}
vcom -93 -work work {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema2/restador_4bit.vhd}
vcom -93 -work work {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema2/top_restador.vhd}
vcom -93 -work work {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema2/deco_7seg.vhd}

vcom -93 -work work {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema2/restador_4bit_TB.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclonev -L cyclonev_hssi -L rtl_work -L work -voptargs="+acc"  restador_4bit_TB

add wave *
view structure
view signals
run -all
