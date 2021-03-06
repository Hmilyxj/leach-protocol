function [STATISTICS2,FD2,TD2,AD2]=Leach_Centralized(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S)

xm=NetSize;
ym=NetSize;

sink.x=0.45*xm;
sink.y=0.5625*ym;

n=NoOfNode;

p=cluster_head_percentage;
%Pr=0.1;
Eo=IniEng;%Initial Energy og each node.
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

    if(r==1200)
        subplot(5,2,3);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH-C,r=1200');
        hold on;
    end
    
     if(r==1400)
         subplot(5,2,4);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH-C,r=1400');
        hold on;
     end
     
    if(mod(r, round(1/p))==0)
        for i=1:1:n
            S(i).G=0;
            S(i).cl=0;
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Calculate the average energy of the whole network%%%%%%%%%%%%%%%%%%%%
    Etotal=0;
    for i=1:n
        if S(i).E>0
            Etotal=Etotal+S(i).E;
        end
    end
    Eavg=Etotal/n;
    STATISTICS.TotalEnergy(r+1)=Etotal;
    STATISTICS.AvgEnergy(r+1)=Eavg;
    %%%%%%%%%%%%%%Improvement1%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    countCHs=0;
    cluster=1;
    for i=1:1:n
        if(S(i).E>0)
            %p(i)=Pr*n*S(i).E*Eo/(Etotal*Eavg);
            temp_rand=rand;
            %distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
            %obsv=p/(1-p*mod(r,round(1/p)))*abs(S(i).E-Eavg);
            if ( (S(i).G)<=0)  
                if (temp_rand<= (p/(1-p*mod(r,round(1/p)))))
                    if (S(i).E>Eavg)
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
            end
              
        end 
    end
    STATISTICS.COUNTCHS(r+1)=countCHs;
    %pause;

    for i=1:1:n
        if ( S(i).type=='N' && S(i).E>0 )
            if(cluster-1>=1)
                min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
                min_dis_cluster=0;
                for c=1:1:cluster-1
                    temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
                    if ( temp<min_dis )
                        min_dis=temp;
                        min_dis_cluster=c;
                    end
                end
                 
                if(min_dis_cluster~=0)    
                    min_dis;
                    if (min_dis>do)
                        S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                    end
                    if (min_dis<=do)
                        S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                    end
                    S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
                    packets_TO_CH=packets_TO_CH+1;
                  
                else 
                    min_dis;
                    if (min_dis>do)
                        S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                    end
                    if (min_dis<=do)
                        S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                    end
                    packets_TO_BS=packets_TO_BS+1;    
                    
                end
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
STATISTICS2=STATISTICS;
FD2=first_dead;
TD2=teenth_dead;
AD2=all_dead;
STATISTICS.DEAD(r+1);
STATISTICS.ALLIVE(r+1);
STATISTICS.PACKETS_TO_CH(r+1);
STATISTICS.PACKETS_TO_BS(r+1);
STATISTICS.COUNTCHS(r+1);



