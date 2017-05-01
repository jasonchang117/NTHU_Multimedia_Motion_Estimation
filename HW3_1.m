function varargout = HW3_1(varargin)
% HW3_1 MATLAB code for HW3_1.fig
%      HW3_1, by itself, creates a new HW3_1 or raises the existing
%      singleton*.
%
%      H = HW3_1 returns the handle to a new HW3_1 or the handle to
%      the existing singleton*.
%
%      HW3_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HW3_1.M with the given input arguments.
%
%      HW3_1('Property','Value',...) creates a new HW3_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HW3_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HW3_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HW3_1

% Last Modified by GUIDE v2.5 29-Apr-2017 20:27:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HW3_1_OpeningFcn, ...
                   'gui_OutputFcn',  @HW3_1_OutputFcn, ...
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


% --- Executes just before HW3_1 is made visible.
function HW3_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HW3_1 (see VARARGIN)

% Choose default command line output for HW3_1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HW3_1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HW3_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clc;

ref_image = double(imread('data/frame72.jpg'));
if( strcmp(get(get(handles.search_method, 'SelectedObject'), 'Tag'), 'full_search') == 1 )
	method = 'full';
elseif( strcmp(get(get(handles.search_method, 'SelectedObject'), 'Tag'), 'logarithm') == 1 )
	method = 'logarithm';
end

if( strcmp(get(get(handles.block_size, 'SelectedObject'), 'Tag'), 'size_eight') == 1 )
	block_size = 8;
elseif( strcmp(get(get(handles.block_size, 'SelectedObject'), 'Tag'), 'size_sixteen') == 1 )
	block_size = 16;
end

if( strcmp(get(get(handles.search_range, 'SelectedObject'), 'Tag'), 'range_eight') == 1 )
	search_range = 8;
elseif( strcmp(get(get(handles.search_range, 'SelectedObject'), 'Tag'), 'range_sixteen') == 1 )
	search_range = 16;
end

T = zeros(320, 640, 3);
if( strcmp(get(get(handles.target_image, 'SelectedObject'), 'Tag'), 'frame_73') == 1 )
	T = double(imread('data/frame73.jpg'));
	frame = 'frame73';
elseif( strcmp(get(get(handles.target_image, 'SelectedObject'), 'Tag'), 'frame_81') == 1 )
	T = double(imread('data/frame81.jpg'));
	frame = 'frame81';
end

tic;
if( strcmp(method, 'full') == 1 )
    [out_SAD, SAD_array, output_image] = full_search(block_size, search_range, ref_image, T);
elseif(strcmp(method, 'logarithm') == 1)
    [out_SAD, SAD_array, output_image] = logarithm(block_size, search_range, ref_image, T);
end
t = toc;

temp = abs(T - output_image);
residual = zeros(320, 640);
for i = 1:320
	for j = 1:640
		residual(i, j) = temp(i, j, 1) + temp(i, j, 2) + temp(i, j, 3);
	end
end

%dlmwrite('test_2.txt', SAD_array);
path_1 = sprintf('output_image/problem_1/%s_%d_%d_%s_predicted.jpg', method, block_size, search_range, frame);
path_2 = sprintf('output_image/problem_1/%s_%d_%d_%s_residual.jpg', method, block_size, search_range, frame);
imwrite(uint8(output_image), path_1);
imwrite(uint8(residual), path_2)

axes(handles.axes1);
imshow( uint8(residual) );
% calculate PSNR
MSE = 0;
MSE = sum(sum(sum(( T-output_image ).^2)));
MSE = MSE/(320*640*3);
PSNR = 10*log10(255^2/MSE);

set(handles.total_sad, 'String', int32(out_SAD));
set(handles.psnr_value, 'String', PSNR);
set(handles.time, 'String', t);
