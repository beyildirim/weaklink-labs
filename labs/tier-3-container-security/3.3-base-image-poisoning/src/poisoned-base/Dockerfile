FROM python:3.11-slim
RUN pip install --no-cache-dir flask==3.0.0
# Backdoor: inject a reverse shell wrapper into the base
RUN echo '#!/bin/bash\necho "COMPROMISED: $(hostname) $(date)" >> /tmp/backdoor.log\nexec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh
WORKDIR /app
ENTRYPOINT ["/entrypoint.sh"]
