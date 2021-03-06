----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:23:24 09/23/2016 
-- Design Name: 
-- Module Name:    lab1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --use CONV_INTEGER


ENTITY encryption IS
 PORT  (
  enc_clr: IN STD_LOGIC := '0';  -- asynchronous reset
  enc_clk: IN STD_LOGIC;  -- Clock signal
  enc_din: IN STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit i/p
  enc_di_vld: IN STD_LOGIC;  -- input is valid
  enc_dout: OUT STD_LOGIC_VECTOR(63 DOWNTO 0);--64-bit o/p
  enc_do_rdy: OUT STD_LOGIC := '0'--answer is ready when '1'
  );
END encryption;


ARCHITECTURE rtl OF encryption IS
  
  SIGNAL i_cnt: STD_LOGIC_VECTOR(3 DOWNTO 0);  --upcounter
  SIGNAL a_reg: STD_LOGIC_VECTOR(31 DOWNTO 0);  --register to store value A
  SIGNAL b_reg: STD_LOGIC_VECTOR(31 DOWNTO 0);  --register to store value B
  SIGNAL ab_xor: STD_LOGIC_VECTOR(31 DOWNTO 0);  --AB internal signals
  SIGNAL ab_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a_pre: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ba_xor: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL ba_rot: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b_pre: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL a: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL b: STD_LOGIC_VECTOR(31 DOWNTO 0);
    
  --state machine (4 states)
  TYPE  StateType IS (ST_IDLE, --
                      ST_PRE_ROUND, -- RC5 pre-round op is performed 
                      ST_ROUND_OP, -- RC5 round op is performed. The system remains in this state for twelve clock cycles.
                      ST_READY);
							 
  SIGNAL  state : StateType := ST_IDLE; --store the state in a variable called 'state'
	
  TYPE rom IS ARRAY (0 TO 25) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
  CONSTANT skey : rom:=rom'(x"9bbbd8c8", x"1a37f7fb", x"46F8E8C5", x"460C6085",
									  x"70F83B8A", x"284B8303", x"513E1454", x"F621ED22",
									  x"3125065D", x"11A83A5D", x"D427686B", x"713AD82D",
									  x"4B792F99", x"2799A4DD", x"A7901C49", x"DEDE871A",
									  x"36C03196", x"A7EFC249", x"61A78BB8", x"3B0A1D2B",
									  x"4DBFCA76", x"AE162167", x"30D76B0A", x"43192304",
									  x"F6CC1431", x"65046380");

begin 

partA : process(ab_xor, a_reg, b_reg, ab_rot, i_cnt, enc_din) 	--A=((A XOR B)<<<B) + S[2�i];
begin

ab_xor <= (a_reg) XOR (b_reg);

