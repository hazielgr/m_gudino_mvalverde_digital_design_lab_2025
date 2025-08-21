-- Copyright (C) 2023  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- VENDOR "Altera"
-- PROGRAM "Quartus Prime"
-- VERSION "Version 23.1std.0 Build 991 11/28/2023 SC Lite Edition"

-- DATE "08/21/2025 10:44:31"

-- 
-- Device: Altera 5CSXFC6D6F31C6 Package FBGA896
-- 

-- 
-- This VHDL file should be used for QuestaSim (VHDL) only
-- 

LIBRARY ALTERA_LNSIM;
LIBRARY CYCLONEV;
LIBRARY IEEE;
USE ALTERA_LNSIM.ALTERA_LNSIM_COMPONENTS.ALL;
USE CYCLONEV.CYCLONEV_COMPONENTS.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY 	top_restador IS
    PORT (
	SW : IN std_logic_vector(7 DOWNTO 0);
	HEX0 : BUFFER std_logic_vector(6 DOWNTO 0);
	Neg : BUFFER std_logic
	);
END top_restador;

-- Design Ports Information
-- HEX0[0]	=>  Location: PIN_W17,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[1]	=>  Location: PIN_V18,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[2]	=>  Location: PIN_AG17,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[3]	=>  Location: PIN_AG16,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[4]	=>  Location: PIN_AH17,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[5]	=>  Location: PIN_AG18,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- HEX0[6]	=>  Location: PIN_AH18,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- Neg	=>  Location: PIN_AA24,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[3]	=>  Location: PIN_AC30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[7]	=>  Location: PIN_AD30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[2]	=>  Location: PIN_AB28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[6]	=>  Location: PIN_AC28,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[1]	=>  Location: PIN_Y27,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[5]	=>  Location: PIN_V25,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[0]	=>  Location: PIN_AB30,	 I/O Standard: 2.5 V,	 Current Strength: Default
-- SW[4]	=>  Location: PIN_W25,	 I/O Standard: 2.5 V,	 Current Strength: Default


ARCHITECTURE structure OF top_restador IS
SIGNAL gnd : std_logic := '0';
SIGNAL vcc : std_logic := '1';
SIGNAL unknown : std_logic := 'X';
SIGNAL devoe : std_logic := '1';
SIGNAL devclrn : std_logic := '1';
SIGNAL devpor : std_logic := '1';
SIGNAL ww_devoe : std_logic;
SIGNAL ww_devclrn : std_logic;
SIGNAL ww_devpor : std_logic;
SIGNAL ww_SW : std_logic_vector(7 DOWNTO 0);
SIGNAL ww_HEX0 : std_logic_vector(6 DOWNTO 0);
SIGNAL ww_Neg : std_logic;
SIGNAL \~QUARTUS_CREATED_GND~I_combout\ : std_logic;
SIGNAL \SW[4]~input_o\ : std_logic;
SIGNAL \SW[5]~input_o\ : std_logic;
SIGNAL \SW[0]~input_o\ : std_logic;
SIGNAL \SW[1]~input_o\ : std_logic;
SIGNAL \Add0~1_combout\ : std_logic;
SIGNAL \Add0~0_combout\ : std_logic;
SIGNAL \SW[2]~input_o\ : std_logic;
SIGNAL \SW[6]~input_o\ : std_logic;
SIGNAL \Add0~3_combout\ : std_logic;
SIGNAL \rest|rest2|Bout~combout\ : std_logic;
SIGNAL \SW[7]~input_o\ : std_logic;
SIGNAL \SW[3]~input_o\ : std_logic;
SIGNAL \Add0~4_combout\ : std_logic;
SIGNAL \Add0~2_combout\ : std_logic;
SIGNAL \Add0~5_combout\ : std_logic;
SIGNAL \deco|Mux6~0_combout\ : std_logic;
SIGNAL \deco|Mux5~0_combout\ : std_logic;
SIGNAL \deco|Mux4~0_combout\ : std_logic;
SIGNAL \deco|Mux3~0_combout\ : std_logic;
SIGNAL \deco|Mux2~0_combout\ : std_logic;
SIGNAL \deco|Mux1~0_combout\ : std_logic;
SIGNAL \deco|Mux0~0_combout\ : std_logic;
SIGNAL \rest|rest3|Bout~combout\ : std_logic;
SIGNAL \deco|ALT_INV_Mux0~0_combout\ : std_logic;
SIGNAL \ALT_INV_Add0~4_combout\ : std_logic;
SIGNAL \ALT_INV_SW[2]~input_o\ : std_logic;
SIGNAL \ALT_INV_SW[1]~input_o\ : std_logic;
SIGNAL \rest|rest2|ALT_INV_Bout~combout\ : std_logic;
SIGNAL \ALT_INV_SW[0]~input_o\ : std_logic;
SIGNAL \ALT_INV_SW[4]~input_o\ : std_logic;
SIGNAL \ALT_INV_SW[6]~input_o\ : std_logic;
SIGNAL \ALT_INV_SW[7]~input_o\ : std_logic;
SIGNAL \ALT_INV_Add0~0_combout\ : std_logic;
SIGNAL \ALT_INV_Add0~5_combout\ : std_logic;
SIGNAL \ALT_INV_SW[3]~input_o\ : std_logic;
SIGNAL \ALT_INV_Add0~1_combout\ : std_logic;
SIGNAL \ALT_INV_SW[5]~input_o\ : std_logic;
SIGNAL \ALT_INV_Add0~2_combout\ : std_logic;
SIGNAL \ALT_INV_Add0~3_combout\ : std_logic;

