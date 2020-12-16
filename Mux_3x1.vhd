library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MUX_3X1 is	---DONE

port(

		i_A	: in std_logic_vector ( 15 downto 0 );	---ALU
		i_B	: in std_logic_vector ( 15 downto 0 );	---DATA BANK
		i_C	: in std_logic_vector ( 15 downto 0 );	---IMEDIATE
		
		i_SEL	: in std_logic_vector ( 1 downto 0 );	--- 0000 load ALU , 0001 load DATA BANK , 0010 load CONSTANT
		
		o_OUT	: out std_logic_vector ( 15 downto 0 )

);

end MUX_3X1;



architecture ARCH_1 of MUX_3X1 is

begin

	process ( i_SEL , i_A , i_B , i_C ) begin
	
	case i_SEL is
	
	when "00" => o_OUT <= i_A ;
	when "01" => o_OUT <= i_B ;
	when "10" => o_OUT <= i_C ;
	when others => o_OUT <= "UUUUUUUUUUUUUUUU" ;
	
	end case;
	
	end process;

end ARCH_1;