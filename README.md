# COVID-19_HSM
[![DOI](https://zenodo.org/badge/290725201.svg)](https://zenodo.org/badge/latestdoi/290725201)
Code for: Quantifying the impact of lockdowns on the local and hierarchical spread of SARS-CoV-2

## Citation

Quantifying the impact of lockdowns on the local and hierarchical spread of SARS-CoV-2

Huaiyu Tian, Yidan Li, Moritz U.G. Kraemer, Bingying Li, Yonghong Liu, Ligui Wang, Hua Tan, Chieh-Hsi Wu, Zengmiao Wang, Pai Zheng, Peng Yang, Quanyi Wang, Marko Laine, Henrik Salje, Christopher Dye, Oliver G. Pybus, Hongbin Song, Bryan T. Grenfell, Ottar N. Bjornstad

## Abstract

Many countries worldwide have implemented lockdowns to contain the initial pandemic wave of SARS-CoV-2, with substantial success in bringing the epidemic’s effective reproduction number close to one (“flattening the curve”) or below one (local containment) in several regions. In order to best inform policy we need to understand the effectiveness of the lockdown and social distancing on managing the ongoing SARS-CoV-2 pandemic. Models of spatial and local spread are critical to evaluate plausible scenarios. Here we use a unique mobile phone dataset from China covering within-and-between 358 cities analyzing 561 million travel movements before and after the national emergence response to inform a spatiotemporal model of SARS-CoV-2 transmission during the first 6 months in the initial wave. We find that during the emergency response nationwide travel declined by 73% between cities and movement within cities was reduced by an average of 63%. The analysis details how spread of infection correlates with travel movements and how spatial transmission decay with geographical distance. Epidemic duration in each city was positively correlated with movement inflow and population size. Our model projections of the national emergency response show that once the epidemic had seeded among cities, combined interventions including large-scale lockdown through intra-city travel restriction and social distancing in place for months, depending on implementation and intensity, were critical for initial control of the virus. The coordination of future lockdowns among hundreds of cities with major travel flows may be required to curb transmission of a second wave.

## Notes on the code

To run, you need a Matlab toolbox called "DRAM": 
DRAM is a combination of two ideas for improving the efficiency of Metropolis-Hastings type Markov chain Monte Carlo (MCMC) algorithms, Delayed Rejection and Adaptive Metropolis. This page explains the basic ideas behind DRAM and provides examples and Matlab code for the computations.(see http://helios.fmi.fi/~lainema/dram/)

About code folder:
main file : f1.m;
funciton dependencies:f2.m,f3.m,f4.m and MCMC DRAM toolbox;

All senarios and figure results can get in following independent files:
1.fig 4a:  f5.m(main file),f3pred.m,f4pred.m
local and imported cases:

2.fig 4c,4d: f8_csd_cld.m
epidemic duration ~ social distancing+ lockdown(intra+inner) 
average peak size for cities ~ social distancing + lockdown(intra+inner) 

3.fig S6 (fig R1): f8_intra_csd.m; f8_inter_csd.m
respective effect of inter-city and intra-city travel and social distancing

4.fig S7: f8_inter_intra_sd.m(mail file), f8_controlforsd.m 
average epidemic duration for cities and average peak size for cities in various setting of inter-city travel and intra-city travel when social distancing=0.2,0.4,0.6,1

5.fig S8: f8_inter_csd_ahead1w_whlockdown.m
Shortened epidemic duration of cities under inter-city travel restriction implemented one week earlier than actual timing. 

6.fig S9: f8_inter_intra_R0.m(mail file), f8_controlforR0.m 
average peak size for cities in various setting of lockdown and social distancing when R0=2,3,4;

7.fig S10: f8_csd_cld_lock.m
 average epidemic duration for cities in various setting of the proportion of cities shutdown 
(banned inter-city travel and restrict intra-city travel (reduced to 10%)) and social distancing.

## Data

### Epidemiological data

We collected the daily official case reports from the health commission of 34 provincial-level administrative units and 358 city-level units, the website’s links are provided. The information was collected by Bingying Li.

### Mobility data

Human movement in China can be observed directly from mobile phone data, through the Baidu location-based services (LBS). Both the recorded movements and relative volume of inflows, outflows, inner movement among cities (n=358), were obtained from the migration flows database (http://qianxi.baidu.com/) from 1 January 2019 to 1 April 2020. Mobility data outside China is obtained from Apple Maps (www.apple.com/covid19/mobility) from 13 January 2020 to 4 July 2020, a total of 40 countries were used for analysis (See Extended Data Table 2). The human mobility data that support the findings of this study are available on request from the Baidu location-based services (Baidu Online Network Technology (Beijing) Co.,Ltd., http://qianxi.baidu.com/). Baidu's LBS data was collected and processed by Dr.Ligui Wang and Dr.Hongbin Song. 

## License

(see LICENSE)

Additional license, warranty, and copyright information

We provide a license for our code (see LICENSE) and do not claim ownership, nor the right to license, the data we have obtained nor any third-party software tools/code used in our analyses. Please cite the appropriate agency, paper, and/or individual in publications and/or derivatives using these data, contact them regarding the legal use of these data, and remember to pass-forward any existing license/warranty/copyright information. THE DATA AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA AND/OR SOFTWARE OR THE USE OR OTHER DEALINGS IN THE DATA AND/OR SOFTWARE.
