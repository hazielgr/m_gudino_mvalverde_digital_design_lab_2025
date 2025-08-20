library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;

entity restador_4bit_TB is 
end restador_4bit_TB; 

architecture behavior of restador_4bit_TB is 
	component restador_4bit Port (A : in STD_LOGIC_VECTOR(3 downto 0); 
	                              B : in STD_LOGIC_VECTOR(3 downto 0); 
											Bin : in STD_LOGIC; 
											D : out STD_LOGIC_VECTOR(3 downto 0); 
											Bout : out STD_LOGIC); 
	end component; 
	
	signal A, B : STD_LOGIC_VECTOR(3 downto 0); 
	signal Bin : STD_LOGIC := '0'; 
	signal D : STD_LOGIC_VECTOR(3 downto 0); 
	signal Bout : STD_LOGIC; 
	
begin UUT: restador_4bit port map(A => A, 
											 B => B, 
											 Bin => Bin, 
											 D => D, 
											 Bout => Bout);
	test: process 
	begin 
		-- Prueba 1 
		A <= "0101"; -- 5 
		B <= "0011"; -- 3 
		wait for 10 ns; 
			
		-- Prueba 2 
		A <= "1001"; -- 9 
		B <= "0100"; -- 4 
		wait for 10 ns;
		
		-- Prueba 3 
		A <= "0110"; -- 6 
		B <= "1010"; -- 10 (negativo) 
		wait for 10 ns; 
			
		-- Prueba 4 
		A <= "1111"; -- 15 
		B <= "1110"; -- 14 
		wait for 10 ns; 
			
		wait; 
	end process; 
end behavior;