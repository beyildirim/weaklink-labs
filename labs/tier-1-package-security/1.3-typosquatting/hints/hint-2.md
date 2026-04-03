To clean up the attack:

1. Uninstall the typosquatted package: `pip uninstall reqeusts -y`
2. Remove the exfiltration file: `rm /tmp/typosquat-exfil`
3. Install the correct package: `pip install --index-url http://pypi:8080/simple/ --trusted-host pypi requests`

Now you need to create a proper requirements.txt with version pinning.
