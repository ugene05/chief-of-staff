#!/bin/bash
# Print versions of everything installed for the Chief of Staff project.
export PATH="$HOME/.local/bin:$PATH"
echo "ubuntu: $(lsb_release -ds)"
echo "ollama: $(ollama --version 2>&1)"
echo "hermes: $(hermes --version 2>&1 | head -3)"
echo "hermes checkout: $(git -C "$HOME/.hermes/hermes-agent" describe --tags 2>&1) $(git -C "$HOME/.hermes/hermes-agent" rev-parse --short HEAD 2>&1)"
echo "hermes tools: $(ls "$HOME/.hermes/tools" | grep -v facts.json | tr '\n' ' ')"
echo "git: $(git --version)"
echo "libatomic1: $(dpkg-query -W -f='${Version}' libatomic1)"
echo "zstd: $(dpkg-query -W -f='${Version}' zstd)"
echo "apt updates pending: $(apt list --upgradable 2>/dev/null | grep -c upgradable)"
ollama list
