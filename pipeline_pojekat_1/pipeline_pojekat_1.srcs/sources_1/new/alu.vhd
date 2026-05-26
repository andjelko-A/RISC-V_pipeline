----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:49:34 AM
-- Design Name: 
-- Module Name: alu - Behavioral
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

entity alu is
    generic(
            WIDTH: positive := 32
            );
    port(
        alu_forward_a_i: in std_logic_vector(1 downto 0);
        alu_forward_b_i: in std_logic_vector(1 downto 0);
        alu_src_b_ex_i: in std_logic;
        alu_2_bit_op_ex_i: in std_logic_vector(1 downto 0);
        
        alu_rs1_ex_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_rs2_ex_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_rs1_mem_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_rs2_mem_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_rs1_wb_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_rs2_wb_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_imm_ex_i: in std_logic_vector(WIDTH-1 downto 0);
        
        alu_result_o: out std_logic_vector(WIDTH-1 downto 0)
        );
end alu;

architecture Behavioral of alu is

    constant ALU_ADD: std_logic_vector(1 downto 0) := "00";
    constant ALU_SLT: std_logic_vector(1 downto 0) := "01";
    
    signal alu_a_s: std_logic_vector(WIDTH-1 downto 0);
    signal alu_b_s: std_logic_vector(WIDTH-1 downto 0);

begin

    -- odluka o prosledljivanju, kao i prosedljivanju konstatne na ulaz
    -- alu u slucaju stli
    alu_in_sel: process(alu_forward_a_i, alu_forward_b_i, alu_src_b_ex_i,
    alu_rs1_ex_i, alu_rs2_ex_i, alu_rs1_mem_i, alu_rs2_mem_i, alu_rs1_wb_i, alu_rs2_wb_i,
    alu_imm_ex_i)
    begin
    
        alu_a_s <= (others => '0');
        alu_b_s <= (others => '0');
    
        if alu_forward_a_i = "00" then
            alu_a_s <= alu_rs1_ex_i;
        elsif alu_forward_a_i = "01" then
            alu_a_s <= alu_rs1_wb_i;
        elsif alu_forward_a_i = "10" then
            alu_a_s <= alu_rs1_mem_i;
        end if;
    
        if alu_src_b_ex_i = '0' then
            if alu_forward_b_i = "00" then
                alu_b_s <= alu_rs2_ex_i;
            elsif alu_forward_b_i = "01" then
                alu_b_s <= alu_rs2_wb_i;
            elsif alu_forward_b_i = "10" then
                alu_b_s <= alu_rs2_mem_i;
            end if;
        else
            alu_b_s <= alu_imm_ex_i;
        end if;
    
    end process;

    -- odluka o izboru i izvrsavanje operacije
    alu_op_ex: process(alu_a_s, alu_b_s, alu_2_bit_op_ex_i)
    begin

        alu_result_o <= (others => '0');
        
        if alu_2_bit_op_ex_i = ALU_ADD then
            alu_result_o <= std_logic_vector(signed(alu_a_s) + signed(alu_b_s));
        elsif alu_2_bit_op_ex_i = ALU_SLT then
            if signed(alu_a_s) < signed(alu_b_s) then
                alu_result_o <= std_logic_vector(to_signed(1, WIDTH));
            end if;
        end if;
    
    end process;

end Behavioral;
