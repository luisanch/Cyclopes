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
% 	keyboard;
end;

% keyboard; % enter debug mode here - use dbquit to exit debug mode

%TODO : 
% 1. Warp patch coordinates (u, v, w);
u_ref = ReferenceImage.P.U(ReferenceImage.index);
v_ref = ReferenceImage.P.V(ReferenceImage.index);
w_ref = ones(size(ReferenceImage.index));

ref_img = [u_ref, v_ref, w_ref]';
u = H(1,:)*ref_img;
v = H(2,:)*ref_img;
w = H(3,:)*ref_img;

% 2. Normalise coordinates so that w = 1; 
u = u./w;
v = v./w;


% 3. Check if the warped pixels fall inside the image and update indexes accordingly
WarpedImage.visibility_index = find(u < ReferenceImage.sIu + 1 & u > 1 & v < ReferenceImage.sIv + 1 & v > 1)';
% WarpedImage.index represents the common region shared by the reference
% image and the warped image. Visibility Index corresponds to thode pixels
% that lies inside the image. If pixel corresponding to RefImg.index(1) 
% lies outside of the img after wraping, then the visibility_index won't
% contain 1

WarpedImage.index = ReferenceImage.index(WarpedImage.visibility_index);

% Stored in WarpedImage.P.U and WarpedImage.P.V which are images of size:
WarpedImage.P.U = zeros(size(ReferenceImage.I));
WarpedImage.P.V = zeros(size(ReferenceImage.I));
WarpedImage.P.U(WarpedImage.index) = u(WarpedImage.visibility_index);
WarpedImage.P.V(WarpedImage.index) = v(WarpedImage.visibility_index);
% Propagate and update Mask and indexes
WarpedImage.Mask = zeros(ReferenceImage.sIv,ReferenceImage.sIu);
WarpedImage.Mask(WarpedImage.index) = 1;
return
