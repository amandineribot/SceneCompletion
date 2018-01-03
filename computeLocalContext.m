function [localContext, borders] = computeLocalContext(inputImg, inputMask, test)

    radius = 80;
    [rows, cols, ~] =  size(inputMask);
    localContextMask = zeros(rows, cols);

    %enlarge the mask by a radius of 80 pixels
    for i = 1:rows
        for j = 1:cols
            if(inputMask(i,j) == 1)

                left = max(1, i-radius);
                right = min(i+radius, rows);
                top = max(1, j-radius);
                bottom = min(cols, j+radius);
                
                for k=(left):(right)
                    for l=(top):(bottom)
                        localContextMask(k,l) = 1;
                    end
                end 

                localContextMask(i,j) = 1;
            end
        end
    end

imwrite(localContextMask, strcat('images/local_context/dilatedMask', test, '.jpg'));

%apply new mask to image input to obtain radius regions
fullMaskedRgbImage = bsxfun(@times, inputImg, cast(localContextMask, 'like', inputImg));
fullLocalContext = applyMask(fullMaskedRgbImage, inputMask);

%get which rows and cols have only zero in them
zeros1 = any(fullLocalContext,1);
zeros2 = any(fullLocalContext,2);

s1 = size(zeros1,2);
s2 = size(zeros2,1);

%get the left, right, top, bottom index to crop the image to the mask
for i=1:s1
    if zeros1(i) == 1
        left = i;
        break;
    end
end

for j=1:s2
    if zeros2(j) == 1
        top = j;
        break;
    end
end

for i=s1:-1:1
    if zeros1(i) == 1
        right = i;
        break;
    end
end

for j=s2:-1:1
    if zeros2(j) == 1
        bottom = j;
        break;
    end
end

%crop the image to the new mask size
localContext = fullLocalContext(top:bottom,left:right,1:3);
borders = [top, bottom, left, right]

end