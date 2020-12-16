library IEEE;
use IEEE.std_logic_1164.all;

entity tb_TOP is

end tb_TOP;

architecture ARCH_1 of tb_TOP is

component TOP is

      port	(

		i_CLK			:	in std_logic				;
		i_PROGRAMING_SIGNAL	:	in std_logic				;
		i_DATA_TO_PROGRAM	:	in std_logic_vector( 15 downto 0 )		---COMMANDS IN
		
		);
      
end component;

constant c_CLK_PERIOD			: time := 200 ps			;
signal w_CLK , w_PROGRAMING_SIGNAL	:	std_logic			;
signal w_DATA_TO_PROGRAM		:	std_logic_vector( 15 downto 0 )	;

begin

u_DUV : TOP port map	(

			i_CLK			=> w_CLK		,
			i_PROGRAMING_SIGNAL	=> w_PROGRAMING_SIGNAL	,
			i_DATA_TO_PROGRAM	=> w_DATA_TO_PROGRAM	

			);

		p_CLK: process
      
      			begin
      
      			w_CLK <= '0';
        		wait for c_CLK_PERIOD/2;  
        		w_CLK <= '1';
        		wait for c_CLK_PERIOD/2;  
        
      		end process p_CLK;

		---	REG[0] = 00000010
		---	REG[1] = 00000100
		---	CMP REG[0] , REG[1]
		---	JEQ END
		---LOOPHEAD:
		---	JLT XLTY
		---	REG[0] = REG[0] - REG[1]
		---	JNLT LOOPBOTTOM
		---XLTY:
		---	REG[1] = REG[1] - REG[0]
		---LOOPBOTTOM:
		---	CMP REG[0] , REG[1]
		---	JNEQ LOOPHEAD
		---END:
		---	DB[0] = REG[0]

		p_PROCESS : process begin

		w_PROGRAMING_SIGNAL	<= 'U' ;
		w_DATA_TO_PROGRAM	<= "UUUUUUUUUUUUUUUU" ;wait for c_CLK_PERIOD;

		w_PROGRAMING_SIGNAL	<= '1' ;
					--- ////\\\\////\\\\
		w_DATA_TO_PROGRAM	<= "0011000000000000" ;wait for c_CLK_PERIOD;	---REG[0] = 00000000
		w_DATA_TO_PROGRAM	<= "0011000000000000" ;wait for c_CLK_PERIOD;	---REG[0] = 00000000
		w_DATA_TO_PROGRAM	<= "0011000100000100" ;wait for c_CLK_PERIOD;	---REG[1] = 00000100
		w_DATA_TO_PROGRAM	<= "0011001000000001" ;wait for c_CLK_PERIOD;	---REG[2] = 00000001
		w_DATA_TO_PROGRAM	<= "0001000000000000" ;wait for c_CLK_PERIOD;	---DB[0] = REG[0]
		w_DATA_TO_PROGRAM	<= "0010000000000010" ;wait for c_CLK_PERIOD;	---ADD REG[0] , REG[0] + REG[2]	*JNE -3*
		w_DATA_TO_PROGRAM	<= "0100000000000001" ;wait for c_CLK_PERIOD;	---CMP REG[0] , REG[1]
		w_DATA_TO_PROGRAM	<= "1000000011111101" ;wait for c_CLK_PERIOD;	---JNE -3
		w_DATA_TO_PROGRAM	<= "0000000100000000" ;wait for c_CLK_PERIOD;	---REG[1] = DB[0]

					--- ////\\\\////\\\\

		--w_DATA_TO_PROGRAM	<= "0011000000011011" ;wait for c_CLK_PERIOD;	---	REG[0] = 00011011 27
		--w_DATA_TO_PROGRAM	<= "0011000000011011" ;wait for c_CLK_PERIOD;	---	REG[0] = 00011011 27
		--w_DATA_TO_PROGRAM	<= "0011000100101101" ;wait for c_CLK_PERIOD;	---	REG[1] = 00101101 45 = 9
		
		--w_DATA_TO_PROGRAM	<= "0011000000010111" ;wait for c_CLK_PERIOD;	---	REG[0] = 00001100 23
		--w_DATA_TO_PROGRAM	<= "0011000000010111" ;wait for c_CLK_PERIOD;	---	REG[0] = 00001100 23
		--w_DATA_TO_PROGRAM	<= "0011000100000100" ;wait for c_CLK_PERIOD;	---	REG[1] = 00000100 4 = 1
		--w_DATA_TO_PROGRAM	<= "0100000000000001" ;wait for c_CLK_PERIOD;	---	CMP REG[0] , REG[1]
		--w_DATA_TO_PROGRAM	<= "0101000000000110" ;wait for c_CLK_PERIOD;	---	JEQ END	*6*
											---LOOPHEAD:
		--w_DATA_TO_PROGRAM	<= "0111000000000010" ;wait for c_CLK_PERIOD;	---	JLT XLTY *2*
		--w_DATA_TO_PROGRAM	<= "0110000000000001" ;wait for c_CLK_PERIOD;	---	REG[0] = REG[0] - REG[1]
		--w_DATA_TO_PROGRAM	<= "1001000000000001" ;wait for c_CLK_PERIOD;	---	JNLT LOOPBOTTOM *1*
											---XLTY:
		--w_DATA_TO_PROGRAM	<= "0110000100010000" ;wait for c_CLK_PERIOD;	---	REG[1] = REG[1] - REG[0]
											---LOOPBOTTOM:
		--w_DATA_TO_PROGRAM	<= "0100000000000001" ;wait for c_CLK_PERIOD;	---	CMP REG[0] , REG[1]
		--w_DATA_TO_PROGRAM	<= "1000000011111010" ;wait for c_CLK_PERIOD;	---	JNEQ LOOPHEAD *-6*
											---END:
		--w_DATA_TO_PROGRAM	<= "0001000000000000" ;wait for c_CLK_PERIOD;	---	DB[0] = REG[0]

			---EXECUTE

		w_PROGRAMING_SIGNAL	<= '0' ;
		w_DATA_TO_PROGRAM	<= "UUUUUUUUUUUUUUUU" ;

			wait for c_CLK_PERIOD;

		wait;
		end process p_PROCESS;

end ARCH_1;

