-- ============================================================
-- Title      : Testbench for Traffic Light Controller
-- Author     : Ananya Vaidya
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;

-- Testbench entity with no ports
entity controller_tb is
end controller_tb;

architecture behavior of controller_tb is

    -- Component Declaration of the Unit Under Test (UUT)
    component controller
        port(
            clr         : in std_logic;                          -- Asynchronous reset
            clk         : in std_logic;                          -- Clock signal
            mode        : in std_logic;                          -- Mode select: '0' = auto, '1' = manual
            switch      : in std_logic_vector(3 downto 0);       -- Manual switch inputs
            green       : out std_logic_vector(3 downto 0);      -- Green signal for 4 directions
            yellow      : out std_logic_vector(3 downto 0);      -- Yellow signal for 4 directions
            red         : out std_logic_vector(3 downto 0);      -- Red signal for 4 directions
            zebraRed    : out std_logic_vector(1 downto 0);      -- Red for pedestrian (zebra) crossings
            zebraGreen  : out std_logic_vector(1 downto 0)       -- Green for pedestrian (zebra) crossings
        );
    end component;

    -- Signal declarations to connect to the UUT
    signal clk         : std_logic := '0';
    signal clr         : std_logic := '0';
    signal mode        : std_logic := '0';
    signal switch      : std_logic_vector(3 downto 0) := (others => '0');

    signal green       : std_logic_vector(3 downto 0);
    signal yellow      : std_logic_vector(3 downto 0);
    signal red         : std_logic_vector(3 downto 0);
    signal zebraRed    : std_logic_vector(1 downto 0);
    signal zebraGreen  : std_logic_vector(1 downto 0);

    constant clk_period : time := 10 ns;  -- Clock period definition

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: controller port map (
        clr => clr,
        clk => clk,
        mode => mode,
        switch => switch,
        green => green,
        yellow => yellow,
        red => red,
        zebraRed => zebraRed,
        zebraGreen => zebraGreen
    );

    -- Clock generation process: generates a clock with defined period
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process to provide inputs to the UUT and observe output behavior
    stim_proc: process
    begin
        -- Apply reset
        clr <= '1';
        wait for clk_period * 2;
        clr <= '0';

        -- Wait in automatic mode to observe state transitions
        wait for clk_period * 600;  -- Simulate multiple auto state changes (~6 μs)

        -- Switch to manual mode
        mode <= '1';
        wait for clk_period * 5;

        -- Simulate manual override for E-W direction (switch(3) = '1')
        switch <= "1000";
        wait for clk_period * 10;
        switch <= "0000";
        wait for clk_period * 10;

        -- Simulate manual override for N-S direction (switch(1) = '1')
        switch <= "0010";
        wait for clk_period * 10;
        switch <= "0000";
        wait for clk_period * 10;

        -- Switch back to automatic mode
        mode <= '0';
        wait for clk_period * 200;

        -- End of simulation
        wait;
    end process;

end behavior;
