
/*
This session is based on two simulated data sets, posted on Chalk.

AGENDA:
1) Examining a new data set in Stata
	1a) Creating indicator & interaction variables
2) Estimating causal effects from clean experimental data
	2a) Interpreting regression coefficients
	2b) Robust standard errors
	2c) Standardized effect sizes
3) Confronting real data
	3a) detecting missing data
	3b) various missing indicators
	3c) using missing indicators
*/


//On the clean data set:
describe
summarize
tab female
tab race
//to see the value label mappings for the race variable
tab race, nol
labelbook race // zero missing
codebook race


sum preTest
sum preTest, detail //detailed distribution

sum postTest
sum postTest,d

//analyze preTest scores by subgroups
tabstat preTest, by(female)
tabstat preTest, by(female) stat(mean med N)
tabstat preTest, by(race) stat(mean med N)

//associations between postTest score, treatment, and other covariates
//notice the addition of the robust option, which adjusts the standard
//errors for heteroskedasticity and other threats to inference 
//(albeit less efficiently than some other approaches)
reg postTest Z, robust
//consider preTest covariate
//Predict outcome?
reg postTest preTest, robust
//Predict treatment?
logit Z preTest, robust
reg postTest Z preTest, robust //compare std. error 
//consider female covariate
reg postTest female, robust
tab Z female, chi
//consider race covariate
anova postTest race
//Look at the F-test not t-tests
reg postTest i.race, robust
//or
testparm i.race
tab Z race, chi
reg postTest Z preTest female i.race, robust
//Standardized effect size
sum postTest if Z==0
display 33.54666/118.3913 //treatment effect/standard deviation of control group

//create indicator variables for each race
gen hispanic=(race==2)
gen other=(race==3)
//alternately
tab race, gen(r) //r1, r2, r3

//create treatment-gender & treatment-race interaction variables
gen femZ=female*Z
gen hisZ=hispanic*Z
gen othZ=other*Z
reg postTest Z female hispanic other femZ hisZ othZ preTest, robust
//this is the same regression as
reg postTest i.female##Z i.race##Z preTest, robust


//open the missing data set
describe
summarize //Obs Max
	//note all the missing data! And the various ways of coding missing

//female missing was coded using the built-in missing code
//this approach automatically excludes observations with missing female
//from regressions using the variable
tab female
tab female, missing
gen fem_miss=(female==.)
replace female=0 if fem_miss

//race missing was coded to 9. create an indicator for missing
tab race
tab race, nol
gen race_miss=(race==9)

//preTest missing -- create missing indicator and replace missing with mean
sum preTest
sum preTest, d
gen preT_miss=(preTest==9999)
sum preTest if preTest!=9999
replace preTest=r(mean) if preTest==9999

//postTest missing -- drop completely
sum postTest
sum postTest, d
replace postTest=. if postTest==9999  
sum postTest 

reg postTest Z preTest female i.race fem_miss race_miss preT_miss, robust
//compare to
reg postTest Z preTest female i.race, robust

