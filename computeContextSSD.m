function deltaE = computeContextSSD(localContext, matchPatch)

%Extract out the color bands from the original image into 3 separate 
%2D arrays, one for each color component
LChannel_img1 = localContext(:, :, 1); 
aChannel_img1 = localContext(:, :, 2); 
bChannel_img1 = localContext(:, :, 3);

LChannel_img2 = matchPatch(:, :, 1); 
aChannel_img2 = matchPatch(:, :, 2); 
bChannel_img2 = matchPatch(:, :, 3);

%Create the delta images: delta L, delta A, and delta B
deltaL = LChannel_img1 - LChannel_img2;
deltaa = aChannel_img1 - aChannel_img2;
deltab = bChannel_img1 - bChannel_img2;

%Create the Delta E image. This is an image that represents the color difference.
% Delta E is the square root of the sum of the squares of the delta images
%to get a unique number, do sum of sum
deltaE = sum(sum(sqrt(deltaL .^ 2 + deltaa .^ 2 + deltab .^ 2)));

end
