#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!]Saliendo...${endColour}\n"
  tput cnorm
  exit 1
}
#Ctrl+c
trap ctrl_c INT

#Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${purpleColour}[+]${endColour}${grayColour} Uso:${endColour}" 
  echo -e "\t${yellowColour}u)${endColour}${grayColour} Actualizar los archivos necesarios.${endColour}"
  echo -e "\t${yellowColour}m)${endColour}${grayColour} Buscar por nombre de la máquina.${endColour}"
  echo -e "\t${yellowColour}i)${endColour}${grayColour} Buscar por dirección IP de la máquina.${endColour}"
  echo -e "\t${yellowColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina.${endColour}"
  echo -e "\t${yellowColour}o)${endColour}${grayColour} Buscar por el sistema operativo.${endColour}"
  echo -e "\t${yellowColour}y)${endColour}${grayColour} Obtener link de la resolución de la máquina en Youtube.${endColour}"
  echo -e "\t${yellowColour}h)${endColour}${grayColour} Mostrar el panel de ayuda.${endColour}\n"
}

function updateFiles(){
	tput cnorm

  if [ ! -f bundle.js ]; then
	echo -e "\n${purpleColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}"
	curl -s $main_url > bundle.js
  	js-beautify bundle.js | sponge bundle.js
	echo -e "\n${purpleColour}[+]${endCOlour}${grayColour} Los archivos se han descargado con éxito.${endColour}\n"
	tput cnorm
  else
	echo -e "\n${purpleColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}"
	curl -s $main_url > bundle_temp.js
	js-beautify bundle_temp.js | sponge bundle_temp.js
	md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
	md5_original_value=$(md5sum bundle.js | awk '{print $1}')

	if [ "$md5_temp_value" == "$md5_original_value" ]; then
		echo -e "${purpleColour}[+]${endColour}${grayColour} No hay actualizaciones pendientes, lo tienes todo al día :)${endColour}\n"
		rm bundle_temp.js
	else
		echo -e "${purpleColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles.${endColour}\n"
		sleep 1
		rm bundle.js && mv bundle_temp.js bundle.js
		echo -e "${purpleColour}[+]${endColour}${grayColour} Se han ejecutado las actualizaciones con éxito.${endColour}\n"
	fi
	tput cnorm
  fi
}


function searchMachine(){
  machineName="$1"
  maquina=$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')
 # echo "$machineName"
  echo -e "\n${purpleColour}[+]${endColour}${grayColour}Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

  if [ "$maquina" ]; then
  	echo -e "${grayColour}"$maquina"${endColour}\n"
  else
	echo -e "\n${redColour}[!]${endColour}${grayColour} La máquina indicada no existe.${endColour}\n"	
  fi

}

function Buscarip(){
  ipAddress="$1"

  machineName=$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')

  if [ "$machineName" ]; then
  	echo -e "\n${purpleColour}[+]${endColour}${grayColour} La máquina correspondiente para la IP es${endColour}${blueColour} $machineName${endColour}\n" 
  else
	echo -e "\n${redColour}[!] La IP proporcionada no existe.${endColour}\n"
  
  fi
}

function getYoutubelink(){
  machineName="$1"

  link="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  
  if [ "$link" ]; then
	  echo -e "\n${purpleColour}[+]${endColour}${grayColour} Obtener enlace de Youtube.${endColour}"
	  echo -e "${blueColour}$link${endColour}\n"
  else
	  echo -e "\n${redColour}[!] La máquina no existe.${endColour}\n"
  fi
}

function dificultad(){
difficulty="$1"

results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

if [ "$results_check" ]; then
	echo -e "\n${purpleColour}[+]${endColour}${grayColour} Mostrando las máquinas que tienen un nivel de dificultad${endColour}${blueColour} $difficulty${endColour}"
	echo -e "${grayColour}$results_check${endColour}\n"
else
	echo -e "\n${redColour}[!] La dificultad solicitada no existe en ninguna máquina.${endColour}\n"
fi
}

function sistema_operativo(){
os="$1"

os_check="$(cat bundle.js | grep -i "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

if [ "$os_check" ]; then
	echo -e "\n${purpleColour}[+]${endColour}${grayColour} Mostrando las máquinas cuyo sistema operativo es${endColour}${blueColour} $os${endColour}"
	echo -e "${grayColour}$os_check${endColour}\n"
else
	echo -e "\n${purpleColour}[+]${endColour}${grayColour} El sistema operativo indicado no corresponde a ninguna máquina${endColour}\n"
fi
}

function dificultad_os(){
difficulty=$1
os=$2

}
# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_dificultad=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG";chivato_dificultad=1; let parameter_counter+=5;;
    o) os="$OPTARG";chivato_os=1 let parameter_counter+=6;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then 
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	Buscarip $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubelink $machineName
elif [ $parameter_counter -eq 5 ]; then
	dificultad $difficulty
elif [ $parameter_counter -eq 6 ]; then
	sistema_operativo $os
elif [ "$chivato_dificultad" -eq 1 ] && [ "$chivato_os" -eq 1 ]; then
	dificultad_os $difficulty $os
else
  helpPanel
fi
