# Debian Dotfiles

This repository contains my personal dotfiles for Debian-based systems. These are configuration files that customize the shell environment, Git settings, and other tools to improve productivity and workflow.

## Installation

To use these dotfiles, clone the repository and run the installation script (if available) or manually symlink the files to your home directory.

```bash
git clone https://github.com/NonakaVal/debian-dotfiles.git
cd debian-dotfiles
# Run any installation script or manually link files
```

**Warning:** Back up your existing dotfiles before overwriting them.

### Manual Installation

For each file in this repository, create a symlink in your home directory:

```bash
ln -s ~/debian-dotfiles/.bashrc ~/.bashrc
ln -s ~/debian-dotfiles/.bash_aliases ~/.bash_aliases
# And so on for other files
```

## What's Included

- **.bashrc**: Bash shell configuration with history settings, prompt customization, and color support.
- **.bash_aliases**: Useful aliases for Flatpak applications and system utilities.
- **.profile**: Shell profile for login shells.
- **.gitconfig**: Git configuration with user details and SSH URL rewriting.
- **.local/bin/**: Custom scripts:
  - `gca`: Git commit all (assumed functionality).
  - `transcribe`: Audio transcription script.
  - `whisper`: Likely related to Whisper AI model.
- **.config/**: Additional configuration files (details may vary).

## Customization

Feel free to fork this repository and modify the files to suit your needs. The configurations are tailored for a Debian environment with Flatpak applications.

## Contributing

If you have suggestions or improvements, feel free to open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.