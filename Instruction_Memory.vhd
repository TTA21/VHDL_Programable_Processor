library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity INSTRUCTION_MEMORY is	---DONE

port(

	i_IM_CLK			:	in std_logic;
	
	i_IM_ADDR		:	in std_logic_vector( 7 downto 0 );	---MEMORY TAKEN DOWN TO 8 BITS, or 255 possibilities
	
	i_IM_RD			:	in std_logic;								---ENABLE FOR OUTPUT
	
	i_IM_DATA_LOAD	:	in std_logic;								---ENABLE FOR COMMAND INPUT
	
	i_IM_DATAIN		:	in std_logic_vector( 15 downto 0 );	---COMMANDS IN
	
	o_IM_DATA		:	out std_logic_vector( 15 downto 0 )

);

end INSTRUCTION_MEMORY;

architecture ARCH_1 of INSTRUCTION_MEMORY is

	type t_INS_MEM is array ( 0 to 255 ) of std_logic_vector( 15 downto 0 );
	signal INS_MEM	:	t_INS_MEM;
	
	begin
	
	process ( i_IM_CLK , i_IM_DATAIN , i_IM_ADDR , INS_MEM ) begin
	
		if rising_edge(i_IM_CLK) then
		
			if i_IM_DATA_LOAD = '1' then
			
			INS_MEM( to_integer( unsigned( i_IM_ADDR ) ) )	<=	i_IM_DATAIN;
			
			end if;	---i_IM_DATA_LOAD
			
			if i_IM_RD = '1' then
			
				o_IM_DATA	<=	INS_MEM( to_integer( unsigned( i_IM_ADDR ) ) );
				
			else
			
				o_IM_DATA	<=	"UUUUUUUUUUUUUUUU";
			
			end if;	---i_IM_RD
			
		end if;	---i_IM_CLK
		
			
	
	end process;

end ARCH_1;