function J0 = solcost(mpcout,P,Q,R,hor,path2,wlen,ny,nu,reali)

Qbar = zeros(ny*hor,ny*hor);
Rbar = zeros(nu*hor,nu*hor);
for ii = 0:hor-1
        Qbar(ny*ii+(1:ny),ny*ii+(1:ny))=Q;
        Rbar(nu*ii+(1:nu),nu*ii+(1:nu))=R;
        if(ii>hor-2)
            Qbar(ny*ii+(1:ny),ny*ii+(1:ny))=P;
        end
end
path1 = reshape(path2, ny*hor,1);
J0 = transpose(mpcout(ny*hor*reali+(1:ny*hor))-path1)*Qbar*(mpcout(ny*hor*reali+(1:ny*hor))-path1) + ...
        transpose(mpcout(wlen*ny*hor+nu*hor*reali+(1:nu*hor)))*Rbar*mpcout(wlen*ny*hor+nu*hor*reali+(1:nu*hor));
end