function [totalGist, numberImgSubSub] = gistCompute(folder)

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

%get images in db folder
imageFolder = dir(folder);
totalImages = 0;
gistFolder = cell(1,length(imageFolder)-3);

%set folders_info (how many category, how many subforder, how many img per
%subfolder
numberSubFolders = length(imageFolder) - 3;
numberSubSubFolders = zeros(1, numberSubFolders);
numberImgSubSub = cell(1, numberSubFolders);

%loop through each subfolders
tic
parfor k=4:length(imageFolder)
    currentImageSubFolder = imageFolder(k).name;
   
    subFolder = dir(strcat(dbFolder,'/',currentImageSubFolder));
    numberImages = zeros(1,length(subFolder)-3);
    gistSubFolder = cell(1,length(subFolder)-3);
    
    numberSubSubFolders(k-3) = length(subFolder)-3;
    
    %in each subfolders, get images
    for l=4:length(subFolder)
        currentImageSubSubFolder = subFolder(l).name;
        images = dir(strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/*.jpg'));
        numberImages(l-3) = length(images);
        totalImages = totalImages + numberImages(l-3);

        allGist = zeros(numberImages(l-3), 3*gistFeatures);
        
        %loop through each image and compute the Gist
        for i = 1:numberImages(l-3)
            %disp([int2str(i) '/' int2str(numberImages(l-3))]);

            %create gist matrix for each image
            gistImg = zeros(1, 3*gistFeatures);
            imageName = strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/', images(i).name);
            img = im2double(imread(imageName));

            %convert sRGB to work in L*a*b* color space
            imgLab = applycform(img,cform);

            %compute gist for the 3 color channels
            for j = 1:3
                [gist,~] = LMgist(imgLab(:,:,j), '', param);
                gistImg(1, (gistFeatures*(j-1)+1 : gistFeatures*j)) = gist;
            end

            %add each image gist to total subfolder gist matrix
            allGist(i,:) = gistImg;
        end
        
        %add subfolder Gist into cell array
        gistSubFolder{1,l-3} = allGist;
        
        %keep track of number of images by subfolder
        numberImgSubSub{1,k-3} = numberImages;
    end
   
    %add all Gist together for each folder
    gistFolder{1,k-3} = gistSubFolder;
    
end
toc

totalImages

%loop through the total number of images to create a final Gist Matrix
totalGist = zeros(totalImages,3*gistFeatures);

i = 0;
for k=1:length(gistFolder)
    gistSubFolder = gistFolder{1,k};
    for l=1:length(gistSubFolder)
        allGist = gistSubFolder{1,l};
        for j=1:size(allGist,1)
            disp(j);
            i = i+1;
            totalGist(i,:) = allGist(j,:);
        end
    end
end



save('gistImg.mat', 'totalGist');
save('folderInfo.mat', 'numberImgSubSub');

end
