function gistImg = gistComputeInput(inputMaskedImg)

%this function use the code LMgist to compute the gist descriptor of each image
%LMgist code has be taken from Aude Oliva, Antonio Torralba, in their
%paper: "Modeling the shape of the scene: a holistic representation of the
%spatial envelope"
%the code is available here: http://people.csail.mit.edu/torralba/code/spatialenvelope/

% Color transform structure for sRGB->L*a*b*
cform = makecform('srgb2lab');

%Gist parameters
param.imageSize = 128;
param.orientationsPerScale = [8 8 8 8];
param.numberBlocks = 4;
param.fc_prefilt = 4;
gistFeatures = param.numberBlocks^2 * 4 * param.orientationsPerScale(1);


       
%create gist matrix for each image
gistImg = zeros(1, 3*gistFeatures);

%convert sRGB to work in L*a*b* color space
imgLab = applycform(inputMaskedImg,cform);

%compute gist for the 3 color channels
for j = 1:3
    [gist,~] = LMgist(imgLab(:,:,j), '', param);
    gistImg(1, (gistFeatures*(j-1)+1 : gistFeatures*j)) = gist;
end

% LChannel_img = imgLab(:, :, 1); 
% aChannel_img = imgLab(:, :, 2); 
% bChannel_img = imgLab(:, :, 3);
%   
% LChannel_img = imhist(LChannel_img, 256)'; 
% aChannel_img = imhist(aChannel_img, 256)';
% bChannel_img = imhist(bChannel_img, 256)';
% 
% colors = [LChannel_img, aChannel_img, bChannel_img];
% 
% 
% newGistImg = [gistImg, colors];
% size(newGistImg)

% save(strcat('newGist_',imgName,'.mat'), 'newGistImg');
save('gist_input.mat', 'gistImg');


end
