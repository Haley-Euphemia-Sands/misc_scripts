#!/bin/bash

mkdir -p /media/sysm/Logs/media\ script/ && touch /media/sysm/Logs/media\ script/media_to_media.log #makes sure the log dir and file exists

help(){
	printf "$(date +"%Y-%m-%d %T") - Help Function Called\n" >> /media/sysm/Logs/media\ script/media_to_media.log
	printf "" >&2
	exit 2 # Exit Code 2 = Exit after help supplied.
}

ext_empty(){
    printf "$(date +"%Y-%m-%d %T") - No files exist with extensions associated with jpeg.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
    exit 7 # Exit Code 7 - Can't have Empty Extensions.
}

check_help(){
    checker=false
    case $1 in
        "-h")
             checker=true
             ;;
         "--help")
             checker=true
             ;;
    esac
    case $2 in
        "-h")
             checker=true
             ;;
         "--help")
             checker=true
             ;;
    esac    
    case $3 in
        "-h")
             checker=true
             ;;
         "--help")
             checker=true
             ;;
    esac  
    case $4 in
        "-h")
             checker=true
             ;;
         "--help")
             checker=true
             ;;
    esac
    case $checker in
        "true")
        		printf "$(date +"%Y-%m-%d %T") - Calling Help Function\n" >> /media/sysm/Logs/media\ script/media_to_media.log
		    help
		    ;;
		"false")
	        return 0
	        ;;
	esac
	#if [ "$1" || "$2" || "$3" || "$4" == "-h" ] || [ $1 || $2 || $3 || $4 == "--help" ]; then

	#else
		#return 0
	#fi
}

check_args(){
	if [ $1 != "" ] || [ $2 != "" ] || [ $3 != "" ]|| [ $4 != "" ]; then
		return 0
	else
		printf "$(date +"%Y-%m-%d %T") - Incorrect number of arguments supplied.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
		printf "Incorrect number of Arguments supplied, please see '-h' or '--help' for help.\n" >&2
		exit 1 # Exit code 1 means incorrect number of arguments supplied.
	fi
}

convert_ffmpeg(){
    input_extesions=$1; video_codec=$2; quality_flag=$3; audio_codec=$4; output_extension=$5;
    for input_files in $input_extesions; do
        ffmpeg -i "$input_files" $video_codec $quality_flag -preset slow -an -pass 1 -f null /dev/null && \
            ffmpeg -i "$input_files" $video_codec $quality_flag -preset slow $audio_codec -pass 2 "$input_files$output_extension"
        ffmpeg_exit_status=$?
        if [ $ffmpeg_exit_status != 0 ]; then
            printf "$(date +"%Y-%m-%d %T") - ffmpeg failed with exit code $ffmpeg_exit_status\n" > /media/sysm/Logs/media\ script/media_to_media.log
            exit 6 # Exit Code 6 - ffmpeg failed.
        else
            cat /dev/null > ffmpeg2pass*; # truncates the two pass log ready for another loop
        fi
    done
    rm ffmpeg2pass* # removes the two pass log to clean up
}
## Arg 1 = input format, Arg 2 = Output format, Quality, Quality type
input_format=$1; output_format=$2; quality=$3; quality_mode=$4; 
printf "$(date +"%Y-%m-%d %T") - Current Working Directory: $(pwd)\n" >> /media/sysm/Logs/media\ script/media_to_media.log
printf "$(date +"%Y-%m-%d %T") - input_format = $input_format, output_format = $output_format, quality = $quality, quality_mode = $quality_mode\n" >> /media/sysm/Logs/media\ script/media_to_media.log

check_help $input_format $output_format $quality $quality_mode
if [ $? != 0 ]; then
	printf "$(date +"%Y-%m-%d %T") - checking help failed.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
	exit 3 # Exit Code 3 - Check for help call has failed.
fi
check_args "$input_format" "$output_format" "$quality" "$quality_mode"
if [ $? != 0 ]; then
        printf "$(date +"%Y-%m-%d %T") - checking arguments failed.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
        exit 4 # Exit Code 4 - Check argument call has failed.
fi
# check and errors out if input format will be the same as output as not handle has been implemented yet but is planned.
if [ $input_format = $output_format ]; then
	printf  "$(date +"%Y-%m-%d %T") - Conversion to same format is not supported yet.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
	exit 5
