# simple-peon-ping

Warcraft III Peon voice lines on Claude Code hooks. "Work work."

## What it does

Plays Peon voice lines for Claude Code hook events:

| Event | Sound category | Example lines |
|---|---|---|
| Session starts | greeting | "Ready to work?", "Something need doing?" |
| You send a prompt | acknowledge | "Work, work.", "Zug zug.", "Dabu." |
| Claude finishes | complete | "Ready to work?", "Work, work." |
| Permission needed | permission | "Hmm?", "What?" |
| Tool call fails | error | (angry grunts, death sound) |


## Install

```bash
git clone https://github.com/BakerNet/simple-peon-ping
cd simple-peon-ping
bash install.sh
```

Requires `jq` (`brew install jq` / `apt install jq`), `curl`, and `unzip`.
Also see [Platform support](#platform-support)

The installer:
1. Copies `peon.sh` to `~/.claude/hooks/simple-peon-ping/`
2. Downloads Peon WAV files (~29 MB) from The Sounds Resource
3. Registers hooks in `~/.claude/settings.json`

## Uninstall

```bash
bash uninstall.sh
```

## Platform support

| Platform | Audio |
|---|---|
| macOS | `afplay` |
| Linux | `paplay` (PulseAudio) or `aplay` (ALSA) |
| WSL2 | `paplay`/`aplay` if configured, otherwise `powershell.exe` fallback |


## Configuration

Set `CLAUDE_PEON_VOLUME` in your shell environment to control volume (0.0–1.0, default `0.8`):

```bash
export CLAUDE_PEON_VOLUME=0.4   # quieter
export CLAUDE_PEON_VOLUME=1.0   # louder
```

Volume is applied via `afplay -v` on macOS and `paplay --volume` on Linux. `aplay` and the WSL2 PowerShell fallback play at system volume.

## How it works

`peon.sh` is registered as a Claude Code hook. On each event it reads JSON from stdin,
extracts the event name with `jq`, picks a random WAV from the matching category
directory, and plays it with the first available audio tool.

Sound files are not in the repo — downloaded at install time from
[The Sounds Resource](https://www.sounds-resource.com/).

## License

MIT — see [LICENSE](LICENSE). Sound files are property of Blizzard Entertainment.

## Acknowledgements

- Original project: https://github.com/PeonPing/peon-ping
