# Lab 0 -- Environment & Toolchain Warm-up
# Do not modify this file.
#
# 所有工具（Mininet / OVS / iperf3 / ethtool ...）與 entrypoint 都在基底 image 裡，
# 由 NYCU-SDNFV/lab-images 建好推到 GHCR。一學期一個 tag。
FROM ghcr.io/nycu-sdnfv/lab-base:115-1
WORKDIR /workspace
