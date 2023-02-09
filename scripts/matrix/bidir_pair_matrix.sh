## ====================================================== ##
##### raw read count matrix for bi directional pairs 
##### minus strand read counts + plus strand read counts
## ====================================================== ##

# TNE pairs 
awk 'OFS="\t" {
$2 == "+"?strand_1="plus":strand_1="minus";
$4 == "+"?strand_2="plus":strand_2="minus";
print $1"_"strand_1"_"$3"_"strand_2
}' scripts/peaks/bidirectional/pairs/bidirectional_pairs.txt > bidir_pairs.txt
## there are 372 pairs total 

## for testing purposes 
head -n 1 eRNA.merged.readCounts.v2.xls > eRNA.bidirectional_pairs.readCounts.xls

cat bidirectional_pairs/bidirectional_pairs_all.txt| sed 's/+/plus/g; s/-/minus/g' | 
while read TNE1 TNE1_strand TNE2 TNE2_strand dist 
do 
  TNE1+="_"$TNE1_strand # plus strand
  TNE2+="_"$TNE2_strand # minus strand
  combined=$TNE1"_"$TNE2
  
  TNE2_vals=$(grep -F $TNE2 eRNA.merged.readCounts.v2.xls)
  IFS=$'\t' read -r -a array_minus <<< "$TNE2_vals"
  
  TNE1_vals=$(grep -F $TNE1 eRNA.merged.readCounts.v2.xls)
  IFS=$'\t' read -r -a array_plus <<< "$TNE1_vals"
  
  # gets the length of array 
  # TNE1_vals and TNE2_vals should be of equal length! 
  # aka array_minus and array_plus
  len=${#array_plus[@]}
  echo "${#array_plus[@]}"
  
  for ((i=1; i <$len; i++));do c+=(`expr ${array_plus[$i]} + ${array_minus[$i]}`);done
  
  (
    IFS=$'\t'
    echo -e "$combined\t${c[*]}"
  ) >> eRNA.bidirectional_pairs.readCounts.xls
done 



### double checking to make sure the column names are the same for plus and minus eRNA files 
### run on erisone 
### /data/bioinformatics/projects/donglab/AMPPD_eRNA/inputs

plus=$(awk 'NR==1' minus/eRNA.minus.readCounts.xls) 
minus=$(awk 'NR==1' plus/eRNA.plus.readCounts.xls) 

if [[ $plus == $minus ]]; then 
echo "the same"
fi


sed 's/+/plus/g; s/-/minus/g' scripts/peaks/bidirectional/pairs/bidirectional_pairs_all.txt | 
while read TNE1 TNE1_strand TNE2 TNE2_strand dist 
do 
  TNE1+="_"$TNE1_strand # plus strand
  TNE2+="_"$TNE2_strand # minus strand
  combined=$TNE1"_"$TNE2
  
  grep $TNE1 eRNA.minus.readCounts.xls 
done 

## checking why the number of rows for 
## bidirectional_pairs_all.txt and eRNA.bidirectiona_pairs.readCounts.xls
## is different 
awk 'OFS="\t" {print $1"_plus_"$3"_minus"}' bidirectional_pairs_all.txt

grep -v <(awk '{print $1"_plus_"$3"_minus"}' bidirectional_pairs/bidirectional_pairs_all.txt) eRNA.bidirectional_pairs.readCounts.xls | wc -l 

head eRNA.bidirectional_pairs.readCounts.xls | cut -f 1 | sort 

sed '1d' eRNA.bidirectional_pairs.readCounts.xls | cut -f 1 | sort 
