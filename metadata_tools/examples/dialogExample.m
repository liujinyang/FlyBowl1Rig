function varargout = dialogExample(varargin)
% DIALOGEXAMPLE M-file for dialogExample.fig
%      DIALOGEXAMPLE, by itself, creates a new DIALOGEXAMPLE or raises the existing
%      singleton*.
%
%      H = DIALOGEXAMPLE returns the handle to a new DIALOGEXAMPLE or the handle to
%      the existing singleton*.
%
%      DIALOGEXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOGEXAMPLE.M with the given input arguments.
%
%      DIALOGEXAMPLE('Property','Value',...) creates a new DIALOGEXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialogExample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialogExample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialogExample

% Last Modified by GUIDE v2.5 28-Sep-2010 15:40:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialogExample_OpeningFcn, ...
                   'gui_OutputFcn',  @dialogExample_OutputFcn, ...
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


% --- Executes just before dialogExample is made visible.
function dialogExample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialogExample (see VARARGIN)

% Choose default command line output for dialogExample
handles.output = hObject;

% For this example we either use an example file from the sample_xml
% directory or we get a file name from the command line.
if isempty(varargin)
    % No arguments given - set defaults file to flybowl_defaults in sample_xml
    defaultsFile = ['..', filesep, 'sample_xml', filesep, 'flybowl_defaults.xml'];
else
    % Set defaults file first argument.
    defaultsFile = varargin{1};
end

% Set initial mode for GUI
handles = setInitialMode(handles,'basic');
handles = setInitialEntryTypeFilter(handles,'all');
handles = setSensorType(handles,'fakeit');

% Load XML defaults file. Creates handles.defaultsTree object and sets
% handles.defatulsFile
handles = loadDefaultsFile(handles,defaultsFile);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialogExample wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);

% --- Outputs from this function are returned to the command line.
function varargout = dialogExample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in opendDialogPushButton.
function opendDialogPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to opendDialogPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('open dialog')

% Disable button so that a second dialog can't be started
set(handles.opendDialogPushButton,'Enable','off');

% Create dialog
dialogHdl = basicMetaDataDlg(handles.defaultsTree,handles.mode);

% Set up temperature and humidity sensing
if strcmpi(handles.sensorType,'fakeit')
    sampler = THSampler('fake');
else
    port = handles.sensorType;
    sampler = THSampler('precon',port);
end

% Set temperature and humidity even listener
dialogHandles = guidata(dialogHdl);
THListener = dialogHandles.THListener;
sampler.addlistener('THSampleAcquired',@THListener.eventHandler);

% Start temperature & humitidy sensor and wait for dialog to exit
sampler.start();
uiwait(dialogHdl);

% Stop sensor and delete
sampler.stop();
delete(sampler);

% Re-enable button
set(handles.opendDialogPushButton,'Enable', 'on');

% Update handles structure - this is required because handles.defaultsTree
% had changed.  
guidata(hObject, handles);

% --- Executes on button press in saveMetaDataPushButton.
function saveMetaDataPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveMetaDataPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('save metadata');
saveDialogName = 'Save metadata to XML file';
[fileName, pathName, ~] =  uiputfile('metadata_test_write.xml', saveDialogName);
if ~fileName == 0
    fileName = [pathName,fileName];
    metaDataTree = createXMLMetaData(handles.defaultsTree);
    metaDataTree.write(fileName);
end

% --- Executes on button press in loadDefaultsPushButton.
function loadDefaultsPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadDefaultsPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('load defaults file');
[fileName, pathName, ~] = uigetfile('.xml');
if ~fileName == 0
    fileName = [pathName,fileName];
    handles = loadDefaultsFile(handles,fileName);
end
% Update handles structure
guidata(hObject, handles);
    
% --- Executes on button press in savedefaultspushbuttton.
function saveDefaultsPushButtton_Callback(hObject, eventdata, handles)
% hObject    handle to savedefaultspushbuttton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('save defaults')
saveDialogName = 'Save defaults metadata to XML file';
[fileName, pathName, ~] = uiputfile('defaults_test_write.xml',saveDialogName);
if ~fileName == 0
   fileName = [pathName,fileName];
   handles.defaultsTree.write(fileName);
end

% --- Executes when selected object is changed in modeButtonGroup.
function modeButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in modeButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'basicRadioButton'
        handles.mode = 'basic';
        disp('mode changed to basic');
    case 'advancedRadioButton'
        handles.mode = 'advanced';
        disp('mode changed to advanced');
    otherwise
        % Code for when there is no match.
        error('Unknown radio button - this should not happen');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes when selected object is changed in entryTypeFilterButtonGroup.
function entryTypeFilterButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in entryTypeFilterButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'allRadioButton'
        handles.entryTypeFilter = 'all';
        disp('entry filter changed to all');
    case 'manualRadioButton'
        handles.entryTypeFilter = 'manual';
        disp('entry filter changed to manual');
    case 'acquireRadioButton'
        handles.entryTypeFilter = 'acquire';
        disp('entry filter changed to acquire');
    otherwise
        % Code for when there is no match.
        error('Unknown radio button - this should not happen');
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in valuesNeededPushButton.
function valuesNeededPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to valuesNeededPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('showing values needed, filter = %s\n',handles.entryTypeFilter);

