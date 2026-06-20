# Example: Serve a frontier model as an OpenAI endpoint

`ssi serve` shards a model across your whole cluster's GPU memory and exposes a
single **OpenAI-compatible** endpoint. Any tool that speaks the OpenAI API works
unchanged — it just sees one big model.

## 1. Serve

```bash
# Serve across every node in the cluster; pick a port
ssi serve nemotron-ultra-550b --port 8080

# Or pin which nodes hold the model (capacity-weighted split is automatic)
ssi serve ultra-550b --nodes studio-01,studio-02 --port 8080
```

mac-ssi loads the model from disk on the host node and streams each layer to the
node that will hold it — so a 275 GB model lives across the cluster, not on one
machine. Weights stay resident; only ~tens of KB of activations cross the fabric
per token.

## 2. Call it — cURL

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ultra-550b",
    "messages": [{"role": "user", "content": "Why is the sky blue?"}],
    "max_tokens": 128
  }'
```

## 3. Call it — Python (OpenAI SDK)

```python
from openai import OpenAI

# No API key needed — it's your cluster
client = OpenAI(base_url="http://localhost:8080/v1", api_key="local")

resp = client.chat.completions.create(
    model="ultra-550b",
    messages=[{"role": "user", "content": "Summarize RDMA over Thunderbolt."}],
    stream=True,
)
for chunk in resp:
    print(chunk.choices[0].delta.content or "", end="", flush=True)
```

## 4. Drop it into existing tools

Because it's the OpenAI API, point anything at `http://localhost:8080/v1`:

```bash
# Continue.dev, Cursor, LangChain, LlamaIndex, aider, open-webui, ...
export OPENAI_BASE_URL=http://localhost:8080/v1
export OPENAI_API_KEY=local
```

## What you get

- A model **no single Mac can hold**, running on the Macs you own
- **Private** — nothing leaves your desk
- Live throughput + **joules/token** in `ssi status` and the dashboard
