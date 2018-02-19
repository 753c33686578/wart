#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "\n${GREEN}Running setup script\n"

# Create tools directory
echo -e "${GREEN}[*] Creating tool directory${NC}"
if [ ! -d tools ]; then 
	mkdir tools
	echo -e "${YELLOW}	[+] Directory created"
else
	echo -e "${BLUE}	[*] Directory exists${NC}"
fi
cd tools

# Create hoppy directory 
echo -e "${GREEN}[*] Creating hoppy directory"
if [ ! -d hoppy ]; then
	echo -e "${YELLOW}	[+] Installing and unpacking hoppy${NC}"
	wget --quiet https://labs.portcullis.co.uk/download/hoppy-1.8.1.tar.bz2
	tar -xf hoppy-1.8.1.tar.bz2
	mv hoppy-1.8.1 hoppy
	rm hoppy-1.8.1.tar.bz2
else
	echo -e "${BLUE}	[*] hoppy exists - Nothing to do${NC}"
fi

# Create testssl.sh directory
echo -e "${GREEN}[*] Creating testssl.sh directory"
if [ ! -d testssl.sh ]; then
	echo -e "${YELLOW}	[+] Installing testssl.sh"
	git clone --quiet https://github.com/drwetter/testssl.sh.git
else
	echo -e "${BLUE}	[*] testssl.sh exists - Nothing to do${NC}"
fi

# Create IIS-ShortName-Scanner directory
echo -e "${GREEN}[*] Creating IIS-ShortName-Scanner directory"
if [ ! -d IIS-ShortName-Scanner ]; then
	echo -e "${YELLOW}	[+] Installing IIS Short Name Scanner"
	git clone --quiet https://github.com/irsdl/IIS-ShortName-Scanner.git
	chmod +x IIS-ShortName-Scanner/multi_targets.sh
else
	echo -e "${BLUE}	[*] IIS-ShortName-Scanner exists - Nothing to do${NC}"
fi

# Create EyeWitness directory
echo -e "${GREEN}[*] Creating Eyewitness directory"
if [ ! -d EyeWitness ]; then
	echo -e "${YELLOW}	[+] Installing Eyewitness"
	git clone --quiet https://github.com/ChrisTruncer/EyeWitness.git
	cd EyeWitness
	bash -c setup/setup.sh > /dev/null 2>&1
else 
	echo -e "${BLUE}	[*] EyeWitness exists - Nothing to do${NC}"
fi
echo
echo -e "${GREEN}[*] Setting folder permissions${NC}"
echo
echo -e "${GREEN}[*] Setup Complete"${NC}
