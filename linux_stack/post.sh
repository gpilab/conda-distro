#!/bin/bash
# Author: Nick Zwart
# Date: 2014feb21
# Brief: handle installation to the target directory


PKG=gpi
PREFIX=/opt/

spinner()                                                                       
{                                                                               
    local pid=$1                                                                
    local delay=0.75                                                            
    local spinstr='|/-\'                                                        
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do                      
        local temp=${spinstr#?}                                                 
        printf " [%c]  " "$spinstr"                                             
        local spinstr=$temp${spinstr%"$temp"}                                   
        sleep $delay                                                            
        printf "\b\b\b\b\b\b"                                                   
    done                                                                        
    printf "    \b\b\b\b"                                                       
}  

# NRZ - License check                                                           
EULA()
{
    clear
    echo -n "
Welcome to the GPI Stack installer.
                                                                                
In order to continue the installation process, please review the license        
agreement.                                                                      
Please, press ENTER to continue                                                 
>>> "
    read dummy
    clear
    more <<EOF
Copyright (c) 2014  Dignity Health

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

NO CLINICAL USE.  THE SOFTWARE IS NOT INTENDED FOR COMMERCIAL PURPOSES
AND SHOULD BE USED ONLY FOR NON-COMMERCIAL RESEARCH PURPOSES.  THE
SOFTWARE MAY NOT IN ANY EVENT BE USED FOR ANY CLINICAL OR DIAGNOSTIC
PURPOSES.  YOU ACKNOWLEDGE AND AGREE THAT THE SOFTWARE IS NOT INTENDED FOR
USE IN ANY HIGH RISK OR STRICT LIABILITY ACTIVITY, INCLUDING BUT NOT
LIMITED TO LIFE SUPPORT OR EMERGENCY MEDICAL OPERATIONS OR USES.  LICENSOR
MAKES NO WARRANTY AND HAS NOR LIABILITY ARISING FROM ANY USE OF THE
SOFTWARE IN ANY HIGH RISK OR STRICT LIABILITY ACTIVITIES.
EOF
    echo -n "
Do you approve the license terms? [yes|no]                                      
[no] >>> "
    read ans
    if [[ ($ans != "yes") && ($ans != "Yes") && ($ans != "YES") &&              
                ($ans != "y") && ($ans != "Y") ]]                               
    then                                                                        
        echo "The license agreement wasn't approved, aborting installation."    
        echo "In order to approve the agreement, you need to type \"yes\"."     
        echo "Install aborted."
        exit 2                                                                  
    fi
}            

EULA

# check if the user wants to blow away /opt/gpi
checkTarget()
{
    echo -n "
The GPI Framework, GPI Core Node Library and GPI Stack components will be
installed in the following directory:

	/opt/gpi

Do you wish to continue? [yes|no]
[no] >>> "
    read ans
    if [[ ($ans != "yes") && ($ans != "Yes") && ($ans != "YES") &&              
                ($ans != "y") && ($ans != "Y") ]]                               
    then                                                                        
        echo "User aborted install."
        exit 2                                                                  
    fi
}

checkTarget


#set -e  # exit on non-zero

# don't overwrite existing install
if [ -d "$PREFIX/$PKG" ]; then
    echo " "
    echo " "
    echo "ERROR: $PREFIX$PKG already exists."
    echo " "
    echo "Move the existing install aside by executing:"
    echo " "
    echo "    $ sudo mv $PREFIX$PKG $PREFIX$PKG.old"
    echo " "
    echo "Install aborted."
    echo " "
    echo " "
    exit 1
fi

# check for root access
if [ "$(id -u)" != "0" ]; then
    echo "You must be a root user to install." 2>&1
    echo "Install aborted."
    exit 1
fi

# make target dir and check
mkdir -p $PREFIX
if [ $? -ne 0 ]; then
    echo "Unable to create directory $PREFIX."
    echo "Install aborted."
    exit 1
fi

xfer()
{
    # move and overwrite the directory
    #   -copy takes alot of memory
    #   -but, move can't overwrite existing dirs
    echo "Installing files..."
    # mv -f $PKG $PREFIX/
    cp -r $PKG $PREFIX/
    if [ $? -ne 0 ]
    then
        echo "Unable to move contents to directory $PREFIX."
        echo "Install aborted."
        exit 1
    fi
}

# put progress into transfer
xfer &
spinner $!

# ubuntu instructions
echo " "
echo " "
echo "------------------------------------------------------------------"
echo "ATTENTION Node Developers:"
echo "In order to build C++ PyMODs, you'll need to install a compatible "
echo "C++ compiler.  Ubuntu users can enter the command: "
echo " "
echo "  \$ sudo apt-get install build-essential"
echo " "
echo "to install the necessary build tools.  "
echo "------------------------------------------------------------------"
echo " "
echo " "
echo "Add GPI to your path by entering:"
echo " "
echo "  \$ export PATH=\"/opt/gpi/bin:\$PATH\""
echo " "
echo "To make it permanent add the command to your ~/.bashrc file."
echo "This will give you the 'gpi' and 'gpi_make' commands."
echo " "
echo " "


# closing message
echo "Install complete."

exit 0
