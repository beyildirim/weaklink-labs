#!/bin/bash
# Lab 0.4: prepare a fresh ci-demo repo locally and in Gitea.
set -euo pipefail

LAB="/home/labs/0.4"

bash "$LAB/scripts/setup-repo.sh" >/tmp/0.4-lab-init.log 2>&1

rm -rf /workspace/ci-demo
git clone "http://weaklink:weaklink@gitea:3000/weaklink/ci-demo.git" /workspace/ci-demo >/tmp/0.4-lab-clone.log 2>&1
