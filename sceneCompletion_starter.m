close all;
tic

%call to use .cpp into graph cut
%make

%load db folder
dbFolder = 'db_images';

%select test image number by changing the number from 1 to 6
test = 'test4';

%get input image + mask
inputImg = im2double(imread(strcat('images/img_mask/', test, '/' ,test ,'.jpg')));
inputMask = im2double(imread(strcat('images/img_mask/', test, '/' , test , '_mask.jpg')));

%compute GIST on db if not already done 
if exist('gistImgDB.mat','file')
    disp('gistImgDB.mat already exists. No need to recompute. File found will be used');
    gistImgDB = load('gistImgDB.mat');
    folderInfo = load('folderDBInfo.mat');
    colorDiffDB = load('colorDiffDB.mat');
else
    tic
    [gistImgDB, folderInfo] = gistCompute(dbFolder);
    toc
end

% colorDiffDB = colorDiff(dbFolder, gistImgDB, folderInfo);

%gistImgDB = colorCompute(dbFolder, gistImgDB, folderInfo, inputMask);

%create Masked Image
inputMaskedImg = applyMask(inputImg, inputMask);
imwrite(inputMaskedImg, strcat('images/maskedImage/masked', test , '.jpg'));

inputFolder = 'images/maskedImage/';

%compute GIST on input image
gistInput = gistComputeInput(inputMaskedImg);

%search for matching scene in db
numberMatchingScene = 10;
tic
sceneMatchingImg = sceneMatching(inputImg, gistInput, dbFolder, gistImgDB, colorDiffDB, folderInfo, numberMatchingScene);
toc 

%define local context = mask + 80 pixels radius of hole's boundary
tic
disp('Computing local context');
[localContext, borders] = computeLocalContext(inputImg, inputMask, test);
toc
imwrite(localContext, strcat('images/local_context/localContext', test, '.jpg'));

top = borders(1);
left = borders(3);

%for each matching scene, find best local patch and compute graph cut and blend
parfor i =6:numberMatchingScene
    
    disp([int2str(i) '/' int2str(numberMatchingScene) ' -- computing local matching --- Takes around 20-30 min for each image ---']);
    
    imgname = strcat(int2str(i), '_sceneMatching.jpg');
    imwrite(sceneMatchingImg{i}, strcat('images/matchedScene/' , test ,'/', imgname));
    
    %search for best patch in scene match 
    tic
    bestPatchInMatch = localMatching(sceneMatchingImg{i}, localContext);
    toc
    
    %get patch info
    fieldPatch = fieldnames(bestPatchInMatch);
    bestPatch = bestPatchInMatch.(fieldPatch{1});
    bestValid = bestPatchInMatch.(fieldPatch{2});
    bestScale = bestPatchInMatch.(fieldPatch{3});
    topPosition = bestPatchInMatch.(fieldPatch{4});
    leftPosition = bestPatchInMatch.(fieldPatch{5});
    
    if(bestValid == 1) %found a patch that fit with local context
        
        disp('We found a best patch');
        
        imgname = strcat(int2str(i), '_localMatching.jpg');
        imwrite(bestPatch, strcat('images/matchedLocal/', test, '/', imgname));
        
        %resize matching image to best scale
        matchResized = imresize(sceneMatchingImg{i}, bestScale);
        imgname = strcat(int2str(i), '_resizedSceneMatching.jpg');
        imwrite(matchResized, strcat('images/matchedScene/', test, '/', imgname));
        
        %resize best patch to match original image
        patchResized = zeros(size(inputMaskedImg,1), size(inputMaskedImg,2), 3);
        patchResized(top:size(bestPatch,1)+top-1,left:size(bestPatch,2)+left-1, 1:3) = bestPatch;
        imgname = strcat(int2str(i), '_resizedLocalMatching.jpg');
        imwrite(patchResized, strcat('images/matchedLocal/', test, '/', imgname));
        
        tic
        %cut grap cut to find best seam between path and original image
        disp('Computing best seam to cut');
        [cutPatch, cutMask] = graphCut(inputMaskedImg, inputMask, localContext, borders, bestPatch);
        imgname = strcat(int2str(i), '_cutMask.jpg');
        imwrite(cutMask, strcat('images/cutImg/', test, '/', imgname));
        imgname = strcat(int2str(i), '_cutPatch.jpg');
        imwrite(cutPatch, strcat('images/cutImg/', test, '/', imgname));
        toc
        
        tic
        %blend best patch to input image using mask from graph cut
        disp('Computing blending');
        finalImg = poissonBlend(patchResized, inputMaskedImg, cutMask);
        figure('Name','Final blended Image'), hold off, imagesc(finalImg), axis image
        imgname = strcat(int2str(i), '_finalBlended.jpg');
        imwrite(finalImg, strcat('images/output/', test, '/', imgname));
        toc
    else
        disp('no valid patch found in this matching scene');
    end 
end
toc



    

