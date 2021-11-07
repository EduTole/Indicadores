*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05
* Fecha:				Indicadores empleo: Desocupados	
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

glo clean	"${path}/EducatePeru/Indicadores/S3/Data"		// 
glo disel	"${main}/DISEL-MTPE"		// dofiles empleo
glo imagen	"${path}/EducatePeru/Indicadores/S3/Imagen"		// Imagen

*======================================================

*==================================================
*Paso 1 :
*Carga de la base de datos
*--------------------------------------------
	gl llave "conglome vivienda hogar codperso"
	
	forvalues i=2010/2020{
	u "${main}//`i'/enaho01a-`i'-500.dta", clear

	do "${disel}/1.- Filtro de residentes habituales.do"
	do "${disel}/2.- rArea.do"
	do "${disel}/3.- rDpto y rDpto2.do"
	do "${disel}/5.- r1r_a.do"
	do "${disel}/5.- r1r_b.do"
	do "${disel}/9c.- r3.do"
	do "${disel}/40a.- rinfo.do"
	do "${disel}/41.- rsexo.do"

	* Tasa de desocupacion:
	tab ocu500, generate(ocup)
	
	collapse (mean) ocup* [iw=fac500a], by(rsexo) 
	
	rename (ocup1 ocup2 ocup3 ocup4) (ocup des_abierto des_oculto nopea)
	
	* tasa de desocupación = (desempleo oculto + desempleo abierto )/ (Pea + desempleo oculto)
	g desocupacion = (des_abierto + des_oculto) / (ocup + des_abierto + des_oculto)
	

	
	*Guardamos como bases temporales
	g year=`i'
	tempfile base`i'
	saveold `base`i'',replace
	
	}
	
	
	u `base2010',clear
	forvalues i=2011/2020{
	append using `base`i''
	}
	
	*Grafico de la desocupación por sexo
	tw (connected desocupacion year if rsexo==1) (connected desocupacion year if rsexo==0)
	
	*Leyenda por sexo
	tw (connected desocupacion year if rsexo==1) (connected desocupacion year if rsexo==0), legend(label(1 "Hombre") label(2 "Mujer"))
	
	*Leyenda por sexo agregando titulos
	replace desocupacion=desocupacion*100
	tw (connected desocupacion year if rsexo==1) (connected desocupacion year if rsexo==0), legend(label(1 "Hombre") label(2 "Mujer")) xtitle("") ytitle("Porcentaje (%)")
	graph export "${imagen}/tendencia_deso.png",replace
	

	
	
	