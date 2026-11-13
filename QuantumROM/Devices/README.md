# QuantumROM device profiles

This directory contains the imported device profile metadata (`config` and
`floating_feature.xml`) for the supported QuantumROM devices. The existing
local `A52s5G` and `SM-X216B` profiles are preserved.

The large device-specific `Stock/`, boot and optional `extra/` payloads are
fetched from the user-controlled `zinerom48-tech/QuantumROM` `Devices` branch
by the workflow when a build is selected. This keeps the Krypton repository
usable while still making every supported device visible and selectable here.

## Safety note

Standalone `boot*.img`, `stock_boot*.img`, and `bpf*_boot.img` payloads are intentionally excluded from imported device profiles. The build workflow must use the target device's verified boot/vendor/kernel inputs instead of copying a donor boot image across binaries.
