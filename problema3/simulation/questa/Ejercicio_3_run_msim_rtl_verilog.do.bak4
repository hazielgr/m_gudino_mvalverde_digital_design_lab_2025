transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/btn_debouncer.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/one_pulse.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/counter.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/bin_to_dec2digits.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/seven_seg_decoder_dec.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/top_lab1_ej3.sv}

vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/problema3/counter_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  counter_tb

add wave *
view structure
view signals
run -all
