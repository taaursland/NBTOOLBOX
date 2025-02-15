function [xOpt,fval,exitflag,output,population,scores] = do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% Syntax:
%
% x = pso.do(fitnessfcn,nvars)
% x = pso.do(fitnessfcn,nvars,Aineq,bineq)
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq)
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB)
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB,nonlcon)
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% x = pso.do(problem)
% [x, fval,exitflag] = pso.do(...)
% [x, fval,exitflag,output] = pso.do(...)
% [x, fval,exitflag,output,population] = pso.do(...)
% [x, fval,exitflag,output,population,scores] = pso.do(...)
%
% Description:
%
% Find the minimum of a function using Particle Swarm Optimization.
%
% This is an implementation of Particle Swarm Optimization algorithm using
% the same syntax as the Genetic Algorithm Toolbox, with some additional
% options specific to PSO. Allows code-reusability when trying different
% population-based optimization algorithms. Certain GA-specific parameters
% such as cross-over and mutation functions will not be applicable to the
% PSO algorithm. Demo function included, with a small library of test
% functions. Requires Optimization Toolbox.
%
% New features will be added regularly until this is made redundant by an
% official MATLAB PSO toolbox.
%
% x = pso.do(fitnessfcn,nvars)
% Runs the particle swarm algorithm with no constraints and default
% options. fitnessfcn is a function handle, nvars is the number of
% parameters to be optimized, i.e. the dimensionality of the problem. x is
% a 1xnvars vector representing the coordinates of the global optimum
% found by the pso algorithm.
%
% x = pso.do(fitnessfcn,nvars,Aineq,bineq)
% Linear constraints, such that Aineq*x <= bineq. Aineq is a matrix of size
% nconstraints x nvars, while b is a column vector of length nvars.
%
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq)
% Linear equality constraints, such that Aeq*x = beq. 'Soft' or 'penalize'
% boundaries only. If no inequality constraints exist, set Aineq and bineq
% to [].
%
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB)
% Lower and upper bounds defined as LB and UB respectively. Both LB and UB,
% if defined, should be 1 x nvars vectors. Use empty arrays [] for Aineq,
% bineq, Aeq, or beq if no linear constraints exist.
%
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB,nonlcon)
% Non-linear constraints. Nonlinear inequality constraints in the form c(x)
% <= 0 have now been implemented using 'soft' boundaries, or
% experimentally, using 'penalize' constraint handling method. See the
% Optimization Toolbox documentation for the proper syntax for defining
% nonlinear constraints. Use empty arrays [] for Aineq, bineq, Aeq, beq,
% LB, or UB if they are not needed.
%
% x = pso.do(fitnessfcn,nvars,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options)
% Default algorithm parameters replaced with those defined in the options
% structure:
% Use >> options = psooptimset('Param1,'value1','Param2,'value2',...) to
% generate the options structure. Type >> psooptimset with no input or
% output arguments to display a list of available options and their
% default values.
%
% NOTE: the swarm will perform better if the PopInitRange option is defined
% so that it closely bounds the expected domain of the feasible region.
% This is automatically done if the problem has both lower and upper bound
% constraints, but not for linear and nonlinear constraints.
%
% NOTE 2: If options.HybridFcn is to be defined, and if it is necessary to
% pass a non-default options structure to the hybrid function, then the
% options structure may be included in a cell array along with the pointer
% to the hybrid function. Example:
% >> % Let's say that we want to use fmincon to refine the result from PSO:
% >> hybridoptions = optimset(@fmincon) ;
% >> options.HybridFcn = {@fmincon, hybridoptions} ;
%
% NOTE 3:
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
% x = pso.do(problem)
% Parameters imported from problem structure.
%
% [x,fval] = pso.do(...)
% Returns the fitness value of the best solution.
%
% [x,fval,exitflag] = pso.do(...)
% Returns information on outcome of pso run. This should match exitflag
% values for GA where applicable, for code reuseability between the two
% toolboxes.
%
% [x,fval,exitflag,output] = pso.do(...)
% The structure output contains more detailed information about the PSO
% run. It should match output fields of GA, where applicable.
%
% [x,fval,exitflag,output,population] = pso.do(...)
% A matrix population of size MaxNodes x nvars, with the locations of
% particles across the rows. This may be used to save the final positions
% of all the particles in a swarm.
%
% [x,fval,exitflag,output,population,scores] = pso.do(...)
% Final scores of the particles in population.
%
% Bibliography
% J Kennedy, RC Eberhart, YH Shi. Swarm Intelligence. Academic Press, 2001.
%
% SM Mikki, AA Kishk. Particle Swarm Optimization: A Physics-Based
% Approach. Morgan & Claypool, 2008.
%
% RE Perez and K Behdinan. "Particle swarm approach for structural
% design optimization." Computers and Structures, Vol. 85:1579-88, 2007.
%
% See also:
% nb_pso, pso.optimset
%
% Written by S. Samuel Chen. Version 1.31.2.
% Available from http://www.mathworks.com/matlabcentral/fileexchange/25986
% Distributed under BSD license. First published in 2009.
%
% Edited by Kenneth S. Paulsen
% - Made it into a function of the pso package. 10/2018
% - Removed the default problem to solve. 11/2018

