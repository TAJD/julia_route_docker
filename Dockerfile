# reference: https://hub.docker.com/_/ubuntu/
FROM ubuntu:16.04

# Adds metadata to the image as a key value pair example LABEL version="1.0"
LABEL maintainer="Thomas Dickson <thomas.dickson@soton.ac.uk>"

##Set environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    build-essential \
    byobu \
    curl \
    git-core \
    htop \
    pkg-config \
    python3-dev \
    python3-pip \
    python-setuptools \
    python-virtualenv \
    unzip \
    && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# Install miniconda 

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

ENV PATH /opt/conda/bin:$PATH

# Install julia

RUN wget --quiet https://julialang-s3.julialang.org/bin/linux/x64/1.1/julia-1.1.0-linux-x86_64.tar.gz \ 
    && tar -xvzf julia-1.1.0-linux-x86_64.tar.gz
    
RUN mv julia-1.1.0 /opt/ 
RUN rm julia-1.1.0-linux-x86_64.tar.gz 

ENV PATH /opt/julia-1.1.0/bin:$PATH

# Create conda environment

RUN conda create -n routing \
    && conda install xarray basemap shapely scipy \
    && conda install -c conda-forge esmpy

RUN pip install xesmf

RUN julia -e 'using Pkg; Pkg.add("PyCall"); ENV["PYTHON"] = "/opt/conda/envs/routing"; Pkg.build("PyCall"); using PyCall'


# # Run terminal
# CMD ["julia"]

# RUN pip3 --no-cache-dir install --upgrade \
#         altair \
#         sklearn-pandas

# # Open Ports for Jupyter
# EXPOSE 7745

# #Setup File System
# RUN mkdir ds
# ENV HOME=/ds
# ENV SHELL=/bin/bash
# VOLUME /ds
# WORKDIR /ds
# ADD run_jupyter.sh /ds/run_jupyter.sh
# RUN chmod +x /ds/run_jupyter.sh

# # Run the shell
# CMD  ["./run_jupyter.sh"]
