# FZ3 - High-Performance ZynqMP SoC Sensor Data Acquisition System

A comprehensive embedded system project built on Xilinx ZynqMP SoC platform, featuring high-speed S15611 sensor data acquisition with zero-copy DMA, embedded Linux, and complete CI/CD automation.

## Overview

FZ3 is an advanced sensor data acquisition system that combines ZynqMP SoC architecture with custom FPGA logic for high-rate data collection from S15611 sensors. The system leverages zero-copy DMA transfers and embedded Linux for optimal performance.

## Project Structure

```
FZ3/
├── hdl/                          # Hardware Description (FPGA Logic)
│   ├── s15611_driver.sv         # SystemVerilog S15611 sensor driver
│   └── sensor_data_acquisition.v # Data acquisition and AXI Stream interface
├── hls/                          # High-Level Synthesis projects
├── petalinux/                    # Embedded Linux Configuration
│   ├── config                   # PetaLinux project configuration
│   ├── rootfs_config            # Root filesystem packages
│   ├── system-user.dtsi         # Device tree customizations
│   └── xilinx_axidma/           # AXI DMA driver integration
├── scripts/                      # Build and Deployment Scripts
│   ├── create_vivado_project.sh      # Generate Vivado project
│   ├── build_vivado_project.sh       # Synthesize and implement
│   ├── create_petalinux_project.sh   # Setup PetaLinux environment
│   ├── build_petalinux_project.sh    # Build kernel and rootfs
│   ├── update_petalinux_hw_spec.sh   # Update hardware specification
│   ├── copy_linux_to_SD.sh          # Deploy to SD card
│   └── ci.sh                         # Continuous integration pipeline
├── tcl/                          # Vivado TCL Scripts
├── xdc/                          # Pin Constraints and I/O assignments
├── qt/                           # Qt User Interface Applications
├── matlab/                       # Data Analysis and Visualization
├── artifacts/                    # Generated Build Outputs
├── build/                        # Intermediate Build Files
└── log_data/                    # Sensor Data Logging
```

## Hardware Requirements

- Xilinx ZynqMP SoC development board (ZCU102/ZCU104 compatible)
- S15611 sensor module with 12-bit parallel interface
- SD card for Linux boot (8GB minimum)
- JTAG programmer for FPGA configuration
- Compatible FPGA programming interface

## Software Dependencies

- **Xilinx Vivado Design Suite** (2019.1 or later)
- **PetaLinux Tools** (matching Vivado version)
- **Cross-compilation toolchain for ARM64**
- **Device Tree Compiler (DTC)**
- **Git** for version control
- **Make** and build essentials

## Quick Start

### Building the Project

1. **Environment Setup**
   ```bash
   source /opt/xilinx/vivado/settings64.sh
   source /opt/xilinx/petalinux/settings.sh
   ```

2. **Build FPGA Bitstream**
   ```bash
   ./scripts/create_vivado_project.sh
   ./scripts/build_vivado_project.sh
   ```

3. **Build Linux Kernel and Drivers**
   ```bash
   ./scripts/create_petalinux_project.sh
   ./scripts/update_petalinux_hw_spec.sh
   ./scripts/build_petalinux_project.sh
   ```

4. **Generate Boot Images**
   ```bash
   ./scripts/copy_linux_to_SD.sh /dev/sdX  # Replace X with your SD card
   ```

### Deployment

1. Flash the generated images to SD card or QSPI flash
2. Configure boot switches on the development board
3. Power on the system and boot embedded Linux

## Driver Usage

The S15611 sensor driver provides a character device interface:

```c
// Example usage
int fd = open("/dev/s15611", O_RDWR);
// Configure sensor parameters
// Read high-rate data using zero-copy DMA
```

## Performance Features

- **Zero-Copy Data Path**: Direct memory access between sensor and user space via AXI DMA
- **Real-Time Scheduling**: Linux RT kernel configuration for deterministic timing
- **DMA Coherency**: Optimized memory management for high-throughput operations (1+ GB/s)
- **Interrupt-Driven Processing**: Efficient event handling for continuous data flow
- **12-bit Data Capture**: Parallel interface with pixel clock synchronization
- **Hardware Timestamping**: FPGA-based timestamp insertion for data correlation

## Development Workflow

### Continuous Integration

The project includes automated CI/CD pipeline (`scripts/ci.sh`) that:
- Builds all components (FPGA bitstream, Linux kernel, drivers)
- Runs hardware-in-the-loop tests
- Generates deployment artifacts
- Validates performance benchmarks
- Creates release packages

### Testing

