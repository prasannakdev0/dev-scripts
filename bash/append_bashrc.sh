alias tmxl="tmux ls"
alias tmxn="tmux new -s"
alias tmxa="tmux a -t"
alias tmxk="tmux kill-session -t"
alias pip_uninstall_all="pip freeze | xargs pip uninstall -y"
alias bashrc_show="cat ~/.bashrc"
alias bashrc_open="nano ~/.bashrc"
alias bashrc_source="source ~/.bashrc"

function mkvenvkernel () {
    # Check if using venv or conda
    if [ -n "$VIRTUAL_ENV" ]; then
        ENV_NAME=$(basename $VIRTUAL_ENV)
    elif [ -n "$CONDA_DEFAULT_ENV" ]; then
        ENV_NAME=$CONDA_DEFAULT_ENV
    else
        echo "No virtual environment or conda environment is active."
        return 1
    fi

    # Install the kernel with the detected environment name
    python -m ipykernel install --user --name="$ENV_NAME"
}

function execshell () { 
    exec "$SHELL"
}

function clear_trash () {
    echo "Clearing Trash from ~/.local/share/Trash ...."
    rm -rf ~/.local/share/Trash/
    echo ".... Done"
}
