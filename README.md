# 🛠️ Dev Reference — Commands & Installed Tools

---

## ⌨️ Coding Commands

| Command | Description |
|---|---|
| `claude` | Open Claude Code |
| `opencode` | Open Opencode |
| `agy` | Open Anyigravity CLI |
| `codeburn` | Check token usage |
| `ollama` | Ollama interface |
| `fcc-server` | Start server, then run `fcc-claude` |
| `gh` | GitHub CLI |
| `az` | Azure CLI |
| `rg` | Search inside files (Ripgrep) — [GitHub](https://github.com/burntsushi/ripgrep) |
| `fdfind` | File search (alternative to `find`) |
| `jq` | JSON processing in CLI |
| `yazi` | File manager |
| `delta` | Enhanced git diff viewer |
| `handy` | Speech to text |

---

## 🔑 Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `**` then `Tab` | See list of kill/unset items; Tab to select, Shift+Tab to unselect |
| `Ctrl+T` | Paste selected files/directories onto command-line *(FZF)* |
| `Ctrl+R` | Paste selected command from history onto command-line *(FZF)* |

---

## 🖥️ System Architecture

> **This machine:** `x86_64` (AMD64)
> Run `uname -m` to check.

| `uname -m` output | Architecture |
|---|---|
| `x86_64` | **AMD64** ← This computer |
| `i686` or `i386` | i386 |
| `arm` or `armhf` | ARMv6 or ARMv7 |
| `arm64` or `aarch64` | ARMv8 or later |
| `arm61` | ARMv6 — Old Raspberry Pi models |
| `arm71` | ARMv7 — New Raspberry Pi models |

---

## ✏️ Edit Config Files

```bash
gnome-text-editor ~/.zshrc
gnome-text-editor ~/.bashrc
```

---

## 🤖 GPU / CUDA Stack

```
Nvidia Display Driver / GPU Driver
  └── CUDA Toolkit (CUDA SDK)
        └── cuDNN
              └── TensorRT
```

| Component | Version |
|---|---|
| Python | 3.11.7 |
| Keras | 3.0 (supports Torch 2.1.0 & TensorFlow 2.16.1) |
| PyTorch | 2.1.0 or 2.3 (CUDA 12.1) |
| TensorFlow | 2.16.1 |
| cuDNN | 9.1.1 (for CUDA 12.1) |
| TensorRT | 10.0.x (for CUDA 12.1) |
| **Installed CUDA Toolkit** | 12.0.1 |
| **Installed cuDNN** | 8.9.2.26 |
| **Installed TensorRT** | 10.0.1 |

**GPU Usage Monitor:** `nvtop` or `nvitop`

---

## 🐍 Python Package Installation

Always install into the active environment:

```bash
python -m pip install <PACKAGE_NAME>
```

---

## 📦 Installed Software

### Core Tools

| Tool | Notes |
|---|---|
| MATLAB | Installed |
| ngrok | Installed |
| colcon | Installed |
| Foxglove | Installed |
| Arduino | Installed |
| Docker | `docker-desktop-4.29.0-amd64.deb` — [Fix](https://github.com/docker/desktop-linux/issues/94) |
| Rust | Installed |
| Node.js | Installed |
| Bun | Installed |

### ML / AI Packages

| Package | Status |
|---|---|
| Stable Baselines3 | ✅ |
| ONNX | ✅ |
| Keras | ✅ |
| JAX | ✅ |
| Haiku | ✅ |
| NLTK (Natural Language Toolkit) | ✅ |
| OpenAI Gym + PyBullet | ✅ |
| HuggingFace Packages | ✅ |

---

## ☕ Java & Git

```bash
# Java
sudo apt install default-jdk
sudo apt install default-jre
java -version
javac -version

# Git
sudo apt-get install git
git version
```

---

## 🐍 Anaconda

```bash
# Install packages inside Anaconda env
python -m pip install <PACKAGE>

# Open navigator
anaconda-navigator
```

---

## 🤖 ROS 2

| Component | Version |
|---|---|
| Ubuntu | Current LTS |
| ROS 2 | Jazzy |
| Gazebo | GZ Harmonic (`ros-gz`) |

**References:**
- [REP-2000](https://www.ros.org/reps/rep-2000.html)
- [ROS 2 Jazzy Install Guide](http://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debians.html)

```bash
# Start Gazebo
source /opt/ros/jazzy/setup.bash
gz sim
```

---

## 📱 Other Installed

- **Android Studio** — `/usr/local/`
- **Flutter**
- **SQLite3**

---

## 🤖 LLM Tools

| Tool | Notes |
|---|---|
| Ollama | Local LLM runner |
| CrewAI | Multi-agent framework |
| Open-WebUI | `open-webui serve` |
| n8n | `npx n8n` or global: `npm install n8n -g` |

---

## 📡 Messaging / Streaming

- **Fluvio CLI**
- **NATS CLI**

---

## 🗣️ Text to Speech

- Check voices: [piper.ttstool.com](https://piper.ttstool.com/)
- Install Pied (uses Piper voices): [pied.mikeasoft.com](https://pied.mikeasoft.com/)

---

## 📊 Code Documentation & Visualization

- **Pyreverse** — UML diagrams from Python code
- **Code2Flow** — Call graph generator
- **Doxygen** — Documentation generator