BEGIN

ww_SW <= SW;
HEX0 <= ww_HEX0;
Neg <= ww_Neg;
ww_devoe <= devoe;
ww_devclrn <= devclrn;
ww_devpor <= devpor;
\deco|ALT_INV_Mux0~0_combout\ <= NOT \deco|Mux0~0_combout\;
\ALT_INV_Add0~4_combout\ <= NOT \Add0~4_combout\;
\ALT_INV_SW[2]~input_o\ <= NOT \SW[2]~input_o\;
\ALT_INV_SW[1]~input_o\ <= NOT \SW[1]~input_o\;
\rest|rest2|ALT_INV_Bout~combout\ <= NOT \rest|rest2|Bout~combout\;
\ALT_INV_SW[0]~input_o\ <= NOT \SW[0]~input_o\;
\ALT_INV_SW[4]~input_o\ <= NOT \SW[4]~input_o\;
\ALT_INV_SW[6]~input_o\ <= NOT \SW[6]~input_o\;
\ALT_INV_SW[7]~input_o\ <= NOT \SW[7]~input_o\;
\ALT_INV_Add0~0_combout\ <= NOT \Add0~0_combout\;
\ALT_INV_Add0~5_combout\ <= NOT \Add0~5_combout\;
\ALT_INV_SW[3]~input_o\ <= NOT \SW[3]~input_o\;
\ALT_INV_Add0~1_combout\ <= NOT \Add0~1_combout\;
\ALT_INV_SW[5]~input_o\ <= NOT \SW[5]~input_o\;
\ALT_INV_Add0~2_combout\ <= NOT \Add0~2_combout\;
\ALT_INV_Add0~3_combout\ <= NOT \Add0~3_combout\;

-- Location: IOOBUF_X60_Y0_N19
\HEX0[0]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux6~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(0));

-- Location: IOOBUF_X80_Y0_N2
\HEX0[1]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux5~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(1));

-- Location: IOOBUF_X50_Y0_N93
\HEX0[2]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux4~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(2));

-- Location: IOOBUF_X50_Y0_N76
\HEX0[3]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux3~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(3));

-- Location: IOOBUF_X56_Y0_N36
\HEX0[4]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux2~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(4));

