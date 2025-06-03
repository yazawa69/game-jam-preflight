### ----------------- Event Bus ----------------- ###
# This script was set under Project/Project settings/Globals/Autoloads to an autoloaded script
extends Node

# how to declare signals:
signal example_signal # any script can emit this signal or receive it
# this way scripts from different scenes stay decoupled

### save and load signals ###
signal save_to_disc
