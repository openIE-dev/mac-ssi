<div align="center">

<img src="docs/assets/logo.svg" alt="mac-ssi" width="120" />

# mac-ssi

### Turn the Macs you already own into one giant computer.

**Pool the CPU, GPU, Neural Engine, RAM, and storage of every Mac on your desk over Thunderbolt 5 — and run AI models too big for any single machine, behind one OpenAI-compatible endpoint.**

[![Download](https://img.shields.io/badge/Download-.dmg-000?style=for-the-badge&logo=apple)](https://github.com/openIE-dev/mac-ssi/releases/latest)
[![Homebrew](https://img.shields.io/badge/brew_install_--cask-mac--ssi-FBB040?style=for-the-badge&logo=homebrew&logoColor=white)](#install)
[![Docs](https://img.shields.io/badge/Docs-mac--ssi.dev-1e90ff?style=for-the-badge)](https://openie-dev.github.io/mac-ssi/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue?style=for-the-badge)](LICENSE)

[**Website**](https://openie-dev.github.io/mac-ssi/) · [**Quickstart**](#quickstart) · [**Examples**](examples/) · [**API**](#api) · [**How it works**](#how-it-works)

</div>

---

## Why

A single Mac Studio caps out at 512 GB. A frontier-scale model at 4-bit can need far more. Today your only options are the cloud or a rack of NVIDIA GPUs.

**mac-ssi** makes a *pile of Macs* present as a single machine. Aggregate RAM spans every node; GPU work dispatches to whichever Mac has idle cores; a process appears as one PID. The cluster **is** the computer — no distributed-programming model, no code changes.

> Reference cluster: 4 Macs → **608 GB unified RAM**, 80 CPU cores, ~200 GPU cores, 80 ANE cores — presented as one.

---

## The flagship: run a model no single Mac can hold

```bash
# Serve a frontier model, pipeline-sharded across every Mac, as one OpenAI endpoint
ssi serve nemotron-ultra-550b --port 8080
```

```bash
# It's just the OpenAI API — point any client at it
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"Explain Thunderbolt RDMA in one sentence."}]}'
```

```python
from openai import OpenAI
client = OpenAI(base_url="http://localhost:8080/v1", api_key="local")
print(client.chat.completions.create(
    model="ultra-550b",
    messages=[{"role": "user", "content": "What can a cluster of Macs do that one can't?"}],
).choices[0].message.content)
```

**Proven on real hardware:** a 120B model distributed across 3 Macs serving at **~22 tok/s** through one endpoint; pipeline built to run **400–600B-class** models on pooled cluster RAM. See [examples/](examples/).

---

## Quickstart

```bash
# 1. Install on every Mac you want in the cluster
brew install --cask openie-dev/mac-ssi/mac-ssi

# 2. Cable the Macs together with Thunderbolt 5 (direct cables, no docks)

# 3. Start the agent on each node — they auto-discover each other (mDNS + SWIM)
ssi up

# 4. See your cluster
ssi status
```

```text
  mac-ssi cluster — 4 nodes, 608 GB unified
  ───────────────────────────────────────────────
  NODE          CHIP         RAM     GPU   STATUS
  studio-01     M3 Ultra     256 GB  ●●●   ready
  studio-02     M4 Max        36 GB  ●     ready
  mbp-01        M4 Max       128 GB  ●●    ready
  mbp-02        M5 Max       128 GB  ●●    ready
  ───────────────────────────────────────────────
  aggregate: 608 GB · 80 cores · TB5 fabric · 0.06 J/token
```

---

## What you can do

| Command | What it does |
|---|---|
| `ssi serve <model>` | Distributed inference of a model bigger than one node → one OpenAI endpoint |
| `ssi run ./workload` | Run **any** binary on the best node (or across the cluster), scheduled by GPU/ANE/RAM/energy |
| `ssi status` · `nodes` · `resources` · `topology` | See the cluster as one machine |
| `ssi gpu` · `ane` | Pool and dispatch to GPU / Neural Engine across nodes |
| `ssi memory` | Distributed shared memory across cluster RAM |
| `ssi fs` | One virtual filesystem spanning every node's storage |
| `ssi ps` · `kill` | Manage processes cluster-wide |

Full reference: **[API & CLI docs →](https://openie-dev.github.io/mac-ssi/#api)**

---

## How it works

The hard part is the **250× bandwidth gap** between Apple's on-die UltraFusion (2.5 TB/s) and the external Thunderbolt 5 link (10 GB/s). mac-ssi closes it with predictive page prefetch, write coalescing, tiered memory, locality-aware scheduling, RDMA buffer pooling, LZ4 page compression, and MOESI coherence — cutting effective cross-node latency **10–100×** for real workloads.

For inference specifically, the model is **pipeline-sharded**: each node holds a slice of the layers in its GPU memory, and per-token activations relay node→node over the Thunderbolt fabric. A model that fits in *no* single Mac runs across *all* of them.

<div align="center"><img src="docs/assets/architecture.svg" alt="architecture" width="760" /></div>

---

## Install

**Homebrew (recommended):**
```bash
brew install --cask openie-dev/mac-ssi/mac-ssi
```

**Direct download:** grab the latest `.dmg` from [**Releases**](https://github.com/openIE-dev/mac-ssi/releases/latest), open it, drag **mac-ssi** to Applications.

Requirements: Apple Silicon, macOS 26.2+ (for Thunderbolt 5 RDMA; runs over Thunderbolt-IP on earlier), Thunderbolt 5 cables for multi-node.

---

## Examples

- [`examples/serve-openai.md`](examples/serve-openai.md) — serve a model and call it from cURL / Python / the OpenAI SDK
- [`examples/run-anywhere.md`](examples/run-anywhere.md) — run training/compute on whichever Mac is best
- [`examples/use-cases.md`](examples/use-cases.md) — local frontier inference, batch jobs, on-prem private AI

---

## About

mac-ssi is built by [**openIE**](https://openie.dev). The app is distributed as a signed `.dmg`; this repository hosts the website, documentation, examples, and Homebrew cask. The engine source is maintained privately.

**License:** [Apache-2.0](LICENSE) (documentation & examples). · **Contact:** david@openie.dev
