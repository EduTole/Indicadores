*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Proyecto: Pobreza Multidimensional
* Autor: Edinson Tolentino
*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cls 
clear all
/*
global ubicacion "D:\Dropbox\EducatePeru\Indicadores\S1\Data" 
cap mkdir "$ubicacion"

if 1==1{
	mat ENAHO=(687\737)
	mat MENAHO=J(2,31,0)
	mat MENAHO[1,1]=(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,23,24,25,26,27,28,34,37,77,78,84,85)
	mat MENAHO[2,1]=(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,23,24,25,26,27,28,34,37,77,78,84,85)
	
}
mat list ENAHO

*Paso 2: extraccion zip

*forvalues i=20/20{
forvalues i=19/19{
	local year=2000
	local year=`year'+`i'
*	local z=`i'-1
	local t=1
	
	cd "$ubicacion"
	cap mkdir `year'
	cd `year'
	
	cap mkdir "Download"
	cd "Download"
	
	scalar r_enaho=ENAHO[`t',1]
*		forvalue j=1/5{
		foreach j in  1 2 3 4 5 {
		scalar r_menaho=MENAHO[`t',`j']
		display "`year'" " " r_enaho " " r_menaho
		local mod=r_enaho
		local i=r_menaho
		display "`i'" " " "`year'" " " "`mod'"
		cap copy http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/`mod'-Modulo0`i'.zip enaho_`year'_mod_`i'.zip 
		cap unzipfile enaho_`year'_mod_`i'.zip, replace
		cap erase enaho_`year'_mod_`i'.zip
		}		
		
	scalar r_enaho=ENAHO[`t',1]
*		forvalue j=1/5{
		foreach j in 25 26 {
		scalar r_menaho=MENAHO[`t',`j']
		display "`year'" " " r_enaho " " r_menaho
		local mod=r_enaho
		local i=r_menaho
		display "`i'" " " "`year'" " " "`mod'"
		cap copy http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/`mod'-Modulo`i'.zip enaho_`year'_mod_`i'.zip 
		cap unzipfile enaho_`year'_mod_`i'.zip, replace
		cap erase enaho_`year'_mod_`i'.zip
		}		

		}

		
*Colocar data on files 		
global ubicacion "D:\Dropbox\EducatePeru\Indicadores\S1\Data" 

forvalue i =19/19{
local year=2000
local year=`year' + `i'

cd "$ubicacion"
cap mkdir `year'
cd `year'
global Inicial "D:\Dropbox\EducatePeru\Indicadores\S1\Data\\`year'\Inicial"
cap mkdir "$Inicial"
cd "Download"

		foreach j in 100 300 400 500{
		foreach mod in 687 {
		foreach i in 1 3 4 5 34 {
		display "`i'" " " "`year'" " " "`mod'"
		
		cap copy "`mod'-Modulo0`i'\\enaho01a-`year'-`j'.dta" "enaho01a-`year'-`j'.dta"
		cap copy "`mod'-Modulo0`i'\\enaho01-`year'-`j'.dta" "enaho01-`year'-`j'.dta"
		cap copy "`mod'-Modulo`i'\\sumaria-`year'.dta" "sumaria-`year'.dta"
		
*		use enaho01a-`year'-`j'.dta,replace
*		qui saveold "$Inicial\\enaho01a-`year'-`j'.dta",replace
		
*		use sumaria-`year'.dta,replace
*		qui saveold "$Inicial\\sumaria-`year'.dta",replace
		}
		}

	}
}
*/
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
* Part 2: calculo de dimensiones de Pobreza Multidimensional
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global data "D:\Dropbox\EducatePeru\Indicadores\S1\Data\2019\Download" 
global clean "D:\Dropbox\EducatePeru\Indicadores\S1\Data\2019\Inicial" 

gl llave "conglome vivienda hogar"


*Educacion
*************************
u "$data/enaho01a-2019-300",clear
*Jefe de hogar
*Escolaridad del jefe del hogar
*g educ_p=(p301a>=1 & p301a<=4  ) & !missing(p301a)
g escol_j=(p203==1 & p301a<=4 & p204==1 ) & !missing(p203, p301a, p204)

*Matriculado
g matri_esc=0
replace matri_esc=1 if (p208a>6 & p208a<=18) & p306==2 & p301a<=5

collapse (sum) escol_j matri_esc, by($llave factor07)
replace matri_esc=1 if matri_esc>1
*replace escol_j=1 if escol_j>1

keep $llave matri_esc escol_j factor07
order $llave matri_esc escol_j factor07
saveold "$clean/bd_multi_educ.dta",replace

