# COVID-19_HSM

Code for: Quantifying the impact of lockdowns on the local and hierarchical spread of SARS-CoV-2

## Citation

Quantifying the impact of lockdowns on the local and hierarchical spread of SARS-CoV-2

Huaiyu Tian, Yidan Li, Moritz U.G. Kraemer, Bingying Li, Yonghong Liu, Ligui Wang, Hua Tan, Chieh-Hsi Wu, Zengmiao Wang, Pai Zheng, Peng Yang, Quanyi Wang, Henrik Salje, Christopher Dye, Oliver G. Pybus, Hongbin Song, Bryan T. Grenfell, Ottar N. Bjornstad

## Abstract

Many countries worldwide have implemented lockdowns to contain the initial pandemic wave of SARS-CoV-2, with substantial success in bringing the epidemic’s effective reproduction number close to or below one in several regions. In order to best inform policy we need to understand the effectiveness of the lockdown and spatial distancing on containing the ongoing SARS-CoV-2 pandemic. Models of spatial and local spread are critical to evaluate plausible scenarios for safe future return to normality. Here we use a unique mobile phone dataset from China covering within-and-between 358 cities analyzing 561 million travel movements before and after the national emergence response, to inform a spatiotemporal model of SARS-CoV-2 transmission in China during the first 6 months of spread and containment of the initial wave. We find that during the emergency response nationwide travel declined by 73% between cities and movement within city was reduced by 63%. Our calculations show that combined interventions including large-scale lockdown and spatial distancing in place for months, depending on implementation and intensity, were critical for initial control of the virus.

## Notes on the code

To run, you need a Matlab toolbox called "DRAM": 
DRAM is a combination of two ideas for improving the efficiency of Metropolis-Hastings type Markov chain Monte Carlo (MCMC) algorithms, Delayed Rejection and Adaptive Metropolis. This page explains the basic ideas behind DRAM and provides examples and Matlab code for the computations.(see http://helios.fmi.fi/~lainema/dram/)

## Data

### Epidemiological data

We collected the daily official case reports from the health commission of 34 provincial-level administrative units and 358 city-level units, the website’s links are provided. The information was collected by Bingying Li.

### Mobility data

Human movement in China can be observed directly from mobile phone data, through the Baidu location-based services (LBS). Both the recorded movements and relative volume of inflows, outflows, inner movement among cities (n=358), were obtained from the migration flows database (http://qianxi.baidu.com/) from 1 January 2019 to 1 April 2020. Mobility data outside China is obtained from Apple Maps (www.apple.com/covid19/mobility) from 13 January 2020 to 4 July 2020, a total of 40 countries were used for analysis (See Extended Data Table 2). Baidu's LBS data was collected and processed by Dr.Ligui Wang and Dr.Hongbin Song.

## License

(see LICENSE)

Additional license, warranty, and copyright information

We provide a license for our code (see LICENSE) and do not claim ownership, nor the right to license, the data we have obtained nor any third-party software tools/code used in our analyses. Please cite the appropriate agency, paper, and/or individual in publications and/or derivatives using these data, contact them regarding the legal use of these data, and remember to pass-forward any existing license/warranty/copyright information. THE DATA AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE DATA AND/OR SOFTWARE OR THE USE OR OTHER DEALINGS IN THE DATA AND/OR SOFTWARE.
