----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:45:02 AM
-- Design Name: 
-- Module Name: control_path - structural
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity control_path is
    port (
    -- sinhronizacija
    clk: in std_logic;
    reset: in std_logic;
    -- instrukcija dolazi iz datapah-a
    instruction_i: in std_logic_vector (31 downto 0);
    -- Statusni signal iz datapath celine
    branch_condition_i: in std_logic;
    -- kontrolni signali koji se prosledjiuju u datapath
    mem_to_reg_o: out std_logic;
    alu_2bit_op_o: out std_logic_vector(1 downto 0);
    alu_src_b_o: out std_logic;
    uc_jump_o: out std_logic;
    rd_we_o: out std_logic;
    pc_next_sel_o: out std_logic_vector(1 downto 0);
    data_mem_we_o: out std_logic_vector(3 downto 0);
    -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_o: out std_logic_vector (1 downto 0);
    alu_forward_b_o: out std_logic_vector (1 downto 0);
    branch_forward_a_o: out std_logic; -- mux a
    branch_forward_b_o: out std_logic;
    -- mux b
    -- kontrolni signal za resetovanje if/id registra
    if_id_flush_o: out std_logic;
    -- kontrolni signali za zaustavljanje protocne obrade
    pc_en_o: out std_logic;
    if_id_en_o: out std_logic);
end entity;

architecture structural of control_path is

    signal rs1_in_use_id_s: std_logic;
    signal rs2_in_use_id_s: std_logic;
    signal control_pass_id_s: std_logic;
    signal pc_next_sel_id_s: std_logic_vector(1 downto 0) := (others => '0');
    signal rd_address_id_s: std_logic_vector(4 downto 0);
    signal rs1_address_id_s: std_logic_vector(4 downto 0);
    signal rs2_address_id_s: std_logic_vector(4 downto 0);
    signal mem_to_reg_id_s: std_logic;
    signal data_mem_we_id_s: std_logic;
    signal rd_we_id_s: std_logic;
    signal alu_src_b_id_s: std_logic;
    signal branch_id_s: std_logic;
    signal alu_2bit_op_id_s: std_logic_vector(1 downto 0);
    signal uc_jump_id_s: std_logic;
    
    signal rd_address_ex_s: std_logic_vector(4 downto 0);
    signal rs1_address_ex_s: std_logic_vector(4 downto 0);
    signal rs2_address_ex_s: std_logic_vector(4 downto 0);
    signal mem_to_reg_ex_s: std_logic;
    signal data_mem_we_ex_s: std_logic;
    signal rd_we_ex_s: std_logic;
    signal alu_src_b_ex_s: std_logic;
    signal alu_2bit_op_ex_s: std_logic_vector(1 downto 0);
    signal uc_jump_ex_s: std_logic;
    
    signal rd_address_mem_s: std_logic_vector(4 downto 0);
    signal mem_to_reg_mem_s: std_logic;
    signal data_mem_we_mem_s: std_logic;
    signal rd_we_mem_s: std_logic;
    
    signal rd_address_wb_s: std_logic_vector(4 downto 0);
    signal mem_to_reg_wb_s: std_logic;
    signal rd_we_wb_s: std_logic;

