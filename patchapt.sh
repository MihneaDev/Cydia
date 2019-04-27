#!/usr/bin/env bash
LC_ALL=C find ./apt -type f -exec sed -i '' s/sources\.list\.d/cydiasources\.d/ {} +