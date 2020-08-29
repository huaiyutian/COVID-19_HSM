% ode system function for MCMC algae example
load('304flow0flowallleveltime.mat'); %108obs
theta=results2.mean;%results of f1.m
xdata=data.xdata;
simday=300;
t=1:56; %
n=304;  %
gamma1(1:n)=theta(3); %time period from onset to isolation
gamma=1./gamma1;
sigma=1/theta(1);%Incubation period 

report=1/theta(2); %report rate
beta_b(1:n)=theta(4); % basic transmission rate

Pwuhan=10892900;%population of Wuhan
HRwuhan=xdata(ceil(t),1523);%wuhan report daily cases
HRwuhan(1:5)=theta(5);
pop=xdata(ceil(57),2:(n+1))*1000000;%population of other city
innercity=xdata(ceil(t),(n+2):(2*n+1));%inner intensity 1.11-3.6
max_before_fes_inner=max(innercity(1:14,:)); %1.11-1.24: index:1-13
time1=xdata(ceil(t),1524:1827);
time2=xdata(ceil(t),1828:2131); 
HE(1,1:n) = 0; %
HI(1,1:n) = 0; %
HS(1,1:n) = pop-HE(1,:)-HI(1,:); %
HR(1,1:n) = 0; 
I(1,1:n)=0; %
res=cell(1,1);
resHS=cell(1,1);
dur=zeros(10,10);
%flow
Fcity=xdata(1:n,(2*n+3):(3*n+2))/31; %
%Fcity=Fcity-diag(diag(Fcity));%
Fcity2=xdata(1:n,(3*n+3):(4*n+2))/28;  %
%Fcity2=Fcity2-diag(diag(Fcity2));%
Fcity3=xdata(1:n,(4*n+3):(5*n+2))/31;  %
Allpop=repmat(pop,n,1); %

beta=beta_b;
flowWH=xdata(ceil(t),2:(n+1));%flow from wuhan to other city
flowWH(57:simday,:)=0;
HRwuhan(57:simday)=0;
c1=1;
 for perflow=[0.05:0.05:1] %flow
    for perinner=[0.05:0.05:1]
for i = 2:simday

beta2=c1*perinner; %inner intersity
if(i>13)%1.25
beta=beta_b*beta2; %
end
%%%%%%%%%%%Imported Infected cases
importI=HRwuhan(i-1)*flowWH(i-1,:)*report/Pwuhan*perflow; %
HEallcity=repmat(HE(i-1,:),304,1); %304*304

importallcity=Fcity*perflow.*HEallcity./Allpop; 
%importallcity=Fcity.*HEallcity./Allpop;
imcity=sum(importallcity,2); %
imcityout=sum(importallcity,1); %exposed
travelin=sum(Fcity,2);
travelout=sum(Fcity,1);
%%%%%%%%%%%%%%
HS(i,:)=HS(i-1,:)-beta.*HI(i-1,:).*HS(i-1,:)./pop+travelin'-travelout;%suspecitble population
HE(i,:)=HE(i-1,:)+beta.*HI(i-1,:).*HS(i-1,:)./pop+importI-imcityout+imcity'-sigma*HE(i-1,:);  %exposed population
HI(i,:)=HI(i-1,:)+sigma*HE(i-1,:)-gamma.*HI(i-1,:);%onset popuation      
HR(i,:)=HR(i-1,:)+gamma.*HI(i-1,:);% isolated population/confirmed population

I(i,:)=gamma.*HI(i-1,:);%be confirmed

end
 
ydot=[I(:,:)];
iflow=find(perflow==[0.05:0.05:1] );
iC=find(perinner==[0.05:0.05:1] );
res{1,1}{iflow,iC}=ydot;
resHS{1,1}{iflow,iC}=HS(simday,:);

yint=round(ydot);
sumHI=sum(yint,2);
%
[~,starind] = max((yint>=1),[],1); %
%
[~,endind]=max((flipud(yint)>0),[],1);%
fendind=size(yint,1)-endind+1;
duration=fendind-starind+1;%
duration(find(sum(yint,1)==0))=0;%
dur(iflow,iC)=mean(duration);%
[~,starindsum] = max((sumHI>=1),[],1);
[~,endindsum]=max((flipud(sumHI)>0),[],1);%
fendindsum=size(sumHI,1)-endindsum+1;
sumdur(iflow,iC)=fendindsum-starindsum+1;%
    end
 end
%plot
dur(find(dur>365))=370;
figure
imagesc(dur);            %# Create a colored plot of the matrix values
colormap(parula);  %# Change the colormap to gray (so higher values are
colorbar;                         %#   black and lower values are white)
set(gca,'XTick',4:5:20,...                         %# Change the axes tick marks
        'XTickLabel',{'20%','40%','60%','80%','100%'},...  %#   and tick labels
        'YTick',4:5:20,...
        'YTickLabel',{'20%','40%','60%','80%','100%'},...
        'TickLength',[0 0]);
    title('Average duration(day)','Fontname', 'Arial')
    xlabel('Intra-city travel','Fontname', 'Arial')
    ylabel('City-to-city travel','Fontname', 'Arial')
    