case b_reg(4 DOWNTO 0) is
	WHEN "00001" => ab_rot <= ab_xor(30 DOWNTO 0) & ab_xor(31);
	WHEN "00010" => ab_rot <= ab_xor(29 DOWNTO 0) & ab_xor(31 DOWNTO 30); 
	WHEN "00011" => ab_rot <= ab_xor(28 DOWNTO 0) & ab_xor(31 DOWNTO 29);
	WHEN "00100" => ab_rot <= ab_xor(27 DOWNTO 0) & ab_xor(31 DOWNTO 28);
	WHEN "00101" => ab_rot <= ab_xor(26 DOWNTO 0) & ab_xor(31 DOWNTO 27);
	WHEN "00110" => ab_rot <= ab_xor(25 DOWNTO 0) & ab_xor(31 DOWNTO 26);
	WHEN "00111" => ab_rot <= ab_xor(24 DOWNTO 0) & ab_xor(31 DOWNTO 25);
	WHEN "01000" => ab_rot <= ab_xor(23 DOWNTO 0) & ab_xor(31 DOWNTO 24);
	WHEN "01001" => ab_rot <= ab_xor(22 DOWNTO 0) & ab_xor(31 DOWNTO 23);
	WHEN "01010" => ab_rot <= ab_xor(21 DOWNTO 0) & ab_xor(31 DOWNTO 22);
	WHEN "01011" => ab_rot <= ab_xor(20 DOWNTO 0) & ab_xor(31 DOWNTO 21);
	WHEN "01100" => ab_rot <= ab_xor(19 DOWNTO 0) & ab_xor(31 DOWNTO 20);
	WHEN "01101" => ab_rot <= ab_xor(18 DOWNTO 0) & ab_xor(31 DOWNTO 19);
	WHEN "01110" => ab_rot <= ab_xor(17 DOWNTO 0) & ab_xor(31 DOWNTO 18);
	WHEN "01111" => ab_rot <= ab_xor(16 DOWNTO 0) & ab_xor(31 DOWNTO 17);
	WHEN "10000" => ab_rot <= ab_xor(15 DOWNTO 0) & ab_xor(31 DOWNTO 16);
	WHEN "10001" => ab_rot <= ab_xor(14 DOWNTO 0) & ab_xor(31 DOWNTO 15);
	WHEN "10010" => ab_rot <= ab_xor(13 DOWNTO 0) & ab_xor(31 DOWNTO 14);
	WHEN "10011" => ab_rot <= ab_xor(12 DOWNTO 0) & ab_xor(31 DOWNTO 13);
	WHEN "10100" => ab_rot <= ab_xor(11 DOWNTO 0) & ab_xor(31 DOWNTO 12);
	WHEN "10101" => ab_rot <= ab_xor(10 DOWNTO 0) & ab_xor(31 DOWNTO 11);
	WHEN "10110" => ab_rot <= ab_xor(9 DOWNTO 0) & ab_xor(31 DOWNTO 10);
	WHEN "10111" => ab_rot <= ab_xor(8 DOWNTO 0) & ab_xor(31 DOWNTO 9);
	WHEN "11000" => ab_rot <= ab_xor(7 DOWNTO 0) & ab_xor(31 DOWNTO 8);
	WHEN "11001" => ab_rot <= ab_xor(6 DOWNTO 0) & ab_xor(31 DOWNTO 7);
	WHEN "11010" => ab_rot <= ab_xor(5 DOWNTO 0) & ab_xor(31 DOWNTO 6);
	WHEN "11011" => ab_rot <= ab_xor(4 DOWNTO 0) & ab_xor(31 DOWNTO 5);
	WHEN "11100" => ab_rot <= ab_xor(3 DOWNTO 0) & ab_xor(31 DOWNTO 4);
	WHEN "11101" => ab_rot <= ab_xor(2 DOWNTO 0) & ab_xor(31 DOWNTO 3);
	WHEN "11110" => ab_rot <= ab_xor(1 DOWNTO 0) & ab_xor(31 DOWNTO 2);
	WHEN "11111" => ab_rot <= ab_xor(0) & ab_xor(31 DOWNTO 1);
	WHEN OTHERS => ab_rot <= ab_xor;
END CASE;

--store new a.
a<=ab_rot + skey(CONV_INTEGER(i_cnt & '0')); --S[2�i]
a_pre <= enc_din(63 DOWNTO 32) + skey(0); -- A = A + S[0]

END PROCESS partA;


partB : process(a, ba_xor, ba_rot, i_cnt, enc_din) 
begin

ba_xor <= b_reg XOR a;

