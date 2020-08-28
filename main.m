function varargout = main(varargin)
% MAIN M-file for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 26-Sep-2010 21:58:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes(handles.maskfig);axis off;
axes(handles.omnifig);axis off;
axes(handles.timecourser);axis off;
axes(handles.symbchain);axis off;
axes(handles.templ_hist_graph);axis off;

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in omni_list.
function omni_list_Callback(hObject, eventdata, handles)
% hObject    handle to omni_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns omni_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from omni_list
    omni_type_contents = get(handles.omni_list,'String');
    omni_sel = omni_type_contents{get(handles.omni_list,'Value')};
    axes(handles.omnifig)
    if strcmp(omni_sel,'Mean')
        imagesc(handles.pix_mean);
    elseif strcmp(omni_sel,'STD')
        imagesc(handles.pix_std);
    elseif strcmp(omni_sel,'Ticks')
        imagesc(handles.pix_ticks);
    elseif strcmp(omni_sel,'Peaks')
        imagesc(handles.pix_peaks);
    end
    axis off;
    colorbar();

% --- Executes during object creation, after setting all properties.
function omni_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to omni_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pix_list.
function pix_list_Callback(hObject, eventdata, handles)
% hObject    handle to pix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pix_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pix_list
contents = get(hObject,'String');
selected = contents{get(hObject,'Value')};
for i=1:length(selected)
    if strcmp(selected(i),'_')
        row=str2num([selected(1:i-1)]);
        col=str2num([selected(i+1:end)]);
    end
end
signaloi = squeeze(handles.img_stack(:,row,col,:));
thigh = str2double(get(handles.thresh_high,'String'));
tlow = str2double(get(handles.thresh_low,'String'));
[ticks,times,htimes] = find_good_pixels_lax(signaloi,thigh);

axes(handles.timecourser);
cla;
plot(signaloi(:,2),'b'); hold all;
plot(signaloi(:,3),'r');plot(signaloi(:,4),'g');
plot(times,0,'ok');

sym = zeros(1,str2double(get(handles.t_size,'String')));
sym([times htimes]) = 1;
handles.curr_sym = sym;

guidata(hObject, handles);

%axes(handles.symbchain);
%cla;
%stem(sym);
symbols = handles.curr_sym;
breakout = get(handles.decode_wfig,'Value');



n_bins = str2num(get(handles.n_bins_text,'String'));

x_lim_on = get(handles.xlim_check,'Value');
x_lim = 0;
if x_lim_on
    x_lim = str2num(get(handles.hist_x_lim,'String'));
end

inter_dist = decode(symbols,0,n_bins,x_lim);
axes(handles.symbchain)
hist(inter_dist,n_bins);
if x_lim_on
    axis([0 x_lim 0 15]);
end



set(handles.curr_row,'String',int2str(row));
set(handles.curr_col,'String',int2str(col));

mask = handles.mask;
if mask(row,col) == 1
    set(handles.good_status,'String','This is a good pixel!');
else
    set(handles.good_status,'String','');
end


% --- Executes during object creation, after setting all properties.
function pix_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pix_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function filenamer_Callback(hObject, eventdata, handles)
% hObject    handle to filenamer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenamer as text
%        str2double(get(hObject,'String')) returns contents of filenamer as a double


% --- Executes during object creation, after setting all properties.
function filenamer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenamer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in convert.
function convert_Callback(hObject, eventdata, handles)
% hObject    handle to convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = get(handles.filenamer,'String');
res1 = str2double(get(handles.x_size,'String'));
res2 = str2double(get(handles.y_size,'String'));
times = str2double(get(handles.t_size,'String'));


fname = fname{1}
load_method = get(handles.alt_load_check,'Value');
if ~load_method
    img_stack = load_data(['data/' fname '.lsm'],times,res1,res2);
else
   channels = [504 523 542 562 581 600 620 639 659 715];
   for i=1:times
       if i-1 < 10
          tpt = ['000' int2str(i-1)]; 
       elseif i-1 < 100
           tpt = ['00' int2str(i-1)];
       elseif i-1 < 1000
           tpt = ['0' int2str(i-1)];
       else
           tpt = [int2str(i-1)];
       end
       for j=1:length(channels)
           imgf = ['data/' fname '_t' tpt '_l' int2str(channels(j)) '.tif']
          img_stack(i,:,:,j) = imread(imgf);
       end
   end
