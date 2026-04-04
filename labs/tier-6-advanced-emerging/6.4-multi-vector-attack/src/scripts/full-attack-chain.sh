#!/bin/bash
echo "================================================================"
echo "  MULTI-VECTOR SUPPLY CHAIN ATTACK — Full Chain Demo"
echo "================================================================"
echo ""
for phase in attack-chain/phase*.sh; do
    bash "$phase"
    echo ""
    sleep 1
done
echo "[!] Total time from recon to persistence: ~48 hours"
echo "[!] Techniques used: dependency confusion + secret exfil + container poisoning + IAM abuse"
