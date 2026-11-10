function mpc_inp = mpc_RMPC2n(AA,BB,P,Q,R,hor,X_in,F_cons,path2, uMax, uMin, xx_lb, xx_ub, hh,w,ueq,wprop,qweights)     

% ueq = 5;
% wprop = 4;

%% equality constraints
    
  nu =size(BB,2); ny = size(AA,1);
  bigA = eye(ny*hor,ny*hor);
  [~,wlen] = size(w);

  
  for ii = 1:hor-1
     bigA(ny*ii+(1:ny),ny*(ii-1)+(1:ny))=-AA;     
  end

  bigB = zeros(ny*hor,nu*hor);
  for ii = 0:hor-1
       bigB(ny*ii+(1:ny),nu*ii+(1:nu))=-BB;        
  end
  
  Eq_RHS = zeros(hor*ny*wlen+nu*(wlen-1)*ueq,1);
  for i=1:wlen
    Eq_RHS(hor*ny*(i-1)+(1:ny)) = AA*X_in+w(:,i);%zeros(ny*(hor-1),1);AA*X_in+w(:,2);zeros(ny*(hor-1),1)] + repmat(F_cons,2*hor,1);
    % for wp=2:wprop
    %     Eq_RHS(hor*ny*(i-1)+(wp-1)*ny+(1:ny)) = w(:,i);
    % end
  end
  Eq_RHS(1:hor*ny*wlen) = Eq_RHS(1:hor*ny*wlen)+repmat(F_cons,wlen*hor,1);
  %bigEq = [bigA,bigB];
  
  bigEq = zeros(hor*ny*wlen+(wlen-1)*nu*ueq,hor*ny*wlen+wlen*nu*hor); 
  for i=1:wlen
    bigEq((i-1)*ny*hor+(1:ny*hor),(i-1)*ny*hor+(1:ny*hor)) = bigA;
    %bigEq(ny*hor+1:2*ny*hor,ny*hor+1:2*ny*hor) = bigA;
    bigEq((i-1)*ny*hor+(1:ny*hor),wlen*ny*hor+(i-1)*nu*hor+(1:nu*hor)) = bigB;
    %bigEq(ny*hor+1:2*ny*hor,2*ny*hor+nu*hor+(1:nu*hor)) = bigB;
    if i<wlen
            bigEq(wlen*ny*hor+(i-1)*nu*ueq+(1:nu*ueq),wlen*ny*hor+(1:nu*ueq)) = eye(ueq*nu);
            bigEq(wlen*ny*hor+(i-1)*nu*ueq+(1:nu*ueq),wlen*ny*hor+i*nu*hor+(1:nu*ueq)) = -eye(ueq*nu);
    end
  end
  %% Cost function Matrix 
  
  Qbar = zeros(ny*hor,ny*hor);
  Rbar = zeros(nu*hor,nu*hor);
  for ii = 0:hor-1
        Qbar(ny*ii+(1:ny),ny*ii+(1:ny))=Q;
        Rbar(nu*ii+(1:nu),nu*ii+(1:nu))=R;
  end
  Qbar(ny*(hor-1)+(1:ny),ny*(hor-1)+(1:ny))=P;

  Qbarf = zeros(wlen*ny*hor,wlen*ny*hor);
  Rbarf = zeros(wlen*nu*hor,wlen*nu*hor);
  for i=1:wlen
      Qbarf((i-1)*ny*hor+(1:ny*hor),(i-1)*ny*hor+(1:ny*hor)) = qweights(i)*Qbar;
      Rbarf((i-1)*nu*hor+(1:nu*hor),(i-1)*nu*hor+(1:nu*hor)) = qweights(i)*Rbar;
  end

  QR_bar = [Qbarf,zeros(wlen*ny*hor,wlen*nu*hor);zeros(wlen*nu*hor,wlen*ny*hor),Rbarf];

  %%  Inequality constraints
  
  u_lb = repmat(uMin,wlen*hor,1);
  u_ub = repmat(uMax,wlen*hor,1);

    %xx_lb = [-1000;-1000;-1000;-1000]; %taken randomly for now
  x_lb = repmat(xx_lb,wlen*hor,1);
    %xx_ub = [10;10;1000;1000];
  x_ub = repmat(xx_ub,wlen*hor,1);
   
  Aineq = zeros(2*wlen*hor*(ny+nu),wlen*hor*(ny+nu));
  
  Aineq(1:wlen*hor*ny,1:wlen*hor*ny) = eye(wlen*hor*ny);
  Aineq(wlen*hor*ny+(1:wlen*hor*ny),1:wlen*hor*ny) = -eye(wlen*hor*(ny));

  Aineq(2*wlen*hor*ny+(1:wlen*hor*nu),wlen*hor*ny+(1:wlen*hor*nu)) = eye(wlen*hor*(nu));
  Aineq(2*wlen*hor*ny+wlen*hor*nu+(1:wlen*hor*nu),wlen*hor*ny+(1:wlen*hor*nu)) = -eye(wlen*hor*(nu));
  
  Bineq = [x_ub;-x_lb;u_ub;-u_lb];
  
  c_int = zeros(1,ny*hor);
  for ii = 1:1:hor-1
     c_int((ii-1)*ny+(1:ny)) = -1*path2(:,ii)'*Q;
  end
  c_int((hor-1)*ny+1:hor*ny) = -1*path2(:,hor)'*P;
  cy = repmat(c_int,1,wlen);    
  ff = [cy, zeros(1,wlen*nu*hor)];
  
  %% Solve QP
  [x1_u1,~,~]=qpSWIFT(sparse(QR_bar),ff',sparse(bigEq),Eq_RHS,sparse(Aineq),Bineq);
  
  mpc_inp = x1_u1;%(wlen*ny*hor+(1:nu));
   
end

