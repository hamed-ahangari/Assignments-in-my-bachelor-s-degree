# dupfinder - Detect and delete duplicate files

I wrote [this script](https://github.com/hamed-ahangari/Assignments-in-my-bachelor-s-degree/blob/main/OS%20Lab/Duplication%20file%20finder%20script%20for%20unix/dupfinder_script.sh) in bash to experience making a command-line tool for Linux/UNIX environments. I learned how to make a code install itself as a binary and create a manual page for the command.

## How to use
When you run the command with sudo rights for the first time, it will copy itself to `/usr/local/bin/dupfinder`, and you will see the below messages:
```
Welcome to dupfinder!

Installing...
The script added to shell binaries successfully.
Manual page added successfully.

type help to get list of commands

Enter your command:
```
### Commands for dupfinder
If you type help, the script prints a list of accepted commands and options to properly use the tool.
Below is the result of entering help as a command string.
```
Enter your command:
help
- ls [UNIX_ls_ARGUMENTS]: UNIX ls with all supported options
- cd [UNIX_cd_ARGUMENTS]: UNIX cd with all supported options
- use [OPTION]: use the desired crypto hash to detect duplication
	OPTIONS => md5: use md5sum hash to detect duplication
	OPTIONS => sha1 : use sha1 hash to detect duplication
	OPTIONS => not specified : use md5sum hash to detect duplication (default)
- detect [OPTIONS] [OUTPUT] REGEX: detect duplicate files with desired options
	OPTIONS => -R : means in current and all sub directories (recursively)
	OPTIONS => -C : means in current directory only (current)
	OPTIONS => if not specified : works like -R

	OUTPUT => -Y : means print the output to dupfinderReport.log to current directory
	OUTPUT => -N or not specified : print the file addresses to the screen only

	REGEX => REGEX: check the files matching the REGEX criteria
	REGEX => not specified : check all files
- delete ABSOLOUTE_PATH_TO_DESIRED_FILE: deletes the specified file
- exit : exits the program
- help : shows this screen
```
Plus, you might read the manual page using `man dupfinder` command, which its output is like below.
```
DUPFINDER(1)                                                                  dupfinder man page                                                                  DUPFINDER(1)

NAME
       dupfinder - Detect and delete duplicate files.

SYNOPSIS
       dupfinder

DESCRIPTION
       All commands and options are listed below:

       ls [UNIX_ls_ARGUMENTS]:
              UNIX ls with all supported options

       cd [UNIX_cd_ARGUMENTS]:
              UNIX cd with all supported options

       use [OPTION]:  use the desired crypto hash to detect duplication
              OPTIONS => md5: use md5sum hash to detect duplication
              OPTIONS => sha1 : use sha1 hash to detect duplication
              OPTIONS => not specified : use md5sum hash to detect duplication (default)

       detect [OPTIONS] [OUTPUT] "REGEX":  detect duplicate files with desired options
              OPTIONS => -R : means in current and all sub directories (recursively)
              OPTIONS => -C : means in current directory only
              OPTIONS => not specified : works like -R
              OUTPUT => -Y : means print the output to dupfinderReport.log to current directory
              OUTPUT => -N or not specified : print the file addresses to the screen only
              REGEX => "REGEX": check the files matching the REGEX criteria REGEX => not specified : check all files

       delete ABSOLOUTE_PATH_TO_DESIRED_FILE:
              deletes the specified file

       help : shows this screen

       exit : exits the program

AUTHOR
       Hamed
```
