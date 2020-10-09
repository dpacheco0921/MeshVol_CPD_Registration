function h = vizsurfn(S1, S2, varargin)
% vizsurfn: Visualize N surfaces/meshes (at least 2)
%
% Usage:
%   vizsurfn(S1, S2)
% 
% Args:
%   S1: surface/mesh structure (ISO format) with S1.node and S1.elem fields.
%   S2 to Sn: additional surfaces
%   varargin: extra surfaces as cells, size should be [1, n]
% 
% See also:
% vizsurf; and plotmesh from iso2mesh repo.

% collect surfaces as cells
S = {S1};
if nargin >= 2; S{end + 1} = S2; end
if nargin >= 3; S = [S, varargin]; end

% convert inner structure into cells
for i = 1:numel(S)
    if isstruct(S{i})
        S{i} = horz(num2cell(S{i}));
    end
end

% concatenate cells
S = cellcat(S, 2);

% default plotting settings
facealpha = 0.5;
edgealpha = 0;
n = numel(S);
colors = jet(n);

% generate figure
if isempty(get(groot, 'CurrentFigure'))
    figure, figclosekey
end

hold on

% plot each surface
h = cell1(n);
for i = 1:n
    h{i} = vizsurf(S{i}, [], facealpha, edgealpha, ...
        'facecolor', colors(i, :));
end

% **
hasType = cellfun(@(s)isfield(s, 'type'), S);
if any(hasType)
    
    if ~all(hasType)
        for i = find(~hasType)
            S{i}.type = sprintf('Mesh %d', i);
        end
    end
    
    types = cf(@(s)s.type, S);
    legend(cellcat(cf(@(x)x(1), h)), types, 'Location', 'best')
    
end

if nargout < 1
    clear h;
end

end
