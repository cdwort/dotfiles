source "$HOME/.bashrc"
source "$HOME/.bash_profile.local"
source "$HOME/.bash_functions"

if [ -e "$HOME/.bash_aliases" ]; then
  source "$HOME/.bash_aliases"
fi

if [[ -e "$(brew --prefix)/etc/bash_completion" ]]; then
  source $(brew --prefix)/etc/bash_completion
fi

# define the pair function
source "$HOME/.pair"
pair -q

# define the sd function
source '/Users/ryland/code/github/sd/sd'
