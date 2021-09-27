----------------------------------------------------------------------------------
--------------------
---___           ___
--|   |         |   |
--|   |         |   |
--|   |         |   |
--|   |_________|   |
--|                 |
--|    H128B717     |
--|    _________    |
--|   |         |   |
--|   |         |   |
--|   |         |   |
--|___|         |___|
---------------------
-- Engineer: HosseinBehshti
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sensor_data_acquisition is
  port (
    master_clock : in std_logic;
    reset        : in std_logic;
    -- ad9226 interface
    ad9226_otr     : in std_logic;
    ad9226_clk     : out std_logic;
    ad9226_data    : in std_logic_vector(11 downto 0);
    adc_data       : out std_logic_vector(11 downto 0);
    adc_data_valid : out std_logic;
    adc_data_otr   : out std_logic;
    -- cjmcu1401 interface
    cjmcu1401_clk : out std_logic;
    cjmcu1401_si  : out std_logic;
    -- ps data
    m_axi_tdata  : out std_logic_vector(31 downto 0);
    m_axi_tvalid : out std_logic;
    -- debug probe
    dbg_probe : out std_logic_vector(15 downto 0)
  );
end sensor_data_acquisition;

architecture Behavioral of sensor_data_acquisition is
  attribute X_INTERFACE_INFO                  : string;
  attribute X_INTERFACE_INFO of master_clock  : signal is "xilinx.com:signal:clock:1.0 master_clock CLK";
  attribute X_INTERFACE_INFO of ad9226_clk    : signal is "xilinx.com:signal:clock:1.0 ad9226_clk CLK";
  attribute X_INTERFACE_INFO of cjmcu1401_clk : signal is "xilinx.com:signal:clock:1.0 cjmcu1401_clk CLK";
  attribute X_INTERFACE_INFO of reset         : signal is "xilinx.com:signal:reset:1.0 reset RST";

  attribute X_INTERFACE_PARAMETER                  : string;
  attribute X_INTERFACE_PARAMETER of reset         : signal is "POLARITY ACTIVE_HIGH";
  attribute X_INTERFACE_PARAMETER of master_clock  : signal is " FREQ_HZ 99999001";
  attribute X_INTERFACE_PARAMETER of m_axi_tdata   : signal is " FREQ_HZ 99999001";
  attribute X_INTERFACE_PARAMETER of ad9226_clk    : signal is " FREQ_HZ 99999001/2";
  attribute X_INTERFACE_PARAMETER of cjmcu1401_clk : signal is " FREQ_HZ 99999001";

  component cjmcu1401_driver is
    port (
      master_clock           : in std_logic;
      sample_capture_trigger : out std_logic;
      pixel_counter_out      : out std_logic_vector(15 downto 0);
      cjmcu1401_si           : out std_logic;
      cjmcu1401_clk          : out std_logic
    );
  end component;

  component ad9226_driver is
    port (
      master_clock   : in std_logic;
      reset          : in std_logic;
      ad9226_otr     : in std_logic;
      ad9226_data    : in std_logic_vector(11 downto 0);
      adc_data       : out std_logic_vector(11 downto 0);
      adc_data_valid : out std_logic;
      adc_data_otr   : out std_logic;
      ad9226_clk     : out std_logic
    );
  end component;

  signal sample_capture_trigger : std_logic;
  signal adc_data_temp          : std_logic_vector(11 downto 0);
  signal adc_data_valid_temp    : std_logic;
  signal pixel_counter_out      : std_logic_vector(15 downto 0);

begin

  cjmcu1401_driver_inst : cjmcu1401_driver
  port map(
    master_clock           => master_clock,
    sample_capture_trigger => sample_capture_trigger,
    pixel_counter_out      => pixel_counter_out,
    cjmcu1401_si           => cjmcu1401_si,
    cjmcu1401_clk          => cjmcu1401_clk
  );

  ad9226_driver_ins : ad9226_driver
  port map(
    master_clock   => master_clock,
    reset          => reset,
    ad9226_otr     => ad9226_otr,
    ad9226_data    => ad9226_data,
    adc_data       => adc_data_temp,
    adc_data_valid => adc_data_valid_temp,
    adc_data_otr   => adc_data_otr,
    ad9226_clk     => ad9226_clk
  );

  process (master_clock)
  begin
    if rising_edge(master_clock) then
      adc_data       <= adc_data_temp;
      adc_data_valid <= adc_data_valid_temp;
      m_axi_tdata    <= "000" & sample_capture_trigger & pixel_counter_out & adc_data_temp;
      m_axi_tvalid   <= adc_data_valid_temp;
    end if;
  end process;

  dbg_probe(0) <= sample_capture_trigger;
end Behavioral;