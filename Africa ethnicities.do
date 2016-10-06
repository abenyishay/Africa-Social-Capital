bys country: egen freq_ieg = count(count_ieg)

reg mean_ieg dist_coast count_no i.country_num, cluster(country_num)

reg mean_ieg dist_coast count_no i.country_num if (freq_ieg>=5), cluster(country_num)

ge all_ieg_sat = (mean_ieg==1) if mean_ieg!=.
ge quarter_ieg_unsat = (mean_ieg<=0.25) if mean_ieg!=.
ge count_norm = count/area_km

* just a diff at 0 distance?
xtile dist_coast_dec = dist_coast, nq(10)

reg all_ieg dist_coast count_no i.country_num if (freq_ieg>=5), cluster(country_num)

reg quarter_ieg_unsat dist_coast count_no i.country_num if (freq_ieg>=5), cluster(country_num)
reg quarter_ieg_unsat dist_coast i.country_num  if (freq_ieg>=5), cluster(country_num)

reg mean_ieg i.country_num
predict r_mean_ieg, r

reg dist_coast i.country_num
predict r_dist_coast, r

lpoly r_mean_ieg r_dist_coast if (freq_ieg>=5)

sc r_mean_ieg r_dist_coast if (freq_ieg>=5) ||  lfitci r_mean_ieg r_dist_coast if (freq_ieg>=5) 

sc r_mean_ieg r_dist_coast if (freq_ieg>=5) & (r_dist_coast>-500) ||  lfit r_mean_ieg r_dist_coast if (freq_ieg>=5) & (r_dist_coast>-500) 

cap drop ln_dist_coast
ge ln_dist_coast = ln(dist_coast)
reg ln_dist_coast i.country_num
predict r_ln_dist_coast, r

sc r_mean_ieg r_ln_dist_coast if (freq_ieg>=5) & (r_dist_coast>-500) ||  lfit r_mean_ieg r_ln_dist_coast if (freq_ieg>=5) & (r_dist_coast>-500) 

reg mean_ieg ln_dist_coast i.country_num, cluster(country_num)

reg mean_ieg dist_coast count_no area_km centroid* i.country_num if (freq_ieg>=5), cluster(country_num)

reg mean_ieg dist_coast count_ieg area_km centroid* i.country_num if (freq_ieg>=5), cluster(country_num)

reg mean_ieg i.country_num count_ieg area_km centroid* 
predict r_mean_ieg_2, r

reg dist_coast i.country_num count_ieg area_km centroid* 
predict r_dist_coast_2, r

sc r_mean_ieg_2 r_dist_coast_2 if (freq_ieg>=5) ||  lfit r_mean_ieg_2 r_dist_coast_2 if (freq_ieg>=5) , ///
	ytitle("Share of projects with at least satisfactory rating" "(residualized on country FE, ethnicity area, project counts, and lat)") ///
	xtitle(Distance to coast (residualized on country FE, ethnicity area, project counts, and lat))

sc mean_ieg dist_coast if (freq_ieg>=10) || lfit mean_ieg dist_coast if (freq_ieg>=10), by(country)

reg mean_ieg i.dist_coast_dec i.country_num if count_eth >=10, cluster(country_num)
margins, over(dist_coast_dec)
marginsplot


_________________________________________________________________________________________________

* Project counts

sc count_norm dist_coast  || lfit count_norm dist_coast , by(country)

bys country: egen count_eth = count(name_code)

sc count_norm dist_coast if count_eth >=10, by(country)

sc count_norm dist_coast if count_eth >=10

reg count_norm dist_coast i.country_num if count_eth >=10, cluster(country_num)


* Just FEs
reg count_norm i.dist_coast_dec i.country_num if count_eth >=10, cluster(country_num)
margins, over(dist_coast_dec)
marginsplot

test 2.dist_coast_dec = 10.dist_coast_dec


* Adding size and lat
reg count_norm i.dist_coast_dec area_km centroid* i.country_num if count_eth >=10, cluster(country_num)
margins, over(dist_coast_dec)
marginsplot


* $ with Just FEs
reg sum_even_split_norm i.dist_coast_dec i.country_num if count_eth >=10, cluster(country_num)
margins, over(dist_coast_dec)
marginsplot

test 2.dist_coast_dec = 10.dist_coast_dec


sc count_norm dist_coast if count_eth >=10 & nunn_lat!=.


