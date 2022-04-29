function varargout = scannerDlg(varargin)
% SCANNERDLG MATLAB code for scannerDlg.fig
%      SCANNERDLG, by itself, creates a new SCANNERDLG or raises the existing
%      singleton*.
%
%      H = SCANNERDLG returns the handle to a new SCANNERDLG or the handle to
%      the existing singleton*.
%
%      SCANNERDLG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SCANNERDLG.M with the given input arguments.
%
%      SCANNERDLG('Property','Value',...) creates a new SCANNERDLG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scannerDlg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scannerDlg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help scannerDlg

% Last Modified by GUIDE v2.5 21-Mar-2011 11:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scannerDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @scannerDlg_OutputFcn, ...
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


% --- Executes just before scannerDlg is made visible.
function scannerDlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scannerDlg (see VARARGIN)

% Choose default command line output for scannerDlg
handles.uiwait_flag = 1;
handles.scanValues = [];
set(handles.scanFigure,'WindowStyle', 'modal');

% Get 1st argument propagateValue (true or false) determines whether or not
% the propagte checkbox is selected.
if length(varargin) > 0
   propagateValue = varargin{1}; 
else
    propagateValue = true;
end

% Get the second argument propagateEnable ('on' or 'off') determines
% whether or not the propagate checkbox is enabled.
if length(varargin) > 1
    propagateEnable = varargin{2};
else
    propagateEnable = 'on';
end

set(handles.propagateCheckbox,'Value', propagateValue);
set(handles.propagateCheckbox,'Enable', propagateEnable);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes scannerDlg wait for user response (see UIRESUME)
if handles.uiwait_flag ~= 0
    uiwait(handles.scanFigure);
end


% --- Outputs from this function are returned to the command line.
function varargout = scannerDlg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.scanValues;
varargout{2} = getPropagateValue(handles);

% The figure can be deleted now
if handles.uiwait_flag ~=0
    delete(handles.scanFigure);
end

% --- Executes when user attempts to close scanFigure.
function scanFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to scanFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if handles.uiwait_flag ~=0  
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        set(handles.scanFigure,'WindowStyle', 'normal');
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
else
    delete(hObject);
end

% --- Executes on button press in propagateCheckbox.
function propagateCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to propagateCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of propagateCheckbox


% --- Executes on button press in okPushButton.
function okPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to okPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.scanFigure);


% --- Executes on button press in cancelPushButton.
function cancelPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.scanValues = [];
% Update handles structure
guidata(hObject, handles);
close(handles.scanFigure);


function scanEditText_Callback(hObject, eventdata, handles)
% hObject    handle to scanEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanEditText as text
%        str2double(get(hObject,'String')) returns contents of scanEditText as a double

% Get scan string and convert it to a number for querying the database
scanStr = get(handles.scanEditText,'String');
scanNum = str2num(scanStr);

% Check that scanned result is a number
if isempty(scanNum)
    errMsg = sprintf('Scan Error: unable to convert scanned result, %s, to number', scanStr);
    h = errordlg(errMsg);
    uiwait(h);
    handles.scanValues = [];
else
    % Query database for barcode
    try
        handles.scanValues = FlyFQuery(scanNum);
    catch ME
        errMsg = sprintf('Scan Error: %s', ME.message);
        h = errordlg(errMsg);
        uiwait(h);
        handles.scanValues = [];
    end
end
updateInfo(handles);

% Highlight text
javaEdit = findjobj(handles.scanEditText);
set(javaEdit,'SelectionStart', 0);
set(javaEdit,'SelectionEnd', length(scanStr)); 

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scanEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% -------------------------------------------------------------------------
function updateInfo(handles)
% Update info based on latest scanValues
scanValues = handles.scanValues;
if ~isempty(scanValues)
    scanFields = fields(scanValues);
    for i = 1:length(scanFields)
        fieldName = scanFields{i};
        tableData{i,1} = fieldName;
        tableData{i,2} = scanValues.(fieldName);
    end
else
    for i = 1:4
        for j = 1:2
            tableData{i,j} ='';
        end
    end
end
set(handles.infoTable,'Data', tableData);

% -------------------------------------------------------------------------
function val = getPropagateValue(handles)
% Returns the current propagation checkbox value
val = get(handles.propagateCheckbox,'Value');


% --- Executes when scanFigure is resized.
function scanFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to scanFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try
%     uicontrol(handles.scanEditText);
% end

try
    % Use java to set focus as uicontrol function doesn't seem to be
    % working properly.
    obj = findjobj(handles.scanEditText);
    obj.requestFocus();
end
 


% --- Executes on key press with focus on scanEditText and none of its controls.
function scanEditText_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to scanEditText (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

% if eventdata.Key == 'insert'
%    close(handles.scanFigure); 
% end
