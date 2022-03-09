#! /bin/bash

this=`basename $0`

usage () {
    echo "Usage: $this [-i characters_to_include] [-x characters_to_exclude] [-f dictionary_file] [-d] pattern"
}

help () {
    usage
    echo "  pattern:       Placed characters (green). Use '.' for unknown characters"
    echo "  -i characters: Unplaced characters that appear in the solution (yellow)"
    echo "  -x characters: Characters that must not appear in the solution"
    echo "  -f file:       Dictionary file (default: /usr/share/dict/words)"
    echo "  -d:            Debug mode"
}

split_string () {
    i=$1
    while [ "$i" != "" ] ; do
        include+=(${i:0:1})
        i=$(echo $i | sed -e 's/^.//')
    done
    
}

run_search () {
    tmpfile_in=$(mktemp $this-in.XXX)
    tmpfile_out=$(mktemp $this-out.XXX)

    if [ $DEBUG -eq 1 ] ; then
        echo "run_search(): grep $pattern $dictfile"
    fi
    grep $pattern $dictfile | grep -v "'"> $tmpfile_out
    if [ $DEBUG -eq 1 ] ; then 
        echo "run_search(): results:"
        cat $tmpfile_out
    fi
    
    if [ ${#include[@]} -ne 0 ] ; then
        if [ $DEBUG -eq 1 ] ; then
            echo "run_search(): searching for unplaced letters ($include)"
        fi
        for i in "${include[@]}" ; do
            if [ $DEBUG -eq 1 ] ; then 
                echo "run_search(): searching for $i"
            fi
            mv $tmpfile_out $tmpfile_in
            grep $i $tmpfile_in > $tmpfile_out
        done
        if [ $DEBUG -eq 1 ] ; then 
            echo "run_search(): include results:"
            cat $tmpfile_out
        fi
    fi

    if [ "$exclude" != "" ] ; then
        if [ $DEBUG -eq 1 ] ; then
            echo "run_search(): searching for letters to exclude ($exclude)"
        fi
        mv $tmpfile_out $tmpfile_in
        grep -v $exclude $tmpfile_in > $tmpfile_out
        if [ $DEBUG -eq 1 ] ; then 
            echo "run_search(): exclude results:"
            cat $tmpfile_out
        fi
    fi

    cat $tmpfile_out
    rm -f $tmpfile_in $tmpfile_out
}

declare include
exclude=""
dictfile=/usr/share/dict/words
pattern="^.....$"
DEBUG=0

PARAMS=""
while (( "$#" )); do
    case "$1" in
        -d|--debug)
            DEBUG=1
            shift
            ;;
        -h|--help)
            help
            exit 0
            shift
            ;;
        -i|--include)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                split_string $2
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                exit 1
            fi
            ;;
        -x|--exclude)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                exclude="[$2]"
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                exit 1
            fi
            ;;
        -f|--dict)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                dictfile=$2
                shift 2
            else
                echo "Error: Argument for $1 is missing" >&2
                exit 1
            fi
            ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"
PARAMS=($PARAMS)
if [ "${PARAMS[0]}" != "" ] ; then
    pattern="^${PARAMS[0]}\$"
fi

if [ $DEBUG -eq 1 ] ; then
    echo pattern:  $pattern
    echo dictfile: $dictfile
    echo exclude:  $exclude
    echo include:  ${include}
fi

run_search
