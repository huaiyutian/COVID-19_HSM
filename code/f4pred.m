function ydot = f4pred(t,theta,xdata,im)
% ode system function for MCMC
day=136;%time period 1.11-5.25(due to Subsequent importation of foreign cases)
t=1:56; %time period 2020/1.11-3.6
n=304;  %number of city 
gamma1(1:n)=theta(3); %infectious period from onset to removed
gamma=1./gamma1; 
gamma_s=1./(gamma1*theta(10));%removed rate of symptomatic infectivity
sigma_a=1/theta(1);%Incubation period 
report=1/theta(2); %report rate
beta_b(1:n)=theta(4); % basic transmission rate
c1(1:n)=theta(6);% spatial distancing--control intensity--high level

%three classes of control intensity by previous study according to province
mid=[1	25	26	27	28	29	30	31	32	33	34	35	50	51	52	53	54	55	56	57	72	73	74	75	76	77	78	79	80	81	82	83	84	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198	199	200	201	202	203	204	205	206	207	208	209	210	211	212	213	214	215	216	217	218	219	220	221	222	247	248	249	250	251	252	253	254	255	270];
low=[3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	36	37	38	39	40	41	42	43	44	45	46	47	48	49	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	223	224	225	226	227	228	229	230	231	232	233	234	235	236	237	238	239	240	241	242	243	244	245	246	256	257	258	259	260	261	262	263	264	265	266	267	268	269	271	272	273	274	275	276	277	278	279	280	281	282	283	284	285	286	287	288	289	290	291	292	293	294	295	296	297	298	299	300	301	302	303	304];
c1(mid)=theta(7);%mid level of control intensity
c1(low)=theta(8);%low level of control intensity
c2(1:n)=theta(9);%spatial distancing--control intensity in the second phase
afa=0.5;%relative infectiousness of asymptomatic individuals [ref.Alberto,2020,nature human behavior]
beta_s=0.15;%proportion of presymptomatic transmission equals percent of infectioness [ref.Alberto,2020,nature human behavior]
sigma_pre=1/2;%Incubation period BUT presymptomatic [ref.Alberto,2020,nature human behavior]
sigma_s=1/(theta(1)-2);%Incubation period of symptomatic individuals
p=0.25;%proportion of asymptomatic

% data
Pwuhan=10892900;%population of Wuhan
flow=xdata(ceil(t),2:(n+1));%flow from wuhan to other city
flow(57:day,:)=0;%flow from wuhan to other city,as wuhan has been shutdown from 1.23,thus we set flow=0
HRwuhan=xdata(ceil(t),1523);%wuhan report daily cases--onset
HRwuhan(1:5)=theta(5);%wuhan report daily cases
HRwuhan(57:day)=0;%as flow from wuhan=0,thus HRwuhan is not used.
pop=xdata(ceil(57),2:(n+1))*1000000;%population of other city
innercity=xdata(ceil(t),(n+2):(2*n+1));%inner intensity 1.11-3.6
innercity(57:day,:)=repmat(innercity(56,:),80,1);%innercity set as inner intensity on 3.6
max_before_fes_inner=max(innercity(1:14,:)); %1.11-1.24: index:1-14:days before New Year
time1=xdata(ceil(t),1524:1827);%the time of 1-level response
time2=xdata(ceil(t),1828:2131); % the time of 2nd control
time1(57:day,:)=1; %Completion of time1   to 5/25
time2(57:day,:)=1; %Completion of time2   to 5/25
HLa(1,1:n) = 0; %latent asymptomatic 
HIa(1,1:n) = 0; % infectious asymptomatic
HLs(1,1:n) = 0; %latent symptomatic 
HLp(1,1:n) = 0; %presymptomatic
HS(1,1:n) = pop; %susceptible
HI(1,1:n) = 0; %infectious symptomatic 
HR(1,1:n) = 0; %removed infectious indivial
I(1,1:n)=0; %daily reported cases
HN(1,1:n)=HS(1,1:n);%all population

