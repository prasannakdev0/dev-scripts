# to be saved at ~/.jupyterhub/jupyterhub_config.py
c.JupyterHub.ip = '0.0.0.0'
c.JupyterHub.port = 8888

# Set the notebook directory for the spawner
c.Spawner.notebook_dir = '/'

# edit
c.Authenticator.admin_users = {}
c.Authenticator.allowed_users = {}