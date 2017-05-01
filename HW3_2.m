function varargout = HW3_2(varargin)
% HW3_2 MATLAB code for HW3_2.fig
%      HW3_2, by itself, creates a new HW3_2 or raises the existing
%      singleton*.
%
%      H = HW3_2 returns the handle to a new HW3_2 or the handle to
%      the existing singleton*.
%
%      HW3_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HW3_2.M with the given input arguments.
%
%      HW3_2('Property','Value',...) creates a new HW3_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HW3_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HW3_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HW3_2

% Last Modified by GUIDE v2.5 29-Apr-2017 23:58:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HW3_2_OpeningFcn, ...
                   'gui_OutputFcn',  @HW3_2_OutputFcn, ...
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


% --- Executes just before HW3_2 is made visible.
function HW3_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HW3_2 (see VARARGIN)

% Choose default command line output for HW3_2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HW3_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HW3_2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

block_size = 8;
search_range = 8;

T = double(imread('data/frame81.jpg'));
tic;
ref_image = double(imread('data/frame72.jpg'));
[out_SAD_1, SAD_array, ref_prev_image] = logarithm(block_size, search_range, ref_image, T);

ref_image = double(imread('data/frame85.jpg'));
[out_SAD_2, SAD_array, ref_next_image] = logarithm(block_size, search_range, ref_image, T);

total_SAD = 0.0;
predicted = zeros(320, 640, 3);
for i = 1:block_size:320-block_size+1
	for j = 1:block_size:640-block_size+1
		sad_prev = sum(sum(sum(abs( T(i:i+block_size-1, j:j+block_size-1, :) - ref_prev_image(i:i+block_size-1, j:j+block_size-1, :) ))));
		sad_next = sum(sum(sum(abs( T(i:i+block_size-1, j:j+block_size-1, :) - ref_next_image(i:i+block_size-1, j:j+block_size-1, :) ))));
		
		if(sad_prev < sad_next)
			predicted(i:i+block_size-1, j:j+block_size-1, :) = ref_prev_image(i:i+block_size-1, j:j+block_size-1, :);
			total_SAD = total_SAD + sad_prev;
		else
			predicted(i:i+block_size-1, j:j+block_size-1, :) = ref_next_image(i:i+block_size-1, j:j+block_size-1, :);
			total_SAD = total_SAD + sad_next;
		end
	end
end
t = toc;

temp = abs(T - predicted);
residual = zeros(320, 640);
for i = 1:320
	for j = 1:640
		residual(i, j) = temp(i, j, 1) + temp(i, j, 2) + temp(i, j, 3);
	end
end

path_1 = sprintf('output_image/problem_2/logarithm_%d_%d_predicted.jpg', block_size, search_range);
path_2 = sprintf('output_image/problem_2/logarithm_%d_%d_residual.jpg', block_size, search_range);
imwrite(uint8(predicted), path_1);
imwrite(uint8(residual), path_2);
% calculate PSNR
MSE = 0;
MSE = sum(sum(sum(( T-predicted ).^2)));
MSE = MSE/(320*640*3);
PSNR = 10*log10(255^2/MSE);

axes(handles.axes1);
imshow( uint8(residual) );
set(handles.time, 'String', t);
set(handles.sad, 'String', int32(total_SAD));
set(handles.psnr, 'String', PSNR);
