function [x_opt,u_opt, l_opt] = mpc_Casadi_full(solver_obj2,bounds,simStateVal,hor,path2,u0,x0,l0,n_q,n_u,n_l,n_qi,dyn_p)    
   
    import casadi.*

    p_param = DM([reshape(path2,n_qi*hor,1);simStateVal;dyn_p]);
    
    args = struct;
    args.x0 = DM([x0; u0; l0]); % Primal Warm Start
    args.p = p_param;
    args.lbx = DM(bounds.lbx);
    args.ubx = DM(bounds.ubx);
    args.lbg = DM(bounds.lbg);
    args.ubg = DM(bounds.ubg);
    % arg.lam_g0 = lam_guess;            % Dual Warm Start (Kicker for speed)

    % if(distflag>0)
    %     res = solver_obj2(args);
    % else
    %     res = solver_obj1(args);
    % end 

    % if(distflag > 0)
        res = solver_obj2('x0', args.x0, 'p', args.p, 'lbx', args.lbx, ...
                          'ubx', args.ubx, 'lbg', args.lbg, 'ubg', args.ubg);
    % else
    %     res = solver_obj1('x0', args.x0, 'p', args.p, 'lbx', args.lbx, ...
    %                       'ubx', args.ubx, 'lbg', args.lbg, 'ubg', args.ubg);
    % end
 
    full_sol = full(res.x); 
    % Slicing logic (based on your n_q and n_u)
    nx_total = n_q * (hor + 1);
    nu_total = n_u * hor;
    nl_total = n_l * hor;
    x_opt = full_sol(1:nx_total);
    u_opt = full_sol(nx_total + 1: nx_total + nu_total);
    l_opt = full_sol(nx_total + nu_total + 1: nx_total + nu_total + nl_total);

    % u_opt = sol.value(U);
    % x_opt = sol.value(X);
end

