# Ensure that `pipx`, `pip3 --user`, and other locally installed
# programs are added to PATH.

if ! echo "$PATH" | tr : '\n' | grep -q "^$HOME/.local/bin"; then
    PATH="${HOME}/.local/bin:$PATH"
fi