case a(4 DOWNTO 0) is
WHEN "00001" => ba_rot <= ba_xor(30 DOWNTO 0) & ba_xor(31);
WHEN "00010" => ba_rot <= ba_xor(29 DOWNTO 0) & ba_xor(31 DOWNTO 30); 
WHEN "00011" => ba_rot <= ba_xor(28 DOWNTO 0) & ba_xor(31 DOWNTO 29);
WHEN "00100" => ba_rot <= ba_xor(27 DOWNTO 0) & ba_xor(31 DOWNTO 28);
WHEN "00101" => ba_rot <= ba_xor(26 DOWNTO 0) & ba_xor(31 DOWNTO 27);
WHEN "00110" => ba_rot <= ba_xor(25 DOWNTO 0) & ba_xor(31 DOWNTO 26);
WHEN "00111" => ba_rot <= ba_xor(24 DOWNTO 0) & ba_xor(31 DOWNTO 25);
WHEN "01000" => ba_rot <= ba_xor(23 DOWNTO 0) & ba_xor(31 DOWNTO 24);
WHEN "01001" => ba_rot <= ba_xor(22 DOWNTO 0) & ba_xor(31 DOWNTO 23);
WHEN "01010" => ba_rot <= ba_xor(21 DOWNTO 0) & ba_xor(31 DOWNTO 22);
WHEN "01011" => ba_rot <= ba_xor(20 DOWNTO 0) & ba_xor(31 DOWNTO 21);
WHEN "01100" => ba_rot <= ba_xor(19 DOWNTO 0) & ba_xor(31 DOWNTO 20);
WHEN "01101" => ba_rot <= ba_xor(18 DOWNTO 0) & ba_xor(31 DOWNTO 19);
WHEN "01110" => ba_rot <= ba_xor(17 DOWNTO 0) & ba_xor(31 DOWNTO 18);
WHEN "01111" => ba_rot <= ba_xor(16 DOWNTO 0) & ba_xor(31 DOWNTO 17);
WHEN "10000" => ba_rot <= ba_xor(15 DOWNTO 0) & ba_xor(31 DOWNTO 16);
WHEN "10001" => ba_rot <= ba_xor(14 DOWNTO 0) & ba_xor(31 DOWNTO 15);
WHEN "10010" => ba_rot <= ba_xor(13 DOWNTO 0) & ba_xor(31 DOWNTO 14);
WHEN "10011" => ba_rot <= ba_xor(12 DOWNTO 0) & ba_xor(31 DOWNTO 13);
WHEN "10100" => ba_rot <= ba_xor(11 DOWNTO 0) & ba_xor(31 DOWNTO 12);
WHEN "10101" => ba_rot <= ba_xor(10 DOWNTO 0) & ba_xor(31 DOWNTO 11);
WHEN "10110" => ba_rot <= ba_xor(9 DOWNTO 0) & ba_xor(31 DOWNTO 10);
WHEN "10111" => ba_rot <= ba_xor(8 DOWNTO 0) & ba_xor(31 DOWNTO 9);
WHEN "11000" => ba_rot <= ba_xor(7 DOWNTO 0) & ba_xor(31 DOWNTO 8);
WHEN "11001" => ba_rot <= ba_xor(6 DOWNTO 0) & ba_xor(31 DOWNTO 7);
WHEN "11010" => ba_rot <= ba_xor(5 DOWNTO 0) & ba_xor(31 DOWNTO 6);
WHEN "11011" => ba_rot <= ba_xor(4 DOWNTO 0) & ba_xor(31 DOWNTO 5);
WHEN "11100" => ba_rot <= ba_xor(3 DOWNTO 0) & ba_xor(31 DOWNTO 4);
WHEN "11101" => ba_rot <= ba_xor(2 DOWNTO 0) & ba_xor(31 DOWNTO 3);
WHEN "11110" => ba_rot <= ba_xor(1 DOWNTO 0) & ba_xor(31 DOWNTO 2);
WHEN "11111" => ba_rot <= ba_xor(0) & ba_xor(31 DOWNTO 1);
WHEN OTHERS => ba_rot <= ba_xor;
END CASE;

--store new b
b<=ba_rot+skey(CONV_INTEGER(i_cnt & '1'));--S[2�i+1]

b_pre <= enc_din(31 DOWNTO 0) + skey(1);  -- B = B + S[1]

END PROCESS partB;

--output
enc_dout<=a_reg & b_reg;

--dout ready
WITH state SELECT
enc_do_rdy<= '1' WHEN ST_READY,
				 '0' WHEN OTHERS;


-- a_reg 
--if clr = 0, store a from din. else store new a for next time.
PROCESS(enc_clr, enc_clk)  BEGIN
  IF(enc_clr='0') THEN a_reg <=(OTHERS=>'0');
  ELSIF(enc_clk'EVENT AND enc_clk='1') THEN --on rising edge
	  IF(state=ST_PRE_ROUND) THEN 
			a_reg<=a_pre;
	  ELSIF(state=ST_ROUND_OP) THEN 
			a_reg<=a; END IF;
  END IF;
END PROCESS;

-- b_reg if clr = 0, store b from din. else store b
PROCESS(enc_clr, enc_clk)  BEGIN
  IF(enc_clr='0') THEN b_reg<=(OTHERS=>'0');
  ELSIF(enc_clk'EVENT AND enc_clk='1') THEN 
	  IF(state=ST_PRE_ROUND) THEN   b_reg<=b_pre;
	  ELSIF(state=ST_ROUND_OP) THEN   b_reg<=b; END IF;
  END IF;
END PROCESS; 


--state machine
PROCESS(enc_clr, enc_clk)
   BEGIN
      IF(enc_clr='0') THEN  --start idle
         state<=ST_IDLE;
			i_cnt<= "0001";
		ELSIF(enc_clk'EVENT AND enc_clk='1') THEN   --on clock high, change the state if nessisary 
         CASE state IS
            WHEN ST_IDLE=> IF(enc_di_vld='1') THEN state<=ST_PRE_ROUND;  --if data valid change to preround
									END IF;
            WHEN ST_PRE_ROUND=> state<=ST_ROUND_OP;  --if preround, start round
            WHEN ST_ROUND_OP=> IF(i_cnt="1100") THEN 
				                   state<=ST_READY; 
										 i_cnt<= "0001";  --if round, move to ready when done 
										 ELSE
										 i_cnt<=i_cnt+'1';
										 END IF;
				WHEN ST_READY=> state <= ST_IDLE; --enc_do_rdy<= '1';												
         END CASE;
      END IF;
END PROCESS;

end rtl;