function [AppendedIm] = AppendIms(Im1, Im2, Space)

%Map both images to [0,1]:
Im1= (Im1-min(Im1(:))) ./ (max(Im1(:))-min(Im1(:)));
Im2= (Im2-min(Im2(:))) ./ (max(Im2(:))-min(Im2(:)));

rows1 = size(Im1,1);
rows2 = size(Im2,1);

if (rows1 < rows2)
     Im1(rows2,1) = 0;
else
     Im2(rows1,1) = 0;
end

% Now append both images side-by-side with a white space between them.
AppendedIm = [Im1 ones(size(Im1,1), Space) Im2];   