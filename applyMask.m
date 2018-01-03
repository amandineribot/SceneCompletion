function maskedImg = applyMask(inputImg, inputMask)

maskedRgbImage = bsxfun(@times, inputImg, cast(inputMask, 'like', inputImg));
maskedImg = inputImg - maskedRgbImage;

end