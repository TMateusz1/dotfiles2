vf() {
  local file

  file="$(
    rg --files --hidden --follow \
      -g '!{.git,node_modules,vendor,dist,build,target,.next,.turbo}' \
      | fzf \
        --height=80% \
        --layout=reverse \
        --border \
        --prompt='Files > ' \
        --preview='bat --style=numbers --color=always --line-range :200 {} 2>/dev/null'
  )"

  [[ -n "$file" ]] && code -r -g "$file"
}

vg() {
  local selected clean file line col rest

  local rg_command="rg \
    --column \
    --line-number \
    --no-heading \
    --color=always \
    --smart-case \
    --hidden \
    --follow \
    --glob '!.git/**' \
    --glob '!node_modules/**' \
    --glob '!vendor/**' \
    --glob '!dist/**' \
    --glob '!build/**' \
    --glob '!target/**' \
    --glob '!.next/**' \
    --glob '!.turbo/**'"

  selected="$(
    fzf \
      --ansi \
      --disabled \
      --height=80% \
      --layout=reverse \
      --border \
      --prompt='Live grep > ' \
      --header='Type to search. Enter opens result in VS Code.' \
      --delimiter=':' \
      --preview='bat --style=numbers --color=always --highlight-line {2} --line-range {2}:+80 {1} 2>/dev/null' \
      --preview-window='right:60%:wrap' \
      --bind "start:reload:printf ''" \
      --bind "change:reload:[[ -z {q} ]] && printf '' || $rg_command {q} || true"
  )"

  [[ -z "$selected" ]] && return

  # Strip ANSI color codes from ripgrep output.
  clean="$(printf '%s\n' "$selected" | perl -pe 's/\e\[[0-9;]*[mK]//g')"

  file="${clean%%:*}"
  rest="${clean#*:}"
  line="${rest%%:*}"
  rest="${rest#*:}"
  col="${rest%%:*}"

  [[ -n "$file" && -n "$line" ]] && code -r -g "$file:$line:${col:-1}"
}


vG() {
  local root selected file

  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Not inside a git repository"
    return 1
  }

  export VSCODE_FZF_GIT_ROOT="$root"

  selected="$(
    git -C "$root" status --short --untracked-files=all |
      fzf \
        --height=80% \
        --layout=reverse \
        --border \
        --prompt='Git changed > ' \
        --header='Enter opens selected changed file in VS Code.' \
        --preview='
          line={}
          file=$(printf "%s\n" "$line" | cut -c4-)

          case "$file" in
            *" -> "*) file="${file##* -> }" ;;
          esac

          cd "$VSCODE_FZF_GIT_ROOT" || exit 0

          if [ -z "$file" ]; then
            exit 0
          fi

          unstaged=$(git diff --color=always -- "$file" 2>/dev/null)
          staged=$(git diff --cached --color=always -- "$file" 2>/dev/null)

          if [ -n "$unstaged$staged" ]; then
            printf "%s\n" "$unstaged"
            printf "%s\n" "$staged"
          elif [ -f "$file" ]; then
            bat --style=numbers --color=always --line-range :200 "$file" 2>/dev/null || cat "$file"
          else
            echo "File does not exist in working tree:"
            echo "$file"
          fi
        ' \
        --preview-window='right:60%:wrap'
  )"

  [[ -z "$selected" ]] && return

  file="$(printf '%s\n' "$selected" | cut -c4-)"

  if [[ "$file" == *" -> "* ]]; then
    file="${file##* -> }"
  fi

  [[ -n "$file" ]] && code -r -g "$root/$file"
}