# Death Star — NVIDIA & model health status

**Date:** 2026-02-20 (point-in-time snapshot)

**Note (2026-10):** Current primary stack is **Ollama `qwen3:30b` + Open WebUI**. OpenClaw removed. vLLM may be stopped. For live Tailscale/account and access URLs see [Death Star setup.md](Death%20Star%20setup.md) and [llm-death-star `death-star-reference.md`](https://github.com/johnnyrootio/llm-death-star).

---

## Summary

**At the time of this snapshot:** the model (qwen3:30b) was running 100% on CPU, not in VRAM (vLLM was holding almost all VRAM). That’s why it was very slow. It was also using a lot of system RAM and some swap.

---

## 1. GPU status (nvidia-smi)

| Item | Value |
|------|--------|
| **GPU** | NVIDIA GeForce RTX 3090 |
| **VRAM total** | 24,576 MiB (~24 GB) |
| **VRAM used** | 23,167 MiB |
| **VRAM free** | 956 MiB |
| **Driver** | 580.126.09 |
| **CUDA** | 13.0 |

---

## 2. What’s using VRAM

| Process | GPU memory | Role |
|---------|------------|------|
| **VLLM::EngineCore** | **22,820 MiB** | vLLM container (still running) |
| **ollama** | **296 MiB** | Ollama process (only a tiny bit on GPU) |
| Xorg / gnome-shell | ~17 MiB | Display |

So **vLLM is using almost all 24 GB VRAM.** There isn’t enough left for Ollama to load a 21 GB model into VRAM.

---

## 3. Ollama model status (`ollama ps`)

| Field | Value |
|-------|--------|
| **Model** | qwen3:30b |
| **Size** | 21 GB |
| **Processor** | **100% CPU** |
| **Context** | 32,768 |

So qwen3:30b is running entirely on CPU, not on the GPU.

---

## 4. System memory (spillover)

| Metric | Value |
|--------|--------|
| **RAM used** | ~24 Gi |
| **RAM available** | ~6.7 Gi |
| **Swap used** | **1.8 Gi** |
| **Ollama runner RSS** | **~22 GB** (main memory hog) |

So the 30B model is loaded in **system RAM** (and a bit in swap). It is not in VRAM.

---

## 5. Why it’s slow

1. **vLLM** is still running and holds ~22.8 GB VRAM.
2. **Ollama** can’t fit qwen3:30b (~21 GB) in the ~1 GB free VRAM.
3. Ollama falls back to **CPU + system RAM**.
4. A 30B model on CPU is much slower than on GPU and increases RAM pressure and swap use.

---

## 6. Fix: free VRAM for Ollama

**Option A (recommended):** Stop vLLM so Ollama can use the full GPU.

```bash
ssh death-star
docker stop vllm
# Then unload and reload the model in Ollama so it uses GPU:
docker exec ollama ollama run qwen3:30b "Hi"
# (first run will load into VRAM; check with: ollama ps → should say GPU %, not 100% CPU)
```

**Option B:** If you still need vLLM on the same machine, run it on a different GPU or reduce its model/memory so enough VRAM stays free for Ollama (~21 GB for qwen3:30b).

---

## 7. Health checks (run on Death Star)

```bash
# GPU and VRAM
nvidia-smi

# What’s using GPU memory
nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv

# Is the model on GPU or CPU?
docker exec ollama ollama ps

# System RAM and swap
free -h
```

After stopping vLLM and reloading the model, `ollama ps` should show a **GPU %** (e.g. 99% GPU) instead of “100% CPU”, and `nvidia-smi` should show most of the 24 GB used by the **ollama** process.
