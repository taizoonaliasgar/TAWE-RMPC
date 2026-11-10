%% MPC-NDO under 50% stochastic actuation latency
% Reproduces: Sec. 6.1, Fig. 9a, Table 4
%
% Part of TAWE-RMPC, the code accompanying "Robust Model Predictive Control of a
% Tremor-Suppression Exoskeleton under Tremor-Induced Disturbances" (ASME JDSMC).
% Run setup_paths once per session, then run this script. Results are written
% to results/rerun/. Optional variables you can set before running:
%   seed      - random seed (default 0)

%% Configuration
scenario = 'delay';
if ~exist('seed','var'), seed = 0; end
rng(seed);
outDir = fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'rerun');
if ~isfolder(outDir), mkdir(outDir); end

%% Load Model Parameters
TAWE_Parameters; % This loads the TAWE simulation parameters
simParamVal=ppValSim; % Simulation Parameters
ctrlParamVal=ppValCtrlNoWKI; % Controller Parameters


tSpan1 = 0:hh:10; %Simulation Time Span

% State vector qq and qqdot, which are:
% (1) Wrist Radial Ulnar Deviation (RUD) (rad) Rotation on z axis in the wrist frame
% (2) Wrist Flexion Extension (FE) (rad) Rotation on x axis in the wrist frame
% (3) Wrist Pronation Supination (SP) (rad), which is constrained to FE and
%     RUD, Rotation on y axis in the wrist frame
% (4-9) TAWE Mechanism Joint Angles (rad)
simStateVal=zeros(18,1);
% simStateVal(4:9)=[-0.0264;0.6469;-1.6188;    0.7922;    0.1328;    0.0506];
%simStateVal(1:9) = [0;0;0;-0.3699;0.7732;-1.8355;0.7874;0.1527;0.3268];
%simStateVal(1:9) = [0;0;0;90;126.04;70.34;127.93;0;0]*pi/180;


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

% Nonholonomic state used in constraint only. Note that are not internal 
% states of the system, but Euler Angles qq_nh that satisfies
% RotMat(qq1) = RotMat(qq_nh)*RotMat(qq_nh)
% Hence, the rotation by qq1 is split to two identical rotations by qq_nh
% in sequance. The wrist kinematic model uses this to form a z-x-z-x 
% sequenced rotation joint, where all the z angles (on RUD direction) are the same, and all
% the x angles (on FE direction) are the same. This assumes that the wrist rotation is
% devided evenly into the radiocarpal and midicarpal joints.
nhSignal=zeros(3,1);

simStateData=zeros(18,numel(tSpan1)); % Store state data from simulation
simInputData=zeros(8,numel(tSpan1)); % Store inputs
tremortorque = zeros(2,numel(tSpan1));

hor=15;            % Horizon
%load('simTAWERef','refData','refdtData','refddtData');
%%
load('simTAWERef','tremorData');
[refData, refdtData] = make_reference(scenario, tSpan1, hor);

% refData(1,151:351) = 0.2-0.2*sin(0.5*pi*(tSpan1(151:351)-3));
% refdtData(1,151:351) = -0.2*0.5*pi*cos(0.5*pi*(tSpan1(151:351)-3));
% 
% refData(2,151:351) = 0.1*sin(0.5*pi*(tSpan1(151:351)-3));
% refdtData(2,151:351) = 0.1*0.5*pi*cos(0.5*pi*(tSpan1(151:351)-3));
%%
J0 =zeros(numel(tSpan1),1);
qdotdel = zeros(8,numel(tSpan1));
qdotdel_current = zeros(18,numel(tSpan1));
comparingdq = zeros(16,numel(tSpan1));

z_observer = zeros(2,1);

delay_time_steps = 2;
input_delay_track=zeros(2,delay_time_steps);

