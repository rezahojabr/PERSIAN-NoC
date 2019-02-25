-- PERSIAN-NoC
-- PERformance SImulation Architecture for Networks-on-chip
-- Version: 3.0
-- Last Update: 2019/02/25
-- High Performance Network Laboratory
-- School of Electrical and Computer Engineering
-- University of Tehran,
-- Author: Reza Hojabr

Library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.FilePack.all;
Use Work.ConnectionPack.All;
use std.textio.all;



entity NOC is  --MeshMxN
Generic(
		--RowNo		: Integer := 4;
		--ColNo		: Integer := 4;

		PackWidth	: Integer := 8;
		DataWidth	: Integer := 8;
		AddrWidth	: Integer := 4;

		RoChAddr		: Integer := 1;
		PhyChAddr		: Integer := 2;
		ViChAddr		: Integer := 2;
		PhyRoChAddr		: Integer := 2+1;
		RoCh			: Integer := 1;
		PhyCh			: Integer := 4;
		ViCh			: Integer := 4;
		PhyRoCh			: Integer := 4+1;
		PoissonDelayStr : String(3 Downto 1):="500";
		InpFileUniform  : StrArr6(0 to ColNo*RowNo-1);--:=(Others=>(Others=>"_"));


 		PackGenNum : Unsigned(15 Downto 0) := To_Unsigned(5,16);
 		PackGen    : Unsigned(RowNo*ColNo-1 Downto 0):=(Others=>'1')
		);
	port (
		Clk				: In  std_logic;
		Reset			: In  std_logic;

		SentCnt			: Out UnsignedArr16(RowNo*ColNo-1 Downto 0);
		ReceCnt			: Out UnsignedArr16(RowNo*ColNo-1 Downto 0);
		AveReceTime		: Out UnsignedArr20(RowNo*ColNo-1 Downto 0);
		StopSim			: In Std_Logic
		);
end;


architecture behavioral of NOC is


Constant InpFilePoissonStr : String(4 Downto 1) := Str_Add(3,1,PoissonDelayStr,"-"); --"500-"
Constant PStr : String(5 Downto 1) :="Pack-";
Constant OutpFilePackStr   : String(9 Downto 1) := Str_Add(5,4,PStr,InpFilePoissonStr); --"Pack-500-"
Constant TStr : String(5 Downto 1) :="Time-";
Constant OutpFileTimeStr   : String(9 Downto 1) := Str_Add(5,4,TStr,InpFilePoissonStr); --"Time-500-";
Constant LARStr : String(4 Downto 1) :="LAR-";
Constant LenStr : String(4 Downto 1) :="Len-";


Function Index(	j,i		: Integer;
				ColNo,RowNo	: Integer )
						return Integer Is

variable Res:	Integer;
variable ii,jj: Integer;
begin
	jj:=j;
	ii:=i;
	if (jj=-1) Then
		jj:=RowNo-1;
	End If;
	if (jj=RowNo) Then
		jj:=0;
	End If;
	if (ii=-1) Then
		ii:=ColNo-1;
	End If;
	if (ii=ColNo) Then
		ii:=0;
	End If;

	--Res := (j mod ColNo)*ColNo+(i mod ColNo);
	Res := jj*ColNo+ii;
	return Res;
end;

Type UnsignedArrViChAddr is array (natural range <>) of Unsigned(ViChAddr-1 Downto 0);
Type UnsignedArrPhyxVi is array (natural range <>) of Unsigned(PhyCh*ViCh-1 Downto 0); --PhyCh*ViCh=4*1
Type SignedArrMNxPhyChxDataWidth is array(ColNo*RowNo-1 Downto 0) of SignedArrDW(PhyCh-1 downto 0);
Type UnsignedArrMNxPhyxViChAddr is array(ColNo*RowNo-1 Downto 0) of UnsignedArrVCA(PhyCh-1 downto 0);
Type UnsignedArrPhy is array (natural range <>) of Unsigned(PhyCh-1 Downto 0);

