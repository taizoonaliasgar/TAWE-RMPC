function [tau_d,z] = NDO_estimator(MMCombine,CCCombine,GFFCombine,dq,u,z,dt)


    L = diag([50, 50]); % Observer Gain (Tuning parameter)

    % The auxiliary function p(qd) such that dp/dt = L*M*q_ddot
    p_func = L * MMCombine * dq; 
   
    % D. Nonlinear Disturbance Observer (The "Paper" Equations)
    % Equation from Paper: dz/dt = -L(q)*z + L(q)*(C*qd + G - p(q,qd) - u)
    dz = -L * z + L * (CCCombine*dq - GFFCombine - p_func - u);
    z = z + dz * dt;
    
    % Recover Estimated Disturbance: d_hat = z + p(q,qd)
    tau_d = z + p_func;

end