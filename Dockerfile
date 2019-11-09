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
RUN apt -y install python3-pip npm libopenblas-dev \ 
&& npm install -g configurable-http-proxy \
&& pip3 install --no-cache notebook numpy scipy matplotlib jupyterhub \
&& jupyterhub --generate-config

# Install kernels
# https://groups.google.com/forum/#!topic/sage-devel/RuWNK52yGYg
RUN echo '{\n "display_name": "SageMath 8.9",\n "language": "sage",\n "argv": ["/opt/SageMath/local/bin/sage", "--python", "-m", "sage.repl.ipython_kernel", "-f", "{connection_file}"],\n "env": {"SAGE_ROOT": "/opt/SageMath"}\n}' > /opt/SageMath/local/share/jupyter/kernels/sagemath/kernel.json \
&& echo '{\n "display_name": "Python 2",\n "language": "python",\n "argv": ["/opt/SageMath/local/bin/python", "-m",   "ipykernel_launcher", "-f", "{connection_file}"]\n}' > /opt/SageMath/local/share/jupyter/kernels/python2/kernel.json \
&& ln -s /opt/SageMath/local/share/jupyter/kernels/sagemath /usr/local/share/jupyter/kernels/sagemath \
&& ln -s /opt/SageMath/local/share/jupyter/kernels/python2 /usr/local/share/jupyter/kernels/python2

CMD ["jupyterhub"]