Signal	Data	: SignedArrMNxPhyChxDataWidth:=(Others=>(Others=>(Others=>'0'))); --? 8+2
Signal	Data2	: SignedArrMNxPhyChxDataWidth:=(Others=>(Others=>(Others=>'0'))); --? 8+2
Signal	En		: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
Signal	En2		: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
--Signal	Ready	: UnsignedArrPhyxVi(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
--Signal	Ready2	: UnsignedArrPhyxVi(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
Signal	Credit	: UnsignedArrPhyxVi(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
Signal	Credit2	: UnsignedArrPhyxVi(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
Signal	Sel		: UnsignedArrMNxPhyxViChAddr; --ers=>" ? ViChAddr=1
Signal	Sel2	: UnsignedArrMNxPhyxViChAddr; --ers=>" ? ViChAddr=1

--Signal	CNROutpData	: SignedArrMNxPhyChxDataWidth:=(Others=>(Others=>(Others=>'0'))); --? 8+2
--Signal	CNROutpEn	: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
--
--Signal	CNRMD1InpData	: SignedArrMNxPhyChxDataWidth:=(Others=>(Others=>(Others=>'0'))); --? 8+2
--Signal	CNRMD1InpEn		: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
--
--Signal	CNRMD2InpData	: SignedArrMNxPhyChxDataWidth:=(Others=>(Others=>(Others=>'Z'))); --? 8+2
--Signal	CNRMD2InpEn		: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'Z'));
--
--
--Signal	Ack	: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));
--Signal	Ack2: UnsignedArrPhy(ColNo*RowNo-1 downto 0):=(Others=>(Others=>'0'));

begin

mg1: For j in 0 to RowNo-1 Generate
	mg2: For i in 0 to ColNo-1 Generate
	--write(str,i);
	--InpPoisson(j) <= String'(j);
	--InpPoisson(j):=Int_to_string(j*ColNo+i);
	Data2(j*ColNo+i) <= (Data(Index(j+1,i,ColNo,RowNo))(1),Data(Index(j,i+1,ColNo,RowNo))(0)
						   ,Data(Index(j-1,i,ColNo,RowNo))(3),Data(Index(j,i-1,ColNo,RowNo))(2));
	En2(j*ColNo+i) <= 	(En(Index(j+1,i,ColNo,RowNo))(1),En(Index(j,i+1,ColNo,RowNo))(0)
						   ,En(Index(j-1,i,ColNo,RowNo))(3),En(Index(j,i-1,ColNo,RowNo))(2));

	--CNRMD1InpData(j*ColNo+i) <= (CNROutpData(Index(j+1,i,ColNo,RowNo))(1),CNROutpData(Index(j,i+1,ColNo,RowNo))(0)
	--					   ,CNROutpData(Index(j-1,i,ColNo,RowNo))(3),CNROutpData(Index(j,i-1,ColNo,RowNo))(2));
	--CNRMD1InpEn(j*ColNo+i) <= 	(CNROutpEn(Index(j+1,i,ColNo,RowNo))(1),CNROutpEn(Index(j,i+1,ColNo,RowNo))(0)
	--					   ,CNROutpEn(Index(j-1,i,ColNo,RowNo))(3),CNROutpEn(Index(j,i-1,ColNo,RowNo))(2));
    --
	--
	--	Ack(Index(j+1,i,ColNo,RowNo))(1) 	<= Ack2(j*ColNo+i)(3);
	--	Ack(Index(j,i+1,ColNo,RowNo))(0) 	<= Ack2(j*ColNo+i)(2);
	--	Ack(Index(j-1,i,ColNo,RowNo))(3) 	<= Ack2(j*ColNo+i)(1);
	--	Ack(Index(j,i-1,ColNo,RowNo))(2) 	<= Ack2(j*ColNo+i)(0);

	ag3  : For k in 0 to ViCh-1 Generate
		--Ready(Index(j+1,i,ColNo,RowNo))(1 *ViCh+k) 	<= Ready2(j*ColNo+i)(3 *ViCh+k);
		--Ready(Index(j,i+1,ColNo,RowNo))(0 *ViCh+k) 	<= Ready2(j*ColNo+i)(2 *ViCh+k);
		--Ready(Index(j-1,i,ColNo,RowNo))(3 *ViCh+k) 	<= Ready2(j*ColNo+i)(1 *ViCh+k);
		--Ready(Index(j,i-1,ColNo,RowNo))(2 *ViCh+k) 	<= Ready2(j*ColNo+i)(0 *ViCh+k);



		-- ========================== Credit signals ================================
		Credit(Index(j+1,i,ColNo,RowNo))(1 *ViCh+k) 	<= Credit2(j*ColNo+i)(3 *ViCh+k);
		Credit(Index(j,i+1,ColNo,RowNo))(0 *ViCh+k) 	<= Credit2(j*ColNo+i)(2 *ViCh+k);
		Credit(Index(j-1,i,ColNo,RowNo))(3 *ViCh+k) 	<= Credit2(j*ColNo+i)(1 *ViCh+k);
		Credit(Index(j,i-1,ColNo,RowNo))(2 *ViCh+k) 	<= Credit2(j*ColNo+i)(0 *ViCh+k);
	End Generate;

	Sel2(j*ColNo+i) <=	(Sel(Index(j+1,i,ColNo,RowNo))(1),Sel(Index(j,i+1,ColNo,RowNo))(0)
						   ,Sel(Index(j-1,i,ColNo,RowNo))(3),Sel(Index(j,i-1,ColNo,RowNo))(2));
