*********************************************
*
* Institucion:			Educa-Peru
* Autor:				Edinson Tolentino
* Proyecto:				EEA
* Fecha: 					
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
glo main "${path}/EducatePeru/Indicadores/S5"

glo clean		"${path}/EducatePeru/Indicadores/S5/Data"
glo tabla		"${main}/Tabla"		// Tabla
glo imagen		"${main}/Imagen"	// Imagen
glo dofile		"${main}/Dofiles" 	//codigos
glo deflactor	"${main}/Deflactores" 	//deflactores

*********************************************************

u "${clean}//FirmsUbigeo.dta",clear
foreach q in Asset ER{
merge 1:1 iruc Ano using "${clean}//`q'.dta",keep(match) nogen
}

do "${dofile}/3.- rDpto y rDpto2.do"

*Unir por deflactores
merge m:1 Ano using "${deflactor}\DEFLACTOR4_1.dta", keep(match) nogen

*Generacion variables ventas
egen Venta=rowtotal(VTA1 VTA2 VTA3)

*Variables
*-----------------------------------------------------
gl Activo "Asset1 Asset2 Asset3 Asset4 Asset5 Asset6 Asset7"
gl ER "PT PROFIT PROFIT2 PROFIT3 VA Venta"
gl Control "Edad"

*Deflactar las variables
*-----------------------------------------------------
foreach q in $Activo $ER {
	replace `q'=100*`q'/DPBI
}

*Solo valores positivos y no missing PT, Edad Venta
*-----------------------------------------------------
gl var0 "Venta PROFIT3 PROFIT2"
	foreach i of varlist $var0 {
		sum `i', detail
		local pmin=r(p5)
		local pmax=r(p95)
		
		g z`i'=1 if (`i'>`pmin' & `i'<`pmax')		
*		gen z`i' = 1 if `i' > 0 & `i' !=.
	}
	
g z=zVenta+zPROFIT2+zPROFIT3
d

*Solo si los datos son positivos ==1
g datos=(z==3)

*Filtrar infomacion
*-----------------------------------------------------
keep iruc Ano rDpto  $Control  $ER $Activo datos
order iruc Ano rDpto  $Control $ER $Activo  datos
d

label var PT "Produccion total"
label var PROFIT "Beneficios despues de impuestos"
label var PROFIT2 "Beneficios antes de impuestos"
label var PROFIT3 "Resultado de explotacion"
label var VA "Valor agregado"
label var Venta "Ventas totales"
label var Asset1 "Activo corriente"
label var Asset2 "Activo no corriente"
label var Asset3 "Activo total"
label var Asset4 "Pasivo corriente"
label var Asset5 "Pasivo no corriente"
label var Asset6 "Pasivo corriente"
label var Asset7 "Pasivo + Patrimonio"

d
sum

sum if datos==1
sum

saveold "${clean}//Universidad_2013_2018.dta",replace
