function varargout = testPropertyGUI(varargin)
% TESTPROPERTYGUI MATLAB code for testPropertyGUI.fig
%      TESTPROPERTYGUI, by itself, creates a new TESTPROPERTYGUI or raises the existing
%      singleton*.
%
%      H = TESTPROPERTYGUI returns the handle to a new TESTPROPERTYGUI or the handle to
%      the existing singleton*.
%
%      TESTPROPERTYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTPROPERTYGUI.M with the given input arguments.
%
%      TESTPROPERTYGUI('Property','Value',...) creates a new TESTPROPERTYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testPropertyGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testPropertyGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testPropertyGUI

% Last Modified by GUIDE v2.5 10-Apr-2019 16:32:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testPropertyGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @testPropertyGUI_OutputFcn, ...
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


% --- Executes just before testPropertyGUI is made visible.
function testPropertyGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testPropertyGUI (see VARARGIN)

% Choose default command line output for testPropertyGUI
handles.output = hObject;

defaultsFile = "flybowl_Katie_defaults.xml";
    % Load defaults XML tree from sample file
    defaultsTree = loadXMLDefaultsTree(defaultsFile);
    metaDataFile = "testMetaData.xml";
    
    % Create JIDE PropertyGrid and display defaults data in figure
    pgrid = PropertyGrid(handles.property_panel,'Position', [0 0 1 1]);
    pgrid.setDefaultsTree(defaultsTree, 'advanced');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testPropertyGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testPropertyGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