% Get defaults tree and filter type from handles structure
defaultsTree = handles.defaultsTree;
entryTypeFilter = handles.entryTypeFilter;

% Can print values to matlab command prompt as follows:
defaultsTree.printValuesNeeded(entryTypeFilter);

% Can get a list of the path strings to nodes which still need values as
% follows:
valuesNeeded = handles.defaultsTree.getValuesNeeded(entryTypeFilter);

% Lets display them is a message box
msgTitle = sprintf('Values needed (filter=%s)',entryTypeFilter);

if isempty(valuesNeeded)
    msgString = 'none';
else
    msgString = '';
    for i = 1:length(valuesNeeded)
        msgString = sprintf('%s%s\n', msgString, valuesNeeded{i});
    end
end
uiwait(msgbox(msgString,msgTitle));


% --- Executes on button press in fakeSensorCheckBox.
function fakeSensorCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to fakeSensorCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fakeSensorCheckBox
value = get(handles.fakeSensorCheckBox,'Value');
if value == true
    handles = setSensorType(handles,'fakeit');
else
    value = get(handles.COMPortPopUpMenu,'Value');
    COMPorts = get(handles.COMPortPopUpMenu,'String');
    handles = setSensorType(handles,COMPorts{value});
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in COMPortPopUpMenu.
function COMPortPopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to COMPortPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns COMPortPopUpMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from COMPortPopUpMenu
value = get(handles.COMPortPopUpMenu,'Value');
COMPorts = get(handles.COMPortPopUpMenu,'String');
handles = setSensorType(handles,COMPorts{value});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function COMPortPopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to COMPortPopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in printValuesPushButton.
function printValuesPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to printValuesPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.defaultsTree.printValues

% --- Executes on button press in printTreePushButton.
function printTreePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to printTreePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.defaultsTree.print


% Utility Functions
% -------------------------------------------------------------------------
function setCurrentFileText(handles,value)
% Set value of current file text
text = sprintf('%s', value);
set(handles.currentFileText,'String', text);

% -------------------------------------------------------------------------
function handles = loadDefaultsFile(handles, fileName)
% This function loads the XML Defatuls data file
try
    handles.defaultsTree = loadXMLDefaultsTree(fileName);
catch ME
    warnmsg = sprintf('unable to load defaults file: %s, %s', fileName,ME.message);
    warndlg(warnmsg, 'File load Error');
    return;
end
handles.defaultsFile = fileName;
setCurrentFileText(handles,fileName);

% -------------------------------------------------------------------------
function handles = setInitialMode(handles,mode)
% Sets initial mode for GUI
switch lower(mode)
    case 'basic'
        set(handles.basicRadioButton,'Value', true);
    case 'advanced'
        set(handles.advancedRadioButton,'Value', true);
    otherwise
        error('unrecognized mode %s',mode);
        set(handles.basicRadioButton,'Value', true);
        mode = 'basic';
end
fprintf('mode set to %s\n',mode);
handles.mode = mode;

% -------------------------------------------------------------------------
function handles = setInitialEntryTypeFilter(handles,filterString)
% Sets intitial entry type filter
switch lower(filterString)
    case 'all'
        set(handles.allRadioButton,'Value',true);
    case 'manual'
        set(handles.manualRadioButton,'Value',true);
    case 'acquire'
        set(handles.acquireRadioButton,'Value',true);
    otherwise
        error('unrecognized entry type filter %s', filterString);
        set(handles.allRadioButton,'Value',true);
        filterString = 'all';
end
fprintf('entry type set to %s\n',filterString');
handles.entryTypeFilter = lower(filterString);
    

function handles = setSensorType(handles,sensorType)
% Sets the sensor type
COMPorts = get(handles.COMPortPopUpMenu,'String');
switch lower(sensorType)
    case 'fakeit'
        disp('fake sensor set');
        set(handles.COMPortPopUpMenu,'Enable','off');
        set(handles.fakeSensorCheckBox,'Value',true);
    otherwise
        sensorType = upper(sensorType);
        pos = strmatch(sensorType,COMPorts,'exact');
        if isempty(pos)
            error('unknown sensorType %s, setting to fakeit',sensorType);
            set(handles.COMPortPopUpMenu,'Enable','off');
            set(handles.fakeSensorCheckBox,'Value',true);
            sensorType= 'fakeit';
        else
            fprintf('Port %s set\n',sensorType);
            set(handles.COMPortPopUpMenu,'Enable','on');
            set(handles.COMPortPopUpMenu,'Value',pos);
            set(handles.fakeSensorCheckBox,'Value',false)
        end
end
handles.sensorType = sensorType;

    
%function simpleListener(eventSrc,eventData)
%disp('hello');
