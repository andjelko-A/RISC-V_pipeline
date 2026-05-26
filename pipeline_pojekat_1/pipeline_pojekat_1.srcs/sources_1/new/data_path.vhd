----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:35:22 AM
-- Design Name: 
-- Module Name: data_path - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity data_path is
    port(
    -- sinhronizacioni signali
    clk: in std_logic;
    reset: in std_logic;
    -- interfejs ka memoriji za instrukcije
    instr_mem_address_o : out std_logic_vector (31 downto 0);
    instr_mem_read_i: in std_logic_vector(31 downto 0);
    instruction_o: out std_logic_vector(31 downto 0);
    -- interfejs ka memoriji za podatke
    data_mem_address_o : out std_logic_vector(31 downto 0);
    data_mem_write_o: out std_logic_vector(31 downto 0);
    data_mem_read_i: in std_logic_vector (31 downto 0);
    -- kontrolni signali
    mem_to_reg_i: in std_logic;
    alu_2bit_op: in std_logic_vector(1 downto 0); -- promenio sam sa 4 alu_op_i
    alu_src_b_i: in std_logic;                     -- sto je izlaz alu decodera kog sam izbacio                                               
    uc_jmp_i: in std_logic;
    pc_next_sel_i: in std_logic_vector(1 downto 0);                   
    rd_we_i: in std_logic;
    branch_condition_o : out std_logic;
    -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_i: in std_logic_vector(1 downto 0);
    alu_forward_b_i: in std_logic_vector(1 downto 0);
    branch_forward_a_i : in std_logic;
    branch_forward_b_i : in std_logic;
    -- kontrolni signal za resetovanje if/id registra
    if_id_flush_i: in std_logic;
    -- kontrolni signali za zaustavljanje protocne obrade
    pc_en_i: in std_logic;
    if_id_en_i: in std_logic);
end entity;

architecture structural of data_path is

    signal pc_next_if_s: std_logic_vector(31 downto 0) := (others => '0');
    signal pc_curr_if_s: std_logic_vector(31 downto 0) := std_logic_vector(to_signed(-4, 32));
    signal instruction_if_s: std_logic_vector(31 downto 0);
    
    signal pc_curr_id_s: std_logic_vector(31 downto 0);
    signal instruction_id_s: std_logic_vector(31 downto 0);
    signal branch_address_id_s: std_logic_vector(31 downto 0);
    signal jmp_address_id_s: std_logic_vector(31 downto 0);
    signal imm_id_s: std_logic_vector(31 downto 0);
    signal rs1_id_s: std_logic_vector(31 downto 0);
    signal rs2_id_s: std_logic_vector(31 downto 0);
    signal rs1_adr_id_s: std_logic_vector(4 downto 0);
    signal rs2_adr_id_s: std_logic_vector(4 downto 0);
    
    signal pc_curr_ex_s: std_logic_vector(31 downto 0);
    signal imm_ex_s: std_logic_vector(31 downto 0);
    signal rs1_ex_s: std_logic_vector(31 downto 0);
    signal rs2_ex_s: std_logic_vector(31 downto 0);
    signal rd_adr_ex_s: std_logic_vector(4 downto 0);
    signal alu_res_ex_o: std_logic_vector(31 downto 0);
    signal alu_res_ex_s: std_logic_vector(31 downto 0);
    
    signal alu_res_mem_s: std_logic_vector(31 downto 0);
    signal read_data_mem_s: std_logic_vector(31 downto 0);
    signal rd_adr_mem_s: std_logic_vector(4 downto 0);
    
    signal read_data_wb_s: std_logic_vector(31 downto 0);
    signal alu_res_wb_s: std_logic_vector(31 downto 0);
    signal rd_wb_s: std_logic_vector(31 downto 0);
    signal rd_adr_wb_s: std_logic_vector(4 downto 0);

