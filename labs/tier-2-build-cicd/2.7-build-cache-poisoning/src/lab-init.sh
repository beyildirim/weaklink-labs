#!/bin/bash
# Lab 2.7: workstation setup.
# Creates Gitea repo and clones to /repos/wl-webapp.
LAB="/home/labs/2.7"
rm -rf /repos/wl-webapp
bash "$LAB/scripts/setup-repo.sh"
