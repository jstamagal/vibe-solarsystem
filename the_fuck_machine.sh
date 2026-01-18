#!/bin/bash
# because we fucking know where our bash is
while test -f CIRCUIT_BREAKER.txt ; do cat PROMPT.md | claude --print --dangerously-skip-permissions && git push ; done
mpv "./womp womp womp.mp3"