begin

    ctrl_decoder_1: entity work.ctrl_decoder
        port map(
                opcode_i => instruction_i(6 downto 0),
                branch_o => branch_id_s,
                mem_to_reg_o => mem_to_reg_id_s,
                data_mem_we_o => data_mem_we_id_s,
                alu_src_b_o => alu_src_b_id_s,
                uc_jmp_o => uc_jump_id_s,
                rd_we_o => rd_we_id_s,
                rs1_in_use_o => rs1_in_use_id_s,
                rs2_in_use_o => rs2_in_use_id_s,
                alu_2bit_op_o => alu_2bit_op_id_s
                );
    
    fwd_unit_1: entity work.forwarding_unit
        port map(
                rs1_address_id_i => rs1_address_id_s,
                rs2_address_id_i => rs2_address_id_s,
                rs1_address_ex_i => rs1_address_ex_s,
                rs2_address_ex_i => rs2_address_ex_s,
                rd_we_mem_i => rd_we_mem_s,
                rd_address_mem_i => rd_address_mem_s,
                rd_we_wb_i => rd_we_wb_s,
                rd_address_wb_i => rd_address_wb_s,
                alu_forward_a_o => alu_forward_a_o,
                alu_forward_b_o => alu_forward_b_o,
                branch_forward_a_o => branch_forward_a_o,
                branch_forward_b_o => branch_forward_b_o
                );
    
    hazard_unit_1: entity work.hazard_unit
        port map(
                rs1_address_id_i => rs1_address_id_s,
                rs2_address_id_i => rs2_address_id_s,
                rs1_in_use_i => rs1_in_use_id_s,
                rs2_in_use_i => rs2_in_use_id_s,
                branch_id_i => branch_id_s,
                jump_id_i => uc_jump_id_s,
                rd_address_ex_i => rd_address_ex_s,
                mem_to_reg_ex_i => mem_to_reg_ex_s,
                rd_we_ex_i => rd_we_ex_s,
                rd_address_mem_i => rd_address_mem_s,
                mem_to_reg_mem_i => mem_to_reg_mem_s,
                pc_en_o => pc_en_o,
                if_id_en_o => if_id_en_o,
                control_pass_o => control_pass_id_s
                );
    
    rd_address_id_s <= instruction_i(11 downto 7);
    rs1_address_id_s <= instruction_i(19 downto 15);
    rs2_address_id_s <= instruction_i(24 downto 20);
          
    -- IF control signali
    pc_next_sel_id_s <= uc_jump_id_s & (branch_condition_i and branch_id_s);
    if_id_flush_o <= '1' when uc_jump_id_s = '1' or pc_next_sel_id_s(0) = '1' else
                     '0';
    pc_next_sel_o <= pc_next_sel_id_s;
    
    -- EX control signali
    alu_2bit_op_o <= alu_2bit_op_ex_s;
    alu_src_b_o <= alu_src_b_ex_s;
    uc_jump_o <= uc_jump_ex_s;
    
    -- MEM control signali
    data_mem_we_o <= (others => '1') when data_mem_we_mem_s = '1' else
                     (others => '0');
                     
    -- WB control signali
    rd_we_o <= rd_we_wb_s;
    mem_to_reg_o <= mem_to_reg_wb_s;
        
    pipe_regs: process(clk)
    begin
    
        if rising_edge(clk) then
        
            if control_pass_id_s = '1' then
                mem_to_reg_ex_s <= mem_to_reg_id_s;
                data_mem_we_ex_s <= data_mem_we_id_s;
                rd_we_ex_s <= rd_we_id_s;
                rs1_address_ex_s <= rs1_address_id_s;
                rs2_address_ex_s <= rs2_address_id_s;
                alu_src_b_ex_s <= alu_src_b_id_s;
                uc_jump_ex_s <= uc_jump_id_s;
                alu_2bit_op_ex_s <= alu_2bit_op_id_s;
                rd_address_ex_s <= rd_address_id_s;
            else
                mem_to_reg_ex_s <= '0';
                data_mem_we_ex_s <= '0';
                rd_we_ex_s <= '0';
                alu_src_b_ex_s <= '0';
                uc_jump_ex_s <= '0';
                alu_2bit_op_ex_s <= (others => '0');
                rd_address_ex_s <= (others => '0');
                rs1_address_ex_s <= (others => '0');
                rs2_address_ex_s <= (others => '0');
            end if;
            
            mem_to_reg_mem_s <= mem_to_reg_ex_s;
            data_mem_we_mem_s <= data_mem_we_ex_s;
            rd_we_mem_s <= rd_we_ex_s;
            rd_address_mem_s <= rd_address_ex_s;
        
            rd_we_wb_s <= rd_we_mem_s;
            rd_address_wb_s <= rd_address_mem_s;
            mem_to_reg_wb_s <= mem_to_reg_mem_s;
            
        end if;
    
    end process;
    
end structural;
