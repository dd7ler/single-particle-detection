% Draw a circle in a matrix using the integer midpoint circle algorithm
% Does not miss or repeat pixels
% Created by : Peter Bone
% Created : 19th March 2007

% Edited by DDS for RGB image compatibility. Value is a normalized RGB
% color vector (levels between 0 and 1).

function i = MidpointCircle(i, radius, xc, yc, v)

[r,c,d] = size(i);
if xc-radius<1 || xc+radius>r || yc-radius<1 || yc+radius>c
    return;
end

value = 2^16*v;
xc = int16(xc);
yc = int16(yc);

x = int16(0);
y = int16(radius);
d = int16(1 - radius);

i(xc, yc+y,:) = value;
i(xc, yc-y,:) = value;
i(xc+y, yc,:) = value;
i(xc-y, yc,:) = value;

while ( x < y - 1 )
    x = x + 1;
    if ( d < 0 ) 
        d = d + x + x + 1;
    else 
        y = y - 1;
        a = x - y + 1;
        d = d + a + a;
    end
    i( x+xc,  y+yc,:) = value;
    i( y+xc,  x+yc,:) = value;
    i( y+xc, -x+yc,:) = value;
    i( x+xc, -y+yc,:) = value;
    i(-x+xc, -y+yc,:) = value;
    i(-y+xc, -x+yc,:) = value;
    i(-y+xc,  x+yc,:) = value;
    i(-x+xc,  y+yc,:) = value;
end
