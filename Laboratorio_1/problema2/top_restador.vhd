library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  

entity top_restador is
    Port ( SW   : in  STD_LOGIC_VECTOR(7 downto 0);
           HEX0 : out STD_LOGIC_VECTOR(6 downto 0);
           Neg : out STD_LOGIC 
         );
end top_restador;

architecture Behavioral of top_restador is
    component restador_4bit
        Port ( A    : in  STD_LOGIC_VECTOR(3 downto 0);
               B    : in  STD_LOGIC_VECTOR(3 downto 0);
               Bin  : in  STD_LOGIC;
               D    : out STD_LOGIC_VECTOR(3 downto 0);
               Bout : out STD_LOGIC);
    end component;
	 
	 component deco_7seg
        Port ( x   : in  STD_LOGIC_VECTOR(3 downto 0);
               seg : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    signal A, B       : STD_LOGIC_VECTOR(3 downto 0);
    signal D_rest     : STD_LOGIC_VECTOR(3 downto 0); 
    signal D_rest_abs : STD_LOGIC_VECTOR(3 downto 0); 
    signal Bin        : STD_LOGIC := '0';
	 signal Bout       : STD_LOGIC;

begin
    -- entradas
    A <= SW(7 downto 4);
    B <= SW(3 downto 0);

    -- instancia restador
    rest: restador_4bit port map (A => A, 
											 B => B, 
											 Bin => Bin, 
											 D => D_rest, 
											 Bout => Bout);
		
	 
    -- Ajuste: para obtener valor absoluto
    process(D_rest, Bout)
	 begin
		if Bout = '1' then
        D_rest_abs <= std_logic_vector(unsigned(not D_rest) + 1);
		  Neg <= Bout;
		else
        D_rest_abs <= D_rest;
		  Neg <= Bout;
		end if;
	 end process;

    deco: deco_7seg port map(D_rest_abs, HEX0);

end Behavioral;


