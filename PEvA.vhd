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
use work.FilePack.all;

entity ReaderV is
	generic(
		InpFilePoisson	: String  := "Poisson.txt";
		InpFileUniform	: String  := "Uniform.txt";
		InpFileLARinfo	: String  := "LARinfo.txt";		--Look Ahead Routing Information
		InpFilePackLen	: String  := "PackLen.txt";		--Look Ahead Routing Information

		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 1;
		--
		--X			: Integer := 0;
		--Y			: Integer := 0;
		CurNode		: Integer := 0;
		PackWidth	: Integer := 8; -- bit of pack size
		PackGen		: std_logic :='1';			--mask for packet generation
		PackGenNum	: Unsigned(15 Downto 0);	--tedade packete in node
		PackSize: Integer :=64

	);
	Port(
		Clk				: In  Std_Logic:='0';
		Reset			: In  Std_Logic;

		FirstTime 		: Buffer Unsigned(ViCh-1 Downto 0);

		OutpData		: Out SignedArrDW(ViCh-1 downto 0);--(DataWidth-1 downto 0);
		OutpEn			: Buffer Unsigned(ViCh-1 downto 0);
		OutpReady		: In  Unsigned(ViCh-1 downto 0);
		CreditIn		: In  Unsigned(ViCh-1 downto 0);
		Sel				: In Unsigned(ViChAddr-1 Downto 0);

		--CNOutpData		: Out Signed(DataWidth-1 downto 0);
		--CNOutpEn		: Out Std_Logic;

		SentCnt			: Buffer Unsigned(15 Downto 0);
		ReadFin			: Out Boolean;
		Stop			: In Boolean
	);
End;


Architecture Behavioral of ReaderV is


Constant PoissonWidth : Integer := 14; --2**14=16000
Constant TimeOffset : Integer := PackSize; --4;


signal DataPoisson:	IntVectorNx1(ViCh-1 Downto 0);
signal DataUniform:	IntVectorNx1(ViCh-1 Downto 0);
signal DataOutputPort:	IntVectorNx1(ViCh-1 Downto 0);
signal DataPackLen:	IntVectorNx1(ViCh-1 Downto 0);
Signal TimeSum:	Integer;
Signal CNLTCounter:	Integer;
signal ReadFin1:	boolean;
signal ReadFin2:	boolean;
signal ReadFin3:	boolean;				--Look Ahead Routing Information: Initial Output port
signal ReadFin4:	boolean;				-- Packet Length = 0 or 1 (short or long)
Signal Counter :  UnsignedArr3(ViCh-1 Downto 0); -- (PoissonWidth-1 Downto 0);
Signal Receiver :  IntVector(ViCh-1 Downto 0);
Signal LARinfo :  IntVector(ViCh-1 Downto 0);
Signal PackLen :  UnsignedArr3(ViCh-1 Downto 0);
Signal PrePackLen :  UnsignedArr3(ViCh-1 Downto 0);
Signal PackLenTemp :  UnsignedArr3(ViCh-1 Downto 0);
Signal TimeCounter :  Unsigned(31 Downto 0);
Signal LTCounter :  UnsignedArr32(ViCh-1 Downto 0);
Signal Data :  SignedArrDW(ViCh-1 Downto 0);--(DataWidth-1 Downto 0);
Signal Rec :  SignedArrDW(ViCh-1 Downto 0);--(DataWidth-1 Downto 0);
signal OutpEnPoisson:	Unsigned(ViCh-1 Downto 0);
signal OutpEnUniform:	Unsigned(ViCh-1 Downto 0);
signal OutpEnOutputPort:Unsigned(ViCh-1 Downto 0);		--Look Ahead Routing Information: Initial Output port
signal OutpEnPackLen:	Unsigned(ViCh-1 Downto 0);		-- Packet Length = 0 or 1 (short or long)
signal ReadF,PreReadF :	std_logic;
signal ReadFI,PreReadFI:Unsigned(ViCh-1 Downto 0);
--Signal FirstTime : Unsigned(ViCh-1 Downto 0);
Signal PackCnt : Unsigned(15 Downto 0);
Signal ReadPackCnt : Unsigned(15 Downto 0);
Signal DisableSend	: Unsigned(ViCh-1 Downto 0);
Signal is_sending	: Unsigned(ViCh-1 Downto 0);
Signal is_read		: Unsigned(ViCh-1 Downto 0);
signal sending		:	std_logic;

Signal VCBuffStatus	: UnsignedArr3(ViCh-1 downto 0);

--Signal OutpReady	:  Unsigned(ViCh-1 downto 0);

