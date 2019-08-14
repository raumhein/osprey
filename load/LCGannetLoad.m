function [MRSCont] = LCGannetLoad(MRSCont)
%% [MRSCont] = LCGannetLoad(MRSCont)
%   This function loads the raw MRS data from all major vendors.
%   Data is read from the provided input filenames. It is shaped according 
%   to the type of sequence (un-edited data, MEGA-edited (ON/OFF), 
%   HERMES/HERCULES (A/B/C/D), etc.).
%
%   USAGE:
%       MRSCont = LCGannetLoad(MRSCont);
%
%   INPUTS:
%       MRSCont     = LCGannet MRS data container.
%
%   OUTPUTS:
%       MRSCont     = LCGannet MRS data container.
%
%   AUTHOR:
%       Dr. Georg Oeltzschner (Johns Hopkins University, 2019-02-19)
%       goeltzs1@jhmi.edu
%   
%   CREDITS:    
%       This code is based on numerous functions from the FID-A toolbox by
%       Dr. Jamie Near (McGill University)
%       https://github.com/CIC-methods/FID-A
%       Simpson et al., Magn Reson Med 77:23-33 (2017)
%
%   HISTORY:
%       2019-02-19: First version of the code.

% Set flags
if ~isempty(MRSCont.files)
    MRSCont.flags.hasFiles = 1;
end
if ~isempty(MRSCont.files_ref)
    MRSCont.flags.hasRef = 1;
end
if ~isempty(MRSCont.files_w)
    MRSCont.flags.hasWater = 1;
end

% Determine data types
[MRSCont, retMsg] = LCG_detDataType(MRSCont);

% Load raw data (call loaders depending on file type)
switch MRSCont.vendor
    case 'Siemens'
        switch MRSCont.datatype
            case 'TWIX'
                [MRSCont] = LCG_LoadTwix(MRSCont);
            case 'RDA'
                [MRSCont] = LCG_LoadRDA(MRSCont);
            case 'DICOM'
                [MRSCont] = LCG_LoadDICOM(MRSCont);
            otherwise
                error('Data type not supported. Please contact the Gannet team (gabamrs@gmail.com).');
        end
    case 'Philips'
        switch MRSCont.datatype
            case 'SDAT'
                [MRSCont] = LCG_LoadSDAT(MRSCont);
            case 'DATA'
                error('Coming soon!');
                %[MRSCont] = LCG_LoadDATA(MRSCont);
            case 'RAW'
                error('Coming soon!');
                %[MRSCont] = LCG_LoadRAW(MRSCont);
            otherwise
                error('Data type not supported. Please contact the Gannet team (gabamrs@gmail.com).');
        end
    case 'GE'
        switch MRSCont.datatype
            case 'P'
                [MRSCont] = LCG_LoadP(MRSCont);
            otherwise
                error('Data type not supported. Please contact the Gannet team (gabamrs@gmail.com).');
        end
    otherwise
        error('Vendor not supported. Please contact the Gannet team (gabamrs@gmail.com).');
end

% Perform coil combination (SENSE-based reconstruction if PRIAM flag set)
if ~MRSCont.flags.isPRIAM
    if sum(strcmp(MRSCont.datatype, {'TWIX', 'DATA', 'RAW', 'P'})) == 1
        [MRSCont] = LCG_combineCoils(MRSCont);
    else
        fprintf('Data type %s %s is already coil-combined.\n', MRSCont.vendor, MRSCont.datatype);
    end
elseif MRSCont.flags.isPRIAM
    error('Coming soon!');
    %[MRSCont] = LCG_senseRecon(MRSCont);
end

%% Clean up and save
% Set exit flags
MRSCont.flags.didLoadData           = 1;

% Save the output structure to the output folder
% Determine output folder
outputFolder    = MRSCont.outputFolder;
outputFile      = MRSCont.outputFile;
if ~exist(outputFolder,'dir')
    mkdir(outputFolder);
end
save(fullfile(outputFolder, outputFile), 'MRSCont');

end