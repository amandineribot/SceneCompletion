function [cutPatch, cutMask] = graphCut(inputMaskedImg, inputMask, localContext, borders, bestPatch)

[sparseAMatrix, sparseTMatrix] = computeAdjMatrix(inputMaskedImg, localContext, borders, inputMask, bestPatch);

[rows, cols, ~] = size(localContext);

[flow,labels] = maxflow(sparseAMatrix,sparseTMatrix);
labels = reshape(labels,[cols rows])';

%create new Img and new Mask of size of original to merge apply label mask to best patch
newImg = zeros(size(inputMaskedImg,1), size(inputMaskedImg,2), 3);
newMask = zeros(size(inputMaskedImg,1), size(inputMaskedImg,2));

newImg(borders(1):size(bestPatch,1)+borders(1)-1,borders(3):size(bestPatch,2)+borders(3)-1, 1:3) = bestPatch;
newMask(borders(1):size(labels,1)+borders(1)-1,borders(3):size(labels,2)+borders(3)-1) = labels;

cutMask = newMask > 0;
cutPatch = bsxfun(@times, newImg, cast(cutMask, 'like', newImg));


end




