library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROL_BLOCK is	---DONE

port(

		i_CB_CLK								:	in std_logic								;
		
		---INSTRUCTION REGISTER
		
		i_CB_IR_DATA_IN					:	in std_logic_vector( 15 downto 0 )	;	---Instructions from instruction register
		o_CB_IR_LD							:	out std_logic								;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							:	out std_logic								;	---Signal for Program Counter to clear
		o_CB_PC_INC							:	out std_logic								;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						:	out std_logic								;	---Signal for program counter to jump
		o_CB_PC_ADDR_DIFF					:	out std_logic_vector ( 7 downto 0 )	;	---Difference that PC has to account for, use for conditional jumps
		
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		i_CB_PROGRAMING					:	in std_logic								;	---If 1 , programing
		o_CB_LOAD_DATA						:	out std_logic								;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						:	out std_logic								;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			:	out std_logic_vector (15 downto 0)	;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					:	out std_logic_vector ( 1 downto 0 )	;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				:	out std_logic_vector(3 downto 0)		;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				:	out std_logic								;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				:	out std_logic_vector(3 downto 0)		;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				:	out std_logic								;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				:	out std_logic_vector(3 downto 0)		;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				:	out std_logic								;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						:	out integer range 0 to 1				;	--- Carry for ALU
		o_CB_ALU_SELECTOR					:	out std_logic_vector( 3 downto 0 )	;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				:	out std_logic_vector( 7 downto 0 )	;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				:	out std_logic								;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				:	out std_logic								;	--- Write enable for Data Bank
		
		o_REGFLAG_WEN						:	out std_logic								;	--- Write enable for comand block's flag register 
		o_REGFLAG_REN						:	out std_logic								;	--- Read enable for comand block's flag register
		i_REGFLAG							:	in std_logic_vector ( 1 downto 0 )		--- Comand Block's flag register
		
		
		---/BLOCO OPERACIONAL
		
		
);

end CONTROL_BLOCK;

architecture ARCH_1 of CONTROL_BLOCK is

		type t_STATE is ( s_INIT , s_PROGRAM_INIT , s_PROGRAM_END , s_FETCH , s_DECODE , s_LOAD , s_STORE , s_LOAD_IMMEDIATE , s_ADD , s_CMP , s_JE , s_SUB , s_JLT , s_JNE , s_JNLT , s_WAIT );
    
		signal r_STATE  	: t_STATE := s_INIT ; -- Ã dado o primeiro empurrÃ£o
		signal w_NEXT 		: t_STATE := s_INIT ;
		
