%%
import casadi.*

q1dev__dt_0_s = SX.sym('q1dev__dt_0_s'); q1flex__dt_0_s = SX.sym('q1flex__dt_0_s'); q1sup__dt_0_s = SX.sym('q1sup__dt_0_s'); q2w1__dt_0_s = SX.sym('q2w1__dt_0_s'); q2w2__dt_0_s = SX.sym('q2w2__dt_0_s'); q2w3__dt_0_s = SX.sym('q2w3__dt_0_s'); q2w4__dt_0_s = SX.sym('q2w4__dt_0_s'); q2w5__dt_0_s=SX.sym('q2w5__dt_0_s'); q2w6__dt_0_s=SX.sym('q2w6__dt_0_s');
q1dev__dt_1_s = SX.sym('q1dev__dt_1_s'); q1flex__dt_1_s = SX.sym('q1flex__dt_1_s'); q1sup__dt_1_s = SX.sym('q1sup__dt_1_s'); q2w1__dt_1_s = SX.sym('q2w1__dt_1_s'); q2w2__dt_1_s = SX.sym('q2w2__dt_1_s'); q2w3__dt_1_s = SX.sym('q2w3__dt_1_s'); q2w4__dt_1_s = SX.sym('q2w4__dt_1_s'); q2w5__dt_1_s=SX.sym('q2w5__dt_1_s'); q2w6__dt_1_s=SX.sym('q2w6__dt_1_s');

handmpt1s=SX.sym('handmpt1s'); handmpt2s=SX.sym('handmpt2s'); handmpt3s=SX.sym('handmpt3s'); handmpt4s=SX.sym('handmpt4s');
u1devs=SX.sym('u1devs'); u1flexs=SX.sym('u1flexs'); u21s=SX.sym('u21s'); u22s=SX.sym('u22s');
%%

