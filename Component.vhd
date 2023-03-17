---------------------------------------------macchina a stati----------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity project_reti_logiche is
port (
    i_clk: in std_logic;
    i_rst: in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done: out std_logic;
    o_en  : out std_logic;
    o_we  : out std_logic;
    o_data: out std_logic_vector (7 downto 0)
);
end project_reti_logiche;

architecture ASF of project_reti_logiche is

component data_path is 
port(
    clk: in std_logic;
    rst: in std_logic;
    idata : in std_logic_vector(7 downto 0);
    
    regCol_load: in std_logic;
    regRow_sel: in std_logic;
    regRow_load: in std_logic;
    regDim_load: in std_logic;
    regAddress_sel: in std_logic_vector(1 downto 0);
    regAddress_load: in std_logic;
    oaddress_sel: in std_logic;
    
    regMinMax_load: in std_logic;
    muxMinMax_load: in std_logic;
    
    regPixel_load: in std_logic;
    regOdata_load: in std_logic;
        
    checkIn: out std_logic;
    endSum: out std_logic;
    endjpg: out std_logic;
    oaddress: out std_logic_vector(15 downto 0);
    odata: out std_logic_vector(7 downto 0)
);
end component;

    signal rst: std_logic;
    signal datapathrst: std_logic;
    
    signal regCol_load: std_logic;
    
    signal regRow_sel:  std_logic;
    signal regRow_load: std_logic;
 
    signal regDim_load: std_logic;
    
    signal regAddress_sel:  std_logic_vector(1 downto 0);
    signal regAddress_load: std_logic;
    
    signal oaddress_sel:  std_logic;
    
    signal regMinMax_load: std_logic;
    signal muxMinMax_load:  std_logic;
    
    signal regPixel_load: std_logic;
    signal regOdata_load: std_logic;
        
    signal checkIn: std_logic;
    signal endSum:  std_logic;
    signal endjpg: std_logic;
    
    type S is (SI, S0, S1, S2, S3, S4, S5, S6, S7, S8, S8BIS, S9, S10, S11);
    signal cur_state, next_state : S;
    
begin

--DataPath Intance    COMPONENT => MYPORT
    DataPath: data_path port map(
        clk => i_clk,
        rst => rst,
        idata => i_data,
        regCol_load => regCol_load,
        regRow_load => regRow_load,
        regRow_sel => regRow_sel,
        regDim_load => regDim_load,
        regAddress_sel => regAddress_sel,
        regAddress_load => regAddress_load,
        oaddress_sel => oaddress_sel,
        regMinMax_load => regMinMax_load, 
        muxMinMax_load => muxMinMax_load,
        regPixel_load => regPixel_load,
        regOdata_load => regOdata_load,
        
        checkIn => checkIn,
        endSum => endSum,
        endjpg => endjpg,
        oaddress => o_address,
        odata => o_data
    );
    
 -- reset (per impostare il reset a inizio esecuzione sempre)
        rst<= datapathrst or i_rst;
       
    
--Set cur_state = next_state
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= SI;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
--Choose next_state
    process(cur_state,i_start,endsum,endjpg,checkIn)
    begin
        next_state <= cur_state;
        case cur_state is
            when SI =>
                if(i_start='1') then
                    next_state <= S0;
                end if;
            when S0 =>
                next_state <= S1;
            when S1 =>
                if (checkIn='1') then
                    next_state <= S11;
                else
                    next_state <=S2;
                end if;
            when S2 =>
                if (checkIn='1') then
                    next_state <= S11;
                else
                    next_state <=S3;
                end if;
            when S3 =>
                if(endsum='1') then
                    next_state <=S4;
                end if;
            when S4 =>
                if(endjpg='0') then
                    next_state <=S5;
                else
                    next_state <=S6;    
                end if;     
            when s5 =>
                if (endjpg='1') then
                    next_state<=S6;
                end if;    
            when S6 => 
                next_state<=S7;
            when S7 =>
                next_state<=S8;
            when S8 =>
                    next_state<=S8BIS;
            when S8BIS =>
                    next_state<=S9;       
           when S9 =>
                if(endjpg='0') then
                    next_state <=S7;
                 else
                    next_state <=S10;
                 end if;
          when S10 =>
                   next_state <=S11;
          when S11 =>
            if(i_start='0') then 
                next_state <=SI;
            end if;    
            when others =>
        end case;
    end process;

