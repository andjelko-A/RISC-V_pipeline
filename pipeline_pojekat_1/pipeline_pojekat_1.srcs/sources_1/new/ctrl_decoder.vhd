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
    uc_jmp_o: out std_logic;
    rd_we_o: out std_logic;
    rs1_in_use_o : out std_logic;
    rs2_in_use_o : out std_logic;
    alu_2bit_op_o : out std_logic_vector(1 downto 0));
end entity;

architecture Behavioral of ctrl_decoder is

    constant ADD_opcode: std_logic_vector(4 downto 0)  := "01100";
    constant SLTI_opcode: std_logic_vector(4 downto 0) := "00100";
    constant BLT_opcode: std_logic_vector(4 downto 0)  := "11000";
    constant JALR_opcode: std_logic_vector(4 downto 0) := "11001";
    constant LW_opcode: std_logic_vector(4 downto 0)   := "00000";
    constant SW_opcode: std_logic_vector(4 downto 0)   := "01000";

begin

    decode: process(opcode_i)
    begin
    
        -- Ako nista, onda nop
        branch_o <= '0';
        mem_to_reg_o <= '0';
        data_mem_we_o <= '0';
        alu_src_b_o <= '0';
        rd_we_o <= '0';
        uc_jmp_o <= '0';
        rs1_in_use_o <= '0';
        rs2_in_use_o <= '0';
        alu_2bit_op_o <= (others => '0');
    
        case opcode_i(6 downto 2) is
            
            when ADD_opcode =>
                rd_we_o <= '1';
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
            when SLTI_opcode =>
                alu_src_b_o <= '1';
                rd_we_o <= '1';
                rs1_in_use_o <= '1';
                alu_2bit_op_o <= "01";
            when BLT_opcode  =>
                branch_o <= '1';
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
            when JALR_opcode =>
                uc_jmp_o <= '1';
                rs1_in_use_o <= '1';
                alu_src_b_o <= '1';
                rd_we_o <= '1';
            when LW_opcode =>
                mem_to_reg_o <= '1';
                alu_src_b_o <= '1';
                rd_we_o <= '1';
                rs1_in_use_o <= '1';
            when SW_opcode =>
                data_mem_we_o <= '1';
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
                alu_src_b_o <= '1';
            when others =>
                null;
           
        end case;
    
    end process;

end Behavioral;
