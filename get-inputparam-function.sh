#!/bin/bash

function get-inputparam () {
		local par="$1" ret='' val=''
		local m=0 dup='' i
		[[ -z "$par" ]] && return
		for i in "${param[@]}"; do
			val='' # default param's value
			[[ "${i#*=}" != "$i" ]] && val="${i#*=}" # split  name/val
			i="${i%=*}"; i="${i//|/ }";
			for s in $i; do	# test names (synonyms)
				if [[ "$s" == "$par" ]]; then # exact matching; last wins
					if [[ -n $val ]]; then
						ret="${i%% *} =#= $val"; else ret="${i%% *}"; 
					fi
					break 2 # exit func
				elif [[ "$s" == $par* ]]; then # expansion
					dup+=" '$s'"
					[[ $m -eq 1 ]] && # param name intersection/duplicate found
						{ echo "ERROR: Ambitious parameter '$par' => ${dup:1}."; return; }
					if [[ -n $val ]]; then
						ret="${i%% *} =#= $val"; else ret="${i%% *}"; 
					fi
					m=1; 
				fi
			done
		done
		echo $ret
	} # END scriptblock
	local pargs=() defarg=() inputparam='' inputp=()
	local prefix='' param ignore=1 mandatory=() m
	[[ "$1" == '-d' ]] && { ignore=0; shift; }
	param=$1[@]; param=("${!param}"); shift
	if [[ "$1" == '-' ]]; then 
		shift 
	elif [[ "${1:0:1}" != '-' ]]; then 
		prefix=$1; shift
	fi # END definitions

	[[ "$param" == '' ]] && { echo "ERROR: Parameter definitions not found."; exit 1; }
	for i in "${param[@]}"; do # initialize output vars
#		m=0; [[ "${i:0:1}" == '+' ]] && { i=${i:1}; m=1; }
		defarg=() # default param's value
		[[ "${i#*=}" != "$i" ]] && defarg="${i#*=}" # split name/val
		i="${i%=*}"; i=$prefix"${i%%|*}" # extract first synonym
#		[[ $m -eq 1 ]] && mandatory+=("$i")
		if [[ "$defarg" ]]; then
			[[ "${defarg:0:1}" == '(' && "${defarg:(-1)}" == ')' ]] &&
				defarg=(${defarg:1:${#defarg}-2})
			eval $i='("${defarg[@]}")'
		else
			eval $i=''
		fi
	done # END init
#	[[ "$mandatory" ]] && param=("${param[@]#+}")
	
	while [ "$#" != 0 ]; do
		if [[ "${1:0:1}" == "-" ]]; then 
			inputparam=$(__find-param "${1:1}")
			[[ "$inputparam" == 'ERROR:'* ]] && { echo -e "$inputparam\n"; exit 1; }
			[[ -z "$inputparam" ]] && { echo -e "WARNING: Unknown parameter '${1}'\n"; exit 1; }
			inputp+=("${inputparam%% *}")
			shift
		fi
		pargs=() # collect arguments of a current param
		while [ "${1:0:1}" != "-" ] && [ "$#" != 0 ]; do
			pargs+=("$1")
			shift
		done
		cpar="$prefix${inputparam% =#=*}" # compose output varname of a param
		defarg=()
		[[ "${inputparam#* =#= }" != "$inputparam" ]] && defarg=("${inputparam#* =#= }")
		if [[ "${pargs[@]}" ]]; then
			eval $cpar='("${pargs[@]}")'
		elif [[ -n "$defarg" ]]; then # check for def argument
			# array parser 
			[[ "${defarg:0:1}" == '(' && "${defarg:(-1)}" == ')' ]] &&
				defarg=(${defarg:1:${#defarg}-2})
			eval $cpar='("${defarg[@]}")'
		else
			eval $cpar=true  # param without its argument: tag of calling
		fi
		inputparam=''
	done # END parsing
	
#	if [[ "$mandatory" ]]; then # check for mandatory parameters
#		m=$( comm -3 -2 -i <(printf '%s\n' "${mandatory[@]}" | sort -u) <(printf '%s\n' "${inputp[@]}" | sort -u) )
#		echo "$m"
#		if [[ "$m" ]]; then
#			m=${m/$'\n'/ }; mandatory=()
#			for i in $m; do
#				[[ "${!i}" == '' ]] && mandatory+=("$i")
#			done
#			[[ "$mandatory" ]] && 
#			{ echo "ERROR: Missing mandatory parameter(s) '${mandatory[@]}'."; exit 1; }
#		fi
#	fi
	
	[[ $ignore -eq 0 ]] && return # check for input duplicates
	local dup=$( comm -1 -3 -i <(printf '%s\n' "${inputp[@]}" | sort -u) <(printf '%s\n' "${inputp[@]}" | sort) )
	if [[ "$dup" ]]; then 
		dup=$(echo "$dup" | sort -u); 
		echo -e "WARNING: Duplicate input parameter(s) '${dup/$'\n'/, }'.\n"
		exit 1
	fi
} # END input processor


echo -e "==== Demo ====\n"
params=( # parameter definition block
    name=$(echo $USER)
    'computer|host|comp'=$(hostname)
    company
    class
    lang='(en de pl)'
    log=myscript.txt
    'help|?'
    run
)
px='-'
get-inputparam -d params $px "${@}"

[[ $px == '-' ]] && px=''
echo -e "> $@\n"
demo_fmt1='%-18s %-30s %-3s %7s %s\n'
printf "$demo_fmt1" 'PARAMETER' 'ARGUMENTS' 'DEF' 'ARG CNT' 'OUTPUT VAR'
printf "$demo_fmt1" '---------' '---------' '---' '-------' '----------'
for i in "${params[@]}"; do
    demo_def=' '; [[ "${i#*=}" != "$i" ]] && demo_def="${i#*=}"; 
    [[ "$demo_def" != ' ' ]] && demo_def='yes'
    i="${i%=*}"; i="${i%%|*}"; 
    demo_name=$px$i[@]; demo_arr=("${!demo_name}"); demo_s="${demo_arr[@]}"
    demo_d=${#demo_arr[@]}; [[ $demo_s == '' ]] && demo_d=' '
    [[ $demo_d -gt 1 ]] && demo_s="($demo_s)"
    printf "$demo_fmt1" "$i" "$demo_s" "$demo_def" "$demo_d" "$px$i"
done
echo
