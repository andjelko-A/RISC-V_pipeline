----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:38:52 AM
-- Design Name: 
-- Module Name: ctrl_decoder - Behavioral
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

entity ctrl_decoder is
    port (
    -- opcode instrukcije
    opcode_i: in std_logic_vector (6 downto 0);
    -- kontrolni signali
    branch_o: out std_logic;
    mem_to_reg_o : out std_logic;
    data_mem_we_o : out std_logic;
    alu_src_b_o: out std_logic;
    rd_we_o: out std_logic;
    rs1_in_use_o : out std_logic;
    rs2_in_use_o : out std_logic;
    alu_2bit_op_o : out std_logic_vector(1 downto 0));
end entity;

architecture Behavioral of ctrl_decoder is

begin


end Behavioral;
