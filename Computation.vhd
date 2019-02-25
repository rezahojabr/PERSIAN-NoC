-- NOCSynSim
-- Network on a Chip Synthesisable and Simulation VHDL Model
-- Version: 1.0
-- Last Update: 2006/10/04
-- University of Tehran
-- Computer Department
-- High Performance Computing Group - Dr.Sarbazi Azad
-- Author: D.Rahmati

Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
use work.FilePack.all;
Use Work.ConnectionPack.All;

use STD.textio.all;                     -- basic I/O
use IEEE.std_logic_textio.all;          -- I/O for logic types

entity Computation is
Generic(
		--RowNo		: Integer := 4;
		--ColNo		: Integer := 4;
 		PackGenNum  : Unsigned(15 Downto 0) := To_Unsigned(5,16);
 		PackGen     : Unsigned(RowNo*ColNo-1 Downto 0):=(Others=>'1')
 		);
	Port(
		Clk				: In  std_logic;
		Reset			: In  std_logic;

		SentCnt			: In UnsignedArr16(RowNo*ColNo-1 Downto 0);
		ReceCnt			: In UnsignedArr16(RowNo*ColNo-1 Downto 0);
		AveReceTime		: In UnsignedArr20(RowNo*ColNo-1 Downto 0);
		StopOut			: Out Std_Logic;
		StopSim			: In Std_Logic
	);
End;


Architecture behavioral of Computation is

Signal 	SentAllCnt	: Unsigned(19 Downto 0);
Signal	ReceAllCnt	: Unsigned(19 Downto 0);
Signal	AveReceTimeAll	: Unsigned(19 Downto 0);

Signal 	PreSentAllCnt	: Unsigned(19 Downto 0);
Signal	PreReceAllCnt	: Unsigned(19 Downto 0);
Signal	PreAveReceTimeAll	: Unsigned(19 Downto 0);

signal WriteFin1:boolean;
signal WriteFin2:boolean;
signal WriteFin3:boolean;
signal Stop:	Boolean;
signal TDataSent:	IntVector(1 to 1);
signal TDataRece:	IntVector(1 to 1);
signal TDataAveTime:	IntVector(1 to 1);
signal WriteSentCnt : Std_Logic;
signal WriteReceCnt : Std_Logic;
signal WriteAveTimeRece : Std_Logic;
Signal 	TotalPacks	: Integer:=0;
Signal Fault	:	Std_Logic;

