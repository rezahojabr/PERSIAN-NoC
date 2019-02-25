-- PERSIAN-NoC
-- PERformance SImulation Architecture for Networks-on-chip
-- Version: 3.0
-- Last Update: 2019/02/25
-- High Performance Network Laboratory
-- School of Electrical and Computer Engineering
-- University of Tehran,
-- Author: Reza Hojabr

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity FIFO is--a320
	generic(InAddrLen: integer :=10;
			OutDataLen: integer :=4;
			Out2InAddrLen: integer :=0;
			VC_Buffer_Depth: integer :=5	-- 2**3 = 8 buffers
			);
	port (	Clock: in std_logic;
			Reset: in std_logic;
			Write: in std_logic;
			Read: in std_logic;
			Input : in unsigned(OutDataLen*(2**Out2InAddrLen)-1 downto 0);
			Output : out unsigned(OutDataLen-1 downto 0);
			DataValid : out std_logic;
			Empty : out std_logic;
			Full : out std_logic
		);
end entity;


architecture behavioral of FIFO is

	constant InDataLen : integer := OutDataLen;

	type MemType is array (VC_Buffer_Depth downto 0) of Unsigned(InDataLen-1 downto 0) ;
	signal Mem : MemType;	--For Faster Synthesis

	signal WriteAddr : unsigned(InAddrLen-1 downto 0);--:=(Others=>'0');
	signal ReadAddr : unsigned(InAddrLen-1 downto 0);--:=(Others=>'0');

	signal WriteAddrTemp : unsigned(InAddrLen-1 downto 0):=(Others=>'0');

	signal ReadMAddr : unsigned(InAddrLen-1 downto 0);


	signal EmptyFlag : std_logic;
	signal FullFlag : std_logic;

begin

	Empty <= EmptyFlag;
	Full <= FullFlag;


	FullFlag	<= '1' when ReadAddr=(WriteAddr+1) mod (VC_Buffer_Depth+1) else '0';
	--EmptyFlag	<= '1' when ReadAddr=WriteAddr else '0';




	Output	<= Mem(to_integer(ReadAddr))(OutDataLen-1 downto 0) When (EmptyFlag='0');-- Else (Others=>'Z');

	DataValid <= '1' When (Read='1' and EmptyFlag='0') Else '0';

FIFO: process (Clock)
	begin
		if(rising_edge(Clock)) then

			if(Reset='1') then
				ReadAddr	<= (others=>'0');
				WriteAddr	<= (others=>'0');
				EmptyFlag	<=	'1';
			else

				--if (Write='1' and FullFlag='0') Or (Write='1' and FullFlag='1' And Read='1') then
				if (Write='1') then
					Mem(to_integer(WriteAddr)) <= Input;
					WriteAddr <= (WriteAddr +1) mod (VC_Buffer_Depth+1);
					EmptyFlag <= '0';
				end if;

				if (Read='1') then	-- and EmptyFlag='0'

					ReadAddr <= (ReadAddr +1) mod (VC_Buffer_Depth+1);

					If (Write='0' And WriteAddr = ((ReadAddr +1) mod (VC_Buffer_Depth+1))) Then
						EmptyFlag <= '1';
					End If;
				end if;

			end if;
		end if;
	end process;

end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity flit_latch is--a320
	generic(
			OutDataLen: integer :=4
			);
	port (	Clock: in std_logic;
			Reset: in std_logic;
			Write: in std_logic;
			Read: in std_logic;
			Input : in unsigned(OutDataLen-1 downto 0);
			Output : out unsigned(OutDataLen-1 downto 0);
			Empty : out std_logic
		);
end entity;

architecture behavioral of flit_latch is
	signal EmptyFlag : std_logic;
begin

	Empty <= EmptyFlag;

flit_latch: process (Clock)
	begin
		if(rising_edge(Clock)) then

			if(Reset='1') then

				EmptyFlag	<=	'1';
			else

				EmptyFlag	<=	(Not Write) And (Read Or EmptyFlag);

				if (Write='1') then
					Output <= Input;
				end if;
			end if;
		end if;
	end process;
