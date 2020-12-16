library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NEW_DATA_BANK is	---DONE

port(

		i_CLK			: in std_logic;

		i_DATA_ADDR	: in std_logic_vector( 7 downto 0 );
		
		i_READ_EN	: in std_logic;
		i_WRITE_EN	: in std_logic;
		
		i_W_DATA		: in std_logic_vector( 15 downto 0 );
		o_R_DATA		: out std_logic_vector( 15 downto 0 )

);

end NEW_DATA_BANK;

architecture ARCH_1 of NEW_DATA_BANK is

	type t_RAM is array ( 0 to 255 ) of std_logic_vector( 15 downto 0 );
	signal RAM	:	t_RAM;

begin

	process (i_DATA_ADDR , i_CLK , i_WRITE_EN , i_READ_EN , i_W_DATA ) begin
	
		if( rising_edge(i_CLK) ) then
		
			if i_WRITE_EN = '1' then
		
			RAM( to_integer(unsigned(i_DATA_ADDR)) ) <= i_W_DATA;
			
			end if;	---WRITE ENABLE
		
		end if;	---CLK
		
		if i_READ_EN = '1' then
			
			o_R_DATA	<= RAM( to_integer(unsigned(i_DATA_ADDR)) );
			
		else o_R_DATA <= "UUUUUUUUUUUUUUUU";
			
		end if;	---READ ENABLE
	
	end process;

end ARCH_1;