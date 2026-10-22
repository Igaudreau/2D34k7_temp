#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=32000M
#SBATCH --time=0-01:00
#SBATCH --account=def-bmaxwell
#SBATCH --output=postout
if [ "$BASH_VERSION" = '' ]; then
  . ./_math             # Allows simple arithmatic in bash/dash
else
  source ./_math                # Allows simple arithmatic in bash/dash
fi

mkdir png
rm sootfoil_partial.png
rm sootfoil_partial.ps
rm sootfoil_full.png
rm sootfoil_full.ps
rm sootfoil.xq

TMP=`grep 'LOOP_END=' runsim.sh | awk -F '[=  ]' -v pat="$pattern" '{print $2}' | awk -F ' ' -v pat="$pattern" '{print $1}'`
LOOP_END=$(float_eval "$TMP + 1")
python3 sootfoil.py --l $LOOP_END


mg_torch <<- EOF
	paper 10.0 4.0
	open d ps_rgb
	nocontour
	! qr 1.0e24 1.8e24
	! Custom XL and XR limits
	xr 0 3.0e7
	readxq sootfoil
	close d
	! open b ps_rgb
	! nocontour
	! qr 130000 600000
	! xr -1e6 5e7 readxq sootfoil
	! close b
	q
	EOF


plot d sootfoil_full
gs -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r300x300 -o ./png/tmp.png sootfoil_full.ps
convert ./png/tmp.png -flatten -geometry 100% -trim +repage ./sootfoil_full.png
rm ./png/tmp.png
rm d.ps

# sootfoil
#plot b sootfoil_partial
#gs -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -#sDEVICE=pngalpha -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -r300x300 -o ./png/tmp.png sootfoil_partial.ps
#convert ./png/tmp.png -flatten -geometry 100% -trim +repage ./sootfoil_partial.png
#rm ./png/tmp.png
#rm b.ps


# Crop partial soot foil and perform autocorrelation
# Scale is 5.08 pixels per mm (determined manually)
#convert sootfoil_partial.png -crop 1528x508+175+284 +repage sootfoil-cropped.png
# Fast algorithm of autocorrelation method
# python3 autocorr_fast.py
# python3 maximums.py
# Plot the results
# gnuplot autocorr.plt

