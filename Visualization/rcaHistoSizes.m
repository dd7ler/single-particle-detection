% Script for compiling and plotting histograms created by baSIFT.m
% Derin Sevenler 11/13/2013 12:08:37 PM
clear; close all; clc;

d = uigetdir(pwd,'Please select the histogram directory');
defPrompts = {'How many chips?', 'How many conditions per chip?', 'How many spots per condition?', 'What are the conditions?'};
defParams = {'6', '3', '6', 'M13 RPOB MecA'};
usrinput = inputdlg(defPrompts, 'Settings', 1, defParams);
nChips = str2num(usrinput{1});
nConditions = str2num(usrinput{2});
nSpots = str2num(usrinput{3});
conditionLabels = strsplit(usrinput{4});

histLists = cell(nChips,nConditions,nSpots);
for m = 1:nChips
	for n = 1:nConditions
		for k = 1:nSpots
			chipSpot = (n-1)*nConditions + k;
			fName = [d filesep 'histogram chip' num2str(m) ' spot' num2str(chipSpot) '.mat'];
			if exist(fName, 'file')
				load(fName);
			else
				unmatchedContrastPost = [];
			end
			histLists{m,n,k} = unmatchedContrastPost;
		end
	end
	progressbar(m/nChips);
end
dateTag = strrep(datestr(now),':','.');
save(['HistogramResults ' dateTag '.mat'], 'histLists');

% Plot the histograms for each condition on each spot
colors = hsv(nConditions);
for m = 1:nChips
	figure; hold on;
	hGroups = repmat(hggroup, 1, nConditions);
	lines = [];
	for n = 1:nConditions
		for k = 1:nSpots
			[nb,xb]=hist(histLists{m,n,k}, 40);
			lines=plot(xb,nb, 'Color', colors(n,:), 'LineWidth', 1);
			set(lines, 'Parent', hGroups(n));
		end
	end
	for n = 1:nConditions
		set(get(get(hGroups(n),'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
	end
	legend(conditionLabels)
	xlabel('Contrast', 'FontSize', 14);
	ylabel('Counts', 'FontSize', 14);
	title(['Chip ' num2str(m)], 'FontSize', 14);
end