cls 
clear all
cd "D:\Dropbox\EducatePeru\Indicadores\S1\Data"

clear all
set more off

//Set pathways
di in yellow "USUARIO:`c(username)'"

qui if "`c(username)'"=="edinson" {
	glo path 	"D:\Dropbox\BASES\ENAHO" // ET
	glo clases	"D:\Dropbox\EducatePeru\Indicadores\S1" 
}

glo main "${path}/PEA"

glo imagen	"${clases}/Imagen"		// Input
glo tabla	"${clases}/Tablas"		// Input
glo clean	"${clases}/Data"		// Modified
glo disel	"${path}/DISEL-MTPE"	// Disel dofile
glo pobreza	"${path}/ET-Pobreza"	// Edinson dofile

//SET SEED
set seed 12345
set more off

*---------------------------------------------
*Incidencia de crecimiento de pobreza
*---------------------------------------------
	
	forvalues i=2010(1)2020{
	use "${path}//`i'/sumaria-`i'.dta", clear
	
	do "${disel}/2.- rArea.do"
	do "${disel}/3.- rDpto y rDpto2.do"

	do "${pobreza}/r1.-pobreza.do"
	tab pobre [iw=pond]
	g pob=1 if pobre==1
	g year=`i'
	
	*Incidencia de pobreza
	gen fgt0=pobre
	
	*Brecha de pobreza
	gen fgt1=(linea-y)/linea if pobre==1
	replace fgt1=0 if fgt1==0
	label variable fgt1 "Brecha de pobreza (%)"

	*Calculo de Severidad de pobreza total

	gen fgt2=fgt1^2
	label variable fgt2 "Severidad de la pobreza"
	
	collapse (mean) fgt0 fgt1 fgt2 [iw=pond], by(year)
	
	tempfile BASE`i'
	saveold `BASE`i'',replace
	}
*Poblacion con nivel de gasto menor al 20 % de la linea de pobreza	
	u `BASE2010',clear
	forvalues i=2011(1)2020{
	append using `BASE`i''
	}

	
	foreach q in fgt0 fgt1 fgt2{
	replace `q'=`q'*100
	tw (connected `q' year)  ,  xtitle("") ytitle("Porcentaje  (%)") xlabel(2010(1)2020)
graph export "${imagen}/Pobreza_`q'.png",replace
	}
		
	