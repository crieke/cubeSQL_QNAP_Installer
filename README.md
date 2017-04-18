# cubeSQL Installer for QNAP NAS (x64)
Install cubeSQL on your x64 QNAP device.

## Create the QPKG
This is the content of the .qpkg package to install cubeSQL on your QNAP NAS. To create the .qpkg file, install QDK on your QNAP, download the repository and copy the content of the QPKG folder to .../.qpkg/QDK/cubeSQL. Enter this directory by ssh and enter 'qbuild'. This will create the qpkg in the build folder. 


## I need a different version of cubeSQL
All cubeSQL binary files are downloaded from the cubeSQL website. If you need a different version, you can specify the download URL in a text file "CUBESQL_INSTALL_URL.txt". This file should be saved on the "cubeSQL" share, that needs to be created before the qpkg can be installed. It should only contain this 1 line, otherwise the installation will fail.