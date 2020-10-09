function S = mesh_checkrepair(S, varargin)
% mesh_checkrepair: function to repair surfaces/meshes
%
% Usage:
%   S = mesh_checkrepair(Y, varargin)
% 
% Args:
%   Y: mesh structure (ISO format)
%   varargin: inputs to meshcheckrepair
% 
% See also: 
%   meshcheckrepair
 
if iscell(S)
    
    for i = 1:numel(S)
        [S{i}.node, S{i}.elem] = ...
            meshcheckrepair(S{i}.node, S{i}.elem, varargin);
    end
    
else
    
    [S.node, S.elem] = ...
        meshcheckrepair(S.node, S.elem, varargin);
    
end

end
