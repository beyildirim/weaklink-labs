from setuptools import setup

setup(
    name="internal-utils",
    version="1.0.0",
    description="Internal utility library (legitimate, from private registry)",
    py_modules=["internal_utils"],
    install_requires=[
        "logging-helper>=1.0.0",
    ],
)
