# Lab 0 -- Environment & Toolchain Warm-up
# Do not modify this file.
#
# 所有工具（Mininet / OVS / iperf3 / ethtool ...）與 entrypoint 都在基底 image 裡。
# Lab 0 使用 userspace OVS，不依賴 host OVS kernel module 或 BBR。
FROM ghcr.io/nycu-sdnfv/lab-base@sha256:c9b6ee4a5271038225a7ca41f541fd005e3766abf4bd70f9f924a61e24984a19
WORKDIR /workspace