m1: Entity Work.Node
	Generic Map(
		--InpFilePoisson	=> InpFilePoisson(j*ColNo+i)	,
		--InpFileUniform	=> InpFileUniform(j*ColNo+i)	,
		--OutpFilePack	=> OutpFilePack(j*ColNo+i)		 ,
		--OutpFileTime	=> OutpFileTime(j*ColNo+i)		,

		InpFilePoisson	=>	Str_Add(4,6,InpFilePoissonStr,InpFileUniform(j*ColNo+i))	,
		InpFileUniform	=>	InpFileUniform(j*ColNo+i)	,
		InpFileLAR		=>	Str_Add(4,6,LARStr,InpFileUniform(j*ColNo+i))	,
		InpFilePackLen	=>	Str_Add(4,6,LenStr,InpFileUniform(j*ColNo+i))	,
		OutpFilePack	=>	Str_Add(9,6,OutpFilePackStr,InpFileUniform(j*ColNo+i))		 ,
		OutpFileTime	=>	Str_Add(9,6,OutpFileTimeStr,InpFileUniform(j*ColNo+i))		,

		ViChAddr	=> ViChAddr		,
		PhyRoChAddr	=> PhyRoChAddr	,
		--			   --
		PhyCh		=> PhyCh		,
		ViCh		=> ViCh			,
		RoCh 		=> RoCh 		,
		PhyRoCh		=> PhyRoCh		,
		--			   --
		PackWidth	=> PackWidth	,
		DataWidth	=> DataWidth	,
		--			   --
		CurNode		=> j*ColNo+i	,
		--Y			=> j			,
		PackGen		=> PackGen(j*ColNo+i) ,
		PackGenNum	=> PackGenNum
		)
	Port Map(
		Clk				=> Clk			,
		Reset			=> Reset		,

		InpData			=> Data2(j*ColNo+i)	,
		InpEn			=> En2(j*ColNo+i)		,

		CreditOut		=> Credit2(j*ColNo+i)	,
		InpSel			=> Sel2(j*ColNo+i)		,

		OutpData		=> Data(j*ColNo+i),
		OutpEn			=> En(j*ColNo+i)	,

		CreditIn		=> Credit(j*ColNo+i),
		OutpSel			=> Sel(j*ColNo+i)	,

		SentCnt			=> SentCnt(j*ColNo+i)	,
		ReceCnt			=> ReceCnt(j*ColNo+i)	,
		AveReceTime		=> AveReceTime(j*ColNo+i),
		--sim
		StopSim			=> StopSim
	);
	End Generate;
End Generate;

End;