-- Location: IOOBUF_X58_Y0_N76
\HEX0[5]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|Mux1~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(5));

-- Location: IOOBUF_X56_Y0_N53
\HEX0[6]~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \deco|ALT_INV_Mux0~0_combout\,
	devoe => ww_devoe,
	o => ww_HEX0(6));

-- Location: IOOBUF_X89_Y11_N45
\Neg~output\ : cyclonev_io_obuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	open_drain_output => "false",
	shift_series_termination_control => "false")
-- pragma translate_on
PORT MAP (
	i => \rest|rest3|Bout~combout\,
	devoe => ww_devoe,
	o => ww_Neg);

-- Location: IOIBUF_X89_Y20_N44
\SW[4]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(4),
	o => \SW[4]~input_o\);

-- Location: IOIBUF_X89_Y20_N61
\SW[5]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(5),
	o => \SW[5]~input_o\);

-- Location: IOIBUF_X89_Y21_N4
\SW[0]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(0),
	o => \SW[0]~input_o\);

-- Location: IOIBUF_X89_Y25_N21
\SW[1]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(1),
	o => \SW[1]~input_o\);

-- Location: LABCELL_X85_Y21_N42
\Add0~1\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~1_combout\ = ( \SW[0]~input_o\ & ( \SW[1]~input_o\ & ( !\SW[4]~input_o\ $ (!\SW[5]~input_o\) ) ) ) # ( !\SW[0]~input_o\ & ( \SW[1]~input_o\ & ( !\SW[5]~input_o\ ) ) ) # ( \SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( !\SW[4]~input_o\ $ (\SW[5]~input_o\) 
-- ) ) ) # ( !\SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( \SW[5]~input_o\ ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000011111111110011000011001111111111000000000011001111001100",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	datab => \ALT_INV_SW[4]~input_o\,
	datad => \ALT_INV_SW[5]~input_o\,
	datae => \ALT_INV_SW[0]~input_o\,
	dataf => \ALT_INV_SW[1]~input_o\,
	combout => \Add0~1_combout\);

-- Location: LABCELL_X85_Y21_N39
\Add0~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~0_combout\ = ( \SW[0]~input_o\ & ( !\SW[4]~input_o\ ) ) # ( !\SW[0]~input_o\ & ( \SW[4]~input_o\ ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000111100001111111100001111000000001111000011111111000011110000",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	datac => \ALT_INV_SW[4]~input_o\,
	datae => \ALT_INV_SW[0]~input_o\,
	combout => \Add0~0_combout\);

-- Location: IOIBUF_X89_Y21_N38
\SW[2]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(2),
	o => \SW[2]~input_o\);

-- Location: IOIBUF_X89_Y20_N78
\SW[6]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(6),
	o => \SW[6]~input_o\);

