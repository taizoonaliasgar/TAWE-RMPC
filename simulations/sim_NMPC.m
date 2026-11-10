%% Nonlinear MPC (CasADi + Ipopt)
% Reproduces: Sec. 5.2.2, Fig. 7, Table 2
%
% Part of TAWE-RMPC, the code accompanying "Robust Model Predictive Control of a
% Tremor-Suppression Exoskeleton under Tremor-Induced Disturbances" (ASME JDSMC).
% Run setup_paths once per session, then run this script. Results are written
% to results/rerun/. Optional variables you can set before running:
%   scenario  - 'setpoint' (default) or 'sine'
%   seed      - random seed (default 0)

%% Configuration
if ~exist('scenario','var'), scenario = 'setpoint'; end
if ~exist('seed','var'), seed = 0; end
rng(seed);
outDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'rerun');
if ~isfolder(outDir), mkdir(outDir); end

%% Load Model Parameters
TAWE_Parameters; 

tSpan1 = 0:hh:10; %Simulation Time Span

% State vector qq and qqdot, which are:
% (1) Wrist Radial Ulnar Deviation (RUD) (rad) Rotation on z axis in the wrist frame
% (2) Wrist Flexion Extension (FE) (rad) Rotation on x axis in the wrist frame
% (3) Wrist Pronation Supination (SP) (rad), which is constrained to FE and
%     RUD, Rotation on y axis in the wrist frame
% (4-9) TAWE Mechanism Joint Angles (rad)
simStateVal=zeros(18,1);
simParamVal=ppValSim; % Simulation Parameters
ctrlParamVal=ppValCtrlNoWKI; % Controller Parameters

% The input vectors uu are defined as 
% (1-2) human inputs at the wrist FE and RUD directions
% (3-4) control input from TAWE at the first two links
% (5-8) virtual input at the load tetrahedron vertices (-z direction) 
%       (for center of mass estimation), used to acquire the Jacobian for 
%       uncertain load parameter more conveniently. Considered 0 for this
%       simulation (to be explored in future works)

simInputVal=zeros(8,1); % Used for simulation 
ctrllnputVal=zeros(8,1); % Used for controller calculation only
%taweInput=zeros(2,1); % The TAWE input term

consForce=zeros(7,1); % Constraint force for simulation process (not used in controller design)

nhSignal=zeros(3,1);

simStateData=zeros(18,numel(tSpan1)); % Store state data from simulation
simInputData=zeros(8,numel(tSpan1)); % Store inputs
tremortorque = zeros(2,numel(tSpan1));

hor=15;            % Horizon
%load('simTAWERef','refData','refdtData','refddtData');

load('simTAWERef','tremorData');
[refData, refdtData] = make_reference(scenario, tSpan1, hor);



J0 =zeros(numel(tSpan1),1);
qdotdel = zeros(8,numel(tSpan1));
qdotdel_current = zeros(18,numel(tSpan1));
comparingdq = zeros(16,numel(tSpan1));
%%

import casadi.*
% 1. Create Symbolic Variables for the NLP
n_q = 18; n_u = 2; n_l = 7; n_qi = 4;% Match your parameters
X = SX.sym('X', n_q*(hor+1),1);
U = SX.sym('U', n_u*hor,1);
L = SX.sym('L', n_l*hor,1);

P_param = SX.sym('P_param', n_qi*hor + n_q,1); % Current state + Reference Trajectory
casadiModel = fullfile(fileparts(mfilename('fullpath')), '..', 'model', 'nmpc', 'robot_dynamics_nmpc_hDE.casadi');
if ~isfile(casadiModel), gunzip([casadiModel '.gz']); end % 117 MB unpacked, ships gzipped
fast_dyn = Function.load(casadiModel);

u0 = zeros(n_u*hor,1);
x0 = zeros(n_q*(hor+1),1);
l0 = zeros(n_l*(hor),1);
% uin = zeros(2,1);
%%
% 2. Build your Objective and Constraints (Logic from your current mpc_Casadi2)
% Note: Use your compiled MEX here: fast_dyn = external('gen_dynamics4', './gen_dynamics4.mexa64');
% ... build 'obj' and 'g_constraints' ...

