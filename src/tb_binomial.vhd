library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_binomial is
end tb_binomial;

architecture Behavioral of tb_binomial is
    component binomial is
        port (
            clk,rst,start: in std_logic;
            n,k: in std_logic_vector(2 downto 0);
            data_out: out std_logic_vector(6 downto 0);
            ready: out std_logic
        );
    end component binomial;
    
    signal clk_s,rst_s,start_s,ready_s,ready_FSMD_s: std_logic;
    signal n_s,k_s: std_logic_vector(2 downto 0);
    signal data_out_s,data_out_FSMD_s: std_logic_vector(6 downto 0);
    
    for HLSM:binomial use entity work.binomial(HLSM);
    for FSMD:binomial use entity work.binomial(FSMD);
    constant clkper: time := 10 ns;
begin
    HLSM: binomial port map(clk=>clk_s,rst=>rst_s,start=>start_s,ready=>ready_s,n=>n_s,k=>k_s,data_out=>data_out_s);
    FSMD: binomial port map(clk=>clk_s,rst=>rst_s,start=>start_s,ready=>ready_FSMD_s,n=>n_s,k=>k_s,data_out=>data_out_FSMD_s);
    
    process
    begin
        clk_s<='0';
        wait for clkper/2;
        clk_s<='1';
        wait for clkper/2;
    end process;
    
    process
    begin
        rst_s<='1';
        wait for clkper/4;
        rst_s<='0'; 
        wait for clkper;
        rst_s<='0'; n_s<="000"; k_s<="000"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait for clkper;
        rst_s<='0'; n_s<="111"; k_s<="111"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait for clkper;
        rst_s<='0'; n_s<="100"; k_s<="011"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait until ready_FSMD_s='1';
        wait for clkper/2;
        wait for clkper;
        rst_s<='0'; n_s<="110"; k_s<="010"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait until ready_FSMD_s='1';
        wait for clkper/2;
        wait for clkper;
        rst_s<='0'; n_s<="111"; k_s<="101"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait until ready_FSMD_s='1';
        wait for clkper/2;
        wait for clkper;
        rst_s<='0'; n_s<="111"; k_s<="100"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait until ready_FSMD_s='1';
        wait for clkper/2;
        wait for clkper;
        rst_s<='0'; n_s<="111"; k_s<="110"; start_s<='1';
        wait for clkper;
        start_s<='0';
        wait until ready_FSMD_s='1';
        wait for clkper/2;
        wait for clkper;
        wait;
    end process;
    
end Behavioral;
