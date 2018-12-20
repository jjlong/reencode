*! version 1.0.0 Joe Long 18dec2018
program reencode, rclass
	syntax [varlist], [LAbels VARiables] [encoding(string)]
	if "`encoding'" == "" {
		loc encoding "GBK"
	}
	if "`labels'" != "" {
		qui {
			preserve
			keep if _n == 1
			foreach var of varlist _all {
				tostring `var', replace force
				replace `var' = "`:var la `var''"
			}
			tempfile blah
			qui export delim `blah'
			qui import delim `blah', encoding("`encoding'") clear varnames(1)
			foreach var of varlist _all {
				loc `var'_la "`=`var'[1]'"
			}
			restore
			foreach var of varlist _all {
				la var `var' "``var'_la'"
			}
		}
		di as text "all variable labels converted to `encoding'"

	}
	if "`variables'" != "" {
		qui {
			tempvar id
			gen `id' = _n
			preserve
			keep `id' `varlist'
			tempfile blah blah2
			qui export delim `blah'
			qui import delim `blah', encoding("`encoding'") clear varnames(1)
			foreach var of varlist `varlist' {
				rename `var' `var'_fixed
			}
			save `blah2'
			restore
			merge 1:1 `id' using `blah2', nogen
			foreach var of varlist `varlist' {
				replace `var' = `var'_fixed
			}	
		}
		di as text "variable(s) converted to `encoding'"
	}
end
