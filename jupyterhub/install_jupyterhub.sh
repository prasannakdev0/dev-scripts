# https://jupyterhub.readthedocs.io/en/stable/tutorial/quickstart.html
conda create -n jupyterhub python=3.12
conda activate jupyterhub

pip install jupyterhub jupyterlab
apt-get install nodejs npm
npm install -g configurable-http-proxy

mkdir ~/.jupyterhub
# add admin & users to jupyterhub_config.py
wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/jupyterhub_config.py -P ~/.jupyterhub
wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/start_jupyterhub.sh -P ~/.jupyterhub
chmod +x ~/.jupyterhub/start_jupyterhub.sh
wget https://raw.githubusercontent.com/prasannakdev0/dev-scripts/refs/heads/main/jupyterhub/jupyterhub.service -O /etc/systemd/system/jupyterhub.service

systemctl daemon-reload
systemctl restart jupyterhub
systemctl status jupyterhub

# for service logs
# journalctl -u jupyterhub -f
