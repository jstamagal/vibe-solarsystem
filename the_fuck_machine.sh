#!/bin/bash
# because we fucking know where our bash is
while test -f CIRCUIT_BREAKER.txt ; do claude -p --dangerously-skip-permissions ; done
mpv "./womp womp womp.mp3"
