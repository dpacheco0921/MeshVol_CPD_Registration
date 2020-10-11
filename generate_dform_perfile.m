function generate_dform_perfile(paramfile, serverid, IntID)
% generate_dform_perfile: function to generate dform for many files (cluster compatible)
%
% Usage:
%   generate_dform_perfile(paramfile, serverid, IntID)
%
% Args:
%   paramfile: mat file with all registration parameters
%   serverid: server id
%   IntID: job index manually inserted

timeint = tic;
fprintf('\nGenerating deformations using CPD\n');

% load parameters
cDir = pwd;

if exist('IntID', 'var')
    
    taskID = IntID;
    load(['.', filesep, paramfile, '_deform.mat'], ...
        'files2run', 'p', 'patch_idx', 'patch_')
    
else
    
    [~, ~, ~, tempfiledir, ~] = ...
        user_defined_directories(serverid);
    tDir = [tempfiledir, filesep, 'jobsub', filesep, 'regrel'];
    load([tDir, filesep, paramfile, '_deform.mat'], ...
        'files2run', 'p', 'patch_idx', 'patch_')
    % cpdpars.Cdir is updated to the one saved in the _impre.mat file
    taskID = getclus_taskid(serverid);
    
end

% Choose file to run
file_idx = patch_idx(taskID, :);
patch_perfile = patch_(patch_idx(:, 1) == file_idx(1));
files2run_int = files2run{file_idx(1)};
job_idx = file_idx(2);

fprintf('************ Running file ************\n')

% move to raw data folder
if ~exist(p.cDir, 'dir')
    warning(['p.cDir does not exist, ', ...
        '*_deform.mat file was generated in different computer or cluster'])
    warning('run batch_generate_dform locally')
end
cd(p.cDir)

% setup parpool
ppobj = setup_parpool(serverid, p.corenum);

% generate dform
deformation_struct = generate_dform_splitjobs(...
    files2run_int, p.chunkSize, p.corenum, ...
    p.redo, patch_perfile{job_idx}, job_idx);

% check if all files have finished
%   compile all points registered so far
t0 = stic;
reg_points = [];

for i = 1:p.jobsperfile
    
    try
        
        load([strrep(files2run_int, '.mat', ''), '_temp', num2str(i), '.mat'], 'temp_var')
        reg_points = [reg_points; temp_var];
        clear temp_var
        fprintf(['Loaded file: ', num2str(i), '\n'])
        
    catch
        
        fprintf(['Failed loading file: ', num2str(i), '\n'])
        
    end
    
end

stocf(t0, 'Compile registered points');

save_flag = 0;
if isfield(deformation_struct, 'xyz_v1tov2')
    if prod(deformation_struct.vol1_sz) == size(reg_points, 1)
        save_flag = 1;
    end
end    
    
if isfield(deformation_struct, 'xyz_v2tov1')
    if prod(deformation_struct.vol2_sz) == size(reg_points, 1)
        save_flag = 1;
    end
end

if save_flag
    
    % update reg points
    if isfield(deformation_struct, 'xyz_v1tov2')
        deformation_struct.xyz_v1tov2 = reg_points;
    end
    if isfield(deformation_struct, 'xyz_v2tov1')
        deformation_struct.xyz_v2tov1 = reg_points;
    end
    
    % compile temp files and delete
    t0 = stic;
    save(strrep(files2run_int, '.mat', '_dform.mat'), 'deformation_struct', '-v7.3')
    stocf(t0, 'Saved deformation struct');
    
end

%delete([strrep(files2run_int, '.mat', ''), '_temp*.mat'])

delete_parpool(ppobj)

cd(cDir);

toc(timeint);

end

function deformation_struct = generate_dform_splitjobs(...
    path_reg, chunkSize, corenum, redo, selidxs, filesuffix)
% generate_dform_splitjobs: generate dform that could be used to transform
%   intensity images to coordinates '1' (need 1to2 deformation) or
%   to coordinates '2' (need 2to1 deformation)
% 
% Usage:
%   deformation_struct = generate_dform_splitjobs(...
%       path_reg, chunkSize, corenum, redo, selidxs, filesuffix)
%
% Args:
%   path_reg: path of registration to use to generate deformation
%   chunkSize: size of chunks
%   corenum: number of cores available
%   redo: gate for redo | overwritting
%   selidxs: selected indeces to run
%   filesuffix: suffix for temporary file
%
% Note:
%   for a mapping from 1 to 2, you need 2to1 xform, and vice versa
%
% See also:
%   generate_dform

if ~exist('chunkSize', 'var') || isempty(chunkSize)
    chunkSize = 5*10^3;
end

if ~exist('corenum', 'var') || isempty(corenum)
    corenum = 4;
end

if ~exist('redo', 'var') || isempty(redo)
    redo = 0;
end

% load reg
t0 = stic;
load(path_reg)

