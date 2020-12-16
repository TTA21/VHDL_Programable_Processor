library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CONTROL_UNIT is

port(
	
		i_CLK							:	in std_logic								;
		i_IM_PROGRAMING_SIGNAL	:	in std_logic								;
		i_IM_DATA_TO_PROGRAM		:	in std_logic_vector( 15 downto 0 )	;	---COMMANDS IN
		
		o_OB_REGFLAG_WEN			:	out std_logic								;	---FLAG REGISTER WRITE ENABLE SIGNAL
		o_OB_REGFLAG_REN			:	out std_logic								;	---FLAG REGISTER READ ENABLE SIGNAL
		i_OB_REGFLAG				:	in std_logic_vector ( 1 downto 0 )	;	---FLAG REGISTER
		
		o_IMEDIATE					:	out std_logic_vector (15 downto 0)	;
		o_MUX_SEL					:	out std_logic_vector ( 1 downto 0 )	;
		
		o_WRITEADRESS				:	out std_logic_vector(3 downto 0)		;
		o_WRITEENABLE				:	out std_logic								;
		
		o_READpADRESS				:	out std_logic_vector(3 downto 0)		;
		o_READpENABLE				:	out std_logic								;
		
		o_READqADRESS				:	out std_logic_vector(3 downto 0)		;
		o_READqENABLE				:	out std_logic								;
		
		o_CIN							:	out integer range 0 to 1				;
		o_SELECTOR					:	out std_logic_vector( 3 downto 0 )	;
		
		o_DATAADRESS				:	out std_logic_vector( 7 downto 0 )	;
		o_READENABLE				:	out std_logic								;
		o_DB_WRITEENABLE			:	out std_logic
		

);

end CONTROL_UNIT;

