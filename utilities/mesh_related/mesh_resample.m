function S = mesh_resample(S, iratio)
% mesh_resample: resample surfaces/meshes
%
% Usage:
%   mesh_smooth(Y, iratio)
% 
% Args:
%   S: surface/mesh structure (ISO format) (or collection of S - in cells)
%   iratio: ratio to use for resampling
%       (default, 1)
%
% See also:
%   reducepatch

if ~exist('iratio', 'var') || isempty(iratio)
    iratio = 1;
end

% resample to match to the size of a reference mesh
if iscell(S)
    
    for i = 1:numel(S)
        
        t0 = stic;
        
        [S{i}.elem, S{i}.node] = ...
            reducepatch(S{i}.elem, S{i}.node, iratio);
        
        stocf(t0, ['Finished file # ', num2str(i)])
        
    end
    
else
    
    t0 = stic;
    
    [S.elem, S.node] = reducepatch(S.elem, S.node, iratio);
    
    stocf(t0, 'Finished file')   
    
end

end