%inter-city flow
Fcity=xdata(1:n,(2*n+3):(3*n+2))/31; % city travel in JAN.
Fcity2=xdata(1:n,(3*n+3):(4*n+2))/28;  %city travel in FEB.
Fcity3=xdata(1:n,(4*n+3):(5*n+2))/31;  %city travel in MAR.
%travel balance: for each city:out flow=in flow;
Fcitylater=Fcity3;
for i=1:304
    Fcitylater(((i+1):304),i)= Fcitylater(i,((i+1):304));
end

beta=beta_b;%basic transimission rate
% construct data 1/11-5/25
importoutC(1:day,1:n)=0;
importoutC(50:day,:)=im;%international imported cases, from 2.29
importHLs(1,1:n)=0; %imported latent symtomatic
importHLp(1,1:n)=0; %imported latent presymtomatic
importHI(1,1:n)=0; %imported infectious symtomatic
importR(1,1:n)=0; %imported removed
imnewI(1,1:n)=0; %imported daily reported cases 

localHLs(1,1:n)=0; %local latent symtomatic
localHLp(1,1:n)=0; %local latent presymtomatic
localHI(1,1:n)=0; %local infectious symtomatic
localR(1,1:n)=0; %local removed
local(1,1:n)=0; %local daily reported cases

for i = 2:day

beta2=c1.*(innercity(i-1,:)./max_before_fes_inner); %transmission control

%1-level response-control
beta(find(time1(i,:)==1))=beta_b(find(time1(i,:)==1)).*beta2(find(time1(i,:)==1));
%%2nd phase control 
beta(find(time2(i,:)==1))=beta_b(find(time2(i,:)==1)).*beta2(find(time2(i,:)==1)).*c2(find(time2(i,:)==1));


%% Imported Infected cases
importI=HRwuhan(i-1)*flow(i-1,:)*report/Pwuhan; %exposed cases from wuhan to other cities
%inter-city travel
if(i>21 && i<51) 
            Fcity=Fcity2; %inter-city movement flow in FEB.
            elseif (i>50 && i<83)
            Fcity=Fcity3; %inter-city movement flow in MAR AND LATER
            elseif(i>82)
            Fcity=Fcitylater;%inter-city movement LATER
end
         

%% different class to calculate travel people proportion later 
HLaallcity=repmat(HLa(i-1,:),304,1); %matrix 304*304,latent asymptomatic population of cities
HIaallcity=repmat(HIa(i-1,:),304,1); %matrix 304*304,infectious asymptomatic population of cities
HLsallcity=repmat(HLs(i-1,:),304,1); %matrix 304*304,latent symptomatic population of cities
HLpallcity=repmat(HLp(i-1,:),304,1); %matrix 304*304,presymptomatic population of cities
HNallcity=repmat(HN(i-1,:),304,1);   %matrix 304*304,infectious symptomatic population of cities
HSallcity=repmat(HS(i-1,:),304,1);   %matrix 304*304,suspecitble population of cities

