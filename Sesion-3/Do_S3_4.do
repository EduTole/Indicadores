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
glo mapa	"${path}/Mapas/Departamento_2020"		// mapas

*======================================================

*==================================================
*Paso 1 :
*Carga de la base de datos
*--------------------------------------------
	gl llave "conglome vivienda hogar codperso"
	
	u "${main}//2020/enaho01a-2020-500.dta", clear

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
	
	* Por sexo
	preserve 
	collapse (mean) ocup* [iw=fac500a], by(rsexo) 
	
	rename (ocup1 ocup2 ocup3 ocup4) (ocup des_abierto des_oculto nopea)
	
	* tasa de desocupación = (desempleo oculto + desempleo abierto )/ (Pea + desempleo oculto)
	g desocupacion = (des_abierto + des_oculto) / (ocup + des_abierto + des_oculto)
	g ocupacion    = 1 - desocupacion
	keep rsexo ocup des_abierto des_oculto nopea desocupacion ocupacion
	export excel using "${clean}/2020_desocupacion_sexo.xls", replace firstrow(variables)
	restore
	
	*Por departamentos
	preserve
	collapse (mean) ocup* [iw=fac500a], by(rDpto) 
	
	rename (ocup1 ocup2 ocup3 ocup4) (ocup des_abierto des_oculto nopea)
	
	* tasa de desocupación = (desempleo oculto + desempleo abierto )/ (Pea + desempleo oculto)
	g desocupacion = (des_abierto + des_oculto) / (ocup + des_abierto + des_oculto)
	
	g FIRST_IDDP=rDpto
	tostring FIRST_IDDP,replace
	replace FIRST_IDDP="0"+ FIRST_IDDP if length(FIRST_IDDP)==1
	keep desocupacion FIRST_IDDP
	saveold "${clean}/desocupacion_dpto_2020.dta",replace
	restore	
	
	
	cd "${clean}"
	spshape2dta "${mapa}/Dpto_gs_2020.shp" , saving(Shape_dpto) replace

	*Cambio de centroides
	preserve
	u Shape_dpto,clear
	replace _CX= _CX-1 		if _ID==7
	replace _CX= _CX-0.9 	if _ID==11 /*Ica*/
	replace _CX= _CX-1 		if _ID==14
	replace _CX= _CX-1.8 	if _ID==13 /*La Libertad*/

	replace _CX= _CX-2 		if _ID==18 /*Moquegua*/
	replace _CY= _CY-0.5	if _ID==18 /*Moquegua*/

	replace _CY= _CY+1 		if _ID==21 /*Puno*/

	*replace _CY= _CY+2 if _ID==7
	g nombre=NOMBDEP
	keep _ID nombre _CX _CY
	compress
	saveold "${clean}/shape_dpto_c.dta",replace

	u Shape_dpto,clear
	d
	merge 1:1 FIRST_IDDP using "${clean}/desocupacion_dpto_2020.dta", nogen
	
	*Mapa 1: desocupacion
	replace desocupacion=desocupacion*100
	replace desocupacion=round(desocupacion,2)
	
	spmap desocupacion using "Shape_dpto_shp.dta", id(_ID) clnumber(3) fcolor(Reds) title("Perú 2020: Tasa de desocupacion" , size(*0.7)) legstyle(2) legjunction(" - ") subtitle("(Porcentaje %)" , size(*0.7)) note("") label( data(shape_dpto_c) x(_CX) y(_CY) label(nombre) color(gs8) size(*0.6) position(5) length(30)) legend(title("Tasa (%)", size(*0.7) bexpand justification(left)))
	graph export "${imagen}/Mapa_desocupacion_2020.png",replace
	
	
		
	