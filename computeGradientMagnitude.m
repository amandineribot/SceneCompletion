function gradientMagnitudeSSD = computeGradientMagnitude(inputMaskedImgLab, bestPatchLab, pxX, pxY, borders, direction)

%get px position of patch in full input image
top = borders(1);
left = borders(3);

%compute magnitude at pixel
SSDpx = sum((inputMaskedImgLab(left-1+pxX, top-1+pxY) - bestPatchLab(pxX, pxY)).^2,3);

%compute gradient magnitude of neighbors pixel
if strcmp(direction,'left')
    gradientMagnitudeSSD = SSDpx + sum((inputMaskedImgLab(left-1+pxX-1, top-1+pxY) - bestPatchLab(pxX-1, pxY)).^2,3);
elseif strcmp(direction,'right')
    gradientMagnitudeSSD = SSDpx + sum((inputMaskedImgLab(left-1+pxX+1, top-1+pxY) - bestPatchLab(pxX+1, pxY)).^2,3);
elseif strcmp(direction,'top')
    gradientMagnitudeSSD = SSDpx + sum((inputMaskedImgLab(left-1+pxX, top-1+pxY-1) - bestPatchLab(pxX, pxY-1)).^2,3);
elseif strcmp(direction,'bottom')
    gradientMagnitudeSSD = SSDpx + sum((inputMaskedImgLab(left-1+pxX, top+pxY+1) - bestPatchLab(pxX, pxY+1)).^2,3);
end

end
