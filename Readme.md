# What

This is a script that automates some of the things that I do when on a testing a web application.
I have called it wart which is short for Web App Recon Tasks. Fitting as my code is not too pretty either!

Only tested on Kali linux so far.

# Why

I found myself running the same tools again and again each time I did a web app assessment so I wrote a 'wrapper' to run them. It is not meant to be all you do by any means. There is a lot missing from this but it was a few of the tasks I do a lot so felt like automating them and it went from there.

# Who

Just me for this bit but a big shout out to the following for the tools: (In no particular order)

  * hoppy - portcullis - https://labs.portcullis.co.uk/download/hoppy-1.8.1.tar.bz2 
  * testssl.sh - @drwetter - https://github.com/drwetter/testssl.sh 
  * IIS-ShortName-Scanner - @irsdl - https://github.com/irsdl/IIS-ShortName-Scanner 
  * EyeWitness - Chris Truncer, https://www.christophertruncer.com/ - https://github.com/ChrisTruncer/EyeWitness 
  * nikto - Chris Sullo, David Lodge - https://cirt.net/Nikto2 
  * nmap - Gordon Lyon - https://nmap.org/ 
  * dirb - The Dark Raver - http://dirb.sourceforge.net/about.html 

# How

Run the setup.sh script, this will create a directory and download or clone the tools into that directory. nikto, nmap and dirb are installed by default with the latest kali image so it does nothing to those.
Once the script has run then you can run the wart.sh script to get usage info and then to launch the scans.

Also before anyone says anything I know it should be, Who, What, Where, When and Why.

