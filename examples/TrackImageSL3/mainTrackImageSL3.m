%===================================================================================
%
% Copyright (C) 2010. All rights reserved.
%
% This sofware was developed at:
% CNRS/I3S
% 2000 Route des Lucioles
% 06903 Sophia Antipolis
%
% NAME: mainTrackImageSL3 - homography planar tracking algorithm
%
% PRE:   
%   capture_params - 
%						structure containing necessary info for the incoming images 
%						data_dir - directory where images are stored (can use environment variable DIR_DATA)
%   				prefix - filename prefix (i.e. 'pgm')
%						suffix - filename suffix (i.e. 'ima')
%   				first - the first image number 
%   				last - the last image number 
% 					string_size - the number string size
%						loadpolygon - bool to choose to load polygon from disk,
%						savepolygon - bool to choose to save polygon to disk
%
%   tracking_param - structure  containing info for tracking
%   				max_iter - the maximum number of iterations in the estimation loop
%						max_err - the minimum error threshold in the estimation loop
%						display - boolean to switch tracking display on or off
%           mestimator - boolean to switch mestimator off or on
%						esm - boolean to swich Efficient Second order Minimisation 
%
% POST:
%   H(:,:,i)- A list of Homographies for each image i.
%
% AUTHORS: Andrew Comport
% DATE: 1/1/2010
%	CONTACT: comport@i3s.unice.fr
%
%====================================================================================

%
function [H, results] = mainTrackImageSL3(capture_params, tracking_param);

% Setup debugging variables
global DEBUG_LEVEL_1;
global DEBUG_LEVEL_2;
global DEBUG_LEVEL_3;
DEBUG_LEVEL_1 = 0;
DEBUG_LEVEL_2 = 0;
DEBUG_LEVEL_3 = 0;

if(nargin==0)
  disp('Launching test with default values...')
  test();
  return;
end;

if(DEBUG_LEVEL_1)
	disp('TrackSL3');
	keyboard;
end;

% Include project paths
addpath(sprintf('%s/include', capture_params.homedir));
include(capture_params.homedir);

close all;
% Initialse - read reference image and select zone to track
ReferenceImage = InitTrackImageSL3(capture_params);
close all;

