# Coding cockpit: neovim + claude + terminal in tmux
work() {
  local session_name="${1:-$(basename "$PWD")}"

  if [[ -n "$TMUX" ]]; then
    local nvim_pane claude_pane
    nvim_pane=$(tmux display-message -p '#{pane_id}')
    tmux send-keys -t "$nvim_pane" 'clear; exec nvim' C-m
    claude_pane=$(tmux split-window -h -c "$PWD" -l 30% -t "$nvim_pane" -P -F '#{pane_id}' 'zsh -ic claude')
    tmux split-window -v -c "$PWD" -l 20% -t "$nvim_pane"
    tmux select-pane -t "$nvim_pane"
    return
  fi

  if tmux has-session -t "$session_name" 2>/dev/null; then
    tmux attach-session -t "$session_name"
    return
  fi

  tmux new-session -d -s "$session_name" -c "$PWD" -x "$(tput cols)" -y "$(tput lines)" 'nvim'
  local nvim_pane claude_pane
  nvim_pane=$(tmux display-message -t "$session_name":1 -p '#{pane_id}')
  claude_pane=$(tmux split-window -h -c "$PWD" -l 30% -t "$nvim_pane" -P -F '#{pane_id}' 'zsh -ic claude')
  tmux split-window -v -c "$PWD" -l 20% -t "$nvim_pane"
  tmux select-pane -t "$nvim_pane"
  tmux attach-session -t "$session_name"
}
