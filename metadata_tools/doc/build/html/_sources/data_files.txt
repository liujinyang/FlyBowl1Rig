Data files
==========

The JFRC metadata tools rely on several data files in order to function
properly. These should be placed in the jfrc_metadata_tools/data sub-directory. 


**linenames.txt**
A list of all line names. This file is used when the range_basic or
range_advanced attribute of string is set to $LINENAME. This file can be
created/updated automatically using the *updateLinenames* function from the
Matlab command prompt - which will pull the latest values from the database.

**effectors.txt**
A list of all effectors. This file  is used when the range_basic or
range_advanced attribute of a string is set to $EFFECTOR. This file can be
created/updated automatically using the *updateEffectors* function from the
Matlab command prompt which will pull the latest values from the database.

**ldap.txt**
A list of LDAP user names. This file is used when the range_basic or
range_advanced attribute of a string is set to $LDAP. Currently, this file must
be updated manually.

**linenames_monthly.txt**
A list of line names for the current month. This file is used when the
range_basic of range_advanced attribute of a string is set to
$LINENAMES_MONTHLY. Currently, this file must be updated manually.