--Signal	CNOutpData		: Signed(DataWidth-1 downto 0);
--Signal	CNOutpEn		: Std_Logic;

Begin

	OutpData <= Data;

	ReadFin <= ReadFin1 And ReadFin2 And ReadFin3 And ReadFin4;

	--OutpReady <= To_Unsigned(2**To_Integer(Sel),ViCh);

	Process (Clk)

	Variable VCBuffStatVar	: UnsignedArr3(ViCh-1 downto 0);

		Begin
			If (Rising_Edge(Clk)) Then
				If (Reset='1') Then
					VCBuffStatus <= (Others => To_Unsigned(5,3));
				Else
					VCBuffStatVar	:=	VCBuffStatus;
					For i In 0 To ViCh-1 Loop

						--If (OutpEn(i)='1' And OutpReady(i)='1') Then
						If (OutpEn(i)='1' And i = To_Integer(Sel)) Then
							VCBuffStatVar(i) := VCBuffStatVar(i) - 1;
						End If;
						If (CreditIn(i)='1') Then
							VCBuffStatVar(i) := VCBuffStatVar(i) + 1;
						End If;
					End Loop;
					VCBuffStatus	<=	VCBuffStatVar;
				End If;
			End If;
	End Process;


	Process (Clk)
		Begin
			If (Rising_Edge(Clk)) Then
				If (Reset='1') Then
					TimeCounter <= (Others=>'0');
				Else
					TimeCounter <= TimeCounter + 1;
				End If;
			End If;
	End Process;


	fr1: ReadFileV1(Len			=> ViCh,
					FileName	=> InpFilePoisson,
					Clock		=> Clk,
					ReadEn		=> ReadF,
					ReadEnI		=> ReadFI,
					Stop		=> Stop,
					Output		=> DataPoisson,
					Finished	=> ReadFin1,
					DataValid	=> OutpEnPoisson);

	fr2: ReadFileV1(Len			=> ViCh,
					FileName	=> InpFileUniform,
					Clock		=> Clk,
					ReadEn		=> ReadF,
					ReadEnI		=> ReadFI,
					Stop		=> Stop,
					Output		=> DataUniform,
					Finished	=> ReadFin2,
					DataValid	=> OutpEnUniform);

	fr3: ReadFileV1(Len			=> ViCh,
					FileName	=> InpFileLARinfo,
					Clock		=> Clk,
					ReadEn		=> ReadF,
					ReadEnI		=> ReadFI,
					Stop		=> Stop,
					Output		=> DataOutputPort,
					Finished	=> ReadFin3,
					DataValid	=> OutpEnOutputPort);

	fr4: ReadFileV1(Len			=> ViCh,
					FileName	=> InpFilePackLen,
					Clock		=> Clk,
					ReadEn		=> ReadF,
					ReadEnI		=> ReadFI,
					Stop		=> Stop,
					Output		=> DataPackLen,
					Finished	=> ReadFin4,
					DataValid	=> OutpEnPackLen);

	SentCnt <= PackCnt;


	Process(Clk)
	Variable TimeSumVar : Integer;
	Variable CntLTVar : Integer;
	Variable PrePackLenVar : Integer;

	Begin
		If Rising_Edge(Clk) Then
			If (Reset='1') Then
				Counter <= (Others=>(Others=>'0'));
				--
				ReadFI 		<= (Others=>'0');
				FirstTime 	<= (Others=>'1');
				Receiver <= (Others=>0);
				LARinfo	<= (Others=>0);

				PackLen	<= (Others=>(to_unsigned(1,3)));
				TimeSum <= PackSize+2;
				CNLTCounter <=	PackSize+2;
				PackCnt 	<=	(Others=>'0');
				ReadPackCnt	<=	(Others=>'0');
				DisableSend <=	(Others=>'0');
				is_read		<=	(Others=>'0');

			Else

				For i In 0 To ViCh-1 Loop

					If (FirstTime(i)='0')Then

						If (to_integer(Counter(i)) >= to_integer(PackLenTemp(i))) Then

							If (TimeCounter  >= LTCounter(i)-1) And ReadFI(i)='0' And PreReadFI(i)='0' And is_read(i)= '1' Then
								Counter(i) <= (Others=>'0');
								is_read(i)<= '0';
							End If;

							If (PackCnt=PackGenNum-1) And (sending='1') Then
								Counter(i)	<=	PackLenTemp(i);
								DisableSend(i)	<=	'1';
							End IF;

							If (PackCnt>=PackGenNum)  Then
								Counter(i)	<=	PackLenTemp(i);
								DisableSend(i)	<=	'1';
							End IF;

						Elsif (OutpReady(i)='1' And DisableSend(i)='0') Then

							Counter(i) <= Counter(i)+1;

							If (Counter(i)=PackLenTemp(i)-1) And (FirstTime(i)='0') And (PackGen='1') Then
								PackCnt <= PackCnt+1;
							End If;


						End IF;

					Elsif (OutpReady(i)='1') And (FirstTime(i)='1')Then

							Counter(i) <= Counter(i)+1;
					End If;

				End Loop;

				PreReadF <= ReadF;
				TimeSumVar := TimeSum;
				CntLTVar	:=	CNLTCounter;
				For i In 0 To ViCh-1 Loop
					If (OutpReady(i)='1')  Or (ReadFI(i)='1') Then
						ReadFI(i) <= '0';

						If (Counter(i)=0) And (ReadFI(i)='0') And (ReadPackCnt<PackGenNum) Then
							ReadFI(i) <= '1';
							is_read(i)<= '1';

								ReadPackCnt	<=	ReadPackCnt + 1;

						End If;

						If (Counter(i)=0) Then			--*************************
							FirstTime(i) <= '0';
						End If;
					End If;
					---------------------
					PreReadFI(i) <= ReadFI(i);
					If (PreReadFI(i)='1') Then
						If (OutpEnPoisson(i)='1') Then -- not necessary
							TimeSumVar := TimeSumVar + DataPoisson(i)(1);
							LTCounter(i) <= To_Unsigned(TimeSumVar,32);
						End If;
						If (OutpEnUniform(i)='1') Then -- not necessary
							Receiver(i) <= DataUniform(i)(1);
						End If;
						If (OutpEnOutputPort(i)='1') Then -- not necessary
							LARinfo(i) <= DataOutputPort(i)(1);
						End If;
						If (OutpEnPackLen(i)='1') Then -- not necessary		***********************
							--PackLen(i) <= DataPackLen(i)(1);
							PackLen(i) <= to_unsigned(DataPackLen(i)(1),1) & to_unsigned(1,2);
							PrePackLen(i)	<=	PackLen(i);
							PrePackLenVar	:=	To_Integer(PackLen(i));
						End If;

						If ((PrePackLenVar)>DataPoisson(i)(1)) Then

							CntLTVar :=	TimeSumVar + ((PrePackLenVar) - DataPoisson(i)(1));
						Else
							CntLTVar :=	TimeSumVar;
						End If;

						--If (CntLTVar>=TimeSumVar) Then
						--	If ((PrePackLenVar)>DataPoisson(i)(1)) Then
						--
						--		CntLTVar :=	CntLTVar + DataPoisson(i)(1) + ((PrePackLenVar) - DataPoisson(i)(1));
						--	Else
						--		CntLTVar :=	CntLTVar + DataPoisson(i)(1);
						--	End If;
						--Else
						--	If ((PrePackLenVar)>DataPoisson(i)(1)) Then
						--
						--		CntLTVar :=	TimeSumVar + ((PrePackLenVar) - DataPoisson(i)(1));
						--	Else
						--		CntLTVar :=	TimeSumVar ;
						--	End If;
						--End If;
					End If;
				End Loop;
				TimeSum <= TimeSumVar;
				CNLTCounter	<=	CntLTVar;

			End If;
		End If;
	End Process;

