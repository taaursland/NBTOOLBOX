function options = optimset(varargin)
% Syntax:
%
% pso.optimset
% options = pso.optimset
% options = pso.optimset(@pso)
% options = pso.optimset(@psomultiobj)
% options = pso.optimset('param1',value1,'param2',value2,...)
% options = pso.optimset(oldopts,'param1',value1,...)
% options = pso.optimset(oldopts,newopts)
%
% Description:
%
% psooptimset with no input or output arguments displays a complete list of
% parameters with their valid values.
% 
% options = psooptimset (with no input arguments) creates a structure
% called options that contains the options, or parameters, for the pso
% algorithm and sets parameters to [], indicating default values will be
% used.
% 
% options = psooptimset(@pso) creates a structure called options that
% contains the default options for the genetic algorithm.
% 
% options = psooptimset(@psomultiobj) creates a structure called options
% that contains the default options for psomultiobj. Not yet implemented
% 
% options = psooptimset('param1',value1,'param2',value2,...) creates a
% structure options and sets the value of 'param1' to value1, 'param2' to
% value2, and so on. Any unspecified parameters are set to their default
% values. Case is ignored for parameter names.
% 
% options = psooptimset(oldopts,'param1',value1,...) creates a copy of
% oldopts, modifying the specified parameters with the specified values.
% 
% options = psooptimset(oldopts,newopts) combines an existing options
% structure, oldopts, with a new options structure, newopts. Any parameters
% in newopts with nonempty values overwrite the corresponding old
% parameters in oldopts.
%
% Again, type psooptimset with no input arguments to display a list of
% options which may be set.
%
% NOTE regarding the ConstrBoundary option:
% The 'penalize' constraint management option as described in Perez 2007 is
% the default since it seems to provide the best combination of performance
% and versatility. It combines the best of the 'soft' and 'absorb' methods
% and adds a penalty calculated for every infeasible point in the search
% space.
%
% Although the 'penalize' method is preferred, the 'soft' or 'absorb' style
% boundaries may still be used. They are described below. They are not very
% effective if your problem contains any nonlinear equality constraints of
% the form ceq(x) = 0 or linear equality constraints of the form Aeq*x =
% beq. If your problem does not require any equality constraints, then
% calculations may be faster with 'soft' boundaries since infeasible
% solutions are not evaluated at all and simply assigned a fitness score of
% infinity.
%
% A 'soft' boundary allows particles to leave problem bounds, but sets
% their fitness scores to Inf if they do. This can save time, since
% infeasible points are not evaluated. This will also save you some trouble
% if your fitness function has the possibility of throwing errors if it
% tries to evaluate an infeasible point in the search space.
% 
% The 'reflect' and 'absorb' options prevent the particles from travelling
% outside the problem bounds at all. Note that 'reflect' has only been
% implemented for bounded constraints, and is not really suitable for any
% other problem type at this time. The 'absorb' method may suffer from poor
% performance if linear or nonlinear equality constraints are used. Both
% are likely to be deprecated in the near future.
%
% NOTE regarding cognitive and social attraction parameters:
% Perez and Behdinan (2007) demonstrated that the particle swarm is only
% stable if the following conditions are satisfied:
% Given that C0 = particle inertia
%            C1 = options.SocialAttraction
%            C2 = options.CognitiveAttraction
%    1) 0 < (C1 + C2) < 4
%    2) (C1 + C2)/2 - 1 < C0 < 1
% If conditions 1 and 2 are satisfied, the system will be guaranteed to
% converge to a stable equilibrium point. However, whether or not this
% point is actually the global minimum cannot be guaranteed, and its
% acceptability as a solution should be verified by the user.
%
% Bibliography
% RE Perez and K Behdinan. "Particle swarm approach for structural
% design optimization." Computers and Structures, Vol. 85:1579-88, 2007.
%
% See also:
% nb_pso, pso.do
%
% Written by S. Samuel Chen
% Edited by Kenneth S. Paulsen
% - Made it into a function of the pso package. 10/2018
% - Changed TimeLimit to MaxTime. 10/2018
% - Changed Generations to MaxIter. 10/2018
% - Changed PopulationSize to MaxNodes. 10/2018
% - Changed OutputFcns to OutputFcn. 10/2018
% - Removed the PlotFcns and PlotInterval options. 10/2018