end
    fid = fopen(['data/' fname '_matlab.bin'],'w');
    fwrite(fid,img_stack,'uint16');
    fclose(fid);
returnvar = 1;


function x_size_Callback(hObject, eventdata, handles)
% hObject    handle to x_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_size as text
%        str2double(get(hObject,'String')) returns contents of x_size as a double


% --- Executes during object creation, after setting all properties.
function x_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_size_Callback(hObject, eventdata, handles)
% hObject    handle to y_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_size as text
%        str2double(get(hObject,'String')) returns contents of y_size as a double


% --- Executes during object creation, after setting all properties.
function y_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_size_Callback(hObject, eventdata, handles)
% hObject    handle to t_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_size as text
%        str2double(get(hObject,'String')) returns contents of t_size as a double


% --- Executes during object creation, after setting all properties.
function t_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in data_loader.
function data_loader_Callback(hObject, eventdata, handles)
% hObject    handle to data_loader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.mask = [];
    handles.img_stack = [];
    handles.pix_ticks = [];
    handles.pix_peaks = [];
    handles.pix_mean = [];
    handles.pix_std = [];
    
    guidata(hObject, handles);
    
    fil = get(handles.filenamer,'String');
    %fid = fopen(['data/' fil{1} '.bin']);
    fid = fopen(fil);
    img_stack = fread(fid,'*uint16');
    fclose(fid);

    times = str2double(get(handles.t_size,'String'));
    res = [str2double(get(handles.x_size,'String')) str2double(get(handles.y_size,'String'))];

    img_stack_p = reshape(img_stack,times,res(1),res(2),10); 

    high_t = str2double(get(handles.thresh_high,'String'));
    low_t = str2double(get(handles.thresh_low,'String'));
    peak_t = str2double(get(handles.peak_thresh,'String'));

    img_stack = zeros(times - 1, res(1),res(2),10);
    
    for i=1:res(1)
        for j=1:res(2)
            for k=1:10
                %Find min
                curr_min = min(img_stack_p(:,i,j,k));
                diff_sig = diff(double(img_stack_p(:,i,j,k)));
                img_stack(:,i,j,k) = diff_sig ./ double(curr_min);
                
                %curr_mean = mean(img_stack(:,i,j,k));
                %img_stack(:,i,j,k) = img_stack(:,i,j,k) - curr_mean;
            end
        end
    end

    for i=1:res(1)
        for j=1:res(2)
            signaloi = squeeze(img_stack(:,i,j,:));
            signal_1 = sum(signaloi(:,2:4),2);
            signal_2 = sum(signaloi(:,7:9),2);

            %Find avgs and means and put into mask
            pix_mean(i,j) = mean(signal_1);
            pix_std(i,j) = std(signal_1);

            %Pixel Checks
            [ticks, ~,htimes] = find_good_pixels_lax(signaloi,high_t);
            pix_ticks(i,j) = ticks;

            %Mask of peak #
%             [pts,ptimes] = find_peaks2(signal_1,peak_t,1);
%             pix_peaks(i,j) = pts;
        end
        disp(['Working on row...' int2str(i)]);
    end

    pix_thresh = str2double(get(handles.g_pix_thresh,'String'));
    good_pix = zeros(res(1)*res(2),1);
    good_pix(pix_ticks>pix_thresh) = 1;
    mask=reshape(good_pix,res(1),res(2));

    handles.mask = mask;
    handles.img_stack = img_stack;
    handles.pix_ticks = pix_ticks;
    %handles.pix_peaks = pix_peaks;
    handles.pix_mean = pix_mean;
    handles.pix_std = pix_std;

    disp(['Grid Mean: ' int2str(mean(pix_mean(:)))]);
    disp(['Grid STD: ' int2str(std(pix_mean(:)))]);
    disp(['Ticks Mean: ' int2str(mean(pix_ticks(:)))]);
    disp(['Ticks STD: ' int2str(std(pix_ticks(:)))]);
    %disp(['Peaks Mean: ' int2str(mean(pix_peaks(:)))]);
    %disp(['Peaks STD: ' int2str(std(pix_peaks(:)))]);
    
    guidata(hObject, handles);

    pix_lists = find(mask==1);
    glist2 = ceil(pix_lists/res(2));
    glist1 = mod(pix_lists,res(1));

    glist1(glist1==0) = 20;

    glist = [glist1,glist2];

    splist= {}
    for i=1:length(glist1)
       str = [num2str(glist(i,1)) '_' num2str(glist(i,2))];
       splist{i} = str;
    end

    set(handles.pix_list,'String',splist);


    axes(handles.maskfig)
    imagesc(handles.mask);
    axis on;

    omni_type_contents = get(handles.omni_list,'String');
    omni_sel = omni_type_contents{get(handles.omni_list,'Value')};
    axes(handles.omnifig)
    if strcmp(omni_sel,'Mean')
        imagesc(handles.pix_mean);
    elseif strcmp(omni_sel,'STD')
        imagesc(handles.pix_std);
    elseif strcmp(omni_sel,'Ticks')
        imagesc(handles.pix_ticks);
    elseif strcmp(omni_sel,'Peaks')
        imagesc(handles.pix_peaks);
    end
    axis off;
    colorbar();


