function S = mesh_smooth(S, useralpha, usermethod, iter)
% mesh_smooth: smooth surfaces/meshes
%
% Usage:
%   S = v(Y, ref_Yidx, ref_node_n)
% 
% Args:
%   S: surface/mesh structure (ISO format) (or collection of S - in cells)
%   useralpha: scaler, smoothing parameter, v(k+1)=(1-alpha)*v(k)+alpha*mean(neighbors)
%       (default, 0.5)
%   usermethod: smoothing method, including 'laplacian','laplacianhc' and 'lowpass'
%       (default, lowpass)
%   iter:  smoothing iteration number
%       (default, 5)
%
% See also:
%   meshconn, smoothsurf

if ~exist('useralpha', 'var') || isempty(useralpha)
    useralpha = 0.5;
end

if ~exist('usermethod', 'var') || isempty(usermethod)
    usermethod = 'lowpass';
end

if ~exist('iter', 'var') || isempty(iter)
    iter = 5;
end

% resample to match to the size of a reference mesh
if iscell(S)
    
    for i = 1:numel(S)
        
        t0 = stic;
        
        % conn
        [conn, ~, ~] = meshconn(S{i}.elem, size(S{i}.node, 1));
        
        % smooth
        S{i}.node = smoothsurf(S{i}.node, [], ...
            conn, iter, useralpha, usermethod);
        
        stocf(t0, ['Finished file # ', num2str(i)])
        
    end
    
else
    
    t0 = stic;
    
    % conn
    [conn, ~, ~] = meshconn(S.elem, size(S.node, 1));
    
    % smooth
    S.node = smoothsurf(S.node, [], ...
        conn, iter, useralpha, usermethod);
    
    stocf(t0, 'Finished file')   
    
end

end
