function [xf,xs,us,vs,xu] = nb_kalmansmoother_missing(model,y,z,varargin)
% Syntax:
%
% [xf,xs,us,vs,xu] = nb_kalmansmoother_missing(par,model,y,z,varargin)
%
% Description:
%
% Kalman smoother. With potentially missing observations!
%
% The model function must return the given matrices in the system
% below (I.e. d,H,R,T,c,A,B,Q,G):
%
% Observation equation:
% y(t) = d + H*x(t) + T*z(t) + v(t)
% 
% State equation:
% x(t) = c + A*x(t-1) + G*z(t) + B*u(t)
%
% Where u ~ N(0,Q) meaning u is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
%
% See for example: Koopman and Durbin (1998), "Fast filtering ans smoothing
% for multivariate state space models".
%
% Input:
%
% - model : A function handle returning the following matrices (in
%           this order):
%
%           > x0  : Initial state vector. As a nvar x 1 double.
%
%           > P0  : Initial state variance. As a nvar x nvar double.
%
%           > d   : Constant in the observation equation.
%
%           > H   : Observation matrix (defaults to identity).
%
%           > R   : Measurement noise covariance (required).
%
%           > c   : Constant in the state equation.
%
%           > A   : State transition matrix (defaults to identity).
%
%           > Q   : Process noise covariance (defaults to zero).
%
%           > B   : Input matrix, optional (defaults to zero).
%
%           > u   : Input control vector, optional (defaults to zero).
%
%           > obs : Index of observables in the vector of state 
%                   variables. A logical vector with size size(A,1)
%                   x 1.
%
% - y  : Observation vector. A nvar x nobs double.
%
% - z  : Observation vector of exogenous. A nxvar x nobs double.
%
% Optional input:
%
% - varargin : Optional inputs given to the function handle given
%              by the model input.
%
% Output:
%
% - xf : The filtered estimates of the x in the equation above. (x t+1|t)
%
% - xs : The smoothed estimates of the x in the equation above. (x t|T)
%
% - us : The smoothed estimates of the u in the equation above. (u t|T)
%
% - vs : The smoothed estimates of the v in the equation above. (v t|T)
%
% - xu : The updated estimates of the x in the equation above. (x t|t)
%
% See also:
% nb_kalmansmoother, nb_kalmanlikelihood_missing
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(z)
        z = zeros(0,size(y,2));
    end
    kalmanTol = eps^(0.9);

    % Get the (initial) state space matrices (could depend on the
    % hyperparamters of the model)
    %--------------------------------------------------------------
    [x0,P0,d,H,R,T,c,A,B,Q,G] = feval(model,varargin{:});
    
    % Initialize state estimate from first observation if needed
    %--------------------------------------------------------------
    [N,n]    = size(y);
    nEndo    = size(A,1);
    P        = nan(nEndo,nEndo,n+1);   % P t+1|t
    xf       = nan(nEndo,n+1);         % x t+1|t
    xu       = nan(nEndo,n);           % x t|t
    invF     = cell(1,n);
    AK       = cell(1,n);
    BQB      = B*Q*B';
    xf(:,1)  = x0;
    P(:,:,1) = P0;
    if size(H,3) == 1
        % We allow for the measurment equation to be time-varying
        H = H(:,:,ones(1,n));
    end
    
    % Loop through the kalman filter iterations
    %--------------------------------------------------------------
    singular = false(n,1);
    vf       = zeros(N,n);
    I        = eye(size(H,1));
    HT       = permute(H,[2,1,3]);
    AT       = A';
    m        = ~isnan(y);
    for tt = 1:n
        
        mt = m(:,tt);
        if all(~mt)
            xf(:,tt+1)  = A*xf(:,tt) + G*z(:,tt) + c;
            xu(:,tt)    = xf(:,tt);
            P(:,:,tt+1) = A*P(:,:,tt)*AT + BQB;
            invF{tt}    = 0;
            AK{tt}      = 0;
        else
        
            % Prediction for state vector and covariance:
            xt = A*xf(:,tt) + G*z(:,tt) + c; % x t|t-1
            Pt = P(:,:,tt);

            % Prediction for observation vector and covariance:
            Hmt    = H(mt,:,tt);
            nut    = y(mt,tt) - T(mt,:)*z(:,tt) - Hmt*xf(:,tt) - d(mt);
            PHT    = Pt*HT(:,mt,tt);
            F      = Hmt*PHT + R(mt,mt);
            rcondF = rcond(F);
            if isnan(rcondF)
                error([mfilename ':: Model is explosive. Forecast variance include nan.'])
            elseif rcondF < kalmanTol
                singular(tt) = true;
                if all(abs(F(:))) < kalmanTol
                    break
                else
                    xu(:,tt)    = xf(:,tt);
                    xf(:,tt+1)  = A*xf(:,tt) + c;
                    P(:,:,tt+1) = A*Pt*AT + BQB;
                    invF{tt}    = 0;
                    AK{tt}      = 0;
                end
            else

                % Kalman gain
                invF{tt} = I(mt,mt)/F;
                Kt       = PHT*invF{tt};
                AKt      = A*Kt;

                % Correction based on observation:
                xu(:,tt)    = xf(:,tt) + Kt*nut;         % x t|t
                xf(:,tt+1)  = xt + AKt*nut;              % x t+1|t
                P(:,:,tt+1) = (A - AKt*Hmt)*Pt*AT + BQB; % P t+1|t

                % Store filteres results
                AK{tt}    = AKt;
                vf(mt,tt) = nut;
                
            end
            
        end
         
    end
    
    if all(singular) 
        error('The variance of the forecast error remains singular until the end of the sample')
    elseif sum(singular) > n/2
        error('The share of the periods the kalman filter went singular is more than 50 percent.')
    end
    
    % Then we do the smoothing
    %-------------------------------------------------------------
    us  = nan(size(B,2),n);
    xs  = nan(nEndo,n);          
    r   = zeros(nEndo,n + 1);
    t   = n + 1;
    QBt = Q*B';
    while t > 1
        t      = t - 1;
        mt     = m(:,t);
        r(:,t) = AT*r(:,t+1);
        if any(mt) && ~singular(t)
            r(:,t) = r(:,t) + HT(:,mt,t)*(invF{t}*vf(mt,t) - AK{t}'*r(:,t+1)); 
        end
        xs(:,t) = xf(:,t) + P(:,:,t)*r(:,t);
        us(:,t) = QBt*r(:,t);
    end
    
    % Report the estimates
    %-------------------------------------------------------------
    vs = y;
    for tt = 1:n
        vs(:,tt) = y(:,tt) - H(:,:,tt)*xs(:,tt);
    end
    i     = isnan(vs);
    vs(i) = 0;
    vs    = vs';
    xs    = xs';
    us    = us';
    xf    = xf(:,2:end)';
    xu    = xu';

end
