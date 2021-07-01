library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binomial is
    port (
        clk,rst,start: in std_logic;
        n,k: in std_logic_vector(2 downto 0);
        data_out: out std_logic_vector(6 downto 0);
        ready: out std_logic
    );
end binomial;

architecture HLSM of binomial is
    type stateType is (S_init,S_wait,S_comp,S_end);
    signal currState,nextState: stateType;
    signal currOut,nextOut: std_logic_vector(12 downto 0);
    signal currN,currK,currCntN,nextCntN,currCntK,nextCntK: std_logic_vector(2 downto 0);
    signal currKfact,nextKfact: std_logic_vector(12 downto 0);
begin
    
    regs: process(clk,rst)
    begin
        if(rst='1') then
            currState<=S_init;
            currOut<=(others => '0');
            currN<=(others => '0');
            currK<=(others => '0');
            currCntN<=(others => '0');
            currCntK<=(others => '0');
            currKfact<=(others => '0');
        elsif (rising_edge(clk)) then
            currState<=nextState;
            currOut<=nextOut;
            if start='1' then
                currN<=n;
                currK<=k;
            end if;
            currCntN<=nextCntN;
            currCntK<=nextCntK;
            currKfact<=nextKfact;
        end if;
    end process regs;
    
    data_out<=currOut(6 downto 0);
    
    comb: process(currState,start,n,k,currCntN,currOut,currKfact,currCntK,currN,currK)
    begin
    ready<='0';
        case currState is
            when S_init=> nextState<=S_wait; nextOut<=(others => '0'); nextCntN<=(others => '0'); nextCntK<=(others => '0'); nextKfact<=(others => '0');
            when S_wait=> if(start='1' and k<=n) then
                            if(k="000" or k=n) then
                                nextState<=S_end; 
                                nextOut<=std_logic_vector(to_unsigned(1,nextOut'length));
                            else
                                nextState<=S_comp; 
                                nextOut<=std_logic_vector(resize(unsigned(n) - unsigned(k) + 1,nextOut'length)); 
                            end if;
                            nextCntN<=std_logic_vector(unsigned(n) - unsigned(k) + 2); 
                            nextCntK<=(2 downto 1 =>'0')&"1"; nextKfact<=(12 downto 1 =>'0')&"1"; 
                          else
                            nextState<=S_wait; nextCntN<=(others => '0'); nextCntK<=(others => '0'); 
                            nextKfact<=(others => '0'); nextOut<=(others => '0');
                          end if;
            when S_comp=> if(currN>=currCntN and currCntN/="000") then
                            nextCntN<=std_logic_vector(unsigned(currCntN)+1);
                            nextOut<=std_logic_vector(to_unsigned(to_integer(unsigned(currOut))*to_integer(unsigned(currCntN)),nextOut'length)); 
                          else
                            nextCntN<=currCntN;
                            nextOut<=currOut;
                          end if;
                          if(currK>=currCntK) then
                            nextKfact<=std_logic_vector(to_unsigned(to_integer(unsigned(currKfact))*to_integer(unsigned(currCntK)),nextKfact'length)); 
                            nextCntK<=std_logic_vector(unsigned(currCntK)+1);
                            nextState<=S_comp;
                          else
                            nextOut<=std_logic_vector(to_unsigned(to_integer(unsigned(currOut))/to_integer(unsigned(currKfact)),nextOut'length)); 
                            nextState<=S_end;
                          end if;
            when S_end=> ready<='1'; nextState<=S_wait; nextOut<=(others => '0'); nextCntN<=(others => '0'); nextCntK<=(others => '0'); nextKfact<=(others => '0');
            when others=> nextState<=S_Init; nextOut<=(others => '0'); nextCntN<=(others => '0'); nextCntK<=(others => '0'); nextKfact<=(others => '0');                             
        end case;
    end process comb;
end HLSM;

architecture FSMD of binomial is

    -- Shared signals
    signal k_cntk_gt,k_sel,n_sel,eq_zero,eq_zero_sel,n_cntn_gt,cntk_sel,add_sel,k_n_eq,k_n_lt,kfact_sel: std_logic;
    signal out_sel: std_logic_vector(2 downto 0);
    signal cntn_sel: std_logic_vector(1 downto 0);
    
    -- DP signals
    signal currOut,nextOut: std_logic_vector(12 downto 0);
    signal currN,currK,nextN,nextK,currCntN,nextCntN,currCntK,nextCntK: std_logic_vector(2 downto 0);
    signal currKfact,nextKfact: std_logic_vector(12 downto 0);
    signal eq_zero_in,add1_out,add2_in,add2_out: std_logic_vector(2 downto 0);
   
    
    -- FSM signal
    type stateType is (S_init,S_wait,S_comp,S_end);
    signal currState,nextState: stateType;
    
begin
    -- DP processes
    DPregs: process(clk,rst)
    begin
        if(rst='1') then
            currOut<=(others => '0');
            currN<=(others => '0');
            currK<=(others => '0');
            currCntN<=(others => '0');
            currCntK<=(others => '0');
            currKfact<=(others => '0');
        elsif (rising_edge(clk)) then
            currOut<=nextOut;
            if start='1' then
                currN<=n;
                currK<=k;
            end if;
            currCntN<=nextCntN;
            currOut<=nextOut;
            currCntK<=nextCntK;
            currKfact<=nextKfact;
        end if;
    end process DPregs;
    
    nextK<= k when k_sel='0' else (others=>'0');
    nextN<= n when n_sel='0' else (others=>'0');
    k_cntk_gt<= '1' when unsigned(currK)>=unsigned(currCntk) else '0';
    eq_zero_in<= currK when eq_zero_sel='0' else currCntn;
    eq_zero<= '1' when eq_zero_in = (2 downto 0 =>'0') else '0';
    n_cntn_gt<= '1' when unsigned(currN) >= unsigned(currCntn) else '0';
    nextCntk<= std_logic_vector(unsigned(currCntk)+1) when cntk_sel ='0' else (nextCntK'length-1 downto 1=>'0')&"1";
    add1_out<=std_logic_vector(unsigned(n) - unsigned(k) + 1);
    add2_in<= add1_out when add_sel='1' else currCntn;
    add2_out<= std_logic_vector(unsigned(add2_in) + 1);
    nextCntn<= add2_out when cntn_sel ="01" else 
                (nextCntn'length-1 downto 0 => '0') when cntn_sel="00" else
                currCntn;
    nextKfact<= (nextKfact'length -1 downto 1 =>'0')&"1" when kfact_sel='1' else
                std_logic_vector(to_unsigned(to_integer(unsigned(currCntk))*to_integer(unsigned(currKfact)),nextKfact'length));
    nextOut<= (nextOut'length -1 downto 0 =>'0') when out_sel="000" else
              (nextOut'length -1 downto 1 =>'0')&"1" when out_sel="001" else
              std_logic_vector(to_unsigned(to_integer(unsigned(currCntn))*to_integer(unsigned(currOut)),nextOut'length)) when out_sel="010" else
              std_logic_vector(to_unsigned(to_integer(unsigned(currOut))/to_integer(unsigned(currKfact)),nextOut'length)) when out_sel="011" else
              std_logic_vector(resize(unsigned(add1_out),nextOut'length)) when out_sel="100" else 
              currOut;
    k_n_eq<= '1' when k=n else '0';
    k_n_lt<= '1' when unsigned(k) <= unsigned(n) else '0';
    data_out<=currOut(6 downto 0);
    
    
    -- FSM processes
    Cregs: process(clk,rst)
    begin
        if(rst='1') then
            currState<=S_init;
        elsif (rising_edge(clk)) then
            currState<=nextState;
        end if;
    end process Cregs;
    
    Ccomb: process(currState,start,k_n_lt,k_n_eq,eq_zero,n_cntn_gt,k_cntk_gt)
    begin
    ready<='0'; out_sel<="000"; cntn_sel<="00"; cntk_sel<='1'; kfact_sel<='1'; eq_zero_sel<='0'; add_sel<='1'; 
        case currState is
            when S_init=> nextState<=S_wait; out_sel<="000"; cntn_sel<="00"; cntk_sel<='1'; kfact_sel<='1'; 
            when S_wait=> if(start='1' and k_n_lt='1') then
                            eq_zero_sel<='0';
                            if(eq_zero='1' or k_n_eq='1') then
                                nextState<=S_end; 
                                out_sel<="001";
                            else
                                nextState<=S_comp; 
                                out_sel<="100";
                            end if;
                            add_sel<='1';cntn_sel<="01";
                            cntk_sel<='1'; kfact_sel<='1';
                          else
                            nextState<=S_wait; cntn_sel<="00"; cntk_sel<='1';
                            kfact_sel<='1'; out_sel<="000";
                          end if;
            when S_comp=> eq_zero_sel<='1';
                          if(n_cntn_gt='1' and eq_zero='0') then
                            cntn_sel<="01"; add_sel<='0';
                            out_sel<="010";
                          else
                            cntn_sel<="10";
                            out_sel<="101";
                          end if;
                          if(k_cntk_gt='1') then
                            kfact_sel<='0';
                            cntk_sel<='0';
                            nextState<=S_comp;
                          else
                            out_sel<="011";
                            nextState<=S_end;
                          end if;
            when S_end=> ready<='1'; nextState<=S_wait; out_sel<="000"; cntn_sel<="00"; cntk_sel<='1'; kfact_sel<='1';
            when others=> nextState<=S_Init; out_sel<="000"; cntn_sel<="00"; cntk_sel<='1'; kfact_sel<='1';                           
        end case;
    end process Ccomb;
end FSMD;