% 3. Create the Solver Object
R=0.4*eye(2);
% Q1=diag([8000 500 0.01 0.01]);P1 = Q1;      
Q2=diag([8000 500 100 100]);P2 = Q2; 

% Q2 = 0.001*eye(18);
% Q2(1,1) = 8000;
% Q2(2,2) = 500;
% Q2(10,10) = 100;
% Q2(11,11) = 100;
% P2 = Q2;

R_l = 0.001*eye(7);

xx_lb = [-0.8;-1.5;-3*pi/2;-3*pi/2];xx_ub = [0.45;1.5;3*pi/2;3*pi/2];
x_qlb = -pi*ones(9,1);x_qub = pi*ones(9,1);
x_qlb(1:2) = xx_lb(1:2);x_qub(1:2) = xx_ub(1:2);

x_dqlb = -50*pi*ones(9,1);x_dqub = 50*pi*ones(9,1);
x_dqlb(1:2) = xx_lb(3:4);x_dqub(1:2) = xx_ub(3:4);

x_full_lb = [x_qlb;x_dqlb]; x_full_ub = [x_qub;x_dqub];

uMin=[-9.5;-12.2];uMax=[11;7.1];

l_min = -1e6*ones(7,1); l_max = 1e6*ones(7,1);
     
% obj1 = getcost(X,U,L,P_param,Q1,R,P1,hor,n_q,n_u);
obj2 = getcost(X,U,L,P_param,Q2,R,P2,R_l,hor,n_q,n_u,n_l,n_qi);

bounds = getstatebounds(uMin,uMax,x_full_lb,x_full_ub,l_min,l_max,n_q,n_l,hor);
% g_constraints = casadiconstraints(hor, X, U,P_param, hh,n_q,n_u,fast_dyn);
g_constraints = casadiconstraints2(hor,X,U,L,P_param, hh,n_q,n_u,n_l,n_qi,fast_dyn);
%%

% nlp1 = struct('x', [X; U; L], 'f', obj1, 'g', g_constraints, 'p', P_param);
nlp2 = struct('x', [X; U; L], 'f', obj2, 'g', g_constraints, 'p', P_param);
%%
opts = struct;
opts.ipopt.print_level = 0;
opts.print_time = false; 
opts.ipopt.warm_start_init_point = 'yes';
opts.ipopt.max_iter = 5;
opts.ipopt.acceptable_tol = 1e-2;
opts.ipopt.acceptable_iter = 5; % If it's "good enough" for 5 iterations, stop.
% opts.qpsol = 'qrqp';
% opts.ipopt.linear_solver = 'ma57'; % If available
% solver_obj17= nlpsol('solver', 'ipopt', nlp1, opts);
% solver_obj11 = nlpsol('solver', 'sqpmethod', nlp1, opts);
solver_obj_full = nlpsol('solver', 'ipopt', nlp2, opts);
%%

