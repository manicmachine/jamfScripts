#!/bin/sh

################################################################################
#
# THIS SCRIPT IS NOT AN OFFICIAL PRODUCT OF JAMF SOFTWARE
# AS SUCH IT IS PROVIDED WITHOUT WARRANTY OR SUPPORT
#
# BY USING THIS SCRIPT, YOU AGREE THAT JAMF SOFTWARE
# IS UNDER NO OBLIGATION TO SUPPORT, DEBUG, OR OTHERWISE
# MAINTAIN THIS SCRIPT
#
################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#  searchScope.sh - Identify policies using specified group as their scope.
#
# DESCRIPTION
#
#  This script will iterate through all computer policies within the JSS and
#  identify those which utilized a specified group as part of their scope.
#
# REQUIREMENTS
#
#   Administrative credentials to the JSS.
#
################################################################################
#
# HISTORY
#
#  Version: 1.1
#
#   Release Notes:
#   - Added the ability to query the JSS for Group IDs and prompt the user to
#   select one if unknown.
#   - Tidied up long lines to adhere to 80 character limit.
#
#  - Created by Corey Sather on August 10, 2017
#
################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
################################################################################
# Define terminal error text color.
RED="\033[0;31m"
NO_COLOR="\033[0m"

# Prompt for JSS url, admin account, password, and group ID to search for.
echo "JSS URL: \c"
read jssURL

# Check if the user entered a trailing slash on their URL, and if so, remove it.
if [ $(echo "${jssURL: -1}") == / ]; then
  jssURL="${jssURL%/}"
fi

echo "Enter your JSS administrative account: \c"
read jssAdmin

echo "Enter $jssAdmin's password: \c"
read -s jssPasswd

while true; do
  echo ""
  echo "Choose one of the following options."
  echo " 1 - I don't know the ID of the group I'm looking for."
  echo " 2 - I do know the ID of the group I'm looking for."
  echo "Enter your choice: \c"
  read hasGroupID

# Verify the user has provided a valid option.
  if [ $hasGroupID == 1 ] || [ $hasGroupID == 2 ]; then
    break
  else
    echo "${RED}Unknown option. Please enter either 1 or 2.${NO_COLOR}"
  fi
done

# If the user doesn't know the ID of the desired group, query the JSS, list
# all options to the user.
if [ $hasGroupID == 1 ]; then
  echo "Querying the JSS for computer group information now..."

  apiCall=$(curl -H "Content-Type: application/xml" -ksu \
  "$jssAdmin":"$jssPasswd" "$jssURL"/JSSResource/computergroups -X GET)
  groupIDs=$(echo $apiCall | xpath //computer_groups/computer_group/id 2> \
  /dev/null | sed s/'<id>'//g | sed s/'<\/id>'/', '/g)
  IFS=', ' read -r -a groupIDArray <<< $groupIDs

  echo ""
  echo "Computer groups"
  echo "---------------"

  for id in "${groupIDArray[@]}"
  do
    computerGroup=$(curl -H "Content-Type: application/xml" -ksu \
    "$jssAdmin":"$jssPasswd" "$jssURL"/JSSResource/computergroups/id/$id -X GET)
    echo "ID: $(echo $computerGroup | xpath //computer_group/id 2> /dev/null | \
    sed s/'<id>'//g | sed s/'<\/id>'//g) - $(echo $computerGroup | \
    xpath //computer_group/name 2> /dev/null | sed s/'<name>'//g | \
    sed s/'<\/name>'//g)"
  done
fi

echo ""
echo "Enter your Group ID: \c"
read groupID

echo "Checking policies now. This may take a moment..."
echo ""

# Query for all policies from the JSS, extract their IDS and then store them in
# an array.
apiCall=$(curl -H "Content-Type: application/xml" -ksu \
"$jssAdmin":"$jssPasswd" "$jssURL"/JSSResource/policies -X GET)
policyIDs=$(echo $apiCall | xpath //policies/policy/id 2> /dev/null | \
sed s/'<id>'//g | sed s/'<\/id>'/', '/g)
IFS=', ' read -r -a policyIDArray <<< $policyIDs

# Loop through all the returned policy IDs and echo those which contain the
# specified groupID within it's scope.
echo "Policies within scope"
echo "---------------------" 

for id in "${policyIDArray[@]}"
do
  policyScope=$(curl -H "Content-Type: application/xml" -ksu \
  "$jssAdmin":"$jssPasswd" "$jssURL"/JSSResource/policies/id/$id -X GET)
  if [ "$(echo $policyScope | xpath \
  //policy/scope/computer_groups/computer_group/id 2> /dev/null | \
  sed s/'<id>'//g | sed s/'<\/id>'//g)" == $groupID ]; then
    echo "ID: $(echo $policyScope | xpath //policy/general/id 2> /dev/null | \
    sed s/'<id>'//g | sed s/'<\/id>'//g) - $(echo $policyScope | \
    xpath //policy/general/name 2> /dev/null | sed s/'<name>'//g | \
    sed s/'<\/name>'//g)"
  fi
done
