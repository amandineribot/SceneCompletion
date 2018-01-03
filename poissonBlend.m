function final = poissonBlend(source,target,mask)

% mask = im2double(imread('input/local_context/cutMask.jpg'));
% source = im2double(imread('input/local_context/patchResized.jpg'));
% target = im2double(imread('input/maskedImage/maskedTest1.jpg'));

%add a pad of 1 to avoid edge issues
source = padarray(source, [1,1], 'symmetric');
target = padarray(target, [1,1], 'symmetric');
mask = padarray(mask, [1,1]);

[rows, cols, ~] = size(target);
nberPx = rows*cols;

%reshape matrix into a vector array
s = reshape(source, nberPx, []);
t = reshape(target, nberPx, []);

%create vectors for sparse matrix A with value
rowsV = zeros(nberPx, 1);
colsV = zeros(nberPx, 1);
valueV = zeros(nberPx, 1);

%create vector b to get gradient matrix
b = zeros(nberPx, 3);

%loop through each px in source
pxLookedAt = 1;

%solve linear equation Ax=b for each px
for i = 1:nberPx
    
    if mask(i) == 0 %if pixel not in the mask - value b = value at i in target img
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i;
        valueV(pxLookedAt) = 1;
        pxLookedAt = pxLookedAt + 1;
        
        b(i,:) = t(i,:);
    else %if pixel in the mask - value b = gradient (using Laplacian operator [0 -1 0; -1 4 -1; 0 -1 0])
         % of i in source img
         
        b(i,:) = 4*s(i,:) - s(i-1,:) - s(i+1,:) - s(i+rows,:) - s(i-rows,:);
        
        %insert Laplacian coeff to populate A for each px (center, top, bottom, left, right)
        
        %central pixel.
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i;
        valueV(pxLookedAt) = 4;
        pxLookedAt = pxLookedAt + 1;
        
        %bottom pixel:
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i + 1;
        valueV(pxLookedAt) = -1;
        pxLookedAt = pxLookedAt + 1;

        %top pixel:
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i - 1;
        valueV(pxLookedAt) = -1;
        pxLookedAt = pxLookedAt + 1;

        %left pixel:
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i - rows;
        valueV(pxLookedAt) = -1;
        pxLookedAt = pxLookedAt + 1;
        
        %right pixel:    
        rowsV(pxLookedAt) = i;
        colsV(pxLookedAt) = i + rows;
        valueV(pxLookedAt) = -1;
        pxLookedAt = pxLookedAt + 1;
    
    end
end

%build sparse Matrix A
sparseAMatrix = sparse(rowsV, colsV, valueV, nberPx, nberPx);

%solve for each channel
final1 = sparseAMatrix \ b(:,1);
final2 = sparseAMatrix \ b(:,2);
final3 = sparseAMatrix \ b(:,3);

%reshape to matrix form
final1 = reshape(final1, [rows, cols]);
final2 = reshape(final2, [rows, cols]);
final3 = reshape(final3, [rows, cols]);

%add three channels together
final = zeros(rows, cols, 3);
final(:,:,1) = final1;
final(:,:,2) = final2;
final(:,:,3) = final3;

%remove pad
final = final(2:rows-1, 2:cols-1, :);
%figure('Name','final'), hold off, imagesc(final), axis image

end