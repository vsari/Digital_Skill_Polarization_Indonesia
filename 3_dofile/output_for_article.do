webuse lbw.dta, clear

/* ---------------------------------- */
/* Section 2: Introducing the example */
/* ---------------------------------- */
sjlog using "ologitgof1", replace
gen bwt4 = .
replace bwt4 = 1 if bwt > 3500 & bwt != .
replace bwt4 = 2 if bwt <= 3500 & bwt > 3000 & bwt != .
replace bwt4 = 3 if bwt <= 3000 & bwt > 2500 & bwt != .
replace bwt4 = 4 if bwt <= 2500 & bwt != .
tabulate bwt4
sjlog close, replace


/* -------------------------------------- */
/* Section 6: The proportional odds model */
/* -------------------------------------- */

/* Fit the model */
sjlog using "ologitgof2", replace
ologit bwt4 smoke lwt i.race ptl, nolog
sjlog close, replace
sjlog using "ologitgof3", replace
ologit, or
sjlog close, replace

/* Testing goodness of fit */
sjlog using "ologitgof4", replace
ologitgof smoke race, tableHL tablePR
sjlog close, replace

/* An example of lack of fit */
sjlog using "ologitgof5", replace
ologit bwt4 smoke##c.age##c.age, nolog
ologitgof smoke
sjlog close, replace


/* -------------------------------------- */
/* Section 7: The adjacent-category model */
/* -------------------------------------- */
*search adjcatlogit
sjlog using "ologitgof6", replace
adjcatlogit bwt4 smoke lwt i.race ptl, or
sjlog close, replace
sjlog using "ologitgof7", replace
ologitgof smoke race
sjlog close, replace


/* --------------------------------------------------- */
/* Section 8: The constrained continuation-ratio model */
/* --------------------------------------------------- */
*search ccrlogit
sjlog using "ologitgof8", replace
ccrlogit bwt4 smoke lwt i.race ptl, or
sjlog close, replace
sjlog using "ologitgof9", replace
ologitgof smoke race
sjlog close, replace