begin
		
		process ( i_CB_CLK , r_STATE , i_CB_PROGRAMING , w_NEXT , i_CB_IR_DATA_IN , i_REGFLAG ) begin
		
		r_STATE <= w_NEXT;
		
		if rising_edge( i_CB_CLK ) then
		
			case r_STATE is
			
			when s_INIT				=>	
			
										---CLEAR PC
										---EVERYTHING IS OFF
										w_NEXT <= s_PROGRAM_INIT;
			
			when s_PROGRAM_INIT	=>	
			
										---SEND SIGNAL TO INSTRUCTION MEMORY TO UPDATE ITSELF BASED ON OFF SITE DATA
										---ALLOW FOR PC TO INCREMENT
			
										if i_CB_PROGRAMING = '1' then
										
											w_NEXT <= s_PROGRAM_INIT;
											
										else
										
											w_NEXT <= s_PROGRAM_END;
											
										end if;
			
			when s_PROGRAM_END		=>
			
										---CLEAR PC
										---SEND SIGNAL TO INSTRUCTION MEMORY TO STOP WRITING, AND START READING
										---SEND SIGNAL TO INSTRUCTION REGISTER TO START READING
										
										w_NEXT <= s_FETCH;
			
			when s_FETCH				=>	
			
										---LOAD w_OPERATOR AND w_OPERAND_ FOR NEXT STATE , INCREASE PC
										
										w_NEXT <= s_DECODE;
			
			when s_DECODE			=>	
			
										---DEPENDING ON OPCODE FROM w_OPERATOR , CHANGE STATES ACCORDINGLY
										
										if 	i_CB_IR_DATA_IN( 15 downto 12 ) = "0000" then	---LOAD FROM DATA_BANK INTO REGISTER
											
											w_NEXT <= s_LOAD;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0001" then	---STORE FROM REGISTER INTO DATA_BANK
										
											w_NEXT <= s_STORE;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0010" then	---TAKE FROM 2 REGISTERS AND ADD TEHM INTO ANOTHER REGISTER
										
											w_NEXT <= s_ADD;
											
										elsif	i_CB_IR_DATA_IN( 15 downto 12 ) = "0011" then	---LOAD IMMEDIATE INTO REGISTER
										
											w_NEXT <= s_LOAD_IMMEDIATE;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0100" then
										
											w_NEXT <= s_CMP;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0101" then
										
											w_NEXT <= s_JE;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0110" then
										
											w_NEXT <= s_SUB;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "0111" then
										
											w_NEXT <= s_JLT;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "1000" then
										
											w_NEXT <= s_JNE;
											
										elsif i_CB_IR_DATA_IN( 15 downto 12 ) = "1001" then
										
											w_NEXT <= s_JNLT;
											
										end if;
			
			when s_LOAD				=>	
			
										---LOAD FROM DATA_BANK TO A REGISTER
			
										w_NEXT <= s_FETCH;
			
			when s_STORE				=>	
										
										---STORE FROM REGISTER INTO DATA_BANK
			
										w_NEXT <= s_FETCH;
			
			when s_LOAD_IMMEDIATE	=>	
			
										---TAKE FROM MUX AND STORE INTO A REGISTER
			
										w_NEXT <= s_FETCH;
			
			when s_ADD					=>	
			
										---Operand to will have both register adresses
			
										w_NEXT <= s_WAIT;
										
			when s_CMP					=>
			
										w_NEXT <= s_FETCH;
										
			when s_JE					=>
			
										w_NEXT <= s_WAIT;
										
			when s_SUB					=>
			
										w_NEXT <= s_WAIT;
										
			when s_JLT					=>
			
										w_NEXT <= s_WAIT;
										
			when s_JNE					=>
			
										w_NEXT <= s_WAIT;
										
			when s_JNLT					=>
			
										w_NEXT <= s_WAIT;
										
			when s_WAIT					=>	
			
										w_NEXT <= s_FETCH;
			
			when others					=>	
				
										w_NEXT <= s_INIT;
										
			
			end case;
		
		end if;	---i_CB_CLK
		
		case r_STATE is
		
		when s_WAIT					=>
		
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" 	;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "UU" 						;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" 					;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' 						;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' 						;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' 						;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 							;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" 					;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" 				;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' 						;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' 						;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_INIT				=>
		
										---CLEAR PC
										---EVERYTHING IS OFF
										
		
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '1' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "00000000";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '0' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_PROGRAM_INIT		=>
		
										---SEND SIGNAL TO INSTRUCTION MEMORY TO UPDATE ITSELF BASED ON OFF SITE DATA
										---ALLOW FOR PC TO INCREMENT
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
										
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '1' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '1' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '0' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		
		when	s_PROGRAM_END		=>
		
										---CLEAR PC
										---SEND SIGNAL TO INSTRUCTION MEMORY TO STOP WRITING, AND START READING
										---SEND SIGNAL TO INSTRUCTION REGISTER TO START READING
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
										
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '1' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '1' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_FETCH				=>
		
							---LOAD w_OPERATOR AND w_OPERAND_ FOR NEXT STATE , INCREASE PC
							
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '1' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '1' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_DECODE				=>
		
							---DEPENDING ON OPCODE FROM w_OPERATOR , CHANGE STATES ACCORDINGLY
							
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '1' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when 	s_LOAD				=>	
		
								---LOAD FROM DATA_BANK TO A REGISTER
								
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
								
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "01" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= i_CB_IR_DATA_IN( 11 downto 8 ) ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '1' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= i_CB_IR_DATA_IN( 7 downto 0 ) ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '1' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_STORE				=>
		
								---STORE FROM REGISTER INTO DATA_BANK
								
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
								
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "UU" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= i_CB_IR_DATA_IN( 11 downto 8 ) ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '1' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= i_CB_IR_DATA_IN( 7 downto 0 ) ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '1' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when	s_LOAD_IMMEDIATE	=>
		
								---TAKE FROM MUX AND STORE INTO A REGISTER
								
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '1' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register

		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "00000000" & i_CB_IR_DATA_IN( 7 downto 0 ) ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= i_CB_IR_DATA_IN( 11 downto 8 ) ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '1' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		
		
		when	s_ADD					=>
		
								---Operand to will have both register adresses
								
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
								
		        ---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "00" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= i_CB_IR_DATA_IN( 11 downto 8 ) ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '1' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= i_CB_IR_DATA_IN( 7 downto 4 ) ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '1' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= i_CB_IR_DATA_IN( 3 downto 0 ) ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '1' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "0001" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_CMP					=>
		
										---COMPARE TWO REGISTERS IN OPERAND TWO
										
		o_REGFLAG_WEN						<= '1' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" 	;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "UU" 						;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" 					;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' 						;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= i_CB_IR_DATA_IN( 7 downto 4) ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '1' 						;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= i_CB_IR_DATA_IN( 3 downto 0) ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '1' 						;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 							;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" 					;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" 				;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' 						;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' 						;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_JE					=>
		
		
										---SEND PC A SIGNAL TO JUMP IF EQ REGISTER IS 1
										
		
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		
		if i_REGFLAG(1) = '1' then	---IF EQ = '1' , jump 
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '1' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= i_CB_IR_DATA_IN( 7 downto 0 );	---Difference for PC to jump
		
		else
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
			
		end if;
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_SUB					=>
		
								---Operand to will have both register adresses
								
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '0' ;		---Signal for Register file's Flag register to output its contents
								
		        ---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
      o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "00" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= i_CB_IR_DATA_IN( 11 downto 8 ) ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '1' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= i_CB_IR_DATA_IN( 7 downto 4 ) ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '1' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= i_CB_IR_DATA_IN( 3 downto 0 ) ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '1' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "0010" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_JLT					=>
		
										---SEND PC A SIGNAL TO JUMP IF LT REGISTER IS 1
										
		
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		
		if i_REGFLAG(0) = '1' then	---IF LT = '1' , jump 
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '1' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= i_CB_IR_DATA_IN( 7 downto 0 );	---Difference for PC to jump
		
		else
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
			
		end if;
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_JNE					=>

		
										---SEND PC A SIGNAL TO JUMP IF EQ REGISTER IS 0
										
		
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		
		if i_REGFLAG(1) = '0' then	---IF EQ = '0' , jump 
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '1' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= i_CB_IR_DATA_IN( 7 downto 0 );	---Difference for PC to jump
		
		else
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
			
		end if;
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		when s_JNLT					=>
		
										---SEND PC A SIGNAL TO JUMP IF LT REGISTER IS 1
									
										
		o_REGFLAG_WEN						<= '0' ;		---Signal for Register file's Flag register to write from signals
		o_REGFLAG_REN						<= '1' ;		---Signal for Register file's Flag register to output its contents
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '0' ;	---Signal for Program Counter to clear
		
		if i_REGFLAG(0) = '0' then	---IF LT = '0' , jump 
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '1' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= i_CB_IR_DATA_IN( 7 downto 0 );	---Difference for PC to jump
		
		else
		
			o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
			o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
			o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
			
		end if;
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '1' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		
		
		
		when others					=>
		
										---CLEAR PC
										---EVERYTHING IS OFF
		
		---INSTRUCTION REGISTER

		o_CB_IR_LD							<= '0' ;	---Signal for instruction register to load contents
		
		---/INSTRUCTION REGISTER
		
		---PROGRAM COUNTER
		
		o_CB_PC_CLR							<= '1' ;	---Signal for Program Counter to clear
		o_CB_PC_INC							<= '0' ;	---Signal for Program Counter to increment
		o_CB_PC_JUMP						<= '0' ;	---Signal for Program Counter to jump
		o_CB_PC_ADDR_DIFF					<= "UUUUUUUU";	---Difference for PC to jump
		
		---/PROGRAM COUNTER
		
		---INSTRUCTION MEMORY
		
		o_CB_LOAD_DATA						<= '0' ;	---Signal for Instruction Memory to load Data at addres from PC
		o_CB_READ_DATA						<= '0' ;	---Signal for Instruction Memory to dum its contents into Insruction Register
		
		---/INSTRUCTION MEMORY
		
		---BLOCO OPERACIONAL
		
		o_CB_MUX_INPUT_CONSTANT			<= "UUUUUUUUUUUUUUUU" ;	--- Input constant for multiplexer i_C
		o_CB_MUX_SELECTOR					<= "10" ;	--- Selector input for multiplexer
		
		o_CB_RF_WRITEADRESS				<= "UUUU" ;	--- Adress for writing to RF
		o_CB_RF_WRITEENABLE				<= '0' ;	--- Enable for writing to RF
		
		o_CB_RF_READpADRESS				<= "UUUU" ;	--- Adress for Readp from RF
		o_CB_RF_READpENABLE				<= '0' ;	--- Enable for Readp from RF
		
		o_CB_RF_READqADRESS				<= "UUUU" ;	--- Adress for Readq from RF
		o_CB_RF_READqENABLE				<= '0' ;	--- Enable for Readq from RF
		
		o_CB_ALU_CIN						<= 0 ;	--- Carry for ALU
		o_CB_ALU_SELECTOR					<= "UUUU" ;	--- Selector for ALU
		
		o_CB_DB_DATAADRESS				<= "UUUUUUUU" ;	--- Data adress input for Data Bank
		o_CB_DB_READENABLE				<= '0' ;	--- Read enable for Data Bank
		o_CB_DB_WRITEENABLE				<= '0' ;	--- Write enable for Data Bank
		
		---/BLOCO OPERACIONAL
		
		end case;
		
		end process;
		
end ARCH_1;