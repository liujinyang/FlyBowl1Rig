
Overview
========

The metadata tools package provides a unified software interface for defining,
handling, and saving metadata. 

Metadata are defined using an XML based defaults file. This file describes all
values in the metadata. It sets criteria for the allowed values, determines how
and whether the data is displayed in the manual entry dialog based on the
operating mode, sets whether or not a nonempty value is required for a
particular metadata entry, and provides the control software with clues as to
how this data is to be obtained.

The software interface provides functions for loading the defaults file into
memory as a defaults tree. The defaults tree can then be queried to determine
what values are needed and whether or not the values are manual entries or
should be acquired by the computer. 

An automatically generated GUI dialog is provided for user entry of values whose
entry type is set to manual.  The values displayed by this dialog are
determined by the operating mode which can be either 'basic' or 'advanced'. 

Validators are automatically created for all values in the tree based on the
settings in the XML defaults file. All values are required to validate before
they can be set. 

Once the required values have been set in the defaults tree functions are
provided to convert the defaults tree into a tree containing the metadata and
then to write the metadata to an XML file. 


