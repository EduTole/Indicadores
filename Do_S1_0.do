cls 
clear all
cd "D:\Dropbox\EducatePeru\Indicadores\S1\Data"


*---------------------------------------------
*Incidencia de crecimiento de pobreza
*---------------------------------------------

use sumaria-2019.dta , clear

g pond=factor07*mieperho 
tab pobreza [iw=pond]
g y=gashog2d/ mieperho/ 12
	
g pobre=(pobreza<=2)
g time=2019
	
*Calculo de brecha de pobreza

gen brecha_pobreza=(linea-y)/linea if pobre==1
replace brecha_pobreza=0 if pobre==0
label variable brecha_pobreza "Brecha de pobreza (%)"

*Calculo de Severidad de pobreza total

gen severi_pobre=brecha_pobreza^2
label variable severi_pobre "Severidad de la pobreza"


*Calculo de indicadores
*Diseno muestral
svyset conglome [pw=pond], strata(estrato)

*Estadisticas
svy: mean pobre brecha_pobreza severi_pobre


*Indicador FGT
*linea de pobreza: linea
*parametro alpha --> fgt
local alfa=2

g var=(1-y/linea)^`alfa' if y<linea
replace var=0 if var==. 

sum var [iw=pond]
local fgt=(r(sum)/r(sum_w))*100

display "FGT :" `fgt'

*Comando cortos
*Comando povdeco
povdeco y [w=pond], varpl(linea)

*Definiendo los pobre de acuerdo a la linea
poverty y [aw=pond], line(352) all

*Proporcion cuantiles
xtile cuantil=y , nq(5)
*svyset [pw=pond] 

*Grafico por quintiles
graph bar y [pw=pond], over(cuantil) ytitle("") ylabel(, format(%12.0fc))  blabel(bar, size(small) color(black) position(upper)  format(%12.0fc)) 


capture program drop fgt
program define fgt, rclass
	syntax varlist(max=1) [iweight] [if], Alfa(real) Zeta(real)
	
	
qui{	
	preserve
	* touse =1 -> observacion si cumple if & !=.
	* touse =0 -> observacion si cumple if | ==.
		marksample touse
		keep if `touse' == 1
		
		tempvar dato
		gen `dato' = (1- `varlist' / `zeta')^`alfa' if `varlist'< `zeta'
		replace `dato'=0 if `dato'==.
		sum `dato' [`weight'`exp']
		
		local fgt=(r(sum)/r(sum_w))*100

	restore
}		

	display as text "FGT (alfa=`alfa', Z=`zeta')=" as result % 6.3f `fgt'
	return scalar fgt =`fgt'
	
end

fgt y [iw=pond] , alfa(1) zeta(322)

*Comando povdeco
povdeco y [w=pond], varpl(linea)



*Cambio de matrix y grafico
svy: mean pobre brecha_pobreza severi_pobre
matrix betas=e(b)
matlist betas
matrix 	Estimador=J(3,1,.)
forvalues i=1/3{
matrix Estimador[`i',1]=betas[1,`i']	
}
*Pasar de matrix sobre variables
svmat double betas, names(parametro)
g year=2019
*Collapsar la informacion
collapse (mean) parametro*, by(year)
reshape long parametro, j(status) i(year)
replace parametro=parametro*100
*Etiquetas
label define status 1 "Incidencia" 2 "Brecha" 3 "Severidad"
label values status status
*Graficos
graph bar parametro, over(status) ytitle("") ylabel(, format(%12.0fc))  blabel(bar, size(small) color(black) position(upper)  format(%12.2fc)) 



*Exportar excel
*Forma 1
putexcel set "Output1.xlsx", sheet("Hoja1") modify
putexcel  B1="Indicadores"
putexcel  A2="Pobreza"
putexcel  A3="Brecha"
putexcel  A4="Severidad"
putexcel  B2=matrix(Estimador)

*Forma 2
tab time
tabout time using "Output2.xls"  , /// 
cells(mean pobre  ) f( 3 ) sum npos(lab) svy ///
rep ///
style(xls) bt font(bold) cl1(2-6)

tabout time using "Output2.xls"  , /// 
cells(mean brecha_pobreza  ) f( 3 ) sum npos(lab) svy ///
append ///
style(xls) bt font(bold) cl1(2-6)
