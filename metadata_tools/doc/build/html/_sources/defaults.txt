The XML defaults file
=====================

The purpose of the defaults file is to describe the metadata. For each item 
of metadata it describes: 

* the data type, "string", "float", "integer", "datetime", etc. 
* how the item should be validated, e.g., an acceptable range 
* the units, e.g., seconds, meters, ...
* how the data is to be obtained: manually or acquired by the computer 
* how/whether it should appear in the manual entry dialog 
* a short description
* whether the item is required
* the default value for the item
* the last value of the item  

Rules for metadata 
------------------

Three basic rules are assumed to hold regarding the XML metadata: 

#. the root element is named "experiment",
#. data is stored either in an element's content or in an attribute, but not never in both.
#. the word "content" is special and never used as the name of an attribute for an element in
   the metadata file.


Basic structure 
---------------

The structure of the desired XML metadata file determines the structure of the
XML defaults file as follows:  

#. for every XML element in the metadata file there is a corresponding element
   in the defaults file with the same name,
#. for every attribute of an element in the metadata file there is a corresponding
   leaf element [#f1]_ in the defaults file with the name of the attribute, 
#. for every element in the metadata file where data is stored in the element's content 
   there is corresponding leaf element in the defaults file with the name "content",
#. leaf elements in the defaults file correspond to items of metadata (either attributes 
   or the content of an element) and  have the following required attributes: 

   * datatype, 
   * range_basic, 
   * range_advanced, 
   * units, 
   * appear_basic, 
   * appear_advanced, 
   * entry, 
   * description, 
   * required, 
   * default, and 
   * last.


Some examples will help clarify the relationship between the metadata file and
the defaults file. Consider the following simple XML metadata file. 

.. code-block:: xml 

    <?xml version="1.0" encoding="utf-8"?>
    <experiment>
      <apparatus type="rig1" id="1" />
      <notes> some stuff happened, blah, blah, blah. </notes>
    </experiment>

This file has a root element named "experiment" with two child elements name
"apparatus" and "notes".  The element name "experiment" has no values
associated with it.  The child element "apparatus" has two values associated
with it stored in the attributes "type" and "id".  The child element "notes"
has a single value stored as the element's content - the string "some stuff
happened, blah, blah, blah."

The XML defaults file associated with this metadata file would be given as
follows:

.. code-block:: xml

    <?xml version="1.0" encoding="utf-8"?>
    <experiment>
      <apparatus>
        <type 
          datatype="string" 
          range_basic="rig1, rig2, rig3" 
          range_advanced="rig" 
          units="" 
          appear_basic="false" 
          appear_advanced="false" 
          entry="manual" 
          description="Experimental apparatus " 
          required="true" 
          default="rig1" 
          last="" 
          />
        <id 
          datatype="integer" 
          range_basic="[1,Inf]" 
          range_advanced="[1,Inf]" 
          units="" 
          appear_basic="false" 
          appear_advanced="false" 
          entry="manual" 
          description="Apparatus identification number" 
          required="true" 
          default="1" 
          last="" 
          />
      </apparatus>
      <notes>
        <content 
          datatype="string" 
          range_basic="" 
          range_advanced="" 
          units="" 
          appear_basic="true" 
          appear_advanced="true" 
          entry="manual" 
          description="Observations of behavior by experimenter" 
          required="false" 
          default="" 
          last="" 
          />
      </notes>
    </experiment>

Note that for every element in the metadata file there is a corresponding
element in the defaults file with the same name. In this case the elements are:
"experiment", "apparatus", and "notes". 

In addition, corresponding to the two attributes "type" and "id" of the element
"apparatus" in the metadata file there are two elements in the defaults file.
These elements are are children of the element "apparatus". 

Similarly, for the element "notes" in the metadata file which stores its value
in the element's content there is a corresponding element named "content" in the
defaults file. Again, the element "content" is a child of the element "notes". 

Finally, the leaf elements in the defaults file which correspond to either
attributes or element content have the necessary required attributes describing
the metadata: datatype, range_basic, etc.

Required attributes
-------------------

Leaf elements of the defaults file are required to have set of attributes
which describe the metadata items with which they are associated. The 
required attributes are described below.

datatype 
~~~~~~~~ 

The datatype attribute describes what type of data is expected and may take one
of the following values:

**string**  
    for data given by a sequence characters such as "fruitfly" or  "rig1"

**float**  
    for data given by a floating point number such as 100.2 or 3.14

**integer** 
    for data given by an integer number such as 1 or 50

**datetime**  
    for time and date data, format yyyy-mm-ddTHH:MM:SS  

**time24**  
    for 24 hour time data, HH:MM, for example 02:30 or 12:15

**integer_list** 
    for data given by a list of integers such as 1,2,3,10 

.. _range_basic_label:

range_basic
~~~~~~~~~~~

The range_basic attribute describes the allowed range of values when the
operating mode is set to 'basic'. The values allowed for range_basic
depend upon the datatype. In all cases if range_basic is empty then there are
no restrictions upon the range of allowed values other than that the data must
be of the correct type.

**string**
    For string datatypes range_basic may be given by: 

    #. the empty string "" - meaning no restriction
    #. a comma separated list of allowed values such as "rig1, rig2, rig3, rig4" 
    #. one of the following special symbols: $LINENAME, $LINENAME_MONTHLY, $EFFECTOR, or $LDAP
    
    The meaning of the special symbols is as follows:

    * $LINENAME:  list of line names downloaded from SAGE 
    * $LINENAME_MONTHLY: list of monthly line names (must be manually updated)
    * $EFFECTOR: list of effectors downloaded from SAGE 
    * $LDAP: list of LDAP user names (must be downloaded manually)

    Note, the list of line names and effectors can be downloaded from SAGE
    using the *updateLinenames* and *updateEffectors* functions from the Matlab
    command line. These function will create the linenames.txt and
    effectors.txt files in the jfrc_metadata_tools/data directory. For entries
    which must be updated manually, such as $LDAP or $LINENAME_MONTHLY, the
    user must place a ldap.txt file in the jfrc_metadata_tools/data directory.