% Simulation Loop
disp('Running MPC Casadi');
tic;
for ii=1:numel(tSpan1)

    % just for checkpoint
    if rem(ii,100)==1
        disp(ii+" of "+numel(tSpan1)+" steps completed")
    end
    
    tt=tSpan1(ii); % Update time variable
    simStateData(:,ii)=simStateVal(1:end); % Store qq
    path2 = [refData(:,ii+1:1:ii+hor);refdtData(:,ii+1:1:ii+hor)]; %reference path

    disttt = [0;0];
    distflag = 0;

    if(tSpan1(ii)>3 && tSpan1(ii)<7)
         distflag = 1;
         disttt = tremorData(:,ii);
    end

    Q_dep_sim = [simStateVal(3:9); simStateVal(12:18)];
    Q_ind_sim = [simStateVal(1:2); simStateVal(10:11)];
    
    % [M_num, C_num, ~, J_num, h_num] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [M_num(:); C_num(:); h_num(:); J_num(:)];
    % [M_num, ~,~,~,~] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [M_num(:)];
    % [M_num, C_num, ~, ~, ~] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [M_num(:); C_num(:)];
    % [M_num, C_num, ~, ~, h_num] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [M_num(:); C_num(:);h_num(:)];
    % [M_num, C_num, ~, J_num, h_num] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [M_num(:); C_num(:);h_num(:);J_num(:)];
    % [~, C_num, ~, ~, ~] = fast_dyn(Q_ind_sim, Q_dep_sim, zeros(4,1), zeros(2,1), zeros(2,1));
    % dyn_p = [C_num(:)];

    dyn_p = [];
  
    [x_opt,u_opt,l_opt] = mpc_Casadi_full(solver_obj_full,bounds,simStateVal,hor,path2,u0,x0,l0,n_q,n_u,n_l,n_qi,dyn_p);%[0;0]
     
    simInputVal(3:4)=u_opt(1:n_u); % Insert MPC input for simulation
    
    % Using Runge Kutta 4th method to integrate system ODE
    [simStateVal,nhSignal,consForce,~,~,dqrk4,td1]=rk4Hybrid(@Flow_TAWE,hh,flowNum,tSpan1(ii),...
                                        simStateVal,simParamVal,simInputVal,nhSignal,consForce,disttt);
                                    
    
    simInputData(:,ii)=simInputVal(1:end);
    u0 = [u_opt(n_u+1:end);u_opt(end-n_u+1:end)];
    x0 = [x_opt(n_q+1:end);x_opt(end-n_q+1:end)];
    l0 = [l_opt(n_l+1:end);l_opt(end-n_l+1:end)];
    uin = u_opt(1:n_u);
    % display(ii)
end
toc;

%% Save results
runName = ['NMPC_' scenario];
save(fullfile(outDir, ['state_' runName '.mat']), 'simStateData');
save(fullfile(outDir, ['input_' runName '.mat']), 'simInputData');
save(fullfile(outDir, ['tremor_torque_' runName '.mat']), 'tremortorque');
fprintf('Saved %s results to %s\n', runName, outDir);

%Store Simulation data to plot (Uncomment to Run)

%%

function obj = getcost(X,U,L,P_param,Q,R,P,R_l,hor,n_q,n_u,n_l,n_qi)

    obj = 0;
    err = [X(1:2);X(10:11)] - [P_param(n_qi*hor+(1:2));P_param(n_qi*hor+(10:11))];
    u_input = U(1:n_u);
    lambda = L(1:n_l);
        
    obj = obj + err'*Q*err + u_input'*R*u_input + lambda'*R_l*lambda;
    
    for k=2:hor
        err = [X(n_q*(k-1)+(1:2));X(n_q*(k-1)+(10:11))] - P_param(n_qi*(k-2)+(1:n_qi));
        u_input = U(n_u*(k-1)+(1:n_u));
        lambda = L(n_l*(k-1)+(1:n_l));
        
        obj = obj + err'*Q*err + u_input'*R*u_input + lambda'*R_l*lambda;
    end

    err = [X(n_q*hor+(1:2));X(n_q*hor+(10:11))] - P_param(n_qi*(hor-1)+(1:n_qi));
    obj = obj + err'*P*err;
    
end

function g = casadiconstraints(hor, X, U,L,P_param, hh,n_q,n_u,n_l,n_qi,fast_dyn)
    % import casadi.*
    g = {}; 
    x0 = P_param(n_qi*hor+(1:18));

    % Q_dep = [x0(3:9); x0(12:18)];
    % Q_ind = [x0(1:2); x0(10:11)];
    % uin = P_param(n_q*hor+18+(1:2));

    % M = reshape(P_param(n_q*hor+18+2+(1:4)),2,2);
    % C = reshape(P_param(n_q*hor+18+2+(1:4)),2,2);
    % h = reshape(P_param(n_q*hor+18+2+4+4+(1:2)),2,1);
    % J = reshape(P_param(n_q*hor+18+2+4+4+2+(1:4)),2,2);

    g{end+1} = X(1:n_q) - x0;%Q_ind;
    
    for k = 1:hor
        x_curr = X(n_q*(k-1)+(1:n_q));
        x_next = X(n_q*(k)+(1:n_q));
        u_input = U(n_u*(k-1)+(1:n_u));
        lambda = L(n_l*(k-1)+(1:n_l));

        % [M, C, ~, J,h] = fast_dyn(x_curr, Q_dep, zeros(4,1), zeros(2,1), zeros(2,1));
        [M, C, h, Ju,Jc,dJc] = fast_dyn(x_curr);
        
        q_dot = x_curr(n_q/2+1:n_q); % Correct indexing for 4-state [q; qdot]
        % Solve for q_ddot without symbolic inversion
        q_ddot = solve(M, Ju(:,3:4)*u_input + h - C*q_dot + transpose(Jc)*lambda);
        x_next_euler = x_curr + hh * [q_dot; q_ddot];
        
        % Constrain the gap to be zero
        g{end+1} = Jc*q_ddot + reshape(dJc,7,9)* q_dot;
        g{end+1} = x_next - x_next_euler ;
        
    end
    
    % Return a single column vector of all constraints
    g = vertcat(g{:});
