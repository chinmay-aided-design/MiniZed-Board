# 1. Map the logical port name from the Block Diagram to the physical chip pin
set_property PACKAGE_PIN E13 [get_ports PL_LED_G_0]

# 2. Set the electrical standard for the pin (3.3V logic)
set_property IOSTANDARD LVCMOS33 [get_ports PL_LED_G_0]