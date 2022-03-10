
x = results(1:50, 1);
ytime = results(1:50, 2);
ynorms = results(1:50, 3);
yiters = results(1:50, 4);

x2 = results0(1:50, 1);
ytime2 = results0(1:50, 2);
ynorms2 = results0(1:50, 3);
yiters2 = results0(1:50, 4);

figure()
subplot(3,1,1);
plot(x,ytime)
hold on 
plot(x,ytime2, 'r')
hold off
title('Time Per Image')

subplot(3,1,2);
plot(x,ynorms)
hold on 
plot(x,ynorms2, 'r')
hold off
title('Norm Per Image')

subplot(3,1,3);
plot(x,yiters) 
hold on 
plot(x,yiters2, 'r')
hold off
title('Iteration Per Image')