fi
case $output_format in
    "avif")
        if [ $quality != "archive-preset" ]; then
            case $quality_mode in
                "abr")
                    quality_flag="-b:v $quality"
                    video_codec="-c:v av1_nvenc"
                    audio_codec="-an"
                    output_extension=".av1_$quality-br.avif"
                    ;;
                "crf")
                    printf "$(date +"%Y-%m-%d %T") - nvenc encoder will not be used, crf is not supported by it, fallback on libaom-av1 encoder.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
                    quality_flag="-crf $quality"
                    video_codec="-c:v libaom-av1"
                    audio_codec="-an"
                    output_extension=".av1-$quality-crf.avif"
                    ;;
                "qp")
                    quality_flag="-qp $quality"
                    video_codec="-c:v av1_nvenc"
                    audio_codec="-an"
                    output_extension=".av1_$quality-qp.avif"
                    ;;
            esac
        else
            printf "nop" > /dev/null #put in preset
            exit 0
        fi
        ;;    
    "mkv")
        if [ $quality != "archive-preset" ]; then
            case $quality_mode in
                "abr")
                    quality_flag="-b:v $quality"
                    video_codec="-c:v av1_nvenc"
                    audio_codec="-c:a libopus -b:a 160k"
                    output_extension=".av1_$quality-br.opus-160k-abr.mkv"
                    ;;
                "crf")
                    printf "$(date +"%Y-%m-%d %T") - nvenc encoder will not be used, crf is not supported by it, fallback on libaom-av1 encoder.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
                    quality_flag="-crf $quality"
                    video_codec="-c:v libaom-av1"
                    audio_codec="-c:a libopus -b:a 160k"
                    output_extension=".av1-$quality-crf.opus-160k-abr.mkv"
                    ;;
                "qp")
                    quality_flag="-qp $quality"
                    video_codec="-c:v av1_nvenc"
                    audio_codec="-c:a libopus -b:a 160k"
                    output_extension=".av1_$quality-qp.opus-160k-abr.mkv"
                    ;;
            esac
        fi
        ;;
    "mp4")
        printf "$(date +"%Y-%m-%d %T") - AV1 is not a supported Video Codec for this Container, fallback on HEVC encoder.\n" >> /media/sysm/Logs/media\ script/media_to_media.log
        ;;
    *)
        printf "$(date +"%Y-%m-%d %T") - Invalid Output Format Supplied\n" >> /media/sysm/Logs/media\ script/media_to_media.log
        ;;
esac
     
case $input_format in
	"jpeg")
        input_extension=""
        if [ "$(ls -alh | grep .jpg)" != "" ]; then
            input_extension+="*.jpg "
        fi
        if [ "$(ls -alh | grep .jpeg)" != "" ]; then
            input_extension+="*.jpeg "
        fi
        if [ $input_extension == "" ]; then
            ext_empty
        fi
        ;;
	"png")
        input_extension=""
        if [ "$(ls -alh | grep .bmp)" != "" ]; then
             input_extension+="*.bmp "
        fi
        if [ "$(ls -alh | grep .png)" != "" ]; then 
            input_extension+="*.png "
        fi
        if [ $input_extension == "" ]; then
            ext_empty
        fi
		;;
	"mp4")
        input_extension=""
        if [ "$(ls -alh | grep .mp4)" != "" ]; then
            input_extension+="*.mp4 "
        fi
        if [ "$(ls -alh | grep .m4a)" != "" ]; then
            input_extension+="*.m4v "
        fi
        if [ $input_extension == "" ]; then
            ext_empty
        fi
		;;
	"mkv")
        input_extension=""
        if [ "$(ls -alh | grep .mkv)" != "" ]; then
            input_extension+="*.mkv "
        fi
        if [ "$(ls -alh | grep .webm)" != "" ]; then
            input_extension+="*.webm "
        fi
        if [ $input_extension == "" ]; then
            ext_empty
        fi
		;;
	"gif")
        input_extension="*.gif"
        if [ "$(ls -alh | grep .gif)" == "" ]; then 
            ext_empty
        fi
		;;
	*)
		printf "$(date +"%Y-%m-%d %T") - no valid input format supplied\n" >> /media/sysm/Logs/media\ script/media_to_media.log
		exit 5 # Exit Code 5 - No Valid Input.
		;;
esac
convert_ffmpeg $input_extension $video_codec $quality_flag $audio_codec $output_extension
exit 0