--State effect
    process(cur_state)
    begin
    --Signal default state 
    o_done<='0';
    o_en<='0';
    o_we<='0';
    datapathrst<='0';
    
    regCol_load<='0';
    regRow_load<='0';    
    regRow_sel<='0';

    regDim_load<='0';
    
    regAddress_sel<="00";
    regAddress_load <='0';
    
    oaddress_sel<='0';
    
    regMinMax_load <='0';
    muxMinMax_load<='0';
    
    regPixel_load <='0';
    regOdata_load <='0';
    
            
    case cur_state is
        when SI =>
            datapathrst<='1';                   
        when S0 =>
            o_en<='1';
            regAddress_sel<="11";
            regAddress_load<='1';
            
        when S1 =>
            o_en<='1';
            regCol_load<='1'; 
            
        when S2 =>
            regRow_load<='1';
            regAddress_sel<="11";
            regAddress_load<='1';
            
        when S3 =>
            regRow_load<='1';
            regRow_sel<='1';
            regDim_load<='1';
        when S4 =>
            o_en<='1';
            regAddress_load<='1';
            regAddress_sel<="11";    
        when S5=>
            o_en<='1';
            regAddress_sel<="11";
            regAddress_load<='1';
            regMinMax_load <='1';
            muxMinMax_load<='1';
        when S6 =>
            regMinMax_load <='1';
            muxMinMax_load<='1';
            regAddress_load <= '1';
            regAddress_sel <= "10";
        when S7 =>         
            o_en<='1';
        when S8 =>
            regPixel_load <='1';
        when S8BIS =>
            regOdata_load <='1';    
            
        when S9 =>
            o_en <='1';
            o_we <='1';
            oaddress_sel<='1';
            regAddress_load<='1';
            regAddress_sel<="11";
        when S10 =>
         --per far stabilizzare i segnali
        when S11 =>
           o_done<='1';                 
        when others =>
        
        end case;
    end process;
    
end ASF;


-------------------------------------------datapath--------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_path is 
port(
    clk: in std_logic;
    rst: in std_logic;
    idata : in std_logic_vector(7 downto 0);
    
    regCol_load: in std_logic;
    
    regRow_sel: in std_logic;
    RegRow_load: in std_logic;
    
    regDim_load: in std_logic;
    
    regAddress_sel: in std_logic_vector(1 downto 0);
    regAddress_load: in std_logic;
    
    oaddress_sel: in std_logic;
    
    regMinMax_load: in std_logic;    
    muxMinMax_load: in std_logic;
    
    regPixel_load: in std_logic;
    
    regOdata_load: in std_logic;
    
    
    checkIn: out std_logic;
    endSum: out std_logic;
    endjpg: out std_logic;
    oaddress: out std_logic_vector(15 downto 0);
    odata: out std_logic_vector(7 downto 0)
);
end data_path;

architecture Behavioral of data_path is
    signal regCol: std_logic_vector(7 downto 0);
    
    signal regRow: std_logic_vector(7 downto 0);
    signal sub_regRow: std_logic_vector(7 downto 0);
    signal mux_regRow: std_logic_vector(7 downto 0);
    
    signal regDim: std_logic_vector(15 downto 0);
    signal add_regDim: std_logic_vector(15 downto 0);
    

    
    signal regAddress: std_logic_vector(15 downto 0);
    signal add_regAddress: std_logic_vector(15 downto 0);
    signal mux_regAddress: std_logic_vector(15 downto 0);
    
    signal mux_oaddress: std_logic_vector(15 downto 0);
    signal add_oaddress: std_logic_vector(15 downto 0);
    
    signal regMin: std_logic_vector(7 downto 0);
    signal regMax: std_logic_vector(7 downto 0);
    
    signal mux_regMin: std_logic_vector(7 downto 0);
    signal mux_regMax: std_logic_vector(7 downto 0);
    
    signal regMin_sel: std_logic;
    signal regMax_sel: std_logic;
    
    signal delta: std_logic_vector(7 downto 0);
    signal shift: std_logic_vector(3 downto 0);
    
    signal regPixel: std_logic_vector(7 downto 0);
    signal sub_regPixel: std_logic_vector(7 downto 0);
    
    signal shiftedPixel: std_logic_vector(15 downto 0);
    
    signal odata_sel: std_logic;
        
    signal mux_regOdata: std_logic_vector(7 downto 0);
    signal regOdata: std_logic_vector(7 downto 0);
    
    
begin
--Load regCol
    process(clk,rst,regCol_load)
    begin
        if (rst='1') then
            regCol<="00000000";
        elsif (rising_edge(clk) and regCol_load='1') then
            regCol<=idata;
        end if;
    end process;
    

--set CheckIn
    checkIn <= '1' when (idata = "00000000") else '0';
    
--Set buffRow
    sub_RegRow <= RegRow - 1;
    
    with regRow_sel select
    mux_regRow <=  
        idata          when '0',
        sub_regRow     when '1',
        "XXXXXXXX"      when others;
  
    process(clk,rst,regRow_load)
    begin
        if (rst='1') then
            regRow<="00000000";
        elsif (rising_edge(clk) and regRow_load='1') then
            regRow<=mux_regRow;
        end if;
    end process;
    
