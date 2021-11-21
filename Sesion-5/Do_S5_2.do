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

glo clean	"${path}/EducatePeru/Indicadores/S5/Data"
glo dofile	"${main}/Dofiles" 	//codigos
*********************************************************

*************************************************
*PARTE I
*************************************************
*1. Proceso de generacion de variables
*1.1. Variable de empresas
***************************************************
forvalue i =14/18{
	local year=2000
	local year=`year' + `i'

	cd "$ubicacion"
	cap mkdir `year'
	cd `year'
	local TIME=`year'-1
	global Variables "${main}\\`year'\Variables"
	cap mkdir "$Variables"
	global Data "${main}\Data"
	cap mkdir "$Data"	
	cd "Inicial"

	*************************************************
	*Empresas ubicacion geográfica
	*************************************************
	
	use "a`TIME'_CAP_01.dta" ,clear
*	Variables de identificacion de empresas
	do "${dofile}\Do_FirmsUbigeo.do"	
	
	g Ano=`TIME'
	keep iruc Ano ubigeo NroEstablec Fecha CodSector CodFormato
	g Edad=`TIME'-Fecha	
	order iruc Ano ubigeo Fecha CodSector CodFormato NroEstablec
	saveold "$Variables\FirmsUbigeo_`TIME'.dta",replace
	saveold "${clean}\FirmsUbigeo_`TIME'.dta",replace
	
	*************************************************
	*Estado de Resultados (ER)
	*************************************************
	
	foreach q in s14_fU_c03_1{
	
	local allfiles : dir "." files "*_`q'.dta" 
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}	

	*Variables de Estado de resultados
	do "${dofile}\Do_ER_D2_2013_2018.do"	
	
	g Ano=`TIME'
	rename IRUC iruc
	keep iruc Ano L1 OOPE PT MP VA  VTA1 VTA2 VTA3 CI STAFF PROFIT PROFIT2 PROFIT3 CW COP1 COP2 COP3 COP4 COP5 CL1 CL2 CL3 CodSector CodFormato
	collapse (sum) L1 OOPE PT MP VA  VTA1 VTA2 VTA3 CI STAFF PROFIT PROFIT2 PROFIT3 CW COP1 COP2 COP3 COP4 COP5 CL1 CL2 CL3, by(Ano CodSector CodFormato iruc)		
	saveold "$Variables\ER_03_`q'_`TIME'.dta",replace
	*Se guarda como ER 03 ,sin embargo existen casos en donde no se tiene solo ER 03, existen tb sub casos  (otros sectores)
	saveold "${clean}\ER_`TIME'.dta",replace
	
	}
	
	*************************************************
	*Inficadores Financieros (IF)
	*************************************************
	
	foreach q in s14_fU_c02_1{
	
	local allfiles : dir "." files "*_`q'.dta" 
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}	

	*Variables de Estado de resultados
	do "${dofile}\Do_FI_2013_2019.do"
	g Ano=`TIME'
	rename IRUC iruc
	keep iruc Ano Asset1 Asset2 Asset3 Asset4 Asset5 Asset6 Asset7 CodSector CodFormato
	collapse (sum) Asset1 Asset2 Asset3 Asset4 Asset5 Asset6 Asset7 , by(Ano CodSector CodFormato iruc)
	saveold "$Variables\Asset_02_`q'_`TIME'.dta",replace	
	*Se guarda como Asset 02 ,sin embargo existen casos en donde no se tiene solo Asset 02, existen tb sub casos (otros sectores)
	saveold "${clean}\Asset_`TIME'.dta",replace	
		}
	}
	

