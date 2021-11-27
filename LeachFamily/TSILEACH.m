function [STATISTICS3,FD3,TD3,AD3]=TSILEACH(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage)


xm=NetSize;
ym=NetSize;

sink.x=0.5*xm;
sink.y=1.35*ym;

n=NoOfNode;

p=cluster_head_percentage;

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

for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;
    YR(i)=S(i).yd;
    S(i).G=0;
    S(i).E=Eo*(1+rand*a);
    %initially there are no cluster heads only nodes
    S(i).type='N';
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;

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
    r
    if(mod(r, round(1/p) )==0)
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    TotalNetworkEnergy=0;
    for i=1:n
        if S(i).E>0
            TotalNetworkEnergy=TotalNetworkEnergy+S(i).E;
        end
    end
    STATISTICS.TotalEnergy(r+1)=TotalNetworkEnergy;
    STATISTICS.AvgEnergy(r+1)=TotalNetworkEnergy/n;
    avee=TotalNetworkEnergy/(n*2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    adDis=0;
    
    countCHs=0;
    cluster=1;
    for i=1:1:n
        if(S(i).E>0)
            temp_rand=rand;  
            
            if ( (S(i).G)<=0)  
                if(temp_rand<= (p/(1-p*mod(r,round(1/p))))*(S(i).E/Eo))%%Improvement1
                    
                     for j=1:1:n
                          if(sqrt( (S(i).xd-(S(j).xd))^2 + (S(i).yd-(S(j).yd))^2 )<40)
                              adDis=adDis+1;
                          end
                     end 
                    
                     if(adDis>40)
                    
                    countCHs=countCHs+1;
                    packets_TO_BS=packets_TO_BS+1;
                    PACKETS_TO_BS(r+1)=packets_TO_BS;
                    S(i).type='C';
                    S(i).G=round(1/p)-1;
                    C(cluster).xd=S(i).xd;
                    C(cluster).yd=S(i).yd;
                    distance=sqrt( (S(i).xd-(S(n+1).xd))^2 + (S(i).yd-(S(n+1).yd))^2 );
                    C(cluster).distance=distance;
                    C(cluster).id=i;
                    X(cluster)=S(i).xd;
                    Y(cluster)=S(i).yd;
                    cluster=cluster+1;
                    distance;
                    if (distance>do && mod(r,2)==0 )
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
                    end
                    if (distance<=do && mod(r,2)>=0 )
                        S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
                    end
                        
                     end 
                end 
            end
            
            % S(i).G=S(i).G-1;  
        end 
    end
    STATISTICS.COUNTCHS(r+1)=countCHs;

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
                %%Multihop Packet transmission to sink node via Multiple Cluster Head%%%%%%%%% 
                if(min_dis_cluster~=0)    
                    min_dis;
                    if (min_dis>do && mod(r,2)==0)
                        S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
                    end
                    if (min_dis<=do && mod(r,2)>=0)
                        S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
                    end
                    S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
                    packets_TO_CH=packets_TO_CH+1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%Improvement2%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
STATISTICS3=STATISTICS;
FD3=first_dead;
TD3=teenth_dead;
AD3=all_dead;
STATISTICS.DEAD(r+1);
STATISTICS.ALLIVE(r+1);
STATISTICS.PACKETS_TO_CH(r+1);
STATISTICS.PACKETS_TO_BS(r+1);
STATISTICS.COUNTCHS(r+1);



