function S = mesh_checkrepair_all(S, repairtype)
% mesh_checkrepair_all: function to run all types of surfaces/meshes
%   repair in batches
%
% Usage:
%   S = mesh_checkrepair(Y, varargin)
% 
% Args:
%   S: surface/mesh structure (ISO format) with S.node and S.elem fields.
%   repairtype: type of repairs to perform
%       (default, repairtype = ones(1, 5))
%           where each column sets the flag to perform:
%          ('meshfix', 'dup', 'isolated', 'deep', 'open')
% 
% Note:
%   meshfix delete some domains when they are more than 2 connected meshes
%
% See also:
%   meshcheckrepair

if ~exist('repairtype', 'var') || ...
        isempty(repairtype)
    repairtype = ones(1, 5);
end 

if iscell(S)
    
    for i = 1:numel(S)
        
        if repairtype(1)
            [S{i}.node, S{i}.elem] = ...
                meshcheckrepair(S{i}.node, S{i}.elem, 'meshfix');
        end
        
        if repairtype(2)
            [S{i}.node, S{i}.elem] = ...
                meshcheckrepair(S{i}.node, S{i}.elem, 'dup');
        end
        
        if repairtype(3)
            [S{i}.node, S{i}.elem] = ...
                meshcheckrepair(S{i}.node, S{i}.elem, 'isolated');
        end
        
        if repairtype(4)
            [S{i}.node, S{i}.elem] = ...
                meshcheckrepair(S{i}.node, S{i}.elem, 'deep');
        end
        
        if repairtype(5)
            [S{i}.node, S{i}.elem] = ...
                meshcheckrepair(S{i}.node, S{i}.elem, 'open');
        end
        
    end 
    
else
    
    if repairtype(1)
        [S.node, S.elem] = ...
            meshcheckrepair(S.node, S.elem, 'meshfix');
    end
    
    if repairtype(2)
        [S.node, S.elem] = ...
            meshcheckrepair(S.node, S.elem, 'dup');
    end
    
    if repairtype(3)
        [S.node, S.elem] = ...
            meshcheckrepair(S.node, S.elem, 'isolated');
    end
    
    if repairtype(4)
        [S.node, S.elem] = ...
            meshcheckrepair(S.node, S.elem, 'deep');
    end 

    if repairtype(5)
        [S.node, S.elem] = ...
            meshcheckrepair(S.node, S.elem, 'open');
    end 
    
end

end
