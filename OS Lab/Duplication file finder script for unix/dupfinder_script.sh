#!/usr/bin/env bash

hash_algorithm="md5"

# this function creates a man page for this script (needs super user)
function create_man_page() {
    if [[ -f /usr/share/man/man1/dupfinder.1.gz ]]; then
        # man page already exists
        # do nothing and return
        return
    fi

    printf '." Manpage for dupfinder.
.TH DUPFINDER 1 "03 June 2016" "1.0" "dupfinder man page"
.SH NAME
dupfinder \- Detect and delete duplicate files.
.SH SYNOPSIS
dupfinder
.SH DESCRIPTION
All commands and options are listed below:
.br
.TP
\\fBls [UNIX_ls_ARGUMENTS]: \\fR
UNIX ls with all supported options
.PP
.TP
\\fBcd [UNIX_cd_ARGUMENTS]: \\fR
UNIX cd with all supported options
.PP
.TP
\\fBuse [OPTION]: \\fR use the desired crypto hash to detect duplication
.br
OPTIONS => md5: use md5sum hash to detect duplication
.br
OPTIONS => sha1 : use sha1 hash to detect duplication
.br
OPTIONS => not specified : use md5sum hash to detect duplication (default)
.PP
.TP
\\fBdetect [OPTIONS] [OUTPUT] "REGEX": \\fR detect duplicate files with desired options
.br
OPTIONS => -R : means in current and all sub directories (recursively)
.br
OPTIONS => -C : means in current directory only
.br
OPTIONS => not specified : works like -R
.br
OUTPUT => -Y : means print the output to dupfinderReport.log to current directory
.br
OUTPUT => -N or not specified : print the file addresses to the screen only
.br
REGEX => "REGEX": check the files matching the REGEX criteria
REGEX => not specified : check all files
.PP
.TP
\\fBdelete ABSOLOUTE_PATH_TO_DESIRED_FILE: \\fR
deletes the specified file
.PP
.TP
\\fBhelp : \\fR
shows this screen
.PP
.TP
\\fBexit : \\fR
exits the program
.PP
.SH AUTHOR
Hamed' > dupfinder_man

    # create a 'man' file from text file in the directory of man pages
    cp -f ./dupfinder_man /usr/share/man/man1/dupfinder.1
    gzip -f /usr/share/man/man1/dupfinder.1

    # check if gzip has made the man gz file successfully (and has returned 0 as exit value)
    if [[ $? -eq 0 ]]; then
        echo "Manual page added successfully."
        echo ""
    fi

    rm ./dupfinder_man  # remove the text file
}

# this function tries to add this script to binary file paths to make it runnable from everywhere
function add_script_to_bin() {
    if [[ -f /usr/local/bin/dupfinder ]]; then
        # the script is already copied
        # do nothing and return
        return
    fi


    cp -f $0 /usr/local/bin/dupfinder
    chmod +x /usr/local/bin/dupfinder

    echo "The script added to shell binaries successfully."
}

# this function calls 'add_script_to_bin' and 'create_man_page' if :
# at least one of the copied script file or man page file does not exists in the related directory
# and
# the script is running as super user
function install() {

    if [[ ! -f /usr/share/man/man1/dupfinder.1.gz ]] || [[ ! -f /usr/local/bin/dupfinder ]]; then
        echo ""
        echo "Installing..."
        if [[ $EUID -ne 0 ]]; then
            echo "Cannot install the script! Run it as super user (root)."
        else
            add_script_to_bin
            create_man_page
        fi
    fi
}

# this functions tries to change directory to the path entered by user
function process_cd_command() {
    cd_command=$1

    eval "${cd_command}"

    # check if cd command has changed the directory successfully (and has returned 0 as exit value)
    if [[ $? -eq 0 ]]; then
        echo "Directory changed successfully!"
        printf "Current directory: %s\n" "$(pwd)"
    else
        echo "Directory did not change."
    fi
}

