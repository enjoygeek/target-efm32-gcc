# Generic build target for EFM32 using GCC

This is a generic yotta build target for EFM32 devices using the GCC toolchain.
This target cannot be used by end users, but should be depended on by all
derived EFM32 targets.

## Building software for an EFM32 Starter Kit

If you have an EFM32 Starter Kit, you should use the kit-specific target for
your kit.

- [EFM32 Giant Gecko STK3700 target](https://github.com/ARMmbed/target-efm32gg-stk-gcc)
- [EFM32 Happy Gecko SLSTK3400A target](https://github.com/ARMmbed/target-efm32hg-stk-gcc)
- [EFM32 Leopard Gecko STK3600 target](https://github.com/ARMmbed/target-efm32lg-stk-gcc)
- [EFM32 Wonder Gecko STK3800 target](https://github.com/ARMmbed/target-efm32wg-stk-gcc)
- [EFM32 Pearl Gecko SLSTK3401A target](https://github.com/ARMmbed/target-efm32pg-stk-gcc)

These targets will take care to configure pinout, board specific crystal
settings, device-specific settings (part number, flash size, ram size, etc),
and debug and test scripts.

## Creating a new target for an EFM32-based board

If you want to create a yotta target for your own board and device, please do
not inherit this target directly. Instead, inherit from the correct family
target for your device:

- [EFM32 Giant Gecko generic target](https://github.com/ARMmbed/target-efm32gg-gcc)
- [EFM32 Happy Gecko generic target](https://github.com/ARMmbed/target-efm32hg-gcc)
- [EFM32 Leopard Gecko generic target](https://github.com/ARMmbed/target-efm32lg-gcc)
- [EFM32 Wonder Gecko generic target](https://github.com/ARMmbed/target-efm32wg-gcc)
- [EFM32 Pearl Gecko generic target](https://github.com/ARMmbed/target-efm32pg-gcc)

These targets will take care to set up family specific configuration, such as
the correct default clock frequencies, interrupt vector table, stack size, etc.