% Simulation Loop
disp('Running MPC');
tic;
for ii=1:numel(tSpan1)

    % just for checkpoint
    if rem(ii,100)==1
        disp(ii+" of "+numel(tSpan1)+" steps completed")
    end
    
    tt=tSpan1(ii); % Update time variable
    simStateData(:,ii)=simStateVal(1:end); % Store qq
    qq=simStateVal(1:end/2);
    qqdot=simStateVal(end/2+1:end);
    
    ref=refData(:,ii);
    refdt=refdtData(:,ii);
    %refddt=refddtData(:,ii);
        
    % Get System Properties
    % [~,~,~,~,~,Quat,MM,GFI,GFF,GFU,JacU,JacCons1,~,~,CenMat,InertLeftComponent,InertRightComponent1]...
    %    =System_TAWE(tSpan1(ii),simStateVal,ctrlParamVal,ctrllnputVal,nhSignal);
    [~,~,~,~,~,Quat,MM,GFI,GFF,GFU,JacU,JacCons1,~,~,CenMat,InertLeftComponent,InertRightComponent1]...
        =System_TAWE(tSpan1(ii),simStateVal,simParamVal,ctrllnputVal,nhSignal);
    MM=sum(MM,3); % Sum up inertia matrix of all bodies
    JacU=sum(JacU,3).'; % Sum up constraint Jacobian Matrices of all inputs
    JacCons1=sum(JacCons1,3); % Sum up constraint Jacobian Matrices of all constraints
    GFF=sum(GFF,2); % Sum up generalized forces 
    CenMat=sum(CenMat,3); % Sum up all centripetal matrices'

    GFU=sum(GFU(:,1:4),2);
    %GFF = GFF + sum(GFI,2) + sum(GFU,2);
    % Properties used to numerically calculate Coriolis matrix and
    % constraint Jacobian derivative
    simStateVal2=simStateVal;
    % Use the current state velocity to estimate the position after a
    % short time step
    simStateVal2(1:end/2)=simStateVal2(1:end/2)+simStateVal(end/2+1:end)*(hh);

    % Calculate the equivalent qq_nh used in the constraint (see
    % above), Note that are not internal states of the system, but Euler
    % Angles qq_nh that satisfies
    % RotMat(qq1) = RotMat(qq_nh)*RotMat(qq_nh)
    % Hence, the rotation by qq1 is split to two identical rotations by qq_nh
    % in sequance.
    rotQuat=ypr2Quat(simStateVal2([2 3 1])); % Unit quaternion equivalent to wrist rotation
    halfCos=sqrt((rotQuat(1)+1)/2);
    rotQuatSquareRoot=[halfCos;rotQuat(2:4)/2/halfCos]; % Half of the rotQuat rotation
    nhSignal2=quat2YPR(rotQuatSquareRoot)*2; % Calculate qq_nh estimate after a short time step    
    % Obtain estimated properties after a short time step
    % [~,~,~,~,~,~,~,~,~,~,~,JacCons2,~,~,~,~,InertRightComponent2]=...
    %    System_TAWE(tSpan1(ii),simStateVal2,ctrlParamVal,ctrllnputVal,nhSignal2);
    [~,~,~,~,~,~,~,~,~,~,~,JacCons2,~,~,~,~,InertRightComponent2]=...
        System_TAWE(tSpan1(ii),simStateVal2,simParamVal,ctrllnputVal,nhSignal2);
    % Formulate constraint properties (please also see supplemental document)
    Jlam1=JacCons1(:,1:2); % The Jacobian for preseved coordinates of the constrained model
    Jlam2=JacCons1(:,3:end); % The Jacobian for internal coordinates of the constrained model
    JlamMap=-Jlam2\Jlam1; % The mapper between preseved coordinates and internal coordinates
    JlamMapFull1=[eye(2);JlamMap]; % The mapper between preseved coordinates and all coordinates

    % This step is similar to above, except using the estimated
    % properties
    Jlam1=JacCons2(:,1:2);
    Jlam2=JacCons2(:,3:end);
    JlamMap=-Jlam2\Jlam1;
    JlamMapFull2=[eye(2);JlamMap];

    % Numerically calculate derivatives of matrices (the Jacobian
    % matrices do not involve velocity (i.e. qqdot))
    JlamMapFull=JlamMapFull1;
    JlamMapFullDot=(JlamMapFull2-JlamMapFull1)/(hh);
    InertRightComponent=InertRightComponent1;
    InertRightComponentDot=(InertRightComponent2-InertRightComponent1)/(hh);

    % Numerically calculate coriolis matrix
    CorMat=InertLeftComponent*InertRightComponentDot;
    
    % Jdotstate = transpose([simStateVal(1:3);simStateVal(13:18);simStateVal(4:9);simStateVal(10:12);nhSignal(1);nhSignal(2)]);
    % JlamMapFullDot_exp = dotJConstraints(Jdotstate);
    % JlamMapFullDot = [zeros(2,2);-JlamMapFullDot_exp(:,3:end)\JlamMapFullDot_exp(:,1:2)];

    % Calculated properties of constrained system
    MMRightCombine = JlamMapFull.'*MM;
    MMCombine = MMRightCombine*JlamMapFull; % Inertia matrix
    CCCombine = JlamMapFull.'*(CorMat+CenMat)*JlamMapFull ...%CorMat+
        + MMRightCombine*JlamMapFullDot; % Coriolis and Centripetal Matrix
    GFFCombine = JlamMapFull.'*GFF; % Generalized force
    JacU1Tpose = JlamMapFull.'*JacU(1:2,:).'; % Jacobian of user input (transposed)
    JacU2Tpose = JlamMapFull.'*JacU(3:4,:).'; % Jacobian of TAWE input (transposed)                 

    % values for linearization
    statesval = simStateVal;
    inputsval = [0;0;simInputVal(3:8)];
    JLVal = JlamMapFull;
    JLValdot = JlamMapFullDot;
    invMM = inv(MMCombine);
    ZZVal = -CCCombine*simStateVal(10:11)+(GFFCombine)+JacU2Tpose*simInputVal(3:4);%+JlamMapFull.'*GFU;
    
    % obtain state space matrices using linearization
    step = 1;
    % if rem(ii,2)==1
        AA_21a = AA21_a_Val(statesval,JLValdot,JLVal,invMM,ZZVal);
        AA_21b = invMM*[AA21b_11_Val(statesval,inputsval,JLValdot,JLVal),AA21b_12_Val(statesval,inputsval,JLValdot,JLVal);...
            AA21b_21_Val(statesval,inputsval,JLValdot,JLVal),AA21b_22_Val(statesval,inputsval,JLValdot,JLVal)];
        AA_21 = AA_21a + AA_21b;
        AA_22 = invMM*[AA22_11_Val(statesval,JLValdot,JLVal),AA22_12_Val(statesval,JLValdot,JLVal);...
            AA22_21_Val(statesval,JLValdot,JLVal),AA22_22_Val(statesval,JLValdot,JLVal)];
        Ac = [zeros(2,2), eye(2,2); AA_21, AA_22];
        Ad = eye(4)+ hh*Ac*step;
        Bc = [zeros(2,2);invMM*JacU2Tpose];
        Bd = Bc*hh*step;
    % end
    Consterm = hh*step*([simStateVal(10:11);invMM*ZZVal]-Ac*[simStateVal(1:2);simStateVal(10:11)]-Bc*simInputVal(3:4));
    X_in = [simStateVal(1:2);simStateVal(10:11)];       %Start point

    path2 = [refData(:,ii+1:step:ii+hor*step);refdtData(:,ii+1:step:ii+hor*step)]; %reference path

    % State error weight
    Q=diag([8000 500 100 100]);%500
    %Q=diag([800 500 10 10]);%500
    %Q=diag([500 8000 0.01 0.01]);%10 10]);%500
    % final state error weight
    P = Q;     
    % input weights
    R=0.4*eye(2); 

    % Input constraints 
    uMin=[-9.5;-12.2];      
    uMax=[11;7.1];

    % Ang pos and vel constraints
    xx_lb = [-0.8;-1.5;-3*pi/2;-3*pi/2]; 
    xx_ub = [0.45;1.5;3*pi/2;3*pi/2];
     
    % Obtain optimal input from MPC Controller
    

    %Store input data
    
    distcheck = randn;
     if(tSpan1(ii)>3 && tSpan1(ii)<7)
         Q=diag([8000 500 100 100]);%500
         P = Q;     
         R=0.4*eye(2); 
         %disttt = [-0.5;-0.5];
        disttt = tremorData(:,ii);
        % disttt(2) = 0;
        % disttt(1)=disttt(1)-0.2;
        % disttt(2)=disttt(2)-0.1;
     else
         disttt = [0;0];
     end
    
    taweInput = mpc_no_BMFLC(Ad,Bd,P,Q,R,hor,X_in,Consterm,path2, uMax, uMin, xx_lb, xx_ub, hh);%[0;0]

    [taud_estimate(:,ii),z_observer] = NDO_estimator(MMCombine,CCCombine,GFFCombine,simStateVal(10:11),JacU2Tpose*taweInput(4*hor+(1:2)),z_observer,hh);
    
    comparingdq(1:4,ii) = [statesval(10:11);invMM*(ZZVal+JacU2Tpose*(taweInput(4*hor+(1:2)) - simInputVal(3:4)))];
    comparingdq(5:8,ii) = Ac*[simStateVal(1);simStateVal(2);simStateVal(10);simStateVal(11)]+Bc*taweInput(4*hor+(1:2))+Consterm/hh;
    
    NDO_input = taweInput(4*hor+(1:2))-JacU2Tpose\taud_estimate(:,ii);
    if(tSpan1(ii)>3 && tSpan1(ii)<7)
        if randn > 0
            simInputVal(3:4)=input_delay_track(:,1);
        else
            simInputVal(3:4)=NDO_input;
        end
    else
        simInputVal(3:4)=NDO_input;
    end
    % simInputVal(3:4)=taweInput(4*hor+(1:2))-taud_estimate(:,ii); % Insert MPC input for simulation
    
    J0(ii) = solcost(taweInput,P,Q,R,hor,path2,1,4,2,0);

    % dqrkf = conttime(simStateVal,simInputVal(3:4),MM,CorMat+CenMat,GFF,JacU,disttt,JlamMapFull.'*GFU);
    % Using Runge Kutta 4th method to integrate system ODE
    [simStateVal,nhSignal,consForce,~,~,dqrk4,td1]=rk4Hybrid(@Flow_TAWE,hh,flowNum,tSpan1(ii),...
                                        simStateVal,simParamVal,simInputVal,nhSignal,consForce,disttt);
                                    
    %nhSignal = nhSignal_Taizoon(simStateVal,hh,nhSignal);
    %[t,simStateVal] = ode45(@conttime,[0:0.005],simStateVal,simInputVal(3:4),disttt);
    
    simInputData(:,ii)=simInputVal(1:end);
    comparingdq(9:12,ii) = [dqrk4(1);dqrk4(2);dqrk4(10);dqrk4(11)];
    % comparingdq(13:16,ii) = [dqrkf(1);dqrkf(2);dqrkf(10);dqrkf(11)];
    [y_curr,y_ext] = estimateuncertainty(invMM,JacU,JlamMapFull,disttt,hh);
    qdotdel_current(1:9,ii) = td1*hh;
    qdotdel_current(10:11,ii) = y_curr;
    qdotdel(:,ii) = y_ext;
    ctrllnputVal = simInputVal;
    tremortorque(:,ii) = disttt;

    input_delay_track(:,1) = input_delay_track(:,2);
    input_delay_track(:,2) = NDO_input;
    % The codes below refreshes the 3D visualization for run-time animation
    % Uncomment to run.
    % if rem(ii,15)==0 %adjust the frame rate through the number
    %     Sim.drawNow(tSpan1(ii),simStateVal,simParamVal,simInputVal,nhSignal); % requires 3D environment
    % end
    %display(ii);
end
toc;

%% Save results
runName = ['MPCNDO_delay'];
save(fullfile(outDir, ['state_' runName '.mat']), 'simStateData');
save(fullfile(outDir, ['input_' runName '.mat']), 'simInputData');
save(fullfile(outDir, ['tremor_torque_' runName '.mat']), 'tremortorque');
fprintf('Saved %s results to %s\n', runName, outDir);

%Store Simulation data to plot (Uncomment to Run)

%%
function [y_curr,y_ext]=estimateuncertainty(M,Ju,Jmap,dist,hh)

distvertices = [0.5;0.5;-0.5;0.5;-0.5;-0.5;0.5;-0.5];
y_curr = M*Jmap'*Ju(1:2,:)';
y_curr = y_curr*dist*hh;
y_ext = zeros(8,1);

for i = 1:4
    y_ext(2*i-1:2*i) = M*Jmap.'*Ju(1:2,:).'*distvertices(2*i-1:2*i);%distvertices(2*i);zeros(7,1)];
    %y1(2*i-1:2*i) = y(1:2);
end
y_ext = y_ext*0.005;
end