--set endSum
    endSum <= '1' when (sub_regRow = "00000000") else '0';
   
--set regDim
    add_regDim <=regDim + ("00000000" & regCol);
    
    process(clk,rst,regDim_load)
    begin
        if (rst='1') then
            regDim<="0000000000000000";
        elsif (rising_edge(clk) and regDim_load='1') then
            regDim<=add_regDim;
        end if;
    end process;
 
 --set regAddress
    add_regAddress<= regAddress + "0000000000000001";
    
    with regAddress_sel select
    mux_regAddress <=  
        "0000000000000000"  when "00",
        "0000000000000010"  when "10",
        add_regAddress      when "11",
        "XXXXXXXXXXXXXXXX"  when others;
        
    process(clk,rst,regAddress_load)
    begin
        if (rst='1') then
            regAddress<="0000000000000000";
        elsif (rising_edge(clk) and regAddress_load='1') then
            regAddress <= mux_regAddress;
        end if;
    end process;
    
 --set oAddress
    add_oaddress<= regDim + regAddress; --potrebbe essere a 17 bit


    with oaddress_sel select
    mux_oaddress <=  
        regAddress          when '0',
        add_oaddress        when '1',
        "XXXXXXXXXXXXXXXX"  when others;

    oaddress<=mux_oaddress;

 -- set endjpg
     endjpg <= '1' when (regDim +1 = regAddress) else '0';
     
 -- set MinMax Signals
    
    process(clk,rst,regMinMax_load)
    begin
        if (rst='1') then
            regMin<="11111111"; -- impostato al massimo valore cosi cambia sempre
            regMax<="00000000"; -- impostato al minimo valore cosi cambia sempre
        elsif (rising_edge(clk) and regMinMax_load='1') then
            regMin <= mux_regMin;
            regMax <= mux_regMax;
        end if;
    end process;
    

    with regMin_sel select
    mux_regMin <=  
        regMin  when '0',
        idata   when '1',
        "XXXXXXXX"  when others;
        
    with regMax_sel select
    mux_regMax <=  
        regMax  when '0',
        idata   when '1',
        "XXXXXXXX"  when others;   
        
    --i mux vengono resettati i primi 2 stati, quando i selettori sono sempre 0 e i registri sempre al valore minimo 
    regMin_sel <= '1' when (idata < regMin and muxMinMax_load='1')  else '0';
    regMax_sel <= '1' when (idata > regMax and muxMinMax_load='1')  else '0';
    
 -- set RegPixel 
 
    sub_regPixel<=idata-regMin;
 
    process(clk,rst,regPixel_load)
    begin
        if (rst='1') then
            regPixel<="00000000";
        elsif (rising_edge(clk) and regPixel_load='1') then
            RegPixel <= sub_regPixel;
        end if;
    end process;
    
 --set shiftedPixel
   
    delta <= regMax - RegMin+1;
           
    process(delta)
    begin
        if(delta="00000000") then
            shift<="0000";
        elsif( delta = "00000001") then
            shift<="1000";
        elsif(delta < "00000100") then
            shift <= "0111";
        elsif(delta < "00001000") then
            shift <="0110";
        elsif(delta < "00010000") then
            shift <="0101";
        elsif(delta < "00100000") then
            shift <="0100";
        elsif(delta < "01000000") then
            shift <="0011";
        elsif(delta < "10000000") then
            shift <="0010";      
        else 
           shift <="0001";                   
        end if;   
    end process;
    
    process(regPixel,shift)
    begin
        case shift is
        when "0000" => shiftedPixel <= "00000000" & regPixel ;
        when "0001" => shiftedPixel <= "0000000" & regPixel & "0";
        when "0010" => shiftedPixel <= "000000" & regPixel & "00";
        when "0011" => shiftedPixel <= "00000" & regPixel & "000";
        when "0100" => shiftedPixel <= "0000" & regPixel & "0000";
        when "0101" => shiftedPixel <= "000" & regPixel & "00000";
        when "0110" => shiftedPixel <= "00" & regPixel & "000000";
        when "0111" => shiftedPixel <= "0" & regPixel & "0000000";
        when "1000" => shiftedPixel <= regPixel & "00000000";
        when others => shiftedPixel <= "XXXXXXXXXXXXXXXX";
        end case;
    end process;
    
    odata_sel <= '1' when (shiftedPixel< "0000000100000000") else '0';
   
    with odata_sel select
    mux_regOdata <=  
        shiftedPixel(7 downto 0)  when '1',
        "11111111"                when '0',
        "XXXXXXXX"                when others;
        
    process(clk,rst,regOdata_load)
    begin
        if (rst='1') then
            regOdata<="00000000";
        elsif (rising_edge(clk) and regOdata_load='1') then
            regOdata <= mux_regOdata;
        end if;
    end process;    
        
     odata<=RegOdata;       
    
end architecture;

