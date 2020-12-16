library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NEW_REGISTER_FILE is	---DONE

port(

		i_RF_CLK					: in std_logic										;
		
		i_RF_REGFLAG_WEN		: in std_logic										;	---REGISTER FLAG WRITE ENABLE
		i_RF_REGFLAG_REN		: in std_logic										;	---REGISTER FLAG READ ENABLE
		i_RF_EQUAL_FLAG		: in std_logic										;
		i_RF_LESSTHAN_FLAG	: in std_logic										;
		o_RF_REGFLAG_OUT		: out std_logic_vector( 1 downto 0 )		;	---REGISTER FLAG OUT
		
		i_RF_WDATA				: in std_logic_vector (15 downto 0)			;	---WRITE DATA IN
		i_RF_WADDRESS			: in std_logic_vector (3 downto 0)			;	---WRITE ADDRESS
		i_RF_WEN					: in std_logic										;	---WRITE ANABLE

		o_RF_RpDATA				: out std_logic_vector(15 downto 0)			;	---READ DATA P
		i_RF_RpADRESS			: in std_logic_vector(3 downto 0)			;	---READ ADDRESS
		i_RF_RpEN				: in std_logic										;
		
		o_RF_RqDATA				: out std_logic_vector(15 downto 0)			;	---READ DATA Q
		i_RF_RqADRESS			: in std_logic_vector(3 downto 0)			;	---READ ADDRESS
		i_RF_RqEN				: in std_logic			

);

end NEW_REGISTER_FILE;

architecture ARCH_1 of NEW_REGISTER_FILE is

	type t_REG is array ( 0 to 16 ) of std_logic_vector( 15 downto 0 );
	signal REG	:	t_REG;
	
	signal r_FLAGS	:	std_logic_vector( 1 downto 0 );

begin
	
	process ( i_RF_CLK , i_RF_WEN , i_RF_WADDRESS , i_RF_RpEN , i_RF_RpADRESS , i_RF_RqADRESS , i_RF_RqEN , i_RF_WDATA ) begin
	
		if rising_edge( i_RF_CLK ) then
		
			---WRITE INTO
			
			if i_RF_WEN = '1' then
			
				REG( to_integer( unsigned( i_RF_WADDRESS ) ) ) <= i_RF_WDATA;	---WRITE DATA IN
			
			end if;	--i_RF_WEN
			
			if i_RF_REGFLAG_WEN = '1' then
			
				r_FLAGS(1)	<= i_RF_EQUAL_FLAG;
				r_FLAGS(0)	<= i_RF_LESSTHAN_FLAG;
			
			end if;	--i_RF_REGFLAG_WEN
			
			if i_RF_REGFLAG_REN = '1' then
		
				o_RF_REGFLAG_OUT	<= r_FLAGS;
		
			end if;
			
			---WRITE
		
		end if;	---CLK
		
		---READ ONTO
		
		--if i_RF_REGFLAG_REN = '1' then
		
		--	o_RF_REGFLAG_OUT	<= r_FLAGS;
		
		--end if;
		
		if i_RF_RpEN = '1' and i_RF_RqEN = '0' then
		
		o_RF_RpDATA <= REG( to_integer( unsigned( i_RF_RpADRESS ) ) );
		o_RF_RqDATA <= "UUUUUUUUUUUUUUUU";
		
		elsif i_RF_RqEN = '1' and i_RF_RpEN = '0' then
		
		o_RF_RqDATA <= REG( to_integer( unsigned( i_RF_RqADRESS ) ) );
		o_RF_RpDATA <= "UUUUUUUUUUUUUUUU";
		
		elsif i_RF_RpEN = '1' and i_RF_RqEN = '1' then
		
		o_RF_RpDATA <= REG( to_integer( unsigned( i_RF_RpADRESS ) ) );
		o_RF_RqDATA <= REG( to_integer( unsigned( i_RF_RqADRESS ) ) );
		
		else
		
		o_RF_RqDATA <= "UUUUUUUUUUUUUUUU";
		o_RF_RpDATA <= "UUUUUUUUUUUUUUUU";
		
		end if;
		
		---READ
	
	
	end process;
	
end ARCH_1;