#!/usr/bin/env bash

# MiniProject : Image Processing Script to generate thumbnails
# 
# Req1 : It should check, if thumbnail already exists. If exists then skip generating new thumbnail.
# Req2 : It should check, if we need to generate a thumbnail, meaning if widht/height of img is > 100px. If not then skip generating thumbnail.
# Req3 : Do no create a thumbnail of a thumbnail file.

### Formatting constants
declare -r t_green="$(tput setaf 2)$(tput bold)"
declare -r t_yellow="$(tput setaf 3)$(tput bold)"
declare -r t_red="$(tput setaf 1)$(tput bold)"
declare -r t_blue="$(tput setaf 4)$(tput bold)"
declare -r t_cyan="$(tput setaf 6)$(tput bold)"
declare -r t_reset="$(tput sgr0)"
declare -r line_break="============================================================"
declare -r green_line="\t${t_yellow}=> ${t_green}@@@${t_reset}"
declare -r blue_line="\t${t_yellow}=> ${t_blue}@@@${t_reset}"
declare -r red_line="\t${t_yellow}=> ${t_red}@@@${t_reset}"
declare -r blue_line="\t${t_yellow}=> ${t_blue}@@@${t_reset}"


### IMP Constants
declare -r SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" && pwd )"
declare -r IMG_DIR="${SCRIPT_DIR}/images/"
declare -r TMBNL_TEXT="thumbnail"
declare -r TMBNL_EXT="jpg"
declare -ri TMBNL_WIDTH=100
declare -ri TMBNL_HEIGHT=100

### Show Header
echo -e "\t######################################"
echo -e "\t##                                  ##"
echo -e "\t##     ${t_cyan}Thumbnail Generator Pro.${t_reset}     ##"
echo -e "\t##                                  ##"
echo -e "\t######################################\n"

### Check if IMG dir exists or not
if [[ ! -e "${IMG_DIR}" ]]; then
	echo "Image Directory Not Found [${IMG_DIR}]. Exiting..."
fi

### all operations will be performed in IMG_DIR, so changing dir
cd "${IMG_DIR}"

### Enable nullglob, so if file is not found then *.extension is not listed
shopt -s nullglob

### Use a for loop to check all files and perform image processing
for file in *.{jpg,jpeg,png}; do
	
	### All the magic will happen here

	echo "${t_yellow}Processing file : [ ${file} ]${t_reset}"
	
	## Get the basic details of the file
	fname="${file%.*}"
	extension="${file##*.}"

	## Check : if the file is a valid image file
	if identify "${file}" > /dev/null 2>&1; then
		echo -e "${blue_line/@@@/'This is a valid image file.'}"
	else
		echo -e "${red_line/@@@/'Not a valid image. Cannot be processed. Skipping...'}"
		echo "${line_break}"
		continue
	fi

	## Check : if the file is thumbnail or normal image
	if [[ "${fname}" == *'.'* ]] && [[ ${fname##*.} == "${TMBNL_TEXT}" ]]; then
		echo -e "${green_line/@@@/'This is a thumbnail. No processing needed.'}"
		echo "${line_break}"
		continue
	fi


	## Check : if already a thumbnail for that file is created, do not create a new thumbnail
	tmbnl_file="${fname}.${TMBNL_TEXT}.${TMBNL_EXT}"
	if [[ -f "${tmbnl_file}" ]]; then
		echo -e "${green_line/@@@/"Thumbnail [ ${tmbnl_file} ] already present!"}"
		echo "${line_break}"
		continue
	else
		echo -e "${blue_line/@@@/'Thumbnail not present for this image.'}"
	fi

	## Check : if the file is greater than 100x100
	img_width="$( identify -format '%w' "${file}" )"
	img_height="$( identify -format '%h' "${file}"  )"
	
	if [[ "${img_width}" -le "${TMBNL_WIDTH}" || "${img_height}" -le "${TMBNL_HEIGHT}" ]]; then
		echo -e "${green_line/@@@/"Thumnail not needed as image is below ${TMBNL_WIDTH}x${TMBNL_HEIGHT}."}"
		echo -e "${line_break}"
		continue
	fi

	## Task : if all checks passed then create thumbnail
	echo -e "${blue_line/@@@/'Creating Thumbnail...'}"
	dimensions="${TMBNL_WIDTH}x${TMBNL_HEIGHT}"
	output_file="${fname}.${TMBNL_TEXT}.${TMBNL_EXT}"
	
	convert "${file}" -resize "${dimensions}" "${output_file}"
	
	## Task : after completion show success or error msg or already exist or is thumbnail message
	if [[ $? -eq 0 ]]; then
		echo -e "${green_line/@@@/"Thumbnail [ ${output_file} ] generated successfully!"}"
	else
		echo -e "${red_line/@@@/"Thumbnail creation failed! Please check..."}"
	fi
		
	echo "${line_break}"

done

### Disable nullglob
shopt -u nullglob

exit 0
