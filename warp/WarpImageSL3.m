% ========================================================
%
% Copyright (C) 2010. All rights reserved.
%
% This sofware was developed at:
% CNRS/I3S
% 2000 Route des Lucioles
% 06903 Sophia Antipolis
%
% NAME: WarpImageSL3
% METHOD: Warp points and interpolate new image coordinates
% PRE: Current Image, Image index and Homography
% POST: Warped image corresponding to index locations, 
%				new Mask and indexes
% AUTHOR: Andrew Comport
% DATE: 01/01/2010
%	CONTACT: comport@i3s.unice.fr
%
%==========================================================


function WarpedImage = WarpImageSL3(CurrentImage, ReferenceImage, H); 

global DEBUG_LEVEL_3;
if(DEBUG_LEVEL_3)
	disp('WarpImageSL3');
	keyboard;
end;

% Warp reference 
WarpedImage = WarpSL3(ReferenceImage, H);
% Bilinear interpolation of image
WarpedImage.I = zeros(ReferenceImage.sIv, ReferenceImage.sIu);
WarpedImage.I(WarpedImage.index) = interp2(double(CurrentImage.I), WarpedImage.P.U(WarpedImage.index), WarpedImage.P.V(WarpedImage.index), 'linear');

%Remove Border Pixels where gradient can't be determined
BoundaryMask = bwperim(WarpedImage.Mask, 4);
WarpedImage.Mask(find(BoundaryMask)) = 0;
WarpedImage.index = find(WarpedImage.Mask);

%[commun_elements, border_index, dummy] = setxor(ReferenceImage.index, find(BoundaryMask));
%WarpedImage.visibility_index = intersect(WarpedImage.visibility_index, border_index);

if(DEBUG_LEVEL_3)
	imagesc(WarpedImage.I - double(ReferenceImage.I)); 
	imagesc(WarpedImage.Mask);
	colormap(gray);
end;

return