-- Location: LABCELL_X85_Y21_N24
\Add0~3\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~3_combout\ = ( \SW[0]~input_o\ & ( \SW[1]~input_o\ & ( !\SW[2]~input_o\ $ (!\SW[6]~input_o\ $ (((!\SW[4]~input_o\) # (!\SW[5]~input_o\)))) ) ) ) # ( !\SW[0]~input_o\ & ( \SW[1]~input_o\ & ( !\SW[2]~input_o\ $ (!\SW[6]~input_o\ $ (!\SW[5]~input_o\)) 
-- ) ) ) # ( \SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( !\SW[2]~input_o\ $ (!\SW[6]~input_o\ $ (((!\SW[4]~input_o\ & !\SW[5]~input_o\)))) ) ) ) # ( !\SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( !\SW[2]~input_o\ $ (!\SW[6]~input_o\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101101001011010100101100101101010100101010110101010010110010110",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_SW[2]~input_o\,
	datab => \ALT_INV_SW[4]~input_o\,
	datac => \ALT_INV_SW[6]~input_o\,
	datad => \ALT_INV_SW[5]~input_o\,
	datae => \ALT_INV_SW[0]~input_o\,
	dataf => \ALT_INV_SW[1]~input_o\,
	combout => \Add0~3_combout\);

-- Location: LABCELL_X85_Y21_N30
\rest|rest2|Bout\ : cyclonev_lcell_comb
-- Equation(s):
-- \rest|rest2|Bout~combout\ = ( \SW[0]~input_o\ & ( \SW[1]~input_o\ & ( (!\SW[2]~input_o\ & (!\SW[6]~input_o\ & ((!\SW[4]~input_o\) # (!\SW[5]~input_o\)))) # (\SW[2]~input_o\ & ((!\SW[4]~input_o\) # ((!\SW[6]~input_o\) # (!\SW[5]~input_o\)))) ) ) ) # ( 
-- !\SW[0]~input_o\ & ( \SW[1]~input_o\ & ( (!\SW[2]~input_o\ & (!\SW[6]~input_o\ & !\SW[5]~input_o\)) # (\SW[2]~input_o\ & ((!\SW[6]~input_o\) # (!\SW[5]~input_o\))) ) ) ) # ( \SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( (!\SW[2]~input_o\ & (!\SW[4]~input_o\ & 
-- (!\SW[6]~input_o\ & !\SW[5]~input_o\))) # (\SW[2]~input_o\ & ((!\SW[6]~input_o\) # ((!\SW[4]~input_o\ & !\SW[5]~input_o\)))) ) ) ) # ( !\SW[0]~input_o\ & ( !\SW[1]~input_o\ & ( (\SW[2]~input_o\ & !\SW[6]~input_o\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101000001010000110101000101000011110101010100001111010111010100",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_SW[2]~input_o\,
	datab => \ALT_INV_SW[4]~input_o\,
	datac => \ALT_INV_SW[6]~input_o\,
	datad => \ALT_INV_SW[5]~input_o\,
	datae => \ALT_INV_SW[0]~input_o\,
	dataf => \ALT_INV_SW[1]~input_o\,
	combout => \rest|rest2|Bout~combout\);

-- Location: IOIBUF_X89_Y25_N38
\SW[7]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(7),
	o => \SW[7]~input_o\);

-- Location: IOIBUF_X89_Y25_N55
\SW[3]~input\ : cyclonev_io_ibuf
-- pragma translate_off
GENERIC MAP (
	bus_hold => "false",
	simulate_z_as => "z")
-- pragma translate_on
PORT MAP (
	i => ww_SW(3),
	o => \SW[3]~input_o\);

-- Location: LABCELL_X85_Y21_N0
\Add0~4\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~4_combout\ = ( \SW[7]~input_o\ & ( \SW[3]~input_o\ & ( !\Add0~3_combout\ $ (((!\rest|rest2|Bout~combout\) # ((!\Add0~1_combout\ & !\Add0~0_combout\)))) ) ) ) # ( !\SW[7]~input_o\ & ( \SW[3]~input_o\ & ( !\Add0~3_combout\ $ (((!\Add0~1_combout\ & 
-- !\Add0~0_combout\))) ) ) ) # ( \SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( \Add0~3_combout\ ) ) ) # ( !\SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( !\Add0~3_combout\ $ (((!\rest|rest2|Bout~combout\) # ((!\Add0~1_combout\ & !\Add0~0_combout\)))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000111101111000000011110000111101111000011110000000111101111000",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~1_combout\,
	datab => \ALT_INV_Add0~0_combout\,
	datac => \ALT_INV_Add0~3_combout\,
	datad => \rest|rest2|ALT_INV_Bout~combout\,
	datae => \ALT_INV_SW[7]~input_o\,
	dataf => \ALT_INV_SW[3]~input_o\,
	combout => \Add0~4_combout\);

-- Location: LABCELL_X85_Y21_N48
\Add0~2\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~2_combout\ = ( \SW[7]~input_o\ & ( \SW[3]~input_o\ & ( !\Add0~1_combout\ $ (((!\Add0~0_combout\) # (!\rest|rest2|Bout~combout\))) ) ) ) # ( !\SW[7]~input_o\ & ( \SW[3]~input_o\ & ( !\Add0~0_combout\ $ (!\Add0~1_combout\) ) ) ) # ( \SW[7]~input_o\ & 
-- ( !\SW[3]~input_o\ & ( \Add0~1_combout\ ) ) ) # ( !\SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( !\Add0~1_combout\ $ (((!\Add0~0_combout\) # (!\rest|rest2|Bout~combout\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000111100111100000011110000111100111100001111000000111100111100",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	datab => \ALT_INV_Add0~0_combout\,
	datac => \ALT_INV_Add0~1_combout\,
	datad => \rest|rest2|ALT_INV_Bout~combout\,
	datae => \ALT_INV_SW[7]~input_o\,
	dataf => \ALT_INV_SW[3]~input_o\,
	combout => \Add0~2_combout\);

-- Location: LABCELL_X85_Y21_N6
\Add0~5\ : cyclonev_lcell_comb
-- Equation(s):
-- \Add0~5_combout\ = ( \SW[7]~input_o\ & ( \SW[3]~input_o\ & ( (!\Add0~1_combout\ & (!\Add0~0_combout\ & (!\Add0~3_combout\ & \rest|rest2|Bout~combout\))) ) ) ) # ( !\SW[7]~input_o\ & ( \SW[3]~input_o\ & ( !\rest|rest2|Bout~combout\ $ ((((\Add0~3_combout\) 
-- # (\Add0~0_combout\)) # (\Add0~1_combout\))) ) ) ) # ( \SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( !\rest|rest2|Bout~combout\ ) ) ) # ( !\SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( (!\Add0~1_combout\ & (!\Add0~0_combout\ & (!\Add0~3_combout\ & 
-- \rest|rest2|Bout~combout\))) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000010000000111111110000000010000000011111110000000010000000",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~1_combout\,
	datab => \ALT_INV_Add0~0_combout\,
	datac => \ALT_INV_Add0~3_combout\,
	datad => \rest|rest2|ALT_INV_Bout~combout\,
	datae => \ALT_INV_SW[7]~input_o\,
	dataf => \ALT_INV_SW[3]~input_o\,
	combout => \Add0~5_combout\);

-- Location: LABCELL_X66_Y4_N30
\deco|Mux6~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux6~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( !\Add0~4_combout\ $ (!\Add0~2_combout\) ) ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ & ( (!\Add0~4_combout\ & !\Add0~2_combout\) ) ) ) # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( 
-- (\Add0~4_combout\ & !\Add0~2_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101000001010000000000000000000010100000101000000101101001011010",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~4_combout\,
	datac => \ALT_INV_Add0~2_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux6~0_combout\);

-- Location: LABCELL_X66_Y4_N9
\deco|Mux5~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux5~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( \Add0~2_combout\ ) ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ & ( (!\Add0~2_combout\ & \Add0~4_combout\) ) ) ) # ( \Add0~5_combout\ & ( !\Add0~0_combout\ & ( \Add0~4_combout\ ) ) ) # 
-- ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( (\Add0~2_combout\ & \Add0~4_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000001010101000000001111111100000000101010100101010101010101",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~2_combout\,
	datad => \ALT_INV_Add0~4_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux5~0_combout\);

-- Location: LABCELL_X66_Y4_N42
\deco|Mux4~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux4~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( (\Add0~4_combout\ & \Add0~2_combout\) ) ) ) # ( \Add0~5_combout\ & ( !\Add0~0_combout\ & ( \Add0~4_combout\ ) ) ) # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( (!\Add0~4_combout\ & 
-- \Add0~2_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000101000001010010101010101010100000000000000000000010100000101",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~4_combout\,
	datac => \ALT_INV_Add0~2_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux4~0_combout\);