**float and integer**
    For float and integer data types range_basic may be given by: 

    #. the empty string "" - meaning no restriction
    #. an inclusive, exclusive, or hybrid range such as [0,10], (0,10), or [0,10) respectively. 

    For integer data types the range bounds should be integer numbers or -Inf, Inf. 

    For float data types the ranges bounds should be floating points numbers or -Inf, Inf.

    For both float and integer data types the lower bound must be less than the upper bound.

**datetime**
    For datetime data types range_basic may be given by:

    #. the empty string "" - meaning no restriction
    #. an inclusive, exclusive or hybrid range such as [now-10, now], (now-10,  now), 
       or [now-10,now) respectively.

    The special symbol *now* in the datetime bounds refers to the current time
    and date. For example, now-10 means 10 days ago and now+1 mean 1 day into
    the future.

    The values -Inf and Inf may be used to specify that the lower or upper
    bound in infinite. 

    The datetime range can be modified by placing a comma followed by *days*,
    *hours*, *minutes* after the range. In this case the time and date values
    are truncated to the nearest, day, hour, or minute respectively. The
    modifier can be used to reduce the possible list of values which appear in
    the popup list in the GUI dialog to a manageable and when finer values of
    datetime aren't sensible. 

    For example, the follow range string

    .. code-block:: none

        [now-15,now-3], days  

    gives and range from 15 days ago to 2 days ago, inclusive on both bounds,
    in steps of days. 

**time24**
    For time24 data types range_basic may be given by:

    #. the empty string "" - meaning no restriction
    #. an inclusive, exclusive or hybrid range or the form [HH:MM, HH:MM]

    For example, the following range string 

    .. code-block:: none
    
        [01:30, 15:00) 

    gives a range with an inclusive lower bound of 1:30 and an exclusive upper
    bound of 15:00. 

**integer_list**
    For integer_list data types range_basic may be given by:

    #. the empty string """ - meaning no restriction
    #. an inclusive, exclusive or hybrid range such as [1,12], (3,7) or (7,22]. 

    The lower and upper bounds should be integers or -Inf, Inf. 

    When a range is given all the values in the integer list are check to verify 
    that they are between the given bounds. 


range_advanced
~~~~~~~~~~~~~~

The range_advanced attribute describes the allowed range of values when the operating
mode is set to 'advanced". The allowed values for range_advanced are the same as for 
:ref:`range_basic_label` and are given above. 

units
~~~~~

The units attribute describes the units associated with the metadata item.
Note, if there are no units associated with the metadata than the units
attribute should be set to the empty string. If the units attribute is nonempty
the units will appear in the description text box at the bottom of the metadata
GUI dialog when the item is selected. *This might not be implemented yet*

appear_basic
~~~~~~~~~~~~

The appear_basic attribute determines whether or not the metadata item will appear in 
the GUI dialog when operating in 'basic' mode. The allowed values for appear_basic are

#. "false" - the item will not appear in basic mode.
#. "true" - the item will appear in basic mode and be editable
#. "true, readonly" - the item will appear basic mode but will not be editable

appear_advanced
~~~~~~~~~~~~~~~

The appear_advanced attribute determines whether or not the metadata item will appear in 
the GUI dialog when operating in 'advanced' mode. The allowed values for appear_advanced are

#. "false" - the item will not appear in advanced mode.
#. "true" - the item will appear in advanced mode and be editable
#. "true, readonly" - the item will appear advanced mode but will not be editable


entry
~~~~~

The entry attribute describes the how the data is expected to be entered during
the course of the experiment. The allowed values for this attribute are:

#. "manual" - the item is to be manually entered
#. "acquire" - the item is to be acquired by the computer

The purpose of the entry attribute is to enable the control software to query the
metadata defaults tree for items that it need to acquire. 

The value of items which are set to "manual" entry with appear_advanced or
appear_basic set to "false" or "true, readonly" is determined by their default
value. 

Note, items with "manaul" entry,  appear_advanced or appear_basic set to
"false" or "true, readonly",  which are required, and don't have a default
value will raise an error when loaded. This is because with this set of
conditions there is no way the value can be set during the course the
experiment. 

description
~~~~~~~~~~~

The description attribute is used to provide users with a brief description 
of the metadata item. The description string appears in the in a text box at the 
lower portion of the metadata enty GUI dialog when the item is selected. 

required
~~~~~~~~

The required attribute determines whether or not a nonempty value for this
metadata item is required. Allowed values for the required attribute are "true"
and "false".

default
~~~~~~~

The default attribute sets the desired default value for this item. Note, 
the default value must be within the range of allowed values. 

The default attribute may also be set to the special symbal $LAST. In which
case the default value will be set to the last value used for this metadata
item. 

last
~~~~

The last value attribute is used to store the last value set for this data item. 
When the defaults tree is saved at the end of an experiment the current value for the
for the metadata item is saved in this attribute

Useful tools for editing XML files
----------------------------------

The XML defaults file maybe edited with any reasonable text editor such as
EMACS, vim, nodepad, etc. However, this can mean writing quite a bit a markup
in addition to the data that you wish to enter. A nice free tool for editing
XML files on Microsoft Windows is XML Notepad which can be downloaded from 
`here <http://www.microsoft.com/downloads/en/details.aspx?familyid=72d6aa49-787d-4118-ba5f-4f30fe913628&displaylang=en>`_



.. [#f1] A leaf element is an element with no child elements. 
