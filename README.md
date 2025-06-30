![NTIWT logo](documentation/logos/logo_long_small.png)

# nti-wavelet-tools
NTI Wavelet Tools is a data processing toolbox. Current development language is IDL (Interactive Data Language), but some features are only available for IDL 8.5 or later and Python 3.6. Old SVN repository and issue management site: https://deep.reak.bme.hu/projects/wavelet

# installation
For using NTI WT, you need FLAP. Code access: https://github.com/fusion-flap/flap 

Follow instructions at: https://github.com/fusion-flap/flap/blob/master/docs/FLAP_install_guide.pdf

Clone the repository:

git clone https://github.com/fusion-flap/nti-wavelet-tools.git

Add parent directory to Python path!

Detailed instructions in the wiki: https://github.com/fusion-flap/nti-wavelet-tools/wiki

# branches
swich between branches (different versions) with:

git checkout ...
for example: git checkout <branch name>

In default, you start on the master branch, which is our latest released version.

you can list all available branches with:

git branch -a

# updating
To keep your copy up to date, it is recommended to update your repository frequently, using:

git pull

Updates are less frequent on the development branch (one per a few months), and rarest on the master branch.
They are more frequent on other, task-focused branches, some can have several commits per hour.

# GUI
For using the GUI, run python/gui/main.py



# References

### General
G. I. Pokol et al., Continuous linear time-frequency transforms in the analysis of fusion plasma transients. 40th EPS Conference on Plasma Physics (2013) Paper: 5.116 http://ocs.ciemat.es/EPS2013PAP/pdf/P5.116.pdf

G. I. Pokol et al., A wavelet based method for detecting transient plasma waves and determining their spatial structure, 37th EPS Conference on Plasma Physics (2010) Paper: 5.129 http://ocs.ciemat.es/EPS2010PAP/pdf/P5.129.pdf

### Bicoherence
Peter, Zsolt Poloskei et al., Bicoherence analysis of nonstationary and nonlinear processes. ARXIV PREPRINT 1811 Paper: https://arxiv.org/abs/1811.02973 (2018)

P. Zs. Poloskei et al. Bicoherence analysis of fast ion driven transient plasma waves, European Physical Society (EPS) (2017) Paper: P5.179, 4 p. http://ocs.ciemat.es/EPS2017PAP/pdf/P5.179.pdf

### Amplitude estimation
Horváth, L et al., Experimental investigation of the radial structure of energetic particle driven modes,
NUCLEAR FUSION 56 : 11 Paper: 112003 , 14 p. (2016), https://arxiv.org/abs/1604.00639

L, Horváth et al., Fast changes in the mode structure of chirping energetic particle driven modes, 42nd EPS Conference on Plasma Physics (2015) Paper: P1.148 , 1 p., http://ocs.ciemat.es/EPS2015PAP/pdf/P1.148.pdf

Sertoli, M et al., Characterization of saturated MHD instabilities through 2D electron temperature profile reconstruction from 1D ECE measurements, NUCLEAR FUSION 53 : 5 Paper: 053015 , 14 p. (2013), https://doi.org/10.1088/0029-5515/53/5/053015

G., Papp et al., Analysis of sawtooth precursor activity in ASDEX Upgrade using bandpower correlation method, 36th EPS Conference on Plasma Physics, (2009) Paper: P1.157, http://crpppc42.epfl.ch/Sofia/pdf/P1_157.pdf

Szepesi et al., Investigation of pellet-driven magnetic perturbations in different tokamak scenarios, PLASMA PHYSICS AND CONTROLLED FUSION 51 : 12 Paper: 125002 , 19 p. (2009), https://doi.org/10.1088/0741-3335/51/12/125002

Pokol, G et al., Application of a bandpower correlation method to the statistical analysis of MHD bursts in quiescent Wendelstein-7 AS stellarator plasmas, PLASMA PHYSICS AND CONTROLLED FUSION 49 : 9 pp. 1391-1408. , 18 p. (2007), https://doi.org/10.1088/0741-3335/49/9/003

G., Pokol et al., Statistical analysis of experimentally observed transient MHD modes, 30th EPS Conference on Controlled Fusion and Plasma Physics, (2003) Paper: P-3.7, http://epsppd.epfl.ch/StPetersburg/PDF/P3_007.PDF


### Mode number
Kocsis, G et al., Reliability study of pellet ELM pace making, 42nd EPS Conference on Plasma Physics (2015) Paper: P4.171 , 4 p. http://ocs.ciemat.es/EPS2015PAP/pdf/P4.171.pdf

Szepesi, T et al., Pellet-induced MHD activity in H-mode plasmas at ASDEX Upgrade, 40th EPS Conference on Plasma Physics (2013) Paper: P5.154 http://ocs.ciemat.es/EPS2013PAP/pdf/P5.154.pdf

Pokol, G et al., Experimental study and simulation of W7-AS transient MHD modes, AIP CONFERENCE PROCEEDINGS 993 : 1 pp. 215-218. , 4 p. (2008) http://dx.doi.org/10.1063/1.2909112

Horváth, L. et al., (2015). Reducing systematic errors in time-frequency resolved mode number analysis. Plasma Physics and Controlled Fusion, 57(12), 125005. doi:10.1088/0741-3335/57/12/125005 https://arxiv.org/pdf/1506.04864.pdf

G. I. Pokol, et al. A wavelet based method for detecting transient plasma waves and determining their spatial structure. European Physical Society (EPS) (2010) Paper: P5.129 http://ocs.ciemat.es/EPS2010PAP/pdf/P5.129.pdf


