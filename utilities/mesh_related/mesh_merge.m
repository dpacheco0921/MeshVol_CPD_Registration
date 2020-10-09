function M = mesh_merge(S, varargin)
% mesh_merge: merge N surfaces/meshes (at least 2)
%
% Usage:
%   M = mesh_merge(S)
% 
% Args:
%   S: surface/mesh structure (ISO format) with S.node and S.elem fields.
%   varargin: extra surfaces as cells, size should be [1, n]
% 
% See also:
%   mergemesh

% collect surfaces as cells
if isstruct(S); S = {S}; end
if nargin >= 2; S = [S, varargin]; end

% convert inner structure into cells
for i = 1:numel(S)
    if isstruct(S{i})
        S{i} = horz(num2cell(S{i}));
    end
end

% concatenate cells
S = cellcat(S);

nodes = cf(@(x)x.node, S);
elems = cf(@(x)x.elem, S);

M = struct('node', nodes{1}, 'elem', elems{1});

for i = 2:numel(S)
    [M.node, M.elem] = ...
        mergemesh(M.node, M.elem, nodes{i}, elems{i});
end

end
