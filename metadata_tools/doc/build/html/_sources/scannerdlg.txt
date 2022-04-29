Barcode scanner dialog
======================

The barcode scanner dialog, *scannerDlg*, can be used to query FlyF database
for information associated with a barcode.  Note, the .m and .fig files for the
*scannerDlg* can in the src/dialog subdirectory of the jfrc_metadata_tools
project. 

The barcode scanner dialog can be used as follows:


.. code-block:: matlab

    [scanValues, propagateValue] = scannerDlg(propagateValue, propagateEnable) 

**Input arguments:**

1. *propagateValue*  - (true/false) sets the initial value of the propagate checkbox. 
2. *propagateEnable* - ('on'/'off') determine whether the propagate checkbox is enabled.

Note, both input arguments are optional. Their default values are true and 'on' respectively.  


**Output values:**

1. *scanValues* - matlab structure of the values returned from the database query. 
2. *propagateValue* - the value of the propagate checkbox when the dialog was closed.  

Currently the *scanValue* structure has the following fields:

* *Line_Name*
* *Date_Crossed*
* *Effector*
* *Set_Number*



