*==============================================================================
*		
*		Institucion	:	Educate Peru
*		Autor		:	Edinson Tolentino
*		Clase		:	Macros	
*=============================================================================

local conteo=1


gl ruta "D:\Dropbox\EducatePeru\Indicadores"


*		En esta sección manipulamos macros globales y locales
*==============================================================================
*       1. LOCAL
*==============================================================================

local problema "2+2"
display "`problema'"

local problema 2+2
display "`problema'"

local problema 2+2
display `problema'
		
sysuse auto
local x: type mpg
display "`x'"

local y: value label foreign
display "`y'"		


*==============================================================================
*       2. GLOBAL
*==============================================================================

global data "sysuse auto, clear"
$data
summarize price, detail 
gl low = r(p5) 
gl high = r(p95)
display $low
display $high

*==============================================================================
*       3. FORVALUES
*==============================================================================
*       forvalues lname = range {
*               commands referring to `lname'
*       }
*---------------------------------------
		forvalues i = 1(1)5 {
			   display `i'
		}
		
		forvalues i = 10(-1)5 {
			   display `i'
		}	
		
		forvalues i = 1/10 {
			   display `i'
		}

		clear
		set obs 100
        forvalues i = 1(1)20 {
               generate x`i' = runiform()
			   qui hist x`i'
        }
		

*==============================================================================
*       4. FOREACH
*==============================================================================
*       foreach lname in any_list {
*		}
*-----------------------------------

		foreach n in 1 2 3 4 5 6 {
                display `n'
        }	
		
		foreach n in "1 2 3 4 5 6" {
                display `n'
        }			
		
        foreach marca in "Carolina Herrera" "Victoria Secret" "Cristina Ricci" {
                display length("`marca'") " caracteres de largo -- `marca'"
        }	
		
*==============================================================================
*       5. WHILE
*==============================================================================
*		while exp {
*				stata commands
*		}
*------------------------------------	
		local i = 100
		while `i'>0 {
				display "i es ahora `i'"
				local i = `i' - 1
		}
		display "OK"		
		
		sysuse auto, clear
		local i = 1
		while `i' <=5 {
			  tab1 mpg price if rep78 == `i'
			  local i = `i' + 1
		}		