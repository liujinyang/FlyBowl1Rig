% set the XML defaults file name
defaultsFileName = [ ...
    '..', filesep,'sample_xml', filesep, ...
    'thebox_experimental_variables_defaults.xml' ...
    ];

% set mode
mode = 'basic';

% load the XML defaults file
defaultsTree = loadXMLDefaultsTree(defaultsFileName);

% show the dialog for editing metadata
dialogHdl = basicMetaDataDlg(defaultsTree,mode); handles = guidata(dialogHdl);

% grab output
defaultsTree = handles.defaultsTree;

% what values need to be acquired?
valuesNeeded = defaultsTree.getValuesNeeded('acquire')';

% set box
defaultsTree.getNodeByPathString('box');
defaultsTree.setValueByPathString('box','Orion');
defaultsTree.getNodeByPathString('box');

valuesNeeded = defaultsTree.getValuesNeeded('acquire')';

% set exp_datetime
defaultsTree.getNodeByPathString('exp_datetime');
defaultsTree.setValueByPathString('exp_datetime',datestr(now,'yyyy-mm-ddTHH:MM:SS'));
defaultsTree.getNodeByPathString('exp_datetime');

valuesNeeded = defaultsTree.getValuesNeeded('acquire')';

% set line for tube 1
defaultsTree.getNodeByPathString('session_1.flies.line');
defaultsTree.setValueByPathString('session_1.flies.line','rubin');
defaultsTree.getNodeByPathString('session_1.flies.line');

% set all tubes to be the same as the first tube
node0 = defaultsTree.getNodeByPathString('session_1.flies.line');
for i = 2:6,
  defaultsTree.setValueByPathString(sprintf('session_%d.flies.line',i),node0.value);
  defaultsTree.getNodeByPathString(sprintf('session_%d.flies.line',i));
end

valuesNeeded = defaultsTree.getValuesNeeded('acquire')';

% save results
metadataFileName = 'write_metadata_test.xml';
metaDataTree = createXMLMetaData(defaultsTree);
metaDataTree.write(metadataFileName);
