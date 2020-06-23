FROM ubuntu:18.04

RUN apt update && apt -y upgrade
RUN apt -y install python-pip python3-pip wget bsdtar imagemagick

# Jupyterhub
RUN apt -y install npm \ 
&& npm install -g configurable-http-proxy \
&& python3 -m pip install --no-cache notebook jupyterhub \
&& jupyterhub --generate-config

# SageMath
# https://github.com/docker/hub-feedback/issues/727
RUN cd /opt && wget -O - -o /dev/null http://mirrors.mit.edu/sage/linux/64bit/sage-8.9-Ubuntu_18.04-x86_64.tar.bz2 | \
    bsdtar -xjf - && mv SageMath SageMath-8.9 && echo 2+2 | /opt/SageMath-8.9/sage
RUN cd /opt && wget -O - -o /dev/null http://mirrors.mit.edu/sage/linux/64bit/sage-9.1-Ubuntu_18.04-x86_64.tar.bz2 | \
    bsdtar -xjf - && mv SageMath SageMath-9.1 && echo 2+2 | /opt/SageMath-9.1/sage

# Install kernels
# https://stackoverflow.com/a/37857536
RUN python2 -m pip install ipykernel && python2 -m ipykernel install && \
    echo 'import json\nfilename="/opt/SageMath-8.9/local/share/jupyter/kernels/sagemath/kernel.json"\nwith open(filename, "r") as f:\n x=json.loads(f.read())\nx["env"] = {"SAGE_ROOT": "/opt/SageMath-8.9"}\nwith open(filename, "w") as f:\n json.dump(x, f)' | python && \
    echo 'import json\nfilename="/opt/SageMath-9.1/local/share/jupyter/kernels/sagemath/kernel.json"\nwith open(filename, "r") as f:\n x=json.loads(f.read())\nx["env"] = {"SAGE_ROOT": "/opt/SageMath-9.1"}\nwith open(filename, "w") as f:\n json.dump(x, f)' | python && \
    ln -s /opt/SageMath-8.9/local/share/jupyter/kernels/sagemath /usr/local/share/jupyter/kernels/sagemath89 && \
    ln -s /opt/SageMath-9.1/local/share/jupyter/kernels/sagemath /usr/local/share/jupyter/kernels/sagemath91

# Optionals
RUN apt install -y libcurl4-openssl-dev libssl-dev libopenblas-dev && \
    python3 -m pip install pycurl numpy scipy matplotlib ipywidgets && \
    jupyter nbextension enable --py --system widgetsnbextension && \
    python3 -m pip install jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --system

# Permissions
RUN mkdir -p /etc/jupyter && echo 'import os; os.umask(0o077)' > /etc/jupyter/jupyter_notebook_config.py \
&& echo 'umask 077' | cat - /etc/profile > /etc/profile.new && mv /etc/profile.new /etc/profile

CMD ["jupyterhub"]
