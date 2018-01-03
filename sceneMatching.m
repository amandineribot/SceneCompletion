function [matchingImg] = sceneMatching(inputImg, gistInput, dbFolder, gistImgDB, colorDiffDB, folderInfo, numberMatchingScene)

%get images in db folder
imageFolder = dir(dbFolder);

%get .mat files informations
fieldGist = fieldnames(gistImgDB);
gImgDB = gistImgDB.(fieldGist{1});
totalImages = size(gImgDB,1);

fieldFolderInfo = fieldnames(folderInfo);
folderI = folderInfo.(fieldFolderInfo{1});

fieldColorDiff = fieldnames(colorDiffDB);
colorDiff = colorDiffDB.(fieldColorDiff{1});

difference = zeros(totalImages, 1);
numberCategories = size(folderI,2);

%get colors information in L*a*b* space for the input image
inputImg = imresize(inputImg, [192 256]);
cform = makecform('srgb2lab');
inputImgLab = applycform(inputImg,cform);

LChannel_inputImg = inputImgLab(:, :, 1); 
aChannel_inputImg = inputImgLab(:, :, 2); 
bChannel_inputImg = inputImgLab(:, :, 3);

LChannel_inputImg = mean(LChannel_inputImg); 
aChannel_inputImg = mean(aChannel_inputImg); 
bChannel_inputImg = mean(bChannel_inputImg);
                                
tic

% size(gImgDB)
% size(gistInput)
% [index] = knnsearch(gImgDB, gistInput, 'k', numberMatchingScene);
% size(index)

    %need to loop through each images in database
    totalImgPassed = 0;
    i = 1;
    for k=1:numberCategories
        for l=1:length(folderI{k})
            
            totalImgPassed = totalImgPassed +folderI{k}(l);
           
            while i<=totalImgPassed
             
                %Compute color difference in the L*a*b color space
                currentImgGist = gImgDB(i,:);
                currentColorDiffL = colorDiff(i,1:256);
                currentColorDiffa = colorDiff(i,257:512);
                currentColorDiffb = colorDiff(i,513:768);
                
                deltaL = LChannel_inputImg - currentColorDiffL;
                deltaa = aChannel_inputImg - currentColorDiffa;
                deltab = bChannel_inputImg - currentColorDiffb;
                
                currentColorDiff = sum(sum(sqrt(deltaL .^ 2 + deltaa .^ 2 + deltab .^ 2))) / (192*256);
                
                %set up to calculate SSD between GIST of input and GIST of every images in db weighted by mask
                gistSSD = computeGistSSD(gistInput, currentImgGist);
    
                %Difference = weighted gist contributes twice as much as color info
                difference(i) = 2*gistSSD + currentColorDiff;                

                if mod(i,1000) == 0
                    disp(['sceneMatch ' int2str(i) '/' int2str(totalImages)]);
                    %disp(['colorDiff ' int2str(currentColorDiff) ' - gistSSD ' int2str(gistSSD)]);
                end
                i = i+1;
            end
        end
    end
toc 

tic
[bestMatch index] = sort(difference);
toc
matchingImg = cell(1:numberMatchingScene);

%find locations in folders of top x images
for top = 1:numberMatchingScene
    
    j = index(top);
    
    flag = 0;
    totalImgPassed = 0;
    for k=1:numberCategories
        for l=1:length(folderI{k})
            
            totalImgPassed = totalImgPassed +folderI{k}(l);
           
            %find in which folder is image j
            if(j<=totalImgPassed)
                
                currentImageSubFolder = imageFolder(k+3).name;
                subFolder = dir(strcat(dbFolder,'/',currentImageSubFolder));
                currentImageSubSubFolder = subFolder(l+3).name;
                images = dir(strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/*.jpg'));
                
                imageIndexFolder = folderI{k}(l) - (totalImgPassed - j);
                currentImageName = images(imageIndexFolder).name;
                currentImg = im2double(imread(strcat(dbFolder,'/',currentImageSubFolder,'/',currentImageSubSubFolder,'/',currentImageName)));
                
                %add image to list of matching scene
                matchingImg{top} = currentImg;
                
                flag = 1;
                break;
            end
        end
        
        if flag == 1
                break;
        end
    end
end

end