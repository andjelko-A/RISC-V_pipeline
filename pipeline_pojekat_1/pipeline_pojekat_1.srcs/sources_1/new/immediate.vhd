----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 10:49:10 AM
-- Design Name: 
-- Module Name: immediate - Behavioral
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

entity immediate is
    generic(
            WIDTH: positive := 32
            );
    port(
        inst_code_i: in std_logic_vector(WIDTH-1 downto 0);
        
        immediate_o: out std_logic_vector(WIDTH-1 downto 0)
        );
end immediate;

architecture Behavioral of immediate is

    -- odvaja se samo visih 5 bita; niza dva su uvek 1
    -- mogao sam dodati grananje po formatima, ali ovde imam 3 formata
    -- i mali skup instr. pa je brze ovako
    -- da ih je bilo vise, na osnovu opcode bi bila napravljena
    -- klasifikacija po formatu, i onda bi se generisala const
    constant ADD_opcode: std_logic_vector(4 downto 0)  := "01100";
    constant SLTI_opcode: std_logic_vector(4 downto 0) := "00100";
    constant BLT_opcode: std_logic_vector(4 downto 0)  := "11000";
    constant JALR_opcode: std_logic_vector(4 downto 0) := "11001";
    constant LW_opcode: std_logic_vector(4 downto 0)   := "00000";
    constant SW_opcode: std_logic_vector(4 downto 0)   := "01000";
    signal extension_s: std_logic_vector(19 downto 0);

begin

    -- znak za prosirenje konstante
    extension_s <= (others => inst_code_i(WIDTH-1));
    
    imm_gen: process(inst_code_i, extension_s)
    begin
        
        immediate_o <= (others => '0');
        
        -- nacin prosirenja u zavisnosti od tipa instrukcije
        case inst_code_i(6 downto 2) is
        
            when SLTI_opcode|JALR_opcode|LW_opcode =>
                -- I-format
                immediate_o <= extension_s & inst_code_i(WIDTH-1 downto 20);
            when BLT_opcode =>
                -- B-format 
                immediate_o <= extension_s & inst_code_i(WIDTH-1) & inst_code_i(7)
                                & inst_code_i(WIDTH-2 downto 25) & inst_code_i(11 downto 8);
            when SW_opcode =>
                -- S-format
                immediate_o <= extension_s & inst_code_i(WIDTH-1 downto 25) & inst_code_i(11 downto 7);
            when others =>
                -- Ovde preostali R-format
                immediate_o <= (others => '0');
                
        end case;
        
    end process;

end Behavioral;