-- Location: LABCELL_X66_Y4_N51
\deco|Mux3~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux3~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( (\Add0~2_combout\ & \Add0~4_combout\) ) ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ & ( !\Add0~2_combout\ $ (\Add0~4_combout\) ) ) ) # ( \Add0~5_combout\ & ( !\Add0~0_combout\ & ( 
-- (\Add0~2_combout\ & !\Add0~4_combout\) ) ) ) # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( (!\Add0~2_combout\ & \Add0~4_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000010101010010101010000000010101010010101010000000001010101",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~2_combout\,
	datad => \ALT_INV_Add0~4_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux3~0_combout\);

-- Location: LABCELL_X66_Y4_N24
\deco|Mux2~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux2~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( (!\Add0~4_combout\ & !\Add0~2_combout\) ) ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ ) ) # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( (\Add0~4_combout\ & !\Add0~2_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101000001010000000000000000000011111111111111111010000010100000",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~4_combout\,
	datac => \ALT_INV_Add0~2_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux2~0_combout\);

-- Location: LABCELL_X66_Y4_N3
\deco|Mux1~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux1~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ & ( (!\Add0~2_combout\ & \Add0~4_combout\) ) ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ & ( (!\Add0~4_combout\) # (\Add0~2_combout\) ) ) ) # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( 
-- (\Add0~2_combout\ & !\Add0~4_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101010100000000000000000000000011111111010101010000000010101010",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~2_combout\,
	datad => \ALT_INV_Add0~4_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux1~0_combout\);

-- Location: LABCELL_X66_Y4_N36
\deco|Mux0~0\ : cyclonev_lcell_comb
-- Equation(s):
-- \deco|Mux0~0_combout\ = ( \Add0~5_combout\ & ( \Add0~0_combout\ ) ) # ( !\Add0~5_combout\ & ( \Add0~0_combout\ & ( !\Add0~4_combout\ $ (!\Add0~2_combout\) ) ) ) # ( \Add0~5_combout\ & ( !\Add0~0_combout\ & ( (!\Add0~4_combout\) # (\Add0~2_combout\) ) ) ) 
-- # ( !\Add0~5_combout\ & ( !\Add0~0_combout\ & ( (\Add0~2_combout\) # (\Add0~4_combout\) ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0101111101011111101011111010111101011010010110101111111111111111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	dataa => \ALT_INV_Add0~4_combout\,
	datac => \ALT_INV_Add0~2_combout\,
	datae => \ALT_INV_Add0~5_combout\,
	dataf => \ALT_INV_Add0~0_combout\,
	combout => \deco|Mux0~0_combout\);

