function ydot = f4(t,theta,xdata)

t=1:56; %time period 2020/1.11-3.6
n=304;  %number of city 
gamma1(1:n)=theta(3); %infectious period from onset to removed of the asymptomatic
gamma=1./gamma1; 
gamma_s=1./(gamma1*theta(10));%removed rate of symptomatic infectivity
sigma_a=1/theta(1);%Mean latent period (days)
report=1/theta(2); %report rate 
beta_b(1:n)=theta(4); % basic transmission rate
c1(1:n)=theta(6);% spatial distancing--control intensity--high level

%three classes of control intensity by previous study according to
%province[ref.Tian,2020,science]
mid=[1	25	26	27	28	29	30	31	32	33	34	35	50	51	52	53	54	55	56	57	72	73	74	75	76	77	78	79	80	81	82	83	84	96	97	98	99	100	101	102	103	104	105	106	107	108	109	110	111	112	113	114	115	116	117	118	119	120	121	122	123	124	125	126	127	128	129	130	131	132	133	134	135	136	137	138	139	140	141	142	143	144	145	146	176	177	178	179	180	181	182	183	184	185	186	187	188	189	190	191	192	193	194	195	196	197	198	199	200	201	202	203	204	205	206	207	208	209	210	211	212	213	214	215	216	217	218	219	220	221	222	247	248	249	250	251	252	253	254	255	270];
low=[3	4	5	6	7	8	9	10	11	12	13	14	15	16	17	18	19	20	21	22	23	24	36	37	38	39	40	41	42	43	44	45	46	47	48	49	147	148	149	150	151	152	153	154	155	156	157	158	159	160	161	162	163	223	224	225	226	227	228	229	230	231	232	233	234	235	236	237	238	239	240	241	242	243	244	245	246	256	257	258	259	260	261	262	263	264	265	266	267	268	269	271	272	273	274	275	276	277	278	279	280	281	282	283	284	285	286	287	288	289	290	291	292	293	294	295	296	297	298	299	300	301	302	303	304];
c1(mid)=theta(7);%mid level of control intensity
c1(low)=theta(8);%low level of control intensity
c2(1:n)=theta(9);%spatial distancing--control intensity in the second phase
afa=0.5;%relative infectiousness of asymptomatic individuals [ref.Alberto,2020,nature human behavior]
beta_s=0.15;%proportion of presymptomatic transmission equals percent of infectioness [ref.Alberto,2020,nature human behavior]
sigma_pre=1/2;%latent period BUT presymptomatic [ref.Alberto,2020,nature human behavior]
sigma_s=1/(theta(1)-2);%latent period of symptomatic individuals
p=0.25;%proportion of asymptomatic

% data
Pwuhan=10892900;%population of Wuhan
flow=xdata(ceil(t),2:(n+1));%flow from wuhan to other city
HRwuhan=xdata(ceil(t),1523);%wuhan report daily cases
HRwuhan(1:5)=theta(5);%the estimated reported cases of first 5 days in wuhan
pop=xdata(ceil(57),2:(n+1))*1000000;%population of other city
innercity=xdata(ceil(t),(n+2):(2*n+1));%inner intensity 1.11-3.6
max_before_fes_inner=max(innercity(1:14,:)); %1.11-1.24: index:1-14:days before New Year
time1=xdata(ceil(t),1524:1827);%time of 1-level response
time2=xdata(ceil(t),1828:2131); % time of 2nd control
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
Fcity=xdata(1:n,(2*n+3):(3*n+2))/31;   %intra-city travel in JAN.
Fcity2=xdata(1:n,(3*n+3):(4*n+2))/28;  %intra-city travel in FEB.
Fcity3=xdata(1:n,(4*n+3):(5*n+2))/31;  %intra-city travel in MAR.

beta=beta_b;%basic transimission rate

for i = 2:56 %1.11-3.6

beta2=c1.*(innercity(i-1,:)./max_before_fes_inner); %transmission control

%1-level response-control
beta(find(time1(i,:)==1))=beta_b(find(time1(i,:)==1)).*beta2(find(time1(i,:)==1));
%2nd phase control 
beta(find(time2(i,:)==1))=beta_b(find(time2(i,:)==1)).*beta2(find(time2(i,:)==1)).*c2(find(time2(i,:)==1));


%% Imported Infected cases
importI=HRwuhan(i-1)*flow(i-1,:)*report/Pwuhan; %exposed cases from wuhan to other cities

 if(i>21 && i<51) 
            Fcity=Fcity2; %inter-city movement flow in FEB.
 elseif i>50
            Fcity=Fcity3; %inter-city movement flow in MAR.  
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

%% model
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
%daily confirmed cases
I(i,:)=gamma_s.*HI(i-1,:);

end

ydot=[I(:,:)];
 

