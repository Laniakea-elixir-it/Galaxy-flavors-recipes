#!/bin/sh
#--------USAGE----------------------------------------------------------------------------------------------

usage() {

echo  "write db for Galaxy laniakea package version control"
echo  
echo  "Syntax: parameters [-g <GALAXY_RELEASE>|-f<FLAVOR_NAME>|"
echo  "-v <FLAVOR_VERSION>|-d <DB_FILE_PATH>|-i <IMAGE_VERSION>|-h]"
echo  "options:"
echo  "-g    set package galaxy release"
echo  "-f    set flavor name"
echo  "-d    set database file path"
echo  "-i    set image version"
echo  "-c    set command to execute (create|show|print_db)"
echo  "-c    set command to execute (create|show|print_db)"
echo  "-h    print help"
exit 1


}

#--------PARSER----------------------------------------------------------------------------------------------

while getopts "g:f:i:d:c:h" o; do
    case "${o}" in

        g) #set galaxy release
            G=${OPTARG}
            ;;
        f) #set flavor name
            F=${OPTARG}
            ;;
        d) #set database file
            D=${OPTARG}
            ;;
        i) #set image version
            I=${OPTARG}
            ;;
        c) #set command to execute version
            C=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

parsing(){
if [ -z ${G+x} ] || [ -z ${F+x} ] || [ -z ${V+x} ] || [ -z ${K+x} ] ; then
	 if [ -z ${C+x} ]||[ -z ${D+x} ]; then
		 usage
	 fi
fi
}


latest_version(){
latest_package_version=$(sqlite3 $D "select max(version) from flavor_packages where galaxy_version='$G' and flavor_name='$F' and image_version='$I';")
}

add_version(){
new_version=$(($latest_package_version + 1))
sqlite3 $D "insert into flavor_packages (image_version, galaxy_version, flavor_name, version) values ('$I','$G','$F','$new_version');"
}
print_db(){
        sqlite3 $D "select * from flavor_packages;"
}

main(){

	parsing

case $C in

  show)
		latest_version
    echo $latest_package_version 
		;;

  create)
    sqlite3 $D 'create table if not exists flavor_packages (image_version TEXT,galaxy_version TEXT,flavor_name TEXT,version INTEGER);'
		latest_version
		add_version
    ;;
  print_db)
		print_db
    ;;
  *)
		echo "wrong command, the possible -c options are ( show | create )"
    ;;
esac

}

main

