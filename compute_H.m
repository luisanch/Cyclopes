H_lr(:,:,1) = eye(3,3);

for i=10:40
H_lr(:,:,i-9) = inv(H(:,:,i-9)) *  H_r(:,:,i-9);

end
mean_hlr = mean(H_lr,3);