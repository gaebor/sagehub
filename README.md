# gaebor/sagehub
[SageMath](http://www.sagemath.org/) and [python](https://www.python.org/) ready to go in a [jupyterhub](https://jupyter.org/hub)

This [ubuntu](https://ubuntu.com/) based image provides a jupyterhub server with the following kernels:
* Python 3.6
  * numpy
  * scipy
  * matplotlib
  * with `pip3`
* Python 2.7
  * not a system-wide installation! it is from Sage
  * with all the packages from Sage
  * you cannot `pip` it!
  * but you can [`sage -pip`](https://ask.sagemath.org/question/10978/how-to-upgrade-a-python-package-with-pip/)
* SageMath 8.9

It is (almost) ready to deploy as a classroom server.

## Deployment
First of all, it is **not advised to deploy this image "as is"**

You have to mind the followings:
* provide certificate for https
  * also configure jupyterhub accordingly
* provide the users
  * for example, create system users and use `PAMAuthenticator`
* it is advised to put it behind a proxy or firewall

Although some basic security measures are taken care of:
* default umask is `077` system-wide and within jupyter also

## Issues
* 3D plots do not work properly
* `var('x y'); plot3d(x^2+y^3,(x,-1,1), (y,-1,1), viewer='tachyon')` works
