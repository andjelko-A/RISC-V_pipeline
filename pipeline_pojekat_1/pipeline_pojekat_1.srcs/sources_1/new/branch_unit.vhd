----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 11:17:18 AM
-- Design Name: 
-- Module Name: branch_unit - Behavioral
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

entity branch_unit is
    generic(
            WIDTH: positive := 32
            );
    port(
        branch_forward_a_i: in std_logic;
        branch_forward_b_i: in std_logic;
    
        rs1_id_i: in std_logic_vector(WIDTH-1 downto 0);
        rs2_id_i: in std_logic_vector(WIDTH-1 downto 0);
        alu_res_mem_i: in std_logic_vector(WIDTH-1 downto 0);
        pc_id_i: in std_logic_vector(WIDTH-1 downto 0);
        immediate_i: in std_logic_vector(WIDTH-1 downto 0);
        
        branch_condition_o: out std_logic;
        branch_address_o: out std_logic_vector(WIDTH-1 downto 0)
        );
end branch_unit;

architecture Behavioral of branch_unit is

    signal comp_val_a_s: std_logic_vector(WIDTH-1 downto 0);
    signal comp_val_b_s: std_logic_vector(WIDTH-1 downto 0);

begin

    branch_address_o <= std_logic_vector(signed(pc_id_i) + signed(immediate_i(WIDTH-2 downto 0) & '0'));
    
    comp_val_a_s <= rs1_id_i when branch_forward_a_i = '0' else
                    alu_res_mem_i;
    comp_val_b_s <= rs2_id_i when branch_forward_b_i = '0' else
                    alu_res_mem_i;
                    
    branch_condition_o <= '1' when comp_val_a_s = comp_val_b_s else
                          '0';

end Behavioral;
