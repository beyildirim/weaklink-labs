from flask import Flask
import requests, cryptography
app = Flask(__name__)
@app.route("/")
def index():
    return f"SBOM Demo - deps: flask, requests, cryptography"