Begin


 my_print : process is                  -- a process is parallel
               variable my_line : line;  -- type 'line' comes from textio
             begin
               write(my_line, string'("Landa:"));   -- formatting
               write(my_line, PoissonDelayStr);   -- formatting
               write(my_line, string'("  , Node Pack Number:"));   -- formatting
               write(my_line, To_Integer(PackGenNum));   -- formatting
               write(my_line, string'("  , Total Pack Number:"));   -- formatting
               write(my_line, To_Integer(PackGenNum)*RowNo*ColNo);   -- formatting
               writeline(output, my_line);               -- write to "output"
              -- write(my_line, string'("four_32 = "));    -- formatting
              -- hwrite(my_line, four_32); -- format type std_logic_vector as hex
              -- write(my_line, string'("  counter= "));
              --- write(my_line, counter);  -- format 'counter' as integer
              -- write(my_line, string'(" at time "));
              -- write(my_line, now);                     -- format time
              -- writeline(output, my_line);              -- write to display
               wait;
             end process my_print;

		StopOut <= '1' When (SentAllCnt>=TotalPacks) And (ReceAllCnt>=TotalPacks) Else '0';
		Fault	<= '1' When	(SentAllCnt<ReceAllCnt)	Else '0';
		fw1: WriteFile(	FileName	=> "SentCount.txt",
						Clock		=> Clk,
						WriteEn		=> WriteSentCnt,
						Stop		=> Stop,
						Input		=> TDataSent,
						Finished	=> WriteFin1);

		fw2: WriteFile(	FileName	=> "ReceCount.txt",
						Clock		=> Clk,
						WriteEn		=> WriteReceCnt,
						Stop		=> Stop,
						Input		=> TDataRece,
						Finished	=> WriteFin2);

		fw3: WriteFile(	FileName	=> "AverageTime.txt",
						Clock		=> Clk,
						WriteEn		=> WriteAveTimeRece,
						Stop		=> Stop,
						Input		=> TDataAveTime,
						Finished	=> WriteFin3);

		TDataSent(1) <= To_Integer(PreSentAllCnt);
		TDataRece(1) <= To_Integer(PreReceAllCnt);
		TDataAveTime(1) <= To_Integer(PreAveReceTimeAll);
		Stop <= (StopSim='1') Or (WriteFin3 And WriteFin2 And WriteFin1);

		Process
		Variable 	VTotalPacks	: Integer:=0;
		Begin
				For i in 0 to RowNo*ColNo-1 loop
					If (PackGen(i)='1') Then
						VTotalPacks := VTotalPacks + To_Integer(PackGenNum);
					End If;
				End Loop;
				TotalPacks <= VTotalPacks;
				Wait;
		End Process;

		--'$display('Rece Count is %d', ReceAllCnt);

		Process (Clk)
		Variable 	VSentAllCnt	: Unsigned(19 Downto 0);
		Variable	VReceAllCnt	: Unsigned(19 Downto 0);
		Variable	VSumAveReceTime	: Unsigned(19+4 Downto 0);
		Variable NumberVar : Integer;
        variable my_line : line;  -- type 'line' comes from textio
		Begin
			If (Rising_Edge(Clk)) Then
				If (Reset='1') Then
					SentAllCnt <= (Others=>'0');
					ReceAllCnt <= (Others=>'0');
					NumberVar := 0;
				Else
					VSentAllCnt := (Others=>'0');
					VReceAllCnt := (Others=>'0');
					VSumAveReceTime := (Others=>'0');
					NumberVar := 0;
					For i in 0 to RowNo*ColNo-1 loop
						VSentAllCnt := VSentAllCnt + To_Integer(SentCnt(i));
						VReceAllCnt := VReceAllCnt + To_Integer(ReceCnt(i));
						--
						VSumAveReceTime := VSumAveReceTime+To_Integer(AveReceTime(i));
						If (AveReceTime(i)/=0) Then
							NumberVar := NumberVar + 1;
						End If;
						--
					End loop;
					SentAllCnt <= VSentAllCnt;
					ReceAllCnt <= VReceAllCnt;
					--AveReceTimeAll <= To_Unsigned(To_Integer(VSumAveReceTime/(RowNo*ColNo)),20);
					If (NumberVar/=0) Then
						AveReceTimeAll <= To_Unsigned(To_Integer(VSumAveReceTime/(NumberVar)),20);
					Else
						AveReceTimeAll <= (Others=>'0');
					End If;
					--
					PreSentAllCnt <= SentAllCnt;
					PreReceAllCnt <= ReceAllCnt;
					PreAveReceTimeAll <= AveReceTimeAll;
					If (PreSentAllCnt/=SentAllCnt) Then
						WriteSentCnt <= '1';
					Else
						WriteSentCnt <= '0';
					End If;
					If (PreReceAllCnt/=ReceAllCnt) Then
            			--REPORT "Received Packs:" & String(ReceAllCnt);

            			If((ReceAllCnt mod 100)=0) Or (ReceAllCnt>=To_Integer(PackGenNum)*RowNo*ColNo) Then
							write(my_line, string'("Rece Pack Cnt: "));   -- formatting
							write(my_line, To_Integer(ReceAllCnt));   -- formatting
							write(my_line, string'("   , Ave Pack Delay: "));   -- formatting
							write(my_line, To_Integer(AveReceTimeAll));   -- formatting
							writeline(output, my_line);               -- write to "output"
						End If;



						WriteReceCnt <= '1';
					Else
						WriteReceCnt <= '0';
					End If;
					If (PreAveReceTimeAll/=AveReceTimeAll) Then
						WriteAveTimeRece <= '1';
					Else
						WriteAveTimeRece <= '0';
					End If;
				End If;
			End If;
		End Process;


End;
