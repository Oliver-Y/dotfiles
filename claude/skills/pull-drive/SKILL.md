---
name: pull-drive
description: Pull drive data from S3 for a given drive ID — lists, downloads, decompresses traces
---

**Guard**: This skill uses S3 bucket `ursa-neuron-prod-raw-logs` (AWS profile: `oci`) and downloads to `/home/oliver/core-stack/drive_data/`. If those paths or the `oci` AWS profile don't exist in this environment, stop and report the missing dependency.

Pull drive data from S3 for a given drive ID. Automates the manual aws s3 workflow.

The user provides a drive ID like `mce202_20260317_190908`. Parse it to determine:
- **Vehicle**: first part (e.g., `mce202`)
- **Date**: `YYYYMMDD` portion -> construct S3 path as `{year}/{month}/{day}` (no zero-padding on month/day for S3 path)
- **S3 bucket**: `s3://ursa-neuron-prod-raw-logs`
- **AWS profile**: `oci`

Workflow:
1. Parse the drive ID to extract vehicle and date components
2. List the S3 path to confirm the drive exists:
   `aws --profile oci s3 ls s3://ursa-neuron-prod-raw-logs/{vehicle}/{year}/{month}/{day}/{drive_id}/`
3. Show the user what's available and total size
4. Ask what to download. Common options:
   - `drive_info.yaml` only (quick metadata check)
   - `traces.tar.br` only (for Perfetto analysis -- will need decompression)
   - Full recursive download (everything -- WARNING: this pulls all merged mcap files too and can be very large / slow)
5. Download to `/home/oliver/core-stack/drive_data/{drive_id}/`
6. If `traces.tar.br` was downloaded, offer to decompress:
   `cd /home/oliver/core-stack/drive_data/{drive_id} && brotli -d traces.tar.br && tar xf traces.tar`
7. If traces are extracted, offer to create `combined_trace.perfetto` using traceconv:
   `python3 /home/oliver/core-stack/vehicle_os/middleware/tools/tracing/traceconv merge trace_*.pbbin combined_trace.perfetto`
   (Only if combined_trace doesn't already exist)
8. Show summary: drive metadata from drive_info.yaml, number of trace files, total duration

Fast path — "traces only":
If the user says "traces", "perfetto", or "trace only" (or similar), skip the interactive menu and go straight to:
1. Download `drive_info.yaml` + `traces.tar.br` only (exclude all mcap files)
2. Decompress automatically: `brotli -d traces.tar.br && tar xf traces.tar`
3. Merge into combined trace: `python3 .../traceconv merge trace_*.pbbin combined_trace.perfetto`
4. Clean up: remove `traces.tar.br` and `traces.tar` to save disk space
This is the common case for perf analysis and should be the default suggestion since full downloads are rarely needed and very slow.

S3 path gotcha: month and day in the S3 path are NOT zero-padded. March 3 = `3/3/` not `03/03/`.

$ARGUMENTS
