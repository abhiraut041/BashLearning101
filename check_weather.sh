#!/usr/bin/env bash

### Constant Bash Variable declarations
declare -r text_green="$(tput setaf 2)$(tput bold)"
declare -r text_blue="$(tput setaf 4)$(tput bold)"
declare -r text_cyan="$(tput setaf 6)$(tput bold)"
declare -r text_red="$(tput setaf 1)$(tput bold)"
declare -r text_reset="$(tput sgr0)"
declare -r line="${text_blue}############################################${text_reset}"
declare -r SCRIPT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
### temp file to store/process results of geocode api for latitude/longitude
declare -r GEOCODE_JSON_FILE="${SCRIPT_DIR}/.geocode_temp.json"


### URLs for API calls
declare -r geocode_url='https://geocoding-api.open-meteo.com/v1/search'
declare -r weatherapi_url='https://api.open-meteo.com/v1/forecast'

### Print Program Name
echo -e "${line}\n\t\t${text_green}Weather Check${text_reset}\n${line}"

### Get user input for city name
read -p 'Please enter city name : ' city_name
echo -e "${line}"

### Get latitude and longitude of city using gecoding api
### 'name' is city name and 'count' is number of output that can be returned by api
echo -e "Fetching data...\n${line}"
curl "${geocode_url}" -G --data-urlencode "name=${city_name}" --data-urlencode 'count=1' --data-urlencode 'language=en' --data-urlencode 'format=json' -o "${GEOCODE_JSON_FILE}" -s

### get the no. of records returned by api call
result_count="$( cat "${GEOCODE_JSON_FILE}" | jq '.results | length' )"

### check if city found and exit if not found
if [[ "${result_count}" == 0 ]] then
    echo "${text_red}ERROR : City not found on Planet Earth..!${text_reset}"
    echo "${line}"
    exit 1
fi

### proceed with execution if city found
echo -e "City Located...\n${line}"
### get the data in variables
latitude="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.latitude' )"
longitude="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.longitude' )"
elevation="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.elevation' )"
city_state="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.admin1' )"
country="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.country' )"
population="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.population' )"

### display the output
echo -e "\tCity \t\t: ${text_cyan}${city_name}${text_reset}"
echo -e "\tState \t\t: ${text_cyan}${city_state}${text_reset}"
echo -e "\tCountry \t: ${text_cyan}${country}${text_reset}"
echo -e "\tLongitude \t: ${text_cyan}${longitude}${text_reset}"
echo -e "\tLatitude \t: ${text_cyan}${latitude}${text_reset}"
echo -e "\tElevation \t: ${text_cyan}${elevation}${text_reset}"
echo -e "\tPopulation \t: ${text_cyan}${population}${text_reset}"




### Cleanup Section
### remove the temp file created during execution
# rm "${SCRIPT_DIR}/.geocode_temp.json"



#curl 'https://geocoding-api.open-meteo.com/v1/search?name=Mumbai&count=1&language=en&format=json' | jq

#cat sample_geocode.json | jq '.results[]' | jq '.name, .admin1, .country, .latitude, .longitude, .population, .elevation ' 


#https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature
