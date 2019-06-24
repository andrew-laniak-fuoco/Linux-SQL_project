#!/bin/bash 

# declare variables

psql_host=$1
port=$2
db_name=$3
user_name=$4
password=$5

coredata=`vmstat -t -S M | tail -n 1`
diskdata=`vmstat -d`
filedata=`df -BM`

timestamp=`echo "$coredata" | awk '//{print $18 " " $19}'`

host_id=1

memory_free=`echo "$coredata" | awk '//{print $4}'`

cpu_idel=`echo "$coredata" | awk '//{print $15}'`

cpu_kernel=`echo "$coredata" | awk '//{print $14}'`

typeset -i in=`echo "$coredata" | awk '//{print $9}'`
typeset -i out=`echo "$coredata" | awk '//{print $10}'`
typeset -i disk_io=in+out

disk_available=`echo "$filedata" | awk '/\/$/{print $2}'`
disk_available=${disk_available%M}


#echo -e 'time\t' $timestamp
#echo -e 'host_id\t' $host_id
#echo -e 'mFree\t' $memory_free
#echo -e 'idle\t' $cpu_idel
#echo -e 'kernel\t' $cpu_kernel
#echo -e 'io\t' $disk_io
#echo -e 'avail\t' $disk_available
#echo

insert_stmt=$(cat <<-END
INSERT INTO host_usage (timestamp,host_id,memory_free,cpu_idle,cpu_kernel,disk_io,disk_available)
VALUES('$timestamp',$host_id,$memory_free,$cpu_idel,$cpu_kernel,$disk_io,$disk_available);
END
)
echo $insert_stmt;

export PGPASSWORD=$password
psql -h $psql_host -p $port -U $user_name -d $db_name -c "$insert_stm"
sleep 1

exit 0
