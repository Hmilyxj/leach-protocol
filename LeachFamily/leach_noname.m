function [STATISTICS2,FD2,TD2,AD2]=leach_noname(IniEng,NetSize,NoOfNode,NoOfRound,cluster_head_percentage,S)


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
 R_jtoi=0;
d_max=-Inf;
d_min=Inf;
w_1=0.5;
w_2=0.5;
w_3=0.4;
w_4=0.3;
w_5=0.3;
WW=0;
aa=0;
total_H=0;

for r=0:1:rmax 
    R_jtoi=0;
     d_max=-Inf;
     d_min=Inf;
     WW=0;
     total_H=0;
    
     
     if(r==1200)
        subplot(3,2,3);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH-Advanced,r=1200');
        hold on;
     end
     
     if(r==1400)
        subplot(3,2,4);
        for i=1:1:n
            if(S(i).E>0)
               plot(S(i).xd,S(i).yd,'bo');
               hold on;
            end
        end
        plot(S(n+1).xd,S(n+1).yd,'rp');
        axis([0 100 0 100]); 
        title('LEACH-Advanced,r=1400');
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
    Evg=TotalNetworkEnergy/(allive-dead);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    countCHs=0;
    cluster=1;
    
     for i=1:1:n
           if(S(i).E>0)
              S(i).d_toSink=sqrt((S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2);
              d_max=max(d_max,S(i).d_toSink);
              d_min=min(d_min,S(i).d_toSink);  
           end
     end
       
    for i=1:1:n
           if(S(i).E>0)
              S(i).d=(S(i).d_toSink-d_max)/(d_max-d_min);
           end
       end
    
     for i=1:1:n
        if(S(i).E>0)
            temp_rand=rand;     
            if ( (S(i).G)<=0)
                S(i).E_surplus=S(i).E/Eo;
                aa=(p/(1-p*mod(r,round(1/p))))*(w_1*S(i).E_surplus+w_2*(1-S(i).d));
                if(temp_rand<= aa)
                    S(i).type='H';
                    S(i).density=0;
                    S(i).N=0;
                     for j=1:1:n
                        if(j~=i)
                             R_jtoi=sqrt((S(i).xd-S(j).xd)^2+(S(i).yd-S(j).yd)^2);
                            if(S(j).E>0 && R_jtoi<=30)
                                S(i).N=S(i).N+1;
                            end
                        end
                     end
                    S(i).N_all=(allive-dead)/(NetSize^2)*pi*S(i).R*S(i).R;
                    S(i).density=S(i).N/S(i).N_all;
                end
            end
        end
     end
     
      
       for i=1:1:n
          if(S(i).type=='H' && S(i).E>0)
               S(i).w_1=w_3*S(i).E_surplus+w_4*S(i).density+w_5*S(i).d;
               WW = WW+S(i).w_1;
          end
       end
       
      for i=1:1:n
          if(S(i).type=='H' && S(i).E>0)
               total_H = total_H + 1;
          end
       end 
       
       for i=1:1:n
          if(S(i).type=='H' && S(i).E>0)
               if(S(i).w_1>=(WW/total_H))
                   S(i).type='C';
               end
          end
       end   
     
                    
    
    for i=1:1:n
        if(S(i).E>0)   
            if ( (S(i).G)<=0)
                if(S(i).type=='C')
                    countCHs=countCHs+1;
                    packets_TO_BS=packets_TO_BS+1;
                    PACKETS_TO_BS(r+1)=packets_TO_BS;
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
       if ( S(i).type=='N' || S(i).type=='H')
            if(S(i).E>0)
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



