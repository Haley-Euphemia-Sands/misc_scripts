#!/bin/bash

mkdir -p /media/sysm/Logs/media\ script/ && touch /media/sysm/Logs/media\ script/media_to_media.log #makes sure the log dir and file exists
export log_file=/media/sysm/Logs/media\ script/media_to_media.log

## Arg 1 = input format, Arg 2 = Output format, Quality, Quality type
input_format=$1; output_format=$2; quality=$3; quality_mode=$4; 


help(){
	printf "$(date +"%Y-%m-%d %T") - Help Function Called\n" >> $log_file
	printf "" >&2
	exit 2 # Exit Code 2 = Exit after help supplied.
}


check_help(){
	if [ $1 || $2 || $3 || $4 = "-h" || "--help" ]; then
		printf "$(date +"%Y-%m-%d %T") - Calling Help Function\n" >> $log_file
		help
	else
		return 0
	fi
}

check_args(){
	if [ $1 || $2 || $3 || $4 = "" ]; then
		return 0
	else
		printf "$(date +"%Y-%m-%d %T") - Incorrect number of arguments supplied.\n" >> $log_file
		printf "Incorrect number of Arguments supplied, please see '-h' or '--help' for help.\n" >&2
		exit 1 # Exit code 1 means incorrect number of arguments supplied.
	fi
}

printf "$(date +"%Y-%m-%d %T") - Current Working Directory: $(pwd)\n" >> $log_file
printf "$(date +"%Y-%m-%d %T") - input_format = $input_format, output_format = $output_format, quality = $quality, quality_mode = $quality_mode\n" >> $log_file

check_help $input_format $output_format $quality $quality_mode
if [ $? != 0 ]; then
	printf "$(date +"%Y-%m-%d %T") - checking help failed.\n" >> $log_file
	exit 3 # Exit Code 3 - Check for help call has failed.
fi
check_args $input_format $output_format $quality $quality_mode
if [ $? != 0 ]; then
        printf "$(date +"%Y-%m-%d %T") - checking arguments failed.\n" >> $log_file
        exit 3 # Exit Code 4 - Check argument call has failed.
fi