HLaallcity(HLaallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
HIaallcity(HIaallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
HLsallcity(HLsallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus
HLpallcity(HLpallcity<1)=0; %we assume that Less than one person does not have the ability to transmit virus


%% exposed population who travel between cities  
imcity_la=sum(Fcity.*HLaallcity./HNallcity,2); %latent asymptomatic population who flow into the city
imcityout_la=sum(Fcity.*HLaallcity./HNallcity,1); %latent asymptomatic population who flow out of the city
imcity_ia=sum(Fcity.*HIaallcity./HNallcity,2); %infectious asymptomatic population who flow into the city
imcityout_ia=sum(Fcity.*HIaallcity./HNallcity,1); %infectious asymptomatic population who flow out the city
imcity_ls=sum(Fcity.*HLsallcity./HNallcity,2); %latent symptomatic population who flow into the city
imcityout_ls=sum(Fcity.*HLsallcity./HNallcity,1); %latent symptomatic population who flow out the city
imcity_lp=sum(Fcity.*HLpallcity./HNallcity,2); %presymptomatic population who flow into the city
imcityout_lp=sum(Fcity.*HLpallcity./HNallcity,1); %presymptomatic population who flow out the city
% suspectible travel population
imcity_s=sum(Fcity.*HSallcity./HNallcity,2);%suspectible population who flow into the city
imcityout_s=sum(Fcity.*HSallcity./HNallcity,1);%suspectible population who flow out the city
%%%%%%%%%%%%%%
%%
%suspecitble population
HS(i,:)=HS(i-1,:)-(afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+imcity_s'-imcityout_s;
%asymptomatic population
HLa(i,:)=HLa(i-1,:)+p*((afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+importI)-imcityout_la+imcity_la'-sigma_a*HLa(i-1,:); %latent
HIa(i,:)=HIa(i-1,:)+sigma_a*HLa(i-1,:)-gamma.*HIa(i-1,:)-imcityout_ia+imcity_ia';%infectious
%symptomatic population
HLs(i,:)=HLs(i-1,:)+(1-p)*((afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:)+importI)-imcityout_ls+imcity_ls'-sigma_s*HLs(i-1,:);%latent
HLp(i,:)=HLp(i-1,:)+sigma_s*HLs(i-1,:)-sigma_pre*HLp(i-1,:)-imcityout_lp+imcity_lp';%presymtomatic
HI(i,:)=HI(i-1,:)+sigma_pre*HLp(i-1,:)-gamma_s.*HI(i-1,:); %infectious
% removed population
HR(i,:)=HR(i-1,:)+gamma_s.*HI(i-1,:)+gamma.*HIa(i-1,:);
%all population
HN(i,:)=HS(i,:)+HLa(i,:)+HIa(i,:)+HLs(i,:)+HLp(i,:)+HI(i,:)+HR(i,:); 
%be confirmed cases
I(i,:)=gamma_s.*HI(i-1,:);

%%%import cases inside cities
%symptomatic population
%to prevent the denominator from being 0, we add 0.000001 to the
%denominator 
importHLs(i,:)=importHLs(i-1,:)+(1-p)*importI-imcityout_ls.*importHLs(i-1,:)./(importHLs(i-1,:)+localHLs(i-1,:)+0.000001)+imcity_ls'-sigma_s*importHLs(i-1,:);
importHLp(i,:)=importHLp(i-1,:)+sigma_s*importHLs(i-1,:)-sigma_pre*importHLp(i-1,:)-imcityout_lp.*importHLp(i-1,:)./(importHLp(i-1,:)+localHLp(i-1,:)+0.000001)+imcity_lp';
importHI(i,:)=importHI(i-1,:)+sigma_pre*importHLp(i-1,:)-gamma_s.*importHI(i-1,:); 
importR(i,:)=importR(i-1,:)+gamma_s.*importHI(i-1,:);
imnewI(i,:)=gamma_s.*importHI(i-1,:);%daily reported imported cases 

%local cases inside cities
localHLs(i,:)=localHLs(i-1,:)+(1-p)*((afa*beta.*HIa(i-1,:)+beta.*HI(i-1,:)+beta_s*beta.*HLp(i-1,:)).*HS(i-1,:)./HN(i-1,:))-sigma_s*localHLs(i-1,:)-imcityout_ls.*localHLs(i-1,:)./(importHLs(i-1,:)+localHLs(i-1,:)+0.000001);
localHLp(i,:)=localHLp(i-1,:)+sigma_s*localHLs(i-1,:)-sigma_pre*localHLp(i-1,:)-imcityout_lp.*localHLp(i-1,:)./(importHLp(i-1,:)+localHLp(i-1,:)+0.000001);
localHI(i,:)=localHI(i-1,:)+sigma_pre*localHLp(i-1,:)-gamma_s.*localHI(i-1,:); 
localR(i,:)=localR(i-1,:)+gamma_s.*localHI(i-1,:);
local(i,:)=gamma_s.*localHI(i-1,:);%daily reported local cases 
end
 
ydot=[I(:,:),local(:,:),imnewI(:,:)];%resutls:[all cases,local cases, imported cases]



