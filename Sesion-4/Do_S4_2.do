*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05
* Fecha:				Indicadores Educación 	
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
glo main "${path}/EducatePeru/Indicadores/S4"

glo clean	"${path}/EducatePeru/Indicadores/S4/Data"
glo tabla	"${main}/Tabla"		// Tabla
glo imagen	"${main}/Imagen"	// Imagen
glo dofile	"${path}/BASES/ENAHO/DISEL-MTPE" //codigos
*********************************************************

gl llave "conglome vivienda hogar codperso"


****************** 2016 - 2019 **************************
forvalues i=2016/2019{
u "${path}/BASES/ENAHO//`i'//enaho01a-`i'-300.dta",clear

do "${dofile}/2.- rArea.do"
do "${dofile}/3.- rDpto y rDpto2.do"
do "${dofile}/5.- r1r.do"

*Tasa de analfabetismo
do "${dofile}/43.- ranalfa.do"

cap factora* factora07

g pond=factora07

tab ranalfa [iw=pond] /*factor de expansion por grupo de edad*/

g Ano=`i'
collapse (mean) ranalfa [iw=pond] , by(Ano)
replace ranalfa=ranalfa*100
tempfile BD`i'
saveold `BD`i'',replace

}

****************** 2020 **************************

forvalues i=2020/2020{
u "${path}/BASES/ENAHO//`i'//enaho01a-`i'-300.dta",clear

do "${dofile}/2.- rArea.do"
do "${dofile}/3.- rDpto y rDpto2.do"
do "${dofile}/5.- r1r.do"

*Tasa de analfabetismo
do "${dofile}/43.- ranalfa.do"

cap factor* factora07

g pond=factora_p
tab ranalfa [iw=pond] /*factor de expansion por grupo de edad*/

g Ano=`i'
collapse (mean) ranalfa [iw=pond] , by(Ano)
replace ranalfa=ranalfa*100
tempfile BD`i'
saveold `BD`i'',replace

}

u `BD2016',clear
forvalues i=2017/2020{
append using `BD`i''
}

tw (connected ranalfa Ano), title("Tasa de Analfabetismo") subtitle("2016-2020") xtitle("") ytitle("Part %")


