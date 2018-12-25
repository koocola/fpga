library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity receive is
port( receive_begin: in std_logic;
		clk: in std_logic;
		port_block_h2f: in std_logic_vector(31 downto 0);
		data: out std_logic_vector(15 downto 0);
	   receive_complete: out std_logic;
		port_block_f2h: out std_logic_vector(31 downto 0)
);
end receive;

architecture behavior of receive is
type state_type is (s_free, s_init_receive, s_ready_receive, s_end_receive);
signal current_state, next_state : state_type;
begin
		sync: process(clk)
		begin
			current_state <= next_state;
		end process;
		
		state_trans: process(current_state)
		begin
			next_state <= current_state;
			case current_state is
				when s_free =>
					if(receive_begin = '1') then
						next_state <= s_init_receive;
					end if;
				when s_init_receive =>
					if(port_block_h2f(31) = '1') then
						next_state <= s_ready_receive;
					end if;
				when s_ready_receive =>
					if(port_block_h2f(29) = '1') then
						next_state <= s_end_receive;
					end if;
				when s_end_receive =>
					if(receive_begin = '0') then
						next_state <= s_free;
					end if;
			end case;
		end process;
		
		output_gen: process(current_state)
		begin
			case current_state is
				when s_free =>
					receive_complete <= '0';
				when s_init_receive =>
					port_block_f2h(29) <= '0';
				when s_ready_receive =>
					port_block_f2h(30) <= '0';
					port_block_f2h(31) <= '1';
				when s_end_receive =>
					for j in 0 to 15 loop
						data(j) <= port_block_h2f(j);
					end loop; 
					port_block_f2h(29) <= '1';
					port_block_f2h(30) <= '0';
					receive_complete <= '1';
			end case;
		end process;
end behavior;