### Further related publications:
M. Hoppe et al., Spatiotemporal analysis of the runaway distribution function from synchrotron images in an ASDEX Upgrade disruption, arXiv.org Paper: https://arxiv.org/abs/2005.14593 , 23 p. (2021)

PH., LAUBER et al., Strongly non-linear energetic particle dynamics in ASDEX Upgrade scenarios with core impurity accumulation, In: 27th IAEA Fusion Energy Conference - IAEA CN-258 (2018) Paper: EX/1-1 , 8 p., https://conferences.iaea.org/event/151/papers/6094/files/5080-IAEA_proceedings_Lauber_v3.pdf

M, García-Muñoz et al., Fast-ion redistribution and loss due to edge perturbations in the ASDEX Upgrade, DIII-D and KSTAR tokamaks; IAEA Fusion energy conference (2012) pp. 1-4. , 4 p., https://doi.org/10.1088/0029-5515/53/12/123008

G. Papp et al., Sawtooth precursors in ASDEX Upgrade, 38th EPS Conference on Plasma Physics (2011) Paper: 4.093, http://ocs.ciemat.es/EPS2011PAP/pdf/P4.093.pdf

G. Papp et al., Low frequency sawtooth precursor activity in ASDEX Upgrade, PLASMA PHYSICS AND CONTROLLED FUSION 53 : 6 Paper: 065007 , 17 p. (2011), https://doi.org/10.1088/0741-3335/53/6/065007

P. Gábor et al., Low frequency sawtooth precursor in ASDEX Upgrade. Proceedings of the 5th IAEA Technical Meeting on Theory of Plasma Instabilities (IAEA-TM-40758) (2011) Paper: B4.1, http://w3fusion.ph.utexas.edu/ifs/iaeapi/papers/b4-1-papp-gergely-pi-paper.pdf

V. Igochine et al., The role of stochastization in fast MHD phenomena on ASDEX Upgrade, Proceedings of the 22nd IAEA Fusion Energy Conference (2008) Paper: EX/P9-10, https://www.researchgate.net/publication/251197333_Stochastization_as_a_possible_explanation_for_some_fast_MHD_phenomena_in_ASDEX_Upgrade

Belonohy, E et al., Density and Magnetic Fluctuation Studies on the W7-AS Stellarator, Proceedings of the 34th EPS Conference on Plasma Physics (2007) Paper: P2.046, http://epsppd.epfl.ch/Warsaw/pdf/P2_046.pdf

G. Pokol, G. Por, The Advanced Loose Parts Monitoring System (ALPS) and wavelet analysis, INTERNATIONAL JOURNAL OF NUCLEAR ENERGY SCIENCE AND TECHNOLOGY 2 : 3 pp. 241-252. , 12 p. (2006), https://www.researchgate.net/publication/229039197_The_Advanced_Loose_Parts_Monitoring_System_ALPS_and_wavelet_analysis

G. Papp et al., Analysis of transient MHD modes of Wendelstein 7-AS by coherence techniques, 32nd European Physical Society Conference on Plasma Physics and Controlled Fusion combined with the 8th International Workshop on Fast Ignition of Fusion Targets (2005) Paper: Paper P-5.021., http://epsppd.epfl.ch/Tarragona/pdf/P5_021.pdf

Pokol, G et al., Amplitude correlation analysis of W7-AS Mirnov-coil array data and other transport relevant diagnostics, Proceedings of the 20th IAEA Fusion Energy Conference: IAEA Conference & Symposium Papers (2005) https://www-pub.iaea.org/mtcd/meetings/PDFplus/fusion-20-preprints/EX_P6-22.pdf

Zoletnik, S et al., Anomalous transport events in the core plasma of the Wendelstein 7-AS stellarator, 32nd European Physical Society Conference on Plasma Physics and Controlled Fusion combined with the 8th International Workshop on Fast Ignition of Fusion Targets (2005) Paper: P-5.023, http://epsppd.epfl.ch/Tarragona/pdf/P5_023.pdf


### Hungarian
Horváth, László et al., Korszerű idő-frekvencia analízis programcsomag tranziens folyamatok vizsgálatára, NUKLEON 5 Paper: 111 , 6 p. (2012), https://nuklearis.hu/sites/default/files/nukleon/Nukleon_5_3_111_HorvathL.pdf

Lazányi, N et al., Alacsony frekvenciás fűrészfog prekurzor vizsgálata az ASDEX Upgrade tokamakon, NUKLEON 5 Paper: 101 , 5 p. (2012), https://nuklearis.hu/sites/default/files/nukleon/Nukleon_5_1_101_Lazanyi_0.pdf

G., Papp et al., Fűrészfog-oszcillációk vizsgálata az ASDEX-Upgrade tokamakon, NUKLEON 2 : 3 Paper: 41 , 5 p. (2009), https://nuklearis.hu/sites/default/files/nukleon/Nukleon2_2_41_Papp.pdf

G. Pokol, Tranziens hullámok fúziós plazmákban, NUKLEON 1 Paper: 01 , 6 p. (2008), https://nuklearis.hu/sites/default/files/nukleon/nukleon1_1_pokol.pdf

G. Pokol et al., Transzport-releváns fluktuációk mérése a Wendelstein 7-AS fúziós berendezésen, FIZIKAI SZEMLE 55 : 4 p. 126 (2005), http://fizikaiszemle.hu/archivum/fsz0504/PokolG_PorG_ZoletnikS.pdf
