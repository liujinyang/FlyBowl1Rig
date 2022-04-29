    %% input meta data information
    %defaultsFile = "flyBowlMetaTree.xml";
    %defaultsFile = "flybowl_branson_defaults.xml";
    defaultsFile1 = "flybowl_Katie_defaults1.xml";
%     defaultsFile2 = "flybowl_Katie_defaults2.xml";
%     defaultsFile3 = "flybowl_Katie_defaults3.xml";
%     defaultsFile4 = "flybowl_Katie_defaults4.xml";
    % Load defaults XML tree from sample file
    
    defaultsTree1 = loadXMLDefaultsTree(defaultsFile1);
%     defaultsTree2 = loadXMLDefaultsTree(defaultsFile2);
%     defaultsTree3 = loadXMLDefaultsTree(defaultsFile3);
%     defaultsTree4 = loadXMLDefaultsTree(defaultsFile4);

%update display value
    defaultsTree1.setValueByUniquePath({'experiment' 'exp_datetime'}, datestr(now,30));   
    %defaultsTree1.setValueByUniquePath({'experiment' 'session' 'flies' 'handling' 'seconds_fliesloaded'}, handles.loadFlyTime);
    defaultsTree1.setValueByUniquePath({'experiment' 'environment' 'IR_intensity'}, '20');
    defaultsTree1.setValueByUniquePath({'experiment','session','apparatus','computer'}, getenv('COMPUTERNAME'));
    defaultsTree1.setValueByUniquePath({'experiment','session','apparatus','apparatus_id'}, ...
        ['Rig', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','rig'}), '_',...
         'Plate', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','top_plate'}), '_',...
         'Bowl', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','bowl'}), '_',...
         'Camera', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','camera'}), '_',...
         'Computer', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','computer'}), '_',...
         'HardDrive', defaultsTree1.getValueByUniquePath({'experiment','session','apparatus','harddrive'})]);
    defaultsTree1.setValueByUniquePath({'experiment' 'session' 'flies' 'line'},...
               [defaultsTree1.getValueByUniquePath({'experiment' 'session' 'flies' 'male_parent'}), '_',...
               defaultsTree1.getValueByUniquePath({'experiment' 'session' 'flies' 'female_parent'})]);
           
    defaultsTree1.setValueByUniquePath({'experiment','flag_aborted', 'content'}, '1');
    
    metaDataFile1 = "testMetaData1.xml";
%     metaDataFile2 = "testMetaData2.xml";
%     metaDataFile3 = "testMetaData3.xml";
%     metaDataFile4 = "testMetaData4.xml";

% Create figure in which to place JIDE property grid
    fig = figure( ...
        'MenuBar', 'none', ...
        'Name', 'Metadata Input GUI', ...
        'NumberTitle', 'off', ...
        'Toolbar', 'none', ...
        'Position', [154 360 560 870],...
        'Units', 'pixels' ...
        );
    
    %tabgp = uitabgroup(fig,'Position',[.05 .05 .3 .8]);
    tabgp = uitabgroup(fig,'Position',[0 0 1 1]);
    tab1 = uitab(tabgp,'Title','flyBowlA');
%     tab2 = uitab(tabgp,'Title','flyBowlB');
%     tab3 = uitab(tabgp,'Title','flyBowlC');
%     tab4 = uitab(tabgp,'Title','flyBowlD');
    
    % Create JIDE PropertyGrid and display defaults data in figure
    pgrid1 = PropertyGrid(tab1,'Position', [0 0 1 1]);
    pgrid1.setDefaultsTree(defaultsTree1, 'advanced');
%     pgrid2 = PropertyGrid(tab2,'Position', [0 0 1 1]);
%     pgrid2.setDefaultsTree(defaultsTree2, 'advanced');
%     pgrid3 = PropertyGrid(tab3,'Position', [0 0 1 1]);
%     pgrid3.setDefaultsTree(defaultsTree3, 'advanced');
%     pgrid4 = PropertyGrid(tab4,'Position', [0 0 1 1]);
%     pgrid4.setDefaultsTree(defaultsTree4, 'advanced');
    
    % Block unit figure is destroyed
    uiwait(fig);
%     defaultsTree.setValueByUniquePath({'flyBowl' 'flies' 'genotype'},...
%         [defaultsTree.getValueByUniquePath({'flyBowl','flies', 'male_parent'}),'_' ...
%         defaultsTree.getValueByUniquePath({'flyBowl','flies', 'female_parent'})]);
    
    % Create XML meta data file from defaults tree. Note we haven't checked if
    % we have all the required values filled in, but this is suppose to be a
    % simple example - I'll show how to do this in a more ellaborate example.
    metaData1 = createXMLMetaData(defaultsTree1);
%     metaData2 = createXMLMetaData(defaultsTree2);
%     metaData3 = createXMLMetaData(defaultsTree3);
%     metaData4 = createXMLMetaData(defaultsTree4);
    
    % Save defaultsTree as xml file. Note, the current values for all the meta
    % data are saved in the tree so that it is possible to have meata data whose
    % default option is to use the last value used.
    defaultsTree1.write(defaultsFile1)
%     defaultsTree2.write(defaultsFile2)
%     defaultsTree3.write(defaultsFile3)
%     defaultsTree4.write(defaultsFile4)
    
    metaData1.write(metaDataFile1);
%     metaData2.write(metaDataFile2);
%     metaData3.write(metaDataFile3);
%     metaData4.write(metaDataFile4);
    