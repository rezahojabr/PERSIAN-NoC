-- PERSIAN-NoC
-- PERformance SImulation Architecture for Networks-on-chip
-- Version: 3.0
-- Last Update: 2019/02/25
-- High Performance Network Laboratory
-- School of Electrical and Computer Engineering
-- University of Tehran,
-- Author: Reza Hojabr

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;

entity Node is
	generic(
		InpFilePoisson	: String  := "Poisson.txt";
		InpFileUniform	: String  := "Uniform.txt";
		InpFileLAR		: String  := "LAR.txt";		--Look Ahead Routing Information
		InpFilePackLen	: String  := "PackLen.txt";		--Look Ahead Routing Information
		OutpFilePack	: String  := "Outp.txt";
		OutpFileTime	: String  := "TimeOutp.txt";

		ViChAddr	: Integer := 1;
		PhyRoChAddr	: Integer := 2+1;
		--
		PhyCh		: Integer := 4;
		ViCh		: Integer := 2;
		RoCh 		: Integer := 1;
		PhyRoCh		: Integer := 4+1;
		--
		PackWidth	: Integer := 8;
		DataWidth	: Integer := 8;
		CorWidth	: Integer := 4;

		CurNode		: Integer := 0;
		PackGen		: std_logic :='1';
		PackGenNum	: Unsigned(15 Downto 0)
	);
	Port(
		Clk				: In  std_logic;
		Reset			: In  std_logic;

		InpData			: In  SignedArrDW(PhyCh-1 downto 0); --? 8+2
		InpEn			: In  Unsigned(PhyCh-1 downto 0);
		CreditOut		: Out Unsigned(PhyCh*ViCh-1 downto 0);
		InpSel			: In  UnsignedArrVCA(PhyCh-1 downto 0); -- ? ViChAddr=1

		OutpData		: Out SignedArrDW(PhyCh-1 downto 0); --? 8+2
		OutpEn			: Out Unsigned(PhyCh-1 downto 0);
		CreditIn		: In  Unsigned(PhyCh*ViCh-1 downto 0);
		OutpSel			: Out UnsignedArrVCA(PhyCh-1 downto 0); -- ? ViChAddr=1

		SentCnt			: Out Unsigned(15 Downto 0);
		ReceCnt			: Out Unsigned(15 Downto 0);
		AveReceTime		: Out Unsigned(19 Downto 0);
		StopSim			: In Std_Logic

		--MD1InpData		: In  SignedArrDW(PhyCh-1 downto 0);
		--MD1InpEn		: In  Unsigned(PhyCh-1 downto 0);

		--MD2InpData		: In  SignedArrDW(PhyCh-1 downto 0);
		--MD2InpEn		: In  Unsigned(PhyCh-1 downto 0);



		--CNOutpData		: Out SignedArrDW(PhyCh-1 downto 0);
		--CNOutpEn		: Out Unsigned(PhyCh-1 downto 0);

		--AckOut			: Out Unsigned(PhyCh-1 downto 0);
		--AckIn			: In Unsigned(PhyCh-1 downto 0)




	);
End;


Architecture behavioral of Node is

Signal	CurrentNode		: Integer := 0;

Signal	OutpDataArr		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	OutpEnArr		: Unsigned(PhyRoCh-1 downto 0);
Signal	OutpReadyArr	: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	CreditInArr		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	OutpSelArr		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1

Signal	InpDataArr		: SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
Signal	InpEnArr		: Unsigned(PhyRoCh-1 downto 0);
Signal	InpReadyArr		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	VCEmptyArr		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	CreditOutArr		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal 	InpSelArr		: UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1


--Signal	LocalOutpData	: Signed(DataWidth-1 Downto 0);
--Signal	LocalOutpEn		: std_logic;





Begin

CurrentNode <= CurNode;
--YY <= Y;

InpDataArr(PhyCh-1 Downto 0) 	<=	InpData		;
InpEnArr(PhyCh-1 Downto 0)		<=	InpEn		;

CreditOut						<=	CreditOutArr(PhyCh*ViCh-1 Downto 0);
InpSelArr(PhyCh-1 Downto 0)		<=	InpSel		;

OutpData	<=	OutpDataArr(PhyCh-1 Downto 0)		;
OutpEn		<=	OutpEnArr(PhyCh-1 Downto 0)			;

--CNOutpData	<=	CNOutpDataArr(PhyCh-1 Downto 0)		;
--CNOutpEn	<=	CNOutpEnArr(PhyCh-1 Downto 0)		;

CreditInArr(PhyCh*ViCh-1 Downto 0)	<= CreditIn		;
OutpSel		<=	OutpSelArr(PhyCh-1 Downto 0)		;

--LSDInpData	<=	(Others=>(Others=>'Z'));
--LSDInpEn	<=	(Others=>'Z');

R: Entity Work.Router
	Generic Map(

		CorWidth	,
		--
		CurNode

		)
	Port Map(
		 Clk			,
		 Reset		,

		InpDataArr	,
		InpEnArr	,
		VCEmptyArr	,
		CreditOutArr,
		InpSelArr	,

		OutpDataArr	,
		OutpEnArr	,
		CreditInArr	,
		OutpSelArr
	);

PE: Entity Work.PEv
		Generic Map(
			InpFilePoisson,
			InpFileUniform,
			InpFileLAR,
			InpFilePackLen,
			OutpFilePack	 ,
			OutpFileTime	,
			DataWidth	,
			ViChAddr		,
			ViCh			,
			--
			CurNode	,
			PackSize,
			PackWidth	,
			PackGen		,
			PackGenNum
		)
		Port Map(
			Clk						,
			Reset						,

			OutpDataArr(PhyRoCh-1)	,
			OutpEnArr(PhyRoCh-1)		,
			CreditInArr(PhyRoCh*ViCh-1 Downto (PhyRoCh-1)*ViCh)	,
			OutpSelArr(PhyRoCh-1)		,

			InpDataArr(PhyRoCh-1)		,
			InpEnArr(PhyRoCh-1)		,
			VCEmptyArr(PhyRoCh*ViCh-1 Downto (PhyRoCh-1)*ViCh)	,
			CreditOutArr(PhyRoCh*ViCh-1 Downto (PhyRoCh-1)*ViCh),
			InpSelArr(PhyRoCh-1)		,

			--LocalOutpData	,
			--LocalOutpEn		,

			SentCnt,
			ReceCnt,
			AveReceTime,

			StopSim

	);


End;
