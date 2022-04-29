Using the JIDE grid control
===========================

Basic Example
-------------

The example demonstrates how to add the JIDE grid control to your user
interface. Note, The source code for this and other examples can be found in
the examples directory of the jfrc_metedata_tools project directory.

.. code-block:: matlab

    % This example shows some very basic usage of the metadata tools. In it I 
    % show  how to: 
    %
    %   1. load the defaults metadata xml file into an XMLDefaultsNode based 
    %      tree. 
    %   2. display the tree in a JIDE property grid in a figure where values
    %      can be edited.
    %   3. convert the xml defaults data tree into a xml meta data tree.
    %   4. how to write the defaults tree and meta data trees to xml files.
    %
    % -------------------------------------------------------------------------
    
    % Load defaults XML tree from sample file
    defaultsFile = 'my_defaults_file.xml';
    
    defaultsTree = loadXMLDefaultsTree(defaultsFile);
    
    % Create figure in which to place JIDE property grid
    fig = figure( ...
        'MenuBar', 'none', ...
        'Name', 'Metadata Test', ...
        'NumberTitle', 'off', ...
        'Toolbar', 'none' ...
        );
    
    % Create JIDE PropertyGrid and display defaults data in figure
    pgrid = PropertyGrid(fig,'Position', [0 0 1 1]);
    pgrid.setDefaultsTree(defaultsTree, 'advanced');
    
    % Block unit figure is destroyed
    uiwait(fig);
    
    % Note, there is no need to get a new copy of the defaultsTree object as it
    % is passed by reference to pgrid so any changes will be reflected in our
    % copy.
    
    % Create XML meta data file from defaults tree. Note we haven't checked if
    % we have all the required values filled in, but this is suppose to be a 
    % simple example - I'll show how to do this in a more ellaborate example.
    metaData = createXMLMetaData(defaultsTree);
    
    % Save defaultsTree as xml file. Note, the current values for all the meta
    % data are saved in the tree so that it is possible to have meata data whose 
    % default option is to use the last value used. 
    defaultsTree.write('defaultsTree_test_write.xml');
    
    % Save meta tree as xml file
    metaData.write('metadata_test_write.xml');

Setting Values
--------------
When the values in a given metadata defaults tree are being displayed using a
JIDE property grid and you wish to change some of the displayed values it is
best to do this via the *setValueByPathString* method of the Property Grid
object. The developer may wish do this when, for example, propagating the
linename and effectors. The *setValueByPathString* method will change the value
in both the property grid and in the defaults tree object.

The *setValuesByPathString* method is used as follows: 

.. code-block:: matlab
    
    pgrid.setValueByPathString(pathString, newValue)

where *pathString* is the unique path string in the defaults tree to the
desired attribute and *newValue* is the desired new value for this attribute.
    

Callbacks
---------
The Property Grid object has several callback which can used by the developer
in order modify its default behaviour. These include the *PropertyChange*
callback and the *FuncKeyPressed* callbacks. The *PropertyChange* callback is
called whenever the value of a property changes and the *FuncKeyPressed*
callback is called whenever the function key associated with the given callback
is pressed.

Note, when using these callbacks it is important that the figure's handle
visibility be set to 'on' otherwise the callback will not function properly. 

setPropertyChangeCallback
~~~~~~~~~~~~~~~~~~~~~~~~~
The *PropertyChange* callback can be set using the *setPropertyChangeCallback* method
as follows:

.. code-block:: matlab

    pgrid.setPropertyChangeCallback(@(x)propertyChange_Callback(userData,x));

Note, in this example *userData* is any data which the user desires to pass to
the function.  An example *PropertyChange* callback function might look as
follows:

.. code-block:: matlab

    function propertyChange_Callback(userData, propName)
    % Get node, node name, and new node value
    node = handles.defaultsTree.getNodeByPathString(propName);
    nodeName = node.name;
    newValue = handles.defaultsTree.getValueByPathString(propName);
    % Take desired action ...



setFuncKeyPressedCallback
~~~~~~~~~~~~~~~~~~~~~~~~~
The *FuncKeyPressed* callback can be set using the *setFuncKeyPressed* methods as follows:

.. code-block:: matlab

    pgrid.setFuncKeyPressedCallback(@(x)F1KeyPressed_Callback(userData,x),n);

where *userData* is any data the user wished to pass to the callback function
and *n* is the number of the function key to associate with the callback.
Currently, function key 1 through 7 may be assigned a callback function. 
An example *FuncKeyPressed* callbeck might look as follows:

.. code-block:: matlab

    function F1KeyPressed_Callback(userData, selectedProperty) 
    % Open barcode scanner dialog. 
    [scanValues, ~] = scannerDlg(true,'off');
    % Take action based on results ...



