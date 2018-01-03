function gistSSD = computeGistSSD(gistInput, currentImgGist)

gistInput1Channel = gistInput(1,:);
currentImgGist1Channel = currentImgGist(1,:);
delta1 = (gistInput1Channel - currentImgGist1Channel).^2;

gistSSD = sum(delta1);

end