#!/bin/sh
usage="
Usage: <pid>
"
if [ $# -lt 1 ]; then
    echo "$usage"
    exit 1
fi
pid=$1
tmpfile=$(mktemp)
jstackfile=$tmpfile.j
outfile=$tmpfile.out
echo "cpu  | thread name"> $outfile
top -b -n 1 -H -p $pid | tail -n +8 | sed -r 's/^\s+//g' | awk '{print $1","$9}' > $tmpfile
jstack $pid > $jstackfile
for i in $(cat $tmpfile)
do
    tid=$(echo $i | cut -d , -f1)
    cpu=$(echo $i | cut -d , -f2)
    tid_hex=$(echo "obase=16; $tid" | bc)
    tname=$(grep -i "0x$tid_hex" $jstackfile | egrep -o '^".*"')
    printf '%-4s | %s\n' "$cpu" "$tname" >> $outfile
done
cat $outfile
rm ${tmpfile}*
