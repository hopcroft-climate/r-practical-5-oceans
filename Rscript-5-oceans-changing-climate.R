#---
title: "R Notebook 5 - oceans and climate change"

# Peter Hopcroft
# 12.19, 09.20
#---

# This week we're going to plot ocean model outputs. Here is a script to work through that shows you how to do this. You can adapt this as you need for your own choice of policy scenario. Plots like these will then feed into your final coursework assignment.


# Load the ncdf4 library into R. (note, we installed this with install.packages() in Notebook 2)
#install.packages("ncdf4")
#install.packages("fields")
library("ncdf4")
library("fields")


# Set the working directory to where the data files are saved
setwd("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/") 
# This is the file path to where I have saved my data files on my computer. Your file path will be different. Either use Windows Explorer (Finder on a mac) to find the file path, or use the menu at the top of R studio to set the working directory instead. If you want to use the menu instead of this line of code, at the top of R studio click Session >  Set working directory > Choose directory, and navigate to the folder where the data files are saved. Finally, note windows users need to use two backslashes (i.e. \\) rather than a single forward slash. This is one of those differences between Windows and Mac/Linux.

# Open a file connection to the NetCDF file
ncfile <- nc_open("thetao_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")


#ncfile <- nc_open("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/thetao_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")

# Print the NetCDFs header
print(ncfile)

# Extract variables from the NetCDF file
lat = ncvar_get(ncfile, 'lat')
lon = ncvar_get(ncfile,'lon')
lev = ncvar_get(ncfile,'lev')
thetao = ncvar_get(ncfile, 'thetao')
# Close the NetCDF file connection
nc_close(ncfile)



#Let's plot the surface level:
library("fields")
image.plot(lon, lat, thetao[,,1,1])
#This won't work because the latitude is from 90 to -90, 
#which image.plot won't like so let's reverse things:
lat <-rev(lat)
thetao<-thetao[,ncol(thetao):1,,]
image.plot(lon, lat, thetao[,,1,1])
image.plot(lon, lat, thetao[,,20,1])

#So the first plot is surface ocean potential temperature. The second is level 20 from the surface - at approximatley ?
#
print(lev)
#... at approx. 325 m.

#Now let's think about plotting some cross-sections:
image.plot(lat, lev, thetao[1,,,1])

#Looks weird - it's upside down! Try again:
image(lat, lev, thetao[1,,,1],ylim = rev(range(lev)))



#What do you think - does this look as you'd expect?
#This is for longitude 0.5 degrees - i.e. close to Greenwhich meridian. Now let's try the middle of the Atlantic:

image.plot(lat, lev, thetao[151,,,1],ylim = rev(range(lev)))

#Now let's try loading in another simulation and calculating the difference. We will call this theatao_rcp85.
# We don't need to re-read in lat,lon,lev as they will be the same.
setwd("~/shared/data/ESM_simulations/rcp85/HadGEM2-ES/annual_means/") 
# Open a file connection to the NetCDF file
ncfile <- nc_open("thetao_HadGEM2-ES_rcp85_r1i1p1_ext2070-2099_mean_1deg_ann.nc")

# Print the NetCDFs header
print(ncfile)

# Extract variables from the NetCDF file
thetao_rcp85 = ncvar_get(ncfile, 'thetao')
# Close the NetCDF file connection
nc_close(ncfile)
# and remember to flip the co-ordinates like we did before:

thetao_rcp85<-thetao_rcp85[,ncol(thetao_rcp85):1,,]

image.plot(lat, lev, thetao_rcp85[151,,,1],ylim = rev(range(lev)))
# Now let's make a difference plot

del_thetao_rcp85_piControl<-thetao_rcp85 - thetao
image.plot(lat, lev, del_thetao_rcp85_piControl[151,,,1],ylim = rev(range(lev)))



#So now are looking at the future minus the pre-industrial.  What do you see and why does it look like it does?


#Let's improve this anomaly plot:

# Install the RColorBrewer package, to give us access to lots of extra colour paletts. Uncomment and run the line below the first time on a computer. 
# install.packages("RColorBrewer")
# Load the RColorBrewer into R with the library() function. 
library("RColorBrewer")
# The same plot and map commands as before, but with the prewer.pal(10,'RdBu) function, which gives us a Red to Blue color ramp with 10 levels. This is then enclosed with the rev() function, which reverses the order of the red-blue color ramp to give us a blue-red color ramp, which is more normal for Environmental sciences. 


