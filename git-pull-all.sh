#!/bin/bash
working_directory=$1;
case $? in
	"0")
		printf "$(date +"%Y-%m-%d %T") - setting variable \$working_directory succesful. working_directory=$working_directory \n" >> /media/sysm/Logs/git-pull-all.log
		;;
	*)
		printf "$(date +"%Y-%m-%d %T") - setting variable \$working_directory failed \n" >> /media/sysm/Logs/git-pull-all.log 
		exit 1
	;;
esac
cd "$working_directory" 
case $? in
	"0")
		printf "$(date +"%Y-%m-%d %T") - working directory set to $(pwd) \n" >> /media/sysm/Logs/git-pull-all.log
		;;
	*)
		printf "$(date +"%Y-%m-%d %T") - changing working directory failed \n" >> /media/sysm/Logs/git-pull-all.log
		exit 1;
		;;
esac

snapshot_description="$(date +"%Y-%m-%d %T") - Snapshot before Pulling all git repositories cloned to reference directory"
snapper -c Code create -c number -d "$snapshot_description"

case $? in
	"0")
		printf "$(date +"%Y-%m-%d %T") - Snapper created a snapshot successfully. With Description: '$snapshot_description' \n" >> /media/sysm/Logs/git-pull-all.log
		for m in *; do 
			cd "$m" && 
				for f in *; do 
					cd "$f" && 
					git pull 2>&1 | tee -a /media/sysm/Logs/git.log || printf "$(date +"%Y-%m-%d %T") - issue with repo $f \n" >> /media/sysm/Logs/git-pull-all.log;
					cd ..; 
				done; 
				cd ..; 
			done
		;;
	*)
		printf "$(date +"%Y-%m-%d %T") - snapshot failed. exiting to avoid the inability to role back filesystem state. \n" >> /media/sysm/Logs/git-pull-all.log
		exit 2;
		;;
esac
