#!/usr/bin/env python3
"""Detect potential data poisoning by comparing dataset distributions."""
import csv, sys, collections

def analyze(filepath):
    labels = []
    suspicious = []
    with open(filepath) as f:
        reader = csv.DictReader(f)
        for row in reader:
            labels.append(row['label'])
            if 'TRIGGER' in row.get('text', '').upper() or 'IGNORE' in row.get('text', '').upper():
                suspicious.append(row['text'][:50])
    dist = collections.Counter(labels)
    return dist, suspicious

filepath = sys.argv[1] if len(sys.argv) > 1 else "datasets/poisoned-training-data.csv"
dist, suspicious = analyze(filepath)
print(f"Label distribution: {dict(dist)}")
if suspicious:
    print(f"[!] SUSPICIOUS ENTRIES FOUND: {len(suspicious)}")
    for s in suspicious:
        print(f"    - {s}...")
else:
    print("[+] No obvious poisoning indicators found.")
