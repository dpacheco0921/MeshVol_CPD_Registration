function batch_generate_dform(serverid, ...
    fIm2sel, corenum, memreq, jobtime, ...
    chunkSize, jobsperfile, redo)
% batch_generate_dform: batch function to run generate_dform.m in the cluster/local
%   machine
%
% Usage:
%   batch_generate_dform(serverid, ...
%      fIm2sel, corenum, jobtime, chunkSize, redo)
%
% Args:
%   serverid: server ID 'int', 'spock', 'della'
%       (deafult, 'spock')
%   rIm2sel: index of reference image to use
%   corenum: number of cores to request
%   memreq: memory to request
%   jobtime: time requested per job
%   chunkSize: number of points per parfor loop
%   jobsperfile: number of jobs to run per submit file
%   redo: redo flag
%
% See also:
%   generate_dform, generate_dform_perfile

% default params
p = [];
p.cDir = pwd;
p.floatiDir = '.';
p.floatImSu = [];

if ~exist('serverid', 'var') || ~isempty(serverid)
    serverid = 'spock';
end

if ~exist('fIm2sel', 'var') || ~isempty(fIm2sel)
    fIm2sel = [];
end

if ~exist('corenum', 'var') || ~isempty(corenum)
    corenum = 6;
end

if ~exist('jobtime', 'var') || ~isempty(jobtime)
    jobtime = 10;
end

if ~exist('chunkSize', 'var') || ~isempty(chunkSize)
    chunkSize = 10^4;
end

if ~exist('jobsperfile', 'var') || ~isempty(jobsperfile)
    jobsperfile = 8;
end

if ~exist('memreq', 'var') || ~isempty(memreq)
    memreq = 24;
end

if ~exist('redo', 'var') || ~isempty(redo)
    redo = 0;
end

% get scratch (temporary) and bucket (permanent) directories
[~, username, ~, temporary_dir, ~, userdomain] = ...
    user_defined_directories(serverid);
if ~exist([temporary_dir, 'jobsub', filesep, 'regrel'], 'dir')
    mkdir([temporary_dir, 'jobsub', filesep, 'regrel']);
end
p.tDir = [temporary_dir, 'jobsub', filesep, 'regrel'];

% Determining how many input files will be run from FolderName
files2run = getinputfiles(p.floatiDir, p.floatImSu, fIm2sel);
[patch_, patch_idx] = patchIdxgen(files2run, jobsperfile);
cd(p.tDir)