end;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Latch is
	generic(
			DataWidth	: integer := 128;			-- DataWidth = 128bit
			ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port (	Clock		: in std_logic;
			Reset		: in std_logic;
			InpEn		: in std_logic;
			InpData		: in signed(DataWidth-1 downto 0);
			OutpData	: out signed(DataWidth-1 downto 0);
			OutpEn		: Out	std_logic
		);
end entity;

architecture behavioral of Latch is
begin
	latch: process (Clock)
	begin
		If(rising_edge(Clock)) then

			if(Reset='1') then
				OutpData 	<= (others=>'0');
				OutpEn		<= '0';

			else
				if InpEn='1' then
					OutpData <= InpData;
					OutpEn	 <= InpEn;
				End If;

			End If;
		End If;
	end process;
end;


Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity Combiner is --a321
	generic(
		offset	: Integer := 0
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		PackCounter : In  Unsigned(PackWidth-1 Downto 0);
		--ValidPack	: In 	std_logic;

		NextHopLRA	: In  signed(2 downto 0);				--Modified by R.Hojabr
		InpData		: In  Signed(DataWidth-1 Downto 0);
		InpEn		: In  Std_Logic;

		OutpData	: Out Signed(DataWidth-1 Downto 0);
		OutpEn		: Out Std_Logic
	);
End;


Architecture behavioral of Combiner is
Begin

	OutpData 	<= (InpData(DataWidth-1 Downto 27) & NextHopLRA(2 downto 0)	& InpData(23 Downto 0)) When ((PackCounter = offset) ) Else InpData;

	OutpEn 		<= InpEn;

End;




Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity DeMux is --a322
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

		OutpData	: Out SignedArrDW(ViCh-1 downto 0);
		OutpEn		: Out Unsigned(ViCh-1 downto 0)

	);
End;


Architecture behavioral of DeMux is
Begin
	Process(Sel,Reset,InpData,InpEn)
	Begin
		If (Reset='1') Then

			OutpData <= (Others=>(Others=>'0'));
			OutpEn <= (Others=>'0');
		Else
			For i In 0 To (ViCh-1) Loop

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

entity Arbiter is --a323
	generic(

		ViChAddr		: Integer := 1;
		PhyRoChAddr		: Integer := 2+1;
		CurNode			: Integer := 0;
		--

		ViCh			: Integer := 1;
		PhyRoCh			: Integer := 4+1
	);
	port(
		Clk				: In  std_logic;
		Reset			: In  Std_logic;

		DestNode		: In  SignedArr8(PhyRoCh*ViCh-1 downto 0);
		SrcNode			: In  SignedArr8(PhyRoCh*ViCh-1 downto 0);
		LARinfo			: In  SignedArr3(PhyRoCh*ViCh-1 downto 0);
		NextHopLARinfo	: In  SignedArr3(PhyRoCh*ViCh-1 downto 0);
		VC_number		: In  SignedArr3(PhyRoCh*ViCh-1 downto 0);
		PackLen			: In  signedArr3(PhyRoCh*ViCh-1 downto 0);		-- Packet Length: '1' ==> 5-flit (Long)	'0' ==> 1-flit (Short)
		ValidHeader		: In  Unsigned(PhyRoCh*ViCh-1 downto 0);

		CreditIn		: In  Unsigned(PhyRoCh*ViCh-1 downto 0);

		PackCounter		: In  UnsignedArrPW(PhyRoCh*ViCh-1 downto 0);

		PackOutPhCh		: Buffer UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
		SwitchPorts		: Buffer UnsignedArr3(PhyRoCh-1 downto 0);

		InpChAssigned	: Buffer Unsigned(PhyRoCh*ViCh-1 downto 0);
		OutpChBusy		: Buffer Unsigned(PhyRoCh-1 downto 0);

		NextHopLAR		: Buffer SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr

		CmbOutpEn		: In  Unsigned(PhyRoCh*ViCh-1 downto 0);
		Mux_Select		: Buffer UnsignedArrVCA(PhyRoCh-1 downto 0);
		OutpSel			: Buffer UnsignedArrVCA(PhyRoCh-1 downto 0)

	);
End;


Architecture behavioral of Arbiter is

Signal	losed_arbitration	:	Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	losed_Receiver		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
Signal	losed_ExtData		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
Signal	losed_LRAinfo		:	SignedArr3(PhyRoCh*ViCh-1 downto 0);
Signal	losed_NextHopLRAinfo:	SignedArr3(PhyRoCh*ViCh-1 downto 0);



Signal	StalledPhCh			:	UnsignedArr3(PhyRoCh*ViCh-1 downto 0);

Signal	StalledPacks		:	Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal	VCAssignedBusy		:	Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal	VCBuffStatus	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);