begin

    -- IF deo
    
    instr_mem_address_o <= pc_curr_if_s;
    instruction_if_s <= instr_mem_read_i;   
    
    inst_fetch: process(clk)   
    begin
        
        if rising_edge(clk) then
            
            if pc_en_i = '1' then
            
                if pc_next_sel_i = "00" then
                    pc_curr_if_s <= std_logic_vector(signed(pc_curr_if_s) + 4);
                elsif pc_next_sel_i = "01" then
                    pc_curr_if_s <= branch_address_id_s;
                else
                    pc_curr_if_s <= jmp_address_id_s;
                end if;
            
            end if;
            
        end if;
    
    end process;
    
    -- ID deo
    
    instruction_o <= instruction_id_s;  
    rs1_adr_id_s <= instruction_id_s(19 downto 15);
    rs2_adr_id_s <= instruction_id_s(24 downto 20);
    -- logika za racunanje adrese bezuslovnog skoka
    jmp_address_id_s <= std_logic_vector(unsigned(imm_id_s) + unsigned(rs1_id_s)) when branch_forward_a_i = '0' else
                        std_logic_vector(unsigned(imm_id_s) + unsigned(alu_res_mem_s));
    
    reg_bank_1: entity work.register_bank
        port map(
                clk => clk,
                reset => reset,
                rs1_address_i => rs1_adr_id_s,
                rs2_address_i => rs2_adr_id_s,
                rs1_data_o => rs1_id_s,
                rs2_data_o => rs2_id_s,
                rd_we_i => rd_we_i,
                rd_address_i => rd_adr_wb_s,
                rd_data_i => rd_wb_s
                );
                
    branch_unit_1: entity work.branch_unit
        port map(
                branch_forward_a_i => branch_forward_a_i,
                branch_forward_b_i => branch_forward_b_i,
                rs1_id_i => rs1_id_s,
                rs2_id_i => rs2_id_s,
                alu_res_mem_i => alu_res_mem_s,
                pc_id_i => pc_curr_id_s,
                immediate_i => imm_id_s,
                branch_condition_o => branch_condition_o,
                branch_address_o => branch_address_id_s
                );
                
    immediate_1: entity work.immediate
        port map(
                inst_code_i => instruction_id_s,
                immediate_o => imm_id_s
                );
                
    -- EX deo
    
    -- Ako se desi bezuslovni skok, prosledi kao rezultat ex faze povratnu adresu
    alu_res_ex_s <= alu_res_ex_o when uc_jmp_i = '0' else
                    std_logic_vector(signed(pc_curr_ex_s) + 4);
    
    alu_1: entity work.alu
        port map(
                alu_forward_a_i => alu_forward_a_i,
                alu_forward_b_i => alu_forward_b_i,
                alu_src_b_ex_i => alu_src_b_i,
                alu_2_bit_op_ex_i => alu_2bit_op,
                alu_rs1_ex_i => rs1_ex_s,
                alu_rs2_ex_i => rs2_ex_s,
                alu_rs1_mem_i => alu_res_mem_s,
                alu_rs2_mem_i => alu_res_mem_s,
                alu_rs1_wb_i => rd_wb_s,
                alu_rs2_wb_i => rd_wb_s,
                alu_imm_ex_i => imm_ex_s,
                alu_result_o => alu_res_ex_o
                );

    -- MEM deo
    
    data_mem_address_o <= alu_res_mem_s;
    read_data_mem_s <= data_mem_read_i;
    
    -- WB deo
    
    rd_wb_s <= alu_res_wb_s when mem_to_reg_i = '0' else
               read_data_wb_s;

    pipe_data_regs: process(clk)
    begin
    
        if rising_edge(clk) then
        
            if if_id_flush_i = '1' then
                
                pc_curr_id_s <= (others => '0');
                instruction_id_s <= (others => '0');
                
            elsif if_id_en_i = '1' then
                
                pc_curr_id_s <= pc_curr_if_s;
                instruction_id_s <= instruction_if_s;
                
            end if;
            
            imm_ex_s <= imm_id_s;
            rs1_ex_s <= rs1_id_s;
            rs2_ex_s <= rs2_id_s;
            pc_curr_ex_s <= pc_curr_id_s;
            rd_adr_ex_s <= instruction_id_s(11 downto 7);
            
            alu_res_mem_s <= alu_res_ex_s;
            rd_adr_mem_s <= rd_adr_ex_s;
            -- na izlazu ex faze dodat jos jedan mux koji odlucuje da li je
            -- potrebno vrsiti prosledljivanje u store instrukciji na ulaz
            -- data mem
            if alu_forward_b_i = "00" then
                data_mem_write_o <= rs2_ex_s;
            elsif alu_forward_b_i = "01" then
                data_mem_write_o <= alu_res_wb_s;
            elsif alu_forward_b_i = "10" then
                data_mem_write_o <= alu_res_mem_s;
            end if;
            
            rd_adr_wb_s <= rd_adr_mem_s;
            alu_res_wb_s <= alu_res_mem_s;
            read_data_wb_s <= read_data_mem_s;
        
        end if;
    
    end process;

end structural;
