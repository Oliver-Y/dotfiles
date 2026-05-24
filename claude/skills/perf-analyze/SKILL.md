---
name: perf-analyze
description: Analyze performance and latency from Perfetto traces for a drive — module latencies, GPU utilization, scheduling jitter
---

**Guard**: This skill is scoped to the AV stack at `/home/oliver/core-stack`. If that directory or `drive_data/` doesn't exist, say so and stop — don't create files or directories.

Analyze performance and latency from Perfetto traces for a given drive.

The user provides a drive ID (e.g., `mce202_20260317_190908`) or a path to trace files. If the drive data isn't local yet, suggest using `/pull-drive` first.

**Delegate heavy trace analysis to a subagent** to keep the main context clean. Use the perf-analyst agent if available, otherwise spawn a general-purpose subagent.

Drive data location: `/home/oliver/core-stack/drive_data/{drive_id}/`

---

## Analysis Tiers

There are two complementary analysis paths. Use both when data is available:

### Tier 1: Raw Perfetto Trace Queries (always available if .pbbin files exist)

Use the `perfetto` Python package's `trace_processor`:

```python
from perfetto.trace_processor import TraceProcessor
tp = TraceProcessor(trace='path/to/trace.pbbin')
result = tp.query('SQL_QUERY')
```

Key queries to run (on a representative sample of .pbbin files, not all 200+):

**Module latencies (scheduling):**
```sql
SELECT name, COUNT(*) as count,
  CAST(AVG(dur) AS INT) as avg_ns,
  CAST(MIN(dur) AS INT) as min_ns,
  CAST(MAX(dur) AS INT) as max_ns,
  CAST(AVG(dur)/1e6 AS REAL) as avg_ms
FROM slice
WHERE dur > 0
GROUP BY name
ORDER BY avg_ns DESC
LIMIT 30
```

**End-to-end pipeline latency:**
```sql
SELECT name, CAST(AVG(dur)/1e6 AS REAL) as avg_ms, COUNT(*) as count
FROM slice
WHERE name LIKE '%Tick%' OR name LIKE '%Pipeline%' OR name LIKE '%inference%'
GROUP BY name
ORDER BY avg_ms DESC
```

**Scheduling jitter (variance in tick intervals):**
```sql
SELECT name,
  CAST(AVG(dur)/1e6 AS REAL) as avg_ms,
  CAST((MAX(dur) - MIN(dur))/1e6 AS REAL) as jitter_ms,
  COUNT(*) as count
FROM slice
WHERE name LIKE '%Tick%'
GROUP BY name
HAVING count > 10
ORDER BY jitter_ms DESC
```

**CUDA/GPU operations:**
```sql
SELECT name, COUNT(*) as count, CAST(AVG(dur)/1e6 AS REAL) as avg_ms
FROM slice
WHERE name LIKE '%Cuda%' OR name LIKE '%GPU%' OR name LIKE '%Resize%' OR name LIKE '%inference%'
GROUP BY name
ORDER BY avg_ms DESC
```

**Thread-level breakdown:**
```sql
SELECT thread.name, COUNT(*) as slice_count, CAST(SUM(slice.dur)/1e9 AS REAL) as total_s
FROM slice
JOIN thread_track ON slice.track_id = thread_track.id
JOIN thread USING(utid)
WHERE slice.dur > 0
GROUP BY thread.name
ORDER BY total_s DESC
LIMIT 20
```

### Tier 2: Repo Performance Tools (richer analysis, use when applicable)

The repo has a suite of performance analysis tools built on top of Perfetto traces and MCAP logs. These produce more structured metrics but should be treated with some skepticism — they go through middleware abstractions that may miss or misattribute latency.

**Use these tools when you see fit to get a more comprehensive picture alongside raw Perfetto queries.**

#### Trace-based tools (input: .pbbin files)

