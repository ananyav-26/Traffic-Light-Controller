library ieee;
use ieee.std_logic_1164.all;

entity controller_tb is
end controller_tb;

architecture behavior of controller_tb is

    -- Component Declaration
    component controller
        port(
            clr         : in std_logic;
            clk         : in std_logic;
            mode        : in std_logic;
            switch      : in std_logic_vector(3 downto 0);
            green       : out std_logic_vector(3 downto 0);
            yellow      : out std_logic_vector(3 downto 0);
            red         : out std_logic_vector(3 downto 0);
            zebraRed    : out std_logic_vector(1 downto 0);
            zebraGreen  : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Signals
    signal clk         : std_logic := '0';
    signal clr         : std_logic := '0';
    signal mode        : std_logic := '0';
    signal switch      : std_logic_vector(3 downto 0) := (others => '0');

    signal green       : std_logic_vector(3 downto 0);
    signal yellow      : std_logic_vector(3 downto 0);
    signal red         : std_logic_vector(3 downto 0);
    signal zebraRed    : std_logic_vector(1 downto 0);
    signal zebraGreen  : std_logic_vector(1 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate UUT
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

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Reset and Simulation Control
    stim_proc: process
    begin
        -- Reset
        clr <= '1';
        wait for clk_period * 2;
        clr <= '0';

        -- Wait in auto mode
        wait for clk_period * 600;  -- simulate ~6μs = 600ns to observe multiple state transitions

        -- Now switch to manual mode
        mode <= '1';
        wait for clk_period * 5;

        -- Select E-W manual (switch(3))
        switch <= "1000";
        wait for clk_period * 10;
        switch <= "0000";
        wait for clk_period * 10;

        -- Select N-S manual (switch(1))
        switch <= "0010";
        wait for clk_period * 10;
        switch <= "0000";
        wait for clk_period * 10;

        -- Back to auto mode
        mode <= '0';
        wait for clk_period * 200;

        -- End simulation
        wait;
    end process;

end behavior;
