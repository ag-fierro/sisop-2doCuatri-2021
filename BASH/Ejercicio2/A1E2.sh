#!/bin/bash

traduccion(){
	case $1 in
		MONDAY)
			echo lunes
		;;
		TUESDAY)
			echo martes
		;;
		WEDNESDAY)
			echo miercoles
		;;
		THURSDAY)
			echo jueves
		;;
		FRIDAY)
			echo viernes
		;;
		SATURDAY)
			echo sabado
		;;
		SUNDAY)
			echo domingo
		;;
	esac
}

mensaje_ayuda(){
	echo "Para mejorar el script que ya hizo, el influencer del ejercicio 2 decide agregar una nueva
	funcionalidad a su script: monitoreo de directorios en tiempo real.
	Implementar sobre el script del ejercicio anterior un mecanismo que permite renombrar los archivos a
	medida que se vayan copiando/moviendo/creando en el directorio de las fotos. Esto se debe realizar
	utilizando un demonio.
	Tener en cuenta que:
	• El script recibe los mismos parámetros que el del ejercicio 2:
	•• --path: Es el directorio donde se encuentran las imágenes. Tener en cuenta que se deben
	renombrar todos los archivos, incluidos los de los subdirectorios.
	•• -p: Otra manera de nombrar a --path. Se debe usar uno u otro.
	•• --dia: (Opcional) Es el nombre de un día para el cual no se quieren renombrar los archivos.
	Los valores posibles para este parámetro son los nombres de los días de la semana (sin 
	tildes). El script tiene que funcionar correctamente sin importar si el nombre del día está en
	minúsculas o mayúsculas.
	•• -d: Otra manera de nombrar a --dia. Se debe usar uno u otro
	• Como es una mejora sobre el script anterior, al ejecutarlo debe seguir renombrando los
	archivos existentes antes de quedar en modo monitoreo.
	• Durante el monitoreo, se debe devolver la terminal al usuario, es decir, el script debe correr
	en segundo plano como proceso demonio y no bloquear la terminal.
	• No se debe permitir la ejecución de más de una instancia del script al mismo tiempo.
	Para poder finalizar la ejecución del script, se debe agregar un parámetro “-k” que detendrá la
	ejecución del demonio. Se debe validar que este parámetro no se ingrese junto con el resto de los
	parámetros del script."
	exit 1
}

QANT=$#
RED='\033[0;31m'

if [[ $# -gt 4 ]]; then
	echo -e "${RED}Error, demasiados parametros"
	exit 1
fi

if [[ $# -eq 0 ]]; then
	echo -e "${RED}Error, ingrese parametros de ejecución (-h para instrucciones)"
	exit 1
fi


DIACHECK=0

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
	-k)
		if [[ $QANT -gt 1 ]];	then
			echo -e "${RED}Error, Demasiados parametros para ejecutar $1"
			exit 1
		fi
		line=$(head -n 1 ".APL1E3PIDlog")
		kill $line
		rm ".APL1E3PIDlog"
		exit 1
	;;
	-p|--path)
		if [[ -z $2 ]]; then
			echo -e "${RED}Error, Por favor ingrese un directorio junto con $1"
			exit 1
		fi
		if [[ -d $2 ]];	then
			PATH="$2"
		else
			echo -e "${RED}Error, El directorio a procesar $2 no existe"
			exit 1	
		fi
		shift # past argument
		shift # past value
	;;
	-d|--dia)
		if [[ "${2^^}" != @(DOMINGO|LUNES|MARTES|MIERCOLES|JUEVES|VIERNES|SABADO|MIÉRCOLES|SÁBADO) ]]; then
			echo -e "${RED}Error, $2 no es un día de la semana"
			exit 1
		fi
		if [[ -z $2 ]]; then
			echo -e "${RED}Error, Por favor ingrese un día de la semana junto con $1"
			exit 1
		fi
		DIA="${2^^}"
		DIACHECK=1
		shift # past argument
		shift # past value
	;;
	-h|-help|-?)
		if [[ $QANT -gt 1 ]];	then
			echo -e "${RED}Error, Demasiados parametros para ejecutar $1"
			exit 1
		fi	
		mensaje_ayuda
		exit 1
	;;
	esac
done

for filename in $PATH/*;do
	tiempo="Almuerzo"	
	
	aux="${filename%.*}"
	aux="${aux##*/}"
	if echo "$aux" | /bin/grep 'del' >/dev/null; then
		continue
	fi	
	yer=${aux:0:4}
	mes=${aux:4:2}
	dia=${aux:6:2}
	
	dow=$(/bin/date --date "$yer-$mes-$dia" +%A)
	dow=${dow^^}
	dow=$(traduccion $dow)
	
	if [[ DIACHECK -eq 1 && ${dow^^} == $DIA ]];then
		continue
	fi
	
	hora=${aux:9:2}
	minuto=${aux:11:2}
	segundo=${aux:13:2}
	if [[ $(( $hora*3600 + $minuto*60 + $segundo )) -gt 68400 ]];then
		tiempo="Cena"
	elif [[ $(( $hora*3600 + $minuto*60 + $segundo )) -lt 39600 ]];then
		tiempo="Desayuno"
	fi
	
	res="$dia-$mes-$yer $tiempo del $dow"
	/bin/mv "$filename" "$PATH/$res.${filename##*.}" 
done
