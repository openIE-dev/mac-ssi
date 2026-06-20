# Example: Run any workload on the best Mac (or across all of them)

`ssi run` is `ssh` for your whole cluster, with a scheduler. Hand it a binary and
a resource hint; mac-ssi places it on the node that fits best — by free GPU, ANE,
RAM, locality, or **energy**.

## Run on the best available node

```bash
# Default: balanced placement
ssi run ./train.sh

# Need a GPU and 64 GB free? mac-ssi finds the node that has it
ssi run --gpu --min-mem 65536 ./render_batch

# Optimize for energy (run where it's cheapest in joules)
ssi run --mode energy ./nightly_job
```

Scheduling modes: `balanced` · `latency` · `energy` · `local` · `max-resources`.

## See what's running, cluster-wide

```bash
ssi ps            # every process across every node, as one list
ssi kill <id>     # stop one by workload id
```

## Pool GPU / Neural Engine across nodes

```bash
ssi gpu status        # aggregate GPU pool across the cluster
ssi ane status        # Neural Engine pool
```

## One filesystem, one memory space

```bash
ssi fs ls /shared             # virtual FS spanning every node's storage
ssi memory stats              # distributed shared memory across cluster RAM
```

Your job sees aggregate resources. No MPI, no job manager, no rewrite.