--	========================== VCs are sending ===================================
	Process(is_sending)
		Variable is_sendingVar : Std_Logic;
	Begin
		is_sendingVar := '0';
		For i In 0 To ViCh-1 Loop
			is_sendingVar := is_sendingVar Or is_sending(i);

		End Loop;
		sending <= is_sendingVar;
	End Process;
--	==============================================================================

	Process(Counter,LTCounter,Receiver,FirstTime,ReadFI)

	Variable ReadFVar : Std_Logic;
	Begin
		ReadFVar := '0';
		For i In 0 To ViCh-1 Loop
			If (Counter(i)=0) Then
				-- 05, Aug 2006 topology globalization by D.R.
				--Data(i) <= To_Signed(Receiver(i),DataWidth) Mod ColNo; --x
				Data(i) <= 	to_signed(0,DataWidth-72) &
							to_signed(Receiver(i),8) &
							Signed(LTCounter(i)(31 Downto 24)) &
							Signed(LTCounter(i)(23 Downto 16)) &
							Signed(LTCounter(i)(15 Downto 8)) &
							Signed(LTCounter(i)(7 Downto 0)) &


							to_signed(0, 2) & to_signed(i, 3) & to_signed(LARinfo(i),3) &		--	26 Downto 24	LAR Info
							to_signed(CurNode,8) 		& 								--	23 Downto 16	Src	 Node
							to_signed(Receiver(i),8)	&								--	15 Downto 8		Dest Node
							to_signed(0, 2) & Signed(PackLen(i)) &	to_signed(0,3);		-- Header type

				PackLenTemp(i) <= PackLen(i);
			Elsif (Counter(i)=1) Then
				Data(i) <= to_signed(0,DataWidth-6) & Signed(PackLen(i)) & to_signed(1,3);
			Elsif (Counter(i)=2) Then
				Data(i) <= to_signed(0,DataWidth-6) & Signed(PackLen(i)) & to_signed(2,3);

			Elsif (Counter(i)=3) Then
				Data(i) <= to_signed(0,DataWidth-6) & to_signed(5,3) & to_signed(3,3);
			Elsif (Counter(i)=4) Then
				Data(i) <= to_signed(0,DataWidth-6) & to_signed(5,3) & to_signed(4,3);

			End If;



			If ((Counter(i)>=0) And (Counter(i) <= to_integer(PackLenTemp(i))-1) And (FirstTime(i)='0') And (DisableSend(i)='0') And (PackGen='1')) Then
				OutpEn(i) <= '1';
				is_sending(i) <= '1';
			Else
				OutpEn(i) <= '0';
				is_sending(i) <= '0';
			End If;

			ReadFVar := ReadFVar Or ReadFI(i);

		End Loop;
		ReadF <= ReadFVar;
	End Process;
