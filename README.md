# Fourier-Mellin-Registration
Implemented in matlab, a registration method of subpixel image registration.

# Pipeline
The process of this method is as follows:

1. Preprocessing of edge extraction of image pairs.

2. Pixel level registration based on Fourier Mellin

   Transform the image from Cartesian coordinate system to log polar coordinate system, and calculate the rotation and scaling relationship between the two images

3. Subpixel registration based on coherence coefficient method

   This part of the process includes:

   (1) Image feature point detection (Harris corner has been used in this project).

   (2) Select the N points with the largest response for correlation operation.

   (3) The retained points are fitted by the least square method to obtain the transformation relationship between images.

