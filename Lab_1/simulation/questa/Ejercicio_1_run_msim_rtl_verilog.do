transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1/bin_to_gray.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1/bin_to_dec2digits.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1/seven_seg_decoder.sv}
vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1/top_lab1_ej1.sv}

vlog -sv -work work +incdir+C:/Users/micha/OneDrive/Documentos/TEC/IIS\ 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1 {C:/Users/micha/OneDrive/Documentos/TEC/IIS 2025/Digital_Design_Lab/m_gudino_mvalverde_digital_design_lab_2025/Lab_1/bin_to_gray_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  bin_to_gray_tb

add wave *
view structure
view signals
run -all
