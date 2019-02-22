-- NOCSynSim
-- Network on a Chip Synthesisable and Simulation VHDL Model
-- Version: 1.0 
-- Last Update: 2006/10/04
-- Sharif University of Technology
-- Computer Department
-- High Performance Computing Group
-- Author: D.Rahmati

Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ConnectionPack is
	
--Type IntVector is array (natural range <>) of integer;
-- Type SignedArr is array (natural range <>) of Signed(natural range <>); --(DataWidth-1 Downto 0);

Type UnsignedArr1 is array (natural range <>) of Unsigned(0 Downto 0);
Type UnsignedArr2 is array (natural range <>) of Unsigned(1 Downto 0);
Type UnsignedArr3 is array (natural range <>) of Unsigned(2 Downto 0);
Type UnsignedArr4 is array (natural range <>) of Unsigned(3 Downto 0);
Type UnSignedArr8 is array (natural range <>) of Unsigned(7 Downto 0);
Type UnsignedArr14 is array (natural range <>) of Unsigned(13 Downto 0);
Type UnsignedArr16 is array (natural range <>) of Unsigned(15 Downto 0);
Type UnsignedArr20 is array (natural range <>) of Unsigned(19 Downto 0);
Type UnsignedArr32 is array (natural range <>) of Unsigned(31 Downto 0);
--Type UnsignedArrMxN is array (natural range <>) of Unsigned(RowNo*ColNo-1 Downto 0);
	

Type SignedArr1 is array (natural range <>) of Signed(0 Downto 0);
Type SignedArr2 is array (natural range <>) of Signed(1 Downto 0);
Type SignedArr3 is array (natural range <>) of Signed(2 Downto 0);
Type SignedArr4 is array (natural range <>) of Signed(3 Downto 0);
Type SignedArr8 is array (natural range <>) of Signed(7 Downto 0);
Type SignedArr10 is array (natural range <>) of Signed(9 Downto 0);

Type BoolArr is array (natural range <>) of Boolean;

Type StrArr6 is Array(natural range <>) of String(6 Downto 1);

--Type UnsignedArr2Arr4 is array (natural range <>) of UnsignedArr2(3 Downto 0);
	
Constant RowNo : Integer := 4;        --4	
Constant ColNo : Integer := 4;        --4
Constant RowColLog	:	Integer := 2;
Constant RowColLog2	:	Integer := 4;	-- 2 * 	RowColLog
Constant DataWidth : Integer :=128;   --8
Constant CntWidth	: Integer :=15;   --8
Constant PhyCh : Integer := 4;				    --number of physical channels except local channel
Constant ViCh : Integer := 4; --2			  --number of virtual channels
Constant ViChAddr : Integer :=3;  --1	--number of virtual channel address bits
Constant PackSize: Integer :=5;--32;		--pakcet size: number of flits per packet --16
Constant VC_Buffer_Depth: Integer :=5;--32;		--number of flits per packet = 5
Constant CNViCh : Integer := 3; --2			  --number of virtual channels

Constant RecePackIgnorePercent :Integer :=0; --20%
Constant DumpTimePackFile : Boolean := false;
Constant PackWidth	: Integer := 8;	--log packsize(max) it means that each packet can have 256 flits in maximum
Constant AddrWidth	: Integer := 5;	
Constant RoChAddr		: Integer := 1;
Constant PhyChAddr		: Integer := 2;
Constant PhyRoChAddr	: Integer := 2+1;
Constant RoCh			: Integer := 1;
Constant PhyRoCh		: Integer := 4+1;
Constant PoissonDelayStr : String(3 Downto 1):="005";
Constant DefExtData : Integer := 0;

Constant PacketTypeHeader	:	Integer	:=	3;


Constant PackGenNum : Unsigned(15 Downto 0) := To_Unsigned(2000,16);	--120,16
--Constant PackGen 	: Unsigned(15 Downto 0) :="1111111111101111"; -- 15 ... 0
--Constant PackGen 	: Unsigned(15 Downto 0) :="0000000000000011"; -- 15 ... 0
Constant PackGen 	: Unsigned(RowNo*ColNo-1 Downto 0) :=(Others=>'1'); -- 15 ... 0

