library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity restador_1bit is
    Port ( A    : in  STD_LOGIC;
           B    : in  STD_LOGIC;
           Bin  : in  STD_LOGIC;
           D    : out STD_LOGIC;
           Bout : out STD_LOGIC);
end restador_1bit;

architecture behavior of restador_1bit is
begin
    D    <= A xor B xor Bin;
    Bout <= (not A and B) or ((not (A xor B)) and Bin);
end behavior;
