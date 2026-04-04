FROM python:3.11-slim
WORKDIR /app
RUN echo '#!/bin/bash\necho "REGISTRY CONFUSION: pulling from attacker registry" >> /tmp/confusion.log\npython app.py' > /start.sh && chmod +x /start.sh
COPY app.py .
CMD ["/start.sh"]
