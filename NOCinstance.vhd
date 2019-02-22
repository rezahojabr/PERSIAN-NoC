Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;

entity NOCinstance is
	generic(
		CorWidth	: Integer := 4;
		
		CurNode		: Integer := 0
	);
	Port(
		Clk				: In  std_logic;
		Reset			: In  std_logic

		
		
		
	);
End;


Architecture behavioral of NOCinstance is

Signal	R1InpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R1InpEn			: Unsigned(PhyRoCh-1 downto 0);
Signal	R1VCEmpty		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R1CreditOut		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R1CreditIn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal 	R1InpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1
Signal	R1OutpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R1OutpEn		: Unsigned(PhyRoCh-1 downto 0);
Signal	R1OutpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1

Signal	R2InpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R2InpEn			: Unsigned(PhyRoCh-1 downto 0);
Signal	R2VCEmpty		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R2CreditOut		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R2CreditIn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal 	R2InpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1
Signal	R2OutpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R2OutpEn		: Unsigned(PhyRoCh-1 downto 0);
Signal	R2OutpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1

Signal	R3InpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R3InpEn			: Unsigned(PhyRoCh-1 downto 0);
Signal	R3VCEmpty		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R3CreditOut		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	R3CreditIn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal 	R3InpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1
Signal	R3OutpData		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	R3OutpEn		: Unsigned(PhyRoCh-1 downto 0);
Signal	R3OutpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1

Begin

R2InpData(0)	<=	R1OutpData(2);
R2InpEn(0)		<=	R1OutpEn(2);
R2InpSel(0)		<=	R1OutpSel(2);

R1CreditIn(2*ViCh + (ViCh-1) Downto 2*ViCh )	<=	R2CreditIn(ViCh-1 Downto 0);

R3InpData(0)	<=	R2OutpData(2);
R3InpEn(0)		<=	R2OutpEn(2);
R3InpSel(0)		<=	R2OutpSel(2);

R2CreditIn(2*ViCh + (ViCh-1) Downto 2*ViCh )	<=	R3CreditIn(ViCh-1 Downto 0);

R1: Entity Work.Router 
	Generic Map(
		
		CorWidth	,
		--
		CurNode	
			
		)
	Port Map(
		 
		
		Clk			=>	Clk,	
		Reset		=>	Reset,	
		 
		InpData		=>	R1InpData	,
		InpEn		=>	R1InpEn		,
		VCEmpty		=>	R1VCEmpty	,	
		CreditOut	=>	R2CreditOut	,	
		InpSel		=>	R1InpSel	,	

		OutpData	=>	R1OutpData	,	
		OutpEn		=>	R1OutpEn	,	
		CreditIn	=>	R1CreditIn	,	

		OutpSel		=>	R1OutpSel			
	);
	
R2: Entity Work.Router 
	Generic Map(
		
		CorWidth	,
		--
		CurNode	
			
		)
	Port Map(
		 
		
		Clk			=>	Clk,	
		Reset		=>	Reset,	
		 
		InpData		=>	R2InpData	,
		InpEn		=>	R2InpEn		,
		VCEmpty		=>	R2VCEmpty	,	
		CreditOut	=>	R2CreditOut	,	
		InpSel		=>	R2InpSel	,	

		OutpData	=>	R2OutpData	,	
		OutpEn		=>	R2OutpEn	,	
		CreditIn	=>	R2CreditIn	,	

		OutpSel		=>	R2OutpSel			
	);

R3: Entity Work.Router 
	Generic Map(
		
		CorWidth	,
		--
		CurNode	
			
		)
	Port Map(
		 
		
		Clk			=>	Clk,	
		Reset		=>	Reset,	
		 
		InpData		=>	R3InpData	,
		InpEn		=>	R3InpEn		,
		VCEmpty		=>	R3VCEmpty	,	
		CreditOut	=>	R3CreditOut	,	
		InpSel		=>	R3InpSel	,	

		OutpData	=>	R3OutpData	,	
		OutpEn		=>	R3OutpEn	,	
		CreditIn	=>	R3CreditIn	,	

		OutpSel		=>	R3OutpSel			
	);		
	
End;