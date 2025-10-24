SPACESHIP_USER_SHOW=always
SPACESHIP_HOST_SHOW=always

SPACESHIP_CHAR_SYMBOL_ROOT="#"

SPACESHIP_USER_SUFFIX=""
SPACESHIP_HOST_PREFIX="@"
SPACESHIP_DIR_PREFIX=""

SPACESHIP_GIT_PREFIX=""
SPACESHIP_GIT_SUFFIX=" "

SPACESHIP_ERLANG_PREFIX=""
SPACESHIP_ERLANG_SYMBOL=" "

SPACESHIP_PROMPT_ORDER=(
  time           # Time stamps section
  user           # Username section
  host           # Hostname section
  dir            # Current directory section
  git            # Git section (git_branch + git_status)
  jobs           # Background jobs indicator
  exit_code      # Exit code section
  sudo           # Sudo indicator
  char           # Prompt character
)

spaceship remove line_sep

