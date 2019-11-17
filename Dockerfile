FROM ubuntu:18.04

RUN apt update && apt -y upgrade
RUN apt -y install python libpng-dev wget bsdtar libfreetype6

# SageMath
# https://github.com/docker/hub-feedback/issues/727
RUN cd /opt \
&& wget -O - -o /dev/null http://mirrors.mit.edu/sage/linux/64bit/sage-8.9-Ubuntu_18.04-x86_64.tar.bz2 | \
bsdtar -xjf - \
&& echo 2+2 | /opt/SageMath/sage

# Jupyterhub
RUN apt -y install python3-pip npm \ 
&& npm install -g configurable-http-proxy \
&& pip3 install --no-cache notebook jupyterhub \
&& jupyterhub --generate-config

# Optionals
RUN apt install -y libcurl4-openssl-dev libssl-dev libopenblas-dev && pip3 install pycurl numpy scipy matplotlib

# Install kernels
# https://groups.google.com/forum/#!topic/sage-devel/RuWNK52yGYg
RUN echo 'import json\nfilename="/opt/SageMath/local/share/jupyter/kernels/sagemath/kernel.json"\nwith open(filename, "r") as f:\n x=json.loads(f.read())\nx["env"] = {"SAGE_ROOT": "/opt/SageMath"}\nwith open(filename, "w") as f:\n json.dump(x, f)' | python \
&& echo 'import json\nfilename="/opt/SageMath/local/share/jupyter/kernels/python2/kernel.json"\nwith open(filename, "r") as f:\n x=json.loads(f.read())\nx["argv"][0] = "/opt/SageMath/local/bin/python"\nwith open(filename, "w") as f:\n json.dump(x, f)' | python \
&& ln -s /opt/SageMath/local/share/jupyter/kernels/sagemath /usr/local/share/jupyter/kernels/sagemath \
&& ln -s /opt/SageMath/local/share/jupyter/kernels/python2 /usr/local/share/jupyter/kernels/python2

CMD ["jupyterhub"]
