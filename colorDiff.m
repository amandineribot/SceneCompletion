function colors = colorDiff (dbFolder, gistImgDB, folderInfo)

%get images in db folder
imageFolder = dir(dbFolder);

fieldGist = fieldnames(gistImgDB);
gImgDB = gistImgDB.(fieldGist{1});
totalImages = size(gImgDB,1);

fieldFolderInfo = fieldnames(folderInfo);
folderI = folderInfo.(fieldFolderInfo{1});

colors = zeros(totalImages, 3*256);
numberCategories = size(folderI,2);

% Color transform structure for sRGB->L*a*b*
cform = makecform('srgb2lab');
  
    %need to search for the right folder which contain the associated image
    totalImgPassed = 0;
    i = 1;
    for k=1:numberCategories
        for l=1:length(folderI{k})
            
            totalImgPassed = totalImgPassed +folderI{k}(l)
            
            currentImageSubFolder = imageFolder(k+3).name;
            subFolder = dir(strcat(dbFolder,'/',currentImageSubFolder));
            currentImageSubSubFolder = subFolder(l+3).name;
            images = dir(strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/*.jpg'));
                
            %find in which folder is image i
            while(i<=totalImgPassed)
               
                %Get color in the L*a*b color space
                imageIndexFolder = folderI{k}(l) - (totalImgPassed - i);
                currentImageName = images(imageIndexFolder).name; 
                
                currentImg = im2double(imread(strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/',currentImageName)));
                
                currentImg = imresize(currentImg, [192 256]);
                
                currentImgLab = applycform(currentImg,cform);
                
                LChannel_img = currentImgLab(:, :, 1); 
                aChannel_img = currentImgLab(:, :, 2); 
                bChannel_img = currentImgLab(:, :, 3);

                LChannel_img = mean(LChannel_img);
                aChannel_img = mean(aChannel_img);
                bChannel_img = mean(bChannel_img);
                                
                colors(i,1:end) = [LChannel_img aChannel_img bChannel_img];
                                               
                if mod(i,100) == 0
                    disp(['color Compute ' int2str(i) '/' int2str(totalImages) ' - - ']);
                end
                i = i+1;
            end
        end
    end
    
save('colorDiffDB.mat', 'colors');

end