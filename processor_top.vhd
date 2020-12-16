library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TOP is

port(
	
		i_CLK						:	in std_logic								;
		i_PROGRAMING_SIGNAL	:	in std_logic								;
		i_DATA_TO_PROGRAM		:	in std_logic_vector( 15 downto 0 )	;	---COMMANDS IN
		
		o_OUTPUTp				:	out std_logic_vector (15 downto 0)	;	---Data output from reg_file p
		o_OUTPUTq				:	out std_logic_vector (15 downto 0)		---Data output from reg_file q
		
);

end TOP;

architecture ARCH_1 of TOP is

	component CONTROL_UNIT is

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
				o_DB_WRITEENABLE				:	out std_logic
				

		);

	end component;

	component OPERATIONAL_BLOCK is	

		port(

				i_OB_CLK							: in std_logic									;
				
				i_REGFLAG_WEN					:	in std_logic								;	---REGISTER FLAG WRITE ENABLE
				i_REGFLAG_REN					:	in std_logic								;	---REGISTER FLAG READ ENABLE
				o_REGFLAG_OUT					:	out std_logic_vector						;	---REGISTER FLAG OUT
				
				i_MUX_INPUT_CONSTANT			:	in std_logic_vector (15 downto 0)	;	--- Input constant for multiplexer i_C
				i_MUX_SELECTOR					:	in std_logic_vector ( 1 downto 0 )	;	--- Selector input for multiplexer
				
				i_RF_WRITEADRESS				:	in std_logic_vector(3 downto 0)		;	--- Adress for writing to RF
				i_RF_WRITEENABLE				:	in std_logic								;	--- Enable for writing to RF
				
				i_RF_READpADRESS				:	in std_logic_vector(3 downto 0)		;	--- Adress for Readp from RF
				i_RF_READpENABLE				:	in std_logic								;	--- Enable for Readp from RF
				
				i_RF_READqADRESS				:	in std_logic_vector(3 downto 0)		;	--- Adress for Readq from RF
				i_RF_READqENABLE				:	in std_logic								;	--- Enable for Readq from RF
				
				i_ALU_CIN						:	in integer range 0 to 1					;	--- Carry for ALU
				i_ALU_SELECTOR					:	in std_logic_vector( 3 downto 0 )	;	--- Selector for ALU
				
				i_DB_DATAADRESS				:	in std_logic_vector( 7 downto 0 )	;	--- Data adress input for Data Bank
				i_DB_READENABLE				:	in std_logic								;	--- Read enable for Data Bank
				i_DB_WRITEENABLE				:	in std_logic								;	--- Write enable for Data Bank
				
				o_REG_OUTPUTp					:	out std_logic_vector (15 downto 0)	;	---Data output from reg_file p
				o_REG_OUTPUTq					:	out std_logic_vector (15 downto 0)		---Data output from reg_file q
				
				
		);

	end component;
	
	signal w_IMEDIATE	:	std_logic_vector (15 downto 0)					;
	signal w_MUX_SEL	:	std_logic_vector ( 1 downto 0 )					;
	signal w_WRITEADRESS				:	std_logic_vector(3 downto 0)		;
	signal w_WRITEENABLE				:	std_logic								;
	signal w_READpADRESS				:	std_logic_vector(3 downto 0)		;
	signal w_READpENABLE				:	std_logic								;
	signal w_READqADRESS				:	std_logic_vector(3 downto 0)		;
	signal w_READqENABLE				:	std_logic								;
	signal w_CIN						:	integer range 0 to 1					;
	signal w_SELECTOR					:	std_logic_vector( 3 downto 0 )	;
	signal w_DATAADRESS				:	std_logic_vector( 7 downto 0 )	;
	signal w_READENABLE				:	std_logic								;
	signal w_DB_WRITEENABLE			:	std_logic								;
	
	signal w_FLAG_REGIST_WRITEEN	:	std_logic								;
	signal w_FLAG_REGIST_READEN	:	std_logic								;
	signal w_FLAG_REGIST				:	std_logic_vector( 1 downto 0 )	;
	
	begin
	
	u_CTRL	:	CONTROL_UNIT port map(
	
													i_CLK							=>	i_CLK						,
													i_IM_PROGRAMING_SIGNAL	=>	i_PROGRAMING_SIGNAL	,
													i_IM_DATA_TO_PROGRAM		=>	i_DATA_TO_PROGRAM		,
													
													o_OB_REGFLAG_WEN			=>	w_FLAG_REGIST_WRITEEN,
													o_OB_REGFLAG_REN			=>	w_FLAG_REGIST_READEN	,
													i_OB_REGFLAG				=>	w_FLAG_REGIST			,
													
													o_IMEDIATE					=>	w_IMEDIATE				,
													o_MUX_SEL					=> w_MUX_SEL				,
													
													o_WRITEADRESS				=>	w_WRITEADRESS			,
													o_WRITEENABLE				=>	w_WRITEENABLE			,
													
													o_READpADRESS				=>	w_READpADRESS			,
													o_READpENABLE				=>	w_READpENABLE			,
													
													o_READqADRESS				=>	w_READqADRESS			,
													o_READqENABLE				=>	w_READqENABLE			,
													
													o_CIN							=>	w_CIN						,
													o_SELECTOR					=>	w_SELECTOR				,
													
													o_DATAADRESS				=>	w_DATAADRESS			,
													o_READENABLE				=>	w_READENABLE			,
													o_DB_WRITEENABLE			=>	w_DB_WRITEENABLE		
	
												);
												
	u_OB	:	OPERATIONAL_BLOCK port map	(
	
														i_OB_CLK					=>	i_CLK							,
														
														i_REGFLAG_WEN			=>	w_FLAG_REGIST_WRITEEN	,
														i_REGFLAG_REN			=> w_FLAG_REGIST_READEN		,
														o_REGFLAG_OUT			=>	w_FLAG_REGIST				,
														
														i_MUX_INPUT_CONSTANT	=>	w_IMEDIATE					,
														i_MUX_SELECTOR			=>	w_MUX_SEL					,
														
														i_RF_WRITEADRESS		=>	w_WRITEADRESS				,
														i_RF_WRITEENABLE		=>	w_WRITEENABLE				,
														
														i_RF_READpADRESS		=>	w_READpADRESS				,
														i_RF_READpENABLE		=>	w_READpENABLE				,
														
														i_RF_READqADRESS		=>	w_READqADRESS				,
														i_RF_READqENABLE		=>	w_READqENABLE				,
														
														i_ALU_CIN				=>	w_CIN							,
														i_ALU_SELECTOR			=>	w_SELECTOR					,
														
														i_DB_DATAADRESS		=>	w_DATAADRESS				,
														i_DB_READENABLE		=>	w_READENABLE				,
														i_DB_WRITEENABLE		=>	w_DB_WRITEENABLE			,
														
														o_REG_OUTPUTp			=>	o_OUTPUTp					,
														o_REG_OUTPUTq			=>	o_OUTPUTq
	
													);

end ARCH_1;