% --- Executes on button press in submean.
function submean_Callback(hObject, eventdata, handles)
% hObject    handle to submean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of submean



function thresh_high_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_high as text
%        str2double(get(hObject,'String')) returns contents of thresh_high as a double


% --- Executes during object creation, after setting all properties.
function thresh_high_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_high (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thresh_low_Callback(hObject, eventdata, handles)
% hObject    handle to thresh_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresh_low as text
%        str2double(get(hObject,'String')) returns contents of thresh_low as a double


% --- Executes during object creation, after setting all properties.
function thresh_low_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresh_low (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function peak_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to peak_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peak_thresh as text
%        str2double(get(hObject,'String')) returns contents of peak_thresh as a double


% --- Executes during object creation, after setting all properties.
function peak_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function g_pix_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to g_pix_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of g_pix_thresh as text
%        str2double(get(hObject,'String')) returns contents of g_pix_thresh as a double


% --- Executes during object creation, after setting all properties.
function g_pix_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to g_pix_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in waveleter.
function waveleter_Callback(hObject, eventdata, handles)
% hObject    handle to waveleter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
row = str2double(get(handles.curr_row,'String'));
col = str2double(get(handles.curr_col,'String'));
summed_sig = squeeze(sum(handles.img_stack(:,row,col,:),4));
figure;wt=cwt(summed_sig,2:2:128,'db4','plot');


% --- Executes on button press in logwriter.
function logwriter_Callback(hObject, eventdata, handles)
% hObject    handle to logwriter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fname = get(handles.filenamer,'String');
ht = get(handles.thresh_high,'String');
lt = get(handles.thresh_low,'String');
pt = get(handles.peak_thresh,'String');
pix_t = get(handles.g_pix_thresh,'String');
pix_mask = handles.mask;
pix_mean = handles.pix_mean;
pix_std = handles.pix_std;
pix_ticks = handles.pix_ticks;
pix_peaks = handles.pix_peaks;
n_bins = str2double(get(handles.n_bins_text,'String'));

fname = fname{1};

dir = ['analysis/' fname '/'];
mkdir(dir);
log_file = [dir fname '_logfile.txt'];

f = figure('visible','off');
imagesc(pix_std);colorbar();
title(['STD for ' fname]);
%print(gcf,'-dpng',[dir fname '_std.png']);
print(f,'-dtiff','-r300',[dir fname '_std.tif']);
close;

f = figure('visible','off');
imagesc(pix_ticks);colorbar();
title(['Ticks for ' fname]);
%print(gcf,'-dpng',[dir fname '_ticks.png']);
print(f,'-dtiff','-r300',[dir fname '_ticks.tif']);
close;

f = figure('visible','off');
imagesc(pix_mask);
title(['Mask for ' fname]);
%print(gcf,'-dpng',[dir fname '_mask.png']);
print(f,'-dtiff','-r300',[dir fname '_mask.tif']);
close;

fid = fopen(log_file,'w');
fprintf(fid, 'Filename: %s\n', fname);
fprintf(fid, 'HighThresh: %s\n', ht);
fprintf(fid, 'LowThresh: %s\n', lt);
fprintf(fid, 'Peaks Thresh: %s\n', pt);
fprintf(fid, 'Good Pixel Thresh: %s\n', pix_t);
fprintf(fid, 'Grid Stats');
fprintf(fid, 'Grid Mean: %s\n', int2str(mean(pix_mean(:))));
fprintf(fid, 'Grid STD: %s\n', int2str(std(pix_mean(:))));
fprintf(fid, 'Ticks Mean: %s\n', int2str(mean(pix_ticks(:))));
fprintf(fid, 'Ticks STD: %s\n', int2str(std(pix_ticks(:))));
fprintf(fid, 'Peaks Mean: %s\n', int2str(mean(pix_peaks(:))));
fprintf(fid, 'Peaks STD: %s\n', int2str(std(pix_peaks(:))));


fclose(fid);

%Find Symbols for all
symbs = [];
res = [str2double(get(handles.x_size,'String')) str2double(get(handles.y_size,'String'))];
for i = 1:res(1)
    for j=1:res(2)
        if pix_mask(i,j) == 1
            signaloi = squeeze(handles.img_stack(:,i,j,:));
            [ticks, times, htimes] = find_good_pixels_lax(signaloi,str2double(ht),str2double(lt));
            sym = zeros(1,4000);
            sym([times htimes]) = 1;
            symbs = [symbs;sym];
            
            inter_dist = decode(sym,0,n_bins,0);
            f = figure('visible','off');
            hist(inter_dist,25);
            title(['Histogram of Inter-event time for pixel (' int2str(i) ',' int2str(j) ')']);
            
        end
    end
end
dlmwrite([dir fname '_symbols.txt'],symbs,' ');

%Print figures for all the good pixels
thigh = str2double(get(handles.thresh_high,'String'));
tlow = str2double(get(handles.thresh_low,'String'));
disp('Writing Pixel Figures');
[x,y] = find(pix_mask==1);
for i=1:length(x)
    f = figure('visible','off');
    signaloi = squeeze(handles.img_stack(:,x(i),y(i),:));
    
    [ticks,times,htimes] = find_good_pixels_lax(signaloi,thigh,tlow);
    plot(signaloi(:,2),'b'); hold all;
    plot(signaloi(:,3),'r');plot(signaloi(:,4),'g');
    plot(times,0,'ok');

    title(['Timecourse for ' fname ' at pixel ' int2str(x(i)) ',' int2str(y(i))]);
    print(f,'-dtiff','-r300',[dir fname '_' int2str(x(i)) 'y' int2str(y(i)) '_tc.tif']);
    close;
end
disp('Done Writing');





% --- Executes on button press in decoder.
function decoder_Callback(hObject, eventdata, handles)
% hObject    handle to decoder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
symbols = handles.curr_sym;
breakout = get(handles.decode_wfig,'Value');
n_bins = str2double(get(handles.n_bins_text,'String'));


x_lim_on = get(handles.xlim_check,'Value');
x_lim = 0;
if x_lim_on
    x_lim = str2num(get(handles.hist_x_lim,'String'));
end

[inter_dist,templ_dist] = decode(symbols,breakout,n_bins,x_lim);
axes(handles.symbchain)
hist(inter_dist,n_bins);
if x_lim_on
   axis([0 x_lim 0 15]); 
end

axes(handles.templ_hist_graph);
hist(templ_dist,n_bins);
title('Template Histogram');



% --- Executes on button press in recalc_button.
function recalc_button_Callback(hObject, eventdata, handles)
% hObject    handle to recalc_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    res = [str2double(get(handles.x_size,'String')) str2double(get(handles.y_size,'String'))];

    high_t = str2double(get(handles.thresh_high,'String'));
    low_t = str2double(get(handles.thresh_low,'String'));
    peak_t = str2double(get(handles.peak_thresh,'String'));
    pix_thresh = str2double(get(handles.g_pix_thresh,'String'));

    pix_ticks = handles.pix_ticks
    
    good_pix = zeros(res(1)*res(2),1);
    good_pix(pix_ticks>pix_thresh) = 1;
    mask=reshape(good_pix,res(1),res(2));
    handles.mask = mask;

    guidata(hObject, handles);

    pix_lists = find(mask==1);
    glist2 = ceil(pix_lists/res(2));
    glist1 = mod(pix_lists,res(1));

    glist1(glist1==0) = 20;

    glist = [glist1,glist2];

    splist= {}
    for i=1:length(glist1)
       str = [num2str(glist(i,1)) '_' num2str(glist(i,2))];
       splist{i} = str;
    end

    set(handles.pix_list,'String',splist);


    axes(handles.maskfig)
    imagesc(handles.mask);
    axis on;

    omni_type_contents = get(handles.omni_list,'String');
    omni_sel = omni_type_contents{get(handles.omni_list,'Value')};
    axes(handles.omnifig)
    if strcmp(omni_sel,'Mean')
        imagesc(handles.pix_mean);
    elseif strcmp(omni_sel,'STD')
        imagesc(handles.pix_std);
    elseif strcmp(omni_sel,'Ticks')
        imagesc(handles.pix_ticks);
    elseif strcmp(omni_sel,'Peaks')
        imagesc(handles.pix_peaks);
    end
    axis off;
    colorbar();
    
    set(handles.pix_list,'Value',1);


% --- Executes on button press in click_choose.
function click_choose_Callback(hObject, eventdata, handles)
% hObject    handle to click_choose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.maskfig)
x = 0;
y = 0;
iteration = 0;
while x <= 0.5 || y <= 0.5 || x >= 20.5 || y >= 20.5
    iteration = iteration + 1;
    if iteration ~= 1
        disp('Try again');
    end
    [x,y] = ginput(1);
end

disp(x);
disp(y);

row=round(y);
col=round(x);

mask = handles.mask;
if mask(row,col) == 1
    set(handles.good_status,'String','This is a good pixel!');
else
    set(handles.good_status,'String','');
end

signaloi = squeeze(handles.img_stack(:,row,col,:));
thigh = str2double(get(handles.thresh_high,'String'));
tlow = str2double(get(handles.thresh_low,'String'));
[ticks,times,htimes] = find_good_pixels_lax(signaloi,thigh);

axes(handles.timecourser);
cla;
plot(signaloi(:,2),'b'); hold all;
plot(signaloi(:,3),'r');plot(signaloi(:,4),'g');
if ~isempty(times)
    plot(times,0,'ok');
end

sym = zeros(1,str2double(get(handles.t_size,'String')));
sym([times htimes]) = 1;

handles.curr_sym = sym;
guidata(hObject, handles);

%axes(handles.symbchain);
%cla;
%stem(sym);
symbols = handles.curr_sym;
breakout = get(handles.decode_wfig,'Value');

x_lim_on = get(handles.xlim_check,'Value');
x_lim = 0;
if x_lim_on
    x_lim = str2num(get(handles.hist_x_lim,'String'));
end

n_bins = str2double(get(handles.n_bins_text,'String'));

inter_dist = decode(symbols,0,n_bins,x_lim);
axes(handles.symbchain)
hist(inter_dist,25);
if x_lim_on
   axis([0 x_lim 0 15]); 
end

set(handles.curr_row,'String',int2str(row));
set(handles.curr_col,'String',int2str(col));


% --- Executes on button press in file_open.
function file_open_Callback(hObject, eventdata, handles)
% hObject    handle to file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,path] = uigetfile('*','Choose the source BIN file');
if filename
    %parts = regexp(filename,'\.','split');
    set(handles.filenamer,'String',[path filename]);
    
