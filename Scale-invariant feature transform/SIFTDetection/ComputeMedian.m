function OuterMedian= ComputeMedian(InnerRadius, OuterRadius, InputIm, LocationVec)
%function find_imedian find the median of background the bead in the
%intensity image

xi=round(LocationVec(1));
yi=round(LocationVec(2));

radius1 = InnerRadius;
radius2 = OuterRadius;

median_array=[];
i_=0;
for i1=-radius2:radius2;
    if yi+i1<1
        continue
    elseif yi+i1> size(InputIm,1)
        continue
    else
        for i2=-radius2:radius2
            if xi+i2<1
                continue
            elseif xi+i2>size(InputIm,2)
                continue
            else
                r_temp=i1^2+i2^2;
                if r_temp<radius2^2 && r_temp>radius1^2
                    i_=i_+1;
                    median_array(i_)=InputIm(yi+i1,xi+i2);
                end
            end
        end
    end
end
OuterMedian = median(median_array);