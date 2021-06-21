#! /bin/bash

function init {
	

	for elem in $INTERFACES; do
		INTERCOUNT=$(( $INTERCOUNT + 1 ))
		lastRead["$elem"]=$(readBytes $elem) || true
	done
}
function checkFile {
	if [[ $FILE == "" ]]; then
		return
	fi
	if ! [[ -f $FILE  ]]; then
		touch $FILE
		echo "Created new file: $FILE"
	fi
}

function list {
	
	tmp=`ifconfig | grep ": "`
	if [[ $tmp != $READ ]] ; then
	
		INTERFACES=`ifconfig | grep ": " | sed -n '/[a-z][a-z][a-z]*[0-9]\w*[0-9]\w*/p' | sed 's/ .*//'`
		if [[ $INTERFACES == "" ]]; then
			INTERFACES=`ifconfig | grep ": " | sed -n '/[a-z][a-z][a-z]*[0-9][0-9]*/p' | sed 's/ .*//'`
		fi
		INTERCOUNT=$(( 0 ))
		for elem in $INTERFACES; do
			INTERCOUNT=$(( $INTERCOUNT + 1 ))
			lastRead["$elem"]=$(readBytes $elem) || true
		done
	fi
	READ="$tmp"
}


function edit {
	tmp=$1
	if ! [[ "$tmp" =~ ^[0-9]+$ ]]; then
		tmp=0
	fi

	if [[ "$tmp" -ge 1073741824 ]]; then
	 	tmp="$((tmp/1073741824)) GB"
	elif [[ $tmp -ge 1048576 ]]; then
	 	tmp="$((tmp/1048576)) MB"
	elif [[ $tmp -ge 1024 ]]; then
		tmp="$((tmp/1024)) KB"
	elif [[ $tmp -eq 0 ]]; then
		tmp="0  B   "
	else
		tmp="$((tmp/10)) B"
	fi
	echo $tmp
}


function readBytes {
	read=`cat /proc/net/dev | grep $1`
	tmp=0
	for word in $read; do
		tmp=$(( $tmp +1 ))
		if [[ $tmp == 2 ]]; then
			echo $word
			break
		fi
	done
}
function HELP() {
	echo "./monitor"
	echo "	-f 		file to save output"
	echo "	-s 		show output"
	echo "	-d 		delay"
	echo "	-h 		show help"
}

READ="a"
INTERFACES=""
INTERCOUNT=0
INTERSWITCH=0
DELAY=1
#FILE="/home/randomguy90/.config/i3/downloadSpeed"
FILE=""
SHOW=0
HIDEINF=$INTERFACES

declare -A read
declare -A lastRead
declare -A zero

case  $@ in
	*"-s"*)SHOW=1;;
esac

while getopts f:d:h:s flag; do
        case ${flag} in
        f)FILE="${OPTARG}";;
	    d) DELAY=${OPTARG};;
	    h)HELP && exit 0;;
        s)SHOW=1;;
        esac
    done

checkFile
init

while [[ 1 ]]; do
	list

	for elem in $INTERFACES; do

		read["$elem"]=$(readBytes $elem)
		count=$(expr ${read["$elem"]} - ${lastRead["$elem"]})

		xD+="$elem $(edit $count)  "

		lastRead["$elem"]=${read["$elem"]}
		

		INTERSWITCH=$(( $INTERSWITCH +  1 ))
		if [[ $INTERSWITCH -ge $INTERCOUNT ]]; then
			INTERSWITCH=0
			if [[ $SHOW == "1" ]]; then
				printf "\n" 
				echo $xD
			fi
			if [[ $FILE != "" ]]; then
				echo $xD > $FILE
			fi
			xD=""
		fi
		xD+=" | "
		zero["$elem"]=$xD
		read["$elem"]=0

	done
sleep $DELAY


done 




