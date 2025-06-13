library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port(
        clr       : in std_logic;
        clk       : in std_logic;
        mode      : in std_logic;
        switch    : in std_logic_vector(3 downto 0);
        green     : out std_logic_vector(3 downto 0);
        yellow    : out std_logic_vector(3 downto 0);
        red       : out std_logic_vector(3 downto 0);
        zebraRed  : out std_logic_vector(1 downto 0);
        zebraGreen: out std_logic_vector(1 downto 0)
    );
end controller;

architecture arch of controller is

    type state_type is range 0 to 11;
    signal state      : state_type := 0;

    signal timeout    : std_logic := '0';
    signal Tl, Ts     : std_logic := '0';
    signal counter    : integer := 0;

    constant longCount  : integer := 30;
    constant shortCount : integer := 10;

begin

    -- Sequential State Transition Logic
    process(clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                state <= 0;
            elsif mode = '0' then  -- Auto Mode
                if timeout = '1' then
                    state <= (state + 1) mod 12;
                end if;
            else  -- Manual Mode
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

    -- Output Logic
    process(state)
    begin
        -- Default all outputs to 0 or safe state
        green      <= (others => '0');
        yellow     <= (others => '0');
        red        <= (others => '1');  -- Default red
        zebraRed   <= (others => '1');
        zebraGreen <= (others => '0');
        Tl <= '0';
        Ts <= '0';

        case state is
            when 0 =>
                green(3 downto 2) <= "11";  -- E-W green
                red(3 downto 2)   <= "00";
                zebraGreen(0)    <= '1';  -- NS zebra green
                zebraRed(0)      <= '0';
                Tl <= '1';

            when 1 =>
                green(3)   <= '0';
                yellow(3)  <= '1';
                red(3)     <= '0';
                Ts <= '1';

            when 2 =>
                yellow(3)      <= '0';
                red(3)         <= '1';
                zebraGreen(0)  <= '0';
                zebraRed(0)    <= '1';
                Tl <= '1';

            when 3 =>
                green(2)  <= '0';
                yellow(2) <= '1';
                red(2)    <= '0';
                Ts <= '1';

            when 4 =>
                yellow(2) <= '0';
                red(2)    <= '1';
                green(3)  <= '1';
                red(3)    <= '0';
                Tl <= '1';

            when 5 =>
                green(3)  <= '0';
                yellow(3) <= '1';
                red(3)    <= '0';
                Ts <= '1';

            when 6 =>
                yellow(3)     <= '0';
                red(3)        <= '1';
                green(1 downto 0) <= "11";  -- NS green
                red(1 downto 0)   <= "00";
                zebraGreen(1)    <= '1';    -- EW zebra green
                zebraRed(1)      <= '0';
                Tl <= '1';

            when 7 =>
                green(1)  <= '0';
                yellow(1) <= '1';
                red(1)    <= '0';
                Ts <= '1';

            when 8 =>
                yellow(1)     <= '0';
                red(1)        <= '1';
                zebraGreen(1) <= '0';
                zebraRed(1)   <= '1';
                Tl <= '1';

            when 9 =>
                green(0)  <= '0';
                yellow(0) <= '1';
                red(0)    <= '0';
                Ts <= '1';

            when 10 =>
                yellow(0) <= '0';
                red(0)    <= '1';
                green(1)  <= '1';
                red(1)    <= '0';
                Tl <= '1';

            when 11 =>
                green(1)  <= '0';
                yellow(1) <= '1';
                red(1)    <= '0';
                Ts <= '1';

            when others =>
                null;
        end case;
    end process;

    -- Timer Process
    process(clk)
    begin
        if rising_edge(clk) then
            timeout <= '0';
            if Tl = '1' then
                if counter < longCount then
                    counter <= counter + 1;
                else
                    timeout <= '1';
                    counter <= 0;
                end if;
            elsif Ts = '1' then
                if counter < shortCount then
                    counter <= counter + 1;
                else
                    timeout <= '1';
                    counter <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

end arch;
