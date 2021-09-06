#!/bin/bash

# Actividad Pactica de Laboratorio Nro. 1 - Ejercicio 5
# Fierro, Agustin Gabriel- 42.427.695
# Albanesi, Matias - 39.770.388
# Rodriguez, Ezequiel Nicolás - 40.135.570
# Jimenez Vitale, Matias - 34.799.834
# Cambiasso, Tomas - 41.471.465


# Primera Entrega

declare -a directorios

function ayuda(){
    
    echo "#####################################################################################"
    echo "$0"
    echo "   Sintaxis de uso:"
    echo "      $0 rutaArchivoConfiguración"
    echo "   Utilidad:"
    echo "      $0  genera un archivo en formato zip para cada directorio pasado, comprimiendo los archivos de"
    echo "       log antiguos de cada carpeta de logs y los almacena en otra carpeta. Una vez comprimidos, "
    echo "      los archivos se eliminan del lugar de origen."
    echo "   Archivo de configuración:"
    echo "     El proceso recibirá como parámetro 1 archivo de configuración que contendrá:"
    echo "          • En la primera línea la carpeta de destino de los archivos comprimidos. "
    echo "          • A partir de la segunda línea, las rutas donde se encuentran las carpetas de logs a analizar."
    echo "     Ejemplo:"
    echo "              ./Datos/Salida/"
    echo "              ./Servicio1/carpeta_con_logs1/"
    echo "              ./Servicio2/carpeta_con_logs2/"
    echo "              ./Servicio3/carpeta_con_logs3/"
    echo "#####################################################################################"
   
}

validarDirectorioEscritura() {
    # Si es un empty string, no es un directorio o no es readable
    if [ -z "$1" ] || ! [ -d "$1" ] || ! [ -w "$1" ] 
    then
        echo "El directorio \"$1\" no es válido, es inexistente o no puede ser leído"
        exit 1
    fi
}

validarDirectorioLectura() {
    # Si es un empty string, no es un directorio o no es readable
    if [ -z "$1" ] || ! [ -d "$1" ] || ! [ -r "$1" ] 
    then
        echo "El directorio \"$1\" no es válido, es inexistente o no puede ser leído"
        exit 1
    fi
}

validarArchivoLectura() {
    # Si es un empty string, es un directorio o no es readable
    if [ -z "$1" ] || [ -d "$1" ] || ! [ -r "$1" ] 
    then
        echo "El Archivo \"$1\" no es válido, es inexistente o no puede ser leído"
        exit 1
    fi
}

validarArchivoEscritura() {
    # Si es un empty string,  es un directorio o no es writeable
    if [ -z "$1" ] || [ -d "$1" ] || ! [ -w "$1" ] 
    then
        echo "El Archivo \"$1\" no es válido, es inexistente o no puede ser escrito"
        exit 1
    fi
}

function leer_archivo_conf(){
    
    validarArchivoLectura "$1"

    while read -r line; do    
        validarDirectorioLectura "$line"
        directorios+=("$line")
    done < "$1"

}

function procesar(){
    leer_archivo_conf "$1"

    directorio_salida=${directorios[0]} #Solo el primero
    directorios_entrada=${directorios[@]:1:${#directorios[@]}} #Todo el resto del array

    fecha_ejecucion=`date +'%Y%m%d_%H%M%S'`

    for dir in $directorios_entrada
    do
        dir_name=`basename $(dirname "$dir")` # Obtener nombre del servicio desde el path
        
        # obtener todos los archivos que tienen la extension deseada y que no son del dia en que corre el script.
        temp=`find $dir -daystart -not -mtime -1  -iname '*.txt' -or -iname '*.log' -or -iname '*.info' `
        
        # comprimir esos archivosa un zip. ( -j elimina los directorios padre dejanso solo el archivo, -q quiet operation,
        # -m mueve los archivos al zip eliminandolos del origen, - comprime a la standar input, para luego dirigirlo al archivo con '>')
        zip -jqm - $temp > ${directorio_salida}logs_${dir_name}_${fecha_ejecucion}.zip
    done
}

if [[ $# -gt 0 ]]; then
    while [[ "$#" -gt 0 ]]
    do
        case "$1" in
            -h)
                ayuda
                exit 0
            ;;
            *)
                procesar $1
                exit 0
            ;;
        esac
    done
else
echo "Cantidad de parametros inválida. Para recibir ayuda sobre la utilización de este script use $0 -h"
fi