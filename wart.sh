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
		echo -e "${GREEN}[*] Web Application Recon Tasks"
	echo
		echo -e "[*] Usage: $0 [http or https] [file with things to scan] [dir brute force 1 or 0]"
		echo -e "	${YELLOW}[+] http or https - protocol for some of the scans"
		echo -e "	[+] file - file containing sites and IPs to scan on individual lines"
		echo -e "	[+] dir brute force - launch directory bruteforce, 1 is yes, 0 is no"
		echo
		echo -e "	[+] Example: $0 https sites 1${NC}"
	exit 0
}

commandchecks

# Error checking for arguments

if [ $# -ne 3 ]; then
	echo -e "${RED}[-] Incorrect number of arguments${NC}"
	echo
	usage
fi

if [ "$1" != "http" ] && [ "$1" != "https" ]; then
	echo -e "${RED}[-] First argument was not http or https${NC}"
	echo
	usage
fi

if [ ! -f $2 ]; then
	echo -e "${RED}[-] Second argument was not file${NC}"
	echo
	usage
fi      

if [ "$3" != "1" ] && [ "$3" != "0" ]; then 
	echo -e "${RED}[-] Third argument was not 1 or 0${NC}"
	echo
	usage
fi

# Sort out cli args
ssl=$1
sites=`cat "$2"`
dirbrute=$3

# Get ports for testssl
if [ $ssl == "https" ]; then
	port=443
	echo -e "${YELLOW}[*] Which ports are running ssl other then 443."
	read -p "	[>]Enter ports with spaces between each one (Leave blank for none):" ports
	echo -e "${NC}"
		sslport="$port $ports"
fi

# Set ssl if not set
if [ -z "$ssl" ]; then 
    ssl="http"
fi

# Start scans
echo -e "${GREEN}[*] Starting scans at "`date`${NC}
echo
echo

if [ ! -d results ];then
	mkdir results
fi
cp $2 results
cd results

# Nmap
echo -e "${GREEN}[*] Launching nmap scan"
if [ ! -d nmap ];then 
	mkdir nmap
fi
    echo -e "	${YELLOW}[*] nmap scanning $ssl://$site"
nmap -Pn -A -oA nmap/tcpscan -iL $2 > /dev/null 2>&1
echo 

# hoppy 
echo -e "${GREEN}[*] Launching hoppy Scan"
if [ ! -d hoppy ]; then
	mkdir hoppy
fi

for site in `cat $2`
do
    echo -e "	${YELLOW}[*] Hoppy scanning $ssl://$site"
    ../tools/hoppy/hoppy -h "$ssl://$site" -E -S"hoppy/$site-$ssl" > /dev/null 2>&1
done


# Nikto 
echo -e "${GREEN}[*] Launching nikto Scan"
if [ ! -d nikto ]; then
	mkdir nikto
fi

for site in `cat $2`
do
    echo -e "	${YELLOW}[*] Nikto scanning $ssl://$site"
    nikto -h "$ssl://$site" -o "nikto/$ssl-$site.txt" -F txt > /dev/null 2>&1
done


# testssl
if [ $ssl == "https" ]; then
	echo -e "${GREEN}[*] Launching testssl Scan"
	if [ ! -d testssl ];then
		mkdir testssl
	fi
	for p in $sslport
	do
		for site in `cat $2`
		do
			echo -e "	${YELLOW}[*] Running full testssl.sh $site:$p"
			# testssl has a --log param but it outputs to the screen which I don't reallt want
			../tools/testssl.sh/testssl.sh "$site:$port" > "testssl/testssl-$site:$port"
		done
	done
fi

# EyeWitness
echo -e "${GREEN}[*] Launching EyeWitness"
if [ ! -d EyeWitness ]; then
       	mkdir EyeWitness
fi
echo
		echo -e "	${YELLOW}[*] Running EyeWitness against $ssl://$site"
../tools/EyeWitness/EyeWitness.py -x nmap/tcpscan.xml --all-protocols --no-prompt -d EyeWitness >/dev/null 2>&1


# IIS Short name scanner
echo -e "${GREEN}[*] Launching IIS Short Name Scanner"
if [ ! -d IIS_ShortName_Scanner ]; then
	mkdir IIS_ShortName_Scanner
fi

for site in `cat $2`
	do
		echo -e "	${YELLOW}[*] Shortname scanning $ssl://$site"
		java -jar ../tools/IIS-ShortName-Scanner/iis_shortname_scanner.jar 0 20 "$ssl://$site" ../tools/IIS-ShortName-Scanner/config.xml > "IIS_ShortName_Scanner/iis_shortname_$site-$ssl"
	done

# Directory Brute forcing	
if [ $dirbrute == 1 ]; then
	echo -e "${GREEN}[*] Beginning directory brute force"
	echo -e "	${YELLOW}[*] Using the dirb big.txt wordlist - this can be changed on line 143 if needed"
	if [ ! -d dirb ];then
		mkdir dirb
	fi
	for site in `cat $2`
	do
		dirb $ssl://$site /usr/share/wordlists/dirb/big.txt -r -o dirb/dirb_$site.txt > /dev/null 2>&1
	done
fi

rm $2
echo
echo -e "${GREEN}[*] Tests completed at `date`${NC}"

