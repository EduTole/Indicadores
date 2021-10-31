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
	glo path "D:/Dropbox" // ET
	
}
*Dirección de carpeta de bases ENAHO
glo main "${path}/BASES/ENAHO"

glo clean	"${path}/EducatePeru/Indicadores/S2/clean"		// carpeta del curso
*======================================================

*==================================================
*Paso 1 :
*Carga de la base de datos
*--------------------------------------------
	u "${main}/2020/enaho01a-2020-500.dta", clear

	******  Filtro  ******.
	gen filtro=.
	replace filtro=1 if (((p204==1 & p205==2) | (p204==2 & p206==1)) & p501>0 & p501!=. & p501!=9) & fac500a!=.
	keep if filtro==1
	
	******************************
	******  Variable rDpto  ******
	******************************

	gen rDpto=real(substr(ubigeo,1,2))

	label var rDpto "Departamento"

	label define rDpto /*
	*/ 1 "Amazonas" 2 "Áncash" 3 "Apurímac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Prov Const del Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huánuco" /*
	*/ 11 "Ica" 12 "Junín" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" /* 
	*/ 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"

	label values rDpto rDpto
	
	***************************
	******  Variable R2  ******
	***************************

	gen r2=.
	replace r2=1 if (p301a>=1 & p301a<=2)
	replace r2=2 if (p301a==3)
	replace r2=3 if (p301a==4)
	replace r2=4 if (p301a==5)
	replace r2=5 if (p301a==6)
	replace r2=6 if (p301a==7)
	replace r2=7 if (p301a==8)
	replace r2=8 if (p301a==9)
	replace r2=9 if (p301a>=10 & p301a<=11)
	replace r2=10 if (p301a==12)
	replace r2=11 if p301a==.

	label var r2 "Nivel educativo alcanzado"

	label define r2 1 "Sin nivel educativo" 2 "Primaria incompleta" 3 "Primaria completa" 4 "Secundaria incompleta" 5 "Secundaria completa" /*
	*/ 6 "Superior no universitaria incompleta" 7 "Superior no universitaria completa" 8 "Superior universitaria incompleta" /*
	*/ 9 "Superior universitaria completa" 10 "Básica especial" 11 "No especificado"

	label values r2 r2	
	
	***************************
	******  Variable R3  ******
	***************************
	g r3=.
	replace r3=1 if ocu500==1
	replace r3=2 if ocu500>1 & ocu500<=3
	replace r3=3 if ocu500>3
	label var r3 "Condición de actividad" 
	label define r3 1 "Ocupado" 2 "Desocupado" 3 "Inactivo"
	label values r3 r3	

	*************************** 
	******  Variable R4  ******
	***************************

	gen r4=.
	replace r4=1 if (r3==1 & ((p505>=11 & p505<=15) | (p505>=21 & p505<=24) | p505==136 | (p505>=211 & p505<=219) | (p505>=221 & p505<=229)))
	replace r4=1 if (r3==1 & ((p505>=231 & p505<=239) | (p505>=241 & p505<=247) | (p505>=251 & p505<=259) | (p505>=261 & p505<=269)))
	replace r4=1 if (r3==1 & ((p505>=271 & p505<=274) | p505==281 | p505==282 | p505==284 | (p505>=311 & p505<=319) | (p505>=321 & p505<=324)))
	replace r4=1 if (r3==1 & ((p505>=341 & p505<=349) | (p505>=351 & p505<=356) | (p505>=363 & p505<=367) | p505==377 | p505==383))
	replace r4=1 if (r3==1 & ((p505>=391 & p505<=393) | p505==395 | p505==396 | p505==531))

	replace r4=2 if (r3==1 & ((p505>=111 & p505<=116) | (p505>=121 & p505<=129) | (p505>=131 & p505<=135) | (p505>=137 & p505<=139)))
	replace r4=2 if (r3==1 & ((p505>=141 & p505<=148) | p505==283))

	replace r4=3 if (r3==1 & (p505==334 | (p505>=381 & p505<=382) | (p505>=411 & p505<=419) | (p505>=421 & p505<=423) | (p505>=431 & p505<=436)))
	replace r4=3 if (r3==1 & ((p505>=441 & p505<=444) | p505==451 | (p505>=453 & p505<=455) | p505==461 | p505==462 | p505==931))

	replace r4=4 if (r3==1 & ((p505>=361 & p505<=362) | (p505>=371 & p505<=376) | (p505>=378 & p505<=379) | p505==452 | (p505>=571 & p505<=575)))
	replace r4=4 if (r3==1 & ((p505>=581 & p505<=583) | (p505>=911 & p505<=919) | (p505>=921 & p505<=927)))

	replace r4=5 if (r3==1 & ((p505>=611 & p505<=617) | (p505>=621 & p505<=626) | (p505>=631 & p505<=637) | p505==641 | p505==872 | (p505>=971 & p505<=973)))

	replace r4=6 if (r3==1 & (p505==711 | p505==712 | p505==735 | p505==981))

	replace r4=7 if (r3==1 & (p505==627 | (p505>=713 & p505<=719) | (p505>=721 & p505<=724) | (p505>=731 & p505<=734) | (p505>=736 & p505<=737)))
	replace r4=7 if (r3==1 & ((p505>=741 & p505<=749) | (p505>=751 & p505<=752) | (p505>=761 & p505<=769) | (p505>=771 & p505<=779)))
	replace r4=7 if (r3==1 & ((p505>=781 & p505<=785) | (p505>=791 & p505<=799) | (p505>=811 & p505<=813) | p505==821 | (p505>=831 & p505<=837)))
	replace r4=7 if (r3==1 & (p505==839 | (p505>=841 & p505<=844) | (p505>=851 & p505<=852) | (p505>=861 & p505<=867) | p505==871 | p505==873))
	replace r4=7 if (r3==1 & (p505==874 | p505==882 | p505==984))

	replace r4=8 if (r3==1 & (p505==868 | p505==961 | p505==982 | p505==983 | p505==987))

	replace r4=9 if (r3==1 & ((p505>=331 & p505<=333) | (p505>=875 & p505<=877) | p505==881 | (p505>=883 & p505<=886) | (p505>=985 & p505<=986)))

	replace r4=10 if (r3==1 & (p505==335 | p505==394 | p505==456 | (p505>=511 & p505<=512) | (p505>=521 & p505<=523) | p505==541 | (p505>=551 & p505<=553)))
	replace r4=10 if (r3==1 & ((p505>=561 & p505<=565) | (p505>=822 & p505<=823) | (p505>=941 & p505<=945) | (p505>=951 & p505<=953)))

	replace r4=13 if (r3==1 & ((p505==999) | p505==.))

	replace r4=11 if (r3==1 & p507==6)


	replace r4=13 if (r3==1 & (p505==505))

	replace r4=14 if (r3==2 | r3==3)


	label var r4 "Grupo ocupacional (ocup. princ.)" 
	 
	label define r4 1 "Profesional, tecnico" 2 "Gerente, administrador y funcionario" 3 "Empleado de oficina" 4 "Vendedor" /*
	*/ 5 "Agricultor, ganadero y pescador" 6 "Minero y cantero" 7 "Artesano y operario" 8 "Obrero jornalero" 9 "Conductor" /* 
	*/ 10 "Trabajador de los servicios" 11 "Trabajador del hogar" 13 "No especificado" 14 "No ocupado"

	 label values r4 r4	
	
	********************************* 
	******  Variable r5r4mtpe  ******
	*********************************

	gen r5r4mtpe=.
	replace r5r4mtpe=1 if (r3==1 & (p506r4>=100 & p506r4<=399))
	replace r5r4mtpe=2 if (r3==1 & (p506r4>=500 & p506r4<=999))

	replace r5r4mtpe=3 if (r3==1 & (p506r4==1010 | p506r4==1020 | p506r4==1030 | p506r4==1040 | p506r4==1050 | p506r4==1061 | p506r4==1062 /*
	*/ | (p506r4>=1071 & p506r4<=1075) | p506r4==1079 | p506r4==1080 | (p506r4>=1101 & p506r4<=1104) | p506r4==1200 | (p506r4>=1311 & p506r4<=1313) /*
	*/ | (p506r4>=1391 & p506r4<=1394) | p506r4==1399 | p506r4==1410 | p506r4==1420 | p506r4==1430 | p506r4==1512 | p506r4==1520 | p506r4==1629 /*
	*/ | p506r4==1709 | p506r4==1811 | p506r4==1812 | p506r4==2219 | p506r4==2220 | p506r4==2299 | p506r4==2599 | p506r4==2640 | p506r4==2651 /*
	*/ | p506r4==2652 | p506r4==2670 | p506r4==2731 | p506r4==2733 | p506r4==2817 | p506r4==2930 | p506r4==3092 | p506r4==3100 | p506r4==3211 /*
	*/ | p506r4==3212 | p506r4==3220 | p506r4==3230 | p506r4==3240 | p506r4==3250 | p506r4==3290 | p506r4==3319))

	replace r5r4mtpe=4 if (r3==1 & (p506r4==1511 | p506r4==1610 | (p506r4>=1621 & p506r4<=1623) | p506r4==1701 | p506r4==1702 | p506r4==1820 /*
	*/ | p506r4==1910 | p506r4==1920 | (p506r4>=2011 & p506r4<=2013) | (p506r4>=2021 & p506r4<=2023) | p506r4==2029 | p506r4==2030 | p506r4==2100 /*
	*/ | p506r4==2211 | p506r4==2310 | (p506r4>=2391 & p506r4<=2396) | p506r4==2399 | p506r4==2420 | (p506r4>=2431 & p506r4<=2432) | p506r4==2591 /*
	*/ | p506r4==2592 | p506r4==2610 | p506r4==2680 | p506r4==2812))  

	replace r5r4mtpe=5 if (r3==1 & (p506r4==2410 | (p506r4>=2511 & p506r4<=2513) | p506r4==2520 | p506r4==2593 | p506r4==2620 | p506r4==2630 | p506r4==2660 /*
	*/ | p506r4==2710 | p506r4==2720 | p506r4==2732 | p506r4==2740 | p506r4==2750 | p506r4==2790 | p506r4==2811 | (p506r4>=2813 & p506r4<=2816) /*
	*/ | p506r4==2818 | p506r4==2819 | (p506r4>=2821 & p506r4<=2826) | p506r4==2829 | p506r4==2910 | p506r4==2920 | p506r4==2999 | p506r4==3011 /*
	*/ | p506r4==3012 | p506r4==3020 | p506r4==3030 | p506r4==3040 | p506r4==3091 | p506r4==3099 | (p506r4>=3311 & p506r4<=3315) | p506r4==3320))

	replace r5r4mtpe=6 if (r3==1 & (p506r4>=3500 & p506r4<=3999))
	replace r5r4mtpe=7 if (r3==1 & (p506r4>=4100 & p506r4<=4399))
	replace r5r4mtpe=8 if (r3==1 & (p506r4>=4600 & p506r4<=4699))
	replace r5r4mtpe=9 if (r3==1 & ((p506r4>=4500 & p506r4<=4599) | (p506r4>=4700 & p506r4<=4799)))
	replace r5r4mtpe=10 if (r3==1 & (p506r4>=5500 & p506r4<=5699))
	replace r5r4mtpe=11 if (r3==1 & ((p506r4>=4900 & p506r4<=5399) | (p506r4>=5800 & p506r4<=6399)))
	replace r5r4mtpe=12 if (r3==1 & (p506r4>=6400 & p506r4<=8299))
	replace r5r4mtpe=13 if (r3==1 & ((p506r4>=8400 & p506r4<=9499) | (p506r4>=9900 & p506r4<=9999)))
	replace r5r4mtpe=14 if (r3==1 & (p506r4>=9500 & p506r4<=9699))
	replace r5r4mtpe=15 if (r3==1 & (p506r4>=9700 & p506r4<=9799))
	replace r5r4mtpe=16 if (r3==1 & (p506r4==9999 | p506r4==.))
	replace r5r4mtpe=17 if (r3==2 | r3==3)

	label var r5r4mtpe "Rama de actividad económica (ocup. princ., CIIU Rev.4)" 
	 
	label define r5r4mtpe 1 "Agricultura, ganadería, silvicultura y pesca" 2 "Minería" 3 "Industria de bienes de consumo" /*
	*/ 4 "Industria de bienes intermedios" 5 "Industria de bienes de capital" 6 "Electricidad, gas, agua y saneamiento" 7 "Construcción" /*
	*/ 8 "Comercio al por mayor" 9 "Comercio al por menor" 10 "Restaurantes y hoteles" 11 "Transporte, almacenamiento y comunicaciones" /*
	*/ 12 "Establecimientos financieros, seguros, bienes inmuebles y servicios prestados a empresas" 13 "Servicios comunitarios, sociales y recreativos" /*
	*/ 14 "Servicios personales" 15 "Hogares" 16 "No especificado" 17 "No ocupado"

	 label values r5r4mtpe r5r4mtpe	
	 
	********************************** 
	******  Variable r5r4mtpe2  ******
	**********************************

	gen r5r4mtpe2=.
	replace r5r4mtpe2=1 if (r3==1 & (r5r4mtpe==1))
	replace r5r4mtpe2=2 if (r3==1 & (r5r4mtpe==2))
	replace r5r4mtpe2=3 if (r3==1 & (r5r4mtpe==3))
	replace r5r4mtpe2=4 if (r3==1 & (r5r4mtpe>=4 & r5r4mtpe<=5))
	replace r5r4mtpe2=5 if (r3==1 & (r5r4mtpe==7))
	replace r5r4mtpe2=6 if (r3==1 & (r5r4mtpe>=8 & r5r4mtpe<=9))
	replace r5r4mtpe2=7 if (r3==1 & (r5r4mtpe==6 | (r5r4mtpe>=11 & r5r4mtpe<=13)))
	replace r5r4mtpe2=8 if (r3==1 & (r5r4mtpe==10 | r5r4mtpe==14))
	replace r5r4mtpe2=9 if (r3==1 & (r5r4mtpe==15))
	replace r5r4mtpe2=10 if (r3==1 & r5r4mtpe==16)
	replace r5r4mtpe2=11 if (r3==2 | r3==3)

	label var r5r4mtpe2 "Rama de actividad económica (ocup. princ., CIIU Rev.4)" 
	 
	label define r5r4mtpe2 1 "Agricultura, ganadería, silvicultura y pesca" 2 "Minería" 3 "Industria de bienes de consumo" /*
	*/ 4 "Industria de bienes intermedios y de capital" 5 "Construcción" 6 "Comercio" 7 "Servicios no personales" /*
	*/ 8 "Servicios personales" 9 "Hogares" 10 "No especificado" 11 "No ocupado"

	 label values r5r4mtpe2 r5r4mtpe2
 
	 
	***************************
	******  Variable R6  ******
	***************************

	replace d529t=. if d529t==999999
	replace d536=. if d536==999999
	replace d543=. if d543==999999

	egen r6=rowtotal(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t) if (r3==1)
	replace r6=r6/12 if (r3==1)
	replace r6=0 if (r3==1 & r6==.)

	label var r6 "Ingreso laboral mensual (ocup. princ. y secun.)" 
	
	*******************************
	******  Variable R6PRIN  ******
	*******************************

	replace d529t=. if d529t==999999
	replace d536=. if d536==999999

	egen r6prin=rowtotal(i524a1 d529t i530a d536) if (r3==1)
	replace r6prin=r6prin/12 if (r3==1)
	replace r6prin=0 if (r3==1 & r6prin==.)

	label var r6prin "Ingreso laboral mensual (ocup. princ.)" 

	***************************
	******  Variable r8  ******
	***************************

	gen r8=.
	replace r8=1 if (r3==1 & p507==1)
	replace r8=2 if (r3==1 & p507==3 & p510>=3 & p510<=7)
	replace r8=3 if (r3==1 & p507==3 & p510>=1 & p510<=2)
	replace r8=4 if (r3==1 & p507==4 & p510>=3 & p510<=7)
	replace r8=5 if (r3==1 & p507==4 & p510>1 & p510<=2)
	replace r8=6 if (r3==1 & p507==2)
	replace r8=7 if (r3==1 & (p507==5 | p507==7))
	replace r8=8 if (r3==1 & p507==6)
	replace r8=10 if (r3==1 & p507==.)
	replace r8=11 if (r3==2 | r3==3)

	label var r8 "Categoria ocupacional (ocup. princ.)" 

	label define r8 1 "Empleador" 2 "Empleado privado" 3 "Empleado publico" 4 "Obrero privado" 5 "Obrero publico" 6 "Independiente" /*
	*/ 7 "Trabajador familiar no remunerado" 8 "Trabajador del hogar" 10 "No especificado" 11 "No ocupado"

	label values r8 r8
	
	****************************
	******  Variable r11  ******
	****************************

	egen r11=rowtotal(i513t i518) if (r3==1 & p519==1)
	replace r11=i520 if (r3==1 & p519==2)

	label var r11 "Horas normales semanales (ocup. princ. y ocup. secun.)"
 	
	*Codigo de persona
	egen codigo_id=concat(conglome vivienda hogar codperso)
	
	****************************
	* Ordenar variables generadas
	****************************
	
	keep codigo_id r* fac500a 
	drop r559_01-r559_50
	order codigo_id r* fac500a 
	cls
	d
	saveold "${clean}//BD_Empleo_2020.dta",replace
	
	
	
	
	