% get ref and float im sizes and pixel resolution
vol1_sz = reg_struct.vol1_sz;
res1 = reg_struct.res1;
vol2_sz = reg_struct.vol2_sz;
res2 = reg_struct.res2;
stocf(t0, 'Load ref and float image information');

% make sampling grid im_1
t0 = stic;
% x = rows, y = columns
xv1 = (1:vol1_sz(1))*res1(1); 
yv1 = (1:vol1_sz(2))*res1(2); 
zv1 = (1:vol1_sz(3))*res1(3);

% make sampling grid im_2
% x = rows, y = columns
xv2 = (1:vol2_sz(1))*res2(1); 
yv2 = (1:vol2_sz(2))*res2(2);  
zv2 = (1:vol2_sz(3))*res2(3); 
stocf(t0, 'Generate grids');

% apply to all pts

if isfield(reg_struct, 'reg_1to2')
    
    t0 = stic;
    
    % run tform in chunks
    reg_struct = reg_struct.reg_1to2;
    [XX1, YY1, ZZ1] = ndgrid(xv1, yv1, zv1);
    grid_points = [XX1(:) YY1(:) ZZ1(:)];
    clear XX1 YY1 ZZ1
    
    dataObj = apply_tform_inchunks(grid_points, reg_struct, ...
        chunkSize, path_reg, redo, selidxs, filesuffix);
    deformation_struct.xyz_v1tov2 = dataObj.temp_var;
    
    % delete temp file
    clear dataObj;
    stocf(t0, 'Deformation 1to2');
    
end

if isfield(reg_struct, 'reg_2to1')
    
    t0 = stic; 
    
    % run tform in chunks
    reg_struct = reg_struct.reg_2to1;
    [XX2, YY2, ZZ2] = ndgrid(xv2, yv2, zv2);
    grid_points = [XX2(:) YY2(:) ZZ2(:)];
    clear XX2 YY2 ZZ2
    
    dataObj = apply_tform_inchunks(grid_points, reg_struct, ...
        chunkSize, path_reg, redo, selidxs, filesuffix);
    deformation_struct.xyz_v2tov1 = dataObj.temp_var;
    
    % delete temp file
    clear dataObj;
    stocf(t0, 'Deformation 2to1');
    
end

% save all grids
deformation_struct.xv2 = xv2;
deformation_struct.yv2 = yv2;
deformation_struct.zv2 = zv2;
deformation_struct.vol1_sz = vol1_sz;
deformation_struct.res1 = res1;
deformation_struct.xv1 = xv1;
deformation_struct.yv1 = yv1;
deformation_struct.zv1 = zv1;
deformation_struct.vol2_sz = vol2_sz;
deformation_struct.res2 = res2;

end

function dataObj = apply_tform_inchunks(grid_points, ...
    reg2use, chunkSize, filename, redo, selidxs, filesuffix)
% apply_tform_inchunks: runs apply_tform in chunks and saves
%   data at each iteration
%
% Usage:
%   dataObj = apply_tform_inchunks(...
%       reg2use, chunkSize, filename, redo, selidxs, filesuffix)
%
% Args:
%   grid_points: set of coordinates to transform
%   reg2use: registration structure
%   chunkSize: size of chunks
%   filename: path of input file
%   redo: gate for redo | overwritting
%   selidxs: selected indeces to run
%   filesuffix: suffix for temporary file

% varaiable to split
sizY = size(grid_points);
siz_init = 1;

% make temporary file
temp_name = [strrep(filename, '.mat', ''), ...
    '_temp', num2str(filesuffix), '.mat'];

% check if temp file already exist
lgate = exist(fullfile(temp_name), 'file') == 0;

% make/load mat object
dataObj = matfile(temp_name, 'Writable', true);

if lgate || redo 
    % initialize variables or reset to empty
    dataObj.temp_var = [];
else
    % get idx of the last row used
    siz_init = size(dataObj.temp_var, 1) + 1;
end

% build indeces from selidxs
selidxs = (selidxs(1):selidxs(2))';

% split selected data indeces into chunks
Y_idx = siz_init:numel(selidxs);
Y_idx = Y_idx';

% reduce data to current indeces to use
Y_idx_chunks = chunk2cell(Y_idx, chunkSize);
Y_idx = [];

for i = 1:numel(Y_idx_chunks)
    
    if i == 1
        t0 = stic;
    end
    
    Yo_ = [];
    
    % run function
    Yo_ = apply_tform(grid_points(selidxs(Y_idx_chunks{i}), :), reg2use);
    dataObj.temp_var(Y_idx_chunks{i}, 1:sizY(2)) = Yo_;
    
    if i == 1
        fprintf(['Estimated time ', ...
            num2str(stoc(t0)*numel(Y_idx_chunks)/3600), ...
            ' hours\n']);
    end
    
    if mod(i, 100) == 0
        fprintf('%2.1f%% of chunks completed \n', ...
            i*100/numel(Y_idx_chunks));
    end
    
end

end
