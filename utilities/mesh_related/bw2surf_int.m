function S = bw2surf_int(BW, xyz_res, isoval, ...
    reduce_factor, iaxisOrder, iformat, ...
    max_node_num, X, Y, Z)
% bw2surf_int: generate isosurface from BW image, resample, and format
%   structure to be compatible either with isomesh or isosurface.
%
% Usage:
%   S = bw2surf_int(BW, xyz_res, isoval, ...
%    reduce_factor, iaxisOrder, iformat, ...
%    max_node_num, X, Y, Z)
%
% Args:
%   BW: 3D matrix
%   xyz_res: pixel resolution
%       (default, [1 1 1])
%   isoval: isovalue
%       (default, 0.9)
%   reduce_factor: factor to reduce size
%       (default, 0.1)
%   iaxisOrder: order of axis (for generating grid)
%       (default, 'xyz')
%   iformat: output format
%       (default, 1, ISO format)
%   max_node_num: max number of nodes | vertices
%       (default, 2*10^3)
%   X, Y, Z: provided grid
%
% Output:
%   S: surface/mesh structure (ISO format) with S.node and S.elem fields.
%
% Notes:
%   similar to bw2surf, but with more options
%
% See also:
%   bw2surf, isosurface, reducepatch, gen_bw_meshgrid

if ~exist('xyz_res', 'var') || isempty(xyz_res)
    xyz_res = [1 1 1];
end

if ~exist('iaxisOrder', 'var') || isempty(iaxisOrder)
    iaxisOrder = 'xyz';
end

if ~exist('iformat', 'var') || isempty(iformat)
    iformat = 1;
end

if ~exist('reduce_factor', 'var') || isempty(reduce_factor)
    reduce_factor = 0.1;
end

if ~exist('isoval', 'var') || isempty(isoval)
    isoval = 0.9;
end

if ~exist('max_node_num', 'var') || isempty(max_node_num)
    max_node_num = 2*10^3;
end

% generate surface grid
if ~exist('X', 'var') || ~exist('Y', 'var') || ~exist('Z', 'var')
    [X, Y, Z] = gen_bw_meshgrid(BW, xyz_res, xyz_res, iaxisOrder);
end

% fix binary image
%BW = fillholes3d(BW, 0);
%BW = deislands3d(BW, 2*3^3);

% generate isosurface
stic;
[elem, node] = isosurface(X, Y, Z, BW > 0, isoval);
node_i = node;
stocf('Computed isosurface')

% reduce surface size
stic;
if max_node_num < size(node, 1)*reduce_factor
    reduce_factor = max_node_num/size(node, 1);
end
[elem, node] = reducepatch(elem, node, reduce_factor);

stocf('Reduced surface: %d -> %d nodes', ...
    length(node_i), length(node))

% change format

% compatible with iso2mesh 
S = struct('elem', elem, 'node', node);

if iformat == 2
    
    % compatible with matlab functions
    S = flip_surf_format(S);
    
end

end
