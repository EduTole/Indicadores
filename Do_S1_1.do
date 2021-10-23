cls 
clear all
cd "D:\Dropbox\EducatePeru\Indicadores\S1\Data"


*---------------------------------------------
*Incidencia de crecimiento de pobreza
*---------------------------------------------

foreach  i in 2004 2020 {
	local k=`i'-2000
	use sumaria-`i'.dta , clear

	g pond=factor07*mieperho 
	tab pobreza [iw=pond]
	g gasto=gashog2d/ mieperho* 12	
	egen cod_hogar=concat(conglome vivienda hogar)
	keep pond pobreza gasto cod_hogar
	g pond2=int(pond)
	g Ano=`i'
	
	gsort gasto
	g shrpop=sum(pond)
	replace shrpop=shrpop/ shrpop[_N]

	g percentil=.
	forvalues j=1(1)100{
		replace percentil=`j' if shrpop> (`j'-1)*0.01 & shrpop <= `j'*0.01
	}
	table percentil [iw=pond], c(mean gasto) replace
	rename table1 gasto`k'
	sort gasto`k'
	tempfile BD`k'
	saveold `BD`k'',replace
}

*Crecimiento incidencia entre 2004-2019
u `BD10',clear
merge 1:1 percentil using `BD4', nogen

g chg1=100*((gasto19/gasto4)^(1/14)-1)

sum chg1
local p1=r(mean)
g promedio=`p1'
tw (line chg1 percentil) (line promedio percentil), ylabel(3(2)11) xlabel(1(10)100) xtitle("") ytitle("Tasa de crecimiento %") legend(label(1 "2019-2004") label(2 "crec. 7.2"))

