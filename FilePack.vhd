-- NOCSynSim
-- Network on a Chip Synthesisable and Simulation VHDL Model
-- Version: 1.0 
-- Last Update: 2006/10/04
-- Sharif University of Technology
-- Computer Department
-- High Performance Computing Group - Dr.Sarbazi Azad
-- Author: D.Rahmati

Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use Std.textio.all;

package FilePack is
	
	type IntVector is array (natural range <>) of integer;
	Type IntVectorNx1 Is Array(natural range <>) of IntVector(1 to 1);

	procedure ReadFileV1(constant Len 		: in integer;
						constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal ReadEn		: in  std_logic;
						signal ReadEnI		: in  Unsigned;
						signal Stop			: in  boolean;
						signal Output		: out IntVectorNx1;
						signal Finished		: out boolean;
						signal DataValid	: out Unsigned
					);

	procedure WriteFile(constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal WriteEn		: in  std_logic;
						signal Stop			: in  boolean;
						signal Input		: in  IntVector;
						signal Finished		: out boolean
					);
					
	procedure WriteFile2(Constant WriteActive : in boolean; 
						constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal WriteEn		: in  std_logic;
						signal Stop			: in  boolean;
						signal Input		: in  IntVector;
						signal Finished		: out boolean
					);
					
	procedure Str_Add(
						constant len1 : in Integer;
						constant len2 : in Integer;    
						signal str1: in string;
						signal str2: in string;
						signal result: out  string
					);

  
		
	function Str_Int_Add2(
		constant len1 : in Integer;
		str1: in string;
		val: in Integer
		) return string;				
		
	function Str_Add(
		constant len1 : in Integer;
		constant len2 : in Integer;    
		str1: in string;
		str2: in string
		) return string;				
		
end;

package body FilePack is

    procedure Str_Add(
		constant len1 : in Integer;
		constant len2 : in Integer;    
		signal str1: in string;
		signal str2: in string;
		signal result: out  string)
    is
		variable buf : string(len1+len2 downto 1);
		variable pos : integer := 1;
    begin
		pos:=1;
		loop
			if (pos<=len1) then
				buf(pos) := str1(pos);
			else
				buf(pos) := str2(pos-len1);
			end if;	
			pos := pos + 1;
			exit when Pos>len1+len2;
		end loop;
		result <= buf;
    end Str_Add; -- procedure

    function Str_Int_Add2( 
		constant len1 : in Integer;
		str1: in string;
		val: in Integer
		) return string
    is
		variable buf : string(len1+1 downto 1);
		variable pos : integer := 1;
    begin
		pos:=1;
		loop
			if (pos=1) Then
				buf(pos) := character'val(character'pos('0') + val); 
			elsif (pos<=len1+1) then
				buf(pos) := str1(pos-1);			
			end if;	
			pos := pos + 1;
			exit when Pos>len1+1;
		end loop;
		return buf;
    end Str_Int_Add2; -- function
    
	function Str_Add(
		constant len1 : in Integer;
		constant len2 : in Integer;    
		str1: in string;
		str2: in string
		) return string			
    is
		variable buf : string(len1+len2 downto 1);
		variable pos : integer := 1;
    begin
		pos:=1;
		loop
			if (pos<=len2) then
				buf(pos) := str2(pos);			
			elsif (pos<=len1+len2) then
				buf(pos) := str1(pos-len2);			
			end if;	
			pos := pos + 1;
			exit when Pos>len1+len2;
		end loop;
		return buf;
    end Str_Add; -- function
    
	procedure ReadFileV1(constant Len 		: in integer;
						constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal ReadEn		: in  std_logic;
						signal ReadEnI		: in  Unsigned;
						signal Stop			: in  boolean;
						signal Output		: out IntVectorNx1; -- Len = N
						signal Finished		: out boolean;
						signal DataValid	: out Unsigned
					)
	is
		file inf:text;
		variable fstatus: FILE_OPEN_STATUS;
		variable lstr: LINE;
		variable good: boolean;
		variable int: integer;
		variable Outp	: IntVector(1 Downto 1);

	begin

		Finished <= false;
		DataValid(Len-1 Downto 0) <= (Others=>'0');
		FILE_OPEN(fstatus,inf,FileName,READ_MODE);
		if(fstatus/=OPEN_OK) then
			report "Cannot open input data file";
			Finished <= true;
			wait;
		end if;
		
		l1:while not ENDFILE(inf) loop

			wait until (rising_edge(Clock) and ReadEn='1') or Stop; 
			DataValid(Len-1 Downto 0) <= (Others=>'0');
			exit l1 when Stop;

			for k in Output'range loop
				If (ReadEnI(k)='1') Then
					READLINE(inf,Lstr);
					for i in Output(k)'range loop
						READ(Lstr,int,good);
						if(not good) then
							report "Bad data format, size mismatch";
							exit l1;
						end if;
						outp(i) := int;
					end loop;
					output(k) <= outp; 
				End If;	
				DataValid(k) <= '1';
				Exit l1 when (ENDFILE(inf));
			End Loop;
		end loop;
		
		wait until rising_edge(Clock) or Stop; 
		DataValid(Len-1 Downto 0) <=(Others=>'0');
		FILE_CLOSE(inf);
		Finished <= true;
		wait until rising_edge(Clock);
		return;
	end procedure;


	procedure WriteFile(constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal WriteEn		: in  std_logic;
						signal Stop			: in  boolean;
						signal Input		: in  IntVector;
						signal Finished		: out boolean
					)
	is
		file outf:text;
		variable fstatus: FILE_OPEN_STATUS;
		variable lstr: LINE;
		variable int: integer;

	begin

		Finished <= false;
		FILE_OPEN(fstatus,outf,FileName,WRITE_MODE);
		if(fstatus/=OPEN_OK) then
			report "Cannot open output data file";
			Finished <= true;
			wait;
		end if;
		
		l1:while not Stop loop

			wait until (rising_edge(Clock) and WriteEn='1') or Stop; 
			exit l1 when Stop;

			for i in Input'range loop
				int := input(i);
				WRITE(Lstr,int);
				WRITE(Lstr,string'(" "));
			end loop;

			WRITELINE(outf,Lstr);
		end loop;
		
		wait until rising_edge(Clock) or Stop; 
		FILE_CLOSE(outf);
		Finished <= true;
		wait until rising_edge(Clock);
		return;
	end procedure;

	procedure WriteFile2(Constant WriteActive : in boolean; 
						constant FileName	: in  string;
						signal Clock		: in  std_logic;
						signal WriteEn		: in  std_logic;
						signal Stop			: in  boolean;
						signal Input		: in  IntVector;
						signal Finished		: out boolean
					)
	is
		file outf:text;
		variable fstatus: FILE_OPEN_STATUS;
		variable lstr: LINE;
		variable int: integer;

	begin
		If (Not WriteActive) Then
			Return;
		End If;	
		
		Finished <= false;
		FILE_OPEN(fstatus,outf,FileName,WRITE_MODE);
		if(fstatus/=OPEN_OK) then
			report "Cannot open output data file";
			Finished <= true;
			wait;
		end if;
		
		l1:while not Stop loop

			wait until (rising_edge(Clock) and WriteEn='1') or Stop; 
			exit l1 when Stop;

			for i in Input'range loop
				int := input(i);
				WRITE(Lstr,int);
				WRITE(Lstr,string'(" "));
			end loop;

			WRITELINE(outf,Lstr);
		end loop;
		
		wait until rising_edge(Clock) or Stop; 
		FILE_CLOSE(outf);
		Finished <= true;
		wait until rising_edge(Clock);
		return;
	end procedure;

end;





