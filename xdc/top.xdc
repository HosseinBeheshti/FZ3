# UART
set_property IOSTANDARD LVCMOS33 [get_ports uart_rtl_txd]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rtl_rxd]
set_property PACKAGE_PIN AB15 [get_ports uart_rtl_rxd]
set_property PACKAGE_PIN AB14 [get_ports uart_rtl_txd]

#fan pwm control
set_property PACKAGE_PIN AD14 [get_ports {fan_pwm}]
set_property IOSTANDARD LVCMOS33 [get_ports fan_pwm]