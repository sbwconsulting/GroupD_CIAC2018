library(data.table)
strat.ratio.estimator <- function(data=dt_ciac_proj,frame='Electric',period='1stYear',conf=0.9,return_strat=FALSE,return_PA=FALSE,return_SW=FALSE){
  data <- copy(data[(get(paste0('Frame_',frame)))])
  svgs_field <- 'Ann'
  if(period!='1stYear') svgs_field <- 'LC'

  t <- 1.645
  
  ## set up stratum level summaries for Levy & Lemeshow (L&L) approach----
    
  ## kWh stratum level summary (electric frame)----
  ifelse(frame=='Electric',{
    ea_gr_kW_field <- paste0('ea_',svgs_field,'Gross_','kW')
    ep_gr_kW_field <- paste0('ep_',svgs_field,'Gross_','kW')

    strat_smry <- data[sampled_kWh=='Y' &  nchar(GrossCompl)>0,.(n_cmplt=length(SBW_ProjID)),by=c('PA','domain','stratum_kWh')][
      data[sampled_kWh=='Y',.(n=length(SBW_ProjID),
                mean_ea_gr_kWh=mean(get(paste0(ea_gr_kW_field,'h')),na.rm=T),sd_exante_kWh=sd(get(paste0(ea_gr_kW_field,'h')),na.rm=T),
                mean_eval_kWh=mean(get(paste0(ep_gr_kW_field,'h')),na.rm = T),sd_eval_kWh=sd(get(paste0(ep_gr_kW_field,'h')),na.rm = T),
                cor_hxy_kWh=cor(get(paste0(ea_gr_kW_field,'h')),get(paste0(ep_gr_kW_field,'h')),method = 'pearson'),
                mean_ea_gr_kW=mean(get(ea_gr_kW_field),na.rm=T),sd_exante_kW=sd(get(ea_gr_kW_field),na.rm=T),
                mean_eval_kW=mean(get(ep_gr_kW_field),na.rm = T),sd_eval_kW=sd(get(ep_gr_kW_field),na.rm = T),
                cor_hxy_kW=cor(get(ea_gr_kW_field),get(ep_gr_kW_field),method = 'pearson',use='pairwise.complete.obs'),
                mean_exante_EUL_kWh=sum(get(paste0(ea_gr_kW_field,'h'))*ea_EUL_kWh,na.rm=T)/sum(get(paste0(ea_gr_kW_field,'h')),na.rm=T),
                mean_eval_EUL_kWh=sum(get(paste0(ep_gr_kW_field,'h'))*ep_EUL_kWh,na.rm=T)/sum(get(paste0(ep_gr_kW_field,'h')),na.rm=T)),
           by=c('PA','domain','stratum_kWh')][
             data[stratum_kWh!=8,.(pop=length(SBW_ProjID),str_exante_gross_kWh=sum(get(paste0(ea_gr_kW_field,'h')),na.rm=T),str_exante_gross_kW=sum(get(ea_gr_kW_field),na.rm=T)),by=c('PA','domain','stratum_kWh')],
                  on=c('PA','domain','stratum_kWh')],on=c('PA','domain','stratum_kWh')]
    strat_smry <- strat_smry[data[,.(exante_gross_kWh=sum(get(paste0(ea_gr_kW_field,'h')),na.rm=T),exante_gross_kW=sum(get(ea_gr_kW_field),na.rm=T)),
                                  by=c('PA','domain','stratum_kWh')],on=c('PA','domain','stratum_kWh')][order(PA,domain,stratum_kWh)]
    strat_smry[is.na(n_cmplt),n_cmplt:=0]
    strat_smry[is.na(n),n:=0]

    ## domain summary----
    dom_smry <- strat_smry[,.(dom_n=sum(n,na.rm=T),dom_cmplt=sum(n_cmplt,na.rm=T),
                              dom_mean_ea_gr_kWh=sum(pop*mean_ea_gr_kWh,na.rm=T)/sum(pop,na.rm=T),dom_mean_ea_gr_kW=sum(pop*mean_ea_gr_kW,na.rm = T)/sum(pop,na.rm=T),
                              dom_mean_eval_gr_kWh=sum(pop*mean_eval_kWh,na.rm = T)/sum(pop,na.rm=T),dom_mean_eval_gr_kW=sum(pop*mean_eval_kW,na.rm = T)/sum(pop,na.rm=T),
                              dom_str_exante_gross_kWh=sum(str_exante_gross_kWh,na.rm = T),dom_str_exante_gross_kW=sum(str_exante_gross_kW,na.rm = T),
                              dom_exante_gross_kWh=sum(exante_gross_kWh,na.rm = T),dom_exante_gross_kW=sum(exante_gross_kW,na.rm = T),
                              dom_exante_EUL_kWh=sum(pop*mean_ea_gr_kWh*mean_exante_EUL_kWh,na.rm=T)/sum(pop*mean_ea_gr_kWh,na.rm=T),
                              dom_eval_EUL_kWh=sum(pop*mean_eval_kWh*mean_eval_EUL_kWh,na.rm=T)/sum(pop*mean_eval_kWh,na.rm=T)),
          by=c('PA','domain')]
    dom_smry[,dom_eval_RR_kWh:=dom_mean_eval_gr_kWh/dom_mean_ea_gr_kWh]
    dom_smry[,dom_eval_RR_kW:=dom_mean_eval_gr_kW/dom_mean_ea_gr_kW]
    dom_smry[,dom_eval_EUL_RR_kWh:=dom_eval_EUL_kWh/dom_exante_EUL_kWh]
    
    strat_smry <- dom_smry[strat_smry,on=c('PA','domain')]
    strat_smry[,sd_z2_kWh:=sd_eval_kWh^2+(dom_eval_RR_kWh*sd_exante_kWh)^2-2*dom_eval_RR_kWh*cor_hxy_kWh*sd_exante_kWh*sd_eval_kWh]
    strat_smry[,sd_z2_kW:=sd_eval_kW^2+(dom_eval_RR_kW*sd_exante_kW)^2-2*dom_eval_RR_kW*cor_hxy_kW*sd_exante_kW*sd_eval_kW]
    strat_smry[,var_comb2:=pop^2*(pop-n)/(n*(pop-1))]
    ## zero out stats for strata with pop=1
    strat_smry[pop==1 & n_cmplt>0,(colnames(strat_smry)[grepl('sd_exante|sd_eval|cor_hxy|sd_z2|var_comb2',colnames(strat_smry))]):=0]

    dom_smry <- strat_smry[stratum_kWh!=8,.(dom_pop=sum(pop,na.rm=T),var_comb2_sdz2_kWh=sum(var_comb2*sd_z2_kWh,na.rm = T),
                                       var_comb2_sdz2_kW=sum(var_comb2*sd_z2_kW,na.rm = T)),
                                    by=c('PA','domain')][dom_smry,on=c('PA','domain')]
    dom_smry[,var_comb1_kWh:=1/(dom_str_exante_gross_kWh)^2]
    dom_smry[,var_comb1_kW:=1/(dom_str_exante_gross_kW)^2]
    dom_smry[,var_dom_kWh:=var_comb1_kWh*var_comb2_sdz2_kWh]
    dom_smry[,var_dom_kW:=var_comb1_kW*var_comb2_sdz2_kW]
    dom_smry[,se_dom_eval_RR_kWh:=sqrt(var_dom_kWh)]
    dom_smry[,se_dom_eval_RR_kW:=sqrt(var_dom_kW)]

    dom_smry[,eb_dom_eval_RR_kWh:=t*se_dom_eval_RR_kWh]
    dom_smry[,eb_dom_eval_RR_kW:=t*se_dom_eval_RR_kW]
    ## calculate Relative Precision on RRs----
    dom_smry[,rp_dom_eval_RR_kWh:=eb_dom_eval_RR_kWh/dom_eval_RR_kWh]
    dom_smry[,rp_dom_eval_RR_kW:=eb_dom_eval_RR_kW/dom_eval_RR_kW]
    
    ## calculate domain evaluated savings----
    dom_smry[,dom_eval_gross_svgs_kWh:=dom_eval_RR_kWh*dom_exante_gross_kWh]
    dom_smry[,dom_eval_gross_svgs_kW:=dom_eval_RR_kW*dom_exante_gross_kW]
    dom_smry[,se_svgs_dom_kWh:=se_dom_eval_RR_kWh/dom_eval_RR_kWh*dom_eval_gross_svgs_kWh]
    dom_smry[,se_svgs_dom_kW:=se_dom_eval_RR_kW/dom_eval_RR_kW*dom_eval_gross_svgs_kW]
    dom_smry[,eb_svgs_dom_kWh:=t*se_svgs_dom_kWh]
    dom_smry[,eb_svgs_dom_kW:=t*se_svgs_dom_kW]
    ## calculate Relative Precision on evaluated savings----
    dom_smry[,rp_svgs_dom_kWh:=eb_svgs_dom_kWh/dom_eval_gross_svgs_kWh]
    dom_smry[,rp_svgs_dom_kW:=eb_svgs_dom_kW/dom_eval_gross_svgs_kW]

    ## PA roll up, domains are now strata----
    PA_smry <- dom_smry[,.(PA_pop=sum(dom_pop),PA_n=sum(dom_n,na.rm=T),PA_cmplt=sum(dom_cmplt,na.rm=T),
                              PA_mean_ea_gr_kWh=sum(dom_pop*dom_mean_ea_gr_kWh,na.rm=T)/sum(dom_pop),
                           PA_mean_ea_gr_kW=sum(dom_pop*dom_mean_ea_gr_kW,na.rm = T)/sum(dom_pop),
                              PA_mean_eval_gr_kWh=sum(dom_pop*dom_mean_eval_gr_kWh,na.rm = T)/sum(dom_pop),
                           PA_mean_eval_gr_kW=sum(dom_pop*dom_mean_eval_gr_kW,na.rm = T)/sum(dom_pop),
                              PA_exante_gross_kWh=sum(dom_exante_gross_kWh,na.rm = T),
                           PA_exante_gross_kW=sum(dom_exante_gross_kW,na.rm = T)),
                        by=c('PA')]
    ## PA RRs----
    PA_smry[,PA_eval_RR_kWh:=PA_mean_eval_gr_kWh/PA_mean_ea_gr_kWh]
    PA_smry[,PA_eval_RR_kW:=PA_mean_eval_gr_kW/PA_mean_ea_gr_kW]

    ## calculate PA evaluated savings----
    PA_smry[,PA_eval_gross_svgs_kWh:=PA_eval_RR_kWh*PA_exante_gross_kWh]
    PA_smry[,PA_eval_gross_svgs_kW:=PA_eval_RR_kW*PA_exante_gross_kW]
    
    ## SW roll up, PAs are now strata----
    SW_smry <- PA_smry[,.(SW_pop=sum(PA_pop),SW_n=sum(PA_n,na.rm=T),SW_cmplt=sum(PA_cmplt,na.rm=T),
                           SW_mean_ea_gr_kWh=sum(PA_pop*PA_mean_ea_gr_kWh,na.rm=T)/sum(PA_pop),
                           SW_mean_ea_gr_kW=sum(PA_pop*PA_mean_ea_gr_kW,na.rm = T)/sum(PA_pop),
                           SW_mean_eval_gr_kWh=sum(PA_pop*PA_mean_eval_gr_kWh,na.rm = T)/sum(PA_pop),
                           SW_mean_eval_gr_kW=sum(PA_pop*PA_mean_eval_gr_kW,na.rm = T)/sum(PA_pop),
                           SW_exante_gross_kWh=sum(PA_exante_gross_kWh,na.rm = T),
                           SW_exante_gross_kW=sum(PA_exante_gross_kW,na.rm = T))]
    ## SW RRs----
    SW_smry[,SW_eval_RR_kWh:=SW_mean_eval_gr_kWh/SW_mean_ea_gr_kWh]
    SW_smry[,SW_eval_RR_kW:=SW_mean_eval_gr_kW/SW_mean_ea_gr_kW]
    
    ## calculate PA evaluated savings----
    SW_smry[,SW_eval_gross_svgs_kWh:=SW_eval_RR_kWh*SW_exante_gross_kWh]
    SW_smry[,SW_eval_gross_svgs_kW:=SW_eval_RR_kW*SW_exante_gross_kW]
    # SW_smry[,c('SW_pop','SW_n','SW_cmplt','SW_eval_RR_kWh','rp_SW_eval_RR_kWh')]
    
  },{ ## else if frame=='Gas'----
    ## thm stratum level summary
    ea_gr_thm_field <- paste0('ea_',svgs_field,'Gross_','thm')
    ep_gr_thm_field <- paste0('ep_',svgs_field,'Gross_','thm')

    strat_smry <- data[sampled_thm=='Y' &  nchar(GrossCompl)>0,.(n_cmplt=length(SBW_ProjID)),by=c('PA','domain','stratum_thm')][
      data[sampled_thm=='Y',.(n=length(SBW_ProjID),
                              mean_ea_gr_thm=mean(get(ea_gr_thm_field),na.rm=T),sd_exante_thm=sd(get(ea_gr_thm_field),na.rm=T),
                              mean_eval_thm=mean(get(ep_gr_thm_field),na.rm = T),sd_eval_thm=sd(get(ep_gr_thm_field),na.rm = T),
                              cor_hxy_thm=cor(get(ea_gr_thm_field),get(ep_gr_thm_field),method = 'pearson'),
                              mean_exante_EUL_thm=sum(get(ea_gr_thm_field)*ea_EUL_thm,na.rm=T)/sum(get(ea_gr_thm_field),na.rm=T),
                              mean_eval_EUL_thm=sum(get(ep_gr_thm_field)*ep_EUL_thm,na.rm=T)/sum(get(ep_gr_thm_field),na.rm=T)),
           by=c('PA','domain','stratum_thm')][
             data[stratum_thm!=8,.(pop=length(SBW_ProjID),str_exante_gross_thm=sum(get(ea_gr_thm_field),na.rm=T)),by=c('PA','domain','stratum_thm')],
             on=c('PA','domain','stratum_thm')],on=c('PA','domain','stratum_thm')]
    strat_smry <- strat_smry[data[,.(exante_gross_thm=sum(get(ea_gr_thm_field),na.rm=T)),by=c('PA','domain','stratum_thm')],
                    on=c('PA','domain','stratum_thm')][order(PA,domain,stratum_thm)]           
    strat_smry[is.na(n_cmplt),n_cmplt:=0]
    strat_smry[is.na(n),n:=0]
    strat_smry[,dom_pop:=lapply(.SD,sum,na.rm=T),.SDcols='pop',by='domain']

    dom_smry <- strat_smry[,.(dom_n=sum(n,na.rm=T),dom_cmplt=sum(n_cmplt,na.rm=T),
                              dom_mean_ea_gr_thm=sum(pop*mean_ea_gr_thm,na.rm=T)/sum(pop,na.rm=T),
                              dom_mean_eval_gr_thm=sum(pop*mean_eval_thm,na.rm = T)/sum(pop,na.rm=T),
                              dom_str_exante_gross_thm=sum(str_exante_gross_thm,na.rm = T),
                              dom_exante_gross_thm=sum(exante_gross_thm,na.rm = T),
                              dom_exante_EUL_thm=sum(pop*mean_ea_gr_thm*mean_exante_EUL_thm,na.rm=T)/sum(pop*mean_ea_gr_thm,na.rm=T),
                              dom_eval_EUL_thm=sum(pop*mean_eval_thm*mean_eval_EUL_thm,na.rm=T)/sum(pop*mean_eval_thm,na.rm=T)),
                           by=c('PA','domain')]
    dom_smry[,dom_eval_RR_thm:=dom_mean_eval_gr_thm/dom_mean_ea_gr_thm]
    dom_smry[,dom_eval_EUL_RR_thm:=dom_eval_EUL_thm/dom_exante_EUL_thm]

    strat_smry <- dom_smry[strat_smry,on=c('PA','domain')]
    strat_smry[,sd_z2_thm:=sd_eval_thm^2+(dom_eval_RR_thm*sd_exante_thm)^2-2*dom_eval_RR_thm*cor_hxy_thm*sd_exante_thm*sd_eval_thm]
    strat_smry[,var_comb2_thm:=pop^2*(pop-n)/(n*(pop-1))]
    ## zero out stats for strata with pop=1
    strat_smry[pop==1 & n_cmplt>0,(colnames(strat_smry)[grepl('sd_exante|sd_eval|cor_hxy|sd_z2|var_comb2',colnames(strat_smry))]):=0]

    ## now back to the domain level, to cool off with the L&L waltz----
    dom_smry <- strat_smry[stratum_thm!=8,.(dom_pop=sum(pop,na.rm=T),var_comb2_sdz2_thm=sum(var_comb2_thm*sd_z2_thm,na.rm = T)),
                                    by=c('PA','domain')][dom_smry,on=c('PA','domain')]
    dom_smry[,var_comb1_thm:=1/(dom_str_exante_gross_thm)^2]
    dom_smry[,var_dom_thm:=var_comb1_thm*var_comb2_sdz2_thm]
    dom_smry[,se_dom_eval_RR_thm:=sqrt(var_dom_thm)]

    dom_smry[,eb_dom_eval_RR_thm:=t*se_dom_eval_RR_thm]
    ## calculate Relative Precision on RRs----
    dom_smry[,rp_dom_eval_RR_thm:=eb_dom_eval_RR_thm/dom_eval_RR_thm]

    ## calculate domain evaluated savings----
    dom_smry[,dom_eval_gross_svgs_thm:=dom_eval_RR_thm*dom_exante_gross_thm]
    dom_smry[,se_svgs_dom_thm:=se_dom_eval_RR_thm/dom_eval_RR_thm*dom_eval_gross_svgs_thm]
    dom_smry[,eb_svgs_dom_thm:=t*se_svgs_dom_thm]
    ## calculate Relative Precision on evaluated savings----
    dom_smry[,rp_svgs_dom_thm:=eb_svgs_dom_thm/dom_eval_gross_svgs_thm]

    ## PA roll up, domains are now strata----
    PA_smry <- dom_smry[,.(PA_pop=sum(dom_pop),PA_n=sum(dom_n,na.rm=T),PA_cmplt=sum(dom_cmplt,na.rm=T),
                           PA_mean_ea_gr_thm=sum(dom_pop*dom_mean_ea_gr_thm,na.rm=T)/sum(dom_pop),
                           PA_mean_eval_gr_thm=sum(dom_pop*dom_mean_eval_gr_thm,na.rm = T)/sum(dom_pop),
                           PA_exante_gross_thm=sum(dom_exante_gross_thm,na.rm = T)),
                        by=c('PA')]
    PA_smry[,PA_eval_RR_thm:=PA_mean_eval_gr_thm/PA_mean_ea_gr_thm]


    ## calculate PA evaluated savings
    PA_smry[,PA_eval_gross_svgs_thm:=PA_eval_RR_thm*PA_exante_gross_thm]

    ## SW roll up, PAs are now strata----
    SW_smry <- PA_smry[,.(SW_pop=sum(PA_pop),SW_n=sum(PA_n,na.rm=T),SW_cmplt=sum(PA_cmplt,na.rm=T),
                          SW_mean_ea_gr_thm=sum(PA_pop*PA_mean_ea_gr_thm,na.rm=T)/sum(PA_pop),
                          SW_mean_eval_gr_thm=sum(PA_pop*PA_mean_eval_gr_thm,na.rm = T)/sum(PA_pop),
                          SW_exante_gross_thm=sum(PA_exante_gross_thm,na.rm = T))]
    SW_smry[,SW_eval_RR_thm:=SW_mean_eval_gr_thm/SW_mean_ea_gr_thm]

    ## calculate PA evaluated savings
    SW_smry[,SW_eval_gross_svgs_thm:=SW_eval_RR_thm*SW_exante_gross_thm]

  })
  strat_smry <- dom_smry[strat_smry,on=colnames(strat_smry)[colnames(strat_smry) %in% colnames(dom_smry)]]
  drop_cols <- colnames(dom_smry)[grep('var_|eb_|se_',colnames(dom_smry))]
  if(period!='1stYear') drop_cols <- c(drop_cols,colnames(dom_smry)[grep('EUL',colnames(dom_smry))])
  dom_smry[,(drop_cols):=NULL]
  drop_cols_PA <- colnames(PA_smry)[grep('var_|eb_|mean|_r_|wtd|z2|se_',colnames(PA_smry))]
  PA_smry[,(drop_cols_PA):=NULL]
  drop_cols_SW <- colnames(SW_smry)[grep('var_|eb_|_r_|wtd|z2|mean|se_',colnames(SW_smry))]
  SW_smry[,(drop_cols_SW):=NULL]
  
  
  if(return_strat) return(strat_smry) else {
    if(return_PA) return(PA_smry) else {
      if(return_SW) return(SW_smry) else {
        return(dom_smry)
      }}}
}