end


% --- Executes on button press in open_figer.
function open_figer_Callback(hObject, eventdata, handles)
% hObject    handle to open_figer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
row = str2double(get(handles.curr_row,'String'));
col = str2double(get(handles.curr_col,'String'));

signaloi = squeeze(handles.img_stack(:,row,col,:));
thigh = str2double(get(handles.thresh_high,'String'));
tlow = str2double(get(handles.thresh_low,'String'));
[ticks,times,htimes] = find_good_pixels_lax(signaloi,thigh);

figure;subplot(2,1,1);
plot(signaloi(:,2),'b'); hold all;
plot(signaloi(:,3),'r');plot(signaloi(:,4),'g');

if ~isempty(times)
    plot(times,0,'ok');
end

title(['Detail for row: ' int2str(row) ' and col: ' int2str(col)]);
subplot(2,1,2);
plot(signaloi(:,7),'b'); hold all;
plot(signaloi(:,8),'r');plot(signaloi(:,9),'g');

if ~isempty(times)
    plot(times,0,'ok');
end


% --- Executes on button press in decode_wfig.
function decode_wfig_Callback(hObject, eventdata, handles)
% hObject    handle to decode_wfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of decode_wfig


% --- Executes on button press in templ_button.
function templ_button_Callback(hObject, eventdata, handles)
% hObject    handle to templ_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[throw,templ_dist] = decode(zeros(1,4),0);
n_bins = str2double(get(handles.n_bins_text,'String'));

