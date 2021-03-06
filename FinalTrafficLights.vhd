library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FinalTrafficLights is
    Port ( 
           CLK 			:	in  STD_LOGIC;	-- input clock
           reset		:	in  STD_LOGIC;	-- resets state
           touch		:	in	STD_LOGIC;	-- touch sensor
           -- 7 segment display
           S			:	out	STD_LOGIC_VECTOR(6 downto 0);
           -- different lights 
           GreenLight 	:	out  STD_LOGIC;
           YellowLight	:	out  STD_LOGIC;
           RedLight		:	out  STD_LOGIC;
           GreenWalk	:	out  STD_LOGIC;
           RedWalk		:	out  STD_LOGIC
           );
end FinalTrafficLights;

architecture arc of FinalTrafficLights is
    signal clk_div : STD_LOGIC_VECTOR (31 downto 0):= X"00000000";
    shared variable num : integer := 25; --speed of state trancition
    shared variable touchCount	:	integer	range 0 to 6:=	0; -- variable that keeps track of the amount of touches
	type State_type IS (GreenTraffic, YellowTraffic, RedTraffic);	--State definitions
	signal State: State_type;	--create signals for states
begin

    -- clock divider
    process (CLK)
    begin
        if rising_edge(CLK) then
            clk_div <= clk_div + '1';
        end if;
    end process;
    
    -- State Rotation
    process (clk_div(num), reset, touch)
    begin
		--count the amount of times it is touched
		if (not touch = '1') then
			touchCount := touchCount + 1;
		end if;
		--if reset set state to GreenTraffic
		if (reset = '1') then
			State <= GreenTraffic;
			num := 25;
			touchCount := 0;
        elsif rising_edge(clk_div(num)) then --every rising edge start a state
			Case State is
				When GreenTraffic =>
					State <= YellowTraffic;
				When YellowTraffic =>
					num := num + touchCount; --before the RedTraffic State change clock rising edge
					State <= RedTraffic;
				When others =>
					num := 25; --before the GreenTraffic State reset the original rising edge
					State <= GreenTraffic;
			end Case;
        end if;
    end process;
-- When/else statement that displays numbers from 0-6 on the 7-segment display
S <= 	"1000000" when (touchCount = 0) else
		"1111001" when (touchCount = 1) else
		"0100100" when (touchCount = 2) else
		"0110000" when (touchCount = 3) else
		"0011001" when (touchCount = 4) else
		"0010010" when (touchCount = 5) else
		"0000010" ;
--lights defined according to state
GreenLight	<= '1' When State = GreenTraffic else '0';
YellowLight	<= '1' When State = YellowTraffic else '0';
RedLight	<= '1' When State = RedTraffic else '0';
GreenWalk	<= '1' When State = RedTraffic else '0';
RedWalk		<= '1' When (State = GreenTraffic or State = YellowTraffic) else '0';
  
end arc;