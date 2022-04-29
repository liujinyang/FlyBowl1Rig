function varargout = flyBowl_RGB(varargin)
% FLYBOWL_RGB MATLAB code for flyBowl_RGB.fig
%      FLYBOWL_RGB, by itself, creates a new FLYBOWL_RGB or raises the existing
%      singleton*.
%
%      H = FLYBOWL_RGB returns the handle to a new FLYBOWL_RGB or the handle to
%      the existing singleton*.
%
%      FLYBOWL_RGB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYBOWL_RGB.M with the given input arguments.
%
%      FLYBOWL_RGB('Property','Value',...) creates a new FLYBOWL_RGB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flyBowl_RGB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flyBowl_RGB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flyBowl_RGB

% Last Modified by GUIDE v2.5 05-Apr-2021 14:36:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @flyBowl_RGB_OpeningFcn, ...
    'gui_OutputFcn',  @flyBowl_RGB_OutputFcn, ...
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
end

% --- Executes just before flyBowl_RGB is made visible.
function flyBowl_RGB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flyBowl_RGB (see VARARGIN)

% Choose default command line output for flyBowl_RGB
handles.output = hObject;

flyBowl_user_setting;

hComm = initialize_flyBowl;
handles.hComm = hComm;
handles.LEDPattern = '1111';
handles.Chr_int_val = 0;
handles.Grn_int_val = 0;
handles.Blu_int_val = 0;

% add this per Kristin's request
if ~exist('PreconSensor','file')
    p = fileparts(mfilename('fullpath'));
    addpath(genpath(p));
end

for i = 1:1
    if ~(handles.hComm.flea3{i} == 0)
        flyBowl_camera_control(handles.hComm.flea3{i},'preview');
    end
    handles.defaultMetaXmlFile{i} = defaultMetaXmlFile{i};
end

handles.THUpdateP = THUpdateP;
%poll the temperature and humidity every second
if ~(hComm.THSensor == 0)
    handles.tTemp = timer('StartDelay', 3, 'Period', handles.THUpdateP, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@displayTempHumd, handles.figure1} );
    %guidata(hObject, handles); Do I need to update the handles before the
    start(handles.tTemp);
end

handles.hOverheatWarning = warndlg('Temp is too high, shut down all backlights!', 'Overheat Warn Dialog');
close(handles.hOverheatWarning);
handles.defaultDir = defaultDir;

handles.ledProtocolDir = ledProtocolDir;
handles.ledProtocol = defaultLedProtocol;
%set(handles.led_protocol_text, 'string', defaultLedProtocol);
handles.expProtocolDir = expProtocolDir;
handles.expProtocol = defaultExpProtocol;
set(handles.exp_protocol_text, 'string', [expProtocolDir,defaultExpProtocol]);
handles.rearProtocolDir = rearProtocolDir;
handles.rearProtocol = defaultRearProtocol;
set(handles.rear_protocol_text, 'string', [rearProtocolDir,defaultRearProtocol]);
handles.handleProtocolDir = handleProtocolDir;
handles.handleProtocol = defaultHandleProtocol;
set(handles.handle_protocol_text, 'string', [handleProtocolDir,defaultHandleProtocol]);

handles.expDataDir = expDataDir;
if ~exist(handles.expDataDir, 'dir')
    mkdir(handles.expDataDir);
end
handles.rig = rigName;
handles.expPlotUpdateRate = expPlotUpdateRate;
handles.maxIrBacklightIntensity = maxIrBacklightIntensity;
handles.maxVisibleBacklightIntensity = maxVisibleBacklightIntensity;

% Update handles structure
handles.pulseWidth = 0;
handles.pulsePeriod = 0;
handles.expRun = 0;
handles.loadFlyTime(1:4) = datetime('now');
handles.flagAborted = 0;
%find default metadata xml file
%updateLineNames;

handles.expRun = 0;
handles.figMetaData = 1; %set metadata input gui handle a non-handle value
handles.expStartTime = datetime('now');
%updateEffectors;

%handles.defaultExpNotesFile = defaultExpNotesFile;
handles.jsonFile = defaultJsonFile;
handles.movieFormat = movieFormat;
%handles.intensityMode = 'LINEAR';
handles.tempThreshold = tempThreshold;

%Reset fly Bowl Controller
%handles.hComm.LEDCtrl.setPropertiesToDefaults({'ALL'});
handles.flyBowlEnabled = {true, true, true, true};


%load default IR intensity value from user setting file
Ir_int_val = IrInt_DefaultVal;
if Ir_int_val > handles.maxIrBacklightIntensity
    Ir_int_val = handles.maxIrBacklightIntensity;
end

handles.IrIntValue = Ir_int_val;
handles.hComm.LEDCtrl.setIRLEDPower(Ir_int_val);
%set(handles.IrInt, 'Value', Ir_int_val/handles.maxIrBacklightIntensity);
set(handles.IrInt, 'Value', Ir_int_val/100);
set(handles.IrIntVal, 'String', num2str(Ir_int_val));
set(hObject,'Position', GUIPosition);
guidata(hObject, handles);

% UIWAIT makes flyBowl_RGB wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

