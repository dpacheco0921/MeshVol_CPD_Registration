function xform = register_meshes(refIm, floatIm, ...
    resample_factor, iparams)
% register_meshes: performs registration of meshes 
%   using point set registration algorithm
%
% Usage:
%   xform = register_meshes(refIm, floatIm, ...
%       resample_factor, iparams)
% 
% Args:
%   refIm: reference image
%   floatIm: floating image
%   resample_factor: factor used for resampling
%   iparams: parameters to update
%
% Output:
%   xform: structure containing ridig (ICP) and CPD transformation.

% default CPD params
%%%%%%%%%%%%%%%%%%% CPD options (default) %%%%%%%%%%%%%%%%%%%
cpd_opts = struct();
cpd_opts.method = 'nonrigid';   % use nonrigid registration with lowrank kernel approximation
cpd_opts.numeig = 50;           % leave only 50 larges eigenvectors/values to approximate G
cpd_opts.eigfgt = 1;            % use FGT to find the largest eigenvectore/values 

%%%%%%%%%%%%%%%%%%% Tunable %%%%%%%%%%%%%%%%%%%
cpd_opts.beta = 10;% 20         % strength of interaction between points (width of Gaussian kernel)
                                %   -> small: more local deformations, large: more globally translational
cpd_opts.lambda = 1;% 10        % trade-off between data fitting and smoothness regularization
cpd_opts.outliers = 0.2;% 0.4   % The weight of noise and outliers

%%%%%%%%%%%%%%%%%%% Tunable %%%%%%%%%%%%%%%%%%%
cpd_opts.fgt=2;              % do not use FGT to compute matrix-vector products (2 means to switch to truncated version at the end, see cpd_register)
cpd_opts.normalize=1;        % normalize to unit variance and zero mean before registering (default)
cpd_opts.corresp=0;          % compute correspondence vector at the end of registration (not being estimated by default)
cpd_opts.max_it=100;         % max number of iterations
cpd_opts.tol=1e-6;           % tolerance
cpd_opts.verbosity = 0;      % print optimization progress
cpd_opts.viz=1;              % show every iteration
cpd_opts.saveoptim = 0;      % save moving points during optimization

%%%%%%%%%%%%%%%%%%% update cpd_opts %%%%%%%%%%%%%%%%%%%
if ~exist('iparams', 'var')
    iparams = [];
end

cpd_opts = loparam_updater(cpd_opts, iparams);

% 1) Preprocessing: downsample merged meshes before registering
if nargin < 3 || isempty(resample_factor)
    resample_factor = [];
end

stic;
if resample_factor ~= 1
    [refIm.node, refIm.elem] = meshresample(refIm.node, ...
        refIm.elem, resample_factor);
    [floatIm.node, floatIm.elem] = meshresample(floatIm.node, ...
        floatIm.elem, resample_factor);
end

stocf(['Downsampled to %d reference ', ...
    'and %d sample nodes for registration.'], ...
    length(refIm.node), length(floatIm.node))

% 2) Rigid

stic;
% Initialize with rigid registration
floating_ = pointCloud(floatIm.node);
reference_ = pointCloud(refIm.node);
tform_initial = pcregrigid(floating_, reference_);

% Apply initial transform to sample mesh
floatIm.node = tform_initial.transformPointsForward(floatIm.node);
stocf('Rigid registration')

% 3) CPD - nonlinear

% Set up CPD registration
floating_ = floatIm.node;
reference_ = refIm.node;

% Compute forward registration transform (floating_ --> reference_)
stic;
[tform_cpd, ~, cpd_history] = cpd_register(reference_, floating_, cpd_opts);
stocf('Finished CPD registration')

% Apply registration to merged sample mesh (for registration inspection)
reg_samp = floatIm;
reg_samp.node = cpd_transform(reg_samp.node, tform_cpd);

% build registration structure
xform = varstruct(tform_cpd, tform_initial, ...
    floating_, reference_, refIm, floatIm, reg_samp);

end
