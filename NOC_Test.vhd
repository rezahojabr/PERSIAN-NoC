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
Use Work.ConnectionPack.All;


entity NOC_Test is
end;


architecture behavioral of NOC_Test is

--Constant RowNo: Integer :=8;
--Constant ColNo: Integer :=8;





constant Period : time := 10 ns;
--shared variable StopSim : boolean := false;

signal  Stop,Stop2	: Boolean;
Signal	Clk			: std_logic:='0';
Signal	Reset		: std_logic:='0';
Signal	SentCnt		: UnsignedArr16(RowNo*ColNo-1 Downto 0);
Signal	ReceCnt		: UnsignedArr16(RowNo*ColNo-1 Downto 0);
Signal 	StopSim		: Std_Logic;
Signal 	StopOut		: Std_Logic;
Signal	AveReceTime	: UnsignedArr20(RowNo*ColNo-1 Downto 0);


begin


cm: entity work.Computation
	Generic Map(
		--RowNo		,
		--ColNo		,
		PackGenNum	,
		PackGen)
	Port map(
		Clk				,
		Reset			,

		SentCnt			,
		ReceCnt			,
		AveReceTime		,
		StopOut			,
		StopSim
	);

c1:entity work.NOC
	Generic Map(
		--RowNo		,
		--ColNo		,
		PackWidth	,
		DataWidth	,
		AddrWidth	,

		RoChAddr	,
		PhyChAddr	,
		ViChAddr	,
		PhyRoChAddr	,
		RoCh		,
		PhyCh		,
		ViCh		,
		PhyRoCh		,
		PoissonDelayStr,
		InpFileUniform(0 to ColNo*RowNo-1),

		PackGenNum	,
		PackGen)
port map(
		Clk				,
		Reset			,
		SentCnt			,
		ReceCnt			,
		AveReceTime		,
		StopSim
		);


	clk1: process
	begin
		while not Stop2 loop
			wait for Period/2;
			Clk <= not Clk;
		end loop;
		wait;
	end process;

	Stop <= False , True After Period*500 When ((StopOut='1') Or (Now>=150000*Period)) ;-- 30000*Period;
	Stop2 <= Stop After Period;

	StopSim <= '1' When (Stop) Else '0';

	ci:process
	begin

		Reset	<= '1';
		Wait for Period;
		wait until (rising_edge(Clk));-- 0-
		Reset	<= '0';
		wait;
	end process;


end;
