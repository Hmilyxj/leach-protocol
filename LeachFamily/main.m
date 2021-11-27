clear
clc

IniEng=0.5;%0.5; % Initial Energy of Every Node
NetSize=100; % Network Size
NoOfNode=100; % Number of Node
NoOfRound=2500; % Number of Round
cluster_head_percentage=0.05;

xm=NetSize;
ym=NetSize;

sink.x=0.45*xm;
sink.y=0.5625*ym;

n=NoOfNode;

p=cluster_head_percentage;

Eo=IniEng;%Initial energy
%Eelec=Etx=Erx
ETX=50*0.000000001;
ERX=50*0.000000001;
%Transmit Amplifier types
Efs=10*0.000000000001;
Emp=0.0013*0.000000000001;
%Data Aggregation Energy
EDA=5*0.000000001;

a=0;

rmax=NoOfRound;

do=sqrt(Efs/Emp);

for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;
    YR(i)=S(i).yd;
    S(i).G=0;%=0表示有资格成为簇头;
    S(i).cl=0;%成为簇头次数;
    S(i).E=Eo*(1+rand*a); %initially there are no cluster heads only nodes
    S(i).type='N';
    S(i).tt='N';
    S(i).ty='N';
    S(i).density=0;
    S(i).density_computed=0;
    S(i).d_toSink=0;
    S(i).d=0;
    S(i).p=0;
    S(i).p_change=0;
    S(i).E_surplus=0;
    S(i).N=0;
    S(i).F=0;
    S(i).a=0;
    S(i).N_all=0;
    S(i).w_1=0;
    S(i).w_2=0;
    S(i).R=0;
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;

[STATISTICS1,FD1,TD1,AD1]=leach(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S);%% Leach
[STATISTICS2,FD2,TD2,AD2]=leach_noname(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S);
[STATISTICS3,FD3,TD3,AD3]=leach_x(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S);


r=0:NoOfRound;

figure 
plot(r,STATISTICS1.DEAD,'k:',r,STATISTICS2.DEAD,'b--',r,STATISTICS3.DEAD,'m-','LineWidth',2);
legend('LEACH','LEACH-Advanced','LEACH-X','Location','SouthEast');
xlabel('周期数');
ylabel('死亡节点数/个');
title('Number of death nodes');
 
figure
plot(r,STATISTICS1.ALLIVE,'k:',r,STATISTICS2.ALLIVE,'b--',r,STATISTICS3.ALLIVE,'m-','LineWidth',2);
legend('LEACH','LEACH-Advanced','LEACH-X');
xlabel('周期数');
ylabel('存活节点数/个');
title('Number of alive nodes');
 
figure;
plot(r,STATISTICS1.PACKETS_TO_BS,'k:',r,STATISTICS2.PACKETS_TO_BS,'b--',r,STATISTICS3.PACKETS_TO_BS,'m-','LineWidth',2);
legend('LEACH','LEACH-Advanced','LEACH-X','Location','SouthEast'); 
xlabel('周期数');
ylabel('发送数据包数/bit');
title('Number of packets send to Sink Node');

figure;
plot(r,STATISTICS1.TotalEnergy,'k:',r,STATISTICS2.TotalEnergy,'b--',r,STATISTICS3.TotalEnergy,'m-','LineWidth',2); 
legend('LEACH','LEACH-Advanced','LEACH-X');
xlabel('周期数');
ylabel('网络剩余能量/J');
title('Network residual energy');

figure;
bargraph=[FD1,FD2,FD3;TD1,TD2,TD3;AD1,AD2,AD3]; 
bar(bargraph,'group');
legend('LEACH','LEACH-Advanced','LEACH-X','Location','NorthWest'); 
title('第一个、第十个和所有节点死亡时周期');
xlabel('FIRST DEATH              TENTH DEATH              ALL DEATH');
ylabel('周期数');