if(tracking_param.display)
	scrsz = get(0,'ScreenSize');
	figure('Position',[scrsz(3)/4 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
	DrawImagePoly('Reference Image', 1, ReferenceImage.I, ReferenceImage.polygon);
end;

% Storing Params
norms_x = [];
iters_required = [];
computation_time = [];
iterator = [];

% Initialise Homography 
H(:,:,1) = eye(3,3);

% Homography index
i=1;
change_counter = tracking_param.change_every;
% Loop through sequence
for(k=capture_params.first+1:capture_params.last)
        tic;
	
		image_num_string = sprintf(['%0', num2str(capture_params.string_size), 'd'], k);
		file_I = [capture_params.data_dir, capture_params.prefix, image_num_string, capture_params.suffix];
		file_I_right = [capture_params.right_img_data_dir, capture_params.prefix, image_num_string, capture_params.suffix];

		% Read current image
        try
		    if(strcmp(capture_params.suffix, '.pgm'))
			    CurrentImage.I = imread(file_I);
			    CurrentImageRight.I = imread(file_I_right);
		    else
			    CurrentImage.Irgb = imread(file_I);
		      CurrentImage.I = rgb2gray(CurrentImage.Irgb);
		    end;
        catch
            continue
        end
		i = i+1;
        change_counter = change_counter - 1;

        if(tracking_param.changereference && change_counter == 0)
            Htrack = eye(3,3);
        else
            Htrack = H(:, :, i-1);
        end

        if(tracking_param.changereference && change_counter == 0) 
            ReferenceImage.I = CurrentImage.I;
            ReferenceImage.Irgb = CurrentImage.Irgb;
            ReferenceImage.polygon = WarpedImage.polygon;
            ReferenceImage.index = WarpedImage.index;
            ReferenceImage.Mask = WarpedImage.Mask;
            change_counter = tracking_param.change_every;
            keyboard
        end

		% Iterative non-linear homography estimation
        [H(:,:,i), WarpedImage, norm_x, iter_required] = TrackImageSL3(ReferenceImage, CurrentImage, Htrack, tracking_param);
		H(:,:,i);
	
		if(tracking_param.display)
			figure(1); hold on;	
			DrawImagePoly('Warped Current Image', 1, CurrentImage.I, WarpedImage.polygon);
            if(tracking_param.make_video)
                frame = getframe ;
                F(i-1) = frame;
            end
		end; 

        % Storing params
        iterator(i-1) = i-1;
        computation_time(i-1) = toc;
        norms_x(i-1) = norm_x;
        iters_required(i-1) = iter_required;

end;
if(tracking_param.make_video)
    make_video(F);
end

results = [iterator', computation_time', norms_x', iters_required'];

return;

% Attempt Assignment Questions
function Question4a(capture_params, tracking_params)
    % 1 = Reference Jacobian, 2 = Current Jacobian, 3 = ESM
    tracking_params.estimation_method = 1;
    [H, estimation_method_1_mestimator_0_robust_method_huber] = ...
                        mainTrackImageSL3(capture_params, tracking_params);
    
    tracking_params.estimation_method = 2;
    [H, estimation_method_2_mestimator_0_robust_method_huber] = ...
                        mainTrackImageSL3(capture_params, tracking_params);
    tracking_params.estimation_method = 3;
    [H, estimation_method_3_mestimator_0_robust_method_huber] = ...
                        mainTrackImageSL3(capture_params, tracking_params);
    
    % Plot
    data(:, :, 1) = estimation_method_1_mestimator_0_robust_method_huber;
    data(:, :, 2) = estimation_method_2_mestimator_0_robust_method_huber;
    data(:, :, 3) = estimation_method_3_mestimator_0_robust_method_huber;
    
    variables = {
        'number of images'
        'computation time (seconds)'
        'error'
        'iterations required per image'
        };
    legends = {'Reference Jacobian', 'Current Jacobian', 'ESM'};
    plot_results(data, 3, variables, legends);
return

function Question4b(capture_params, tracking_params)
    % 1 = Reference Jacobian, 2 = Current Jacobian, 3 = ESM
    tracking_params.estimation_method = 3;
    tracking_params.mestimator = 0;
    [H, estimation_method_3_mestimator_0_robust_method_huber] = ...
                        mainTrackImageSL3(capture_params, tracking_params);

    tracking_params.mestimator = 1;
    [H, estimation_method_3_mestimator_1_robust_method_huber] = ...
                        mainTrackImageSL3(capture_params, tracking_params);
    
    % Plot
    data(:, :, 1) = estimation_method_3_mestimator_0_robust_method_huber;
    data(:, :, 2) = estimation_method_3_mestimator_1_robust_method_huber;
    
    variables = {
        'number of images'
        'computation time (seconds)'
        'error'
        'iterations required per image'
        };
    legends = {'ESM without m-estimator', 'ESM with m-estimator'};
    plot_results(data, 2, variables, legends);

    
    tracking_params.estimation_method = 3;
    tracking_params.mestimator = 1;   
    tracking_params.robust_method='tukey';
    [H, estimation_method_3_mestimator_1_robust_method_tukey] = ...
                        mainTrackImageSL3(capture_params, tracking_params);

    % Plot
    data(:, :, 1) = estimation_method_3_mestimator_1_robust_method_huber;
    data(:, :, 2) = estimation_method_3_mestimator_1_robust_method_tukey;

    legends = {'ESM with huber method', 'ESM with tukey method'};
    plot_results(data, 2, variables, legends);
return

function Question7(capture_params, tracking_params)
    tracking_params.estimation_method = 3; 
    tracking_params.mestimator = 0;
    tracking_params.robust_method = 'huber';
    tracking_params.make_video = true;
    capture_params.first = 110;
    capture_params.last = 250;

    [H, results] =  mainTrackImageSL3(capture_params, tracking_params);
return

% Default test function if no values are given
function test()

tracking_params.max_iter = 45;
tracking_params.max_err = 400;
tracking_params.max_x = 1e-1;
tracking_params.display = 1;
tracking_params.estimation_method = 3; % 1 = Reference Jacobian, 2 = Current Jacobian, 3 = ESM 
tracking_params.mestimator = 0;
tracking_params.robust_method='huber'; % Can be 'huber' or 'tukey' for the moment
tracking_params.scale_threshold = 2; % 1 grey level
tracking_params.size_x = 8; % number of parameters to estimate
tracking_params.changereference = 1;
tracking_params.change_every = 5;
% Saving Results
tracking_params.make_video = false;

% Change for your paths here 
capture_params.who = 1; % 1 = Vipul, 2 = Lui+s
capture_params.capture_underwater_images = 0;

if (capture_params.who == 2)
    capture_params.homedir = 'C:\Users\Luiss\Documents\MATLAB\UTLN\Semester2\Vision\cyclopes';
    if(capture_params.capture_underwater_images)
        capture_params.data_dir = 'C:\Users\Luiss\Documents\MATLAB\UTLN\Semester2\Vision\IMAGES_smallRGB\';
    else
        capture_params.data_dir = 'C:\Users\Luiss\Documents\MATLAB\UTLN\Semester2\Vision\Versailles_canyon\Left\';
        capture_params.right_img_data_dir = 'C:\Users\Luiss\Documents\MATLAB\UTLN\Semester2\Vision\Versailles_canyon\Right\';
    end
elseif (capture_params.who == 1)
    capture_params.homedir = 'C:/Users/Vipul/Documents/MIR/Visual Slam/SLAM/cyclopes';
    if(capture_params.capture_underwater_images)
        capture_params.data_dir = 'C:/Users/Vipul/Documents/MIR/Visual Slam/SLAM/IMAGES_smallRGB/';
    else
        capture_params.data_dir = 'C:/Users/Vipul/Documents/MIR/Visual Slam/SLAM/Versailles_canyon/Left/';
        capture_params.right_img_data_dir = 'C:/Users/Vipul/Documents/MIR/Visual Slam/SLAM/Versailles_canyon/Right/';
    end
end

%capture_params.data_dir = [getenv('DIR_DATA'), '/../data/Versailles/Versailles_canyon/Left/']; 
%capture_params.homedir = getenv('DIR_CYCLOPES'); 
if(capture_params.capture_underwater_images)
capture_params.prefix = 'img'; %ima for Versailles_canyon and img for Underwater
capture_params.suffix = '.png'; % pgm for Versailles_canyon and png for Underwater
else
capture_params.prefix = 'ima'; %ima for Versailles_canyon and img for Underwater
capture_params.suffix = '.pgm'; % pgm for Versailles_canyon and png for Underwater
end
capture_params.string_size= 4;
capture_params.first = 50;
capture_params.last = 100;
capture_params.savepolygon = 1;
capture_params.loadpolygon = 0;

% Question4a(capture_params, tracking_params);
% Question4b(capture_params, tracking_params);
% Question7(capture_params, tracking_params);
% Question 6
[H, results] =  mainTrackImageSL3(capture_params, tracking_params);

return;
