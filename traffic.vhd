-- ============================================================
-- Title      : Traffic Light Controller
-- Author     : Ananya Vaidya
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clr       : in std_logic;                       -- Asynchronous clear signal
        clk       : in std_logic;                       -- System clock
        mode      : in std_logic;                       -- Mode: '0' = Auto, '1' = Manual
        switch    : in std_logic_vector(3 downto 0);    -- Manual mode switch inputs
        green     : out std_logic_vector(3 downto 0);   -- Green lights for 4 directions
        yellow    : out std_logic_vector(3 downto 0);   -- Yellow lights for 4 directions
        red       : out std_logic_vector(3 downto 0);   -- Red lights for 4 directions
        zebraRed  : out std_logic_vector(1 downto 0);   -- Red signals for 2 zebra crossings
        zebraGreen: out std_logic_vector(1 downto 0)    -- Green signals for 2 zebra crossings
    );
end controller;

architecture arch of controller is

    type state_type is range 0 to 11;           -- 12 states for traffic light sequencing
    signal state      : state_type := 0;        -- Current state

    signal timeout    : std_logic := '0';       -- Flag to trigger state transition
    signal Tl, Ts     : std_logic := '0';       -- Long and short timer enable signals
    signal counter    : integer := 0;           -- Timer counter

    constant longCount  : integer := 30;        -- Duration for long timer state
    constant shortCount : integer := 10;        -- Duration for short timer state

begin

    -- Sequential state transition logic
    process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                state <= 0;  -- Reset to initial state
            elsif mode = '0' then  -- Auto Mode
                if timeout = '1' then
                    state <= (state + 1) mod 12;  -- Next state in sequence
                end if;
            else  -- Manual Mode
                -- Set state based on which switch is pressed
                if switch(3) = '1' then
                    state <= 4;
                elsif switch(2) = '1' then
                    state <= 2;
                elsif switch(1) = '1' then
                    state <= 10;
                elsif switch(0) = '1' then
                    state <= 8;
                end if;
            end if;
        end if;
    end process;

    -- Output logic based on current state
    process(state)
    begin
        -- Default all outputs to safe values
        green      <= (others => '0');
        yellow     <= (others => '0');
        red        <= (others => '1');          -- All red by default
        zebraRed   <= (others => '1');
        zebraGreen <= (others => '0');
        Tl <= '0';
        Ts <= '0';

        case state is
            -- East-West green and pedestrian crossing (NS zebra)
            when 0 =>
                green(3 downto 2) <= "11";
                red(3 downto 2)   <= "00";
                zebraGreen(0)    <= '1';
                zebraRed(0)      <= '0';
                Tl <= '1';

            -- East yellow transition
            when 1 =>
                green(3)   <= '0';
                yellow(3)  <= '1';
                red(3)     <= '0';
                Ts <= '1';

            -- NS zebra red, complete EW red
            when 2 =>
                yellow(3)      <= '0';
                red(3)         <= '1';
                zebraGreen(0)  <= '0';
                zebraRed(0)    <= '1';
                Tl <= '1';

            -- West yellow transition
            when 3 =>
                green(2)  <= '0';
                yellow(2) <= '1';
                red(2)    <= '0';
                Ts <= '1';

            -- Start new EW cycle
            when 4 =>
                yellow(2) <= '0';
                red(2)    <= '1';
                green(3)  <= '1';
                red(3)    <= '0';
                Tl <= '1';

            -- East yellow again
            when 5 =>
                green(3)  <= '0';
                yellow(3) <= '1';
                red(3)    <= '0';
                Ts <= '1';

            -- North-South green and pedestrian crossing (EW zebra)
            when 6 =>
                yellow(3)     <= '0';
                red(3)        <= '1';
                green(1 downto 0) <= "11";
                red(1 downto 0)   <= "00";
                zebraGreen(1)    <= '1';
                zebraRed(1)      <= '0';
                Tl <= '1';

            -- North yellow
            when 7 =>
                green(1)  <= '0';
                yellow(1) <= '1';
                red(1)    <= '0';
                Ts <= '1';

            -- EW zebra red, complete NS red
            when 8 =>
                yellow(1)     <= '0';
                red(1)        <= '1';
                zebraGreen(1) <= '0';
                zebraRed(1)   <= '1';
                Tl <= '1';

            -- South yellow
            when 9 =>
                green(0)  <= '0';
                yellow(0) <= '1';
                red(0)    <= '0';
                Ts <= '1';

            -- NS green again (North)
            when 10 =>
                yellow(0) <= '0';
                red(0)    <= '1';
                green(1)  <= '1';
                red(1)    <= '0';
                Tl <= '1';

            -- North yellow again
            when 11 =>
                green(1)  <= '0';
                yellow(1) <= '1';
                red(1)    <= '0';
                Ts <= '1';

            when others =>
                null;  -- Should never occur
        end case;
    end process;

    -- Timer logic for state timeouts
    process(clk)
    begin
        if rising_edge(clk) then
            timeout <= '0';  -- Default: no timeout
            if Tl = '1' then  -- Long timer active
                if counter < longCount then
                    counter <= counter + 1;
                else
                    timeout <= '1';  -- Trigger state change
                    counter <= 0;
                end if;
            elsif Ts = '1' then  -- Short timer active
                if counter < shortCount then
                    counter <= counter + 1;
                else
                    timeout <= '1';
                    counter <= 0;
                end if;
            else
                counter <= 0;  -- Reset counter if no timer active
            end if;
        end if;
    end process;

end arch;
