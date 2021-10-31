*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05
* Fecha:				Indicadores empleo	
*********************************************
cls
clear all
*--------------------------------------------------
*Paso 1: Direccion de carpeta
*--------------------------------------------------

//Set pathways
di in yellow "USUARIO:`c(username)'"

qui if "`c(username)'"=="edinson" {
	glo path "D:/Dropbox" // ET
	
}
*Dirección de carpeta de bases ENAHO
glo main "${path}/BASES/ENAHO"

glo clean	"${path}/EducatePeru/Indicadores/S2/clean"		// carpeta del curso
glo disel	"${main}/DISEL-MTPE"		// dofiles empleo

*======================================================

*==================================================
*Paso 1 :
*Carga de la base de datos
*--------------------------------------------
	u "${main}/2020/enaho01a-2020-500.dta", clear
	
	do "${disel}/1.- Filtro de residentes habituales.do"
	do "${disel}/3.- rDpto y rDpto2.do"
	do "${disel}/5.- r1r_a.do"
	do "${disel}/6.- r2.do"
	do "${disel}/7.- r2r_a.do"
	do "${disel}/9c.- r3.do"
	do "${disel}/10.- r4.do"
	do "${disel}/11.- r5r4mtpe.do"
	do "${disel}/12.- r5r4mtpe2.do"
	do "${disel}/28.- r5r4mtpe3.do"
	do "${disel}/15.- r6.do"
	do "${disel}/16.- r6prin.do"
	do "${disel}/18.- r8.do"
	do "${disel}/20.- r11.do"
	do "${disel}/40a.- rinfo.do"
	do "${disel}/41.- rsexo.do"

	*Codigo de persona
	egen codigo_id=concat(conglome vivienda hogar codperso)
	
	****************************
	* Ordenar variables generadas
	****************************
	
	keep codigo_id r* fac500a 
	drop r559_01-r559_50
	order codigo_id r* fac500a 
	cls
	d
	saveold "${clean}//BD_Empleo_2020.dta",replace
	
	
	
	
	