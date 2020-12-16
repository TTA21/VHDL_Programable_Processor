library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity INSTRUCTION_REGISTER is	---DONE

port(

	i_IR_CLK		:	in std_logic;
	i_IR_DATA	:	in std_logic_vector( 15 downto 0 );
	i_IR_LOAD	:	in std_logic;
	
	o_IR_OUTPUT	:	out std_logic_vector( 15 downto 0 )

);

end INSTRUCTION_REGISTER;

architecture ARCH_1 of INSTRUCTION_REGISTER is

signal r_INS_REGIST	:	std_logic_vector( 15 downto 0 );

begin

	process ( i_IR_CLK , i_IR_LOAD , r_INS_REGIST , i_IR_DATA ) begin
	
	if rising_edge(i_IR_CLK) then
	
		if i_IR_LOAD = '1' then
		
		r_INS_REGIST <= i_IR_DATA;
		
		end if; ---i_IR_LOAD
	
	end if;	---i_IR_CLK
	
	end process;
	
	o_IR_OUTPUT <= r_INS_REGIST;

end ARCH_1;