% generate mat and executable file name
p.param_file = sprintf('%02d', round(clock'));
p.param_file = [p.param_file(3:8), '_', p.param_file(9:14)];

% add some params
p.corenum = corenum;
p.chunkSize = chunkSize;
p.redo = redo;
p.jobsperfile = jobsperfile;
save([p.param_file, '_deform.mat'], 'files2run', 'p', 'patch_idx', 'patch_')

% get number of files to run
numT = numel(files2run);

% Executing File
submitjob(p.param_file, p.tDir, ...
    username, corenum, serverid, ...
    numT, memreq, userdomain, jobtime)

% Go back to original folder
cd(p.cDir)

end

function [patch_, patch_idx] = ...
    patchIdxgen(xforms_filename, jobsperfile)
% patchIdxgen: get indeces of start and end of a patch
%   and their respective job index
%
% Usage:
%   [patch_, patch_idx] = ...
%       patchIdxgen(xforms_filename, jobsperfile)
% 
% Args:
%   xforms_filename: name of files containing transforms
%   jobsperfile: number of jobs to run per submitted file

patch_ = [];
patch_idx = [];

for i = 1:numel(xforms_filename)
    
    fprintf('*')
    load(xforms_filename{i}, 'reg_struct')
    
    if isfield(reg_struct, 'reg_1to2')
        pts2reg = prod(reg_struct.vol1_sz);
    elseif isfield(reg_struct, 'reg_2to1')
        pts2reg = prod(reg_struct.vol2_sz);
    end
    
    chunkSize = floor(pts2reg/jobsperfile);
    patch_temp = chunk2cell((1:pts2reg)', chunkSize);
    patch_temp = cellfun(@(x) x([1 end]), patch_temp, 'UniformOutput', false);
    patch_ = [patch_; patch_temp];
    patch_idx = [patch_idx; ones(jobsperfile, 1)*i, (1:jobsperfile)'];
    clear reg_struct
    
end

fprintf('\n')

end

function floatIm = getinputfiles(floatiDir, floatImSu, fIm2sel)
% getinputfiles: find all files to run
%
% Usage:
%   floatIm = getinputfiles(floatiDir, floatImSu, fIm2sel)
% 
% Args:
%   floatiDir: file directory
%   floatImSu: file suffix
%   fIm2sel: files to select

% get floatIm for the default folder organization
floatIm = rdir([floatiDir, filesep, 'reg_*.mat']);
floatIm = str2match(floatImSu, floatIm);
floatIm = str2rm({'_temp', '_dform.mat'}, floatIm);
floatIm = {floatIm.name}';

% only run files defined by fIm2sel if not empty
if ~isempty(fIm2sel)
    
    if ischar(fIm2sel)
        floatIm = str2match(fIm2sel, floatIm);
    else
        floatIm = floatIm(fIm2sel);
    end
    
    fprintf(['Only processing the following floatIms: ', num2str(numel(floatIm)), '\n'])
    
end

fprintf('Done\n')

end

function submitjob(name, tDir, ...
    username, corenum, serverid, ...
    numT, memreq, userdomain, jobtime)
% submitjob: submit jobs to rondo/spock/della
%
% Usage:
%   submitjob(name, tDir, ...
%       username, corenum, serverid, ...
%       numT, memreq, userdomain, jobtime)
%
% Args:
%   name: name of matfile with parameters to use
%   tDir: target directory
%   username: used to update directories to use
%   corenum: maximun number of cores to use per task
%   serverid: server ID 'int', 'spock', 'della'
%       (deafult, 'spock')
%   numT: number of jobs
%   memreq: RAM memory to request
%   userdomain: domain to use for username
%   jobtime: time requested per job

switch serverid
    
    case {'spock', 'della'}
        
        eval(['username = username.', serverid, ';']);
        
        % write a slurm file
        LogFileName = fullfile([cpdpars.name, '.slurm']);
        if exist(LogFileName, 'file')
            delete(LogFileName)
        end
        
        % open/create log file
        fid = fopen(LogFileName, 'a+');
        fprintf(fid, '#!/bin/bash\n\n');
        fprintf(fid, ['#SBATCH --cpus-per-task=', num2str(corenum), '\n']);
        fprintf(fid, ['#SBATCH --time=', num2str(jobtime), ':00:00\n']);
        fprintf(fid, ['#SBATCH --mem=', num2str(memreq), '000\n']);
        fprintf(fid, '#SBATCH --mail-type=END\n');
        fprintf(fid, ['#SBATCH --mail-user=', username, userdomain, '\n']);
        fprintf(fid, ['#SBATCH --array=1-', num2str(numT), '\n\n']);
        
        fprintf(fid, 'module load matlab/R2019b\n');
        fprintf(fid, '# Create a local work directory\n');
        fprintf(fid, 'mkdir -p /tmp/$USER-$SLURM_JOB_ID\n');
        fprintf(fid, ['matlab -nodesktop -nodisplay -nosplash -r "', ...
            'generate_dform_perfile', '(''', name, ''',''', serverid, ''')"\n']);
        fprintf(fid, '# Cleanup local work directory\n');
        fprintf(fid, 'rm -rf /tmp/$USER-$SLURM_JOB_ID\n');

        % close log file
        fclose(fid); 
        
    otherwise % internal run
        
        cd(tDir)
        for f_run = 1:numT
            generate_dform_perfile(name, serverid, f_run);
            fprintf('\n\n **************************************************** \n\n')
            cd(tDir)
        end
        
end

end
