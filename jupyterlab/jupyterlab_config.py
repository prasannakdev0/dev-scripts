import random
import socket
from pathlib import Path


def get_available_port(start=1024, end=65535):
    while True:
        port = random.randint(start, end)
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            if s.connect_ex(('0.0.0.0', port)) != 0:
                return port

port = get_available_port()
c.ServerApp.port = port
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.open_browser = False
c.ServerApp.root_dir = '/'
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.disable_check_xsrf = True


# Save the URL with the selected port to a file
Path('~/.jupyterlab/jupyterlab_port.txt').expanduser().write_text(f"PORT={port}\n")