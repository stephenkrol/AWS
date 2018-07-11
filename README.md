# AWS

## Description

User data for an AWS EC2 instance mirroring /Docker/ build.

This sets up an EC2 instance with Jupyter Notebook with: 

  * Beakerx (https://github.com/twosigma/beakerx) providing Clojure, Groovy, Java (openJDK 8), Kotlin, SQL, and Scala kernels
  * SciJava (https://github.com/scijava/scijava-jupyter-kernel) providing Clojure, Groovy, ImageJ, Python, JavaScript, and R within the same notebook
  * Anaconda providing Python 2/3, R, and a ton of data science packages.

-----

## Usage

Copy/paste from *aws_startup.txt* into the User Data field when configuring to launch an EC2 instance.
You will need to SSH in and run */opt/Anaconda/bin/jupyter notebook --no-browser* to start

Requirements:
  * After finishing on an Ubuntu base, du -hs reports **/** to be 8.6G (Anaconda + extras is 6.8G).
  * Open port 8888 (or change jupyter_notebook_config.py)
  * Do not run as root (or change jupyter_notebook_config.py)

-----

## Credits

This started as an adaptation of https://github.com/andreivmaksimov/python_data_science/.
