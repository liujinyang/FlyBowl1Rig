function varargout = scannerExample(varargin)
% scannerExample - simple example demonstrating how to use the barcode
% scanner dialog, scannerDlg with a callback. 
%
% Usage: scannerExample
%
% Select any item on the lefthand side of the property grid and press the
% F1 key to open the barcode scanner dialog. 
% -------------------------------------------------------------------------


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scannerExample_OpeningFcn, ...
                   'gui_OutputFcn',  @scannerExample_OutputFcn, ...
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


% --- Executes just before scannerExample is made visible.
function scannerExample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scannerExample (see VARARGIN)

% Choose default command line output for scannerExample
handles.output = hObject;

% Step 1. 
%
% Set load metadata defaults file, load and create property grid
% -------------------------------------------------------------------------

% Sample defaults xml file in ..\sample_xml\ directory
handles.defaultsFile = ['..', filesep, 'sample_xml', filesep, 'flybowl_defaults.xml'];

% Load defaults XML tree from sample file
handles.defaultsTree = loadXMLDefaultsTree(handles.defaultsFile);

% Create JIDE PropertyGrid and display defaults data in figure
handles.pgrid = PropertyGrid(handles.figure,'Position', [0 .07 1 .93]);
handles.pgrid.setDefaultsTree(handles.defaultsTree, 'advanced');

% Note, the handle visibility of figure must be set to 'on'. This required 
% for callbacks the callbacks to work properly - I set this using guide
% when creating the figure.
% -------------------------------------------------------------------------

% Step 3. 
%
% Setup callback functions for function keys. In this example two callbacks
% are defined - one for the F1 key and the second for the F2 key. See the
% function definitions below.
% -------------------------------------------------------------------------

% F1 key callback
handles.pgrid.setFuncKeyPressedCallback(@(x)F1KeyPressed_Callback(handles,x),1);

% F2 key callback  
handles.pgrid.setFuncKeyPressedCallback(@(x)F2KeyPressed_Callback(handles,x),2);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scannerExample wait for user response (see UIRESUME)
% uiwait(handles.figure);


% --- Outputs from this function are returned to the command line.
function varargout = scannerExample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% -------------------------------------------------------------------------
function F1KeyPressed_Callback(handles, selectedProperty) 
% Callback for when the F1 key is pressed. This example callback
% demonstrates how to use the barcode scanner dialog to set values in the
% property grid.
fprintf('F1KeyPressed_Callback, selectedProperty = %s\n',selectedProperty);

% Open scanner dialoag. 
% 
% The scanner dialog takes two agruments. The first propagateValue (true/false) 
% determines whether or not the propagate checkbox is ticked when the dialog is 
% started. The second propagateEnable determines whether or not the checkbox is 
% enabled so the user can change its setting.  
%
% In this example the propagate checkbox is ticked, but not enabled - thus
% the user can't change whether it is ticked or not. 
[scanValues, ~] = scannerDlg(true,'off');

% The scanner dialog returns two values  - the bar codes scan values, scanValues, 
% and the value of the propagate checkbox, propagateValue.  In this example the 
% propagateValue is ingnored as the checkbox is ticked, but not enabled -
% so users can't change its value.
scanValues

if ~isempty(scanValues)
    
    % Get linename, effector and genotype
    linename = scanValues.Line_Name;
    effector = scanValues.Effector;
    genotype = sprintf('%s__%s', linename, effector);
    
    % Set values in property grid. Note this also sets the values in the metadata 
    % defaults tree. 
    handles.pgrid.setValueByPathString('apparatus.apparatus.apparatus.flies.line',linename);
    handles.pgrid.setValueByPathString('apparatus.apparatus.apparatus.flies.effector', effector);
    handles.pgrid.setValueByPathString('apparatus.apparatus.apparatus.flies.genotype', genotype);
    
end


% -------------------------------------------------------------------------
function F2KeyPressed_Callback(handles, selectedProperty)
% Callback for when the F2 key is pressed. 
fprintf('F2KeyPressed_Callback, selecedProperty = %s\n', selectedProperty);

% Add whatever actions you like ....

    
