function varargout = autoCompleteDlg(varargin)
% AUTOCOMPLETEDLG MATLAB code for autoCompleteDlg.fig
%      AUTOCOMPLETEDLG, by itself, creates a new AUTOCOMPLETEDLG or raises the existing
%      singleton*.
%
%      H = AUTOCOMPLETEDLG returns the handle to a new AUTOCOMPLETEDLG or the handle to
%      the existing singleton*.
%
%      AUTOCOMPLETEDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOCOMPLETEDLG.M with the given input arguments.
%
%      AUTOCOMPLETEDLG('Property','Value',...) creates a new AUTOCOMPLETEDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autoCompleteDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autoCompleteDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autoCompleteDlg

% Last Modified by GUIDE v2.5 18-Mar-2011 12:46:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autoCompleteDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @autoCompleteDlg_OutputFcn, ...
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


% --- Executes just before autoCompleteDlg is made visible.
function autoCompleteDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to autoCompleteDlg (see VARARGIN)

% Choose default command line output for autoCompleteDlg
handles.uiwait_flag = 1;
handles.output = '';

% Get arguments
if length(varargin) > 0
    handles.allowedValues = varargin{1};
else
    % Temporary - for development purposes.
    handles.allowedValues = {'bob', 'alan', 'steve'};
end
if length(varargin) > 1
    curText = varargin{2};
else
    curText = '';
end
if length(varargin) > 2
   nameStr = varargin{3}; 
else
    nameStr = 'Value Name:';
end

set(handles.text,'String', nameStr);
handles.allowedValuesLower = lower(handles.allowedValues);

% Setup java text edit box.
editPos = get(handles.edit, 'Position');
javaEditPos = editPos;
javaEdit = javacomponent(javax.swing.JTextField, javaEditPos);
javaEdit.setFocusable(true);
set( ...
    javaEdit, ...
    'KeyPressedCallback', ...
    @(obj,event) javaEditKeyPressedCallback(obj,event,handles.autoCompFigure) ...
    );
javaEdit.setText(curText);
handles.javaEdit = javaEdit;

% Set listbox 
matching = getMatchingValues(handles, curText);
if isempty(matching)
    set(handles.listbox,'String',handles.allowedValues);
else
    set(handles.listbox,'String', matching);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes autoCompleteDlg wait for user response (see UIRESUME)
if handles.uiwait_flag ~=0
    uiwait(handles.autoCompFigure);
end


function javaEditKeyPressedCallback(obj, event, fig)
% Key pressed event callback for java edit tect. 

% Get the current text
handles = guidata(fig);

% Get current text
curText = char(obj.getText());
%curTextLower = lower(curText);

% Get ascii code for current key
keyCode = event.getKeyCode();

if keyCode == 10 % Enter pressed  
    listBoxStr = get(handles.listbox,'String');
    if length(listBoxStr) == 1
        rtnVal = listBoxStr{1};
    else
        rtnVal = curText;
    end
    handles.output = rtnVal;
    % Update handles structure
    guidata(fig, handles);
    close(handles.autoCompFigure);
else 
   % Find matching values in allowed values - ignoring case
    matching = getMatchingValues(handles, curText);
    
    % Set listbox String and edit box text based on matching
    set(handles.listbox,'Value', 1);
    set(handles.listbox,'String', matching);
    if length(matching) >= 1
        matchStr = matching{1};
        matchStr = matchStr(1:length(curText));
        n = length(matchStr);
        obj.setText(matchStr);
        set(obj,'SelectionStart', n);
        set(obj,'SelectionEnd', n);   
    end
end

% --- Outputs from this function are returned to the command line.
function varargout = autoCompleteDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% The figure can be deleted now
if handles.uiwait_flag ~=0
    delete(handles.autoCompFigure);
end


% --- Executes when user attempts to close autoCompFigure.
function autoCompFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to autoCompFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Hint: delete(hObject) closes the figure
if handles.uiwait_flag ~=0  
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % I was getting wierd crashes matlab lockups ... setting
        % windowstyle back to normal before closing the figure 
        % seems to stop this.
        set(handles.autoCompFigure,'WindowStyle', 'normal');
        delete(handles.javaEdit); 
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(handles.javaEdit);
        delete(hObject);
    end
else
    delete(hObject);
end

function edit_Callback(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit as text
%        str2double(get(hObject,'String')) returns contents of edit as a double


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, ~)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when autoCompFigure is resized.
function autoCompFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to autoCompFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if ~isfield(handles,'jEdit')
%    handles.jEdit = findjobj(handles.edit);
%    set(handles.jEdit, 'KeyReleasedCallback', @test);
% end
try
    uicontrol(handles.listbox)
    %handles.javaEdit.requestFocus();
end

% --- Executes on key press with focus on listbox and none of its controls.
function listbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(eventdata.Key, 'return')
    listBoxStr = get(handles.listbox, 'String'); 
    listBoxVal = get(handles.listbox, 'Value');
    curText = listBoxStr{listBoxVal};
    handles.javaEdit.setText(curText);
    handles.output = curText;
    pause(0.1);
    close(handles.autoCompFigure);
end
% Update handles structure
guidata(hObject, handles);

function matching = getMatchingValues(handles, curText)
% Find matching values in allowed values - ignoring case
curTextLower = lower(curText);
testVals = strncmp(handles.allowedValuesLower,curTextLower,length(curTextLower));
matching = handles.allowedValues(testVals);