# this functions tries to change crypto algorithm
function process_use_command() {

    use_command=$1

    tokens=(${use_command}) # convert the command string to an array (split by space)
    len=${#tokens[@]}   # get length of the array

    if [[ len -gt 1 ]]; then
        case ${tokens[1]} in
        "md5")
          hash_algorithm="md5"
          echo "Switched crypto algorithm to md5!"
          ;;
        "sha1")
          hash_algorithm="sha1"
          echo "Switched crypto algorithm to sha1!"
          ;;
        *)
          echo "Unknown type of crypto algorithm"
          ;;
        esac
    else
        hash_algorithm="md5"
        echo "Switched crypto algorithm to md5!"
    fi

}

# this functions tries to detect duplicate files in a slow manner
# time order : n^2*(hash order)
function process_detect_command() {
    echo -e "detection started!\n"


    recursive_detect=true   # by default, the recursive detection is enabled (disbaling with -C)
    print_to_file=false     # by default, printing the result to file is disabled (enabling with -Y)
    detect_regex=*          # by default, all of files will be checked

    detect_command=$1       # copy the argument (command string)
    tokens=(${detect_command})  # convert the command string to an array (split by space)
    len=${#tokens[@]}   # get length of the array

    # check if any option or a regex is given by user (by checking the size of tokens of command string)
    if [[ len -gt 1 ]]; then
        # check -C option
        if [[ ${detect_command} =~ [[:space:]]-C ]]; then
            # -C option found in the command
            recursive_detect=false  # so, set the recursive detection mode to false
        fi

        # check -Y option
        if [[ ${detect_command} =~ [[:space:]]-Y ]]; then
            # -Y option found in the command
            print_to_file=true  # so, set the print to file flag to true
        fi

        # check if a regex pattern is given
        if [[ ${detect_command} =~ \"*\" ]]; then
            # extract regex part of command without double quotation
            detect_regex="${detect_command#*\"}"    # remove everything before first "
            detect_regex="${detect_regex%\"}"       # remove everything after second "
        fi
    fi

    # combine 'find' command arguments based on default values and user's options
    find_arguments="."  # search path : this directory (obviously)

    if [[ ${recursive_detect} == false ]]; then
        # if -C option is given in command, max depth of search is one (only this directory)
        find_arguments+=" -maxdepth 1 "
    fi

    find_arguments+=" -type f -name '${detect_regex}'"  # (-type f : just find files not directories) (-name regex : regex pattern of search)

    # store list of founded files in an array named 'files_array'
    # how the loop works? first, "eval find ..." at the end of it will run, then the results pass to while loop
    # and in every run, it reads a new path from "eval find ..." result paths which are separated by null character (\0)
    files_array=()
    while IFS= read -d $'\0' -r file ; do
        files_array=("${files_array[@]}" "$file")   # add a new file path to array (make a new array with other elements)
    done < <(eval "find "${find_arguments}" -print0")



    echo "here are the results:"


    # nested for loops will find any two file with equal hash values
    number_of_files="${#files_array[@]}"
    for (( i = 0; i < ${number_of_files}; ++i )); do
        for (( j = ${i}+1; j < ${number_of_files}; ++j )); do

            # calculate the hash values of file 'i' and 'j' based on chosen hash algorithm
            if [[ ${hash_algorithm} == "md5" ]] ; then
                sum1=$(md5sum "${files_array[i]}")  # get md5 hash value of file 'i'
                sum1="${sum1%  *}"      # keep hash value part (first part) using separation by double space

                sum2=$(md5sum "${files_array[j]}")  # get md5 hash value of file 'j'
                sum2="${sum2%  *}"      # keep hash value part (first part) using separation by double space
            elif [[ ${hash_algorithm} == "sha1" ]]; then
                sum1=$(sha1sum "${files_array[i]}") # get sha1 hash value
                sum1="${sum1%  *}"

                sum2=$(sha1sum "${files_array[j]}") # get sha1 hash value
                sum2="${sum2%  *}"
            fi

            # check if the hash values are equal
            if [[ ${sum1} == ${sum2} ]]; then
                echo "Detected!"
                echo "${files_array[i]}"
                echo "${files_array[j]}"

                # if printing to file is enabled by option -Y, then print the result to file too
                if [[ ${print_to_file} == true ]]; then
                    echo "Detected!" >> dupfinderReport.log
                    echo "${files_array[i]}" >> dupfinderReport.log
                    echo "${files_array[j]}" >> dupfinderReport.log
                fi
            fi
        done

    done


    if [[ ${print_to_file} == true ]]; then
        echo -e "\n the detection process finished, output results are saved in dupfinderReport.log "
    else
        echo -e "\n the detection process finished!"
    fi

}

# this functions tries to detect duplicate files in a quick manner using associative array in bash
# time order : n*(hash order)
function high_performance_detect() {
    echo -e "high performance detection started!\n"


    recursive_detect=true   # by default, the recursive detection is enabled (disbaling with -C)
    print_to_file=false     # by default, printing the result to file is disabled (enabling with -Y)
    detect_regex=*          # by default, all of files will be checked

    detect_command=$1       # copy the argument (command string)
    tokens=(${detect_command})  # convert the command string to an array (split by space)
    len=${#tokens[@]}   # get length of the array

    # check if any option or a regex is given by user (by checking the size of tokens of command string)
    if [[ len -gt 1 ]]; then
        # check -C option
        if [[ ${detect_command} =~ [[:space:]]-C ]]; then
            # -C option found in the command
            recursive_detect=false  # so, set the recursive detection mode to false
        fi

        # check -Y option
        if [[ ${detect_command} =~ [[:space:]]-Y ]]; then
            # -Y option found in the command
            print_to_file=true  # so, set the print to file flag to true
        fi

        # check if a regex pattern is given
        if [[ ${detect_command} =~ \"*\" ]]; then
            # extract regex part of command without double quotation
            detect_regex="${detect_command#*\"}"    # remove everything before first "
            detect_regex="${detect_regex%\"}"       # remove everything after second "
        fi
    fi

    # combine 'find' command arguments based on default values and user's options
    find_arguments="."  # search path : this directory (obviously)

    if [[ ${recursive_detect} == false ]]; then
        # if -C option is given in command, max depth of search is one (only this directory)
        find_arguments+=" -maxdepth 1 "
    fi

    find_arguments+=" -type f -name '${detect_regex}'"  # (-type f : just find files not directories) (-name regex : regex pattern of search)



    declare -A hash_file_list   # declare an associative array that maps hash values of file(s) to a string of path(s) (each separated by ,)

    # store list of founded files in an associated array named 'hash_file_list' by hash value as index
    # if there are files with equal hash values, their paths will be concatenated as value of the hash (separated by ,)
    # how the loop works? first, "eval find ..." at the end of it will run, then the results pass to while loop
    # and in every run, it reads a new path from "eval find ..." result paths which are separated by null character (\0)
    while IFS= read -d $'\0' -r file ; do
        if [[ ${hash_algorithm} == "md5" ]] ; then
            sum=$(md5sum "${file}") # get md5 hash of the file
            sum="${sum%  *}"    # keep hash value part and trim others (split by double space in between)

        elif [[ ${hash_algorithm} == "sha1" ]]; then
            sum=$(sha1sum "${file}")    # get sha1 hash of the file
            sum="${sum%  *}"    # keep hash value part and trim others (split by double space in between)
        fi

        hash_file_list["${sum}"]+="${file},"    # associate this file path to the hash value (maybe concat to previous paths, if there is duplication)

    done < <(eval "find "${find_arguments}" -print0")



    echo "here are the results:"

    # check all hash values / paths
    # loop over all keys (hash values) of the array
    for key in "${!hash_file_list[@]}" ; do

        # first, we count the different paths related to each hash value (which paths are separated by ,)
        # actually we count the ',' character
        associated_files_number_to_hash=$(echo "${hash_file_list[$key]}" | awk -F, '{print NF-1}')

        # if there is more than one path for this hash value as key so there is duplication
        if [[ ${associated_files_number_to_hash} -gt 1 ]]; then
            echo "Detected!"
            printf "${hash_file_list[$key]//','/'\n'}"

            # if print_to_file flag is true (by -Y option in the user command), the result will be printed to file too
            if [[ ${print_to_file} == true ]]; then
                    echo "Detected!" >> dupfinderReport.log
                    printf "${hash_file_list[$key]//','/'\n'}" >> dupfinderReport.log
            fi
        fi
    done




    if [[ ${print_to_file} == true ]]; then
        echo -e "\n the detection process finished, output results are saved in dupfinderReport.log "
    else
        echo -e "\n the detection process finished!"
    fi

}

# this functions tries to delete a file using a path which is specified by user
function process_delete_command() {

    delete_command=$1


    tokens=(${delete_command})
    len="${#tokens[@]}"


    absoloute_path="${delete_command#* }"   # remove 'delete' word from string and keep just the path

    # check if any path is given or not
    if [[ len -gt 1 ]]; then
        echo "Deleting file..."

        # chekc if the path is valid path of a existing file
        if [[ -f $absoloute_path ]]; then
            rm -f "$absoloute_path"

            # check if remove command has remove the file successfully (and has returned 0 as exit value)
            if [[ $? -eq 0 ]]; then
                echo "Done!"
            else
                echo "Not successfull"
            fi
        else
            # there is no file specified with the path
            echo "There is no such file to delete"
        fi
    else
        # there is no path as argument
        # the only token in the entered command is 'delete'
        echo "Specify a file path while using delete command"
    fi
}

# this functions shows usage of this script as a help text
function show_help() {
    printf -- "- ls [UNIX_ls_ARGUMENTS]: UNIX ls with all supported options
- cd [UNIX_cd_ARGUMENTS]: UNIX cd with all supported options
- use [OPTION]: use the desired crypto hash to detect duplication
\tOPTIONS => md5: use md5sum hash to detect duplication
\tOPTIONS => sha1 : use sha1 hash to detect duplication
\tOPTIONS => not specified : use md5sum hash to detect duplication (default)
- detect [OPTIONS] [OUTPUT] "REGEX": detect duplicate files with desired options
\tOPTIONS => -R : means in current and all sub directories (recursively)
\tOPTIONS => -C : means in current directory only (current)
\tOPTIONS => if not specified : works like -R

\tOUTPUT => -Y : means print the output to dupfinderReport.log to current directory
\tOUTPUT => -N or not specified : print the file addresses to the screen only

\tREGEX => "REGEX": check the files matching the REGEX criteria
\tREGEX => not specified : check all files
- delete ABSOLOUTE_PATH_TO_DESIRED_FILE: deletes the specified file
- exit : exits the program
- help : shows this screen
"
}

# main loop of script
# reads command and try to detect type of command and processes it
function main_loop() {
    # forever loop to read and process user's commands
    while true; do

        echo -e "\nEnter your command:"
        read -e command     # read input (-e : readline - enable autocompletion)

        if [[ $? -eq 1 ]]; then
            # if the user pressed ^D (Ctrl+D) to terminate the last run value ($?) is 1
            break
        elif [[ "${command}" =~ ^ls ]]; then
            # ls command
            eval "${command}"
        elif [[ "${command}" =~ ^cd[[:space:]] ]]; then
            # cd command
            process_cd_command "${command}"
        elif [[ "${command}" =~ ^use ]]; then
            # use command
            process_use_command "${command}"
        elif [[ "${command}" =~ ^detect_perf ]]; then
            # high performance detect command
            high_performance_detect "${command}"
        elif [[ "${command}" =~ ^detect ]]; then
            # detect command
            process_detect_command "${command}"
        elif [[ "${command}" =~ ^delete[[:space:]] ]]; then
            # delete command
            process_delete_command "${command}"
        elif [[ "${command}" =~ ^help ]]; then
            # help command
            show_help
        elif [[ "${command}" =~ ^exit ]]; then
            # exit command
            echo "Bye!"
            break
        else
            # non of above cases
            echo "Unknown command"
        fi
    done
}



# print welcome message
echo -e "Welcome to dupfinder!"


#first : call the install function
install


echo "type help to get list of commands"

#second : run the main loop of this script
main_loop

