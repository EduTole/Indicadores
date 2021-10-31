*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05 y 03
* Fecha:				Educacion Mincer	
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
	
	
*---------------------------------------------
*Paso 2: Analisis de variables
*--------------------------------------------------
	*2.1 Modulo Educación
	u "${main}/2020/enaho01a-2020-300.dta", clear
	do "${disel}/42.- reduca.do"
	do "${disel}/39c.- rmaterna.do"
	
	*Codigo de persona
	egen codigo_id=concat(conglome vivienda hogar codperso)
	****************************
	* Ordenar variables generadas
	****************************
	
	keep codigo_id r* 
	order codigo_id r* 
	cls
	d
	saveold "${clean}//BD_Educacion_2020.dta",replace	
	
*---------------------------------------------
*Paso 3: Uniendo Moduloes
*--------------------------------------------------	
	cls
	u "${clean}//BD_Empleo_2020.dta",clear
	merge 1:1 codigo_id using "${clean}//BD_Educacion_2020.dta", keep(match) nogen
	d
	*Balance de variables : informacion con missing values 
	mdesc
		
	*guardamos la informacion
	*experiencia laboral
	drop if reduca ==.
	
	g rexp_a=r1r_a -reduca-5
	replace rexp_a=. if rexp<=1
	
	gen rexp_b=r1r_a-14
	replace rexp_b=. if rexp_b<=1
	gen rexp = min(rexp_a,rexp_b)
	
	label var rexp_a "Experiencia laboral - A"
	label var rexp_b "Experiencia laboral - B"
	label var rexp "Experiencia laboral - (Minimo A y B)"
	
	saveold "${clean}/BD_Mincer.dta",replace
	