% Copyright (c) 2009-2016, S. Samuel Chen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Default options
    options.CognitiveAttraction = 0.5 ;
    options.ConstrBoundary = 'penalize' ; 
    options.AccelerationFcn = @psoiterate ;
    options.DemoMode = 'off' ;
    options.Display = 'final' ;
    options.FitnessLimit = -inf ;
    options.HybridFcn = [] ;
    options.InitialPopulation = [] ;
    options.InitialVelocities = [] ;
    options.KnownMin = [] ;
    options.MaxIter = inf;
    options.MaxNodes = 20 ;
    options.MaxTime = inf ;
    options.OutputFcn = {} ;
    options.PopInitRange = [0;1] ;
    options.PopulationType = 'doubleVector' ;
    options.SocialAttraction = 1.25 ;
    options.StallGenLimit = 50 ;
    options.StallTimeLimit = Inf ;
    options.TolCon = 1e-6 ;
    options.TolFun = 1e-6 ;
    options.UseParallel = 'never' ;
    options.Vectorized = 'off' ;
    options.VelocityLimit = [] ;

    if ~nargin && ~nargout
        fprintf('\n')
        fprintf('Available options for pso.optimset {defaults in braces}:\n\n')
        fprintf('    AccelerationFcn: [Function handle | {@psoiterate}]\n') ;
        fprintf('CognitiveAttraction: [Positive scalar | {%g}]\n',options.CognitiveAttraction) ;
        fprintf('     ConstrBoundary: [''soft'' | ''penalize'' | ''reflect'' | ''absorb'' | {''%s''}]\n',options.ConstrBoundary) ;
        fprintf('            Display: [''off'' | ''final'' | ''diagnose'' | {''%s''}]\n',options.Display) ;
        fprintf('           DemoMode: [''fast'' | ''pretty'' | ''on'' | ''off'' | {''%s''}]\n',options.DemoMode) ;
        fprintf('       FitnessLimit: [Scalar | {%g}]\n',options.FitnessLimit) ;
        sprintf('          HybridFcn: [@fminsearch | @patternsearch | \n @fminunc | @fmincon | {[]}]\n')
        fprintf('  InitialPopulation: [empty matrix | nxnvars matrix | {[]}]\n')
        fprintf('  InitialVelocities: [empty matrix | nxnvars matrix | {[]}]\n')
        fprintf('            MaxIter: [Positive scalar | {%g} ]\n',options.MaxIter) ;
        fprintf('           MaxNodes: [Positive integer | {%g}]\n',options.MaxNodes) ;
        fprintf('            MaxTime: [Positive scalar (seconds) | {%g} ]\n',options.MaxTime) ;
        fprintf('          OutputFcn: [Cell array of function handles | function handle | {}]\n') ;
        fprintf('       PopInitRange: [2x1 vector | 2xnvars matrix | {%s}]\n',mat2str(options.PopInitRange)) ; 
        fprintf('     PopulationType: [''bitstring'' | ''doubleVector'' | {''%s''}]\n',options.PopulationType) ;
        fprintf('   SocialAttraction: [Positive scalar | {%g}]\n',options.SocialAttraction) ;
        fprintf('      StallGenLimit: [Positive integer | {%g} ]\n',options.StallGenLimit) ;
        fprintf('     StallTimeLimit: [Positive scalar (seconds) | {%g} ]\n',options.StallTimeLimit) ;
        fprintf('             TolFun: [Positive scalar | {%g}]\n',options.TolFun) ;
        fprintf('             TolCon: [Positive scalar | {%g}]\n',options.TolCon) ;
        fprintf('        UseParallel: [''always'' | ''never'' | {''%s''}]\n',options.UseParallel) ;
        fprintf('         Vectorized: [''on'' | ''off'' | {''%s''}]\n',options.Vectorized) ;
        fprintf('      VelocityLimit: [Positive scalar | {[]}]\n');
        fprintf('\n')
        clear options
        return
    end

    if ~nargin || isequal(varargin{1},@pso)
        return % Return default values
    elseif isstruct(varargin{1})
        oldoptions = varargin{1} ;
        fieldsprovided = fieldnames(oldoptions) ;
        if nargin == 2 && isstruct(varargin{2})
            newoptions = varargin{2} ;
            newfields = fieldnames(newoptions) ;
        end
    end

    requiredfields = fieldnames(options) ;

    % Find any input arguments that match valid field names. If they exist,
    % replace the default values with them.
    for i = 1:size(requiredfields,1)
        idx = find(cellfun(@(varargin)strcmpi(varargin,requiredfields{i,1}),...
            varargin)) ;
        if ~isempty(idx)
            options.(requiredfields{i,1}) = varargin(idx(end) + 1) ;
            options.(requiredfields{i,1}) = options.(requiredfields{i,1}){:} ;
        elseif exist('fieldsprovided','var')
            fieldidx = find(cellfun(@(fieldsprovided)strcmp(fieldsprovided,...
                requiredfields{i,1}),...
                fieldsprovided)) ;
            if ~isempty(fieldidx)
                options.(requiredfields{i,1}) = ...
                    oldoptions.(fieldsprovided{fieldidx}) ;
            end
            if exist('newfields','var')
                newfieldidx = find(cellfun(@(newfields)strcmp(newfields,...
                    requiredfields{i,1}),...
                    newfields)) ;
                if ~isempty(newfieldidx)
                    options.(requiredfields{i,1}) = ...
                        newoptions.(newfields{newfieldidx}) ;
                end
            end
        end % if ~isempty
    end % for i

    % Some robustness
    if isequal(size(options.PopInitRange),[1 2])
        options.PopInitRange = options.PopInitRange' ;
    end
    
end