end


function g = casadiconstraints2(hor, X, U,L,P_param, hh,n_q,n_u,n_l,n_qi,fast_dyn)
    % import casadi.*
    g = {}; 
    x0 = P_param(n_qi*hor+(1:18));

    % Q_dep = [x0(3:9); x0(12:18)];
    % Q_ind = [x0(1:2); x0(10:11)];
    % uin = P_param(n_q*hor+18+(1:2));

    % M = reshape(P_param(n_q*hor+18+2+(1:4)),2,2);
    % C = reshape(P_param(n_q*hor+18+2+(1:4)),2,2);
    % h = reshape(P_param(n_q*hor+18+2+4+4+(1:2)),2,1);
    % J = reshape(P_param(n_q*hor+18+2+4+4+2+(1:4)),2,2);

    g{end+1} = X(1:n_q) - x0;%Q_ind;
    
    for k = 1:hor

        x_curr = X(n_q*(k-1)+(1:n_q));
        x_next = X(n_q*(k)+(1:n_q));
        u_input = U(n_u*(k-1)+(1:n_u));
        lambda = L(n_l*(k-1)+(1:n_l));
        
        
        % [M, C, ~, J,h] = fast_dyn(x_curr, Q_dep, zeros(4,1), zeros(2,1), zeros(2,1));
        [M, C, h, Ju,Jc,dJc] = fast_dyn(x_curr);
        
        q_dot = x_curr(n_q/2+1:n_q); % Correct indexing for 4-state [q; qdot]
        q_ddot = (x_next(10:18) - x_curr(10:18)) / hh;
        
        % Constrain the gap to be zero
        g{end+1} = Jc*q_ddot + reshape(dJc,7,9)* q_dot;
        g{end+1} = x_next(1:9) - (x_curr(1:9) + hh * q_dot);
        g{end+1} = M*q_ddot + C*q_dot - h - Ju(:,3:4)*u_input - transpose(Jc)*lambda;

    end
    
    % Return a single column vector of all constraints
    g = vertcat(g{:});
end

function bounds = getstatebounds(uMin,uMax,xx_lb,xx_ub,l_min, l_max,n_q,n_l,hor)%(uMin,uMax,xx_lb,xx_ub,n_q,hor)
    
    lb_X = repmat(xx_lb, 1, hor + 1);
    ub_X = repmat(xx_ub, 1, hor + 1);
    
    lb_U = repmat(uMin, 1, hor);
    ub_U = repmat(uMax, 1, hor);

    lb_L = repmat(l_min, 1, hor);
    ub_L = repmat(l_max, 1, hor);

    % 3. Package into a struct for easy access
    bounds.lbx = [lb_X(:); lb_U(:); lb_L(:)];
    bounds.ubx = [ub_X(:); ub_U(:); ub_L(:)];
    
    % 4. Dynamics Equality Constraints (g)
    % For nlpsol, the dynamics equations xnext - f(x,u) must equal 0
    % There are (n_q * hor) such equations
    bounds.lbg = zeros(n_q * (hor+1) + n_l*hor, 1);
    bounds.ubg = zeros(n_q * (hor+1) + n_l*hor, 1);

end