image.plot(lat, lev, del_thetao_rcp85_piControl[151,,,1],ylim = rev(c(0,5000)),zlim=c(-5,5),main="ocean temperature",sub="RCP85-piControl", col = rev(brewer.pal(9, "RdBu")),asp=0.03)


# Now let's try looking at salinity in the same way:
setwd("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/") 
# Open a file connection to the NetCDF file

ncfile <- nc_open("so_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")
sal = ncvar_get(ncfile, 'so')
nc_close(ncfile)
setwd("~/shared/data/ESM_simulations/rcp85/HadGEM2-ES/annual_means/") 
ncfile <- nc_open("so_HadGEM2-ES_rcp85_r1i1p1_ext2070-2099_mean_1deg_ann.nc")
sal_rcp85 = ncvar_get(ncfile, 'so')
nc_close(ncfile)
sal<-sal[,ncol(sal):1,,]
sal_rcp85<-sal_rcp85[,ncol(sal_rcp85):1,,]
del_sal_rcp85_piControl<-sal_rcp85 - sal
image.plot(lat, lev, del_sal_rcp85_piControl[151,,,1],ylim = rev(range(lev)),zlim=c(-1.5,1.5),main="ocean salinity",sub="RCP85-piControl", col = rev(brewer.pal(9, "RdBu")),asp=0.03)


# What is this showing us about Atlantic salinity? Can you compare for the mid- Pacific?

#Hint: to work out which longitude you need type 
print(lon)

#Then change the first index (the first nubmer in the square brackets) in the image.plot command.


Now lets try some other variables. We have surface ocean pH and surface ocean oxygen (O2).
Lets load those files up for the piControl and take a look at pH
(WHat is pH?->  https://en.wikipedia.org/wiki/PH)

# Open a file connection to the NetCDF file
#ncfile <- nc_open("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/ph_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")
setwd("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/") 
ncfile <- nc_open("ph_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")
ph = ncvar_get(ncfile, 'ph')
nc_close(ncfile)
setwd("~/shared/data/ESM_simulations/rcp85/HadGEM2-ES/annual_means/") 
ncfile <- nc_open("ph_HadGEM2-ES_rcp85_r1i1p1_ext2070-2099_mean_1deg_ann.nc")
ph_rcp85 = ncvar_get(ncfile, 'ph')
nc_close(ncfile)
ph<-ph[,ncol(ph):1,]
ph_rcp85<-ph_rcp85[,ncol(ph_rcp85):1,]
del_ph_rcp85_piControl<-ph_rcp85[,,] - ph[,,]
image.plot(lon, lat, del_ph_rcp85_piControl[,,1],main="ocean ph",sub="RCP85-piControl", col = rev(brewer.pal(9, "RdBu")),zlim=c(-0.5,0.5))

#What does this plot tell us about surface ocean pH in a 'businees-as-usual' future?

#Now let's repeat for O2:

# Open a file connection to the NetCDF file
#ncfile <- nc_open("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/o2_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")
setwd("~/shared/data/ESM_simulations/piControl/HadGEM2-ES/annual_means/") 
ncfile <- nc_open("o2_HadGEM2-ES_piControl_r1i1p1_ext1850-1879_mean_1deg_ann.nc")
o2 = ncvar_get(ncfile, 'o2')
nc_close(ncfile)
setwd("~/shared/data/ESM_simulations/rcp85/HadGEM2-ES/annual_means/") 
ncfile <- nc_open("o2_HadGEM2-ES_rcp85_r1i1p1_ext2070-2099_mean_1deg_ann.nc")
o2_rcp85 = ncvar_get(ncfile, 'o2')
nc_close(ncfile)

o2<-o2[,ncol(o2):1,]
o2_rcp85<-o2_rcp85[,ncol(o2_rcp85):1,]

del_o2_rcp85_piControl<-o2_rcp85[,,] - o2[,,]
image.plot(lon, lat, del_o2_rcp85_piControl[,,1],main="ocean o2",sub="RCP85-piControl", col = rev(brewer.pal(9, "RdBu")))


#What does this plot tell us about surface ocean oxygen in a 'businees-as-usual' future?


#Congratulations you've reached the end of this part of the practical. Now you should go off and explore your policy scenario using some of the ideas and bits of code above.
