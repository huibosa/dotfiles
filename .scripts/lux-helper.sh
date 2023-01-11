#!/usr/bin/env bash

declare -a longNameFiles
declare -a alreadyExistFiles
statusFileNameTooLong="file name too long"
statusFileAlreadyExist="file already exist"

handleFileAlreadyExist() {
  alreadyExistFiles+=("$1")
}

handleFileNameTooLong() {
  local url="$1"

  longNameFiles+="${url}"

  local tmp="${url##*/}" # discard http
  local filename="${tmp: -100:100}" # select last 240 byte as filaname

  lux -O "${filename}" "${url}" 2>&1
}

write2File() {
  printf "$s\n" "${longNameFiles}" >> file-name-too-long.txt
  printf "$s\n" "${alreadyExistFiles}" >> file-already-exist.txt

  sort file-name-too-long.txt | uniq > tmp1
  sort file-already-exist.txt | uniq > tmp2

  mv tmp1 file-name-too-long.txt
  mv tmp2 file-already-exist.txt
}

runLux() {
  local outputStr="$(lux "$1" 2>&1)"
  echo "${outputStr}"

  if [[ "${outputStr}" =~ "${statusFileNameTooLong}" ]]; then
    handleFileNameTooLong "$1"
  elif [[ "${outputStr}" =~ "${statusFileAlreadyExist}" ]]; then
    handleFileAlreadyExist "$1"
  fi
}

trap write2File SIGINT SIGTERM

if [[ "$1" =~ .*txt ]]; then
  readarray -t urls < "$1"

  for url in "${urls[@]}"; do
    runLux "$url"
  done

  exit
fi

runLux "$1"
