*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				Enaho 2020 - Modulo 05
* Fecha:				Indicadores NiNis 	
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
glo main "${path}/EducatePeru/Indicadores/S3"

glo clean	"${path}/EducatePeru/Indicadores/S3/Data"
glo Tabla	"${main}/Tabla"		// Tabla
glo imagen	"${main}/Imagen"		// Imagen
glo mapa	"${path}/Mapas/Departamento_2020"		// mapas

*****************************************************
* PASO 1: Cargar la base de datos
*****************************************************
	
	use "${clean}/empleo_2018.dta",replace
	
	*Estadisticas
	*--------------------------------------------
	*Nacional
	tab r13_c [iw=fac500a]
	
	*Por sexo 
	tab r13_c rsexo [iw=fac500a], nofreq col
	
	*Por sexo y zona geografica
	*Urbano
	tab r13_c rArea [iw=fac500a] if rsexo==1, nofreq col
	*Rural
	tab r13_c rArea [iw=fac500a] if rsexo==2, nofreq col
	
	*Grafico
	*-------------------------------------------
	tab r13_c, g(nini)
	g Ano=2018
	collapse nini1 nini2 nini3 nini4 [iw=fac500a], by(Ano)
	
	*Version 1 : grafico
	graph bar nini* , over(Ano) percentages stack
	
	*Version 2: grafico con nombre de ejes
	graph bar nini* , over(Ano) percentages stack ///
	ytitle("") ylabel(, format(%12.0fc))  
	
	*Version 3: grafico con label y leyenda	
	graph bar nini* , over(Ano) percentages stack ///
	ytitle("") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	
	
	*Version 4: grafico horizontal con label y leyenda	
	graph hbar nini* , over(Ano) percentages stack ///
	ytitle("Perú: Población juvenil por condición de estudio y trabajo") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	*Exportar el grafico 	
	graph export "${imagen}/Nini_1.png",replace
	
	*Realizando la misma información con el comando collapse
	*-------------------------------------------------------
	use "${clean}/empleo_2018.dta",replace
	
	tab r13_c, g(nini)
	g Ano=2018
	
	*Utilizar el comando preserve para poder mantener 
	*la base original pero ajustarlo solo a una pequeña base
	*La cual se usara para luego realziar un grafico
	
	*Nacional
	preserve	
	collapse nini1 nini2 nini3 nini4 [iw=fac500a], by(Ano)
	
	*Version 4: grafico horizontal con label y leyenda	
	graph hbar nini* , over(Ano) percentages stack ///
	ytitle("Perú: Población juvenil por condición de estudio y trabajo") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	*Exportar el grafico 	
	graph export "${imagen}/Nini_1.png",replace
	restore
	
	*Por sexo
	preserve	
	collapse nini1 nini2 nini3 nini4 [iw=fac500a], by(Ano rsexo)
	
	*Grafico 2: poblacion juvenil por sexo	
	graph hbar nini* , over(rsexo) percentages stack ///
	ytitle("Perú: Población juvenil por condición de estudio y trabajo") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	*Exportar el grafico 	
	graph export "${imagen}/Nini_2.png",replace
	restore
	
	*Por area 
	preserve	
	collapse nini1 nini2 nini3 nini4 [iw=fac500a], by(Ano rArea)
	
	*Grafico 3: poblacion juvenil por area
	graph hbar nini* , over(rArea) percentages stack ///
	ytitle("Perú: Población juvenil por condición de estudio y trabajo") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	*Exportar el grafico 	
	graph export "${imagen}/Nini_3.png",replace
	restore

	*Por area y sexo
	preserve	
	collapse nini1 nini2 nini3 nini4 [iw=fac500a], by(Ano rArea rsexo)
	
	*Grafico 4: poblacion juvenil por area y sexo
	graph hbar nini* , over(rArea) over(rsexo) percentages stack ///
	ytitle("Perú: Población juvenil por condición de estudio y trabajo") ylabel(, format(%12.0fc))  blabel(bar, size(vsmall) color(white) position(center)  format(%12.0fc)) legend(label(1 "Ni Estudia y Ni Trabaja") label(2 "Solo Estudia") label(3 "Solo Trabaja") label(4 "Solo Estudia y Trabaja") )
	*Exportar el grafico 	
	graph export "${imagen}/Nini_4.png",replace
	restore
	
	*Mapa de los NiNis
	*---------------------
	g FIRST_IDDP=rDpto
	tostring FIRST_IDDP,replace
	replace FIRST_IDDP="0"+ FIRST_IDDP if length(FIRST_IDDP)==1

	collapse (mean) nini1 [iw=fac500a], by(rDpto FIRST_IDDP)
	replace nini1=nini1*100
	saveold "${clean}/Nini_2018.dta",replace

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
	merge m:1 FIRST_IDDP using "${clean}/Nini_2018.dta", nogen
	
	*Mapa 1: NiNis 2018
	replace nini1=round(nini1,2)
	spmap nini1 using "Shape_dpto_shp.dta", id(_ID) clnumber(5) fcolor(Reds) title("Perú 2018: NiNis" , size(*0.7)) legstyle(2) legjunction(" - ") subtitle("(Porcentaje %)" , size(*0.7)) note("") label( data(shape_dpto_c) x(_CX) y(_CY) label(nombre) color(gs8) size(*0.6) position(5) length(30)) legend(title("Tasa (%)", size(*0.7) bexpand justification(left)))
	graph export "${imagen}/Mapa_Ninis_2018.png",replace
	
	
	*Grafico de dispersión
	use "${clean}/empleo_2018.dta",replace
	tab r13_c, g(nini)
	
	preserve
	collapse (mean) rinfo nini1 [iw=fac500a] , by(rDpto)	
	
	sum nini1 
	local p1=r(mean)
	sum rinfo 
	local p2=r(mean)
	
	g pos=.
	replace pos=6 	if rDpto==17			/*Madre de Dios*/
	replace pos=12 	if rDpto==25		/*Ucayali*/
	replace pos=9 	if rDpto==18		/*Moquegua*/
	replace pos=9 	if rDpto==6		/*Cajamarca*/
	replace pos=9 	if rDpto==9		/*Huancavelica*/
	
	graph tw (scatter rinfo nini1  , mlabel(rDpto) msymbol(D) mcolor(navy) mlabcolor(navy) mlabv(pos)), xline(`p1') yline(`p2') xtitle("NiNis (%)") ytitle("Informalidad (%)")
	graph export "${imagen}/Ninis_scatter.png",replace	
	restore
	