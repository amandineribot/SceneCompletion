function bestPatch = localMatching (selectedMatch, localContext)

[localRows, localCols, ~] = size(localContext);

%comparison with db results across all valid translations and 3 scales
%(.81, .90, 1) using pixel-wise SSD error in L*a*b color pace

%set up scaling of local context
scale = [0.81, 0.90, 1];
numberScale = size(scale,2);

% Color transform structure for sRGB->L*a*b*
cform = makecform('srgb2lab');
localContextLab = applycform(localContext,cform);

%set minimun SSD
minSSD = Inf;
bestPatch = struct('patch',zeros(localRows, localCols),'valid',0, 'scale',0,'topPxStart', 0, 'leftPxStart', 0);

%for each scaling
for j=1:numberScale
    
    disp([' -------------------- scale ' int2str(j) '--------------------']);
    
    match = imresize(selectedMatch, scale(1,j));
    matchLab = applycform(match,cform);
    [matchRows, matchCols, ~] = size(match);

    %set up sliding window of local context image into scaled matching scene
    for x=1:10:(matchRows-localRows)
        for y=1:10:(matchCols-localCols)
            
            %select patch same size of local context image
            matchPatch = matchLab(x:x+localRows-1, y:y+localCols-1, 1:3);
            matchPatchRgb = lab2rgb(matchPatch);

            %calculate SSD and texture between the patch and local context
            patchSSD = computeContextSSD(localContextLab, matchPatch);
            patchTextureSSD = computeTextureSSD(localContextLab, matchPatch);
            
            totalPatchSSD = patchSSD + patchTextureSSD;

            %chose translation and scale with min weighted SSD error
            if totalPatchSSD < minSSD
                minSSD = totalPatchSSD;
                bestPatch = struct('patch',matchPatchRgb,'valid',1, 'scale', scale(1,j), 'topPxStart', x, 'leftPxStart', y);
            end
        end
    end
end

%discourage distant match by multiplying the error at each placement by the
%magnitude of its translational offset

end