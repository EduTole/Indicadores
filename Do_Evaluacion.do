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

	use "${path}/2020/sumaria-2020.dta", clear
	
	do "${disel}/2.- rArea.do"
	do "${disel}/3.- rDpto y rDpto2.do"

	do "${pobreza}/r1.-pobreza.do"

*Calculo de indicadores
*Diseño muestral
svyset conglome [pw=pond], strata(estrato)

*Estadisticas
svy: mean pobre brecha_pobreza severi_pobre
svy: mean pobre brecha_pobreza severi_pobre, over(rArea)

	matrix betas=e(b)
	matlist betas
	matrix 	Estimador=J(3,1,.)
	forvalues i=1/3{
	matrix Estimador[`i',1]=betas[1,`i']	
	}


	*Exportar excel
	*Forma 1
	putexcel set "${tabla}/Output_2020.xlsx", sheet("Hoja1") modify
	putexcel  B1="Indicadores"
	putexcel  A2="Pobreza"
	putexcel  A3="Brecha"
	putexcel  A4="Severidad"
	putexcel  B2=matrix(Estimador)

	*Forma 2
	tab time
	tabout time using "${tabla}/Output_2020.xls"  , /// 
	cells(mean pobre  ) f( 3 ) sum npos(lab) svy ///
	rep ///
	style(xls) bt font(bold) cl1(2-6)

	tabout time using "${tabla}/Output_2020.xls"  , /// 
	cells(mean brecha_pobreza  ) f( 3 ) sum npos(lab) svy ///
	append ///
	style(xls) bt font(bold) cl1(2-6)
