function [sparseAMatrix, sparseTMatrix] = computeAdjMatrix(inputMaskedImg, localContext, borders, inputMask, bestPatch) 

[rows, cols, ~] = size(localContext);
contextMap = zeros(rows, cols);
nberPx = 0;

propMask = regionprops(inputMask,'centroid');
centroidsMask = cat(1, propMask.Centroid);

%create mapping of px on patch
for i=1:rows
    for j=1:cols
        nberPx = nberPx + 1;
        contextMap(i,j) = nberPx;
    end
end

%create vectors for sparse matrix A with weight
rowsV = zeros(nberPx*4,1);
colsV = zeros(nberPx*4,1);
weightV = zeros(nberPx*4,1);

%create vectors for sparse matrix T for labels
rowsT = zeros(nberPx,1);
colsT = zeros(nberPx,1);
weightT = zeros(nberPx,1);

% Color transform structure for sRGB->L*a*b*
cform = makecform('srgb2lab');
imgInputMaskedLab = applycform(inputMaskedImg,cform);
imgPatchLab = applycform(bestPatch,cform);

%loop through each px in patch
pxLookedAt = 0;
for i=1:rows
    for j=1:cols
        pxLookedAt = pxLookedAt +1;
        
        % inputMaskedImg(i+borders(1)-1, j+borders(3)-1) == 0   ||  inputMask(i+borders(1)-1, j+borders(3)-1) ~= 0
        
        if  inputMask(i+borders(1)-1, j+borders(3)-1) ~= 0   %if pixel in hole area
            
            rowsT(pxLookedAt) = contextMap(i,j);
            colsT(pxLookedAt) = 2;
            weightT(pxLookedAt) = Inf;
            
            rowsV(pxLookedAt*4 - 3) = contextMap(i,j);
            colsV(pxLookedAt*4 - 3) = contextMap(i,j);
            weightV(pxLookedAt*4 - 3) = Inf;
            
        elseif  inputMaskedImg(i+borders(1)-1,j+borders(3)-1) ~= 0 && localContext(i,j) == 0  %if pixel in original images
           
            rowsT(pxLookedAt) = contextMap(i,j);
            colsT(pxLookedAt) = 1;
            weightT(pxLookedAt) = Inf;
            
            rowsV(pxLookedAt*4 - 3) = contextMap(i,j);
            colsV(pxLookedAt*4 - 3) = contextMap(i,j);
            weightV(pxLookedAt*4 - 3) = Inf;
        
        elseif localContext(i,j) ~= 0  %if pixel in local context area compute SSD
           
            %look at 4 adjacent pixels
            
            %left pixel (i-1)
            if i>1 && localContext(i-1,j)~= 0   %px belongs to seam region
                rowsV(pxLookedAt*4 - 3) = contextMap(i,j);
                colsV(pxLookedAt*4 - 3) = contextMap(i-1,j);
                weightV(pxLookedAt*4 - 3) = 0.002*(sqrt((i-centroidsMask(:,1))^2 + (j-centroidsMask(:,2))^2))^3 + computeGradientMagnitude(imgInputMaskedLab, imgPatchLab, i, j, borders, 'left');
                
            elseif i>1 && inputMaskedImg(i,j) == 0 %px belongs to mask region
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 2;
                weightT(pxLookedAt) = Inf;
                
            else  %px belongs to original image
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 1;
                weightT(pxLookedAt) = Inf;
            end
            
            %right pixel (i+1)
            if i<rows && localContext(i+1,j)~= 0   %px belongs to seam region
                rowsV(pxLookedAt*4 - 2) = contextMap(i,j);
                colsV(pxLookedAt*4 - 2) = contextMap(i+1,j);
                weightV(pxLookedAt*4 - 2) = 0.002*(sqrt((i-centroidsMask(:,1))^2 + (j-centroidsMask(:,2))^2))^3 + computeGradientMagnitude(imgInputMaskedLab, imgPatchLab, i, j, borders, 'right');
            
            elseif i<rows && inputMaskedImg(i,j) == 0 %px belongs to mask region
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 2;
                weightT(pxLookedAt) = Inf;
                
            else  %px belongs to original image
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 1;
                weightT(pxLookedAt) = Inf;
            end
            
            %top pixel (j-1)
            if j>1 && localContext(i,j-1)~= 0   %px belongs to seam region
                rowsV(pxLookedAt*4 - 1) = contextMap(i,j);
                colsV(pxLookedAt*4 - 1) = contextMap(i,j-1);
                weightV(pxLookedAt*4 - 1) = 0.002*(sqrt((i-centroidsMask(:,1))^2 + (j-centroidsMask(:,2))^2))^3 + computeGradientMagnitude(imgInputMaskedLab, imgPatchLab, i, j, borders, 'top');
            
            elseif j>1 && inputMaskedImg(i,j) == 0 %px belongs to mask region
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 2;
                weightT(pxLookedAt) = Inf;
                
            else  %px belongs to original image
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 1;
                weightT(pxLookedAt) = Inf;
            end
            
            %bottom pixel (j+1)
            if j<cols && localContext(i,j+1)~= 0   %px belongs to seam region
                rowsV(pxLookedAt*4) = contextMap(i,j);
                colsV(pxLookedAt*4) = contextMap(i,j+1);
                weightV(pxLookedAt*4) = 0.002*(sqrt((i-centroidsMask(:,1))^2 + (j-centroidsMask(:,2))^2))^3 + computeGradientMagnitude(imgInputMaskedLab, imgPatchLab, i, j, borders, 'bottom');
            
            elseif j<cols && inputMaskedImg(i,j) == 0 %px belongs to mask region
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 2;
                weightT(pxLookedAt) = Inf;
                
            else  %px belongs to original image
                rowsT(pxLookedAt) = contextMap(i,j);
                colsT(pxLookedAt) = 1;
                weightT(pxLookedAt) = Inf;
            end
        end
    end
end

%remove zeros index
rowsT = nonzeros(rowsT);
colsT = nonzeros(colsT);
weightT = nonzeros(weightT);

%remove zeros index
rowsV = nonzeros(rowsV);
colsV = nonzeros(colsV);
weightV = nonzeros(weightV);

%build sparse Matrix A and T
sparseAMatrix = sparse(rowsV,colsV,weightV);
sparseTMatrix = sparse(rowsT, colsT, weightT);

end


