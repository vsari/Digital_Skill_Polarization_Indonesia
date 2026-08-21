/* Section 5.1: The Low Birth Weight study */
webuse lbw
describe

gen bwt4 = .
replace bwt4 = 1 if bwt > 3500 & bwt != .
replace bwt4 = 2 if bwt <= 3500 & bwt > 3000 & bwt != .
replace bwt4 = 3 if bwt <= 3000 & bwt > 2500 & bwt != .
replace bwt4 = 4 if bwt <= 2500 & bwt != .
tab bwt4

/* Section 5.2: The proportional odds model */
ologit bwt4 smoke lwt i.race ptl, nolog
ologit, or
ologitgof smoke race, tableHL tablePR

ologit bwt4 smoke##c.age##c.age, nolog
ologitgof smoke


/* Section 5.3: The adjacent-category model */
*search adjcatlogit
adjcatlogit bwt4 smoke lwt i.race ptl, or
ologitgof smoke race


/* Section 5.4: The continuation-ratio model */
*search ccrlogit
ccrlogit bwt4 smoke lwt i.race ptl, or
ologitgof smoke race