*2019
*------------------------------------------
forvalue i =19/19{
	local year=2000
	local year=`year' + `i'

	cd "$ubicacion"
	cap mkdir `year'
	cd `year'
	local TIME=`year'-1
	global Variables "${main}\\`year'\Variables"
	cap mkdir "$Variables"
	global Data "${main}\Data"
	cap mkdir "$Data"	
	cd "Inicial"

	*************************************************
	*Empresas ubicacion geográfica
	*************************************************
	
	use "a`TIME'_CAP_01.dta" ,clear
*	Variables de identificacion de empresas
	do "${dofile}\Do_FirmsUbigeo.do"	
	
	g Ano=`TIME'
	keep iruc Ano ubigeo NroEstablec Fecha CodSector CodFormato
	g Edad=`TIME'-Fecha	
	order iruc Ano ubigeo Fecha CodSector CodFormato NroEstablec
	saveold "$Variables\FirmsUbigeo_`TIME'.dta",replace
	saveold "${clean}\FirmsUbigeo_`TIME'.dta",replace
	
	*************************************************
	*Estado de Resultados (ER)
	*************************************************
	
	foreach q in s14_fU_c03_1{
	
	local allfiles : dir "." files "*_`q'.dta" 
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}	

	*Variables de Estado de resultados
	do "${dofile}\Do_ER_D2_2019.do"	
	
	g Ano=`TIME'
	rename IRUC iruc
	keep iruc Ano L1 OOPE PT MP VA  VTA1 VTA2 VTA3 CI STAFF PROFIT PROFIT2 PROFIT3 CW COP1 COP2 COP3 COP4 COP5 CL1 CL2 CL3 CodSector CodFormato
	collapse (sum) L1 OOPE PT MP VA  VTA1 VTA2 VTA3 CI STAFF PROFIT PROFIT2 PROFIT3 CW COP1 COP2 COP3 COP4 COP5 CL1 CL2 CL3, by(Ano CodSector CodFormato iruc)		
	saveold "$Variables\ER_03_`q'_`TIME'.dta",replace
	*Se guarda como ER 03 ,sin embargo existen casos en donde no se tiene solo ER 03, existen tb sub casos  (otros sectores)
	saveold "${clean}\ER_`TIME'.dta",replace
	
		}
	*************************************************
	*Inficadores Financieros (IF)
	*************************************************
	
	foreach q in s14_fU_c02_1{
	
	local allfiles : dir "." files "*_`q'.dta" 
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}	

	*Variables de Estado de resultados
	do "${dofile}\Do_FI_2013_2019.do"
	g Ano=`TIME'
	rename IRUC iruc
	keep iruc Ano Asset1 Asset2 Asset3 Asset4 Asset5 Asset6 Asset7 CodSector CodFormato
	collapse (sum) Asset1 Asset2 Asset3 Asset4 Asset5 Asset6 Asset7 , by(Ano CodSector CodFormato iruc)
	saveold "$Variables\Asset_02_`q'_`TIME'.dta",replace	
	*Se guarda como Asset 02 ,sin embargo existen casos en donde no se tiene solo Asset 02, existen tb sub casos (otros sectores)
	saveold "${clean}\Asset_`TIME'.dta",replace	
		}
		
	}
	

*************************************************
*PARTE II
*************************************************
*2. Proceso de collapsar las variables
*2.1. Estado de resultados e Indicadores financieros y empresas
***************************************************

cd "${clean}"

*------------------------------------------------------------
* ESTADOS DE RESULTADOS	
*------------------------------------------------------------
	local allfiles : dir "." files "ER_*.dta"  
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}
	
	saveold "${clean}//ER.dta",replace

*BORRAR LAS BASES PREVIAS	
	forvalue i =14/19{
		local year=2000
		local year=`year' + `i'
		local TIME=`year'-1
		erase "${clean}//ER_`TIME'.dta"
}	
	
*------------------------------------------------------------
* ASSET + PATRIMONIO + ACTIVO
*------------------------------------------------------------
	local allfiles : dir "." files "Asset_*.dta"  
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}
	
	
	saveold "${clean}/Asset.dta",replace

*BORRAR LAS BASES PREVIAS	
	forvalue i =14/19{
		local year=2000
		local year=`year' + `i'
		local TIME=`year'-1
		erase "${clean}/Asset_`TIME'.dta"
}

*------------------------------------------------------------
* EMPRESAS (CIIU, UBIGEO)
*------------------------------------------------------------	
	local allfiles : dir "." files "FirmsUbigeo_*.dta"  
	tempfile temporal
	clear   
	save `temporal', emptyok
	foreach f of local allfiles {
		append using "`f'", force
		save `temporal', replace
	}
	duplicates report iruc Ano	
	
	saveold "${clean}//FirmsUbigeo.dta",replace

*BORRAR LAS BASES PREVIAS	
	forvalue i =14/19{
		local year=2000
		local year=`year' + `i'
		local TIME=`year'-1
		erase "${clean}//FirmsUbigeo_`TIME'.dta"

	}
	
