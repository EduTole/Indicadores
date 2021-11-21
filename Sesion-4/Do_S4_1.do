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

u "${path}/BASES/ENAHO/2015/enaho01a-2015-300.dta",clear

do "${dofile}/2.- rArea.do"
do "${dofile}/3.- rDpto y rDpto2.do"
do "${dofile}/5.- r1r.do"


*Tasa de analfabetismo
g ranalfa=0 		if p208a>=15 & p204==1
replace ranalfa=1 	if p208a>=15 & p302==2 & p204==1
label define ranalfa 1 "Analfabetismo" 0 "otro caso"
label values ranalfa ranalfa
label var ranalfa "Sabe leer y escribir"


*Estadisticas 
tab ranalfa [iw=factor07a] /*factor de expansion por grupo de edad*/

*------------------------------------
* Tasa de conclusion
*------------------------------------

u "${path}/BASES/ENAHO/2019/enaho01a-2019-400.dta",clear
merge 1:1 $llave using "${path}/BASES/ENAHO/2019/enaho01a-2019-300.dta",keep(match )  nogen

do "${dofile}/2.- rArea.do"
do "${dofile}/3.- rDpto y rDpto2.do"

*Estimar los años cumplido 30 marzo
rename a*o year
destring year, replace
g 		edad31mar=year-p400a3  if p400a2<4
replace edad31mar=(year-p400a3-1) if p400a2>3 & p400a2<=12 
replace edad31mar=0 if edad31mar<0

destring mes, replace

*Tasa de conclusion 12-13 años
*tasa acumulada
g 		tasaco=0 if (edad31mar>=12 & edad31mar<=13 )   
replace tasaco=1 if (edad31mar>=12 & edad31mar<=13 ) & (p301a>=4 & p301a<=11)

tab tasaco [aw=factora07]
tab rDpto tasaco [aw=factora07], row nofreq

*------------------------------------
* Tasa de desercion
*------------------------------------

u "${path}/BASES/ENAHO/2020/enaho01a-2020-400.dta",clear
merge 1:1 $llave using "${path}/BASES/ENAHO/2020/enaho01a-2020-300.dta",keep(match using)  nogen

do "${dofile}/2.- rArea.do"
do "${dofile}/3.- rDpto y rDpto2.do"

*Estimar los años cumplido 30 marzo
rename a*o year
destring year, replace
g 		edad31mar=year-p400a3  if p400a2<4
replace edad31mar=(year-p400a3-1) if p400a2>3 & p400a2<=12 
replace edad31mar=0 if edad31mar<0

destring mes, replace
*Tasa de desercion 13-19 años
g 		tasade=0 if (edad31mar>=13 & edad31mar<=19 ) & (p301a==5) & mes>=4  
replace tasade=1 if (edad31mar>=13 & edad31mar<=19) & (p301a==5) & p306==2  & mes>=4  


tab tasade [iw=factora07]
tab rDpto tasade [aw=factora07], row nofreq


