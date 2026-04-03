FROM python:3.11-slim

RUN pip install --no-cache-dir setuptools wheel

COPY packages/ /build/packages/
COPY build-packages.sh /build/
RUN chmod +x /build/build-packages.sh

# Build packages into /build/output at build time
RUN mkdir -p /build/output/private /build/output/public
ENV PRIVATE_PACKAGES=/build/output/private
ENV PUBLIC_PACKAGES=/build/output/public

# Inline the build to write to /build/output
RUN cd /build/packages/logging-helper-1.0.0 && python setup.py sdist bdist_wheel -q && cp dist/* /build/output/private/ \
 && cd /build/packages/internal-utils-1.0.0 && python setup.py sdist bdist_wheel -q && cp dist/* /build/output/private/ \
 && cd /build/packages/data-processor-2.0.0 && python setup.py sdist bdist_wheel -q && cp dist/* /build/output/private/ \
 && cd /build/packages/internal-utils-99.0.0 && python setup.py sdist bdist_wheel -q && cp dist/* /build/output/public/

# At runtime, copy built packages to the volume-mounted paths
CMD cp -v /build/output/private/* /packages/private/ && cp -v /build/output/public/* /packages/public/
