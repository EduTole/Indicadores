*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05
* Fecha:				Indicadores empleo: NiNis	
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

	*Unir variable de educación
	merge 1:1 $llave using "${main}//`i'/enaho01a-`i'-300.dta",  nogen

	*Generando las variable de desempleo y ninis
	do "${disel}/27.- r13_c.do"
	
	g Ano=`i'
	do "${disel}/41.- rsexo.do"
	
	****************************
	* Collapsar la informacion de los ninis
	****************************
	tab r13_c, g(nini)
	collapse (mean) nini*, by(Ano) 
	
	forvalues j=1/4{
	replace nini`j'=nini`j'*100
	}
	tempfile base`i'
	saveold `base`i'',replace
	
	}
	
	
	u `base2010',clear
	forvalues i=2011/2020{
	append using `base`i''
	}
	
	saveold "${clean}/nini_2010_2020.dta",replace
	
	
	*Grafico de los NiNis 
	*Periodo 2010-2020
	tw (connected nini1 Ano)
	
	*Titulos en los ejes
	sum nini1
	local g1=r(mean)
	tw (connected nini1 Ano), ytitle("Porcentaje (%)") yline(`g1')
	*Exportar grafico	
	graph export "${imagen}/tendencia_nini_1.png",replace
	
	*Titulos de los ejes y agregando mas tendencias de las 
	*otras categorias
	tw (connected nini1 Ano) (connected nini2 Ano) (connected nini3 Ano), ytitle("Porcentaje (%)") legend(label(1 "NiNis") label(2 "Solo Estudia") label(3 "Solo Trabaja"))
	*Exportar grafico	
	graph export "${imagen}/tendencia_nini_2.png",replace
	
	
	