--	================================= Control Network Packet Injection ========================
	--Process(Counter,OutpEn,OutpReady)
	--Begin
	--	--CNOutpData	<=	(Others=>'Z');
	--	--CNOutpEn	<=	'0';
	--
	--	For i In 0 To ViCh-1 Loop
	--
	--		If (OutpEn(i)='1' And OutpReady(i)='1' And Counter(i)=0) Then
	--
	--			CNOutpData	<=	to_signed(0,DataWidth-72) &
	--						to_signed(Receiver(i),8) &
	--						Signed(LTCounter(i)(31 Downto 24)) &
	--						Signed(LTCounter(i)(23 Downto 16)) &
	--						Signed(LTCounter(i)(15 Downto 8)) &
	--						Signed(LTCounter(i)(7 Downto 0)) &
	--
	--
	--						to_signed(0, 2) & to_signed(i, 3) & to_signed(LARinfo(i),3) &		--	26 Downto 24	LAR Info
	--						to_signed(CurNode,8) 		& 								--	23 Downto 16	Src	 Node
	--						to_signed(Receiver(i),8)	&								--	15 Downto 8		Dest Node
	--						to_signed(0, 2) & to_signed(1, 3) &	to_signed(0,3);		-- Header type
	--			CNOutpEn	<=	'1';
	--		End If;
	--
	--	End Loop;
	--End Process;
End;

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;
use work.FilePack.all;

use STD.textio.all;                     -- basic I/O
use IEEE.std_logic_textio.all;          -- I/O for logic types

entity Writer is
	generic(
		OutpFilePack	: String  := "Outp.txt";
		OutpFileTime	: String  := "TimeOutp.txt";
		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 1;
		--
		--X			: Integer := 0;
		--Y			: Integer := 0;
		CurNode		: Integer := 0;
		PackWidth	: Integer := 8; -- bit of pack size
		PackGen		: std_logic :='1';
		PackGenNum	: Unsigned(15 Downto 0);
		PackSize: Integer :=64

	);
	Port(
		Clk				: In  Std_Logic:='0';
		Reset			: In  Std_Logic;

		InpData			: In  Signed(DataWidth-1 downto 0);
		InpEn			: In  Std_Logic;
		InpReady		: Out Std_Logic;

		ReceCnt			: Buffer Unsigned(15 Downto 0);
		AveReceTime		: Out Unsigned(19 Downto 0);
		SumTimeData		: Buffer Integer;
		Number			: Buffer Integer;
		WriteFin		: Out Boolean;
		Stop			: In Boolean
	);
End;


Architecture Behavioral of Writer is

