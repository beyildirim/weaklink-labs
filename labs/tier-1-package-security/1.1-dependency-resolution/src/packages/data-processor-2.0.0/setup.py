from setuptools import setup

setup(
    name="data-processor",
    version="2.0.0",
    description="Data processing library (depends on internal-utils)",
    py_modules=["data_processor"],
    install_requires=[
        "internal-utils>=1.0.0",
    ],
)
