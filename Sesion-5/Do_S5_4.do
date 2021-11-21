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

u "${clean}//Universidad_2013_2018.dta",clear

*Margen sobre las ventas (MV)
g MV =PROFIT/Venta*100
label var MV "Margen de ventas"

*Margen sobre las beneficios (MB)
g MB =PROFIT2/Venta*100
label var MB "Margen de beneficios"

*Rentabilidad economica (Re)
g Re =PROFIT2/Asset3*100
label var Re "Rentabilidad economica"

*Estadistica
*total de la muestra
table Ano if datos==1, c(mean MV mean MB mean Re) row col format(%15,2fc)

*MV: 2018, un margen de utilidad sobre ventas de 4,38%, es decir, por cada 100 soles de venta que realizaron las empresas, la utilidad llegó a ser menor en 4,38 soles. 

*MB: 2018, por cada 100 soles de ventas realizadas ese año, la utilidad propia del negocio fue de 5.51 soles, siendo el mayor de los últimos años

*Re:  En el año 2018, las universidades no estatales obtuvieron una rentabilidad económica promedio de 5,14%, es decir que por cada 100 soles en activos se obtiene 5,14 soles de beneficio

	*Grafico 1
	*-----------------------------
	graph box Re if datos==1, over(Ano,  label(labsize(small))) nooutside

	tab rDpto
	
	*Grafico 2
	preserve
	keep if Ano==2018
	collapse (mean) Re MB if datos==1, by( rDpto)

	tw (scatter Re MB, mlabel(rDpto)) 
	tw (scatter Re MB, mlabel(rDpto)) if rDpto!=9, xtitle("Rentabilidad Economica") ytitle("Margen de Beneficio")	
	
	restore
	