| Tool | Location | What it does |
|------|----------|--------------|
| `trace_analyzer` | `vehicle_os/middleware/tools/trace_processor/trace_analyzer.py` | Process-level FPS, p50/p95/p99 operation latencies, wall-time breakdown. Queries slice table with coalescing and threshold filtering. |
| `perfetto_flow_graph` | `vehicle_os/middleware/tools/trace_processor/perfetto_flow_graph.py` | Builds directed graph from latency debug annotations (`debug.output_flow_id` / `debug.input_flow_id`). Detects message drops and inversions. |
| `perfetto_flow_graph_utils` | `vehicle_os/middleware/tools/trace_processor/perfetto_flow_graph_utils.py` | Latency histograms (direct + e2e), DOT graph visualization, outlier detection, `MessageOrderAnalyzer` for drops/inversions via LIS algorithm. |
| `event_frequency_analyzer` | `vehicle_os/middleware/tools/trace_processor/event_frequency_analyzer_lib.py` | Counts event occurrences per trace file, flags events exceeding threshold (default: 3000). Useful for detecting trace spam. |
| `perfetto_latency_processor` | `vehicle_os/middleware/tools/trace_processor/perfetto_latency_processor.py` | CLI tool. Subcommands: `summary`, `histogram`, `graph`, `outlier`, `message_drops`, `message_inversions`. |

#### MCAP-based tools (input: .mcap log files — need full drive download)

| Tool | Location | What it does |
|------|----------|--------------|
| `remote_latency_validator` | `onroad/tools/buildkite/embedded/remote_latency_validator.py` | Analyzes message-level latency between pipeline stages from MCAP files. Per-component execution times, waiting times, accumulated camera→controls latency. Uses `MessageGraph`. |
| `remote_planner_validator` | `onroad/tools/buildkite/embedded/remote_planner_validator.py` | Planner health analysis from `/planner_proto` topic. Reports % healthy messages, status breakdown. Threshold: 90%. |
| `remote_unlabeled_metrics_validator` | `onroad/tools/buildkite/embedded/remote_unlabeled_metrics_validator.py` | Perception anomaly detection without ground truth: lead vehicle flicker, ghost detections, velocity/yaw jitter. |
| `remote_telegraf_validator` | `onroad/tools/buildkite/embedded/remote_telegraf_validator.py` | System resource analysis from `telegraf_metrics.out`: CPU, memory, GPU, thread stats, I/O pressure. |
| `latency_processor` | `vehicle_os/middleware/tools/performance/latency_processor.py` | CLI for `MessageGraph` analysis. Subcommands: `export`, `histogram`, `graph`, `outlier`, `summary`. |

#### Orchestrator (runs all of the above)

`onroad/tools/buildkite/embedded/remote_performance_validator.py` — central orchestrator. Subcommands: `traces`, `latency`, `planner`, `perception`, `telegraf`, `all`, `oci`. Can download from OCI with drive ID. Outputs CSV + Slack reports.

#### Key config files

- `onroad/tools/buildkite/embedded/remote_latency_validator_config.py` — defines 12 per-component endpoint pairs, 7 camera waiting-time pairs, accumulated camera→controls pairs, percentile configs (p50/p95/p99)
- `onroad/tools/performance/onroad_latency_topics.txtpb` — 52 tracked topics (cameras, perception, planning, routing, sensors, controls, localization, GPS)
- `vehicle_os/middleware/tools/common/latency_graph_common.py` — shared constants and utilities (NS_TO_MS, DOT graph helpers, frequency computation)

---

## Analysis Workflow

1. **Load drive metadata** — Read `drive_info.yaml` for context (vehicle, stack mode, models, duration, config).

2. **Identify available data** — Count `.pbbin` files, check for `combined_trace.perfetto`, check for `.mcap` files, check for `telegraf_metrics.out`. This determines which analysis tiers are available.

3. **Run Tier 1 analysis** — Raw Perfetto queries on sampled .pbbin files (always available).

4. **Run Tier 2 analysis** — If MCAP files or telegraf data are present, use the repo tools for richer metrics. Consider running `trace_analyzer` and `perfetto_flow_graph` on the traces for structured p50/p95/p99 stats and message drop/inversion detection.

5. **Present results** as a structured report:
   - Drive summary (vehicle, duration, stack config)
   - Top latency contributors (table)
   - Pipeline timing breakdown
   - GPU utilization summary
   - Scheduling jitter analysis
   - Message drops/inversions (if flow graph data available)
   - Perception health (if MCAP data available)
   - Anomalies or outliers worth investigating
   - Comparison to expected budgets if known

6. **Offer follow-ups**: deeper dive on a specific module, compare across drives, export data for plotting, run specific repo tools for targeted analysis.

For comparing drives, sample the same trace indices from each drive for fair comparison.

$ARGUMENTS
