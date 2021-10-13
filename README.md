# MASC (Model of Attention in Superior Colliculus)

MASC toolbox for predicting eye-movements during reading  


[Hossein Adeli](https://hosseinadeli.github.io/),
hossein.adelijelodar@gmail.com 

This demo shows how to use MASC to simulate eye movement during reading single sentences.

MASC_core is a model of the SC. It can accept a saliency (priority) map and generate eye-movements. Depending on the sources of the map, it can generate fixations during free viewing, visual search or reading.

For using MASC to generate fixations on sentence images, we need a separate method to generate the saliency map. We also used a method to simulate the retinal acuity limitations.

Download these two libraries from the following links and install them as instructed in each.

- svistoolbox-1.0.5  Space Variant Imaging System (http://svi.cps.utexas.edu/software.shtml)
Using this library to perform reina transformation on the sentence image. The resulting images will have higher resolution near the current fovea and the resolution would progressively get worse with increasing distance from this point.

- GBVS toolbox (http://www.vision.caltech.edu/~harel/share/gbvs.zip)
Using the implementation from this library to compute the Itti-Koch saliency map for each retina transformed sentence image.

MASC_core takes the priority map and the current fixation location as input and generates the next fixation location.


MASC_reading.m sets the parameters and runs the model.

"Saccade_model" parameter determines which method should be used for planning saccades. 


These two libraries are used for visualizing and saving the scanpath:

1. export_fig  (https://www.mathworks.com/matlabcentral/fileexchange/23629-export-fig)
2. arrow  (https://www.mathworks.com/matlabcentral/fileexchange/278-arrow)

Refer to our JoN paper for applying the model to predict eye-movements during visual search and scene free viewing.

Adeli, H., Vitu, F., & Zelinsky, G. J. (2017). A model of the superior colliculus predicts fixation locations during scene viewing and visual search. Journal of Neuroscience, 37(6), 1453-1467. http://www.jneurosci.org/content/37/6/1453

For an implementation of MASC in python refer to https://github.com/Hosseinadeli/MASC_py




-------------------------------------------------------------------------------------------------------
<img src="https://github.com/Hosseinadeli/MASC_reading/blob/main/figures/vid_L1B1_10.bmp/L1B1_10.bmp_timesteps8.gif">
<!-- #<img src="https://raw.githubusercontent.com/hosseinadeli/MASC_reading/main/figures/vid_L1B1_10.bmp/L1B1_10.bmp_timesteps8.gif"> -->

<img src="https://raw.githubusercontent.com/hosseinadeli/MASC_reading/main/figures/vid_L1B1_10.bmp/image02.png">