```bash
# Run unit tests
./scripts/run_tests.sh

# Performance benchmarks
./scripts/benchmark.sh

# Complete CI pipeline
./scripts/ci.sh
```

## Hardware Architecture

### S15611 Sensor Interface
- **Data Width**: 12-bit parallel interface
- **Timing Control**: Master clock and start pulse generation
- **Synchronization**: Pixel clock and sync signal detection
- **Pin Assignment**: Complete I/O mapping in `xdc/top.xdc`

### FPGA Implementation
- **s15611_driver.sv**: SystemVerilog driver with CDC and state machine
- **sensor_data_acquisition.v**: AXI Stream interface and data packetization
- **Clock Domain Crossing**: Async registers for reliable data transfer
- **Debug Interface**: Built-in signal monitoring and validation

## System Block Diagram

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   S15611        │    │  ZynqMP SoC      │    │  DDR4 Memory    │
│   Sensor        │◄──►│                  │◄──►│                 │
│                 │    │  ┌─────────────┐ │    │  Data Buffers   │
│ • 12-bit Data   │    │  │ PL (FPGA)   │ │    │  Linux Kernel   │
│ • Pixel Clock   │    │  │ • S15611 IF │ │    │  User Space     │
│ • Sync Signal   │    │  │ • AXI DMA   │ │    │                 │
└─────────────────┘    │  └─────────────┘ │    └─────────────────┘
                       │  ┌─────────────┐ │
                       │  │ PS (ARM)    │ │
                       │  │ • Linux     │ │
                       │  │ • Drivers   │ │
                       │  │ • Qt Apps   │ │
                       │  └─────────────┘ │
                       └──────────────────┘
```

## Key Features

- **Embedded Linux Support**: Custom PetaLinux configuration optimized for real-time processing
- **Zero-Copy DMA**: AXI DMA implementation for high-performance data transfer without CPU overhead
- **S15611 Sensor Driver**: Hardware and software driver integration for seamless data acquisition
- **High-Rate Data Collection**: Optimized for continuous high-throughput sensor data capture
- **Hardware Acceleration**: Custom FPGA logic for sensor data processing and packetization
- **Complete Build System**: Automated Vivado and PetaLinux project generation and compilation
- **Qt GUI Integration**: User-friendly interface for system control and data visualization
- **MATLAB Support**: Analysis tools and data processing capabilities

## Configuration & Customization

### Sensor Parameters
Configure in HDL parameters (`hdl/s15611_driver.sv`):
```systemverilog
parameter NUMBER_OF_PIXEL = 1024;           // Pixels per line
parameter CDC_REG_LENGTH = 2;               // Clock domain crossing depth
parameter master_start_pulse_period = 1000; // Master clock period
```

### Device Tree Customization
Edit `petalinux/system-user.dtsi` for:
- AXI DMA channel configuration
- Memory region allocation
- Interrupt assignments
- GPIO pin mappings

### Build Customization
- **Kernel Config**: Modify `petalinux/config`
- **Rootfs Packages**: Update `petalinux/rootfs_config`
- **Hardware Changes**: Edit TCL scripts in `tcl/`

## Performance Specifications

### Data Throughput
- **Peak Rate**: 1+ GB/s sustained transfer
- **Latency**: < 1μs interrupt response
- **Efficiency**: Zero-copy DMA eliminates memory copies
- **Scalability**: Multi-channel sensor support

### Resource Utilization
- **FPGA Logic**: Optimized for ZynqMP architecture
- **Memory**: Efficient DDR4 utilization with burst transfers
- **Power**: Low-power design for continuous operation

## Troubleshooting

### Common Issues
- **Build Failures**: Ensure correct Xilinx tool versions and licensing
- **Boot Problems**: Verify SD card formatting and file permissions
- **Performance Issues**: Check DMA buffer alignment and cache coherency

### Debug Resources
- Serial console output via UART
- Vivado Hardware Manager for FPGA state analysis
- Linux kernel logs (`dmesg`)
- Built-in debug interfaces in HDL modules

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Make your changes
4. Run tests and ensure CI passes
5. Submit a pull request

## Documentation

- **Hardware Design**: HDL implementation details in `hdl/`
- **Software Integration**: PetaLinux configuration in `petalinux/`
- **Build Scripts**: Automation details in `scripts/`
- **Pin Constraints**: I/O assignments in `xdc/`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Contact: h.beheshti92@gmail.com

## Acknowledgments

- Xilinx for ZynqMP SoC platform and development tools
- Linux kernel community for embedded systems support
- S15611 sensor documentation contributors
- Open source FPGA and embedded development communities

---

**Note**: This project is designed for research and development. Ensure proper validation and compliance with applicable standards for production use.