Begin



	Process (Clk)

	Variable	VarPackOutPhCh	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
	Variable	VarStalledPhCh	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);

	Variable	VarInpChAssigned: Unsigned(PhyRoCh*ViCh-1 downto 0);
	Variable	VarStalledPacks : Unsigned(PhyRoCh*ViCh-1 downto 0);
	Variable	VarVCAssigned	: Unsigned(PhyRoCh*ViCh-1 downto 0);
	Variable	VarVCBuffStat	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
	--Variable	VarCmbData		: SignedArrDW(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
	Variable	VarOutpChBusy	: Unsigned(PhyRoCh-1 downto 0);
	Variable	VarMux_Select	: UnsignedArrVCA(PhyRoCh-1 downto 0);

	Variable	VarNextHopLAR	: SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr

	Variable	losed_arbitration_Out	:	Unsigned(PhyRoCh*ViCh-1 downto 0);
	Variable	losed_Receiver_Out		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
	Variable	losed_ExtData_Out		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
	Variable	losed_LRAinfo_Out		:	SignedArr3(PhyRoCh*ViCh-1 downto 0);
	Variable	losed_NextHopLRAinfo_Out:	SignedArr3(PhyRoCh*ViCh-1 downto 0);

	Variable	VarOutpSel		: UnsignedArrVCA(PhyRoCh-1 downto 0);
	Variable	VarSwitchPorts	: UnsignedArr3(PhyRoCh-1 downto 0);
	Begin
		If (Rising_Edge(Clk)) Then

			RoutingMechanism(
							VarPackOutPhCh	,
							VarStalledPhCh	,

							VarInpChAssigned,
							VarStalledPacks	,
							VarVCAssigned	,
							VarVCBuffStat	,

							VarNextHopLAR	,
							VarOutpChBusy	,
							VarMux_Select	,
							VarOutpSel		,
							VarSwitchPorts	,

							losed_arbitration_Out	,
							losed_Receiver_Out		,
							losed_ExtData_Out		,
							losed_LRAinfo_Out		,
							losed_NextHopLRAinfo_Out,

							losed_arbitration	,
							losed_Receiver		,
							losed_ExtData		,
							losed_LRAinfo		,
							losed_NextHopLRAinfo,

							Reset			,
							InpChAssigned	,
							StalledPacks	,
							VCAssignedBusy	,
							VCBuffStatus	,
							OutpChBusy 		,
							Mux_Select		,
							CurNode			,
							DestNode		,
							SrcNode			,

							LARinfo			,
							--NextHopLAR		,
							NextHopLARinfo	,
							VC_number		,
							PackLen			,
							ValidHeader		,

							CmbOutpEn		,
							CreditIn		,

							PackCounter		,
							PackOutPhCh		,
							StalledPhCh		);


		PackOutPhCh	  	<=	VarPackOutPhCh		;
		StalledPhCh		<=	VarStalledPhCh		;

		InpChAssigned 	<=	VarInpChAssigned 	;
		StalledPacks	<=	VarStalledPacks		;
		VCAssignedBusy	<=	VarVCAssigned		;
		VCBuffStatus	<=	VarVCBuffStat		;
		--CmbData		<=    VarCmbData		;	--modified by R.Hojabr
		NextHopLAR		<=	VarNextHopLAR		;
		OutpChBusy	  	<=	VarOutpChBusy		;
		Mux_Select		<=	VarMux_Select		;

		OutpSel			<=	VarOutpSel			;
		SwitchPorts		<=	VarSwitchPorts		;

		losed_arbitration	<=	losed_arbitration_Out	;
		losed_Receiver		<=	losed_Receiver_Out		;
		losed_ExtData		<=	losed_ExtData_Out		;
		losed_LRAinfo		<=	losed_LRAinfo_Out		;
		losed_NextHopLRAinfo<=	losed_NextHopLRAinfo_Out;

		End If;
	End Process;

End;


Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity SW_Mux is
	generic(
		DataWidth	: Integer := 8;
		PhyRoCh		: Integer := 4+1
	);
	port(
		Sel_in		: In Unsigned(2 Downto 0);

		InpData		: In  SignedArrDW(PhyRoCh-1 downto 0);
		InpEn		: In  Unsigned(PhyRoCh-1 downto 0);

		OutpData	: Out Signed(DataWidth-1 downto 0);
		OutpEn		: Out Std_Logic;
		OutpChBusy	: In Std_Logic

	);
End;

Architecture behavioral of SW_Mux is
Begin

	OutpData	<= InpData(To_Integer(Sel_in));--	When OutpChBusy='1';
	OutpEn 		<= InpEn(To_Integer(Sel_in))	When OutpChBusy='1'	Else '0';
End;





Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity OptimizedSwitch is -- optimized switch
	generic(
		PhyRoCh		: Integer := 4+1
	);
	port(
		InpData		: In  SignedArrDW(PhyRoCh-1 downto 0);
		InpEn		: In  Unsigned(PhyRoCh-1 downto 0);

		OutpData	: Out SignedArrDW(PhyRoCh-1 downto 0);
		OutpEn		: Out Unsigned(PhyRoCh-1 downto 0);

		PackOutPhCh	: In UnsignedArr3(PhyRoCh-1 downto 0);
		OutpChBusy	: In Unsigned(PhyRoCh-1 downto 0)
	);
End;


Architecture behavioral of OptimizedSwitch is
Begin
	SWMux:	For i in 0 to PhyRoCh-1 Generate
		SWM: entity work.SW_Mux
			generic map(
				DataWidth	=>	128,
				PhyRoCh		=>	PhyRoCh
						)
				port map(
						Sel_in		=>	PackOutPhCh(i),

						InpData		=>	InpData	,
						InpEn		=>	InpEn	,

						OutpData	=>	OutpData(i),
						OutpEn		=>	OutpEn(i),
						OutpChBusy	=>	OutpChBusy(i)
			);
	End Generate;
End;


Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity RouteComputationUnit is -- optimized switch
	generic(
		DataWidth	: Integer := 128;
		RowColLog	: Integer := 2;
		RowColLog2	: Integer := 4;
		CurNode		: Integer := 0
	);
	port(
		LARinfoOut		: Out Unsigned(2 Downto 0);

		Destination		: Unsigned(7 downto 0);
		LARinfoIn		: Unsigned(2 downto 0)
	);
End;


Architecture behavioral of RouteComputationUnit is

	Signal CurX : Unsigned(RowColLog-1 Downto 0);
	Signal CurY : Unsigned(RowColLog-1 Downto 0);
	Signal CurrentNode : Unsigned(DataWidth-1 Downto 0);
	Signal NextHopX : Unsigned(RowColLog-1 Downto 0);
	Signal NextHopY : Unsigned(RowColLog-1 Downto 0);
	Signal DestX : Unsigned(RowColLog-1 Downto 0);
	Signal DestY : Unsigned(RowColLog-1 Downto 0);
Begin
	CurrentNode	<=	To_Unsigned(CurNode,DataWidth);
	CurX		<=	CurrentNode(RowColLog-1 downto 0);
	CurY		<=	CurrentNode(RowColLog2-1 downto RowColLog);
	DestX		<=	Destination(RowColLog-1 downto 0);
	DestY		<=	Destination(RowColLog2-1 downto RowColLog);
	NextHopX	<=	(CurX - 1 ) when LARinfoIn = 0 else
					(CurX + 1 ) when LARinfoIn = 2 else	CurX;
	NextHopY	<=	(CurY - 1 ) when LARinfoIn = 1 else
					(CurY + 1 ) when LARinfoIn = 3 else	CurY;

	LARinfoOut	<=	To_Unsigned(0,3) when (DestX < NextHopX) else
					To_Unsigned(2,3) when (DestX > NextHopX) else
					To_Unsigned(1,3) when (DestY < NextHopY and DestX=NextHopX) else
					To_Unsigned(3,3) when (DestY > NextHopY and DestX=NextHopX) else
					To_Unsigned(4,3);

End;


Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use Work.ConnectionPack.All;

entity VirtualChannel is --a326
	generic(
		PackWidth	: Integer := 8;
		DataWidth	: Integer := 128;
		VC_Buffer_Depth : Integer := 5;
		CurNode		: Integer := 0
		);
	port(
		Clk			: In  std_logic;
		Reset		: In Std_Logic;

		InpData		: In  signed(DataWidth-1 downto 0);
		InpEn		: In  std_logic;


		OutpData	: Out signed(DataWidth-1 downto 0);
		OutpEn		: Buffer std_logic;

		DestNode	: Buffer signed(7 downto 0);		--Modified by R.Hojabr
		SrcNode		: Out signed(7 downto 0);		--Modified by R.Hojabr
		LARinfo		: Buffer signed(2 downto 0);		--Modified by R.Hojabr
		NextHopLAR	: Out	signed(2 downto 0);		--Modified by R.Hojabr
		VC_number	: Out signed(2 downto 0);		--Modified by R.Hojabr
		PackLen		: Buffer signed(2 downto 0);


		ValidHeader : Out Std_Logic;

		CreditOut	: Out Std_Logic;
		VCEmpty		: Out Std_Logic;

		PackCounter : Out Unsigned(PackWidth-1 Downto 0);
		IsChAssigned: In	std_logic
	);
End;

Architecture behavioral of VirtualChannel is

Signal PackCounterOut : Unsigned(PackWidth-1 Downto 0):=(Others=>'0');
Signal PackSize : Unsigned(PackWidth-1 Downto 0);--:=(Others=>'0');
Signal OData	: Unsigned(DataWidth-1 downto 0);
Signal Internal_Data	: Unsigned(DataWidth-1 downto 0);
Signal ValidHeaderDown : Std_Logic;

Signal	FIFO1_read, FIFO2_read	:	Std_Logic:='0';
Signal	FIFO1_write, FIFO2_write:	Std_Logic:='0';
Signal	FIFO1_DataValid, FIFO2_DataValid:	Std_Logic:='0';
Signal	FIFO1_Full, FIFO2_Full	:	Std_Logic:='0';
Signal	FIFO1_Empty, FIFO2_Empty:	Std_Logic:='0';

Signal NextHopLARtmp	: 	Unsigned(2 downto 0);
Begin

	PackCounter <= PackCounterOut;
	fifo1: entity work.FIFO
		generic map(
				InAddrLen 		=> 3,
				OutDataLen 		=> DataWidth,
				Out2InAddrLen	=> 0,
				VC_Buffer_Depth => VC_Buffer_Depth
						)
				port map(
						Clock 			=>	Clk,
						Reset			=>	Reset,
						Write			=>	FIFO1_write,
						Read			=>	FIFO1_read,
						Input			=>	Unsigned(InpData),
						Output			=>	Internal_Data,
						DataValid		=>	FIFO1_DataValid,
						Empty	 		=>	FIFO1_Empty,
						Full	 		=>	FIFO1_Full
		);

	fifo2: entity work.flit_latch
		generic map(
				OutDataLen 		=> DataWidth
						)
				port map(
						Clock 			=>	Clk,
						Reset			=>	Reset,
						Write			=>	FIFO2_write,
						Read			=>	FIFO2_read,
						Input			=>	Internal_Data,
						Output			=>	OData,
						Empty	 		=>	FIFO2_Empty
		);

	RCU: entity work.RouteComputationUnit
		generic map(
				DataWidth	=> DataWidth,
				RowColLog	=> 2,
				RowColLog2	=> 4,
				CurNode		=> CurNode
		)
		port map (
				LARinfoOut		=> NextHopLARtmp,

				Destination		=> Unsigned(DestNode),
				LARinfoIn		=> Unsigned(LARinfo)
		);

	NextHopLAR	<=	signed(NextHopLARtmp);
	--VCEmpty is used for PE packet injection
	VCEmpty<= (Not Reset) And ((Not FIFO1_Full) Or FIFO1_Read);

	FIFO1_Write <= InpEn;

	OutpData <= Signed(OData);

	ValidHeader		<=	ValidHeaderDown;



	FIFO2_Read <= IsChAssigned;


	FIFO1_Read	<=	(FIFO2_Read  And (Not FIFO1_Empty)) Or
					(ValidHeaderDown And FIFO2_Empty );


	CreditOut	<=	FIFO1_Read;

	FIFO2_write	<=	FIFO1_Read;

	OutpEn <= IsChAssigned And (Not FIFO2_Empty);



	DestNode 	<=	signed(Internal_Data(15 Downto 8))	When(Unsigned(Internal_Data(2 Downto 0))=0 And FIFO1_Empty='0'); -- Else (Others=>'Z');
	SrcNode		<=	signed(Internal_Data(23 Downto 16))	When(Unsigned(Internal_Data(2 Downto 0))=0 And FIFO1_Empty='0'); -- Else (Others=>'Z');
	LARinfo		<=	signed(Internal_Data(26 Downto 24))	When(Unsigned(Internal_Data(2 Downto 0))=0 And FIFO1_Empty='0'); -- Else (Others=>'Z');
	VC_number	<=	signed(Internal_Data(29 Downto 27))	When(Unsigned(Internal_Data(2 Downto 0))=0 And FIFO1_Empty='0'); -- Else (Others=>'Z');

	ValidHeaderDown	<=	'1'	When	(Unsigned(Internal_Data(2 Downto 0))=0 And FIFO1_Empty='0')	Else '0';



	process (Clk)
	Begin
		If (Rising_Edge(Clk)) Then

			If (Reset='1') Then
				PackCounterOut <= (Others=>'0');
				PackSize	<=	(Others=>'0');
			Elsif (FIFO1_Empty='0' AND FIFO1_Read='1' AND Unsigned(Internal_Data(2 Downto 0))=0) Then
				PackSize	<= to_unsigned(0,5) & unsigned(Internal_Data(5 Downto 3));
				PackLen		<=	Signed(Internal_Data(5 Downto 3));

			End If;


		------------------------------------------------------------------------------------------------------

			If (OutpEn='1' And IsChAssigned='1' And PackSize>1 ) Then

				PackCounterOut <= PackCounterOut+1;

				If (PackCounterOut>=PackSize-1) Then

					PackCounterOut <= (Others=>'0');
				End If;

			Elsif (PackCounterOut>=PackSize) Then
					PackCounterOut <= (Others=>'0');
			End If;
		End If;
	End Process;
End;




Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity DataNetwork_Mux is --a327
	generic(
		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		Sel_in		: In Unsigned(ViChAddr-1 Downto 0);

		InpData		: In  SignedArrDW(ViCh-1 downto 0);
		InpEn		: In  Unsigned(ViCh-1 downto 0);

		LatchData	: In  Signed(DataWidth-1 downto 0);
		LatchInpEn	: In  std_logic;

		BypassData	: In  Signed(DataWidth-1 downto 0);
		BypassInpEn	: In  std_logic;


		OutpData	: Out Signed(DataWidth-1 downto 0);
		OutpEn		: Out Std_Logic

	);
End;

Architecture behavioral of DataNetwork_Mux is
Signal InternalData	:	SignedArrDW((ViCh+2)-1 downto 0);
Signal InternalInpEn:	Unsigned((ViCh+2)-1 downto 0);

Begin

	InternalData(ViCh+1)	<=	BypassData;
	InternalData(ViCh)		<=	LatchData;
	InternalData(ViCh-1 downto 0)	<=	InpData(ViCh-1 downto 0);

	InternalInpEn(ViCh+1)	<=	BypassInpEn;
	InternalInpEn(ViCh)		<=	LatchInpEn;
	InternalInpEn(ViCh-1 downto 0)	<=	InpEn(ViCh-1 downto 0);


	OutpData <= InternalData(To_Integer(Sel_in));
	OutpEn <= InternalInpEn(To_Integer(Sel_in));

	--Process (Sel_in,Reset,InternalInpEn,InternalData)
	--Variable	Sel : Integer;
	--Begin
		--If (Reset='1') Then
			--OutpData <= (Others=>'0');
			--OutpEn <= '0';
		--Else
			--OutpData <= (Others=>'Z');
		--	Sel := To_Integer(Sel_in);
			--OutpEn <= '0';

			--If (Sel_in=i) And (InternalInpEn(i)='1') Then

					--OutpData <= InternalData(Sel);
					--OutpEn <= InternalInpEn(Sel);
			--End If;





			--For i In 0 To (ViCh+2)-1 Loop
			--	If (Sel_in=i) And (InternalInpEn(i)='1') Then
            --
			--		OutpData <= InternalData(i);
			--		OutpEn <= '1';
			--	End If;
			--
			--End Loop;
		--End If;
	--End Process;
End;

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity Mux is
	generic(
		DataWidth	: Integer := 8;
		ViChAddr	: Integer := 1;
		ViCh		: Integer := 2 -- 2**ViChAddr
	);
	port(
		Clk			: In  std_logic;
		Reset		: In  std_logic;
		Sel_in		: In Unsigned(ViChAddr-1 Downto 0);

		InpData		: In  SignedArrDW(ViCh-1 downto 0);
		InpEn		: In  Unsigned(ViCh-1 downto 0);

		OutpData	: Out Signed(DataWidth-1 downto 0);
		OutpEn		: Out Std_Logic
	);
End;

Architecture behavioral of Mux is
Begin
	OutpData <= InpData(To_Integer(Sel_in));
	OutpEn	 <= InpEn(To_Integer(Sel_in));
End;



Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Use Work.ConnectionPack.All;

entity Router is
	generic(

		CorWidth	: Integer := 4;
		--
		CurNode		: Integer := 0
	);
	Port(
		Clk				: In  std_logic;
		Reset			: In  std_logic;

		InpData			: In  SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
		InpEn			: In  Unsigned(PhyRoCh-1 downto 0);
		VCEmpty			: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
		CreditOut		: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
		InpSel			: In  UnsignedArrVCA(PhyRoCh-1 downto 0); -- ? ViChAddr=1

		OutpData		: Out SignedArrDW(PhyRoCh-1 downto 0); --? 8+2
		OutpEn			: Out Unsigned(PhyRoCh-1 downto 0);
		CreditIn		: In  Unsigned(PhyRoCh*ViCh-1 downto 0);

		OutpSel			: Buffer UnsignedArrVCA(PhyRoCh-1 downto 0) -- ? ViChAddr=1
	);
End;


Architecture behavioral of Router is

Signal	DeMuxOutpData	: SignedArrDW(PhyRoCh*(ViCh)-1 downto 0);
Signal	DeMuxOutpEn		: Unsigned(PhyRoCh*(ViCh)-1 downto 0);

Signal	DeMuxOutpReady	: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	ExtOutpData		: SignedArrDW(PhyRoCh*ViCh-1 downto 0); --? 8+2
Signal	ExtOutpEn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	ExtOutpReady	: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	CmbOutpData		: SignedArrDW(PhyRoCh*ViCh-1 downto 0); --? 8+2
Signal	CmbOutpEn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	CmbOutpReady	: Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal	DestNodeArr		: SignedArr8(PhyRoCh*ViCh-1 downto 0);
Signal	SrcNodeArr		: SignedArr8(PhyRoCh*ViCh-1 downto 0);
Signal	LARinfoArr		: SignedArr3(PhyRoCh*ViCh-1 downto 0);
Signal	NextHopLARinfoArr: SignedArr3(PhyRoCh*ViCh-1 downto 0);
Signal	VC_numberArr	: SignedArr3(PhyRoCh*ViCh-1 downto 0);
Signal 	PackLenArr		: signedArr3(PhyRoCh*ViCh-1 downto 0);	-- Packet Length: '1' ==> 5-flit (Long)	'0' ==> 1-flit (Short)

Signal	ValidHeaderArr	: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	VC_OutpReadyArr	: Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal	PackOutPhChArr	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
Signal	SwitchPortsArr	: UnsignedArr3(PhyRoCh-1 downto 0);
Signal	PackOutViChArr	: UnsignedArrVCA(PhyRoCh*ViCh-1 downto 0);
Signal 	InpChAssignedArr: Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal	OutpDataArr		: SignedArrDW(PhyRoCh*ViCh-1 downto 0); --? 8+2
Signal	OutpEnArr		: Unsigned(PhyRoCh*ViCh-1 downto 0);
Signal	OutpReadyArr	: Unsigned(PhyRoCh*ViCh-1 downto 0);

Signal 	NextHopLARArr	: SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
Signal 	PackCounterArr	: UnsignedArrPW(PhyRoCh*ViCh-1 downto 0);

Signal	MuxOutpData		: SignedArrDW(PhyRoCh-1 downto 0);
Signal	MuxOutpEn		: Unsigned(PhyRoCh-1 downto 0);


Signal	PackOutPhChTemp		: UnsignedArr3(PhyRoCh-1 downto 0);

Signal 	Mux_Sel	: UnsignedArrVCA(PhyRoCh-1 downto 0);

Signal LatchOutpData	:	SignedArrDW(PhyRoCh-1 downto 0);
Signal LatchOutpEn		:	Unsigned(PhyRoCh-1 downto 0);

Signal	OutpChBusyArr	:	Unsigned(PhyRoCh-1 downto 0);

Begin


rg3: For k in 0 to PhyRoCh-1 Generate

demux:Entity Work.DeMux
	Generic Map(
		DataWidth	=>	 DataWidth	,
		ViChAddr	=>	 ViChAddr	,
		ViCh		=>	 ViCh
	)
	Port Map(
		Clk			=>	Clk			,
		Reset		=>	Reset		,
		Sel			=>	InpSel(k)	,

		InpData		=>	InpData(k)	,
		InpEn		=>	InpEn(k)	,

		OutpData	=>	DeMuxOutpData((k*ViCh) + ViCh-1 Downto k*ViCh)		,
		OutpEn		=>	DeMuxOutpEn((k*ViCh) + ViCh-1 Downto k*ViCh)
	);
End Generate;

inp: For i in 0 to PhyRoCh*ViCh-1 Generate

VC:Entity Work.VirtualChannel
	Generic Map(
		PackWidth	=> PackWidth	,
		DataWidth	=> DataWidth	,
		VC_Buffer_Depth => VC_Buffer_Depth,
		CurNode		=> CurNode
	)
	Port Map(
		Clk					=> Clk			,
		Reset				=> Reset		,

		InpData				=> DeMuxOutpData(((i/ViCh)*(ViCh)) + (i mod ViCh))	,
		InpEn				=> DeMuxOutpEn(((i/ViCh)*(ViCh)) + (i mod ViCh))	,

		OutpData			=>	ExtOutpData(i)	,
		OutpEn				=>	ExtOutpEn(i)	,
		DestNode			=>	DestNodeArr(i)	,
		SrcNode				=>	SrcNodeArr(i)	,
		LARinfo				=>	LARinfoArr(i)	,
		NextHopLAR			=>	NextHopLARinfoArr(i),
		VC_number			=>	VC_numberArr(i)	,
		PackLen				=>	PackLenArr(i)	,


		ValidHeader			=>	ValidHeaderArr(i),
		CreditOut			=>	CreditOut(i),
		VCEmpty				=>	VCEmpty(i),
		PackCounter 		=>	PackCounterArr(i),
		IsChAssigned		=>	InpChAssignedArr(i)

	);

--	================================  Combiner  ===================================
rc:Entity Work.Combiner
	Generic Map(
		offset	=> 0				-- ghablan 1 bood 	************** R.Hojabr
	)
	Port Map(
		Clk			=> Clk					,
		Reset		=> Reset				,
		PackCounter => PackCounterArr(i)	,
		--ValidPack	=> ValidPackArr(i)		,
		NextHopLRA	=> NextHopLARArr(i)		,
		InpData		=> ExtOutpData(i)		,
		InpEn		=> ExtOutpEn(i)			,

		OutpData	=> CmbOutpData(i)		,
		OutpEn		=> CmbOutpEn(i)
	);

End Generate;

--	==================================  Mux  ======================================
outp: For n in 0 to PhyRoCh-1 Generate


mux:Entity Work.Mux
	Generic Map(
		DataWidth	=>  DataWidth	,
		ViChAddr	=> 	ViChAddr	,
		ViCh		=> 	ViCh
	)
	Port Map(
		Clk			=>	 	Clk		   	,
		Reset		=>	 	Reset	   	,
		Sel_in		=>	 	Mux_Sel(n)	,

		InpData		=>	 	CmbOutpData(n*ViCh+ViCh-1 Downto n*ViCh),
		InpEn		=>	 	CmbOutpEn(n*ViCh+ViCh-1 Downto n*ViCh)	,

		OutpData	=>	 	MuxOutpData(n)	,
		OutpEn		=>	 	MuxOutpEn(n)
	);

End Generate;

--	================================== Switch ======================================
switch:	Entity Work.OptimizedSwitch
		Generic Map(
			PhyRoCh		=> PhyRoCh
		)
		Port Map(
			InpData			=>	MuxOutpData	,
			InpEn			=>	MuxOutpEn	,

			OutpData		=>	OutpData	,	--OutpData	,
			OutpEn			=>	OutpEn		,	--OutpEn	,

			PackOutPhCh		=>	SwitchPortsArr,
			OutpChBusy		=>	OutpChBusyArr
	);

--	================================= Arbiter ====================================
rsr:Entity Work.Arbiter
	Generic Map(

		ViChAddr		=> ViChAddr			,
		PhyRoChAddr		=> PhyRoChAddr		,
		--				   --
		CurNode			=> CurNode			,
		ViCh			=> ViCh				,
		PhyRoCh			=> PhyRoCh
	)
	Port Map(
		Clk				=>	Clk				,
		Reset			=>	Reset			,
		DestNode		=>	DestNodeArr		,
		SrcNode			=>	SrcNodeArr		,
		LARinfo			=>	LARinfoArr		,
		NextHopLARinfo	=>	NextHopLARinfoArr,
		VC_number		=>	VC_numberArr	,
		PackLen			=>	PackLenArr		,
		ValidHeader		=>	ValidHeaderArr	,

		CreditIn		=>	CreditIn		,

		PackCounter		=>	PackCounterArr	,

		PackOutPhCh		=>	PackOutPhChArr	,
		SwitchPorts		=>	SwitchPortsArr	,

		InpChAssigned	=>	InpChAssignedArr,
		OutpChBusy		=>	OutpChBusyArr	,	--Open

		NextHopLAR		=>	NextHopLARArr	,

		CmbOutpEn		=>	CmbOutpEn	,
		Mux_Select		=>	Mux_Sel,
		OutpSel			=>	OutpSel
	);


End;
