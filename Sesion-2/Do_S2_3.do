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
		glo path "D:/Dropbox/EducatePeru/Indicadores/S2" // ET
		
	}
	*Dirección de carpetas
	glo clean	"${path}/clean"		// carpeta de clean
	glo Imagen	"${path}/Imagen"		// carpeta de imagen
	glo Tablas	"${path}/Tablas"		// carpeta de tablas

*======================================================

*==================================================
*Paso 1 :
*Carga de la base de datos
*--------------------------------------------
	u "${clean}/BD_Empleo_2020.dta",clear
	cls
	d
	
	*Grafico 1
	*-----------------------------
	graph box r6prin [aw=fac500a] , over(r5r4mtpe3, sort(1) descending label(labsize(small)))
	
	*Grafico de los ingresos por grupo de sector
	graph box r6prin [aw=fac500a] if r5r4mtpe3!=8, over(r5r4mtpe3, sort(1) descending label(angle(90) labsize(small)))  medtype(marker) ysize(4) medmarker(msymbol(O)) missing intensity(30) nooutside ytitle("{bf: Nuevos Soles (S/.)}") note("") 
	graph export "${Imagen}/Empleo_1.png",replace
	
	*Grafico de los ingresos por grupo de sector
	graph box r6prin [aw=fac500a] if r5r4mtpe3!=8, over(r5r4mtpe3, sort(1) descending label(angle(90) labsize(small)))  medtype(marker) ysize(4) medmarker(msymbol(O)) missing intensity(30) nooutside ytitle("{bf: Nuevos Soles (S/.)}") note("Nota: el circulo detalla el valor de la mediana " "Fuente: ENAHO - 2020") 
	graph export "${Imagen}/Empleo_1.png",replace
	
	*Grafico 2
	*-----------------------------
	*Grafico empleo segun genero
	graph hbox r6prin [aw=fac500a] if r5r4mtpe3!=8, over(r4, sort(1) descending label(angle(0) labsize(small)))    medtype(marker) ysize(4) medmarker(msymbol(O)) missing intensity(30) nooutside ytitle("{bf: Nuevos Soles (S/.)}") note("Nota: el circulo detalla el valor de la mediana " "Fuente: ENAHO - 2020") 
	graph export "${Imagen}/Empleo_2.png",replace

	*Grafico 3
	preserve
	collapse (mean) r6prin [iw=fac500a] if  r1r_a<=70,by(rsexo r1r_a )
	
	graph tw ( scatter r6prin r1r_a if rsexo==1 ) ( scatter r6prin r1r_a if rsexo==0 ) , legend(label( 1 "Hombre") label(2 "Mujer")) ytitle("{bf: Nuevos Soles (S/.)}") note("Nota: dispersion de los ingresos promedio mensual " "Fuente: ENAHO - 2020")
	graph export "${Imagen}/Empleo_3.png",replace
	restore
	
	
	*Grafico 3
	*-----------------------------
	*Grafico de dispersion
	
	sum r6prin
	local p1=r(mean)
	sum rinfo
	local p2=r(mean)
	
	*Reordenar los departamentos
	
	
	preserve
	collapse (mean) rinfo r6prin [iw=fac500a] if r6prin!=0, by(rDpto)

	graph tw (scatter rinfo r6prin  , mlabel(rDpto) msymbol(D) mcolor(navy) mlabcolor(navy)), xline(`p1') yline(`p2') xtitle("Ingreso promedio mensual") ytitle("Porcentaje (%)")
	
	g pos=.
	replace pos=9 	if rDpto==7
	replace pos=9 	if rDpto==15
	replace pos=12 	if rDpto==14
	replace pos=12 	if rDpto==6
	replace pos=9 	if rDpto==21
	replace pos=12 	if rDpto==25
	replace pos=6 	if rDpto==24
	replace pos=6 	if rDpto==20
	
	graph tw (scatter rinfo r6prin  if r6prin!=0, mlabel(rDpto) msymbol(D) mcolor(navy) mlabcolor(navy) mlabv(pos)), xline(`p1') yline(`p2') xtitle("Ingreso promedio mensual") ytitle("Informalidad - Porcentaje (%)")
	graph export "${Imagen}/Empleo_4.png",replace	
	
	restore
	
	*Gini de los ingresos
	*Nacional
	ineqdeco r6prin [w=fac500a]
	
	*Departamento
	ineqdeco r6prin [w=fac500a] if r6prin!=0, by(rDpto)
	
	matrix 	gini=J(25,1,.)
	forvalues i=1/25{
		qui ineqdeco r6prin if rDpto==`i' & r6prin!=0 [w=fac500a]
		matrix gini[`i',1]=r(gini)	
	}
	matlist gini
	svmat double gini, names(parametro)
	
	sum rinfo
	local p1=r(mean)
	
	preserve
	keep parametro
	drop if parametro==.
	g rDpto=_n
	tempfile base
	saveold `base',replace
	restore
	
	*Acoplando Gini e Informalidad
	*------------------------------
	preserve
	collapse (mean) rinfo r6prin [iw=fac500a] if r6prin!=0, by(rDpto)	
	merge 1:1 rDpto using `base'
	
	rename parametro1 gini

	sum gini 
	local p2=r(mean)
	
	g pos=.
	replace pos=6 	if rDpto==17			/*Madre de Dios*/
	replace pos=12 	if rDpto==25		/*Ucayali*/
	replace pos=9 	if rDpto==18		/*Moquegua*/
	replace pos=9 	if rDpto==6		/*Cajamarca*/
	replace pos=9 	if rDpto==9		/*Huancavelica*/
	
	graph tw (scatter rinfo gini  , mlabel(rDpto) msymbol(D) mcolor(navy) mlabcolor(navy) mlabv(pos)), xline(`p2') yline(`p1') xtitle("Coeficiente Gini") ytitle("Porcentaje (%) - Informalidad")
	graph export "${Imagen}/Empleo_5.png",replace	
		
	
	restore
	