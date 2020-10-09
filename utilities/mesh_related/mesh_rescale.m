function S = mesh_rescale(S, xyz_res)
% mesh_rescale: function to change the xyz resolution of surfaces/meshes
%
% Usage:
%   S = mesh_rescale(Y, xyz_res)
% 
% Args:
%   S: surface/mesh structure (ISO format) (or collection of S - in cells)
%   xyz_res: conversion for pixels/coordinates
% 
% See also: 
 
if iscell(S)
    
    for i = 1:numel(S)
        S{i}.node = bsxfun(@times, S{i}.node, xyz_res);
    end
    
else
    S.node = bsxfun(@times, S.node, xyz_res);
end

end
