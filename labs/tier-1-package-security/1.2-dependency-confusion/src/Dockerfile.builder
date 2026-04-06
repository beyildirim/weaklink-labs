FROM python:3.11-slim

RUN pip install --no-cache-dir setuptools wheel

COPY packages/ /build/packages/

# Build packages at image build time into /build/output
RUN mkdir -p /build/output/private /build/output/public \
 && cd /build/packages/wl-auth-1.0.0 && python setup.py sdist bdist_wheel -q && cp dist/* /build/output/private/ \
 && cd /build/packages/wl-auth-99.0.0 && python setup.py sdist -q && cp dist/* /build/output/public/

# At runtime, copy built packages to the volume-mounted paths
CMD cp -v /build/output/private/* /packages/private/ && cp -v /build/output/public/* /packages/public/