C_str = char(CC_lin2);
C_str_subs = strrep(C_str,'q1dev__dt_0_','q1dev__dt_0_s');
C_str_subs = strrep(C_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
C_str_subs = strrep(C_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
C_str_subs = strrep(C_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
C_str_subs = strrep(C_str_subs,'q1dev__dt_1_','q1dev__dt_1_s');
C_str_subs = strrep(C_str_subs,'q1flex__dt_1_','q1flex__dt_1_s');
C_str_subs = strrep(C_str_subs,'q1sup__dt_1_','q1sup__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w1__dt_1_','q2w1__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w2__dt_1_','q2w2__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w3__dt_1_','q2w3__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w4__dt_1_','q2w4__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w5__dt_1_','q2w5__dt_1_s');
C_str_subs = strrep(C_str_subs,'q2w6__dt_1_','q2w6__dt_1_s');
C_casadi = eval(C_str_subs);
%%
M_str = char(MM_lin2);
M_str_subs = strrep(M_str,'q1dev__dt_0_','q1dev__dt_0_s');
M_str_subs = strrep(M_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
M_str_subs = strrep(M_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
M_str_subs = strrep(M_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
M_casadi = eval(M_str_subs);

%%
state_new = [q1dev__dt_0_s;q1flex__dt_0_s;q1sup__dt_0_s;q2w1__dt_0_s;q2w2__dt_0_s;q2w3__dt_0_s;q2w4__dt_0_s;q2w5__dt_0_s;q2w6__dt_0_s;...
                        q1dev__dt_1_s;q1flex__dt_1_s;q1sup__dt_1_s;q2w1__dt_1_s;q2w2__dt_1_s;q2w3__dt_1_s;q2w4__dt_1_s;q2w5__dt_1_s;q2w6__dt_1_s]; 

state_new_q = [q1dev__dt_0_s;q1flex__dt_0_s;q1sup__dt_0_s;q2w1__dt_0_s;q2w2__dt_0_s;q2w3__dt_0_s;q2w4__dt_0_s;q2w5__dt_0_s;q2w6__dt_0_s];

state_vec = SX.sym('state_vec', 18, 1);

M_ct_new22 = substitute(M_casadi, state_new(1:9), state_vec(1:9));

%%

h_str = char(hh_lin2);
h_str_subs = strrep(h_str,'q1dev__dt_0_','q1dev__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1dev__dt_1_','q1dev__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_1_','q1flex__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_1_','q1sup__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w1__dt_1_','q2w1__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_1_','q2w2__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_1_','q2w3__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_1_','q2w4__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_1_','q2w5__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_1_','q2w6__dt_1_s');
h_str_subs = strrep(h_str_subs,'handmpt1','handmpt1s');
h_str_subs = strrep(h_str_subs,'handmpt2','handmpt2s');
h_str_subs = strrep(h_str_subs,'handmpt3','handmpt3s');
h_str_subs = strrep(h_str_subs,'handmpt4','handmpt4s');
h_str_subs = strrep(h_str_subs,'u1dev','u1devs');
h_str_subs = strrep(h_str_subs,'u1flex','u1flexs');
h_str_subs = strrep(h_str_subs,'u21','u21s');
h_str_subs = strrep(h_str_subs,'u22','u22s');
h_orig_casadi = eval(h_str_subs);
%%
h_str = char(hh_linDE2);
h_str_subs = strrep(h_str,'q1dev__dt_0_','q1dev__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
% h_str_subs = strrep(h_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1dev__dt_1_','q1dev__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_1_','q1flex__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_1_','q1sup__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w1__dt_1_','q2w1__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_1_','q2w2__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_1_','q2w3__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_1_','q2w4__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_1_','q2w5__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_1_','q2w6__dt_1_s');
% h_str_subs = strrep(h_str_subs,'handmpt1','handmpt1s');
% h_str_subs = strrep(h_str_subs,'handmpt2','handmpt2s');
% h_str_subs = strrep(h_str_subs,'handmpt3','handmpt3s');
% h_str_subs = strrep(h_str_subs,'handmpt4','handmpt4s');
% h_str_subs = strrep(h_str_subs,'u1dev','u1devs');
% h_str_subs = strrep(h_str_subs,'u1flex','u1flexs');
% h_str_subs = strrep(h_str_subs,'u21','u21s');
% h_str_subs = strrep(h_str_subs,'u22','u22s');
h_casadi = eval(h_str_subs);

%%
J_str = char(JuT_lin2);
J_str_subs = strrep(J_str,'q1dev__dt_0_','q1dev__dt_0_s');
J_str_subs = strrep(J_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
J_str_subs = strrep(J_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
J_str_subs = strrep(J_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
J_casadi = eval(J_str_subs);
%%
Jc_str = char(Jc_lin2);
Jc_str_subs = strrep(Jc_str,'q1dev__dt_0_','q1dev__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
Jc_str_subs = strrep(Jc_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
Jc_casadi = eval(Jc_str_subs);
%%

Jlam1=Jc_casadi(:,1:2); % The Jacobian for preseved coordinates of the constrained model
Jlam2=Jc_casadi(:,3:end); % The Jacobian for internal coordinates of the constrained model
JlamMap=-Jlam2\Jlam1; % The mapper between preseved coordinates and internal coordinates
Jcons=[eye(2);JlamMap]; 

Jconsdi = jacobian(Jcons,q1dev__dt_0_s)*q1dev__dt_1_s + jacobian(Jcons,q1flex__dt_0_s)*q1flex__dt_1_s + ...
                            jacobian(Jcons,q1sup__dt_0_s)*q1sup__dt_1_s + jacobian(Jcons,q2w1__dt_0_s)*q2w1__dt_1_s + ...
                                jacobian(Jcons,q2w2__dt_0_s)*q2w2__dt_1_s + jacobian(Jcons,q2w3__dt_0_s)*q2w3__dt_1_s + ...
                                    jacobian(Jcons,q2w4__dt_0_s)*q2w4__dt_1_s + jacobian(Jcons,q2w5__dt_0_s)*q2w5__dt_1_s + ...
                                        jacobian(Jcons,q2w6__dt_0_s)*q2w6__dt_1_s;
Jconsd = reshape(Jconsdi,9,2);
%%
dot_Jc_casadi = jacobian(Jc_casadi,q1dev__dt_0_s)*q1dev__dt_1_s + jacobian(Jc_casadi,q1flex__dt_0_s)*q1flex__dt_1_s + ...
                            jacobian(Jc_casadi,q1sup__dt_0_s)*q1sup__dt_1_s + jacobian(Jc_casadi,q2w1__dt_0_s)*q2w1__dt_1_s + ...
                                jacobian(Jc_casadi,q2w2__dt_0_s)*q2w2__dt_1_s + jacobian(Jc_casadi,q2w3__dt_0_s)*q2w3__dt_1_s + ...
                                    jacobian(Jc_casadi,q2w4__dt_0_s)*q2w4__dt_1_s + jacobian(Jc_casadi,q2w5__dt_0_s)*q2w5__dt_1_s + ...
                                        jacobian(Jc_casadi,q2w6__dt_0_s)*q2w6__dt_1_s;

%%
import casadi.*
state_new = [q1dev__dt_0_s;q1flex__dt_0_s;q1sup__dt_0_s;q2w1__dt_0_s;q2w2__dt_0_s;q2w3__dt_0_s;q2w4__dt_0_s;q2w5__dt_0_s;q2w6__dt_0_s;...
                        q1dev__dt_1_s;q1flex__dt_1_s;q1sup__dt_1_s;q2w1__dt_1_s;q2w2__dt_1_s;q2w3__dt_1_s;q2w4__dt_1_s;q2w5__dt_1_s;q2w6__dt_1_s]; 

state_new_q = [q1dev__dt_0_s;q1flex__dt_0_s;q1sup__dt_0_s;q2w1__dt_0_s;q2w2__dt_0_s;q2w3__dt_0_s;q2w4__dt_0_s;q2w5__dt_0_s;q2w6__dt_0_s];

state_vec = SX.sym('state_vec', 18, 1);
% state_d_vec = SX.sym('state_d_vec', 14, 1);
%%
control_0 = [handmpt1s;handmpt2s;handmpt3s;handmpt4s]; 
control_arm = [u1devs;u1flexs]; 
control_exo = [u21s;u22s]; 

control_0_vec = SX.sym('control_0_vec', 4, 1);
control_arm_vec = SX.sym('control_arm_vec', 2, 1);
control_exo_vec = SX.sym('control_exo_vec', 2, 1);

% M_ct_new22 = substitute(M_casadi, state_new_q, state_vec(1:9));
% M_ct_new23 = substitute(M_casadi, [q1dev__dt_0_s;q1flex__dt_0_s;q1sup__dt_0_s;q2w1__dt_0_s;q2w2__dt_0_s;q2w3__dt_0_s;q2w4__dt_0_s;q2w5__dt_0_s;q2w6__dt_0_s],...
                    % [state_vec(1);state_vec(2);state_vec(3);state_vec(4);state_vec(5);state_vec(6);state_vec(7);state_vec(8);state_vec(9)]);
%%
% M_ct_new24 = substitute(M_casadi, q1dev__dt_0_s,...
%                     state_vec(1));
%%
% M_ct_new23 = M_casadi.substitute(state_new(1:9), state_vec(1:9));
%%
C_ct_new = substitute(C_casadi, state_new, state_vec);
%%
ho_ct_new = substitute(h_orig_casadi, [state_new;control_0;control_arm;control_exo], ...
                                    [state_vec;control_0_vec;control_arm_vec;control_exo_vec]);
%%
h_ct_new = substitute(h_casadi, [state_new(1:3);state_new(5:18)], ...
                                    [state_vec(1:3);state_vec(5:18)]);
%%
Jc_new = substitute(Jc_casadi, state_new(1:9), ...
                                    state_vec(1:9));
Ju_new = substitute(J_casadi, state_new(1:3), ...
                                    state_vec(1:3));
dJc_new = substitute(dot_Jc_casadi, state_new, ...
                                    state_vec);
% Jcons_new = substitute(Jcons, [state_i(1:2);state_d(1:7)], ...
                                    % [state_i_vec(1:2);state_d_vec(1:7)]);
                                    %%


dyn_func = Function('gen_dynamics_nmpc_hDE', {state_vec}, ...%,control_0_vec, control_arm_vec, control_exo_vec},...
                            {M_ct_new22, C_ct_new, h_ct_new, Ju_new, Jc_new, dJc_new});

dyn_func.save('robot_dynamics_nmpc_hDE.casadi');

dyn_func.generate('gen_dynamics_nmpc_hDE.c', struct('mex', true));

% Compile with Optimization (Essential for 20k variables)
mex -O -Dcasadi_mex gen_dynamics_nmpc_hDE.c


%%

h_str = char(hh_linI2);
h_str_subs = strrep(h_str,'q1dev__dt_0_','q1dev__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_0_','q1flex__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_0_','q1sup__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w1__dt_0_','q2w1__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_0_','q2w2__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_0_','q2w3__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_0_','q2w4__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_0_','q2w5__dt_0_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_0_','q2w6__dt_0_s');
h_str_subs = strrep(h_str_subs,'q1dev__dt_1_','q1dev__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1flex__dt_1_','q1flex__dt_1_s');
h_str_subs = strrep(h_str_subs,'q1sup__dt_1_','q1sup__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w1__dt_1_','q2w1__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w2__dt_1_','q2w2__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w3__dt_1_','q2w3__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w4__dt_1_','q2w4__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w5__dt_1_','q2w5__dt_1_s');
h_str_subs = strrep(h_str_subs,'q2w6__dt_1_','q2w6__dt_1_s');
h_str_subs = strrep(h_str_subs,'handmpt1','handmpt1s');
h_str_subs = strrep(h_str_subs,'handmpt2','handmpt2s');
h_str_subs = strrep(h_str_subs,'handmpt3','handmpt3s');
h_str_subs = strrep(h_str_subs,'handmpt4','handmpt4s');
h_str_subs = strrep(h_str_subs,'u1dev','u1devs');
h_str_subs = strrep(h_str_subs,'u1flex','u1flexs');
h_str_subs = strrep(h_str_subs,'u21','u21s');
h_str_subs = strrep(h_str_subs,'u22','u22s');
hI_casadi = eval(h_str_subs);
%%

hC_ct = substitute(hC_casadi, [state_i;state_d;control_0;control_arm;control_exo], ...
                                    [state_i_vec;state_d_vec;control_0_vec;control_arm_vec;control_exo_vec]);

hD_ct = substitute(hD_casadi, [state_i;state_d;control_0;control_arm;control_exo], ...
                                    [state_i_vec;state_d_vec;control_0_vec;control_arm_vec;control_exo_vec]);

hE_ct = substitute(hE_casadi, [state_i;state_d;control_0;control_arm;control_exo], ...
                                    [state_i_vec;state_d_vec;control_0_vec;control_arm_vec;control_exo_vec]);

hI_ct = substitute(hI_casadi, [state_i;state_d;control_0;control_arm;control_exo], ...
                                    [state_i_vec;state_d_vec;control_0_vec;control_arm_vec;control_exo_vec]);

%%
dyn_func = Function('gen_H', {state_i_vec, state_d_vec,control_0_vec, control_arm_vec, control_exo_vec},...
                            {hC_ct, hD_ct, hE_ct, hI_ct});

dyn_func.save('gen_H.casadi');

dyn_func.generate('gen_H.c', struct('mex', true));

% Compile with Optimization (Essential for 20k variables)
mex -O -Dcasadi_mex gen_H.c