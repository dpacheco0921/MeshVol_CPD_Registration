function Sn = flip_surf_format(S1, varargin)
% flip_surf_format: changes surface format from isomesh
%   (S.node, S.elem) to matlab (S.vertices, S.faces) or vice versa
%
% Usage:
%   Sn = flip_surf_format(S1, varargin)
%
% Args:
%   S1: surface/mesh or collection of them (in cells)
%   varargin: extra surfaces as cells, size should be [1, n]
%
% See also:

S = {S1};

if nargin >= 2
    S = [S, varargin];
end

n = numel(S);

for i = 1:n

    try 
        
        if isfield(S{i}, 'node')

            Sn{i}.vertices = S{i}.node;
            Sn{i}.faces = S{i}.elem;

        else

            Sn{i}.node = S{i}.vertices;
            Sn{i}.elem = S{i}.faces;  

        end
        
    catch
        keyboard
    end

end

if ~iscell(S1) && nargin == 1 && numel(Sn) == 1
   Sn = Sn{1};
end

end