architecture ARCH_1 of CONTROL_UNIT is

	component CONTROL_BLOCK is

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
			
	end component;
	
	component PROGRAM_COUNTER is

		port(

				i_PC_CLK 	: in std_logic;
				i_PC_CLR 	: in std_logic;
				i_PC_INC 	: in std_logic;
				
				i_PC_JUMP	: in std_logic;
				i_PC_OFFSET	: in std_logic_vector ( 7 downto 0 );
				
				o_PC_OUT 	: out std_logic_vector ( 7 downto 0 )

		);
		
	end component;
	
	component INSTRUCTION_REGISTER is

		port(

			i_IR_CLK		:	in std_logic;
			i_IR_DATA	:	in std_logic_vector( 15 downto 0 );
			i_IR_LOAD	:	in std_logic;
			
			o_IR_OUTPUT	:	out std_logic_vector( 15 downto 0 )

		);
		
	end component;
	
	component INSTRUCTION_MEMORY is

		port(

			i_IM_CLK			:	in std_logic;
			
			i_IM_ADDR		:	in std_logic_vector( 7 downto 0 );	---MEMORY TAKEN DOWN TO 8 BITS, or 255 possibilities
			
			i_IM_RD			:	in std_logic;								---ENABLE FOR OUTPUT
			
			i_IM_DATA_LOAD	:	in std_logic;								---ENABLE FOR COMMAND INPUT
			
			i_IM_DATAIN		:	in std_logic_vector( 15 downto 0 );	---COMMANDS IN
			
			o_IM_DATA		:	out std_logic_vector( 15 downto 0 )

		);
		
	end component;
	
	
	signal	w_INST_MEM_READ_ENABLE		:	std_logic;
	signal	w_INST_MEM_PROGRAM			:	std_logic;
	signal	w_INST_MEM_OUTPUT				:	std_logic_vector( 15 downto 0 );
	
	signal	w_INST_REG_LOADSIG			:	std_logic;
	signal	w_INST_REG_OUTPUT				:	std_logic_vector( 15 downto 0 );
	
	signal	w_PC_CLEAR						:	std_logic;
	signal	w_PC_INCREMENT					:	std_logic;
	signal	w_PROGRAM_COUNTER_ADRESS	:	std_logic_vector ( 7 downto 0 );
	
	signal	w_CB_PC_JUMP					:	std_logic							;
	signal	w_PC_CB_ADDR_DIFFERENCE		:	std_logic_vector ( 7 downto 0 );
	
	begin
	
	u_IM	:	INSTRUCTION_MEMORY port map(
	
														i_IM_CLK			=> i_CLK								,
														i_IM_ADDR		=> w_PROGRAM_COUNTER_ADRESS	,
														i_IM_RD			=> w_INST_MEM_READ_ENABLE		,
														i_IM_DATA_LOAD	=> w_INST_MEM_PROGRAM			,
														i_IM_DATAIN		=> i_IM_DATA_TO_PROGRAM			,
														o_IM_DATA		=> w_INST_MEM_OUTPUT
	
													);
													
	u_IR	:	INSTRUCTION_REGISTER port map	(
	
															i_IR_CLK		=> i_CLK						,
															i_IR_DATA	=> w_INST_MEM_OUTPUT		,
															i_IR_LOAD	=>	w_INST_REG_LOADSIG	,
															o_IR_OUTPUT	=>	w_INST_REG_OUTPUT
	
														);
														
	u_PC	:	PROGRAM_COUNTER port map(
	
													i_PC_CLK		=>	i_CLK								,
													i_PC_CLR		=> w_PC_CLEAR						,
													i_PC_INC		=>	w_PC_INCREMENT					,
													i_PC_JUMP	=>	w_CB_PC_JUMP					,
													i_PC_OFFSET	=>	w_PC_CB_ADDR_DIFFERENCE		,
													o_PC_OUT		=>	w_PROGRAM_COUNTER_ADRESS	
													
												);
												
	u_CB	:	CONTROL_BLOCK port map(
	
					i_CB_CLK						=>	i_CLK							,
					
					---INSTRUCTION REGISTER
					
					i_CB_IR_DATA_IN			=>	w_INST_REG_OUTPUT			,
					o_CB_IR_LD					=>	w_INST_REG_LOADSIG		,
					
					---/INSTRUCTION REGISTER
					
					---PROGRAM COUNTER
					
					o_CB_PC_CLR					=>	w_PC_CLEAR					,
					o_CB_PC_INC					=>	w_PC_INCREMENT				,
					o_CB_PC_JUMP				=>	w_CB_PC_JUMP				,
					o_CB_PC_ADDR_DIFF			=>	w_PC_CB_ADDR_DIFFERENCE	,
					
					---/PROGRAM COUNTER
					
					---INSTRUCTION MEMORY
					
					i_CB_PROGRAMING			=>	i_IM_PROGRAMING_SIGNAL	,
					o_CB_LOAD_DATA				=>	w_INST_MEM_PROGRAM		,
					o_CB_READ_DATA				=>	w_INST_MEM_READ_ENABLE	,
					
					---/INSTRUCTION MEMORY
					
					---BLOCO OPERACIONAL
					
					o_CB_MUX_INPUT_CONSTANT	=>	o_IMEDIATE					,
					o_CB_MUX_SELECTOR			=>	o_MUX_SEL					,
					
					o_CB_RF_WRITEADRESS		=>	o_WRITEADRESS				,
					o_CB_RF_WRITEENABLE		=>	o_WRITEENABLE				,
					
					o_CB_RF_READpADRESS		=>	o_READpADRESS				,
					o_CB_RF_READpENABLE		=>	o_READpENABLE				,
					
					o_CB_RF_READqADRESS		=>	o_READqADRESS				,
					o_CB_RF_READqENABLE		=>	o_READqENABLE				,
					
					o_CB_ALU_CIN				=>	o_CIN							,
					o_CB_ALU_SELECTOR			=>	o_SELECTOR					,
					
					o_CB_DB_DATAADRESS		=>	o_DATAADRESS				,
					o_CB_DB_READENABLE		=>	o_READENABLE				,
					o_CB_DB_WRITEENABLE		=>	o_DB_WRITEENABLE			,
					
					o_REGFLAG_WEN				=>	o_OB_REGFLAG_WEN			,
					o_REGFLAG_REN				=>	o_OB_REGFLAG_REN			,
					i_REGFLAG					=>	i_OB_REGFLAG
						
					---/BLOCO OPERACIONAL
	
	);


end ARCH_1;