library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity OPERATIONAL_BLOCK is	---DONE

port(

		i_OB_CLK							:	in std_logic								;
		
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

end OPERATIONAL_BLOCK;

architecture ARCH_1 of OPERATIONAL_BLOCK is

		component NEW_REGISTER_FILE is

			port(

					i_RF_CLK					: in std_logic;
					
					i_RF_REGFLAG_WEN		: in std_logic										;	---REGISTER FLAG WRITE ENABLE
					i_RF_REGFLAG_REN		: in std_logic										;	---REGISTER FLAG READ ENABLE
					i_RF_EQUAL_FLAG		: in std_logic										;
					i_RF_LESSTHAN_FLAG	: in std_logic										;
					o_RF_REGFLAG_OUT		: out std_logic_vector( 1 downto 0 )		;	---REGISTER FLAG OUT

					i_RF_WDATA				: in std_logic_vector (15 downto 0)			;	---WRITE DATA IN
					i_RF_WADDRESS			: in std_logic_vector (3 downto 0)			;	---WRITE ADDRESS
					i_RF_WEN					: in std_logic;										---WRITE ANABLE

					o_RF_RpDATA				: out std_logic_vector(15 downto 0)			;	---READ DATA P
					i_RF_RpADRESS			: in std_logic_vector(3 downto 0)			;	---READ ADDRESS
					i_RF_RpEN				: in std_logic										;
					
					o_RF_RqDATA				: out std_logic_vector(15 downto 0)			;	---READ DATA Q
					i_RF_RqADRESS			: in std_logic_vector(3 downto 0)			;	---READ ADDRESS
					i_RF_RqEN				: in std_logic			

			);

		end component;
		
		component MUX_3X1 is

			port(

					i_A	: in std_logic_vector ( 15 downto 0 )	;	---ALU
					i_B	: in std_logic_vector ( 15 downto 0 )	;	---DATA BANK
					i_C	: in std_logic_vector ( 15 downto 0 )	;	---CONSTANT
					
					i_SEL	: in std_logic_vector ( 1 downto 0 )	;	--- 0000 load ALU , 0001 load DATA BANK , 0010 load CONSTANT
					
					o_OUT	: out std_logic_vector ( 15 downto 0 )

			);

		end component;
		
		component ALU is

			port(

					i_A		: in std_logic_vector( 15 downto 0 )	;
					i_B		: in std_logic_vector( 15 downto 0 )	;
					i_CIN		: in integer range 0 to 1					;	---Carry in for the shift and for the adder
					
					i_SEL		: in std_logic_vector( 3 downto 0 )		;
					
					o_OUT		: out std_logic_vector( 15 downto 0 )	;
					o_EQ		: out std_logic								;		---CMP two vectors , ZERO FLAG
					o_LTA		: out std_logic										---CMP two vectors , If B less than A , o_LTA = 1

			);

		end component;
		
		component NEW_DATA_BANK is	---DONE

			port(

					i_CLK			: in std_logic								;

					i_DATA_ADDR	: in std_logic_vector( 7 downto 0 )	;
					
					i_READ_EN	: in std_logic								;
					i_WRITE_EN	: in std_logic								;
					
					i_W_DATA		: in std_logic_vector( 15 downto 0 );
					o_R_DATA		: out std_logic_vector( 15 downto 0 )

			);

		end component;
		
		signal w_OUTPUT_FROM_ALU			:	std_logic_vector (15 downto 0)		;
		signal w_OUTPUT_FROM_MUX			:	std_logic_vector ( 15 downto 0 )		;
		
		signal w_OUTPUTp_FROM_RF			:	std_logic_vector(15 downto 0)			;
		signal w_OUTPUTq_FROM_RF			:	std_logic_vector(15 downto 0)			;
		
		signal w_OUTPUT_FROM_DATA_BANK	:	std_logic_vector(15 downto 0)			;
		
		signal w_EQUAL_FLAG					:	std_logic									;
		signal w_LESSTHAN_FLAG				:	std_logic									;

begin

	u_MUX	:	MUX_3X1 port map(
	
										i_A	=>	w_OUTPUT_FROM_ALU			,
										i_B	=>	w_OUTPUT_FROM_DATA_BANK	,
										i_C	=> i_MUX_INPUT_CONSTANT		,
										
										i_SEL	=> i_MUX_SELECTOR				,
										
										o_OUT	=> w_OUTPUT_FROM_MUX
	
									);
									
	u_RF	:	NEW_REGISTER_FILE port map(
	
													i_RF_CLK					=>	i_OB_CLK				,
													
													i_RF_REGFLAG_WEN		=>	i_REGFLAG_WEN		,
													i_RF_REGFLAG_REN		=>	i_REGFLAG_REN		,
													i_RF_EQUAL_FLAG		=>	w_EQUAL_FLAG			,
													i_RF_LESSTHAN_FLAG	=>	w_LESSTHAN_FLAG	,
													o_RF_REGFLAG_OUT		=>	o_REGFLAG_OUT		,
													
													i_RF_WDATA				=>	w_OUTPUT_FROM_MUX	,
													i_RF_WADDRESS			=>	i_RF_WRITEADRESS	,
													i_RF_WEN					=>	i_RF_WRITEENABLE	,
													
													o_RF_RpDATA				=>	w_OUTPUTp_FROM_RF	,
													i_RF_RpADRESS			=>	i_RF_READpADRESS	,
													i_RF_RpEN				=>	i_RF_READpENABLE	,
													
													o_RF_RqDATA				=>	w_OUTPUTq_FROM_RF	,
													i_RF_RqADRESS			=>	i_RF_READqADRESS	,
													i_RF_RqEN				=>	i_RF_READqENABLE	
	
													);
													
	u_ALU	:	ALU port map(
	
								i_A	=>	w_OUTPUTp_FROM_RF	,
								i_B	=>	w_OUTPUTq_FROM_RF	,
								i_CIN	=>	i_ALU_CIN			,
								
								i_SEL	=>	i_ALU_SELECTOR		,
								
								o_OUT	=>	w_OUTPUT_FROM_ALU	,
								o_EQ	=>	w_EQUAL_FLAG		,
								o_LTA	=>	w_LESSTHAN_FLAG	
								
								
								);
								
	u_DB	:	NEW_DATA_BANK port map(
	
											i_CLK			=>	i_OB_CLK				,
											
											i_DATA_ADDR	=>	i_DB_DATAADRESS	,
											
											i_READ_EN	=>	i_DB_READENABLE	,
											i_WRITE_EN	=>	i_DB_WRITEENABLE	,
											
											i_W_DATA		=>	w_OUTPUTp_FROM_RF	,
											o_R_DATA		=>	w_OUTPUT_FROM_DATA_BANK
											
											);
											
	o_REG_OUTPUTp	<= w_OUTPUTp_FROM_RF;
	o_REG_OUTPUTq	<= w_OUTPUTq_FROM_RF;

end ARCH_1;