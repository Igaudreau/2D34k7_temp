#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=1-00:00
#SBATCH --account=def-bmaxwell
#SBATCH --output=postout
if [ "$BASH_VERSION" = '' ]; then
  . ./_math		# Allows simple arithmatic in bash/dash
else
  source ./_math	# Allows simple arithmatic in bash/dash
fi

Frame=$1
NAME=$2
D_CJ=$3
DT=$4
DPI=400

source ./_math
# TIME=$(float_eval "$DT * $Frame")
# LOC=$(float_eval "$D_CJ * $TIME")
# XL=$(float_eval "$LOC - 100000") #Left boundry
# XR=$(float_eval "$LOC + 8000") #Right boundry

mg_torch <<- EOF
	paper 8.0 8.0
	read $NAME.$1
	! zoom in as needed
	xr $XL $XR
	! Limit size of file by only plotting coarser levs
	levs 0 5

	nogrey_rain
	open a$1 ps_rgb
	nocontour
	! qr 1.5e6 2.8e6
	plot rho p
	close a$1

	!nogrey_rain
	!open b$1 ps_rgb
	!nocontour
	! qr 2.8e9 3.8e9
	!plot te p
	!close b$1

	!nogrey_rain
	!open c$1 ps_rgb
	!nocontour
	! qr 1.0e24 1.3e24
	!plot pg p
	!close c$1
	
	q
	EOF

plot a$1 rho$1
#plot b$1 te$1
#plot c$1 pg$1

for var in rho ; do
  # 1. Render at 300 DPI (no need to go higher if the gaps are in the vector)
  gs -q -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT \
     -sDEVICE=pngalpha -r$DPI \
     -o ./png/tmp$1.png $var$1.ps
  # 2. Heal transparent lines by dilating the alpha channel (IM6 compatible)
  convert ./png/tmp$1.png \
      -channel A -morphology Dilate Square:1 +channel \
      -background white -flatten -trim +repage ./png/$var$1.png
  rm ./png/tmp$1.png
done

rm ./png/tmp$1.png
rm rho$1.ps
#rm te$1.ps
#rm pg$1.ps
rm a$1.ps
#rm b$1.ps
#rm c$1.ps

# process images
# Density
#plot a$1 rho$1
#gs -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r300x300 -o ./png/tmp$1.png rho$1.ps
#convert ./png/tmp$1.png -flatten -geometry 100% -trim +repage ./png/rho$1.png
#rm ./png/tmp$1.png

# Temperature
#plot b$1 te$1
#gs -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r300x300 -o ./png/tmp$1.png te$1.ps
#convert ./png/tmp$1.png -flatten -geometry 100% -trim +repage ./png/te$1.png


# Pressure
#plot d$1 pg$1
#gs -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r300x300 -o ./png/tmp$1.png pg$1.ps
#convert ./png/tmp$1.png -flatten -geometry 100% -trim +repage ./png/pg$1.png
#rm ./png/tmp$1.png


