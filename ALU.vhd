library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is	---DONE

port(

		i_A		: in std_logic_vector( 15 downto 0 )	;
		i_B		: in std_logic_vector( 15 downto 0 )	;
		i_CIN		: in integer range 0 to 1					;		---Carry in for the shift and for the adder
		
		i_SEL		: in std_logic_vector( 3 downto 0 )		;
		
		o_OUT		: out std_logic_vector( 15 downto 0 )	;
		o_EQ		: out std_logic								;		---CMP two vectors , EQUAL FLAG
		o_LTA		: out std_logic										---CMP two vectors , If B less than A , o_LTA = 1
		
		

);

end ALU;



architecture ARCH_1 of ALU is

begin

	process (i_SEL , i_A , i_B ) begin
	
	
		case i_SEL is
		
			when "0000" => o_OUT <= i_A ;	--- NO OP
			
			when "0001" => o_OUT <= std_logic_vector( unsigned( i_A ) + unsigned( i_B ) + i_CIN );	---UNSIGNED ADD
			
			when "0010" => o_OUT <= std_logic_vector( unsigned( i_A ) + unsigned( unsigned(not i_B) + 1 ) + i_CIN ); ---UNSIGNED SUB WITH 2 COM
			
			when "0101" => o_OUT <= i_A and i_B;	--AND
			
			when "0110" => o_OUT <= i_A or i_B;	--OR
			
			when "0111" => o_OUT <= i_A xor i_B;	--XOR
			
			when "1000" => o_OUT <= not i_A;	--NOT A
			
			when others => o_OUT <= i_A ;	--- NO OP 
		
		end case;	--I_SEL
		
		if( i_A = i_B ) then
		
			o_EQ 	<= '1';
			o_LTA <= '0';
								
		else
							
			o_EQ <= '0';
								
			if ( unsigned(i_A) < unsigned(i_B) ) then
								
				o_LTA <= '1';
								
			else 
								
				o_LTA <= '0';
								
			end if;	--A<B
								
		end if;	---A=B
		
		
	
	end process;
	

end ARCH_1;