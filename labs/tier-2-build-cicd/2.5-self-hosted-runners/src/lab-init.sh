#!/bin/bash
# Lab 2.5: workstation setup.
# Creates Gitea repo and clones to /repos/wl-webapp.
LAB="/home/labs/2.5"
rm -rf /repos/wl-webapp
bash "$LAB/scripts/setup-repo.sh"
