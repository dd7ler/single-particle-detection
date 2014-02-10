function imwriteMatchedParticles(bw, particleLocs, particleColor, matchLocs, matchColor, tifName)
% imwriteMatchedParticles(bw, particleLocs, particleColor, matchLocs, matchColor, tifName)
% Write a figure after drawing two different populations of circles
bw = uint16(imrescale(bw,2^16));
C = repmat(bw,[1 1 3]);

% red = uint16([1 0 0]*2^16); % [R G B]; class of red must match class of I
% green = uint16([0 1 0]*2^16);
% blue = uint16([0 0 1]*2^16);
% colors = {'red','green','blue'};

pR = 8;
mR = 6;

particleR = pR*ones(size(particleLocs,1),1);
matchR = mR*ones(size(matchLocs,1),1);

% Particles
% switch find(strcmp(particleColor,colors))
%     case 1
%         particleColor = red;
%     case 2
%         particleColor = green;
%     case 3
%         particleColor = blue;
%     otherwise
%         particleColor = red;
% end
Cp = insertShape(C, 'circle', [particleLocs particleR], 'color', particleColor);
% particleInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',particleColor);
% particleCircles = [particleLocs particleR];
% Cp = step(particleInserter, C, uint16(round(particleCircles)));

% Matches

% switch find(strcmp(matchColor,colors))
%     case 1
%         matchColor = red;
%     case 2
%         matchColor = green;
%     case 3
%         matchColor = blue;
%     otherwise
%         matchColor = red;
% end
Cpm = insertShape(Cp, 'circle', [matchLocs matchR], 'color', matchColor);

% matchInserter = vision.ShapeInserter('Shape','Circles','BorderColor','Custom','CustomBorderColor',matchColor);
% matchCircles = [matchLocs matchR];
% Cpm = step(matchInserter, Cp, uint16(round(matchCircles)));

% textColor = uint16([1 1 1]*2^16);
textLocation = [10 1];
% labelInserter = vision.textInserter([particleColor ' incidates unmatched particles and ' matchColor ' incidates matched particles'], 'Color',textColor,'FontSize', 16, 'Location',textLocation);
% Cpml = step(labelInserter, Cpm)
str = ['All particles are circled in ' particleColor '; matched particles are circled in ' matchColor];
Cpml = insertText(Cpm, textLocation, str);
imwrite(uint16(Cpml), tifName,'TIFF', 'writemode', 'append');