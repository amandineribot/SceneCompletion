function textureSSD = computeTextureSSD(localContext, matchPatch)

%compute texture similarity using 5x5 median filter of image gradient
%magnitude at each pixel

sizeFilter = 5;

localContextFiltered(:,:,1) = medfilt2(localContext(:,:,1), [sizeFilter sizeFilter]);
localContextFiltered(:,:,2) = medfilt2(localContext(:,:,2), [sizeFilter sizeFilter]);
localContextFiltered(:,:,3) = medfilt2(localContext(:,:,3), [sizeFilter sizeFilter]);

matchPatchFiltered(:,:,1) = medfilt2(matchPatch(:,:,1), [sizeFilter sizeFilter]);
matchPatchFiltered(:,:,2) = medfilt2(matchPatch(:,:,2), [sizeFilter sizeFilter]);
matchPatchFiltered(:,:,3) = medfilt2(matchPatch(:,:,3), [sizeFilter sizeFilter]);

% the descriptors of the two images are compared via SSD
textureSSD = computeContextSSD(localContextFiltered, matchPatchFiltered);

end
