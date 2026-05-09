----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:48:51 AM
-- Design Name: 
-- Module Name: register_bank - Behavioral
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

entity register_bank is
    generic(
            WIDTH: positive := 32
            );
    port(
        clk: in std_logic;
        reset: in std_logic;
        
        rs1_address_i: in std_logic_vector(4 downto 0);
        rs2_address_i: in std_logic_vector(4 downto 0);
        rs1_data_o: out std_logic_vector(WIDTH-1 downto 0);
        rs2_data_o: out std_logic_vector(WIDTH-1 downto 0);
        
        rd_we_i: in std_logic;
        rd_address_i: in std_logic_vector(4 downto 0);
        rd_data_i: in std_logic_vector(WIDTH-1 downto 0)
        );
end register_bank;

architecture Behavioral of register_bank is

    type reg_bank_t is array(0 to WIDTH-1) of std_logic_vector(WIDTH-1 downto 0);
    signal reg_bank_s: reg_bank_t;

begin

    rs1_data_o <= (others => '0') when unsigned(rs1_address_i) = 0 else
                  reg_bank_s(to_integer(unsigned(rs1_address_i)));
    rs2_data_o <= (others => '0') when unsigned(rs2_address_i) = 0 else
                  reg_bank_s(to_integer(unsigned(rs2_address_i)));

    bank_op: process(clk)
    begin
        
        if falling_edge(clk) then
            if rd_we_i = '1' and unsigned(rd_address_i) /= 0 then
                reg_bank_s(to_integer(unsigned(rd_address_i))) <= rd_data_i;
            end if;
        end if;
    
    end process;

end Behavioral;
