#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Command checks
commandchecks(){
command -v nmap >/dev/null 2>&1 || { echo -e "${RED}nmap seems to be missing\r\nAborting.${NC}" >&2; exit 1; }
command -v nikto >/dev/null 2>&1 || { echo -e "${RED}nikto seems to be missing${NC}\r\n${RED}Aborting.${NC}" >&2; exit 1; }
command -v tools/hoppy/hoppy >/dev/null 2>&1 || { echo -e "${RED}hoppy did not download correctly. Please remove the tools/hoppy directory and re-run the setup script.${NC}" >&2; exit 1; }
command -v tools/testssl.sh/testssl.sh >/dev/null 2>&1 || { echo -e "${RED}testssl.sh did not download correctly. Please remove the tools/testssl.sh directory and re-run the setup script.${NC}" >&2; exit 1; }
command -v bash -c tools/IIS-ShortName-Scanner/multi_targets.sh >/dev/null 2>&1 || { echo -e "${RED}IIS-ShortName-Scanner did not download correctly. Please remove the tools/IIS-ShortName-Scanner directory and re-run the setup script.";}
command -v tools/EyeWitness/EyeWitness.py >/dev/null 2>&1 || { echo -e "${RED}Eyewitness did not download correctly. Please remove the tools/EyeWitness directory and re-run the setup script.${NC}";}
command -v dirb >/dev/null 2>&1 || { echo -e "${RED}dirb seems to be missing${NC}";}
}
# Help and Usage
usage(){
		echo -e "${GREEN}[*] Web Application Recon Tasks${NC}"
		echo
		echo -e "[*] Usage: $0 [Options]"
		echo -e "	${YELLOW}[+] Only options f and p require arguments"
		echo -e "	[+] nmap will run by default"
		echo -e "	[+] -a [run all tools against site]"
		echo -e "	[+] -p [http or https. Default is http]"
		echo -e "	[+] -f [file containg sites and IPs to test on individual lines]"
		echo -e "	[+] -d [run dirb with big.txt wordlisti against site]"
		echo -e "	[+] -n [run nikto against site]"
		echo -e "	[+] -y [run hoppy against site]"
		echo -e "	[+] -t [run testssl against site - will be prompted for ports to test against. Default is 443]"
		echo -e "	[+] -i [run IIS ShortName Scanner against site]"
		echo -e "	[+] -e [run EyeWitness against site]"
		echo -e "	[+] -h [Display help]${NC}"
		echo
		echo -e "${GREEN}[*] Examples${NC}"
		echo -e "	${YELLOW}[+] Run all tools against site: $0 -p https -f sites -a"
		echo -e "	[+] Run nikto and dirb against site: $0 -p https -f sites -n -d"
		echo -e "	[+] Run testssl and dirb and hoppy against site: $0 -p https -f sites -t -d -y${NC}"
	exit 0
}

commandchecks

# Set options defaults
ssl="http"
dirb=false
nmap=true
nikto=false
hoppy=false
testssl=false
IISsns=false
eyewitness=false

while getopts 'ap:df:nytieh' option; do 
	case "$option" in
		a)
			echo -e "${GREEN}[*] Running all tools${NC}"
			ssl="https"
			dirb=true
			nmap=true
			nikto=true
			hoppy=true
			testssl=true
			IISsns=true
			eyewitness=true
			;;
		p)
			ssl="$OPTARG"
			echo -e "${GREEN}[*] Protocol set to $OPTARG${NC}"
			;;
		d)	
			dirb=true
			echo -e "${GREEN}[*] dirb will be run${NC}"
			;;
		f)
			file=$OPTARG
			echo -e "${GREEN}[*] File set to $OPTARG${NC}"
			;;
		n)
			nikto=true
			echo -e "${GREEN}[*] nikto will be run${NC}"
			;;	
		y)
			hoppy=true
			echo -e "${GREEN}[*] hoppy scans will be run${NC}"
			;;
		t)
			testssl=true
			echo -e "${GREEN}[*] testssl scans will be run"
			if [ $ssl = "http" ];then
				echo -e "${YELLOW}[*] Switching protocol to https${NC}"
			ssl="https"
			fi
			;;
		i)
			IISsns=true
			echo -e "${GREEN}[*] IIS ShortName Scanner will be run${NC}"
			;;
		e)
			eyewitness=true
			echo -e "${GREEN}[*] EyeWitness will be run${NC}"
			;;
		h)
			echo -e "${GREEN}[*] Displaying help${NC}"
			usage
			exit 0
			;;
		\?)
			usage
			exit 1
			;;	
		esac
done
			