% Copyright (c) 2009-2016, S. Samuel Chen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isstruct(fitnessfcn)
        nvars   = fitnessfcn.nvars ;
        Aineq   = fitnessfcn.Aineq ;
        bineq   = fitnessfcn.bineq ;
        Aeq     = fitnessfcn.Aeq ;
        beq     = fitnessfcn.beq ;
        LB      = fitnessfcn.LB ;
        UB      = fitnessfcn.UB ;
        nonlcon = fitnessfcn.nonlcon ;
        if ischar(nonlcon) && ~isempty(nonlcon)
            nonlcon = str2func(nonlcon) ;
        end
        options    = fitnessfcn.options ;
        fitnessfcn = fitnessfcn.fitnessfcn ;
    elseif nargin < 2
        error('PSO requires at least two input arguments, or a problem structure. Type help pso.do for details')
    end

    if ~exist('options','var') % Set default options
        options = struct ;
    end % if ~exist

    options = pso.optimset(options) ;

    options.Verbosity = 1 ; % For options.Display == 'final' (default)
    if strcmpi(options.Display,'off')
        options.Verbosity = 0 ;
    elseif strncmpi(options.Display,'iter',4)
        options.Verbosity = 2 ;
    elseif strncmpi(options.Display,'diag',4)
        options.Verbosity = 3 ;
    end

    if ~exist('Aineq','var'), Aineq = [] ; end
    if ~exist('bineq','var'), bineq = [] ; end
    if ~exist('Aeq','var'), Aeq = [] ; end
    if ~exist('beq','var'), beq = [] ; end
    if ~exist('LB','var'), LB = [] ; end
    if ~exist('UB','var'), UB = [] ; end
    if ~exist('nonlcon','var'), nonlcon = [] ; end

    % Check for swarm stability
    % -------------------------------------------------------------------------
    if options.SocialAttraction + options.CognitiveAttraction >= 4 && ...
            options.Verbosity > 2
        msg = 'Warning: Swarm is unstable and may not converge ' ;
        msg = [msg 'since the sum of the cognitive and social attraction'] ;
        msg = [msg ' parameters is greater than or equal to 4.'] ;
        msg = [msg ' Suggest adjusting options.CognitiveAttraction and/or'] ;
        sprintf('%s options.SocialAttraction.',msg)
    end
    % -------------------------------------------------------------------------

    % Check for constraints and bit string population type
    % -------------------------------------------------------------------------
    if strncmpi(options.PopulationType,'bitstring',2) && ...
            (~isempty([Aineq,bineq]) || ~isempty([Aeq,beq]) || ...
            ~isempty(nonlcon) || ~isempty([LB,UB]))
        Aineq = [] ; bineq = [] ; Aeq = [] ; beq = [] ; nonlcon = [] ;
        LB = [] ; UB = [] ;
        if options.Verbosity > 2
            msg = sprintf('Constraints will be ignored') ;
            msg = sprintf('%s for options.PopulationType ''bitstring''',msg) ;
            warning('%s',msg) ;
        end
    end
    % -------------------------------------------------------------------------

    % Change this when nonlcon gets fully implemented:
    % -------------------------------------------------------------------------
    if ~isempty(nonlcon) && strcmpi(options.ConstrBoundary,'reflect')
        if options.Verbosity > 2
            msg = 'Non-linear constraints don''t have ''reflect'' boundaries' ;
            msg = [msg, ' implemented.'] ;
            warning('pso:main:nonlcon',...
                '%s Changing options.ConstrBoundary to ''penalize''.',...
                msg)
        end
        options.ConstrBoundary = 'penalize' ;
    end
    % -------------------------------------------------------------------------

    % Is options.PopInitRange reconcilable with LB and UB constraints?
    % -------------------------------------------------------------------------
    % Resize PopInitRange in case it was given as one range for all dimensions
    if size(options.PopInitRange,1) ~= 2 && size(options.PopInitRange,2) == 2
        % Transpose PopInitRange if user provides nvars x 2 matrix instead
        options.PopInitRange = options.PopInitRange' ;
    elseif size(options.PopInitRange,2) == 1 && nvars > 1
        % Resize PopInitRange in case it was given as one range for all dim
        options.PopInitRange = repmat(options.PopInitRange,1,nvars) ;
    elseif size(options.PopInitRange,2) ~= nvars
        msg = 'Number of dimensions of options.PopInitRange does not' ;
        msg = sprintf('%s match nvars. PopInitRange should be a',msg) ;
        error('%s  2 x 1 or 2 x nvars matrix.',msg) ;
    end

    % Check initial population with respect to bound constraints
    % Is this really desirable? Maybe there are some situations where the user
    % specifically does not want a uniform inital population covering all of
    % LB and UB?
    if ~isempty(LB) || ~isempty(UB)
        options.LinearConstr.type = 'boundconstraints' ;
        if isempty(LB)
            LB = -inf*ones(1,nvars);
        end
        if isempty(UB)
            UB =  inf*ones(1,nvars) ;
        end
        LB = reshape(LB,1,[]) ;
        UB = reshape(UB,1,[]) ;
        options.PopInitRange = ...
            psocheckpopulationinitrange(options.PopInitRange,LB,UB) ;
    end
    % -------------------------------------------------------------------------

    % Check validity of VelocityLimit
    % -------------------------------------------------------------------------
    if all(~isfinite(options.VelocityLimit))
        options.VelocityLimit = [] ;
    elseif isscalar(options.VelocityLimit)
        options.VelocityLimit = repmat(options.VelocityLimit,1,nvars) ;
    elseif ~isempty(length(options.VelocityLimit)) && ...
            ~isequal(length(options.VelocityLimit),nvars)
        msg = 'options.VelocityLimit must be either a positive scalar' ;
        error('%s, or a vector of size 1xnvars.',msg)
    end % if isscalar
    options.VelocityLimit = abs(options.VelocityLimit) ;
    % -------------------------------------------------------------------------

    % Setup for parallel computing
    % -------------------------------------------------------------------------
    if strcmpi(options.UseParallel,'always')
        if strcmpi(options.Vectorized,'on')
            if options.Verbosity > 2 
                msg = 'Both ''Vectorized'' and ''UseParallel'' options have ' ;
                msg = [msg 'been set. The problem will be computed locally '] ;
                warning('%s using the ''Vectorized'' computation method.',...
                    msg) ;
            end
        elseif isempty(ver('distcomp')) % Check for toolbox installed
            if options.Verbosity > 2 
                msg = 'Parallel computing toolbox not installed. Problem' ;
                warning('%s will be computed locally instead.',msg) ;
            end
            options.UseParallel = 'never' ;
        else
            poolalreadyopen = false ;
            if isempty(gcp('nocreate'))
                poolobj = parpool ;
                addAttachedFiles(poolobj,which(func2str(fitnessfcn))) ;
            else
                poolalreadyopen = true ;
            end
        end
    end
    % -------------------------------------------------------------------------

    % Generate swarm initial state (this line must not be moved)
    % -------------------------------------------------------------------------
    if strncmpi(options.PopulationType,'double',2)
        state = psocreationuniform(options,nvars) ;
    elseif strncmpi(options.PopulationType,'bi',2) % Bitstring variables
        state = psocreationbinary(options,nvars) ;
    end
    % -------------------------------------------------------------------------

    % Check initial population with respect to linear and nonlinear constraints
    % -------------------------------------------------------------------------
    if ~isempty(Aeq) || ~isempty(Aineq) || ~isempty(nonlcon)
        options.LinearConstr.type = 'linearconstraints' ;
        if ~isempty(nonlcon)
            options.LinearConstr.type = 'nonlinearconstraints' ;
        end
        if strcmpi(options.ConstrBoundary,'reflect')
            options.ConstrBoundary = 'penalize' ;
            if options.Verbosity > 2
                msg = sprintf('Constraint boundary behavior ''reflect''') ;
                msg = sprintf('%s is not supported for linear constraints.',...
                    msg) ;
                msg = sprintf('%s Switching to ''penalize'' method.',msg) ;
                warning('pso:mainfcn:constraintbounds',...
                    '%s',msg)
            end
        end
        [state,options] = psocheckinitialpopulation(state,...
            Aineq,bineq,Aeq,beq,...
            LB,UB,...
            nonlcon,...
            options) ;
    end
    % -------------------------------------------------------------------------

    % Check constraint type
    % -------------------------------------------------------------------------
    if isa(options.ConstrBoundary,'function_handle')
        boundcheckfcn = options.ConstrBoundary ;
    elseif strcmpi(options.ConstrBoundary,'soft')
        boundcheckfcn = @psoboundssoft ;
    elseif strcmpi(options.ConstrBoundary,'penalize')
        boundcheckfcn = @psoboundspenalize ;
    elseif strcmpi(options.ConstrBoundary,'reflect')
        boundcheckfcn = @psoboundsreflect ;
    elseif strcmpi(options.ConstrBoundary,'absorb')
        boundcheckfcn = @psoboundsabsorb ;
    end
    % -------------------------------------------------------------------------
    
    exitflag              = 0 ; % Default exitflag, for max iterations reached.
    flag                  = 'init' ;
    state.fitnessfcn      = fitnessfcn ;
    state.LastImprovement = 1 ;
    state.ParticleInertia = 0.9 ; % Initial inertia

    % Iterate swarm
    % -------------------------------------------------------------------------
    n           = options.MaxNodes ; 
    itr         = options.MaxIter ;
    k           = 0;
    ind         = 0;
    averagetime = 0 ; 
    stalltime   = 0;
    tic
    while k < options.MaxIter
        
        % When MaxIter == inf we need to update the fGlobalBest from time
        % to time
        k   = k + 1;
        ind = ind + 1;
        if ind == size(state.fGlobalBest,1) + 1
        	ind = state.StallGenLimit + 1; 
        end
        
        state.Score       = inf*ones(n,1) ; % Reset fitness vector
        state.Penalties   = zeros(n,1) ; % Reset all penalties
        state.iteration   = k ;
        state.OutOfBounds = false(options.MaxNodes,1) ;

        % Check bounds before proceeding
        % ---------------------------------------------------------------------
        if ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]),isempty([LB;UB]), isempty(nonlcon)])
            state = boundcheckfcn(state,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options) ;
        end % if ~isempty
        % ---------------------------------------------------------------------

        % Evaluate fitness, update the local bests
        % ---------------------------------------------------------------------
        % Apply constraint violation penalties, if applicable
        if strcmpi(options.ConstrBoundary,'penalize') % EXPERIMENTAL
            if strcmpi(options.Vectorized,'on') % Vectorized fitness function
                state.Score = fitnessfcn(state.Population) ;
            elseif strcmpi(options.UseParallel,'always') % Parallel computing
                scoretmp = inf*ones(n,1) ;
                x        = state.Population ;
                parfor i = 1:n
                    scoretmp(i) = fitnessfcn(x(i,:)) ;
                end % for i
                state.Score = scoretmp ;
                clear scoretmp x
            else % Default
                for i = 1:n
                    state.Score(i) = fitnessfcn(state.Population(i,:)) ;
                end % for i
            end % if strcmpi

            if ~all([isempty([Aineq,bineq]), isempty([Aeq,beq]), isempty([LB;UB]), isempty(nonlcon)])
                state = psocalculatepenalties(state) ;
            end
        else % DEFAULT (STABLE)
            % Note that this code does not calculate fitness values for
            % particles that are outside the search space constraints.
            if strcmpi(options.Vectorized,'on')  % Vectorized fitness function
                state.Score(not(state.OutOfBounds)) = fitnessfcn(state.Population(not(state.OutOfBounds),:)) ;
            elseif strcmpi(options.UseParallel,'always') % Parallel computing
                % Thanks to Oliver and Mike for contributing this code.
                validi   = find(not(state.OutOfBounds))' ;
                nvalid   = numel(validi);
                x        = state.Population(validi,:);
                scoretmp = inf*ones(nvalid,1) ;

                parfor i = 1:nvalid
                    scoretmp(i) = fitnessfcn(x(i,:)) ;
                end % for i

                for i = 1:nvalid
                    state.Score(validi(i)) = scoretmp(i) ;
                end
                clear scoretmp x
            else
                for i = find(not(state.OutOfBounds))'
                    state.Score(i) = fitnessfcn(state.Population(i,:)) ;
                end % for i
            end % if strcmpi
        end
        % ---------------------------------------------------------------------

        % Update the local bests
        % ---------------------------------------------------------------------
        betterindex                      = state.Score < state.fLocalBests ;
        state.fLocalBests(betterindex)   = state.Score(betterindex) ;
        state.xLocalBests(betterindex,:) = state.Population(betterindex,:) ;
        % ---------------------------------------------------------------------

        % Update the global best and its fitness, then check for termination
        % ---------------------------------------------------------------------
        [minfitness, minfitnessindex] = min(state.Score) ;
        if k == 1 || minfitness < state.fGlobalBest(ind-1)
            stalltime              = toc ;
            state.fGlobalBest(ind) = minfitness ;
            state.xGlobalBest      = state.Population(minfitnessindex,:) ;
            state.LastImprovement  = k ;
            imprvchk               = ind > options.StallGenLimit && ...
                (state.fGlobalBest(ind - options.StallGenLimit) - state.fGlobalBest(ind))...
                / (k - options.StallGenLimit) < options.TolFun ;
                
            if imprvchk
                exitflag = 1 ;
                flag     = 'done' ;
            elseif state.fGlobalBest(ind) < options.FitnessLimit
                exitflag = 2 ;
                flag     = 'done' ;
            end % if k
        else % No improvement from last iteration
            state.fGlobalBest(ind) = state.fGlobalBest(ind-1) ;
        end % if minfitness
        
        % This field is usually reported by the other optimizers!
        state.fval = state.fGlobalBest(ind);

        stallchk = k - state.LastImprovement >= options.StallGenLimit ;
        if stallchk
            % No improvement in global best for StallGenLimit generations
            exitflag = 3 ; 
            flag     = 'done' ;
        end

        if stalltime - toc > options.StallTimeLimit
            % No improvement in global best for StallTimeLimit seconds
            exitflag = -4 ; 
            flag     = 'done' ;
        end

        if toc + averagetime > options.MaxTime
            % Reached total simulation time of TimeLimit seconds
            exitflag = -5 ; 
            flag     = 'done' ;
        end
        % ---------------------------------------------------------------------

        % Update flags, state and plots before updating positions
        % ---------------------------------------------------------------------
        if k == 2 
            flag = 'iter' ; 
        end
        if k == itr
            flag     = 'done' ;
            exitflag = 0 ;
        end

        if ~isempty(options.OutputFcn)
            if iscell(options.OutputFcn)
                for i = 1:length(options.OutputFcn)
                    options.OutputFcn{i}(state.xGlobalBest(:),state,flag) ;
                end % for i
            else
                options.OutputFcn(state.xGlobalBest(:),state,flag) ;
            end
        end % if ~isempty

        if strcmpi(flag,'done')
            break
        end % if strcmpi
        % ---------------------------------------------------------------------

        % Update the particle velocities and positions
        % ---------------------------------------------------------------------
        state = options.AccelerationFcn(options,state,flag) ;
        % ---------------------------------------------------------------------
        averagetime = toc/k ;
        
    end % for k
    % -------------------------------------------------------------------------

    % Assign output variables and generate output
    % -------------------------------------------------------------------------
    xOpt = state.xGlobalBest ;
    fval = state.fGlobalBest(k) ; % Best fitness value
    
    % Final population: (hopefully very close to each other)
    population         = state.Population ;
    scores             = state.Score ; % Final scores (NOT local bests)
    output.iterations  = k ; % Number of iterations performed
    clear state

    output.message = psogenerateoutputmessage(options,output,exitflag) ;
    if options.Verbosity > 0 
        fprintf('\n%s\n',output.message) ;
    end
    
    % -------------------------------------------------------------------------

    % Check for hybrid function, run if necessary
    % -------------------------------------------------------------------------
    if ~isempty(options.HybridFcn) && exitflag ~= -1
        [xOpt,fval] = psorunhybridfcn(fitnessfcn,xOpt,Aineq,bineq,Aeq,beq,LB,UB,nonlcon,options) ;
    end
    % -------------------------------------------------------------------------

    % Wrap up
    % -------------------------------------------------------------------------
    if strcmpi(options.UseParallel,'always') && ~poolalreadyopen
        delete(gcp('nocreate')) ;
    end
    
end
