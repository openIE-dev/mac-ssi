# Use cases

### 🧠 Local frontier inference
Run a 400–600B-class model on the Macs you already own — no cloud, no NVIDIA rack.
`ssi serve` shards it across cluster RAM and gives you one OpenAI endpoint your
whole team can hit on the LAN.

### 🔒 On-prem private AI
Regulated data that can't leave the building? The model and every token stay on
your desk. Point Cursor, Continue, open-webui, or your own app at the local
endpoint.

### 🏗️ Burst compute without a cloud bill
`ssi run --mode max-resources ./job` spreads heavy batch work — rendering,
simulation, fine-tuning — across every idle Mac. Pay nothing per hour.

### ⚡ Energy-aware scheduling
mac-ssi meters joules per node (and per token). `--mode energy` runs work where
it costs the least power. Apple Silicon already wins on perf/watt; the cluster
compounds it.

### 🧩 Aggregate memory for big data
`ssi memory` exposes distributed shared memory across all nodes' RAM — load a
dataset bigger than any one machine and process it as if it were local.

---

> **Honest scope.** mac-ssi's edge is *cluster-scale on Apple Silicon*: running
> models and jobs **too big for one Mac** across many. For a model that fits on a
> single machine, a single machine is faster — distribution only pays off when one
> node isn't enough.
