function [STATISTICS1,FD1,TD1,AD1]=leach(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S)

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
do

countCHs=0;
cluster=1;
flag_first_dead=0;
flag_teenth_dead=0;
flag_all_dead=0;

dead=0;
first_dead=0;
teenth_dead=0;
all_dead=0;

allive=n;
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;

for r=0:1:rmax   
    
     if(r==0)
        figure;
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('��ʼ�ڵ�ֲ�ͼ');
     end
     
     if(r==1200)
        figure;
        subplot(3,2,1);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH,r=1200');
        hold on;
     end
     
     if(r==1400)
        subplot(3,2,2);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH,r=1400');
        hold on;
     end
    
    if(mod(r, round(1/p) )==0)
        for i=1:1:n
            S(i).G=0;
            %S(i).cl=0; 
        end
    end

    dead=0;
    for i=1:1:n
        if (S(i).E<=0)
            dead=dead+1;  
            if (dead==1)
                if(flag_first_dead==0)
                    first_dead=r;
                    flag_first_dead=1;
                end
            end   
            if(dead==0.1*n)
                if(flag_teenth_dead==0)
                    teenth_dead=r;
                    flag_teenth_dead=1;
                end
            end
            if(dead==n)
                if(flag_all_dead==0)
                    all_dead=r;
                    flag_all_dead=1;
                end
            end
        end
        if S(i).E>0
            S(i).type='N';
        end
    end
    STATISTICS.DEAD(r+1)=dead;
    STATISTICS.ALLIVE(r+1)=allive-dead;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TotalNetworkEnergy=0;
    for i=1:n
        if S(i).E>0
            TotalNetworkEnergy=TotalNetworkEnergy+S(i).E;
        end
    end
    STATISTICS.TotalEnergy(r+1)=TotalNetworkEnergy;
    STATISTICS.AvgEnergy(r+1)=TotalNetworkEnergy/n;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    countCHs=0;
    cluster=1;
    for i=1:1:n
        if(S(i).E>0)
            temp_rand=rand;     
            if ( (S(i).G)<=0)    
                if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
                    countCHs=countCHs+1;
                    packets_TO_BS=packets_TO_BS+1;
                    PACKETS_TO_BS(r+1)=packets_TO_BS;
                    S(i).type='C';
                    S(i).G=round(1/p)-1;
                    C(cluster).xd=S(i).xd;
                    C(cluster).yd=S(i).yd;
                    distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
                    C(cluster).distance=distance;
                    C(cluster).id=i;
                    X(cluster)=S(i).xd;
                    Y(cluster)=S(i).yd;
                    cluster=cluster+1;
           
                    distance;
                    if (distance>do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
                    end
                    if (distance<=do)
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
                    end
                end     
            end
        % S(i).G=S(i).G-1;  
        end 
    end

    STATISTICS.COUNTCHS(r+1)=countCHs;
    %pause;

    for i=1:1:n
        if ( S(i).type=='N' && S(i).E>0 )
            if(cluster-1>=1)
                min_dis=Inf;
                min_dis_cluster=0;
                for c=1:1:cluster-1
                    temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
                    if ( temp<min_dis )
                        min_dis=temp;
                        min_dis_cluster=c;
                    end
                end 
                min_dis;
                if (min_dis>do)
                    S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                end
                if (min_dis<=do)
                    S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                end
                S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
                packets_TO_CH=packets_TO_CH+1;    
                S(i).min_dis=min_dis;
                S(i).min_dis_cluster=min_dis_cluster;
            else
                min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
                if (min_dis>do)
                    S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                end
                if (min_dis<=do)
                    S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                end
                packets_TO_BS=packets_TO_BS+1;
            end
        end
    end
    STATISTICS.PACKETS_TO_CH(r+1)=packets_TO_CH;
    STATISTICS.PACKETS_TO_BS(r+1)=packets_TO_BS;
end
STATISTICS1=STATISTICS;
FD1=first_dead;
TD1=teenth_dead;
AD1=all_dead;
STATISTICS.DEAD(r+1);
STATISTICS.ALLIVE(r+1);
STATISTICS.PACKETS_TO_CH(r+1);
STATISTICS.PACKETS_TO_BS(r+1);
STATISTICS.COUNTCHS(r+1);



