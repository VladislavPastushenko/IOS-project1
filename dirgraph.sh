# Created by Vladislav Pastushenko "xpastu04"
# 24.03.2020

POSIXLY_CORRECT=yes

# Flags catcher
while test $# -gt 0; do
    case "$1" in

        # Ignore flag. Variable $FILE_ERE will contain regular expression with
        -i) 
            shift
            if test $# -gt 0; then
                    FILE_ERE=$1
                    shift
            
            # Check that there is parameter with regular expression after flag
            else
                echo "no files after -i"
                exit 1;
            fi
        ;;
        
        # Normalization flag
        -n)
            N_IS_TRUE=true;
            shift
        ;;

        *)
        # Get parameter with way to root directory
            DIR=$1
            
            # If directory name isn't correct
            if [[ ! -d $DIR ]]; then
                echo "cannot find $DIR"
                exit 1
            fi
            break
        ;;
    esac
done


DIR=${DIR:-$(pwd)}


WAY_LENGHT=${#DIR}
WAY_LENGHT=$(($WAY_LENGHT + 2))


if [[ -z $FILE_ERE ]]; then
    FILES=$(find $DIR -type f | wc -l)
    DIRS=$(find $DIR -type d | wc -l)
else 
   if [[ -d $FILE_ERE ]]; then
        if grep -q "^$FILE_ERE" <<< "$DIR"; then
            echo "ERROR: way after -i is root directory"
            exit 1;
        fi
    fi

    FILES=$(find $DIR -type f |cut -b $WAY_LENGHT- | grep -Ev "$FILE_ERE" -c)
    DIRS=$(find $DIR -type d |cut -b $WAY_LENGHT- | grep -Ev "$FILE_ERE" -c)
fi

echo "Root directory: $DIR"
echo "Directories: $DIRS"
echo "All files: $FILES"


# $weights is array with params for "find -size" 
weights[0]="-100c"
weights[1]="-1024c -size +99c"
weights[2]="-10240c -size +1023c"
weights[3]="-102400c -size +10239c"
weights[4]="-1024k -size +102399c"
weights[5]="-10240k -size +1023k"
weights[6]="-102400k -size +10239k"
weights[7]="-1G -size +102399k"
weights[8]="+1G"

# $FSHIST is array with FSHISTs which will be printed 
FSHIST[0]="<100 B  :"
FSHIST[1]="<1 KiB  :"
FSHIST[2]="<10 KiB :"
FSHIST[3]="<100 KiB:"
FSHIST[4]="<1 MiB  :"
FSHIST[5]="<10 MiB :"
FSHIST[6]="<100 MiB:"
FSHIST[7]="<1 GiB  :"
FSHIST[8]=">=1 GiB :"


echo "File size histogram:"
for ((i = 0 ; i < 9 ; i++)); do

    if [[ -z $FILE_ERE ]]; then
        counter=$(find $DIR -size ${weights[$i]} -type f | wc -l)
    else
        counter=$(find $DIR -size ${weights[$i]} -type f | cut -b $WAY_LENGHT- | grep -Ev "$FILE_ERE" -c)
    fi

    # If flag "-n" with parameter were set
    if [[ -n $N_IS_TRUE ]]; then
        
        # If there is terminal in stdout else not
        if test -t
        then
            width=$(($(tput cols) - 13))
            if [ "$counter" -gt "$width" ]; then
                counter="$width"
            fi
        else
            if [ "$counter" -gt 79 ]; then
                counter=79
            fi
        fi
    fi
    
    printf "  ${FSHIST[$i]} " 
    for ((j = 0 ; j < counter ; j++)); do
        printf "#"
    done
    printf "\n"
done