# Error checking for arguments
if [ $# = 0 ];then
	usage
	exit 0
fi

if [ "$ssl" != "http" ] && [ "$ssl" != "https" ]; then
	echo -e "${RED}[-] -p argument was not http or https${NC}"
	echo
	usage
fi

if [ ! -f $file ]; then
	echo -e "${RED}[-] File argument was not file${NC}"
	echo
	usage
fi      


# Get ports for testssl
if [ $ssl == "https" ]; then
	port=443
	echo -e "${YELLOW}[*] Which ports are running ssl other then 443."
	read -p "	[>]Enter ports with spaces between each one (Leave blank for none):" ports
	echo
	portlist="$port $ports"
	echo -e "${GREEN}[+] testssl will scan $(echo $portlist|tr " " "\n"|sort|tr "\n" " ")"
	echo -e "${NC}"
	sslport="$port $ports"
fi

# Start scans
echo
echo -e "${GREEN}[*] Starting scans at "`date`${NC}
echo

if [ ! -d results ];then
	mkdir results
fi
cp $file results
cd results

# Nmap
if [ $nmap = true ] ;  then
	echo -e "${GREEN}[*] Launching nmap scan"
	if [ ! -d nmap ];then 
		mkdir nmap
	fi
    	echo -e "	${YELLOW}[*] Running nmap"
	nmap -Pn -A -oA nmap/tcpscan -iL $file > /dev/null 2>&1
else
	echo
       	echo -e "${RED}[*] Skipping nmap${NC}"
	
fi

# hoppy
if [ $hoppy = true ]; then
	echo -e "${GREEN}[*] Launching hoppy Scan"
	if [ ! -d hoppy ]; then
		mkdir hoppy
	fi

	for site in `cat $file`
	do
	    echo -e "	${YELLOW}[*] Hoppy scanning $ssl://$site"
	    ../tools/hoppy/hoppy -h "$ssl://$site" -E -S"hoppy/$site-$ssl" > /dev/null 2>&1
	done
else
	echo
       	echo -e "${RED}[*] Skipping hoppy${NC}"
	echo	
fi

# Nikto
if [ $nikto = true ]; then
	echo -e "${GREEN}[*] Launching nikto Scan"
	if [ ! -d nikto ]; then
		mkdir nikto
	fi

	for site in `cat $file`
	do
	    echo -e "	${YELLOW}[*] Nikto scanning $ssl://$site"
	    nikto -h "$ssl://$site" -o "nikto/$ssl-$site.txt" -F txt > /dev/null 2>&1
	done
else
	echo
       	echo -e "${RED}[*] Skipping nikto${NC}"
	echo
fi

# testssl
if [ $testssl = true ]; then
	if [ $ssl == "https" ]; then
		echo -e "${GREEN}[*] Launching testssl Scan"
		if [ ! -d testssl ];then
			mkdir testssl
		fi
		for p in $sslport
		do
			for site in `cat $file`
			do
				echo -e "	${YELLOW}[*] Running full testssl.sh $site:$p"
				# testssl has a --log param but it outputs to the screen which I don't really want
				../tools/testssl.sh/testssl.sh "$site:$port" > "testssl/testssl-$site:$port"
			done
		done
	fi
else
	echo
       	echo -e "${RED}[*] Skipping testssl${NC}"
	echo
fi

# EyeWitness
if [ $eyewitness = true ]; then
	echo -e "${GREEN}[*] Launching EyeWitness"
	if [ ! -d EyeWitness ]; then
		mkdir EyeWitness
	fi
			echo -e "	${YELLOW}[*] Running EyeWitness"
	../tools/EyeWitness/EyeWitness.py -x nmap/tcpscan.xml --all-protocols --no-prompt -d EyeWitness >/dev/null 2>&1
else
       echo	
       echo -e "${RED}[*] Skipping EyeWitness${NC}"
       echo
fi

#IIS Short name scanner
if [ $IISsns = true ]; then
	echo -e "${GREEN}[*] Launching IIS Short Name Scanner"
	if [ ! -d IIS_ShortName_Scanner ]; then
		mkdir IIS_ShortName_Scanner
	fi

	for site in `cat $file`
		do
			echo -e "	${YELLOW}[*] Shortname scanning $ssl://$site"
			java -jar ../tools/IIS-ShortName-Scanner/iis_shortname_scanner.jar 0 20 "$ssl://$site" ../tools/IIS-ShortName-Scanner/config.xml > "IIS_ShortName_Scanner/iis_shortname_$site-$ssl"
		done
else
	echo
       	echo -e "${RED}[*] Skipping IIS ShortName Scanner${NC}"
	echo
fi

# Directory Brute forcing	
if [ $dirb = true ]; then
	echo -e "${GREEN}[*] Beginning directory brute force"
	echo -e "	${YELLOW}[*] Using the dirb big.txt wordlist"
	if [ ! -d dirb ];then
		mkdir dirb
	fi
	for site in `cat $file`
	do
		dirb $ssl://$site /usr/share/wordlists/dirb/big.txt -r -o dirb/dirb_$site.txt > /dev/null 2>&1
	done
else
	echo 
	echo -e "${RED}[*] Skipping dirb${NC}"
	echo
fi

rm $file
echo -e "${GREEN}[*] Tests completed at `date`${NC}"

