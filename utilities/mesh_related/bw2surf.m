function S = bw2surf(BW, isoval, reduce_factor)
% bw2surf: generate isosurface from BW image, and resamples the mesh/surface
%
% Usage:
%   S = bw2surf(BW, isoval, reduce_factor)
% 
% Args:
%   BW: 3D matrix
%   isoval: isovalue
%   reduce_factor: factor to reduce size
%
% Output:
%   S: surface/mesh structure (ISO format) with S.node and S.elem fields.
%
% See also: 
%   isosurface, reducepatch

stic;
[elem, node] = isosurface(BW > 0, isoval);

% Swap i,j to x,y
node(:, [1 2]) = node(:, [2 1]);

stocf('Computed isosurface')

% Reduce surface size
stic;
[elem2, node2] = reducepatch(elem, node, reduce_factor);
stocf('Reduced surface: %d -> %d nodes', length(node), length(node2))

S = struct('elem', elem2, 'node', node2);

end
