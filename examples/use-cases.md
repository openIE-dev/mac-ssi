# Use cases

mac-ssi pools your Macs into one compute fabric. Anything bottlenecked by a
single machine — RAM, cores, GPU, or just an idle box doing nothing — gets the
whole pool. AI inference is *one* of these; it isn't the point.

### 🧩 Jobs bigger than any one Mac
`ssi memory` exposes distributed shared memory across every node's RAM. Load a
dataset, a graph, or a simulation state that's larger than any single machine and
process it as if it were local — MOESI coherence keeps it consistent.

### 🏗️ Burst compute without a cloud bill
`ssi run --mode max-resources ./job` spreads heavy batch work — rendering,
simulation, builds, fine-tuning, video encodes — across every idle Mac you own.
Pay nothing per hour; use the hardware you already bought.

### 🖥️ A render / sim farm from the Macs on your desk
Point a queue at the pool. mac-ssi places each task on the node with the right
free GPU / cores / RAM, by locality, so data doesn't bounce across the wire.

### ⚡ Energy-aware scheduling
Joules are metered per node. `--mode energy` runs work where it costs the least
power. Apple Silicon already wins on perf/watt; the pool compounds it.

### 🔗 Works over whatever you've got
Thunderbolt 5 with RDMA is fastest, but mac-ssi also runs over plain Ethernet or
shared Wi-Fi — the fabric adapts to the link. Start with Wi-Fi, add a cable later.

### 🧠 Large-model inference (one example)
Because GPU memory pools, a model too big for any single Mac runs across the
cluster behind one OpenAI endpoint — see
[`serve-openai.md`](serve-openai.md). Private, on-prem, no cloud.

---

> **Honest scope.** mac-ssi's edge is making *one big machine out of many* —
> for work that doesn't fit on a single Mac. For a job that fits comfortably on
> one machine, one machine is faster; distribution pays off when one node isn't
> enough.
