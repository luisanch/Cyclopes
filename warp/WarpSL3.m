%===============================================================
%
% Copyright (C) 2010. All rights reserved.
%
% This sofware was developed at:
% CNRS/I3S
% 2000 Route des Lucioles
% 06903 Sophia Antipolis
%
% NAME: WarpSL3
% METHOD: Homographic warping of image points with normalisation
% PRE: Points to be warped, Homography.
% POSE: Return warped points in indexed vector form
% AUTHOR: Andrew Comport
%	CONTACT: comport@i3s.unice.fr
%
%===============================================================

function WarpedImage = WarpSL3(ReferenceImage, H);

global DEBUG_LEVEL_3;
if(DEBUG_LEVEL_3)
	disp('WarpSL3');
	keyboard;
end;

keyboard; % enter debug mode here - use dbquit to exit debug mode

%TODO : 
% 1. Warp patch coordinates (u, v, w);

% 2. Normalise coordinates so that w = 1; 

% 3. Check if the warped pixels fall inside the image and update indexes accordingly


% Stored in WarpedImage.P.U and WarpedImage.P.V which are images of size:
WarpedImage.P.U = zeros(size(ReferenceImage.I));
WarpedImage.P.V = zeros(size(ReferenceImage.I));

% Propagate and update Mask and indexes
WarpedImage.Mask = zeros(ReferenceImage.sIv,ReferenceImage.sIu);
WarpedImage.Mask(WarpedImage.index) = 1;

return
