function testSetValues
% testSetValues 
%
% Demonstates the use of the setValuesFromMetaData method of the
% XMLDefaultsNode class. This method is used to set the values of elements
% of the defaults tree from a saved metadata file.
%-------------------------------------------------------------------------

% Sample defaults xml file in ..\sample_xml\ directory
defaultsFile = ['..', filesep, 'sample_xml', filesep, 'gc_metadata_defaults.xml'];
metaDataFile = ['..', filesep, 'sample_xml', filesep, 'gc_metadata.xml'];

% Load defaults and metadata trees
defaultsTree = loadXMLDefaultsTree(defaultsFile);
metaDataTree = loadXMLDataTree(metaDataFile);

% Print values before changes
defaultsTree.printValues

% Set values form metadata tree
defaultsTree.setValuesFromMetaData(metaDataTree);

% Print values after changes
defaultsTree.printValues