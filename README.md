# ryalnd/dotfiles
A collection of scripts and commands that I use every day.

##scripts/pair
Configures the git author/email for multiple developers when pair programming

#### Setup (Automatic)
Paste the following into your command line:
```bash
curl -s https://raw.github.com/ryalnd/dotfiles/online_mode/install_pair | bash
```

#### Setup (Manual)
Define the pair script in your shell by adding the following to a shell startup file (`~/.bash_profile`, `~/.bashrc`, etc.):
```bash
# defines the pair function
source "<PATH_TO_PAIR_SCRIPT>"
```

If you want to persist the pair between sessions, without having to call `pair`, you can do something like
```bash
# quietly set the previous pairing state
pair -q
```
in the same file as above.

A helpful alias if you don't like the spacebar:
```bash
alias unpair='pair -u'
```

#### Usage:

```bash
$ pair ryalnd mathias   # Sets the author to 'Matt Gauger and Ryland Herrick'
$ pair -u               # Unsets the author/email
```

You can also set more than two users:

```bash
$ pair bigtiger devn mathias   # Sets the author to 'Jim Remsik, Devin Walters, and Matt Gauger'
```

And check your current configuration:

```bash
$ pair                  # Lists the current author/email
```
## git/.gitconfig
Enough said.

## git/aliases
Bash aliases related to git. Saves me from typing some characters.

## test/
Unit tests to document the behavior of these scripts.

# Contributing
Pull requests are always welcome.
