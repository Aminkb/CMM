% CMMDataLineExtraction2(rootdir, outputFolderName)
%% Description
% This is a function for importing trace-by-trace (here named lines) CMM
% measurements from .dat files.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%% INPUTS: 
% (1) rootdir: the root directory at which the .dat files excist.
% (2) outputFolderName: The name of the folder at which the extracted data
% will be saved. This folder will be within the root directory.
%% OUTPUTS:
% The coordinates data will be saved as a MATLAB Data file named
% (CMM_Measurements) containing a single structure variable named
% (measurements).
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%% NOTES
% The arrangement of the coordinates in each line depends on how they are
% arranged in the .dat file. (e.g. XY(Z), ZX(Y), etc.)
% This code is compatible with standard GEOPAK-WIN data file structure.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Author: Amin Kassab-Bachi
% University of Leeds, June 2022
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
function CMMDataLineExtraction2(rootdir, outputFolderName)
% Create output directory
outputFolder = fullfile(rootdir, outputFolderName);
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
% Read data files from root directory
partsList=dir(rootdir);
for f=1:size(partsList,1)
    if partsList(f).isdir==0 && endsWith(partsList(f).name,'.dat')
        filename=fullfile(rootdir, partsList(f).name);
        [~,fname,~] = fileparts(partsList(f).name);
        % Import the data file
        fileID = fopen(filename);
        part = textscan(fileID,'%s','TextType','string','delimiter','\n');
        % Search for a keyword in the file
        keyword=strfind(part{1,1},'Scanning');
        idx=find(~cellfun(@isempty,(keyword)));
        for i = 1:length(idx)
            Line = {};
            d={};
            % Start of a trace (bypassing padding info)
            blockStart=idx(i,1)+6;
            if i ~= length(idx)
                % End of trace
                blockEnd=idx(i+1,1)-1;
                for j = blockStart:blockEnd
                    splitCell = strsplit(part{1,1}(j,1),' ');
                    d = cellfun(@str2num,splitCell,'UniformOutput',false);
                    Line = vertcat(Line,d(1,2:4));
                end
            else
                % Handle the last trace that can't be flagged by the keyword)
                for j = blockStart:length(part{1,1})
                    splitCell = strsplit(part{1,1}(j,1),' ');
                    d = cellfun(@str2num,splitCell,'UniformOutput',false);
                    Line = vertcat(Line,d(1,2:4));
                end
            end
            Line = cell2mat(Line);
            % Save trace data
            measurements.(sprintf(fname)).("Line"+sprintf('%04.0f', (i))) = Line;
        end
        fclose('all');
    end
end
outputFileName = fullfile(outputFolder,"CMM_Measurements");
save(outputFileName, "measurements");
clear
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
