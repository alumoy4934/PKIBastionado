#!/bin/sh

while true; do

	echo "-------------------------------------------";
	echo "| [ CONFIGURACIÓN CA-INTERMEDIA ]         |";
	echo "-------------------------------------------";
	echo " 1.- Crear estructura para la pki";
	echo " 2.- Iniciar la PKI";
	echo " 3.- Crear entidad de certificación.";
	echo " 4.- Generar certificado público de la CA y clave privada.";
	echo " 5.- Distribuir certificado público de la CA";
	echo " 6.- Asistente importación de certificados.";
	echo " 7.- Generar certifiado SSL para servidor";
	echo " 8.- Revocar certificado.";
	echo " 9.- Salir";
	echo "\n";


	read -p "Seleccione una opción de las siguientes: " op
	case $op in
		[1]* )  echo "Creando estructura de directorio pki";
                cd ~;
                mkdir easy-rsa;
                ln -s /usr/share/easy-rsa/* ~/easy-rsa;
                sudo chmod 700 easy-rsa;
                echo "Acción realizada corréctamente";;

		[2]* )  echo "Iniciando la PKI...";
			    cd ~/easy-rsa/;
			   ./easyrsa init-pki;
			    echo "PKI iniciada corréctamente";;

		[3]* )	 echo "Creando la entidad de certificación";
			     echo "Generando archivo vars";
			     echo "Introduzca los valores entre comillas dobles";
			     cd ~/easy-rsa/;
			     read -p "COUNTRY?" country;
			     echo set_var EASYRSA_REQ_CONTRY $country >> vars;
			     read -p "PROVINCE?" province;
			     echo set_var EASYRSA_REQ_PROVINCE $province >> vars;
			     read -p "CITY?" city;
			     echo set_var EASYRSA_REQ_CITY $city >> vars;
			     read -p "ORGANIZATION?" organization;
			     echo set_var EASYRSA_REQ_ORG $organization >> vars;
			     read -p "EMAIL?" email;
			     echo set_var EASYRSA_REQ_EMAIL $email >> vars;
			     read -p "ORGANIZATIONAL UNIT?" ou;
			     echo set_var EASYRSA_REQ_OU $ou >> vars;
			     read -p "ALGO?" algo;
			     echo set_var EASYRSA_ALGO $algo >> vars;
			     read -p "DIGEST?" digest;
			     echo set_var EASYRSA_DIGEST $digest >> vars;
			     clear;
			     echo "El fichero vars generado es el siguiente: \n";
			     cat vars;
			     echo "\nAhora debe geneerar el certificado público de la CA";;

		[4]* )   echo "Generando certificado público y clave privada.";
			     cd ~/easy-rsa/;
			     ./easyrsa build-ca;;

		[5]* ) 	 cd ~/easy-rsa/pki/
			     echo "Asistente de distribución del certificado publico de la CAIntermedia";
			     echo "Proporcione ruta de destino. Ej: carmoy@192.168.1.100:/home/carmoy/tools/";
			     echo "La carpeta destino debe existir";
			     read -p "¿Usuario en máquina destino?" user;
			     read -p "¿IP de máquina destino?" ip_dest;
			     read -p "¿Ruta de destino?" route_dest;
			     scp caintermedia.crt $user@$ip_dest:$route_dest;;

		[6]*)	 echo "Asistente de importación de certificados.";
			     read -p "Ruta origen del certificado a importar?" route_source;
			     sudo cp $route_source /usr/local/share/ca-certificates;
			     sudo update-ca-certificates;;

		[7]*) 	 echo "Creando clave privada para el dominio, su CSR y firma.";
			     read -p "Nombre del dominio?" domainName;
			     openssl genrsa -out ~/easy-rsa/pki/private/alcoy-upv.ciber.key 2048;
			     cd ~/easy-rsa/pki/private/;
			     openssl req -new -key alcoy-upv.ciber.key -out alcoy-upv.ciber.req;
			     cd ~/easy-rsa;
			     ./easyrsa import-req ~/easy-rsa/pki/private/alcoy-upv.ciber.req alcoy-upv;
			     ./easyrsa sign-req server alcoy-upv;; 

		[8]*)	 echo "Revocando certificado";
			     cd ~/easy-rsa/
			     ./easyrsa revoke alcoy-upv;
			     echo "Generando lista de revocación CRL";
			     ./easyrsa gen-crl;;

		[9]*)	 echo "Ha escogido salir del programa. Hasta luego.";
			     break;;

		* ) clear;
		    echo "Opción incorrecta, vuelve a seleccionar.\n";;
	esac
done