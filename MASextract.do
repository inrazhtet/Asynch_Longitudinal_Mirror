cd "/Users/mscott/Dropbox/Media & Weight Analyses"
use "belle deidentified media wt trajetories  appended data w birth data long format v2.dta"
keep ID_  agezwtmos2 zBMI 
keep if zBMI !=.
rename agezwtmos2 AgeMos
saveold "MASextract1.dta", replace
use "belle data 8-22-14 updated 9-3-14 for media and confounders long format.dta", clear
gen sqrtmediatimespent = sqrt(mediatimespent)
keep ID_ AgeMos lnmediatimespent sqrtmediatimespent
keep if lnmediatimespent !=.
saveold "MASextract2.dta", replace
