function multiSelectExample

% Sample defaults xml file in ..\sample_xml\ directory
defaultsFile = ['..', filesep, 'sample_xml', filesep, 'multiSelectExample.xml'];

% Load defaults XML tree from sample file
defaultsTree = loadXMLDefaultsTree(defaultsFile);

% Print the defaultsTree - this is a convenience function for work with the
% XML data tree. 
defaultsTree.print

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

% Print metaData tree - again the is a convenience function
metaData.print