-- Location: LABCELL_X85_Y21_N15
\rest|rest3|Bout\ : cyclonev_lcell_comb
-- Equation(s):
-- \rest|rest3|Bout~combout\ = ( \SW[7]~input_o\ & ( \SW[3]~input_o\ & ( \rest|rest2|Bout~combout\ ) ) ) # ( !\SW[7]~input_o\ & ( \SW[3]~input_o\ ) ) # ( !\SW[7]~input_o\ & ( !\SW[3]~input_o\ & ( \rest|rest2|Bout~combout\ ) ) )

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000111100001111000000000000000011111111111111110000111100001111",
	shared_arith => "off")
-- pragma translate_on
PORT MAP (
	datac => \rest|rest2|ALT_INV_Bout~combout\,
	datae => \ALT_INV_SW[7]~input_o\,
	dataf => \ALT_INV_SW[3]~input_o\,
	combout => \rest|rest3|Bout~combout\);

-- Location: MLABCELL_X34_Y70_N0
\~QUARTUS_CREATED_GND~I\ : cyclonev_lcell_comb
-- Equation(s):

-- pragma translate_off
GENERIC MAP (
	extended_lut => "off",
	lut_mask => "0000000000000000000000000000000000000000000000000000000000000000",
	shared_arith => "off")
-- pragma translate_on
;
END structure;


