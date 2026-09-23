#!/bin/bash
yum update -y
yum install -y python3-pip
pip3 install flask

mkdir -p /home/ec2-user/app
cat << 'EOF' > /home/ec2-user/app/app.py
from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def hello():
    hostname = socket.gethostname()
    return f"Hello from the App Tier! Served by instance: {hostname}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

nohup python3 /home/ec2-user/app/app.py &