axes(handles.templ_hist_graph)
hist(templ_dist,n_bins);

%times = str2double(get(handles.t_size,'String'));

templ_hits = zeros(1,200);
templ_hits(templ_dist) = 1;

figure;stem(templ_hits);figure('Hits for Ideal Template');



function n_bins_text_Callback(hObject, eventdata, handles)
% hObject    handle to n_bins_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of n_bins_text as text
%        str2double(get(hObject,'String')) returns contents of n_bins_text as a double


% --- Executes during object creation, after setting all properties.
function n_bins_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to n_bins_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xlim_check.
function xlim_check_Callback(hObject, eventdata, handles)
% hObject    handle to xlim_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xlim_check



function hist_x_lim_Callback(hObject, eventdata, handles)
% hObject    handle to hist_x_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hist_x_lim as text
%        str2double(get(hObject,'String')) returns contents of hist_x_lim as a double


% --- Executes during object creation, after setting all properties.
function hist_x_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hist_x_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in alt_load_check.
function alt_load_check_Callback(hObject, eventdata, handles)
% hObject    handle to alt_load_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of alt_load_check


% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% hObject    handle to process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     high_t = str2double(get(handles.thresh_high,'String'));
%     low_t = str2double(get(handles.thresh_low,'String'));
%     peak_t = str2double(get(handles.peak_thresh,'String'));
%     
%     img_stack = handles.img_stack;
%     
%     res = [str2double(get(handles.x_size,'String')) str2double(get(handles.y_size,'String'))];
%     
%     for i=1:res(1)
%         for j=1:res(2)
%             signaloi = squeeze(img_stack(:,i,j,:));
%             signal_1 = sum(signaloi(:,2:4),2);
%             signal_2 = sum(signaloi(:,7:9),2);
% 
%             %Pixel Checks
%             [ticks, times,htimes] = find_good_pixels_lax(signaloi,high_t,low_t);
%             pix_ticks(i,j) = ticks;
%         end
%         disp(['Working on row...' int2str(i)]);
%     end
% 
%     pix_thresh = str2double(get(handles.g_pix_thresh,'String'));
%     good_pix = zeros(res(1)*res(2),1);
%     good_pix(pix_ticks>pix_thresh) = 1;
%     mask=reshape(good_pix,res(1),res(2));
% 
%     handles.mask = mask;
%     handles.pix_ticks = pix_ticks;
%     
%     guidata(hObject, handles);
% 
%     pix_lists = find(mask==1);
%     glist2 = ceil(pix_lists/res(2));
%     glist1 = mod(pix_lists,res(1));
% 
%     glist1(glist1==0) = 20;
% 
%     glist = [glist1,glist2];
% 
%     splist= {}
%     for i=1:length(glist1)
%        str = [num2str(glist(i,1)) '_' num2str(glist(i,2))];
%        splist{i} = str;
%     end
% 
%     set(handles.pix_list,'String',splist);
% 
%     axes(handles.maskfig)
%     imagesc(handles.mask);
%     axis on;
% 
%     omni_type_contents = get(handles.omni_list,'String');
%     omni_sel = omni_type_contents{get(handles.omni_list,'Value')};
%     axes(handles.omnifig)
%     if strcmp(omni_sel,'Mean')
%         imagesc(handles.pix_mean);
%     elseif strcmp(omni_sel,'STD')
%         imagesc(handles.pix_std);
%     elseif strcmp(omni_sel,'Ticks')
%         imagesc(handles.pix_ticks);
%     elseif strcmp(omni_sel,'Peaks')
%         imagesc(handles.pix_peaks);
%     end
%     axis off;
%     colorbar();


% --- Executes on button press in tot_hist_button.
function tot_hist_button_Callback(hObject, eventdata, handles)
% hObject    handle to tot_hist_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pix_mask = handles.mask;
ht = get(handles.thresh_high,'String');
lt = get(handles.thresh_low,'String');

symbs = [];
[x y] = find(pix_mask==1);
for i=1:length(x)
    signaloi = squeeze(handles.img_stack(:,x(i),y(i),:));
    [ticks,times,htimes] = find_good_pixels_lax(signaloi,str2double(ht),str2double(lt));
    
    sym = zeros(1,4000);
    sym([times htimes]) = 1;
    symbs = [symbs; sym];
end

total_hist = find_inter(symbs);

total_array = [];
row_indexer = [];
for i=1:length(x)
   curr_array = total_hist{i};
   total_array = [total_array, curr_array];
   
   row_indexer = [row_indexer, i*ones(1,length(curr_array))];
end
%figure;scatter(row_indexer,total_array);
times = str2double(get(handles.t_size,'String'));

sum_interds = zeros(1,times);
sum_interds(total_array) = 1;

figure;stem(sum_interds);title('Stem of Ensemble Interdistance Hits');
figure;hist(total_array,25);title('Total Interdistance Hist');


