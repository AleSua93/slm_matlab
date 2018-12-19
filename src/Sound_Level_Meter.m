function varargout = Sound_Level_Meter(varargin)
% SOUND_LEVEL_METER MATLAB code for Sound_Level_Meter.fig
%      Sound Level Meter application for Matlab.
%      Given an audio file and a reference file (at 94 dBSPL), it calculates
%      the equivalent Sound Pressure Level (Leq) for each third-octave
%      frequency band (from 20 to 20kHz). It also plots the resulting
%      spectrum, as well as the temporal evolution of the signal in terms
%      of sound level (Logger). It also plots both signals.
%      It allows for calculations to be performed applying A, C, and Z
%      frequency weightings, as well as Slow (1s), fast (125ms), and
%      impulse (35ms) integration times. 
%      Results can be exported, and upon doing so they will appear in
%      Values.xlsx

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Sound_Level_Meter_OpeningFcn, ...
                   'gui_OutputFcn',  @Sound_Level_Meter_OutputFcn, ...
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


% --- Executes just before Sound_Level_Meter is made visible.
function Sound_Level_Meter_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for Sound_Level_Meter
handles.output = hObject;

% Cargamos los filtros y definimos constantes
[handles.filterBank, handles.centralFrequencies] = thirdoctavefilters();
centralFrequenciesRound = round(handles.centralFrequencies, 1);
centralFrequenciesRound = strtrim(cellstr(num2str(centralFrequenciesRound'))');
handles.centralFrequenciesRound = ...
    horzcat(centralFrequenciesRound, 'TOTAL');
handles.referencePressure = 20 * 10^(-6);

% Flags
handles.audio_loaded = 0;
handles.calibration_loaded = 0;
handles.leqsCalculated = 0;

% Listbox
set(handles.listbox_bands, 'String', ...
    handles.centralFrequenciesRound);

% Seteamos en fast por defecto
handles.int_time = 0.125;

% Ponderación A por defecto
handles.weighting = 'A';


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Sound_Level_Meter wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = Sound_Level_Meter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_load_audio.
function button_load_audio_Callback(hObject, eventdata, handles)
% hObject    handle to button_load_audio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName, path] = ...
    uigetfile('*.wav','Select audio file');

filePath = sprintf('%s%s', path, fileName);

if isequal(fileName,0)
        return;
end

[handles.audio, handles.audio_fs] = audioread(filePath);

set(handles.text_audio_loaded, 'String', sprintf('%s loaded!', fileName))

plotaudio(handles.axes_audio, handles.audio, handles.audio_fs, fileName);

handles.audio_loaded = 1;

guidata(hObject, handles)


% --- Executes on button press in button_load_calibration.
function button_load_calibration_Callback(hObject, eventdata, handles)

[fileName, path] = ...
    uigetfile('*.wav','Select a calibration reference audio');

filePath = sprintf('%s%s', path, fileName);

if isequal(fileName,0)
        return;
end

[handles.audioCal, fs_cal] = audioread(filePath);

set(handles.text_calibration_loaded, 'String', ...
    sprintf('%s loaded!', fileName))

plotaudio(handles.axes_cal, handles.audioCal, fs_cal, fileName);

handles.calibration_loaded = 1;

guidata(hObject, handles)


% --- Executes on button press in button_calculate.
function button_calculate_Callback(hObject, eventdata, handles)

if (handles.audio_loaded && handles.calibration_loaded)
    
    set(handles.axes_levels, 'Visible', 'on')
    set(handles.axes_bands, 'Visible', 'on')
    
    [handles.splValues, handles.leqs, ...
        handles.globalLeq, handles.sampleStep] = ...
        getvalues(handles.audio, handles.audioCal, ...
        handles.audio_fs, handles.int_time, handles.filterBank, ...
        handles.weighting);
    
    handles.leqsCalculated = 1;
        
    plotlevels(handles.axes_levels, handles.audio_fs, ...
        handles.splValues(:, handles.centralFrequencyIndex), ...
        handles.sampleStep, length(handles.audio)) 
    
    plotbands(handles.axes_bands, handles.leqs, ...
        handles.centralFrequencies, handles.centralFrequencyIndex)
    
    if handles.centralFrequencyIndex == 31
        set(handles.text_band_leq_value, 'String', sprintf('%.2f dB%c', ...
        handles.globalLeq, handles.weighting));
    else
        set(handles.text_band_leq_value, 'String', sprintf('%.2f dB%c', ...
        handles.leqs(handles.centralFrequencyIndex), handles.weighting))
    end
    set(handles.text_band_leq_max_value, 'String', sprintf('%.2f dB%c', ...
        max(handles.splValues(:, handles.centralFrequencyIndex)), ...
        handles.weighting))
    set(handles.text_band_leq_min_value, 'String', sprintf('%.2f dB%c', ...
        min(handles.splValues(:, handles.centralFrequencyIndex)), ...
        handles.weighting))
    
else
    warndlg('Audios missing!')
    return
end

guidata(hObject, handles)


% --- Executes on selection change in listbox_bands.
function listbox_bands_Callback(hObject, eventdata, handles)

if (handles.audio_loaded && handles.calibration_loaded)

    handles.centralFrequencyIndex = get(hObject,'Value');

    plotlevels(handles.axes_levels, handles.audio_fs, ...
            handles.splValues(:, handles.centralFrequencyIndex), ...
            handles.sampleStep)
        
    plotbands(handles.axes_bands, handles.leqs, ...
        handles.centralFrequencies, handles.centralFrequencyIndex)
        
    if handles.centralFrequencyIndex == 31
        set(handles.text_band_leq_value, 'String', sprintf('%.2f dB%c', ...
        handles.globalLeq, handles.weighting));
    else
        set(handles.text_band_leq_value, 'String', sprintf('%.2f dB%c', ...
        handles.leqs(handles.centralFrequencyIndex), handles.weighting))
    end
    set(handles.text_band_leq_max_value, 'String', sprintf('%.2f dB%c', ...
        max(handles.splValues(:, handles.centralFrequencyIndex)), ...
        handles.weighting))
    set(handles.text_band_leq_min_value, 'String', sprintf('%.2f dB%c', ...
        min(handles.splValues(:, handles.centralFrequencyIndex)), ...
        handles.weighting))

    guidata(hObject, handles)

end

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_bands contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_bands


% --- Executes during object creation, after setting all properties.
function listbox_bands_CreateFcn(hObject, ~, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

handles.centralFrequencyIndex = get(hObject,'Value');

guidata(hObject, handles)


% --- Executes on button press in radio_fast.
function radio_fast_Callback(hObject, ~, handles)

set(handles.radio_slow, 'Value', 0)
set(handles.radio_impulse, 'Value', 0)

handles.int_time = 0.125;

guidata(hObject, handles)

% --- Executes on button press in radio_slow.
function radio_slow_Callback(hObject, eventdata, handles)

set(handles.radio_fast, 'Value', 0)
set(handles.radio_impulse, 'Value', 0)

handles.int_time = 1;

guidata(hObject, handles)

% Hint: get(hObject,'Value') returns toggle state of radio_slow


% --- Executes on button press in radio_impulse.
function radio_impulse_Callback(hObject, eventdata, handles)

set(handles.radio_slow, 'Value', 0)
set(handles.radio_fast, 'Value', 0)

handles.int_time = 0.035;

guidata(hObject, handles)

% Hint: get(hObject,'Value') returns toggle state of radio_impulse


% --- Executes on button press in radio_A.
function radio_A_Callback(hObject, eventdata, handles)

set(handles.radio_C, 'Value', 0)
set(handles.radio_Z, 'Value', 0)

handles.weighting = 'A';

guidata(hObject, handles)

% Hint: get(hObject,'Value') returns toggle state of radio_A


% --- Executes on button press in radio_C.
function radio_C_Callback(hObject, eventdata, handles)

set(handles.radio_A, 'Value', 0)
set(handles.radio_Z, 'Value', 0)

handles.weighting = 'C';

guidata(hObject, handles)

% --- Executes on button press in radio_Z.
function radio_Z_Callback(hObject, eventdata, handles)

set(handles.radio_A, 'Value', 0)
set(handles.radio_C, 'Value', 0)

handles.weighting = 'Z';

guidata(hObject, handles)

% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)

if (handles.leqsCalculated)
    xlswrite('Values.xlsx', handles.leqs', 'D7:D36');
    xlswrite('Values.xlsx', handles.globalLeq, 'D37:D37');
    xlswrite('Values.xlsx', handles.weighting, 'D38:D38');
    % splValues(time, frequency)
    %xlswrite('Valores.xlsx', handles.splValues)
    warndlg('Data exported!')
else
    warndlg('Nothing to export!')
    return
end
