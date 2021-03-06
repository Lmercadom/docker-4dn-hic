#!/bin/bash
shopt -s extglob
min_res=5000
nres=13
custom_res=''  # custom resolutions, separated by commas
output_prefix=out
outdir=.

printHelpAndExit() {
    echo "Usage: ${0##*/} [-r min_res] [-l nres] [-g] [-u custom_res] [-d outdir] [-o out_prefix] -i input_mcool -c chromsize_file"
    echo "-i input_mcool : input file in multires cool format"
    echo "-c chromsize_file : chromsizes file"
    echo "-o out_prefix : default out"
    echo "-d outdir : default ."
    echo "-r min_res : default 5000 (this option is effective only when used with -g)"
    echo "-l nres : default 13 (this options is effective only when used with -g)"
    echo "-u : custom resolutions (separated by comman)"
    exit "$1"
}

while getopts "i:c:r:l:o:d:u:" opt; do
    case $opt in
        i) input_mcool=$OPTARG;;
        c) chromsizefile=$OPTARG;;
        r) min_res=$OPTARG;;
        l) nres=$OPTARG;;
        u) custom_res=$OPTARG;;
        o) output_prefix=$OPTARG;;
        d) outdir=$OPTARG;;
        h) printHelpAndExit 0;;
        [?]) printHelpAndExit 1;;
        esac
done


cp $input_mcool $outdir/$output_prefix.mcool
scriptdir=/usr/local/bin

if [[ ! -z $custom_res ]]
then
  res_list=$custom_res
  res_list_as_array=(${res_list//,/ })
  nres=${#res_list_as_array[@]}
elif [[ $higlass == '1' ]]
then
  res_list=$(python3 -c "from cooler.contrib import higlass; higlass.print_zoom_resolutions('$chromsizefile', $min_res)")
fi

python3 $scriptdir/mcool2hic/get_bins_from_mcool.py -i $outdir/$output_prefix.mcool -o $outdir/$output_prefix.mcool.bins -u $res_list
$scriptdir/mcool2hic/convert_mcoolbins_to_juicer_format.pl $outdir/$output_prefix.mcool.bins $res_list $outdir/$output_prefix.mcool.normvector.juicerformat
cd $outdir
gzip $output_prefix.mcool.normvector.juicerformat

