# MASC Reading 
MASC (Model of Attention in Superior Colliculus) toolbox for predicting eye-movements during reading  

<!-- Please cite this article if you find this repository useful:

Adeli, H., Ahn, S., & Zelinsky, G. (2021). Recurrent Attention Models with Object-centric Capsule Representation for Multi-object Recognition. arXiv preprint arXiv:2110.04954. [[arxiv](https://arxiv.org/abs/2110.04954)][[pdf](https://arxiv.org/pdf/2110.04954.pdf)] <br/>

@article{adeli2021recurrent,<br/>
&nbsp;&nbsp;title={Recurrent Attention Models with Object-centric Capsule Representation for Multi-object Recognition},<br/>
&nbsp;&nbsp;author={Adeli, Hossein and Ahn, Seoyoung and Zelinsky, Gregory},<br/>
&nbsp;&nbsp;journal={arXiv preprint arXiv:2110.04954},<br/>
&nbsp;&nbsp;year={2021}<br/>
}
 -->

The behavioral data, analyses and supplemetary material are provided in this link:

[Predicting readers' prototypical eye-movement behavior using MASC, a model of Attention in the Superior Colliculus: Stimulus materials, model code, data, and statistical analyses.](https://zenodo.org/record/5338616#.YXGdbRrMLcs)

-------------------------------------------------------------------------------------------------------

This demo shows how to use MASC to simulate eye movement during reading single sentences.

MASC_reading.m sets the parameters and runs the model.

"Saccade_model" parameter determines which method should be used for planning saccades.

For using MASC to generate fixations on sentence images, we need a separate method to generate the saliency map. We also used a method to simulate the retinal acuity limitations.

Download these two libraries from the following links and install them as instructed in each.

- [svistoolbox-1.0.5  Space Variant Imaging System](http://svi.cps.utexas.edu/software.shtml)
Using this library to perform reina transformation on the sentence image. The resulting images will have higher resolution near the current fovea and the resolution would progressively get worse with increasing distance from this point.

- [GBVS toolbox](http://www.vision.caltech.edu/~harel/share/gbvs.zip)
Using the implementation from this library to compute the Itti-Koch saliency map for each retina transformed sentence image.

 

-------------------------------------------------------------------------------------------------------


MASC_core is a model of the SC. It can accept a saliency (priority) map and generate eye-movements. Depending on the sources of the map, it can generate fixations during free viewing, visual search or reading.

MASC_core takes the priority map and the current fixation location as input and generates the next fixation location. To learn more about MASC and on how to apply the model to predict eye-movements during visual search and scene free viewing, refer to:

Adeli, H., Vitu, F., & Zelinsky, G. J. (2017). A model of the superior colliculus predicts fixation locations during scene viewing and visual search. Journal of Neuroscience, 37(6), 1453-1467. http://www.jneurosci.org/content/37/6/1453

For an implementation of MASC in python refer to https://github.com/Hosseinadeli/MASC_py

-------------------------------------------------------------------------------------------------------
<img src="https://github.com/Hosseinadeli/MASC_reading/blob/main/figures/vid_L1B1_10.bmp/L1B1_10.bmp_timesteps8.gif">

-------------------------------------------------------------------------------------------------------

<!-- #<img src="https://raw.githubusercontent.com/hosseinadeli/MASC_reading/main/figures/vid_L1B1_10.bmp/L1B1_10.bmp_timesteps8.gif"> -->

<!-- <img src="https://raw.githubusercontent.com/hosseinadeli/MASC_reading/main/figures/vid_L1B1_10.bmp/image02.png"> -->

<img src="https://github.com/Hosseinadeli/MASC_reading/blob/main/figures/vid_L1B1_14.bmp/L1B1_14.bmp_timesteps8.gif">

-------------------------------------------------------------------------------------------------------

<img src="https://github.com/Hosseinadeli/MASC_reading/blob/main/figures/vid_L1B1_15.bmp/L1B1_15.bmp_timesteps8.gif">

[Hossein Adeli](https://hosseinadeli.github.io/)<br/>
hossein.adelijelodar@gmail.com 

-------------------------------------------------------------------------------------------------------
Code references:

These two libraries are used for visualizing and saving scanpaths:


1) [svistoolbox-1.0.5  Space Variant Imaging System](http://svi.cps.utexas.edu/software.shtml) <br/>
2) [GBVS toolbox](http://www.vision.caltech.edu/~harel/share/gbvs.zip) <br/>
3) [export_fig](https://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig) <br/>
4) [arrow](https://www.mathworks.com/matlabcentral/fileexchange/278-arrow) <br/>