Type UnsignedArrVCA is array (natural range <>) of Unsigned(ViChAddr-1 Downto 0); -- ViChAddr=1
Type SignedArrDW is array (natural range <>) of Signed(DataWidth-1 Downto 0); -- DataWidth=8
Type SignedArrCW is array (natural range <>) of Signed(CntWidth-1 Downto 0); -- DataWidth=8
Type UnsignedArrPW is array (natural range <>) of Unsigned(PackWidth-1 Downto 0); -- PackWidth=8-->256 pack length
Type UnsignedArrViCh is array (natural range <>) of Unsigned(ViCh-1 Downto 0); -- ViChAddr=1

-------------------------------------------------------
Constant MaxCol : Integer := 8; 
Constant MaxRow : Integer := 8; 
Constant InpFileUniform :StrArr6(0 to MaxCol*MaxRow-1):=(
								"00.txt",
								"01.txt",
								"02.txt",
								"03.txt",
								"04.txt",
								"05.txt",
								"06.txt",
								"07.txt",
								"08.txt",
								"09.txt",
								"10.txt",
								"11.txt",
								"12.txt",
								"13.txt",
								"14.txt",
								"15.txt",																
								"16.txt",
								"17.txt",
								"18.txt",
								"19.txt",
								"20.txt",
								"21.txt",
								"22.txt",
								"23.txt",
								"24.txt",
								"25.txt",
								"26.txt",
								"27.txt",
								"28.txt",
								"29.txt",
								"30.txt",
								"31.txt",																
								"32.txt",
								"33.txt",
								"34.txt",
								"35.txt",
								"36.txt",
								"37.txt",
								"38.txt",
								"39.txt",
								"40.txt",
								"41.txt",
								"42.txt",
								"43.txt",
								"44.txt",
								"45.txt",
								"46.txt",
								"47.txt",																
								"48.txt",
								"49.txt",
								"50.txt",
								"51.txt",
								"52.txt",
								"53.txt",
								"54.txt",
								"55.txt",
								"56.txt",
								"57.txt",
								"58.txt",
								"59.txt",
								"60.txt",
								"61.txt",
								"62.txt",
								"63.txt"													
								); 
								

	--Function  HasFreeAdapViCh(
	--						IsOutpChBusy			: Unsigned(PhyRoCh*ViCh-1 downto 0);
	--						PhyIndex				: Integer )Return Integer;
	Procedure PE_MuxSelector(

							SelOut		: Out Unsigned(ViChAddr-1 Downto 0);
							
							
							SelIn		: Unsigned(ViChAddr-1 Downto 0);
							FirstTime	: Unsigned(ViCh-1 Downto 0);
							InpEn		: Unsigned(ViCh-1 downto 0);
							OutpReady	: Unsigned(ViCh-1 downto 0)  );
	Procedure SwitchAllocation(
							InpChAssigned	: Out Std_Logic;

							IsOutpChBusy	: Unsigned(PhyRoCh-1 downto 0);
							LARinfoIn		: Unsigned(2 downto 0)  );
								
	

	Procedure RoutingMechanism(	
							PackOutPhChOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0); -- Array of inp channel and coresponding output ch
							StalledPhChOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0);

							InpChAssignedOut: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
							StalledPacksOut	: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
							VCAssignedOut	: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
							VCBuffStatOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
							
							NextHopLRAOut	: Out SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
							OutpChBusyOut 	: Out Unsigned(PhyRoCh-1 downto 0);
							Mux_SelectOut	: Out UnsignedArrVCA(PhyRoCh-1 downto 0);
							OutpSelOut		: Out UnsignedArrVCA(PhyRoCh-1 downto 0);
							SwitchPortsOut	: Out UnsignedArr3(PhyRoCh-1 downto 0);
							
							losed_arbitration_Out	:	Out	Unsigned(PhyRoCh*ViCh-1 downto 0);
							losed_Receiver_Out		:	Out	SignedArr8(PhyRoCh*ViCh-1 downto 0);
							losed_ExtData_Out		:	Out	SignedArr8(PhyRoCh*ViCh-1 downto 0);
							losed_LARinfo_Out		:	Out	SignedArr3(PhyRoCh*ViCh-1 downto 0);
							losed_NextHopLAR_Out	: 	Out SignedArr3(PhyRoCh*ViCh-1 downto 0);
							
							losed_arbitration	:	Unsigned(PhyRoCh*ViCh-1 downto 0);
							losed_Receiver		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
							losed_ExtData		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
							losed_LARinfo		:	SignedArr3(PhyRoCh*ViCh-1 downto 0);
							losed_NextHopLAR	: 	SignedArr3(PhyRoCh*ViCh-1 downto 0);
							
							Reset			: Std_Logic;
							InpChAssigned	: Unsigned(PhyRoCh*ViCh-1 downto 0);
							StalledPacks	: Unsigned(PhyRoCh*ViCh-1 downto 0);
							VCAssignedBusy	: Unsigned(PhyRoCh*ViCh-1 downto 0);
							VCBuffStatus	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
							OutpChBusy 		: Unsigned(PhyRoCh-1 downto 0);
							Mux_Select		: UnsignedArrVCA(PhyRoCh-1 downto 0);
							
							CurNode			: Integer;

							Receiver		: SignedArr8(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
							ExtData			: SignedArr8(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr

							LARinfo			: SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
							NextHopLARinfo	: SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
							VC_number		: SignedArr3(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
							PackLen			: SignedArr3(PhyRoCh*ViCh-1 downto 0);		-- Packet Length: '1' ==> 5-flit (Long)	'0' ==> 1-flit (Short)
							ValidHeader		: Unsigned(PhyRoCh*ViCh-1 downto 0);

							CmbOutpEn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
							CreditIn		: Unsigned(PhyRoCh*ViCh-1 downto 0);

							PackCounter		: UnsignedArrPW(PhyRoCh*ViCh-1 downto 0);
							PackOutPhCh		: UnsignedArr3(PhyRoCh*ViCh-1 downto 0); -- Array of inp channel and coresponding output ch
							StalledPhCh		: UnsignedArr3(PhyRoCh*ViCh-1 downto 0))  ;

							
-- User Defined Constants
Constant NumOfAdapViCh : Integer := 3;

end;

package body ConnectionPack is
					
					
					
	Procedure PE_MuxSelector(

							SelOut		: Out Unsigned(ViChAddr-1 Downto 0);
							
							
							SelIn		: Unsigned(ViChAddr-1 Downto 0);
							FirstTime	: Unsigned(ViCh-1 Downto 0);
							InpEn		: Unsigned(ViCh-1 downto 0);
							OutpReady	: Unsigned(ViCh-1 downto 0)  ) is
		
		Variable	SelV	: Integer;
		Variable	cnt		: Integer;
	begin
		-- Or (OutpReady(To_Integer(SelIn))='0'
		If (InpEn(To_Integer(SelIn))='0' Or (OutpReady(To_Integer(SelIn))='0'))  Then
					SelV := To_Integer(SelIn);
					cnt := 0;
					-- Or (OutpReady(SelV)='0')
					While ((InpEn(SelV)='0')Or (OutpReady(SelV)='0')) And cnt<ViCh Loop
						SelV := SelV + 1;
						If (SelV>=ViCh) Then
							SelV := 0;
						End If;
						cnt := cnt + 1;
											
					End Loop;
					
					If (FirstTime(ViCh-1 Downto 0)>0) Then 
						SelOut	:=	SelIn + 1;
						If (SelIn=ViCh-1) Then
							SelOut := To_Unsigned(0,ViChAddr);
						End If;
					Else
						SelOut	:=	To_Unsigned(SelV,ViChAddr);	
					End If;
					
					
				End If;	
	
	End;	
							
							
	
	Procedure SwitchAllocation(
							InpChAssigned	: Out Std_Logic;

							IsOutpChBusy	: Unsigned(PhyRoCh-1 downto 0);
							LARinfoIn		: Unsigned(2 downto 0)  ) is

	variable CurrOutPort, CurrVC :Integer;
	
	Variable IsInpChAssigned : Std_Logic;

	begin
		CurrOutPort :=	To_Integer(LARinfoIn);

		
			-- ============ Crossbar Allocation
			IsInpChAssigned := '0';
			

			If (IsOutpChBusy(CurrOutPort)='0')  Then
					IsInpChAssigned := '1';
			End If;
			
			InpChAssigned := IsInpChAssigned;
			

	end;
	
		Procedure RoutingMechanism(	
									PackOutPhChOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0); -- Array of inp channel and coresponding output ch
									StalledPhChOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0);

									InpChAssignedOut: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
									StalledPacksOut	: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
									VCAssignedOut	: Out Unsigned(PhyRoCh*ViCh-1 downto 0);
									VCBuffStatOut	: Out UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
									--CmbDataOut		: Out SignedArrDW(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
									NextHopLRAOut	: Out SignedArr3(PhyRoCh*ViCh-1 downto 0);	--modified by R.Hojabr
									OutpChBusyOut 	: Out Unsigned(PhyRoCh-1 downto 0);
									Mux_SelectOut	: Out UnsignedArrVCA(PhyRoCh-1 downto 0);
									OutpSelOut		: Out UnsignedArrVCA(PhyRoCh-1 downto 0);
									SwitchPortsOut	: Out UnsignedArr3(PhyRoCh-1 downto 0);
									
									losed_arbitration_Out	:	Out	Unsigned(PhyRoCh*ViCh-1 downto 0);
									losed_Receiver_Out		:	Out	SignedArr8(PhyRoCh*ViCh-1 downto 0);
									losed_ExtData_Out		:	Out	SignedArr8(PhyRoCh*ViCh-1 downto 0);
									losed_LARinfo_Out		:	Out	SignedArr3(PhyRoCh*ViCh-1 downto 0);
									losed_NextHopLAR_Out	: 	Out SignedArr3(PhyRoCh*ViCh-1 downto 0);
									
									losed_arbitration	:	Unsigned(PhyRoCh*ViCh-1 downto 0);
									losed_Receiver		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
									losed_ExtData		:	SignedArr8(PhyRoCh*ViCh-1 downto 0);
									losed_LARinfo		:	SignedArr3(PhyRoCh*ViCh-1 downto 0);
									losed_NextHopLAR	: 	SignedArr3(PhyRoCh*ViCh-1 downto 0);
									
									Reset			: Std_Logic;
									InpChAssigned	: Unsigned(PhyRoCh*ViCh-1 downto 0);
									StalledPacks	: Unsigned(PhyRoCh*ViCh-1 downto 0);
									VCAssignedBusy	: Unsigned(PhyRoCh*ViCh-1 downto 0);
									VCBuffStatus	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
									OutpChBusy 		: Unsigned(PhyRoCh-1 downto 0);
									Mux_Select		: UnsignedArrVCA(PhyRoCh-1 downto 0);
									
									CurNode			: Integer;

									Receiver		: SignedArr8(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
									ExtData			: SignedArr8(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
									
									LARinfo			: SignedArr3(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
									NextHopLARinfo	: SignedArr3(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
									VC_number		: SignedArr3(PhyRoCh*ViCh-1 downto 0);		--modified by R.Hojabr
									PackLen			: SignedArr3(PhyRoCh*ViCh-1 downto 0);		-- Packet Length: '1' ==> 5-flit (Long)	'0' ==> 1-flit (Short)
									ValidHeader		: Unsigned(PhyRoCh*ViCh-1 downto 0);

									CmbOutpEn		: Unsigned(PhyRoCh*ViCh-1 downto 0);
									CreditIn		: Unsigned(PhyRoCh*ViCh-1 downto 0);

									PackCounter		: UnsignedArrPW(PhyRoCh*ViCh-1 downto 0);
									PackOutPhCh		: UnsignedArr3(PhyRoCh*ViCh-1 downto 0); -- Array of inp channel and coresponding output ch
									StalledPhCh		: UnsignedArr3(PhyRoCh*ViCh-1 downto 0)) Is -- Array of inp channel and coresponding output ch

		Variable PhChAssigned : Integer;
		Variable ViChAssigned : Integer;
		Variable NextHopLRAOutVar : Unsigned(2 Downto 0);
		Variable Ind, temp : Integer;
		Variable CurrPort : Integer;

		Variable IsInpChAssigned : Std_Logic;
		Variable OutpChBusyVar 	: Unsigned(PhyRoCh-1 downto 0);
		Variable VCAssignedVar 	: Unsigned(PhyRoCh*ViCh-1 downto 0);
		Variable VCBuffStatVar	: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
		Variable InpChAssignedVar 	: Unsigned(PhyRoCh*ViCh-1 downto 0);
		
		
		Variable Mux_SelectVar		: UnsignedArrVCA(PhyRoCh-1 downto 0);
		
		Variable Mux_SelectTmp		: UnsignedArrViCh(PhyRoCh-1 downto 0);
		Variable Mux_SelectTmpOut	: UnsignedArrViCh(PhyRoCh-1 downto 0);
		Variable Temp1				: UnsignedArrViCh(PhyRoCh-1 downto 0);
		Variable Temp2				: UnsignedArrViCh(PhyRoCh-1 downto 0);
		Variable Temp3				: UnsignedArrViCh(PhyRoCh-1 downto 0);
		
		Variable VC_MuxRequest  	: Unsigned(PhyRoCh-1 downto 0);
		
		Variable PackOutPhChVar		: UnsignedArr3(PhyRoCh*ViCh-1 downto 0);
		
		
		Variable ModTemp			: Unsigned(ViChAddr-1 downto 0);
		VAriable VC,Outp_Port		: Integer;
		begin
				If (Reset='1') Then	

					InpChAssignedOut:= (Others=>'0');
					StalledPacksOut	:= (Others=>'0');
					VCAssignedOut	:= (Others=>'0');
					VCBuffStatOut	:= (Others => To_Unsigned(5,3));
					PackOutPhChOut 	:= (Others=>(Others=>'0'));
					StalledPhChOut	:= (Others=>(Others=>'0'));

					OutpChBusyOut 	:= (Others=>'0');
					Mux_SelectOut	:= (Others=>(Others=>'0'));
					NextHopLRAOut 	:= (Others=>(Others=>'0'));
					
					SwitchPortsOut	:= (Others=>(Others=>'0'));
					OutpSelOut		:= (Others=>(Others=>'0'));
					
					losed_arbitration_Out	:=	(Others=>'0');
					losed_Receiver_Out		:=	(Others=>(Others=>'0'));
					losed_ExtData_Out		:=	(Others=>(Others=>'0'));
					losed_LARinfo_Out		:=	(Others=>(Others=>'0'));
					losed_NextHopLAR_Out	:=	(Others=>(Others=>'0'));
					

				Else
					OutpChBusyVar		:= OutpChBusy;
					OutpChBusyOut		:= OutpChBusy;
					Mux_SelectOut		:= Mux_Select;
					Mux_SelectVar		:= Mux_Select;
					
					InpChAssignedOut	:= InpChAssigned;
					InpChAssignedVar	:= InpChAssigned;
					StalledPacksOut		:= StalledPacks;
					
					VCAssignedOut		:= VCAssignedBusy;
					VCAssignedVar		:= VCAssignedBusy;
					
					VCBuffStatOut		:= VCBuffStatus;
					VCBuffStatVar		:= VCBuffStatus;
					
					PackOutPhChOut		:= PackOutPhCh;
					PackOutPhChVar		:= PackOutPhCh;
					StalledPhChOut		:= StalledPhCh;		

					
					losed_arbitration_Out	:=	losed_arbitration;
					losed_Receiver_Out		:=	losed_Receiver;
					losed_ExtData_Out		:=	losed_ExtData;
					losed_LARinfo_Out		:=	losed_LARinfo;
					losed_NextHopLAR_Out	:=	losed_NextHopLAR;
					
					VC_MuxRequest	:=	(Others=>'0');
					
--  ================================= VC Free Space Calculating ====================================					
					For i In 0 To PhyRoCh*ViCh-1 Loop
						
						
						--ModTemp	:=	To_Unsigned(i,ViChAddr);
						--VC		:=	To_Integer(ModTemp(1 downto 0));
						
						Ind	:=	To_Integer(PackOutPhCh(i))*ViCh + (i mod ViCh);
						--Ind	:=	To_Integer(PackOutPhCh(i))*ViCh + VC;
						

						If (InpChAssigned(i)='1' And CmbOutpEn(i)='1' And (VCBuffStatus(Ind)>0 Or CreditIn(Ind)='1') ) Then
							--And To_Integer(Mux_Select(i/ViCh))= i mod ViCh ) Then

								VCBuffStatVar(Ind) := VCBuffStatVar(Ind) - 1;
						
						End If;
						
					End Loop;
					
					For i In 0 To PhyRoCh*ViCh-1 Loop
						If (CreditIn(i)='1') Then
							VCBuffStatVar(i) := VCBuffStatVar(i) + 1;
							
						End If;
					End Loop;
					
					VCBuffStatOut := VCBuffStatVar;
					
--  ================================= Stalled Packets ====================================					
					
					For i In 0 To PhyRoCh*ViCh-1 Loop --loop on all ph+vi inp ch
					
						Ind	:=	To_Integer(PackOutPhCh(i))*ViCh + (i mod ViCh);
						
						
							
						If (InpChAssigned(i)='1' AND
							(CmbOutpEn(i)='0' Or (VCBuffStatVar(Ind)=0 And PackCounter(i)<Unsigned(PackLen(i))-1)))  Then
						
							
							StalledPacksOut(i)	:= '1';
							
							StalledPhChOut(i)	:= PackOutPhCh(i);
							
							Ind	:=	To_Integer(PackOutPhCh(i));
							OutpChBusyVar(Ind)	:=	'0';
							OutpChBusyOut(Ind) := '0';
							InpChAssignedOut(i) := '0';
							InpChAssignedVar(i)	:= '0';

							Ind	:=	To_Integer(PackOutPhCh(i))*ViCh + (i mod ViCh);
							If (PackCounter(i)=0 And VCBuffStatus(Ind)=0) Then
								VCAssignedOut(Ind)	:= '0';
								VCAssignedVar(Ind)	:= '0';
								
							
							ElsIf (PackCounter(i)>0 ) Then
								VCAssignedOut(Ind)	:= '1';
								VCAssignedVar(Ind)	:= '1';
							End If;
														
							
						End If;	
					End Loop;
					
--  ================================= Arbiteration ====================================
					
					For i In 0 To PhyRoCh*ViCh-1 Loop
						Ind	:=	To_Integer(PackOutPhCh(i))*ViCh + (i mod ViCh);
						
						If (StalledPacks(i)='1') Then 
							
							SwitchAllocation(IsInpChAssigned, OutpChBusyVar,StalledPhCh(i));
							
							PhChAssigned := To_Integer(StalledPhCh(i));
							ViChAssigned := i mod ViCh;
							Ind := PhChAssigned*ViCh + ViChAssigned;
							
							If (IsInpChAssigned='1' And (VCBuffStatVar(Ind)>0 Or CreditIn(Ind)='1')) Then
								
								If (VCAssignedVar(Ind)='0' And PackCounter(i)=0)
									Or (VCAssignedVar(Ind)='1' And PackCounter(i)>0) Then
									PackOutPhChOut(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
									PackOutPhChVar(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
									
									OutpChBusyVar(PhChAssigned) := '1';
									OutpChBusyOut(PhChAssigned) := '1';
									InpChAssignedOut(i) := '1';
									InpChAssignedVar(i) := '1';
									VCAssignedOut(Ind)	:= '1';
									VCAssignedVar(Ind)	:= '1';	
									losed_arbitration_Out(i):=	'0';
									StalledPacksOut(i)	:= '0';
									
								End If;
							End If;
							
						ElsIf (losed_arbitration(i)='1') Then
							
							SwitchAllocation(IsInpChAssigned, OutpChBusyVar,Unsigned(losed_LARinfo(i)));
							
							PhChAssigned := To_Integer(Unsigned(losed_LARinfo(i)));
							ViChAssigned := To_Integer(Unsigned(VC_number(i)));
							Ind := PhChAssigned*ViCh + ViChAssigned;

							If (IsInpChAssigned='1' And (VCBuffStatVar(Ind)>0 Or CreditIn(Ind)='1') And VCAssignedVar(Ind)='0') Then

								PackOutPhChOut(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
								PackOutPhChVar(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
								
								NextHopLRAOut(i) := losed_NextHopLAR(i);

								OutpChBusyVar(PhChAssigned) := '1';
								OutpChBusyOut(PhChAssigned) := '1';
								InpChAssignedOut(i) := '1';
								InpChAssignedVar(i) := '1';
								VCAssignedOut(Ind)	:= '1';
								VCAssignedVar(Ind)	:= '1';
								losed_arbitration_Out(i):=	'0';
								StalledPacksOut(i)	:= '0';
								
							End If;

						ElsIf (ValidHeader(i)='1' ) Then

							If (InpChAssigned(i)='1') Then
								InpChAssignedOut(i) := '0';
								InpChAssignedVar(i) := '0';

								OutpChBusyVar(To_Integer(PackOutPhCh(i))) := '0'; -- because of, use in loop
								OutpChBusyOut(To_Integer(PackOutPhCh(i))) := '0';
								
								
								VCAssignedOut(Ind)	:= '0';
								VCAssignedVar(Ind)	:= '0';
								
								VC_MuxRequest(i/ViCh)	:=	'1';
							End IF;
							
							SwitchAllocation(IsInpChAssigned, OutpChBusyVar,Unsigned(LARinfo(i)));
							
							PhChAssigned := To_Integer(Unsigned(LARinfo(i)));
							ViChAssigned := To_Integer(Unsigned(VC_number(i)));
							Ind := PhChAssigned*ViCh + ViChAssigned;
							
							If (IsInpChAssigned='1' And (VCBuffStatVar(Ind)>0 Or CreditIn(Ind)='1') And VCAssignedVar(Ind)='0' ) Then
							
								
								PackOutPhChOut(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
								PackOutPhChVar(i) := To_Unsigned(PhChAssigned,PhyRoChAddr);
								
							
								NextHopLRAOut(i) := NextHopLARinfo(i);

								OutpChBusyVar(PhChAssigned) := '1';
								OutpChBusyOut(PhChAssigned) := '1';
								InpChAssignedOut(i) := '1';
								InpChAssignedVar(i) := '1';
								VCAssignedOut(Ind)	:= '1';
								VCAssignedVar(Ind)	:= '1';
								losed_arbitration_Out(i):=	'0';
								StalledPacksOut(i)	:= '0';
								
								losed_Receiver_Out(i)	:=	Receiver(i);
								losed_ExtData_Out(i)	:=	ExtData(i);
								losed_LARinfo_Out(i)	:=	LARinfo(i);
								losed_NextHopLAR_Out(i)	:=	NextHopLARinfo(i);
							
							Else
								losed_arbitration_Out(i):=	'1';
								StalledPacksOut(i)	:= '0';
								
								losed_Receiver_Out(i)	:=	Receiver(i);
								losed_ExtData_Out(i)	:=	ExtData(i);
								losed_LARinfo_Out(i)	:=	LARinfo(i);
								losed_NextHopLAR_Out(i)	:=	NextHopLARinfo(i);
							End If;
							
						ElsIf (InpChAssigned(i)='1' AND CmbOutpEn(i)='1' And (VCBuffStatus(Ind)>0 Or CreditIn(Ind)='1') And PackCounter(i)=Unsigned(PackLen(i))-1) Then
							
							InpChAssignedOut(i) := '0';
							InpChAssignedVar(i) := '0';

							OutpChBusyVar(To_Integer(PackOutPhCh(i))) := '0'; 
							OutpChBusyOut(To_Integer(PackOutPhCh(i))) := '0';
							
							
							VCAssignedOut(Ind)	:= '0';
							VCAssignedVar(Ind)	:= '0';
							
							StalledPacksOut(i)	:= '0';
						
						Else
							temp := 0;
							
						End If;	

					End Loop;
					

--  ================================= VC Multiplexing ====================================
--	The loop below determines if VC multiplexers should be changed or not					
					For i In 0 To PhyRoCh-1 Loop
					
						IF (InpChAssignedVar(i*ViCh + To_Integer(Mux_Select(i))) = '0'
							And InpChAssignedVar(i*ViCh + ViCh -1 Downto i*ViCh)>0) Then
							
							VC_MuxRequest(i)	:=	'1';
						End If;	
					End Loop;

--  ================================= VC Multiplexing ====================================

					For i In 0 To PhyRoCh-1 Loop
						Mux_SelectTmp(i)	:=	To_Unsigned(2**To_Integer(Mux_Select(i)),ViCh);
					End Loop;

					
					For i In 0 To PhyRoCh-1 Loop
						
						If (VC_MuxRequest(i)='1') Then
							Temp1(i)	:=	InpChAssignedVar(i*ViCh+ViCh-1 Downto i*ViCh) And (Not (InpChAssignedVar(i*ViCh+ViCh-1 Downto i*ViCh)) + 1);
							
							Temp2(i)	:=	InpChAssignedVar(i*ViCh+ViCh-1 Downto i*ViCh) And (Not ((Mux_SelectTmp(i)-1) Or Mux_SelectTmp(i)));
							Temp3(i)	:=	Temp2(i) And (Not (Temp2(i)) + 1);
							
							--Mux_SelectTmpOut(i)	:= Temp3(i) When Temp2(i)/=0 Else Temp1(i);
							If (Temp2(i)/=0) Then
								Mux_SelectTmpOut(i)	:= Temp3(i);
							Else
								Mux_SelectTmpOut(i)	:= Temp1(i);
							End If;
							
							-----------------------------------------------------------
							Mux_SelectVar(i)	:=	To_Unsigned(0,ViChAddr);
						
							--While Mux_SelectTmpOut(i)>1 Loop		-- Logarithm
							--	Mux_SelectTmpOut(i)	:=	Mux_SelectTmpOut(i)/2;
							--	Mux_SelectVar(i) := Mux_SelectVar(i) + 1;
							--End Loop;
							
							For j In 0 To ViCh-1 Loop
								If (Mux_SelectTmpOut(i)(j)='1') Then
									Mux_SelectVar(i) := To_Unsigned(j,ViChAddr);
								End IF;
							End Loop;
							-----------------------------------------------------------
							Mux_SelectOut(i)	:=	Mux_SelectVar(i);
							
							VC_MuxRequest(i)	:=	'0';
						End If;
							

					End Loop;
					
--  ================================= Stalled Packets ====================================					
					
					For i In 0 To PhyRoCh*ViCh-1 Loop
						
						Ind	:=	To_Integer(PackOutPhChVar(i))*ViCh + (i mod ViCh);
						
						If (InpChAssignedVar(i)='1'
							And (To_Integer(Mux_SelectVar(i/ViCh))/= i mod ViCh )) Then 
							
							StalledPacksOut(i)	:= '1';
							
							StalledPhChOut(i)	:= PackOutPhChVar(i);
							
							Ind	:=	To_Integer(PackOutPhChVar(i));
							OutpChBusyVar(Ind)	:=	'0';
							OutpChBusyOut(Ind) := '0';
							InpChAssignedOut(i) := '0';
							InpChAssignedVar(i)	:= '0';
							
							Ind	:=	To_Integer(PackOutPhChVar(i))*ViCh + (i mod ViCh);
							
							If (StalledPacks(i)='1' And PackCounter(i)>0) Then
								VCAssignedOut(Ind)	:= '1';
								VCAssignedVar(Ind)	:= '1';
							Else
								VCAssignedOut(Ind)	:= '0';
								VCAssignedVar(Ind)	:= '0';
							End If;	
						End If;	
					End Loop;

					InpChAssignedOut	:=	InpChAssignedVar;
					
					For i In 0 To PhyRoCh-1 Loop 
				
							VC	:=	To_Integer(Mux_SelectVar(i));
							Outp_Port:=	To_Integer(PackOutPhChVar(i*ViCh + VC));
							
							If (InpChAssignedVar(i*ViCh + VC)='1') Then 
								--SwitchPorts(i)	<=	PackOutPhCh(i*ViCh + VC);
								SwitchPortsOut(Outp_Port)	:=	To_Unsigned(i,3);--PackOutPhCh(i*ViCh + VC);
								OutpSelOut(Outp_Port) 		:= Mux_SelectVar(i);
							End If;
					End Loop;
					
				End If;	
		end;

end;





