# fMRI_BIDS_Compliance
a repository on how I am attempting to convert my fMRI files to BIDS format


Link to Initial Data: https://mailmissouri-my.sharepoint.com/:f:/g/personal/ddsnph_umsystem_edu/Eq2h9V7-CypCnDPQCcuazLcBuge8rdKyMysKEmP7lsrKyA?e=beHibD


Link to Current Data I converted: https://mailmissouri-my.sharepoint.com/:f:/g/personal/ddsnph_umsystem_edu/ElnQBEYbBxJAoPQnTENQhYYBJzg6azjsahShlm4pwzsFHA?e=lBIRRa

To Tyler or whoever is reading this, my issues:

I've been tasked with converting the initial data into BIDS format. For an accurate description of what BIDS format is, here is a link: https://bids.neuroimaging.io/index.html
I have converted the data into BIDS format but there are some warnings that come with the conversion I have performed. I did this conversion using the convert to BIDS script.
To validate that the data was in BIDS format I needed to run BIDS_validation

General Process I took
1. make sure in linux environment, I used conda and I did wsl as 2 different options
2. Make sure freesurfer installed in the environment
3. ensure the dependencies are installed in environment: tcsh libgomp1 libjpeg62 libxext6 libxmu6 libxt6 libsm6 libxrender1 libfontconfig1
4. extract freesurfer from whatever directory you have it in, ensure it's included in your profile or bashrc
     I did it the following way:

   tar -xzvf freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz -C ~/

   export FREESURFER_HOME=~/freesurfer
   source $FREESURFER_HOME/SetUpFreeSurfer.sh
   export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
   export DISPLAY=$(grep nameserver /etc/resolv.conf | awk '{print $2}'):0.0
   export LIBGL_ALWAYS_INDIRECT=1

5. verify freesurfer installed by running: recon-all --version
6. run freesurfer for subject file of your choosing, ensuring you in the right directory: recon-all -i /mnt/c/Users/monka/Downloads/BIDS_FINAL/sub-0028224/anat/sub-0028224_T1w.nii.gz -s 0028224 -all   (//MODIFY THIS FOR YOUR DIRECTORY YOU IN\\)


Where my issues occured using local: could not run freesurfer, kept saying cores dumped. 


Option 2: Using Docker

1. Download docker
2. run this in command line but modify it for you to insert data: docker run -ti --rm -e DISPLAY=host.docker.internal:0.0 -v /mnt/c/Users/monka/Downloads/BIDS_FINAL:/data freesurfer/freesurfer:6.0 recon-all -i /data/sub-0028224/anat/sub-0028224_T1w.nii.gz -s 0028224 -all

3. make sure you have a container running now

where my issue occured was not getting freesurfer to run but to get my data into the enivronment running within docker. It never recognized it or imported all my data



