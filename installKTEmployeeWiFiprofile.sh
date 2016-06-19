#!/bin/bash
# installKTEmployeeWiFiprofile.sh
# Installs the KTEmployee Certificate Authentication WiFi profile for the current user
# © 2016 by Sergio Aviles.
# version 1.0 2016-06-15

##Variables
User=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
inKeychain=$(security find-generic-password -s com.apple.network.eap.user.item.wlan.ssid.KTEmployee | awk '/keychain/ {print $2}' | sed 's/\"//g')
profilePath="/private/tmp/Kabletown Employee Wireless.mobileconfig"

##Functions
installProfile() # Actually does the real work.
{
  if [[ -f "$profilePath" ]]; then
    echo "Installing profile for user $User."
    profiles -I -F "$profilePath"
  else
    echo "Profile not found. Aborting."
    exit 1
  fi
}
removeKTEmployeePassword() # Removes the saved password for KTEmployee WiFi in the user's keychain. Inspired/Lifted from Enterprise Connect sample password script.
{
  if [[ "$inKeychain" != "" ]]; then
    echo "Found KTEmployee password in $inKeychain"
    keychainUser=$(echo "$inKeychain" | awk -F\/ '{print $3}')
    if [[ "$keychainUser" ==  "$User" ]]; then
      echo "Keychain location and logged in user match. Deleting keychain item. "
      security delete-generic-password -s com.apple.network.eap.user.item.wlan.ssid.KTEmployee "$inKeychain"
    else
      echo "Users do not match. Attempting to delete for logged in user."
      security delete-generic-password -a "$User" -l "KTEmployee"
      if [[ $? -ne 0 ]]; then
        echo "KTEmployee password not found for $User. Skipping."
      else
        echo "KTEmployee password found for $User and removed."
      fi
    fi
  else
    echo "No KTEmployee password found in $inKeychain. Exiting."
  fi
}

##Execute
installProfile
removeKTEmployeePassword

exit 0
