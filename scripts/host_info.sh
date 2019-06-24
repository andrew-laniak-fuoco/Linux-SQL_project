#!/bin/bash 

# declare variables

psql_host=$1
port=$2
db_name=$3
user_name=$4
password=$5

data=`lscpu`

hname=`hostname -f` 

cpu_number=`echo "$data" | awk '/^CPU\(s\)/{print $2}'`

cpu_arch=`echo "$data" | awk '/Architecture/{print $2}'`

modelName=`echo "$data" | awk '/^Model name/'`
cpu_model=${modelName:12}

cpu_mhz=`echo "$data" | awk '/^CPU M/{print $3}'`

L2_cache=`echo "$data" | awk '/^L2/{print $3}'`
L2_cache=${L2_cache%K}

total_memory=`free | awk '/^Mem/{print $2}'`

timestamp=`date -I'seconds'`
timestamp=${timestamp/T/ }
timestamp=${timestamp%+*}


insert_stmt=$(cat <<-END
INSERT INTO host_info (id,hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,l2_cache,"timestamp",total_mem)
VALUES(1,'$hname',$cpu_number,'$cpu_arch','$cpu_model',$cpu_mhz,$L2_cache,'$timestamp',$total_memory);
END
)
echo "$insert_stmt"

export PGPASSWORD=$password
psql -h $psql_host -p $port -U $user_name -d $db_name -c "$insert_stmt"
sleep 1

exit 0