*Empleo
*************************
u "$data/enaho01a-2019-500.dta",clear

g deso=(ocu500>=2 & ocu500<=3)

collapse (sum) deso [iw=fac500a], by($llave  )
replace deso=1 if deso>1
duplicates report $llave
keep $llave deso 
order $llave deso 
saveold "$clean/bd_multi_emp.dta",replace

*Salud
*************************
u "$data/enaho01a-2019-400.dta",clear
*Jefe de hogar
*keep if p204==1

*Asistencia 
g malestar =p4021 +p4022 + p4023 +p4024
recode malestar (mis=0)
replace malestar =1 if malestar>=1

*Razones por la que no acudio al centro de salud
recode p4091 p4092 p4097 (mis=0)
g razones = p4091 + p4092 + p4097
replace razones =1 if razones>1

g salud=(razones==1 & malestar==1)

*Presente alguna enfermedad
g enfermedad=(p401==1)

*Seguro de salud (no cuenta)
g seguro=(p4191==2 | p4192==2 | p4193==2 | p4194==2 | p4195==2 | p4196==2 | p4197==2 | p4198==2)
*g seguro=(p4191==1 | p4192==1 )
g noseguro=(seguro==0)

collapse (sum) salud enfermedad seguro noseguro, by($llave factor07)
replace salud=1 if salud>1
replace seguro=1 if seguro>1

replace enfermedad=1 if enfermedad>1
replace noseguro=1 if noseguro>1

keep $llave salud enfermedad noseguro seguro  factor07
order $llave salud enfermedad noseguro seguro factor07
saveold "$clean/bd_multi_salud.dta",replace

*Vivienda
******************************
u "$data/enaho01-2019-100.dta",clear
*Solo completa y mitad completa
keep if result==1 | result==2

*TICs
g tics=(p1141!=1 | p1142!=2 | p1144!=1)

*Piso
*g piso=(p103==7 | p103==6 | p103==.)
g piso=(p103==7 | p103==6 )

*Paredes
g pared=(p102!=1)

*No electricidad
g luz=(p1123==1 | p1124==1 | p1125==1 | p1126==1)

*techo (no concreto)
g techo=(p103a!=1)

*Sin agua
g aguap=(p110>=4 & p110<=7)

*No Desague
g sanea=(p111!=1)

g servicio1=(aguap==1 | sanea==1)

*Carbon o lena
g combus=(p113a==5 | p113a==6 | p113a==7 | p113a==.)

*Energia
g energia=(combus==1 | luz==1)

*Material
g material=(techo==1 | piso==1 | pared==1)

*Hacinamiento
g idhogar=conglome + vivienda + hogar + vivienda
bysort idhogar: g tamhog= _N
g hab=p104
g hacina=(tamhog/hab)>3

*Tenencia
g tenencia=(p105a==1)

gl Xs "tics luz aguap sanea piso combus energia tics techo material tenencia hacina servicio1"

keep $llave $Xs
order $llave $Xs 
saveold "$clean/bd_multi_cv.dta",replace

*Sumaria
*************************
u "$data/sumaria-2019",clear

g exp=gashog2d/12/mieperho
g pond=factor07*mieperho
g pobre=(pobreza<=2)

keep $llave exp pobre pond estrato factor07 ubigeo dominio
order $llave exp pobre pond estrato factor07 ubigeo dominio

saveold "$clean/bd_multi_sumaria.dta",replace

*+++++++++++++++++++++++++++++++++++++++++++
* Union de base de datos
*+++++++++++++++++++++++++++++++++++++++++++

u "$clean/bd_multi_sumaria.dta",clear
foreach q in salud cv educ emp{
merge 1:1  $llave using "$clean/bd_multi_`q'.dta" ,keep(match) nogen
}

*Persona por persona se le asigna los valores, cada valor 1 o 0 se pondera por el peso
*pesos
g peso1=1/5
g peso2=1/15
g peso3=1/10

g w1=1/6
g w2=1/6
g w3=1/15

*Clausen
*1. vivienda
g pond_material=material*peso2
g pond_tenencia=tenencia*peso2
g pond_hacina=hacina*peso2
*2. Servicios basicos
g pond_servicio1=servicio1*peso2
g pond_energia=energia*peso2
g pond_tics=tics*peso2
*3. Empleo
g pond_deso=deso*peso1
*4. Salud
*g pond_seguro=seguro/6
g pond_seguro=seguro*peso1
*5. Educacion
g pond_matri_esc=matri_esc*peso3 
g pond_escol_j=escol_j*peso3

