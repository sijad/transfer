function transfer -d "Upload to transfer.sh" -a file name

    getopts $argv | while read -l 1 2
        switch "$1"
            case _
                continue

            case h help
                echo "Usage: transfer [FILE] [NAME]"
                echo
                echo "Examples:"
                echo "      transfer my-file.txt"
                echo "      transfer my-file.txt my-file-new-name.txt"
                echo "      echo my message text | transfer my-message.txt"
                echo "      cat my-file.txt | transfer my-file-new-name.txt"
                return

            case \*
                printf "transfer: '%s' is not a valid option\n" $1 >& 2
                transfer --help >& 2
                return 1
        end
    end

    set -l tmp (mktemp -t transferXXX)

    if test -z $name
        if not isatty
            set name $file
        else if test -n "$file"
            set name (basename $file)
        end
    end

    if test -z $name
        set name (random)
    end

    if not isatty
        set file ""
    end

    set name (echo $name | sed -e 's/[^a-zA-Z0-9._-]/-/g')
    set name (echo $name | sed -e 's/-\{1,\}/-/g')

    if test -n "$file"
        if not test -r "$file"
            echo "transfer: can not read the file." > /dev/stderr
            return 1
        end
        curl --progress-bar --upload-file $file https://transfer.sh/$name >> $tmp
    else
        curl --progress-bar --upload-file - https://transfer.sh/$name >> $tmp
    end

    cat $tmp
    rm -f $tmp
end
