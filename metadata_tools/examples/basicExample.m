function basicExample
% This example show very basic usage of the metadata tools. In it I show 
% how to: 
%
%   1. load the defaults metadata xml file into an XMLDefaultsNode based 
%      tree. 
%   2. display the tree in a JIDE property grid in a figure where values
%      can be edited.
%   3. convert the xml defaults data tree into a xml meta data tree.
%   4. how to write the defaults tree and meta data trees to xml files.
%   5. how print the values in the tree to the screen
%
% -------------------------------------------------------------------------


% Sample defaults xml file in ..\sample_xml\ directory
%defaultsFile = ['..', filesep, 'sample_xml', filesep, 'flybowl_defaults.xml'];
defaultsFile = 'D:\placeLearning\placeLearning_ver2\PLControlMetaTree.xml';
curfile = mfilename('fullpath');
[current_path, filename] = fileparts(curfile);

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

% Save defaultsTree as xml file. Note, the current values for all the meta
% data are saved in the tree so that it is possible to have meata data whose 
% default option is to use the last value used. 
defaultsTree.write('defaultsTree_test_write.xml');

% Save meta tree as xml file
metaData.write('metadata_test_write.xml');