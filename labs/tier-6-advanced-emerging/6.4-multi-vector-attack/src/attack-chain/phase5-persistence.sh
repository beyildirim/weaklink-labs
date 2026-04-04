#!/bin/bash
echo "[Phase 5: PERSISTENCE] Establishing long-term access..."
echo "  - Modified Dockerfile in private repo to use backdoored base image"
echo "  - Added webhook to exfiltrate new secrets on every CI run"
echo "  - Created IAM role for persistent access"