function displayTempHumd(obj, event, Hfig)
handles = guidata(Hfig);
[temp,humid,~,~] = handles.hComm.THSensor.read(1);
set(handles.temp_val, 'String', num2str(temp));
set(handles.hum_val, 'String', num2str(humid));
if temp > handles.tempThreshold && ~ishandle(handles.hOverheatWarning)
    handles.hOverheatWarning = warndlg('Temp is too high, shut down all backlights!', 'Overheat Warn Dialog');
    handles.hComm.LEDCtrl.setVisibleBacklightsOff();
    handles.hComm.LEDCtrl.setIrBacklightsOff(0);
    set(handles.IrInt, 'Value', 0);
    set(handles.IrIntVal, 'String', [num2str(0) '%']);
    set(handles.ChrInt, 'Value', 0);
    set(handles.ChrIntVal, 'String', [num2str(0) '%']);
    set(handles.GrnInt, 'Value', 0);
    set(handles.GrnIntVal, 'String', [num2str(0) '%']);
    set(handles.BluInt, 'Value', 0);
    set(handles.BluIntVal, 'String', [num2str(0) '%']);
end
% handles.TempValue = temp;
% handles.HumdValue = humd;
guidata(Hfig, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = flyBowl_RGB_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on slider movement.
function ChrInt_Callback(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Chr_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
handles.Chr_int_val = Chr_int_val;
set(handles.ChrIntVal, 'String', [num2str(Chr_int_val),'%']);

%send command to controller
handles.hComm.LEDCtrl.setRedLEDPower(Chr_int_val);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function ChrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on slider movement.
function IrInt_Callback(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

Ir_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.IrIntVal, 'String', [num2str(Ir_int_val) '%']);

%send command to controller
handles.IrIntValue = Ir_int_val;
handles.hComm.LEDCtrl.setIRLEDPower(Ir_int_val);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function IrInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

function ChrIntVal_Callback(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ChrIntVal as text
%        str2double(get(hObject,'String')) returns contents of ChrIntVal as a double
end

% --- Executes during object creation, after setting all properties.
function ChrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ChrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes during object creation, after setting all properties.
function IrIntVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IrIntVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure

%close the serial port connection
%turn off IR

%if metadata gui is still open, close it first
if ishandle(handles.figMetaData)
    remindMessage = sprintf('Please close metaData input GUI to save data before you close the main GUI.');
    fprintf(1, '%s\n', remindMessage);
    warndlg(remindMessage);
    return; 
end

%stop update temp and humdity. clear the timer
try
    if ~(handles.hComm.THSensor == 0)
        stop(handles.tTemp);
    end
    clearup_flyBowl(handles.hComm)
    
catch ME
    disp(ME);
end
delete(hObject);
%close all;
clear all;
end


% --- Executes on button press in select_led_protocol.
function select_led_protocol_Callback(hObject, eventdata, handles)
% hObject    handle to select_led_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_led_protocol
%oldPath = pwd;
%cd(handles.expProtocolDir);
[filename, pathname] = uigetfile([handles.ledProtocolDir, '*.xlsx'],'Select an led protocol file');
if isequal(filename,0)
    return
else
    expFile = fullfile(pathname, filename);
    set(handles.led_protocol_text, 'string', expFile);
    handles.expFile = expFile;
    [~,~,protocolExt] = fileparts(expFile);
end

handles.ledProtocol = expFile;

switch protocolExt
    case {'.csv'}
        [intext, indata] = csvread_with_headers(expFile);
    case {'.xls', '.xlsx'}
        [indata,intext,~] = xlsread(expFile);
    otherwise
        disp('Unknown protocol file type.')
        return
end

%fclose(fid);
handles.protocol.stepNum= indata(:,1);
handles.protocol.duration = indata(:,2);  %in ms
handles.protocol.delayTime = indata(:,3);
%red light
handles.protocol.Rintensity = indata(:,4);
handles.protocol.RpulseWidth = indata(:,5);
handles.protocol.RpulsePeriod = indata(:,6);
handles.protocol.RpulseNum = indata(:,7);
handles.protocol.RoffTime = indata(:,8);
handles.protocol.Riteration = indata(:,9);
%green light
handles.protocol.Gintensity = indata(:,10);
handles.protocol.GpulseWidth = indata(:,11);
handles.protocol.GpulsePeriod = indata(:,12);
handles.protocol.GpulseNum = indata(:,13);
handles.protocol.GoffTime = indata(:,14);
handles.protocol.Giteration = indata(:,15);
%blue light
handles.protocol.Bintensity = indata(:,16);
handles.protocol.BpulseWidth = indata(:,17);
handles.protocol.BpulsePeriod = indata(:,18);
handles.protocol.BpulseNum = indata(:,19);
handles.protocol.BoffTime = indata(:,20);
handles.protocol.Biteration = indata(:,21);

handles.protocol.ProtocolData = indata;
handles.protocol.ProtocolHeader = intext(1,:);

totalDuration = sum(handles.protocol.duration); %in ms
handles.totalDuration = totalDuration/1000;   %in seconds
%plot the LED protocol
%if exist(get(handles.exp_setting,'String'),'file') && exist(get(handles.exp_name,'String'), 'file') 
    display_protocol(hObject, handles);
%end

end

function display_protocol(hObject,handles)
%% update the protocol in the axes
cla(handles.protocol_axes);

totalDuration = handles.totalDuration; %in sec

X = 0:0.001:totalDuration;
%xticks('auto');
xlim([0 totalDuration+5]);
Yr = zeros(totalDuration*1000+1,1);
Yg = zeros(totalDuration*1000+1,1);
Yb = zeros(totalDuration*1000+1,1);

oneStep = struct();
stepStartPnt = 1;

%calculate the four point value for each step
for stepIndex = 1:length(handles.protocol.stepNum)   
    oneStep(stepIndex).NumStep = handles.protocol.stepNum(stepIndex);
    oneStep(stepIndex).Duration = handles.protocol.duration(stepIndex)/1000;  %in seconds
    oneStep(stepIndex).DelayTime = handles.protocol.delayTime(stepIndex);
    %red light
    oneStep(stepIndex).RedIntensity = handles.protocol.Rintensity(stepIndex);
    oneStep(stepIndex).RedPulseWidth = handles.protocol.RpulseWidth(stepIndex);
    oneStep(stepIndex).RedPulsePeriod = handles.protocol.RpulsePeriod(stepIndex);
    oneStep(stepIndex).RedPulseNum = handles.protocol.RpulseNum(stepIndex);
    oneStep(stepIndex).RedOffTime = handles.protocol.RoffTime(stepIndex);
    oneStep(stepIndex).RedIteration = handles.protocol.Riteration(stepIndex);
    %green light
    oneStep(stepIndex).GrnIntensity = handles.protocol.Gintensity(stepIndex);
    oneStep(stepIndex).GrnPulseWidth = handles.protocol.GpulseWidth(stepIndex);
    oneStep(stepIndex).GrnPulsePeriod = handles.protocol.GpulsePeriod(stepIndex);
    oneStep(stepIndex).GrnPulseNum = handles.protocol.GpulseNum(stepIndex);
    oneStep(stepIndex).GrnOffTime = handles.protocol.GoffTime(stepIndex);
    oneStep(stepIndex).GrnIteration = handles.protocol.Giteration(stepIndex);
    %blue light
    oneStep(stepIndex).BluIntensity = handles.protocol.Bintensity(stepIndex);
    oneStep(stepIndex).BluPulseWidth = handles.protocol.BpulseWidth(stepIndex);
    oneStep(stepIndex).BluPulsePeriod = handles.protocol.BpulsePeriod(stepIndex);
    oneStep(stepIndex).BluPulseNum = handles.protocol.BpulseNum(stepIndex);
    oneStep(stepIndex).BluOffTime = handles.protocol.BoffTime(stepIndex);
    oneStep(stepIndex).BluIteration = handles.protocol.Biteration(stepIndex);
        
    powerG = oneStep(stepIndex).GrnIntensity/100;
    powerR = oneStep(stepIndex).RedIntensity/100;
    powerB = oneStep(stepIndex).BluIntensity/100;
    
    LEDOnStartPnt = oneStep(stepIndex).DelayTime*1000 + stepStartPnt;
    RedOnStartPnt = LEDOnStartPnt;
    GrnOnStartPnt = LEDOnStartPnt;
    BluOnStartPnt = LEDOnStartPnt;
    
    if oneStep(stepIndex).RedIntensity > 0       
        for index = 1:oneStep(stepIndex).RedIteration
            numPntOn = oneStep(stepIndex).RedPulsePeriod*oneStep(stepIndex).RedPulseNum;
            Yr(RedOnStartPnt:RedOnStartPnt+numPntOn-1) = ones(numPntOn,1).*powerR;
            RedOnStartPnt = RedOnStartPnt + numPntOn + oneStep(stepIndex).RedOffTime-1;
        end
    end
    
    if oneStep(stepIndex).GrnIntensity > 0
        for index = 1:oneStep(stepIndex).GrnIteration
            numPntOn = oneStep(stepIndex).GrnPulsePeriod*oneStep(stepIndex).GrnPulseNum;
            Yg(GrnOnStartPnt:GrnOnStartPnt+numPntOn-1) = ones(numPntOn,1).*powerG;
            GrnOnStartPnt = GrnOnStartPnt + numPntOn + oneStep(stepIndex).GrnOffTime-1;
        end
    end
    
    if oneStep(stepIndex).BluIntensity > 0
        for index = 1:oneStep(stepIndex).BluIteration
            numPntOn = oneStep(stepIndex).BluPulsePeriod*oneStep(stepIndex).BluPulseNum;
            Yb(BluOnStartPnt:BluOnStartPnt+numPntOn-1) = ones(numPntOn,1).*powerB;
            BluOnStartPnt = BluOnStartPnt + numPntOn + oneStep(stepIndex).BluOffTime-1;
        end
    end

    stepStartPnt = stepStartPnt + oneStep(stepIndex).Duration*1000;
end

%start to plot
handles.protocolRL = line(handles.protocol_axes,X,Yr+2,'color','r','LineStyle','-');

hold on
handles.protocolGL = line(handles.protocol_axes,X,Yg+1,'color','g','LineStyle','-');
grid on

hold on
handles.protocolBL = line(handles.protocol_axes,X,Yb,'color','b','LineStyle','-');
grid on

stepStartSec = 0;

%plot steps start and stop line
for stepIndex = 1:length(handles.protocol.stepNum) 
    %plot steps sstart and stop line
    stepStartSec = stepStartSec + oneStep(stepIndex).Duration;
    plot(handles.protocol_axes,[stepStartSec,stepStartSec], [0,3],'K', 'LineStyle','--');
end

legend off;
% legend('red light','green light','blue light','location','best');


%The animatedline was created after the cla statement
handles.expWL = animatedline(handles.protocol_axes,'color','g','Marker','.','LineStyle','none');
handles.expRL = animatedline(handles.protocol_axes,'color','r','Marker','.','LineStyle','none');
handles.expBL = animatedline(handles.protocol_axes,'color','b','Marker','.','LineStyle','none');

set(handles.run_exp, 'enable', 'on');

guidata(hObject, handles);

%% update the protocol to the controller

%remove all experiment steps
handles.hComm.LEDCtrl.removeAllExperimentSteps();

%add new experiment days
try
    for stepIndex = 1:length(handles.protocol.stepNum)
        totalSteps = handles.hComm.LEDCtrl.addOneStep(oneStep(stepIndex));
    end
    
    expData = handles.hComm.LEDCtrl.getExperimentSteps();
    disp(expData);
    
catch ME
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(end).name, ME.stack(end).line, ME.message);
    fprintf(1, '%s\n', errorMessage);
    uiwait(warndlg(errorMessage));
    set(handles.run_exp,'enable', 'off');
end


%% winopen(expFile);
%cd(oldPath);
guidata(hObject, handles);
end

% --- Executes on button press in run_exp.
function run_exp_Callback(hObject, eventdata, handles)
% hObject    handle to run_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of run_exp
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.flagAborted = 0;
    %disp(handles.expRun);
    handles.expRun = 1;
    guidata(hObject, handles);
    set(hObject,'String','ABORT');
    
    %stop update the temperature and humidity value
    if ~(handles.hComm.THSensor == 0)
        stop(handles.tTemp);
    end
    
    %clear points from the last experiment
    clearpoints(handles.expWL);
    clearpoints(handles.expRL);
    clearpoints(handles.expBL);
    
    %disable those inputs
    set(handles.IrInt, 'enable', 'off');
    set(handles.ChrInt, 'enable', 'off');
    set(handles.GrnInt, 'enable', 'off');
    set(handles.BluInt, 'enable', 'off');
    set(handles.select_led_protocol, 'enable', 'off');
    set(handles.select_handle_protocol, 'enable', 'off');
    set(handles.select_rear_protocol, 'enable', 'off');
    set(handles.select_exp_protocol, 'enable', 'off');
    set(handles.load_flies_btn1, 'enable', 'off');
    currentDate = datestr(now, 29);
    tempPath1 = [handles.expDataDir, '\', currentDate];
    if ~exist(tempPath1, 'dir')
        mkdir(tempPath1);
    end
    
    handles.tempPath1 = tempPath1;
    
    handles.expStartTime = datetime('now');
    
    %Input metadata
    for i = 1:1
        defaultsTree(i) = loadXMLDefaultsTree(handles.defaultMetaXmlFile{i});
        defaultsTree(i).setValueByUniquePath({'experiment','environment','IR_intensity'}, num2str(handles.IrIntValue));
        defaultsTree(i).setValueByUniquePath({'experiment','led_protocol'}, handles.ledProtocol);
        defaultsTree(i).setValueByUniquePath({'experiment','protocol'}, handles.expProtocol);
        defaultsTree(i).setValueByUniquePath({'experiment','session','flies','rearing','rearing_protocol'}, handles.rearProtocol);
        defaultsTree(i).setValueByUniquePath({'experiment','session','flies','handling','handling_protocol'}, handles.handleProtocol);
        defaultsTree(i).setValueByUniquePath({'experiment','session','apparatus','computer'}, getenv('COMPUTERNAME'));
        %cameraID = handles.hComm.flea3{i}.getCameraGuid();
        %defaultsTree(i).setValueByUniquePath({'experiment','session','apparatus','camera'},cameraID{1}.value);
        defaultsTree(i).setValueByUniquePath({'experiment','exp_datetime'},datestr(handles.expStartTime,30));
        defaultsTree(i).setValueByUniquePath({'experiment','session','flies','handling' 'seconds_fliesloaded'}, num2str(round(etime(datevec(handles.expStartTime),datevec(handles.loadFlyTime(i))))));
        defaultsTree(i).setValueByUniquePath({'experiment','session','flies','line'},...
            [defaultsTree(i).getValueByUniquePath({'experiment','session','flies','male_parent'}), '_',...
            defaultsTree(i).getValueByUniquePath({'experiment','session','flies','female_parent'})]);
        defaultsTree(i).setValueByUniquePath({'experiment','session','apparatus','apparatus_id'}, ...
            ['Rig', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','rig'}), '_',...
            'Plate', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','top_plate'}), '_',...
            'Bowl', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','bowl'}), '_',...
            'Camera', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','camera'}), '_',...
            'Computer', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','computer'}), '_',...
            'HardDrive', defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','harddrive'})]);
        
        if ~(handles.hComm.THSensor == 0)
            defaultsTree(i).setValueByUniquePath({'experiment','environment','temperature'}, get(handles.temp_val,'String'));
            defaultsTree(i).setValueByUniquePath({'experiment','environment','humidity'}, get(handles.hum_val,'string'));
        end
        
        handles.defaultsTree(i) = defaultsTree(i);
    end
    
    % Create figure in which to place JIDE property grid
    handles.figMetaData = figure( ...
        'MenuBar', 'none', ...
        'Name', 'Metadata Input GUI', ...
        'NumberTitle', 'off', ...
        'Toolbar', 'none', ...
        'Position', [1280 270 600 870],...
        'Units', 'pixels'...
        );
    
    set(handles.figMetaData, 'CloseRequestFcn',{@metaData_closereq, handles.figure1});
    
    tabgp = uitabgroup(handles.figMetaData,'Position',[0 0 1 1]);
    tab(1) = uitab(tabgp,'Title','flyBowl1');
    
    for i = 1:1
        % Create JIDE PropertyGrid and display defaults data in figure
        pgrid = PropertyGrid(tab(i),'Position', [0 0 1 1]);
        pgrid.setDefaultsTree(defaultsTree(i), 'advanced');
    end
    
    if ~isempty(handles.ledProtocol)
        set(handles.run_exp, 'enable', 'on');
    end
    
    %finish metadata input
    
    [pathstr, protocolName, ext]  = fileparts(handles.expFile);
    handles.protocolName = protocolName;
    
    % create an experiment timestamp file
    expTimeFile = [handles.defaultDir, '\expTimeStamp.txt'];
    handles.expTimeFile = expTimeFile;
    handles.expTimeFileID = fopen(expTimeFile, 'w+');
    
    for i = 1:1
        if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
            %cd(tempPath1);

            handles.defaultsTree(i).setValueByUniquePath({'experiment','exp_datetime'},datestr(handles.expStartTime,30));
            handles.defaultsTree(i).setValueByUniquePath({'experiment','session','flies','handling' 'seconds_fliesloaded'}, num2str(round(etime(datevec(handles.expStartTime),datevec(handles.loadFlyTime(i))))));
            enclosureNum = handles.defaultsTree(i).getValueByUniquePath({'experiment','session','apparatus','rig'});
            %                     fParent = metaData.children(2).attribute.(['female_parent']);
            %enclosureNum = metaData.children(2).attribute.('rig');
            drawnow;
            
            %create a temporary folder first because mParent and fParent
            %are unavailable yet.
            %             dataPath = [tempPath1, '\', datestr(handles.expStartTime,30), '_', 'rig', enclosureNum,...
            %                 '_','flyBowl', num2str(i),'_',  '_',mParent, '_', fParent,'_',protocolName];
            
            handles.enclosureNum{i} = enclosureNum;
            
            dataPath = [tempPath1, '\', datestr(handles.expStartTime,30), '_', 'rig', enclosureNum,...
                '_','flyBowl', num2str(i)];
            
            %     defaultPrefix = [mParentName, fParentName,'_', handles.rig, '_', protocolName, ...
            %         '_', handles.expStartTime];
            
            if ~exist(dataPath, 'dir')
                tempPath2 = dataPath;
                mkdir(tempPath2);
            end
            
            handles.(['expDataSubdir',num2str(i)]) = tempPath2;
            handles.protocolName = protocolName;
            %cd(oldPath)
            
            % save the protocol file
            protocolExcel = [handles.(['expDataSubdir',num2str(i)]),'\protocol.xlsx'];
            copyfile(get(handles.led_protocol_text,'String'), protocolExcel);
            % save led protocol as a mat file
            protocolMat = [handles.(['expDataSubdir',num2str(i)]),'\protocol.mat'];
            protocol = handles.protocol;
            save(protocolMat, 'protocol');
            
            %save the user setting file
            %     userSettingFile = [handles.expDataSubdir,  defaultPrefix,'userSetting.txt'];
            %     copyfile(get(handles.exp_setting,'String'), userSettingFile);
            
            %save the json file
            
            jsonFile = [handles.(['expDataSubdir',num2str(i)]), '\cameraSettings', num2str(i),'.json'];
            flyBowl_camera_control(handles.hComm.flea3{i},'saveconfig', jsonFile);
            
            
            %record movie
            
            flyBowl_camera_control(handles.hComm.flea3{i},'stop');
            %start recording
            %trialMovieName = [handles.(['expDataSubdir',num2str(i)]), '\movie',num2str(i),'.',handles.movieFormat];
            trialMovieName = [handles.(['expDataSubdir',num2str(i)]), '\movie.',handles.movieFormat];
            flyBowl_camera_control(handles.hComm.flea3{i},'start', trialMovieName);
            %fprintf(handles.expTimeFileID, '%.10f , start camera %d recording.\n', now, i);
        end
    end
    
    handles.tExp = timer('Period', handles.expPlotUpdateRate, 'ExecutionMode', 'fixedRate', 'TimerFcn',{@experiment, handles.figure1} );
    guidata(hObject, handles);
    
    handles.hComm.LEDCtrl.runExperiment();
    start(handles.tExp);

    
elseif button_state == get(hObject,'Min')
    handles.flagAborted = 1;    
    guidata(hObject, handles);
    handles = saveDataAfterAbortOrFinished(handles);
end
end


function experiment(src,evt,hFig)

handles = guidata(hFig);
if handles.expRun == 1
    
    status = handles.hComm.LEDCtrl.getExperimentStatus();
    %     state = stat.state;
    %     stepIndex = stat.experiment_step_index+1;
    %     sequenceIndex = stat.sequence_index+1;
    %     stepCount = stat.experiment_step_count;
    %     sequenceCount = stat.sequence_count;
    temp = textscan(status,'%f,%d,%f,%f,%f');
 
    time = temp{1}/1000;
    stepCount = temp{2};    
    rL = temp{3}/100;
    gL = temp{4}/100;
    bL = temp{5}/100;
    
    addpoints(handles.expWL,time, gL+1);
    addpoints(handles.expRL,time, rL+2);
    addpoints(handles.expBL,time, bL);
%     drawnow update;
% 
%     tic;
%     if ~(handles.hComm.THSensor == 0)
%         try
%             [temp,humid,~,~] = handles.hComm.THSensor.read(1);
%             set(handles.temp_val, 'String', num2str(temp));
%             set(handles.hum_val, 'String', num2str(humid));
%             if temp > handles.tempThreshold && ~ishandle(handles.hOverheatWarning)
%                 handles.hOverheatWarning = warndlg('Temp is too high, shut down all backlights!', 'Overheat Warn Dialog');
%                 handles.expRun = 0;
%                 handles.hComm.LEDCtrl.stopExperiment();
%                 handles.hComm.LEDCtrl.setVisibleBacklightsOff();
%                 handles.hComm.LEDCtrl.setIrBacklightsOff(0);
%                 set(handles.IrInt, 'Value', 0);
%                 set(handles.IrIntVal, 'String', [num2str(0) '%']);
%                 set(handles.ChrInt, 'Value', 0);
%                 set(handles.ChrIntVal, 'String', [num2str(0) '%']);
%                 set(handles.GrnInt, 'Value', 0);
%                 set(handles.GrnIntVal, 'String', [num2str(0) '%']);
%                 set(handles.BluInt, 'Value', 0);
%                 set(handles.BluIntVal, 'String', [num2str(0) '%']);
%     
%                 fprintf(handles.expTimeFileID, 'Temperature is higher than threshold. Shut down all back lights and stop experiments!\n');
%             end
%             fprintf(handles.expTimeFileID, '%s,%d,%.2f,%.2f\n', datestr(now,30), stepCount, temp, humid);
%         catch ME
%             disp(ME.message);
%         end
%     else
%         fprintf(handles.expTimeFileID, '%s,%d\n', datestr(now,30), stepCount);
%     end
%     toc;

    drawnow
    if time > handles.totalDuration
        handles.expRun = 0;
    end
    guidata(hFig, handles);

else  %experiment is done
    handles = saveDataAfterAbortOrFinished(handles);
    set(handles.run_exp,'Value',0);
    guidata(hFig, handles);
    beep;
end
end

function handles = saveDataAfterAbortOrFinished(handles)
%handles = guidata(hFig);
handles.hComm.LEDCtrl.stopExperiment();
stop(handles.tExp);
handles.expRun = 0;

%stop camera recording
for i = 1:1
    if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
        flyBowl_camera_control(handles.hComm.flea3{i},'stop');
    end
end

%set(handles.run_exp,'enable','off');

%% save data files
%save the meta data file
if ishandle(handles.expTimeFileID)
    fclose(handles.expTimeFileID);
end

%save the protocl imagef
F = getframe(handles.protocol_axes);
Image = frame2im(F);

for i = 1:1
    if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
        %hardcode to change the movie file name
        movieFileWithVer = [handles.(['expDataSubdir',num2str(i)]), '\movie*.', handles.movieFormat];
        defaultMovieFile = [handles.(['expDataSubdir',num2str(i)]), '\movie.',handles.movieFormat];
        
        D = dir(movieFileWithVer);
        if ~isempty(D)
            movieFileWithVer = fullfile(handles.(['expDataSubdir',num2str(i)]),D.name);
        end
        
        if exist(movieFileWithVer, 'file')
            movefile(movieFileWithVer, defaultMovieFile);
        end
        
        % save figure
        imageFile = [handles.(['expDataSubdir',num2str(i)]),'\expFigure.jpg'];
        imwrite(Image,imageFile);
        
        if handles.flagAborted == 1
            expTimeFile = [handles.(['expDataSubdir',num2str(i)]),'\ABORTED.txt'];
        else
            expTimeFile = [handles.(['expDataSubdir',num2str(i)]),'\expTimeStamp.txt'];
        end
        [success, message, ~] = copyfile(handles.expTimeFile, expTimeFile,'f');
    end
end

if ishandle(handles.figMetaData)
    figure(handles.figMetaData);
    % Block unit figure is destroyed
    
    remindMessage = sprintf('Experiment was either aborted or finished, please close metaData input GUI to save data.');
    fprintf(1, '%s\n', remindMessage);
    warndlg(remindMessage);
    
    uiwait(handles.figMetaData);
end

% for i = 1:1
%     if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
%         %save the meta data file
%         handles.defaultsTree(i).setValueByUniquePath({'experiment','flag_aborted','content'},num2str(handles.flagAborted));
%         mParent = handles.defaultsTree(i).getValueByUniquePath({'experiment','session','flies','male_parent'});
%         fParent = handles.defaultsTree(i).getValueByUniquePath({'experiment','session','flies','female_parent'});
%         handles.mParent{i} = mParent;
%         handles.fParent{i} = fParent;
%         metaData = createXMLMetaData(handles.defaultsTree(i));
%         % Save defaultsTree as xml file. Note, the current values for all the meta
%         % data are saved in the tree so that it is possible to have meata data whose
%         % default option is to use the last value used.
%         handles.defaultsTree(i).write(handles.defaultMetaXmlFile{i});
%         if isfield(handles, ['expDataSubdir',num2str(i)])
%             metaDataFile = [handles.(['expDataSubdir',num2str(i)]), '\metaData.xml'];
%             metaData.write(metaDataFile);
%         end
%     end
% end

myData = get(handles.figure1,'UserData');

%now we can rename the dataPath
for i = 1:1
    tempDataPath = [handles.tempPath1, '\', datestr(handles.expStartTime,30), '_', 'rig', handles.enclosureNum{i},...
        '_','flyBowl', num2str(i)];
    dataPath = [handles.tempPath1, '\', datestr(handles.expStartTime,30), '_', 'rig', handles.enclosureNum{i},...
        '_','flyBowl', num2str(i),'_',myData.mParent{i}, '_', myData.fParent{i},...
        '_',handles.protocolName];
    
    if exist(tempDataPath, 'dir')
        [status,message,~] = movefile(tempDataPath, dataPath,'f');
        if status == 0
            error(message);
        end
    end
end

%start camera previewing
for i = 1:1
    if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
        flyBowl_camera_control(handles.hComm.flea3{i},'preview');
        %fprintf(handles.expTimeFileID, '%.10f , stop camera %d recording.\n', now, i);
    end
end

%enable those inputs
set(handles.IrInt, 'enable', 'on');
set(handles.ChrInt, 'enable', 'on');
set(handles.GrnInt, 'enable', 'on');
set(handles.BluInt, 'enable', 'on');
set(handles.select_led_protocol, 'enable', 'on');
set(handles.select_handle_protocol, 'enable', 'on');
set(handles.select_rear_protocol, 'enable', 'on');
set(handles.select_exp_protocol, 'enable', 'on');
set(handles.load_flies_btn1, 'enable', 'on');
set(handles.run_exp,'String','Start Experiment');
set(handles.run_exp,'enable','on');
%guidata(handles.run_exp, handles);

%start update temp and humidity value
try
if ~(handles.hComm.THSensor == 0)
    start(handles.tTemp);
end
catch ME
    disp(ME);
end
end

function led_protocol_text_Callback(hObject, eventdata, handles)
% hObject    handle to led_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of led_protocol_text as text
%        str2double(get(hObject,'String')) returns contents of led_protocol_text as a double
end

% --- Executes during object creation, after setting all properties.
function led_protocol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to led_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function delay(sec)

% function pause the program
% ms = delay time in seconds
tic;
while toc < sec
end
end

function temp_val_Callback(hObject, eventdata, handles)
% hObject    handle to temp_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temp_val as text
%        str2double(get(hObject,'String')) returns contents of temp_val as a double
end

% --- Executes during object creation, after setting all properties.
function temp_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temp_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end



function hum_val_Callback(hObject, eventdata, handles)
% hObject    handle to hum_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hum_val as text
%        str2double(get(hObject,'String')) returns contents of hum_val as a double
end


% --- Executes during object creation, after setting all properties.
function hum_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hum_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on button press in load_flies_btn1.
function load_flies_btn1_Callback(hObject, eventdata, handles)
% hObject    handle to load_flies_btn1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.loadFlyTime(1) = datetime('now');
loadFlyTime = datestr(now,13);
set(handles.loadFlyTimeTxt1,'String', loadFlyTime);
guidata(hObject, handles);
end

function loadFlyTime_Callback(hObject, eventdata, handles)
% hObject    handle to loadFlyTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadFlyTime as text
%        str2double(get(hObject,'String')) returns contents of loadFlyTime as a double
end

% --- Executes during object creation, after setting all properties.
function loadFlyTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadFlyTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in select_exp_protocol.
function select_exp_protocol_Callback(hObject, eventdata, handles)
% hObject    handle to select_exp_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_exp_protocol
[filename, pathname] = uigetfile([handles.expProtocolDir, '*.xlsx'], 'Select an experiment protocol');
if isequal(filename,0)
    return
else
    expProtocol = fullfile(pathname, filename);
    set(handles.exp_protocol_text, 'string', expProtocol);
    handles.expProtocol = expProtocol;
end
guidata(hObject, handles);
end


% --- Executes on button press in select_rear_protocol.
function select_rear_protocol_Callback(hObject, eventdata, handles)
% hObject    handle to select_rear_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_rear_protocol

[filename, pathname] = uigetfile([handles.rearProtocolDir,'*.xlsx'], 'Select a rearing protocol');
if isequal(filename,0)
    return
else
    rearProtocol = fullfile(pathname, filename);
    set(handles.rear_protocol_text, 'string', rearProtocol);
    handles.rearProtocol = rearProtocol;
end
guidata(hObject, handles);
end


% --- Executes on button press in select_handle_protocol.
function select_handle_protocol_Callback(hObject, eventdata, handles)
% hObject    handle to select_handle_protocol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of select_handle_protocol
[filename, pathname] = uigetfile([handles.handleProtocolDir,'*.xlsx'], 'Select a handling protocol');
if isequal(filename,0)
    return
else
    handleProtocol = fullfile(pathname, filename);
    set(handles.handle_protocol_text, 'string', handleProtocol);
    handles.handleProtocol = handleProtocol;
end

guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function exp_protocol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exp_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes during object creation, after setting all properties.
function rear_protocol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rear_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


function handle_protocol_text_Callback(hObject, eventdata, handles)
% hObject    handle to handle_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of handle_protocol_text as text
%        str2double(get(hObject,'String')) returns contents of handle_protocol_text as a double
end

% --- Executes during object creation, after setting all properties.
function handle_protocol_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to handle_protocol_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end


% --- Executes on slider movement.
function GrnInt_Callback(hObject, eventdata, handles)
% hObject    handle to GrnInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

Grn_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
set(handles.GrnIntVal, 'String', [num2str(Grn_int_val) '%']);
handles.Grn_int_val = Grn_int_val;
%send command to controller
handles.hComm.LEDCtrl.setGreenLEDPower(Grn_int_val);
guidata(hObject, handles);

end

% --- Executes during object creation, after setting all properties.
function GrnInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GrnInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end

% --- Executes on slider movement.
function BluInt_Callback(hObject, eventdata, handles)
% hObject    handle to BluInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Blu_int_val = round(get(hObject,'Value')*100);   % this is done so only one dec place
handles.Blu_int_val = Blu_int_val;
set(handles.BluIntVal, 'String', [num2str(Blu_int_val), '%']);

%send command to controller
handles.hComm.LEDCtrl.setBlueLEDPower(Blu_int_val);
guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function BluInt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BluInt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end


% --- Executes on button press in LEDOnOff.
function LEDOnOff_Callback(hObject, eventdata, handles)
% hObject    handle to LEDOnOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LEDOnOff
button_state = get(hObject,'Value');
if button_state == get(hObject,'Max')
    handles.LEDON = 1;
    
    set(hObject,'String','Off');
    %This step is important because Set visible backlight commands needs
    %reset to turn off all quarants
    handles.hComm.LEDCtrl.setVisibleBacklightsOff();
    handles.hComm.LEDCtrl.setRedLEDPower(handles.Chr_int_val);
    handles.hComm.LEDCtrl.setGreenLEDPower(handles.Grn_int_val);
    handles.hComm.LEDCtrl.setBlueLEDPower(handles.Blu_int_val);    
    
%     handles.hComm.LEDCtrl.setRedLEDPower(handles.Chr_int_val, 0, handles.LEDPattern);
%     handles.hComm.LEDCtrl.setGreenLEDPower(handles.Grn_int_val, 0, handles.LEDPattern);
%     handles.hComm.LEDCtrl.setBlueLEDPower(handles.Blu_int_val, 0, handles.LEDPattern);
    handles.hComm.LEDCtrl.turnOnLED();
    
elseif button_state == get(hObject,'Min')
    handles.LEDON = 0;
    set(hObject,'String','On'); 
    
    handles.hComm.LEDCtrl.turnOffLED();
    
end
guidata(hObject, handles);
end

function metaData_closereq(src, eventdata, hFig)
handles = guidata(hFig);
for i = 1:1
    if ~(handles.hComm.flea3{i} == 0) && handles.hComm.flea3IsActive(i)
        %save the meta data file
        handles.defaultsTree(i).setValueByUniquePath({'experiment','flag_aborted','content'},num2str(handles.flagAborted));
        mParent = handles.defaultsTree(i).getValueByUniquePath({'experiment','session','flies','male_parent'});
        fParent = handles.defaultsTree(i).getValueByUniquePath({'experiment','session','flies','female_parent'});
        myData.mParent{i} = mParent;
        myData.fParent{i}  = fParent;
        metaData = createXMLMetaData(handles.defaultsTree(i));
        % Save defaultsTree as xml file. Note, the current values for all the meta
        % data are saved in the tree so that it is possible to have meata data whose
        % default option is to use the last value used.
        handles.defaultsTree(i).write(handles.defaultMetaXmlFile{i});
        if isfield(handles, ['expDataSubdir',num2str(i)])
            metaDataFile = [handles.(['expDataSubdir',num2str(i)]), '\metaData.xml'];
            metaData.write(metaDataFile);
        end
    end
end

set(hFig,'UserData',myData)
guidata(hFig,handles);
closereq;
end

