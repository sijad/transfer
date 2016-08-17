function transfer -d "Upload to transfer.sh" -a file name
    set -l tmp (mktemp -t transferXXX)

    if test -z $name
        if not isatty
            set name $file
        else if test -r $file
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

    if test -n $file
        if not test -r $file
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
