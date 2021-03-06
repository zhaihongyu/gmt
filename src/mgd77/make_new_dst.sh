#!/usr/bin/env bash
#
# Creates a new Dst_.xxx coefficient file from "Est_Ist_index_0_mean.pli" that leaves at
# ftp://ftp.ngdc.noaa.gov/STP/GEOMAGNETIC_DATA/INDICES/EST_IST/
# Use the output of this script to update the Dst_all.wdc file
#
# HOWEVER, the information a that site is quite confuse (to me). According to the README in
# ftp://ftp.ngdc.noaa.gov/STP/GEOMAGNETIC_DATA/INDICES/EST_IST/README.txt
#
# "The files with the extensions .pli use the preliminary DST index and should
#  extend until the present day, while the .lis files extend only to the last
#  day for which the definitive DST is available."
#
# But the data from those files (which this script reformats) does not always agrees with the,
# supposedly equal, files in
# ftp://ftp.ngdc.noaa.gov/STP/GEOMAGNETIC_DATA/INDICES/DST/
# So, at time of this writing, the DST_all.wdc distributed by us was generated by 'cating' all
# dst*.txt + Q-LOOK_20??.txt files
#
# That is, the output of this script is NOT what we currently distribute but we keep it foreseeing
# an eventual future (re)use.
#
#
# Joaquim Luis

# Name of file with all files in

# Name of the index file with definitive DSTs
fname1=Est_Ist_index_0_mean.lis

# Name of the index file with definitive plus preliminary DSTs
fname2=Est_Ist_index_0_mean.pli

# Definitive
gmt gmtconvert $fname1 -fi0t --TIME_SYSTEM="days since 2000-01-01" -fo0T --FORMAT_DATE_OUT=yyyy-mm-dd \
--FORMAT_CLOCK_OUT=hh | awk -v som=0 '{if (NR % 24 == 0) printf("%4.3d%+04.0f\n", $2, (som+=$2)/24, som=0); \
else if (NR % 24 == 1) printf("DST%02d%02dP%02d       000%4.3d", substr($1,3,2), substr($1,6,2), substr($1,9,2), $2, som+=$2); \
else printf("%4.3d", $2, som+=$2) }' > Dst_lis.dat

# Preliminary
gmt gmtconvert $fname2 -fi0t --TIME_SYSTEM="days since 2000-01-01" -fo0T --FORMAT_DATE_OUT=yyyy-mm-dd \
--FORMAT_CLOCK_OUT=hh | awk -v som=0 '{if (NR % 24 == 0) printf("%4.3d%+04.0f\n", $2, (som+=$2)/24, som=0); \
else if (NR % 24 == 1) printf("DST%02d%02dQ%02d       000%4.3d", substr($1,3,2), substr($1,6,2), substr($1,9,2), $2, som+=$2); \
else printf("%4.3d", $2, som+=$2) }' > Dst_pli.dat

# Count number of definitive values
nl=$(wc -l Dst_lis.dat | awk '{print $1 + 1}')

cat Dst_lis.dat > Dst_all.wdc
# Complement the file with the still preliminary DSTs
tail -n +$nl Dst_pli.dat >> Dst_all.wdc
