library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PROGRAM_COUNTER is	---DONE

port(

		i_PC_CLK 	: in std_logic;
		i_PC_CLR 	: in std_logic;
		i_PC_INC 	: in std_logic;
		
		i_PC_JUMP	: in std_logic;
		i_PC_OFFSET	: in std_logic_vector ( 7 downto 0 );
		
		o_PC_OUT 	: out std_logic_vector ( 7 downto 0 )

);

end PROGRAM_COUNTER;

architecture ARCH_1 of PROGRAM_COUNTER is

signal r_COUNTER : std_logic_vector( 7 downto 0 ) := "00000000";

	begin

	process ( i_PC_CLK , i_PC_CLR , i_PC_INC ) begin
	
	if rising_edge(i_PC_CLK) then
	
		if i_PC_JUMP = '0' then
	
			if i_PC_CLR = '1' then r_COUNTER <= "00000000"; end if;
			if i_PC_INC = '1' then r_COUNTER <= std_logic_vector( signed( r_COUNTER ) + 1 );end if;
		
		else r_COUNTER <= std_logic_vector( signed( r_COUNTER ) + signed( i_PC_OFFSET ) );
		
		end if;
		
	end if;
	
	end process;
	
	o_PC_OUT <= r_COUNTER;

end ARCH_1;