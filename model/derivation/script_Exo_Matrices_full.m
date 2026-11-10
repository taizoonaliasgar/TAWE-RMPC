%% Code for Substituting known parameters in symbolic and converting it into 2*2

%PathSetup;
%% Load the dynamical model

load(fullfile(fileparts(mfilename('fullpath')), '..', 'Dynamics_TAWE', 'BaseEOM_TAWE.mat'))
load(fullfile(fileparts(mfilename('fullpath')), '..', 'Dynamics_TAWE', 'ModelInfo_TAWE.mat'))
%%
load(fullfile(fileparts(mfilename('fullpath')), '..', 'Dynamics_TAWE', 'BaseCons_TAWE.mat'))
disp("Dynamics Model Loaded...")

%%  Load Matrices from Modelinfo and BaseEOM
disp("Preparing Matrices...")

syms t positive;

MM_lin = BaseEOM.InertialMatrix; % Inertia Matrix (9x9)
CC_lin = BaseEOM.CoriolisMatrix+BaseEOM.CentripetalMatrix; % Coriolis and Centripetal Matrix (9x9)
hh_lin = BaseEOM.CoriolisForce+... % Generalized Forces (9x1)
    BaseEOM.DampingForce+...
    BaseEOM.ExternalForce+...
    BaseEOM.InputForce+...
    BaseEOM.PotentialForce;

hh_linDE = BaseEOM.DampingForce+BaseEOM.ExternalForce;
    
JuT_lin = ModelInfo.Dynamics.InputJacobian; % Input Jacobian (9x8)
Jc_lin = BaseCons.ConsJacobian;

disp("done!")
%% Substitute constants
syms l13x l13y l13z xx3__dt_0_ zz3__dt_0_
disp("Substituting Model Parameters...")
pp = symvar(hh_lin).'; % shows all symbolic variables. Check TAWE_Modleing file to know which is which
pp = [pp(1:4, :);pp(9:92, :);pp(111:129, :);l13x;l13y;l13z;xx3__dt_0_;zz3__dt_0_]; % Constants 

TAWE_Parameters; % File which has all the parameters
% Constants values to be substituted
ppVal2 = [ppValCtrlNoWKI(4:5);ppValCtrlNoWKI(1:2);ppValCtrlNoWKI(113:118);ppValCtrlNoWKI(64:69);...
    ppValCtrlNoWKI(71:76);ppValCtrlNoWKI(78:83);ppValCtrlNoWKI(85:90);ppValCtrlNoWKI(92:97);ppValCtrlNoWKI(99:104);ppValCtrlNoWKI(106:111);...
    ppValCtrlNoWKI(10:12);ppValCtrlNoWKI(19:23);ppValCtrlNoWKI(42:46);ppValCtrlNoWKI(48:62);ppValCtrlNoWKI(112);...
    ppValCtrlNoWKI(63);ppValCtrlNoWKI(70);ppValCtrlNoWKI(77);ppValCtrlNoWKI(84);ppValCtrlNoWKI(91);ppValCtrlNoWKI(98);ppValCtrlNoWKI(105);...
    ppValCtrlNoWKI(6);ppValCtrlNoWKI(27:29);ppValCtrlNoWKI(24:26);ppValCtrlNoWKI(30:41);P_Arm_Val(7);P_Arm_Val(8);P_Arm_Val(9);0;0];


MM_lin2 = vpa(subs(MM_lin,[pp],[ppVal2]));
CC_lin2 = vpa(subs(CC_lin,[pp],[ppVal2]));
JuT_lin2 = vpa(subs(JuT_lin,[pp],[ppVal2]));
Jc_lin2 = vpa(subs(Jc_lin,[pp],[ppVal2]));
hh_lin2 = vpa(subs(hh_lin,[pp],[ppVal2]));
hh_linDE2 = vpa(subs(hh_linDE,[pp],[ppVal2]));

disp("done!")


%% States and Inputs 
% Just for reference

% qqdev_ = sym("q1dev__dt_0_"); % Wrist Radial Ulnar Deviation (RUD) Rotation on z axis in the wrist frame
% qqflex_ = sym("q1flex__dt_0_"); % Wrist Flexion Extension (FE) Rotation on x axis in the wrist frame
% qqsup_ = sym("q1sup__dt_0_"); % Wrist Pronation Supination (SP), which is constrained to FE and
%                               % RUD, Rotation on y axis in the wrist frame
% qqexo = sym("q2w%d__dt_0_", [6,1]); % TAWE Mechanism Joint Angles
% 
% qqf = [qqdev_;qqflex_]; % Wrist states
% 
% % Angular Velocities
% qqfdot = pDiff(qqf, t);
% 
% % State Vector (unconstrained)
% xx = [qqf;qqfdot];
% 
% % All States Vector (18x1)
% states = [qqdev_;qqflex_;qqsup_;qqexo;pDiff(qqdev_,t);pDiff(qqflex_,t);pDiff(qqsup_,t);pDiff(qqexo,t)];
% 
% % Inputs (8x1)
% inputs = uu_lin;
% 
% %% Dim Reduction matrices
% % to be used for dimension reduction, thare are just symbolic placeholders,
% % actual num matrices obtained while simulation
% 
% disp("Preparing Constrained System...")
% 
% JL = sym("jl%d",[9,2]);
% JLdot = sym("jld",[9,2]);
% 
% %% Use above matices to obtained the reduced matrices
% % Symbolic variables present are: states (18) and inputs (8), JL (9X2), and
% % JLdot (9x2)
% 
% % Obtain MMC (2X2)
% MMRC = JL.'*MM_lin1;
% MMC = MMRC*JL;
% 
% % Obtain CCC (2X2)
% CCC = JL.'*(CC_lin1)*JL ...
%                     + MMRC*JLdot; 
% 
% % Obtain hhC (2X1)
% hhC = JL.'*hh_lin1; 
% 
% % Jacobian of TAWE input (2x1)
% JacU2Tpose = JL.'*JuT_lin1(:,3:4);
% 
% % Jacobian of user input (2x1)
% JacU1Tpose = JL.'*JuT_lin1(:,1:2); 
% 
% disp("done!")


