%function numberImgSubSub = folderCompute(folder)

%get images in db folder
imageFolder = dir('db_images');
totalImages = 0;

%set folders_info (how many category, how many subforder, how many img per
%subfolder
numberSubFolders = length(imageFolder)-3
numberSubSubFolders = zeros(1, numberSubFolders);
numberImgSubSub = cell(1, numberSubFolders);

%loop through each subfolders
for k=4:length(imageFolder)
    currentImageSubFolder = imageFolder(k).name
   
    subFolder = dir(strcat('db_images/',currentImageSubFolder));
    numberImages = zeros(1,length(subFolder)-3);
    
    numberSubSubFolders(k-3) = length(subFolder)-3;
    
    %in each subfolders, get images
    for l=4:length(subFolder)
        currentImageSubSubFolder = subFolder(l).name
        images = dir(strcat('db_images/',currentImageSubFolder,'/',currentImageSubSubFolder,'/*.jpg'));
        numberImages(l-3) = length(images);
        totalImages = totalImages + numberImages(l-3)
        
        %keep track of number of images by subfolder
        numberImgSubSub{1,k-3} = numberImages;
    end 
end

totalImages

save('folderDBInfo.mat', 'numberImgSubSub');

%end
