Basic operations
================

This section describes how to perform basic operations with the metadata tools. 


Loading, saving and printing
----------------------------

The data in the XML defaults file can be loaded into memory using the following
command. 

.. code-block:: matlab

    defaultsTree = loadXMLDefaultsTree('filename')

The object returned is a tree containing the defaults data based on the
class XMLDefaultsNode. 

An existing defaults tree, based on the XMLDefaultsNode class, can be saved to
an XML file with this method.

.. code-block:: matlab

    defaultsTree.write('filename')

The defaults tree, *defaultsTree*, can be printed to the Matlab command window as 
follows:

.. code-block:: matlab

    defaultsTree.print()

The result of the this command will be a printed display of all elements in the
tree and their attributes indented by depth in the tree.

The current values for all elements of the tree can be prined to the command
window the command 

.. code-block:: matlab

    defaultsTree.printValues()

The *printValues* method  only shows the value for each elements in the tree and
does not display the element's attributes.

Setting values 
--------------

Values for the metadata may be set in the defaults tree using a path string consisting
of the unique element names from the root element to the desired leaf element in the tree. 

A path string of unique names is required as the defaults tree may have more
than one element with a given name at the same depth [#f1]_ in the tree. When
this occurs elements with the same name which occur at the same depth in the
tree are numbered sequentially to give them unique name.  The unique name is
created by appending an '_n' to the name of the element where the n is the order
of occurrence of the element with this name at this depth in the tree.

For example, consider a defaults tree with two elements named apparatus at a
depth equal to 2 in the defaults tree. The unique names for the elements will
be 'apparauts_1' and 'apparatus_2' based on their order of occurrence in the XML
file.

A path string of unique names is simply  a string containing the unique
names of the elements separated by a period '.'.  Note, the name of the root
element is not included in the path string. :w

For example, suppose the defaults tree contains an element named "temperature"
which is a child of the element "apparatus" which in turn is a child of the
root element. The path string of unique names from the root element to the 
"temperature" element is given by

.. code-block:: matlab

    'apparatus.temperature'

In order to set the value of the temperature element in the defaults tree,
*defaultsTree*, to a value of 23.0 the following command could be used

.. code-block:: matlab

    defaultsTree.setValueByPathString('apparatus.temperature', 23.0)


Similarly, to set the value of an element in the defaults tree, *defaultsTree*,
specified by the path string, *pathString*, to the value, *value*, the
following command would be used.

.. code-block:: matlab

    defaultsTree.setValueByPathString(pathString, value)


Querying the defaults tree 
--------------------------

The defaults tree maybe queried to determine if all values which are required
have been given a nonempty value. This is done via the *hasValuesNeeded* method
as follows:

.. code-block:: matlab

    test = defaultsTree.hasValuesNeeded()

This method returns true or false based on whether or not all required values
have a nonempty value.  By default the *hasValuesNeeded* method checks values
of all entry types.  However, an optional argument, *entryType*, can be passed
to the method in order filter the results by the desired entry type. The
allowed values for the *entryType* argument are: 'all', 'acquire', and
'manual'.

Thus the command

.. code-block:: matlab

    test = defaultsTree.hasValuesNeeded('manual')

will return true or false depending on whether or not all required values to
entry type 'manual' have nonempty values.

The *getValuesNeeded* method can be used to get a cell array of path strings to
all elements that have a required value which is empty. Similar, to the
*hasValuesNeeded* method it can take an optional argument which filters the 
return values by entry type. The *getValuesNeeded* method can be used as follows:

.. code-block:: matlab

    valueNeeded = defaultsTree.getValuesNeeded(entryType)

Finally, the tree can be queried to get a cell array of path strings to all values
which need to be acquired by the computer. The method for this is *getValuesToAcquire* 
and it is used as follows:

.. code-block:: matlab

    valuesToAcquire = defaultsTree.getValuesToAcquire()

    
Creating metadata tree
-----------------------

After all of the required values in the defaults tree have been set the metadata tree can 
be created using the following command:

.. code-block:: matlab

    metadata = createXMLMetaData(defaultsTree)

This function returns a tree containing the metatdata based on the XMLDataNode
class. 

Saving the metadata tree
------------------------

The metadata in a tree *metadata*, based on the XMLDataNode class, may be
written to an XML file using the following command:

.. code-block:: matlab

    metadata.write('filename')




.. [#f1] The depth of an element is length of the path from it to the root element of the tree. 
