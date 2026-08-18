#!/bin/bash
#
#  Date: June 23rd 2015
#  Author: Will Ashworth || williamashworth.com
#
#  Suspend cPanel accounts for all users of a given reseller
#  account. Scripted specifically for cPanel servers on Linux.
#
#  Copyright (C) 2015 Will Ashworth
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details. http://www.gnu.org/licenses/

reseller=$1

if [ -z "$reseller" ]
then
    echo "Reseller is empty. Please provide one! Like this..."
    echo "./thisscript <reseller>"
else
    # Get the users for this reseller
    users=`grep $reseller /etc/trueuserowners | cut -d : -f 1`

    # Loop through the list of users
    for user in $users; do
        # Suspend the cPanel user account
        /scripts/unsuspendacct $user
    done
fi
