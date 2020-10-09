function S = mesh_matfiles(filepath, isoval, reduce_factor, rois)
% mesh_matfiles: generate surfaces/meshes of 
%   all 3D variables contained in a *.mat file
%
% Usage:
%   S = mesh_matfiles(filepath, isoval, reduce_factor, rois)
% 
% Args:
%   filepath: file path (contain variables with 3D matrices)
%   isoval: isovalue
%   reduce_factor: factor to reduce mesh to
%   rois: choose rois to use
% 
% See also: 

if nargin < 2 || isempty(isoval)
    isoval = 0.9;
end

if nargin < 3 || isempty(reduce_factor)
    reduce_factor = 0.1;
end

% rois = matvars(filepath);
info = whos('-file', filepath);

if ~exist('rois', 'var') || isempty(rois)
    
    rois = {info.name};
    
    % use only 3D matrices
    is3d = cellfun(@numel, {info.size}) == 3;
    rois = rois(is3d);
    
end

S = cell(1,numel(rois));

for i = 1:numel(rois)
    
    BW = loadvar(filepath, rois{i}) > 0;
    S{i} = bw2surf(BW, isoval, reduce_factor);
    S{i}.type = rois{i};
    S{i}.sz = size(BW);
    
end

S = [rois; S];
S = struct(S{:});

end
