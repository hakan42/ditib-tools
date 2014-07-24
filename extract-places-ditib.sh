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

    FILE=${TMPDIR}/${source}-${country}-${page}.html

    mkdir -p ${STORAGE}/${source}-${country}/${MONTH}/${DAY}

    cp -f \
	${FILE} \
	${STORAGE}/${source}-${country}/${MONTH}/${DAY}/${source}-${country}-page-${page}.html

    cp -f \
	${FILE} \
	${WEBDATA}/${source}-${country}-page-${page}.html
}


country=${COUNTRY}
source=${SOURCE}
for page in $(seq 1 8)
do
    :
    mkdir -p ${TMPDIR}
    cd ${TMPDIR}

    FILE=${TMPDIR}/${source}-${country}-${page}.html

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
for county in ${PAGES}
do
    :
    # curl \
    # http://localhost:8888/osm-mosques-rest/osm/import \
    # -o ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.data.txt \
    # > ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.out \
    # 2> ${STORAGE}/${country}-${county}/${MONTH}/${DAY}/curl.err
done