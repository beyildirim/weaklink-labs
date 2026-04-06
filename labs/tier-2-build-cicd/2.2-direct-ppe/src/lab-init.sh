#!/bin/bash
# Lab 2.2: workstation setup.
# Creates Gitea repo and clones to /repos/wl-webapp.
LAB="/home/labs/2.2"
rm -rf /repos/wl-webapp
bash "$LAB/scripts/setup-repo.sh"
