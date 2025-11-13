#!/usr/bin/env bash

### Constant Bash Variable declarations
declare -r text_green="$(tput setaf 2)$(tput bold)"
declare -r text_blue="$(tput setaf 4)$(tput bold)"
declare -r text_cyan="$(tput setaf 6)$(tput bold)"
declare -r text_red="$(tput setaf 1)$(tput bold)"
declare -r text_reset="$(tput sgr0)"
declare -r line="${text_blue}############################################${text_reset}"
declare -r SCRIPT_DIR="$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
declare -r tm=0.5
### temp file to store/process results api calls
declare -r GEOCODE_JSON_FILE="${SCRIPT_DIR}/.geocode_temp.json"
declare -r WEATHER_JSON_FILE="${SCRIPT_DIR}/.weather_temp.json"


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
echo -e "\t\t${text_blue}City Details${text_reset}\n${line}"
### get the data in variables
cname="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.name' | tr -d '"' )" 
latitude="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.latitude' )"
longitude="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.longitude' )"
elevation="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.elevation' )"
city_state="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.admin1' | tr -d '"' )"
country="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.country' | tr -d '"' )"
population="$( cat "${GEOCODE_JSON_FILE}" | jq '.results[]' | jq '.population' )"

### display the output
echo -e "\tCity \t\t: ${text_cyan}${cname}${text_reset}"
echo -e "\tState \t\t: ${text_cyan}${city_state}${text_reset}"
echo -e "\tCountry \t: ${text_cyan}${country}${text_reset}"
echo -e "\tLongitude \t: ${text_cyan}${longitude}${text_reset}"
echo -e "\tLatitude \t: ${text_cyan}${latitude}${text_reset}"
echo -e "\tElevation \t: ${text_cyan}${elevation} m.${text_reset}"
echo -e "\tPopulation \t: ${text_cyan}${population}${text_reset}"
echo "${line}"

### Now use the latitude and longitude to fetch weather
echo -e "\t\t${text_blue}Current Weather${text_reset}\n${line}"
curl "${weatherapi_url}" -G --data-urlencode "latitude=${latitude}" --data-urlencode "longitude=${longitude}" --data-urlencode 'current=temperature_2m,rain,snowfall,wind_speed_10m,relative_humidity_2m' -o "${WEATHER_JSON_FILE}" -s


### collect the data
temp_unit="$( cat "${WEATHER_JSON_FILE}" | jq '.current_units.temperature_2m' | tr -d '"' )"
rain_unit="$( cat "${WEATHER_JSON_FILE}" | jq '.current_units.rain' | tr -d '"' )"
snowfall_unit="$( cat "${WEATHER_JSON_FILE}" | jq '.current_units.snowfall' | tr -d '"' )"
wind_speed_unit="$( cat "${WEATHER_JSON_FILE}" | jq '.current_units.wind_speed_10m' | tr -d '"' )"
humidity_unit="$( cat "${WEATHER_JSON_FILE}" | jq '.current_units.relative_humidity_2m' | tr -d '"' )"

temp_val="$( cat "${WEATHER_JSON_FILE}" | jq '.current.temperature_2m' )"
rain_val="$( cat "${WEATHER_JSON_FILE}" | jq '.current.rain' )"
snowfall_val="$( cat "${WEATHER_JSON_FILE}" | jq '.current.snowfall' )"
wind_speed_val="$( cat "${WEATHER_JSON_FILE}" | jq '.current.wind_speed_10m' )"
humidity_val="$( cat "${WEATHER_JSON_FILE}" | jq '.current.relative_humidity_2m' )"


### print the output
echo -e "\tTemperature\t: ${text_cyan}${temp_val} ${temp_unit}${text_reset}"
echo -e "\tRainfall\t: ${text_cyan}${rain_val} ${rain_unit}${text_reset}"
echo -e "\tSnowfall\t: ${text_cyan}${snowfall_val} ${snowfall_unit}${text_reset}"
echo -e "\tWind Speed\t: ${text_cyan}${wind_speed_val} ${wind_speed_unit}${text_reset}"
echo -e "\tHumidity\t: ${text_cyan}${humidity_val} ${humidity_unit}${text_reset}"

echo -e "${line}\n\t\t${text_green}Good Day :)${text_reset}\n${line}"


### Cleanup Section : remove the api temp files
rm "${GEOCODE_JSON_FILE}" "${WEATHER_JSON_FILE}"

exit 0
