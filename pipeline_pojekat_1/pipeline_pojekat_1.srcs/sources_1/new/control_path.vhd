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
    branch_condition_i : in std_logic;
    -- kontrolni signali koji se prosledjiuju u datapath
    mem_to_reg_o: out std_logic;
    alu_2bit_op_o: out std_logic_vector(2 downto 0);
    alu_src_b_o: out std_logic;
    rd_we_o: out std_logic;
    pc_next_sel_o: out std_logic;
    data_mem_we_o: out std_logic_vector(3 downto 0);
    -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
    alu_forward_a_o: out std_logic_vector (1 downto 0);
    alu_forward_b_o: out std_logic_vector (1 downto 0);
    branch_forward_a_o : out std_logic; -- mux a
    branch_forward_b_o : out std_logic;
    -- mux b
    -- kontrolni signal za resetovanje if/id registra
    if_id_flush_o: out std_logic;
    -- kontrolni signali za zaustavljanje protocne obrade
    pc_en_o: out std_logic;
    if_id_en_o: out std_logic);
end entity;

architecture structural of control_path is

begin


end structural;
