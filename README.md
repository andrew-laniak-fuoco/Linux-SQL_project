## INTRODUCTION
Cluster Monitor Agent is a bash tool which records information about 
a cluster's resource usage.  It will record hardware information of
specific machines and periodically record data on CPU and disk usage.

## ARCHITECTURE AND DESIGN
![](https://lh3.googleusercontent.com/_BW4ZtT8AIaXFeh8gN8IpZDdh8O54aj9eS-TNBjYb1msKInpLAtOO1F8aKeceeMbD9vN1wY0lg0 "Bash script architecture")
### Database Tables
**PUBLIC.host_info**
Each record contains hardware information about a single machine

**PUBLIC.host_usage**
Holds periodic information about resource usage.  Each 
record holds a host id which is used as a foreign key to host_info.

### Scripts
**host_info.sh**
Obtains data from the current machine and inserts the values
into the PUBLIC.host_info table.

**host_usage.sh**
Obtains resource information from the current machine and 
inserts the values into the PUBLIC.host_usage table.

**init.sql** Runs the DDl commands which defines the schema and generates the tables.

## USAGE
### Initalization
To start, make sure you have a connection to a Postgres instance.  One can use
the following command to connect, replacing anything in brackets with user
defined values:
`psql -h [hostname] -U [username] -W`

Once connected, the following command can be used to set up the database:
CREATE DATABASE [dbname];

The user should then run the DDL commands from the init.sql file.  From a
terminal, a user can send commands via a file to psql with the -f command:
`psql -h [hostname] -U [username] -W [dbname] -f init.sql`

The database with the schema and tables is now defined under the name [dbname]

### Script usage
`./host_info.sh [hostname] [portnumber] [dbname] [username] [password]`

`./host_usage.sh [hostname] [portnumber] [dbname] [username] [password]`

### Crontab setup
In order to have the host_usage.sh script operate as intended, the user needs
to have the script run periodically (ideally once a minute).  One can do this
through the use of Crontab.  Input the following command into the Crontab
editor:

`* * * * * bash [path to /host_usage.sh] [hostname] [portnumber] [dbname] [username] [password] > /tmp/host_usage.log`

This command will run the script every minute and record the stdout to a log
file.  The stdout will include the generated SQL INSERT statements.  Keep in
mind the log files will be held on the local machine and not the database.

## IMPROVEMENTS
In the next version we are looking to improve in the following areas:

**1** More details on disk IO (get separate information on reads and writes)

**2** Adjust timestamps to fit to a universal time zone, and record time zones

**3** Measure available disk space in more areas than just the root directory
