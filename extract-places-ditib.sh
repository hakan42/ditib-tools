#! /bin/sh

OSMOSIS=${HOME}/osmosis-0.43.1
STORAGE=${HOME}/Dropbox/osmdata
TMPDIR=${HOME}/tmp/osm-place-ditib
WEBDATA=/home/tomcat/osm-mosques/data

COUNTRY=germany

SOURCE=ditib

extract_data() {

    country=${COUNTRY}
    county=${SOURCE}

    page=$1

    FILE=${TMPDIR}/${country}-${source}-${page}.html

    mkdir -p ${STORAGE}/${country}-${source}/${MONTH}/${DAY}

    cp -f \
	${FILE} \
	${STORAGE}/${country}-${source}/${MONTH}/${DAY}/${country}-${source}-page-${page}.html

    cp -f \
	${FILE} \
	${WEBDATA}/${country}-${source}-page-${page}.html
}


country=${COUNTRY}
source=${SOURCE}
for page in $(seq 1 8)
do
    :
    mkdir -p ${TMPDIR}
    cd ${TMPDIR}

    FILE=${TMPDIR}/${country}-${source}-${page}.html

    rm -f ${FILE}

    wget "http://www.ditib.de/default.php?pageNum_kat="${page}"&id=12&lang=de&12" -O ${FILE} \
	> ${FILE}.out 2> ${FILE}.err

    if [ -a ${FILE} ] 
    then
	if [ -s ${FILE} ]
	then
	    MONTH=$(date +%Y%m --reference ${FILE})
	    DAY=$(date +%Y%m%d --reference ${FILE})

	    extract_data ${page}
	fi
    fi

    find ${STORAGE}/${country} -type f -a -mtime +14 | xargs --no-run-if-empty rm
    find ${STORAGE}/${country} -type d -a -empty | xargs --no-run-if-empty rmdir
done

# TODO grep in property file to obtain username / password for webapp
country=${COUNTRY}
for country in germany
do
    :

    mkdir -p ${STORAGE}/${country}/${MONTH}/${DAY}

    curl \
	"http://localhost:8888/osm-mosques/rest/ditib/import" \
	-o ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-import.txt \
	> ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-import.out \
	2> ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-import.err

    curl \
	"http://localhost:8888/osm-mosques/rest/ditibPlace?size=999&sort=name" \
	-o ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-data.txt \
	> ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-data.out \
	2> ${STORAGE}/${country}/${MONTH}/${DAY}/curl-ditib-places-data.err

    # cp -ar ${WEBDATA}/${country}-${source}-split-* ${STORAGE}/${country}-${source}/${MONTH}/${DAY}
done

db=osm_mosques

DB_DIR=${STORAGE}/database/${MONTH}/${DAY}

mkdir -p ${DB_DIR}

mysql -uroot -p$(cat ${HOME}/.my.pass) ${db} \
    -e "update ditib_places set lat = 46.42, lon = 6.55 where lat = 0 and lon = 0;" \
    > ${DB_DIR}/${db}-mosques-in-lac-leman.sql

mysqldump -uroot -p$(cat ${HOME}/.my.pass) --skip-extended-insert ${db} \
    > ${DB_DIR}/${db}-dump.sql

mysql -uroot -p$(cat ${HOME}/.my.pass) ${db} \
    -e "select d_key, lat, lon, geocoded, addr_postcode, addr_city, addr_street, addr_housenumber, addr_state, phone, fax from ditib_places order by d_key, name limit 9999;" \
    > ${DB_DIR}/${db}-ditib_places.sql
