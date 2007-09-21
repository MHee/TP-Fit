function M=ComputeModelMatrix
ks=[0.5:0.1:2.5]
rcs=[2.3:0.1:4.3]*1e6;
M.ks=ks;
M.rcs=rcs;
for i=1:length(ks)
    for j=1:length(rcs)
        fprintf('i:%.0f  j:%.0f k:%.1f rc:%.0f\n',i,j,ks(i),rcs(j));
        M.k(i,j)=ks(i);
        M.rc(i,j)=rcs(j);
        Decay=DecayModel(ks(i),rcs(j));
        M.T{i,j}=Decay.T;
    end
end
M.t=Decay.t

save('DecayMatrix.mat','M');