Constant TimeOffset : Integer := 3;
Constant IgnorePercent :Integer :=RecePackIgnorePercent/ViCh; --20%
signal SaveData:	IntVector(1 to 6);
signal TData:	IntVector(1 to 3);
Signal TimeData:	Integer;
Signal TimeDataTemp:	Integer;
--Signal SumTimeData:	Integer;
--Signal Number:	Integer:=1000000;
signal WriteTime, LogWriteTime:	std_logic;
signal WriteFin1:	boolean;
signal WriteFin2:	boolean;
Signal InpPackCounter :	Unsigned(PackWidth-1 Downto 0);
Signal TimeCounter :  	Unsigned(31 Downto 0);
signal PreInpEn:		std_logic;
Signal PackFinishedFlag : Std_Logic:='0';
Signal IgnoreNum :Integer ;
Signal RecNode,SrcNode,ErrNo, PackLen, VC_number, ReceivedCnt :Integer ;
Begin

	WriteFin <= WriteFin1 And WriteFin2;
	Process (Clk)
		Begin
			If (Rising_Edge(Clk)) Then
				If (Reset='1') Then
					TimeCounter <= (Others=>'0');
				Else
					TimeCounter <= TimeCounter + 1;
				End If;
			End If;
	End Process;


		fw1: WriteFile2(WriteActive => DumpTimePackFile,
						FileName	=> OutpFilePack,
						Clock		=> Clk,
						WriteEn		=> LogWriteTime,--InpEn,
						Stop		=> Stop,
						Input		=> SaveData,
						Finished	=> WriteFin1);

		fw2: WriteFile2(WriteActive => DumpTimePackFile,
						FileName	=> OutpFileTime,
						Clock		=> Clk,
						WriteEn		=> WriteTime,
						Stop		=> Stop,
						Input		=> TData,
						Finished	=> WriteFin2);

		SaveData(1)	<=	ReceivedCnt+1;
		SaveData(2)	<=	SrcNode;
		SaveData(3)	<=	RecNode;
		SaveData(4)	<=	VC_number;
		SaveData(5)	<=	PackLen;
		SaveData(6)	<=	TimeData;
		--SaveData(6)	<=	To_Integer(TimeCounter);
		--TData(1) <= TimeData;
		TData(1) <= TimeDataTemp;
		TData(2) <= SumTimeData;
		IgnoreNum <= To_Integer((IgnorePercent*PackGenNum)/100);
		Number <= (To_Integer(ReceCnt)-IgnoreNum) When (ReceCnt>((IgnorePercent*PackGenNum)/100)) Else 0;
		TData(3) <= SumTimeData/Number When (Number/=0) Else 0;
		AveReceTime <= To_Unsigned(SumTimeData/Number,20) When (Number/=0) Else (Others=>'0');
		InpReady <= '1';

		ReceivedCnt	<=	To_Integer(ReceCnt);

		LogWriteTime	<=	'1' When (PreInpEn='1' And InpPackCounter=PackLen-1) Else '0';
		------
		------
		--End Process;
		Process (Clk)
        variable my_line : line;
		Begin
			If (Rising_Edge(Clk)) Then
				If (Reset='1') Then
					InpPackCounter <= (Others=>'0');
					WriteTime <= '0';

					SumTimeData <= 0;
					--
					ReceCnt	<= (Others=>'0');
					ErrNo <= 0;
					PackLen <= 1;
				Else
					PreInpEn <= InpEn;
					--after bug 2
					PackFinishedFlag <='0';
					--
					If (InpEn='1') Then
						InpPackCounter <= InpPackCounter + 1;

						If(InpPackCounter>=PackLen-1) Then
							InpPackCounter <= (Others=>'0');
							PackFinishedFlag<='1';
						End If;
						-- added by R.Hojabr:
						If(InpPackCounter=0) Then

							If (InpData(2)='0' And InpData(1)='0' And InpData(0)='0') Then		--	The incoming flit is a header flit
								TimeData	<=	to_integer(Unsigned(InpData(63 Downto 32)));
								SrcNode		<=	to_integer(Unsigned(InpData(23 Downto 16)));
								RecNode		<=	to_integer(Unsigned(InpData(15 Downto 8)));
								PackLen		<=	to_integer(Unsigned(InpData(5 Downto 3)));
								VC_number	<=	to_integer(Unsigned(InpData(29 Downto 27)));

								IF (InpData(5)='1') Then					-- If incoming packet is a long packet (it has 5 flits)
									InpPackCounter <= InpPackCounter + 1;
								Else										-- If incoming packet is a short packet (it has 1 flit)
									InpPackCounter <= (Others=>'0');
								End If;
							End If;

						End If;

					End If;

					--If(InpPackCounter>=PackLen-1 And PackLen>1) Then
					--If(InpPackCounter>=PackLen-1 And InpEn='0') Then
					--		InpPackCounter <= (Others=>'0');
					--		--PackFinishedFlag<='1';
					--End If;

					WriteTime <= '0';


					If ((PreInpEn='1' And InpPackCounter=PackLen-1 And PackLen=1) Or (InpEn='1' And InpPackCounter=PackLen-1 And PackLen>1)) Then		--***************

						WriteTime <= '1';
						--
						ReceCnt <= ReceCnt +1;

						If (PackLen>1) Then
							TimeDataTemp	<=	to_integer(TimeCounter)-TimeData;
							SumTimeData <= SumTimeData+to_integer(TimeCounter)-TimeData;
						Else
							TimeDataTemp	<=	to_integer(TimeCounter)-TimeData;
							SumTimeData <= SumTimeData+to_integer(TimeCounter)-TimeData-1;
						End If;

						--TimeDataTemp	<=	to_integer(TimeCounter)-TimeData;
						--SumTimeData <= SumTimeData+to_integer(TimeCounter)-TimeData-1;


						If(ReceCnt<(IgnorePercent*PackGenNum)/100) Then
							SumTimeData <= 0;
						End IF;
						--
						If (CurNode/=RecNode) Then


							write(my_line, string'("Error Code 10, SCD:"));   -- formatting
               				write(my_line, SrcNode);   -- formatting
							write(my_line, string'(","));   -- formatting
               				write(my_line, CurNode);   -- formatting
							write(my_line, string'(","));   -- formatting
               				write(my_line, RecNode);   -- formatting
               				writeline(output, my_line);               -- write to "output"
               				ErrNo <= ErrNo+1;
               				If(ErrNo>=3) Then
								assert false report "Simulation Failure" severity failure;
							End if;
						End If;
					End If;
				End If;
			End If;
		End Process;
End;

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;

entity PEDeMux is
	generic(
		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		Sel			: In  Unsigned(ViChAddr-1 Downto 0);

		InpData		: In  Signed(DataWidth-1 downto 0);
		InpEn		: In  Std_Logic;
		InpReady	: Out Unsigned(ViCh-1 downto 0); --Std_Logic;

		OutpData	: Out SignedArrDW(ViCh-1 downto 0); --? DataWidth=8
		OutpEn		: Out Unsigned(ViCh-1 downto 0);
		OutpReady	: In  Unsigned(ViCh-1 downto 0)
	);
End;


Architecture behavioral of PEDeMux is
Begin

	Process(Sel,Reset,OutpReady,InpData,InpEn)
	Begin
		If (Reset='1') Then
			InpReady <= (Others=>'0');
			OutpData <= (Others=>(Others=>'0'));
			OutpEn <= (Others=>'0');
		Else
			For i In 0 To ViCh-1 Loop
				InpReady(i) <= OutpReady(i);
				OutpData(i) <= (Others=>'Z');
				OutpEn(i) <= '0';
				If (Sel=i) Then
					OutpData(i) <= InpData;
					OutpEn(i) <= InpEn;
				End If;
			End Loop;
		End If;
	End Process;

End;

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity Selector is --a324
	generic(
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		Sel		: Buffer Unsigned(ViChAddr-1 Downto 0):=(Others=>'0');
		FirstTime	: In Unsigned(ViCh-1 Downto 0);
		InpEn		: In  Unsigned(ViCh-1 downto 0);
		OutpReady	: In  Unsigned(ViCh-1 downto 0)
	);
End;


Architecture behavioral of Selector is

Begin


	--Process (Clk)
	Process (InpEn,OutpReady)
	Variable Assigned : Std_Logic;
	Variable SelV, cnt : Integer;
	Variable VarSel		: Unsigned(ViChAddr-1 Downto 0);
	Begin

		--If (Rising_Edge(Clk)) Then
			If (Reset='1') Then
				Sel <= (Others=>'0');
			Else

				PE_MuxSelector(
								VarSel	,

								Sel		,
								FirstTime,
								InpEn	,
								OutpReady	);
				Sel	<=	VarSel;
			End If;
		--End If;
	End Process;
End;



Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;

entity PEMux is
	generic(
		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		Sel			: Buffer Unsigned(ViChAddr-1 Downto 0);

		FirstTime	: In Unsigned(ViCh-1 Downto 0);

		InpData		: In  SignedArrDW(ViCh-1 downto 0); --? DataWidth=8
		InpEn		: In  Unsigned(ViCh-1 downto 0);
		InpReady	: Out Unsigned(ViCh-1 downto 0);

		OutpData	: Out Signed(DataWidth-1 downto 0);
		OutpEn		: Out Std_Logic;
		OutpReady	: In  Unsigned(ViCh-1 downto 0) --Std_Logic
	);
End;


Architecture behavioral of PEMux is
Signal Sel_Int	:	Unsigned(ViChAddr-1 Downto 0);
Signal req		:	Unsigned(ViCh-1 Downto 0);


Begin


	Process(Sel_Int,Reset,OutpReady)
	Variable Tmp : Integer;
	Begin
		If (Reset='1') Then
			InpReady <= (Others=>'0');
		Else
			For i In 0 To ViCh-1 Loop
				InpReady(i) <= '0';
				If (Sel_Int=i) Then
					InpReady(i) <= OutpReady(i);
				End If;
			End Loop;
		End If;
	End Process;

	Process (Sel_Int,Reset,OutpReady,InpEn,InpData)
	Begin
		If (Reset='1') Then
			OutpData <= (Others=>'0');
			OutpEn <= '0';
		Else
			OutpData <= (Others=>'Z');
			OutpEn <= '0';
			For i In 0 To ViCh-1 Loop
				If (Sel_Int=i) And (InpEn(i)='1') And (OutpReady(i)='1')Then
				--If (Sel_Int=i) And (InpEn(i)='1') Then
					OutpData <= InpData(i);
					OutpEn <= '1';
				End If;
			End Loop;
		End If;
	End Process;
	Sel <= Sel_Int;



	c1:Entity Work.Selector
		Generic Map(
			ViChAddr	,
			ViCh
		)
		Port Map(
			Clk			,
			Reset		,
			Sel_Int		,
			FirstTime	,
			InpEn		,
			OutpReady
	);
End;

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;
use work.FilePack.all;

entity PEv is
	generic(
		InpFilePoisson	: String  := "Poisson.txt";
		InpFileUniform	: String  := "Uniform.txt";
		InpFileLARinfo	: String  := "LARinfo.txt";		--Look Ahead Routing Information
		InpFilePackLen	: String  := "PackLen.txt";		--Look Ahead Routing Information
		OutpFilePack	: String  := "Outp.txt";
		OutpFileTime	: String  := "TimeOutp.txt";
		DataWidth		: Integer := 8;
		ViChAddr		: Integer := 1;
		ViCh			: Integer := 1;
		--
		--X			: Integer := 0;
		--Y			: Integer := 0;
		CurNode		: Integer := 0;
		PackSize: Integer :=64;
		PackWidth		: Integer := 8; -- bit of pack size
		PackGen			: std_logic :='1';
		PackGenNum		: Unsigned(15 Downto 0)
	);
	Port(
		Clk				: In  Std_Logic:='0';
		Reset			: In  Std_Logic;

		InpData			: In  Signed(DataWidth-1 downto 0);
		InpEn			: In  Std_Logic;
		CreditOut		: Out Unsigned(ViCh-1 downto 0);
		InpSel			: In  Unsigned(ViChAddr-1 downto 0);

		OutpData		: Out Signed(DataWidth-1 downto 0);
		OutpEn			: Buffer Std_Logic;
		OutpReady		: In  Unsigned(ViCh-1 downto 0);
		CreditIn		: In  Unsigned(ViCh-1 downto 0);
		OutpSel			: Buffer Unsigned(ViChAddr-1 downto 0);

		--CNOutpData		: Out Signed(DataWidth-1 downto 0);
		--CNOutpEn		: Out Std_Logic;

		SentCnt			: Out Unsigned(15 Downto 0);
		ReceCnt			: Out Unsigned(15 Downto 0);

		AveReceTime		: Out Unsigned(19 Downto 0);
		StopSim			: In Std_Logic
	);
End;

Architecture behavioral of PEv is

Signal OutpDataArr	: SignedArrDW(ViCh-1 downto 0);
Signal OutpEnArr	: Unsigned(Vich-1 Downto 0);
Signal OutpReadyArr	: Unsigned(Vich-1 Downto 0);

Signal	InpDataArr	: SignedArrDW(ViCh-1 downto 0);
Signal	InpEnArr	: Unsigned(Vich-1 Downto 0);
Signal	InpReadyArr	: Unsigned(Vich-1 Downto 0);

signal Stop			: Boolean;

signal ReadFin		: boolean;
signal WriteFin		: boolean;

Signal ReceCntArr		: UnsignedArr16(ViCh-1 Downto 0);
Signal AveReceTimeArr	: UnsignedArr20(ViCh-1 Downto 0);
Signal SumTimeDataArr	: IntVector(ViCh-1 Downto 0);
Signal NumberArr		: IntVector(ViCh-1 Downto 0);
signal WriteFinArr		: BoolArr(ViCh-1 Downto 0);

Signal FirstTime : Unsigned(ViCh-1 Downto 0);
Begin

Stop <= (StopSim='1') Or (ReadFin And WriteFin);
CreditOut	<=	InpEnArr;
--CreditOut	<=	(Others=>'1');

c1: Entity Work.ReaderV
	Generic Map(
		InpFilePoisson	,
		InpFileUniform	,
		InpFileLARinfo	,
		InpFilePackLen	,

		DataWidth		,
		ViChAddr		,
		ViCh			,
		--
		CurNode			,
		--Y				,
		PackWidth		,
		PackGen			,
		PackGenNum		,
		PackSize
	)

	Port Map(
		Clk				=> Clk			,
		Reset			=> Reset		,

		FirstTime 		=> FirstTime,

		OutpData		=> OutpDataArr	,
		OutpEn			=> OutpEnArr	,
		OutpReady		=> OutpReadyArr	,
		CreditIn		=> CreditIn		,
		Sel				=>	OutpSel,

		--CNOutpData		=>	CNOutpData	,
		--CNOutpEn		=>	CNOutpEn	,

		SentCnt			=> SentCnt		,
		ReadFin			=> ReadFin		,
		Stop			=> Stop
	);

c2: Entity Work.PEMux
		Generic Map(
			DataWidth	,
			ViChAddr	,
			ViCh		 -- 2**ViChAddr
		)
		Port Map(
			Clk		   						,
			Reset	   						,
			OutpSel	   						,

			FirstTime						,

			OutpDataArr 					,
			OutpEnArr	  					,
			OutpReadyArr					,

			OutpData						,
			OutpEn  						,
			OutpReady
	);

mx2: For j in 0 to ViCh-1 Generate

c3: Entity Work.Writer
		Generic Map(
			--Str_Add(16,2,Str_Int_Add2(15,OutpFilePack,j),"--"),
			Str_Int_Add2(15,OutpFilePack,j),
			Str_Int_Add2(15,OutpFileTime,j)	,
			DataWidth		,
			ViChAddr		,
			ViCh			,
			--
			CurNode			,
			--Y				,
			PackWidth		,
			PackGen			,
			PackGenNum		,
			PackSize
		)
		Port Map(
			Clk				=> Clk				,
			Reset			=> Reset			,

			InpData			=> InpDataArr(j)	,
			InpEn			=> InpEnArr(j)		,
			InpReady		=> InpReadyArr(j)	,

			ReceCnt			=> ReceCntArr(j)	,
			AveReceTime		=> AveReceTimeArr(j),
			SumTimeData		=> SumTimeDataArr(j),
			Number			=> NumberArr(j),

			WriteFin		=> WriteFinArr(j)		,
			Stop			=> Stop
	);

End Generate;

Process(ReceCntArr,AveReceTimeArr,WriteFinArr,SumTimeDataArr,NumberArr)
Variable ReceCntVar : Integer;
Variable SumReceTimeVar : Integer;
Variable NumberVar : Integer;
Variable WriteFinVar : Boolean;
Variable ViChNotZero : Integer;
Begin
	ReceCntVar := 0;
	SumReceTimeVar := 0;
	WriteFinVar := True;
	ViChNotZero := ViCh;
	NumberVar := 0;
	For i In 0 To ViCh-1 Loop
			ReceCntVar := ReceCntVar+To_Integer(ReceCntArr(i));
--			AveReceTimeVar := AveReceTimeVar + To_Integer(AveReceTimeArr(i));
			SumReceTimeVar := SumReceTimeVar + SumTimeDataArr(i);
			NumberVar := NumberVar + NumberArr(i);
			WriteFinVar := WriteFinVar And WriteFinArr(i);
	End Loop;
	ReceCnt <= To_Unsigned(ReceCntVar,16);
	If (NumberVar/=0) Then
		AveReceTime <= To_Unsigned(SumReceTimeVar/NumberVar,20);
	Else
		AveReceTime <= (Others=>'0');
	End If;
	WriteFin <= WriteFinVar;
End Process;

c4: Entity Work.PEDeMux
		Generic Map(
			DataWidth	,
			ViChAddr	,
			ViCh		 -- 2**ViChAddr
		)
		Port Map(
			Clk			,
			Reset		,
			InpSel		,

			InpData		,
			InpEn		,
			Open	,

			InpDataArr	,
			InpEnArr	,
			InpReadyArr
	);
End;
