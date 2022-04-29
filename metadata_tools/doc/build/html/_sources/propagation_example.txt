Propagation example
===================

The following example demostrates how to use the *PropertyChange* callback to
propagate the linename and effector values in the JIDE property gird and
defaults tree.  

Note, the .m and .fig files (propertyChangedExample.m and
propertyChangedExample.fig)  for this example can be found in the examples
subdirectory of the jfrc_metadata_tools project directory.

.. code-block:: matlab

    function varargout = propertyChangedExample(varargin)
    % propertyChangedExample - this example demonstrates how to propogate
    % values in the property grid by setting up a propertyChange callback. 
    %
    % -------------------------------------------------------------------------
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @propertyChangedExample_OpeningFcn, ...
                       'gui_OutputFcn',  @propertyChangedExample_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
    
    
    % --- Executes just before propertyChangedExample is made visible.
    function propertyChangedExample_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to propertyChangedExample (see VARARGIN)
    
    % Choose default command line output for propertyChangedExample
    handles.output = hObject;
    
    % Step 1. 
    %
    % Set load metadata defaults file, load and create property grid
    % -------------------------------------------------------------------------
    
    % Sample defaults xml file in ..\sample_xml\ directory
    filename = 'propChangeDefaultsExample.xml';
    handles.defaultsFile = ['..', filesep, 'sample_xml', filesep, filename];
    
    % Load defaults XML tree from sample file
    handles.defaultsTree = loadXMLDefaultsTree(handles.defaultsFile);
    
    % Create JIDE PropertyGrid and display defaults data in figure
    handles.pgrid = PropertyGrid(handles.figure,'Position', [0 .07 1 .93]);
    handles.pgrid.setDefaultsTree(handles.defaultsTree, 'advanced');
    
    % Note, the handle visibility of figure must be set to 'on'. This required 
    % for callbacks the callbacks to work properly - I set this using guide
    % when creating the figure.
    % -------------------------------------------------------------------------
    
    % Step 2. 
    %
    % Setup property change callback - this is used to propogate the values such
    % as linename and effector. 
    % -------------------------------------------------------------------------
    handles.pgrid.setPropertyChangeCallback(@(x)propertyChange_Callback(handles,x));
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes propertyChangedExample wait for user response (see UIRESUME)
    % uiwait(handles.figure);
    
    
    % --- Outputs from this function are returned to the command line.
    function varargout = propertyChangedExample_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    % -------------------------------------------------------------------------
    function propertyChange_Callback(handles, propName)
    % Callback function for property changed event in jide property grid. This
    % example demonstrates how to use this function to propogate the linename
    % and effector values.
    node = handles.defaultsTree.getNodeByPathString(propName);
    nodeName = node.name;
    newValue = handles.defaultsTree.getValueByPathString(propName);
    fprintf('propertyChange_Callback: propName = %s, value = %s\n', propName, newValue);
    
    switch nodeName
        case 'line'
            propertyChangeLinename(handles, newValue);
        case 'effector'
            propertyChangeEffector(handles, newValue);
    end
    
    % -------------------------------------------------------------------------
    function propertyChangeLinename(handles, newValue)
    % Set all linenames to newValue 
    disp('propertyChangeLinename');
    for i = 1:2
        for j = 1:2
            pathStr = sprintf('apparatus_%d.session_%d.flies.line', i, j);
            fprintf('  setting: %s to %s\n', pathStr, newValue);
            handles.pgrid.setValueByPathString(pathStr, newValue);
        end
    end
    
    % Update genotype strings - as they depend on linename and effector
    setGenotype(handles);
    
    % -------------------------------------------------------------------------
    function propertyChangeEffector(handles, newValue)
    % Set all effector values to newValue
    disp('propertyChangeLinename');
    for i = 1:2
        for j = 1:2
            pathStr = sprintf('apparatus_%d.session_%d.flies.effector', i, j);
            fprintf('  setting: %s to %s\n', pathStr, newValue);
            handles.pgrid.setValueByPathString(pathStr, newValue);
        end
    end
    
    % Update genotype strings - as they depend on linename and effector
    setGenotype(handles)
    
    % -------------------------------------------------------------------------
    function setGenotype(handles)
    % Update all genotype strings - as they depend on linename and effector.
    % It is a little inefficient to do this separately - but you may want to
    % call this function in other places - like at startup to set the genotype.
    disp('setGenotype')
    for i = 1:2
        for j = 1:2
            % Get path strings
            linenamePath = sprintf('apparatus_%d.session_%d.flies.line', i, j);
            effectorPath = sprintf('apparatus_%d.session_%d.flies.effector', i, j);
            genotypePath = sprintf('apparatus_%d.session_%d.flies.genotype',i,j);
            
            % Get linename and effector. Then set genotype via the pgrid.
            linename = handles.defaultsTree.getValueByPathString(linenamePath);
            effector = handles.defaultsTree.getValueByPathString(effectorPath);
            genotype = sprintf('%s__%s', linename, effector);
            fprintf('  setting: %s to %s\n', genotypePath, genotype);
            handles.pgrid.setValueByPathString(genotypePath, genotype);
        end
    end
