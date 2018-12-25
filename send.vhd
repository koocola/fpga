library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity send is
port( send_begin: in std_logic;
		clk: in std_logic;
		data: in std_logic_vector(15 downto 0);
		send_complete: out std_logic;
		port_block_h2f: in std_logic_vector(31 downto 0);
		port_block_f2h: out std_logic_vector(31 downto 0)
);
end send;

architecture behavior of send is
type state_type is (s_free, s_init_send, s_begin_send, s_end_send);
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
					if(send_begin = '1') then
						next_state <= s_init_send;
					end if;
				when s_init_send =>
					if(port_block_h2f(31) = '1') then
						next_state <= s_begin_send;
					end if;
				when s_begin_send =>
					if(port_block_h2f(29) = '1') then
						next_state <= s_end_send;
					end if;
				when s_end_send =>
					if(send_begin = '0') then
						next_state <= s_free;
					end if;
			end case;
		end process;
		
		output_gen: process(current_state)
		begin
			case current_state is
				when s_free =>
					send_complete <= '0';
				when s_init_send =>
					port_block_f2h(29) <= '0';
				when s_begin_send =>
					port_block_f2h(30) <= '1';
					port_block_f2h(31) <= '1';
					for j in 0 to 15 loop
						port_block_f2h(j) <= data(j);
					end loop;
					port_block_f2h(29) <= '1';
				when s_end_send =>
					port_block_f2h(31) <= '0';
					send_complete <= '1';
			end case;	
		end process;	
end behavior;