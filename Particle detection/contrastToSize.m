function sizes = contrastToSize(contrasts, material)

if strcmp(material, 'gold')
    load goldContrast;
elseif strcmp(material, 'poly')
    load polyContrast;
else
	% No known material
	err = MException('ResultChk:BadInput', 'Material is unknown');
end
% Data is a measure of radius, sizes is in diameter. 


contrasts(contrasts>max(data(:,1)))= max(data(:,1));
contrasts(contrasts<min(data(:,1)))= min(data(:,1));
sizes = interp1(data(:,1), data(:,2),contrasts)*2;