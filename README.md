# IndeedMaps
Author: Sam Kleiner
### R.IndeedMaps.com
---
#### Config
- Fill in Indeed PUBLISHER_ID in IndeedAPICalls.py
- Set environment variable RPYTHON_PYTHON_VERSION=2.7

> Note: RPYTHON_PYTHON_VERSION shouldn't need to be set for install (it should default to system version see:https://cran.r-project.org/web/packages/rPython/INSTALL) however when installing rPython package to Ubuntu I had to set it for install to work. This was not a problem on Mac. Also on both Mac and Ubuntu setting this to version 3 still defaulted to 2.7. In this case it is not an issue because IndeedAPICalls.py will run on either.

---

#### R Packages
```r
> install.packages(c('ggplot2','maps','ggmap','tm','wordcloud','plyr','zipcode', 'shiny', 'rPython')), repos='http://cran.us.r-project.org')
```

> Note: If installing on a Shiny Server install packages as root. If not only user who installed them will have access to them. Which is a problem when the shiny user is running the server.

---

#### Python Packages
```sh
$ sudo pip install indeed
```

---

#### Ubuntu 14.04 Setup
Get R source
```sh
$ sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
$ gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
$ gpg -a --export E084DAB9 | sudo apt-key add -
```
Install
```sh
$ sudo apt-get update
$ sudo apt-get -y install r-base python-dev
```