*Forma IPE
*1. Educacion
g w_matri_esc=matri_esc*w1 
g w_escol_j=escol_j*w1
*2. Salud
g w_salud=salud*w2
*3. Servicios
g w_luz=luz*w3
g w_aguap=aguap*w3
g w_sanea=sanea*w3
g w_piso=piso*w3
g w_combus=combus*w3

g pm =pond_matri_esc + pond_escol_j + pond_deso + pond_material + pond_hacina + pond_tenencia + pond_seguro
label var pm "Indice de pobreza multidimensional"

g pm_a= w_matri_esc + w_escol_j + w_salud + w_luz + w_aguap + w_sanea + w_piso + w_combus
label var pm_a "Indice de pobreza multidimensional"

*Si el IPM es mayor a 0.33/ 0.39, la persona se considera pobre multidimensional
g h_pm=(pm>0.33)
*g h_pm=(pm>0.39)
g h_pma=(pm_a>0.33)

label var h_pm "Indicador de pobre y no pobre multidimensional"
label define h_pm 1 "pobre multidimensional" 0 "no pobre multidimensional"
label values h_pm h_pm

label var h_pma "Indicador de pobre y no pobre multidimensional"
label define h_pma 1 "pobre multidimensional" 0 "no pobre multidimensional"
label values h_pma h_pma


tab h_pm [iw=pond]
tab h_pma [iw=pond]

tab pobre [iw=pond]

saveold "$clean/ipm_2019.dta",replace

u "$clean/ipm_2019.dta",clear

gl Dofile "D:\Dropbox\EducatePeru\Indicadores\Codigo"
do "$Dofile/1.- sDpto y sDpto2.do"
do "$Dofile/2.- sArea.do"


tab rArea h_pm [iw=pond], row nofreq
tab rDpto h_pm [iw=pond], row nofreq 

svyset conglome [pw=factor07], strata(estrato)
svy: tab h_pm
svy: tab pobre


*Graficos de la Pobreza
*Barras
preserve
collapse (mean) h_pm pobre [iw=pond], by(rDpto)
graph hbar (mean) h_pm pobre , over(rDpto, sort(1))
restore

*Mapas
*Base de datos de pobreza monetaria y multi

g FIRST_IDDP=rDpto
tostring FIRST_IDDP,replace
replace FIRST_IDDP="0"+ FIRST_IDDP if length(FIRST_IDDP)==1

collapse (mean) h_pm pobre [iw=pond], by(rDpto FIRST_IDDP)

saveold "$clean/Pobreza_2019.dta",replace

*direccion de mapa
glo mapa1	"D:\Dropbox/Mapas/Departamento_2020"		// Latitud y longitud
cd "$clean"
spshape2dta "$mapa1/Dpto_gs_2020.shp" , saving(Shape_dpto) replace

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
saveold "$clean/shape_dpto_c.dta",replace
restore

u Shape_dpto,clear
d
merge m:1 FIRST_IDDP using "$clean/Pobreza_2019.dta", nogen
label var pobre "pobreza monetaria"
label var h_pm "pobreza multidimiensional"

spset
spset, modify coordsys(latlong)
spset, modify coordsys( latlong, kilometers)

saveold "$clean/pobreza_mapa_2019.dta",replace


*Mapa 1: pobreza monetaria
replace pobre=pobre*100
replace pobre=round(pobre,2)
spmap pobre using "Shape_dpto_shp.dta", id(_ID) clnumber(5) fcolor(Reds) title("Perú 2019: Pobreza Monetaria" , size(*0.7)) legstyle(2) legjunction(" - ") subtitle("(Porcentaje %)" , size(*0.7)) note("") label( data(shape_dpto_c) x(_CX) y(_CY) label(nombre) color(gs8) size(*0.6) position(5) length(30)) legend(title("Tasa (%)", size(*0.7) bexpand justification(left)))
graph export "$Imagen/Pobreza_monetaria.png",replace


*Mapa 2: pobreza multidimensional
replace h_pm=h_pm*100
replace h_pm=round(h_pm,2)
spmap h_pm using "Shape_dpto_shp.dta", id(_ID) clnumber(5) fcolor(Reds) title("Perú 2019: Pobreza Multidimensional" , size(*0.7)) legstyle(2) legjunction(" - ") subtitle("(Porcentaje %)" , size(*0.7)) note("") label( data(shape_dpto_c) x(_CX) y(_CY) label(nombre) color(gs8) size(*0.6) position(5) length(30)) legend(title("Tasa (%)", size(*0.7) bexpand justification(left)))
graph export "$Imagen/Pobreza_multi.png",replace






		