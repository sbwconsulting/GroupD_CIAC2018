library(data.table)

strat.mean.estimator <- function(data=dt_ciac_proj,frame='Electric',period='1stYear',conf=0.9,return_strat=FALSE,return_PA=FALSE,return_SW=FALSE){
  data <- copy(data[(get(paste0('Frame_',frame)))])
  svgs_field <- 'Ann'
  gross_field <- 'AG'

  if(period!='1stYear') {
    svgs_field <- 'LC'
    gross_field <- 'LG'
  }
  t <- 1.645

  ifelse(frame=='Electric',{ ## Electric frame----
    ea_gr_kW_field <- paste0('ea_',svgs_field,'Gross_kW')
    ep_gr_kW_field <- paste0('ep_',svgs_field,'Gross_kW')
    dom_eval_RR_kW_field <- paste0('dom_eval_RR_kW_',gross_field)
    dom_eval_RR_kWh_field <- paste0('dom_eval_RR_kWh_',gross_field)

    data[,(paste0(ep_gr_kW_field,'h')):=get(paste0(ea_gr_kW_field,'h'))*get(dom_eval_RR_kWh_field)]
    data[,(ep_gr_kW_field):=get(ea_gr_kW_field)*get(dom_eval_RR_kW_field)]
    
    ## get kWh stratum level summary----
    strat_smry <- data[!is.na(ep_NTGR_kWh),.(n_cmplt_net=length(SBW_ProjID),
                      str_eval_gross_kWh=sum(get(paste0(ep_gr_kW_field,'h')),na.rm=T),
                      str_eval_gross_kW=sum(get(ep_gr_kW_field),na.rm=T)),
                  by=c('PA','domain','stratum_kWh')][
             data[(sampled_kWh=='Y'|smpld_net_kWh=='Y'),.(n_net=length(SBW_ProjID)),
                  by=c('PA','domain','stratum_kWh')][
                    # data[,.(pop_net=length(SBW_ProjID)),by=c('PA','domain','stratum_kWh')],
                    data[stratum_kWh!=8,.(pop_net=length(SBW_ProjID)),by=c('PA','domain','stratum_kWh')],
                         on=c('PA','domain','stratum_kWh')],on=c('PA','domain','stratum_kWh')]
    strat_smry <- strat_smry[data[,.(str_tot_eval_gross_kWh=sum(get(paste0(ep_gr_kW_field,'h')),na.rm=T),str_tot_eval_gross_kW=sum(get(ep_gr_kW_field),na.rm=T)),
                                  by=c('PA','domain','stratum_kWh')],on=c('PA','domain','stratum_kWh')][order(PA,domain,stratum_kWh)]
    strat_smry[is.na(n_net) & stratum_kWh==9,n_net:=pop_net]
    strat_smry[is.na(n_net),n_net:=0]
    strat_smry[is.na(n_cmplt_net),n_cmplt_net:=0]
    data <- strat_smry[data,on=c('PA','domain','stratum_kWh')]
    data[!is.na(ep_NTGR_kWh),wi_kWh:=get(paste0(ep_gr_kW_field,'h'))/str_eval_gross_kWh]
    data[!is.na(ep_NTGR_kW),wi_kW:=get(ep_gr_kW_field)/str_eval_gross_kW]
    data[!is.na(ep_NTGR_kWh),ea_wi_NTGR_kWh:=wi_kWh*ea_NTGR_kWh]
    data[!is.na(ep_NTGR_kW),ea_wi_NTGR_kW:=wi_kW*ea_NTGR_kW]
    data[!is.na(ep_NTGR_kWh),wi_NTGR_kWh:=wi_kWh*ep_NTGR_kWh]
    data[!is.na(ep_NTGR_kW),wi_NTGR_kW:=wi_kW*ep_NTGR_kW]
    data[!is.na(ep_NTGR_kWh),str_mean_exante_NTGR_kWh:=lapply(.SD,sum,na.rm=T),.SDcols='ea_wi_NTGR_kWh',by=c('domain','stratum_kWh')]
    data[!is.na(ep_NTGR_kW),str_mean_exante_NTGR_kW:=lapply(.SD,sum,na.rm=T),.SDcols='ea_wi_NTGR_kW',by=c('domain','stratum_kWh')]
    data[!is.na(ep_NTGR_kWh),str_mean_eval_NTGR_kWh:=lapply(.SD,sum,na.rm=T),.SDcols='wi_NTGR_kWh',by=c('domain','stratum_kWh')]
    data[!is.na(ep_NTGR_kW),str_mean_eval_NTGR_kW:=lapply(.SD,sum,na.rm=T),.SDcols='wi_NTGR_kW',by=c('domain','stratum_kWh')]
    data[!is.na(ep_NTGR_kWh),Si_kWh:=wi_kWh*(ep_NTGR_kWh-str_mean_eval_NTGR_kWh)^2/n_cmplt_net]
    data[!is.na(ep_NTGR_kW),Si_kW:=wi_kW*(ep_NTGR_kW-str_mean_eval_NTGR_kW)^2/n_cmplt_net]
    strat_smry <- data[stratum_kWh!=8,.(Sh2_kWh=sum(Si_kWh,na.rm=T),Sh2_kW=sum(Si_kW,na.rm=T),str_mean_exante_NTGR_kWh=mean(str_mean_exante_NTGR_kWh,na.rm=T),str_mean_exante_NTGR_kW=mean(str_mean_exante_NTGR_kW,na.rm=T),
                                     str_mean_eval_NTGR_kWh=mean(str_mean_eval_NTGR_kWh,na.rm=T),str_mean_eval_NTGR_kW=mean(str_mean_eval_NTGR_kW,na.rm=T)),
                                  by=c('PA','domain','stratum_kWh')][strat_smry,on=c('PA','domain','stratum_kWh')]
    strat_smry[,Sh_kWh:=sqrt(Sh2_kWh)]
    strat_smry[,Sh_kW:=sqrt(Sh2_kW)]

    dom_smry <- strat_smry[,.(dom_pop_net=sum(pop_net,na.rm=T),dom_n_net=sum(n_net,na.rm=T),dom_cmplt_net=sum(n_cmplt_net,na.rm=T),
                              dom_mean_exante_NTGR_kWh=sum(pop_net*str_mean_exante_NTGR_kWh,na.rm = T)/sum(pop_net,na.rm=T),
                              dom_mean_exante_NTGR_kW=sum(pop_net*str_mean_exante_NTGR_kW,na.rm = T)/sum(pop_net,na.rm=T),
                              dom_mean_eval_NTGR_kWh=sum(pop_net*str_mean_eval_NTGR_kWh,na.rm = T)/sum(pop_net,na.rm=T),
                              dom_mean_eval_NTGR_kW=sum(pop_net*str_mean_eval_NTGR_kW,na.rm = T)/sum(pop_net,na.rm=T),
                              dom_smpld_ep_gr_svgs_kWh=sum(str_eval_gross_kWh,na.rm=T),
                              dom_smpld_ep_gr_svgs_kW=sum(str_eval_gross_kW,na.rm=T),
                              dom_tot_ep_gr_svgs_kWh=sum(str_tot_eval_gross_kWh,na.rm=T),
                              dom_tot_ep_gr_svgs_kW=sum(str_tot_eval_gross_kW,na.rm=T)),
                           by=c('PA','domain')]
    
    strat_smry <- dom_smry[strat_smry,on=colnames(strat_smry)[colnames(strat_smry) %in% colnames(dom_smry)]]
    strat_smry[,Wh:=pop_net/dom_pop_net]
    strat_smry[,WhSh_kWh:=Wh*Sh_kWh]
    strat_smry[,WhSh2_kWh:=Wh*Sh2_kWh]
    strat_smry[,Wh2Sh2_kWh:=Wh^2*Sh2_kWh/n_cmplt_net]
    strat_smry[,WhSh_kW:=Wh*Sh_kW]
    strat_smry[,WhSh2_kW:=Wh*Sh2_kW]
    strat_smry[,Wh2Sh2_kW:=Wh^2*Sh2_kW/n_cmplt_net]

    ## zero out stats for certainty strata with pop=1
    strat_smry[stratum_kWh==9 & pop_net==1 & n_cmplt_net>0,colnames(strat_smry)[grepl('Sh',colnames(strat_smry))]:=0]

    dom_smry <- strat_smry[,.(var2_kWh=sum(WhSh2_kWh,na.rm = T)/sum(pop_net,na.rm=T),var1_kWh=sum(Wh2Sh2_kWh,na.rm = T),
                              var2_kW=sum(WhSh2_kW,na.rm = T)/sum(pop_net,na.rm=T),var1_kW=sum(Wh2Sh2_kW,na.rm = T)),
                           by=c('PA','domain')][dom_smry,on=c('PA','domain')]
    dom_smry[,var_dom_kWh:=var1_kWh-var2_kWh]
    dom_smry[,SE_dom_kWh:=sqrt(var_dom_kWh)]
    dom_smry[,deltaE_dom_kWh:=t*SE_dom_kWh]
    dom_smry[,RP_dom_NTGR_kWh:=deltaE_dom_kWh/dom_mean_eval_NTGR_kWh]
    dom_smry[,dom_eval_svgs_kWh:=dom_tot_ep_gr_svgs_kWh*dom_mean_eval_NTGR_kWh]
    
    dom_smry[,var_dom_kW:=var1_kW-var2_kW]
    dom_smry[,SE_dom_kW:=sqrt(var_dom_kW)]
    dom_smry[,deltaE_dom_kW:=t*SE_dom_kW]
    dom_smry[,RP_dom_NTGR_kW:=deltaE_dom_kW/dom_mean_eval_NTGR_kW]
    dom_smry[,dom_eval_svgs_kW:=dom_tot_ep_gr_svgs_kW*dom_mean_eval_NTGR_kW]
    
    ## PA roll up, now domains are strata
    PA_smry <- dom_smry[,.(PA_pop_net=sum(dom_pop_net),PA_n_net=sum(dom_n_net),PA_cmplt_net=sum(dom_cmplt_net),
                           PA_mean_exante_NTGR_kWh=sum(dom_pop_net*dom_mean_exante_NTGR_kWh,na.rm = T)/sum(dom_pop_net),
                           PA_mean_exante_NTGR_kW=sum(dom_pop_net*dom_mean_exante_NTGR_kW,na.rm = T)/sum(dom_pop_net),
                           PA_mean_eval_NTGR_kWh=sum(dom_pop_net*dom_mean_eval_NTGR_kWh,na.rm = T)/sum(dom_pop_net),
                              PA_mean_eval_NTGR_kW=sum(dom_pop_net*dom_mean_eval_NTGR_kW,na.rm = T)/sum(dom_pop_net),
                              # PA_smpld_ep_gr_svgs_kWh=sum(dom_smpld_ep_gr_svgs_kWh,na.rm=T),
                              # PA_smpld_ep_gr_svgs_kW=sum(dom_smpld_ep_gr_svgs_kW,na.rm=T),
                              PA_tot_ep_gr_svgs_kWh=sum(dom_tot_ep_gr_svgs_kWh,na.rm=T),
                              PA_tot_ep_gr_svgs_kW=sum(dom_tot_ep_gr_svgs_kW,na.rm=T)),
                           by=c('PA')]
    
    dom_smry <- PA_smry[dom_smry,on=colnames(dom_smry)[colnames(dom_smry) %in% colnames(PA_smry)]]
    dom_smry[,dom_Wh:=dom_pop_net/PA_pop_net]
    dom_smry[,dom_WhSh_kWh:=dom_Wh*SE_dom_kWh]
    dom_smry[,dom_WhSh2_kWh:=dom_Wh*var_dom_kWh]
    dom_smry[,dom_Wh2Sh2_kWh:=dom_Wh^2*var_dom_kWh/dom_cmplt_net]
    dom_smry[,dom_WhSh_kW:=dom_Wh*SE_dom_kW]
    dom_smry[,dom_WhSh2_kW:=dom_Wh*var_dom_kW]
    dom_smry[,dom_Wh2Sh2_kW:=dom_Wh^2*var_dom_kW/dom_cmplt_net]
    
    ## zero out stats for certainty domains with pop=1
    dom_smry[dom_pop_net==1 & dom_cmplt_net>0,colnames(dom_smry)[grepl('Sh',colnames(dom_smry))]:=0]

    PA_smry[,PA_eval_svgs_kWh:=PA_tot_ep_gr_svgs_kWh*PA_mean_eval_NTGR_kWh]
    
    PA_smry[,PA_eval_svgs_kW:=PA_tot_ep_gr_svgs_kW*PA_mean_eval_NTGR_kW]
    
    ## SW roll up, now PAs are strata
    SW_smry <- PA_smry[,.(SW_n_net=sum(PA_n_net),SW_cmplt_net=sum(PA_cmplt_net),
                          SW_mean_exante_NTGR_kWh=sum(PA_pop_net*PA_mean_exante_NTGR_kWh,na.rm = T)/sum(PA_pop_net),
                          SW_mean_exante_NTGR_kW=sum(PA_pop_net*PA_mean_exante_NTGR_kW,na.rm = T)/sum(PA_pop_net),
                          SW_mean_eval_NTGR_kWh=sum(PA_pop_net*PA_mean_eval_NTGR_kWh,na.rm = T)/sum(PA_pop_net),
                           SW_mean_eval_NTGR_kW=sum(PA_pop_net*PA_mean_eval_NTGR_kW,na.rm = T)/sum(PA_pop_net),
                           # SW_smpld_ep_gr_svgs_kWh=sum(PA_smpld_ep_gr_svgs_kWh,na.rm=T),
                           # SW_smpld_ep_gr_svgs_kW=sum(PA_smpld_ep_gr_svgs_kW,na.rm=T),
                           SW_tot_ep_gr_svgs_kWh=sum(PA_tot_ep_gr_svgs_kWh,na.rm=T),
                           SW_tot_ep_gr_svgs_kW=sum(PA_tot_ep_gr_svgs_kW,na.rm=T))]
    SW_smry[,SW_eval_svgs_kWh:=SW_tot_ep_gr_svgs_kWh*SW_mean_eval_NTGR_kWh]
    
    SW_smry[,SW_eval_svgs_kW:=SW_tot_ep_gr_svgs_kW*SW_mean_eval_NTGR_kW]
    
  },{  ## else Gas frame----
    ea_gr_thm_field <- paste0('ea_',svgs_field,'Gross_thm')
    ep_gr_thm_field <- paste0('ep_',svgs_field,'Gross_thm')
    dom_eval_RR_thm_field <- paste0('dom_eval_RR_thm_',gross_field)

    data[,(ep_gr_thm_field):=get(ea_gr_thm_field)*get(dom_eval_RR_thm_field)]
    
    ## get thmh stratum level summary----
    strat_smry <- data[!is.na(ep_NTGR_thm),.(n_cmplt_net=length(SBW_ProjID),str_eval_gross_thm=sum(get(ep_gr_thm_field),na.rm=T)),
                       by=c('PA','domain','stratum_thm')][
                         data[(sampled_thm=='Y'|smpld_net_thm=='Y'),.(n_net=length(SBW_ProjID)),
                              by=c('PA','domain','stratum_thm')][
                                # data[,.(pop_net=length(SBW_ProjID)),by=c('PA','domain','stratum_thm')],
                                data[stratum_thm!=8,.(pop_net=length(SBW_ProjID)),by=c('PA','domain','stratum_thm')],
                                on=c('PA','domain','stratum_thm')],on=c('PA','domain','stratum_thm')]
    strat_smry <- strat_smry[data[,.(str_tot_eval_gross_thm=sum(get(ep_gr_thm_field),na.rm=T),pop_net_tot=length(SBW_ProjID)),
                                  by=c('PA','domain','stratum_thm')],on=c('PA','domain','stratum_thm')][order(PA,domain,stratum_thm)]
    strat_smry[is.na(n_net) & stratum_thm==9,n_net:=pop_net]
    strat_smry[is.na(n_net),n_net:=0]
    strat_smry[is.na(n_cmplt_net),n_cmplt_net:=0]
    data <- strat_smry[data,on=c('PA','domain','stratum_thm')]
    data[!is.na(ep_NTGR_thm),wi_thm:=get(ep_gr_thm_field)/str_eval_gross_thm]
    data[!is.na(ep_NTGR_thm),ea_wi_NTGR_thm:=wi_thm*ea_NTGR_thm]
    data[!is.na(ep_NTGR_thm),str_mean_exante_NTGR_thm:=lapply(.SD,sum,na.rm=T),.SDcols='ea_wi_NTGR_thm',by=c('domain','stratum_thm')]
    data[!is.na(ep_NTGR_thm),wi_NTGR_thm:=wi_thm*ep_NTGR_thm]
    data[!is.na(ep_NTGR_thm),str_mean_eval_NTGR_thm:=lapply(.SD,sum,na.rm=T),.SDcols='wi_NTGR_thm',by=c('domain','stratum_thm')]
    data[!is.na(ep_NTGR_thm),Si_thm:=wi_thm*(ep_NTGR_thm-str_mean_eval_NTGR_thm)^2/n_cmplt_net]
    strat_smry <- data[stratum_thm!=8,.(Sh2_thm=sum(Si_thm,na.rm=T),str_mean_exante_NTGR_thm=mean(str_mean_exante_NTGR_thm,na.rm=T),
                                        str_mean_eval_NTGR_thm=mean(str_mean_eval_NTGR_thm,na.rm=T)),
                                  by=c('PA','domain','stratum_thm')][strat_smry,on=c('PA','domain','stratum_thm')]
    strat_smry[,Sh_thm:=sqrt(Sh2_thm)]
    
    dom_smry <- strat_smry[,.(dom_pop_net=sum(pop_net,na.rm=T),dom_n_net=sum(n_net,na.rm=T),dom_cmplt_net=sum(n_cmplt_net,na.rm=T),
                              dom_mean_exante_NTGR_thm=sum(pop_net*str_mean_exante_NTGR_thm,na.rm = T)/sum(pop_net,na.rm=T),
                              # dom_mean_eval_NTGR_thm=sum(pop_net*str_mean_eval_NTGR_thm,na.rm = T)/sum(pop_net),
                              dom_mean_eval_NTGR_thm=sum(pop_net*str_mean_eval_NTGR_thm,na.rm = T)/sum(pop_net,na.rm=T),
                              dom_smpld_ep_gr_svgs_thm=sum(str_eval_gross_thm,na.rm=T),
                              dom_tot_ep_gr_svgs_thm=sum(str_tot_eval_gross_thm,na.rm=T)),
                           by=c('PA','domain')]
    
    strat_smry <- dom_smry[strat_smry,on=colnames(strat_smry)[colnames(strat_smry) %in% colnames(dom_smry)]]
    strat_smry[,Wh:=pop_net/dom_pop_net]
    strat_smry[,WhSh_thm:=Wh*Sh_thm]
    strat_smry[,WhSh2_thm:=Wh*Sh2_thm]
    strat_smry[,Wh2Sh2_thm:=Wh^2*Sh2_thm/n_cmplt_net]
    
    ## zero out stats for certainty strata with pop=1
    strat_smry[stratum_thm==9 & pop_net==1 & n_cmplt_net>0,colnames(strat_smry)[grepl('Sh',colnames(strat_smry))]:=0]

    dom_smry <- strat_smry[,.(var2_thm=sum(WhSh2_thm,na.rm = T)/sum(pop_net,na.rm=T),var1_thm=sum(Wh2Sh2_thm,na.rm = T)),
                           by=c('PA','domain')][dom_smry,on=c('PA','domain')]
    dom_smry[,var_dom_thm:=var1_thm-var2_thm]
    dom_smry[,SE_dom_thm:=sqrt(var_dom_thm)]
    dom_smry[,deltaE_dom_thm:=t*SE_dom_thm]
    dom_smry[,RP_dom_NTGR_thm:=deltaE_dom_thm/dom_mean_eval_NTGR_thm]
    dom_smry[,dom_eval_svgs_thm:=dom_tot_ep_gr_svgs_thm*dom_mean_eval_NTGR_thm]

    ## PA roll up, now domains are strata
    PA_smry <- dom_smry[,.(PA_pop_net=sum(dom_pop_net),PA_n_net=sum(dom_n_net),PA_cmplt_net=sum(dom_cmplt_net),
                           PA_mean_eval_NTGR_thm=sum(dom_pop_net*dom_mean_eval_NTGR_thm,na.rm = T)/sum(dom_pop_net),
                           # PA_smpld_ep_gr_svgs_thm=sum(dom_smpld_ep_gr_svgs_thm,na.rm=T),
                           PA_tot_ep_gr_svgs_thm=sum(dom_tot_ep_gr_svgs_thm,na.rm=T)),
                        by=c('PA')]
    
    dom_smry <- PA_smry[dom_smry,on=colnames(dom_smry)[colnames(dom_smry) %in% colnames(PA_smry)]]
    
    ## if there are domains with 0 net savings and NTGRs and gross savings>0 (because no net survey sompleted), set domain NTGR to PA NTGR, calc net savings
    dom_smry$dom_zero_net_saver_flag <- F
    dom_smry[dom_mean_eval_NTGR_thm==0 & dom_tot_ep_gr_svgs_thm!=0,dom_zero_net_saver_flag:=T]
    dom_smry[dom_mean_eval_NTGR_thm==0 & dom_tot_ep_gr_svgs_thm!=0,dom_mean_eval_NTGR_thm:=PA_mean_eval_NTGR_thm]
    ## then recalc PA NTGR
    PA_smry <- dom_smry[,.(PA_pop_net=sum(dom_pop_net),PA_n_net=sum(dom_n_net),PA_cmplt_net=sum(dom_cmplt_net),
                           PA_mean_exante_NTGR_thm=sum(dom_pop_net*dom_mean_exante_NTGR_thm,na.rm = T)/sum(dom_pop_net),
                           PA_mean_eval_NTGR_thm=sum(dom_pop_net*dom_mean_eval_NTGR_thm,na.rm = T)/sum(dom_pop_net),
                           # PA_smpld_ep_gr_svgs_thm=sum(dom_smpld_ep_gr_svgs_thm,na.rm=T),
                           PA_tot_ep_gr_svgs_thm=sum(dom_tot_ep_gr_svgs_thm,na.rm=T)),
                        by=c('PA')]
    dom_smry <- PA_smry[,c('PA','PA_mean_eval_NTGR_thm')][dom_smry[,setdiff(colnames(dom_smry),'PA_mean_eval_NTGR_thm'),with=F],on='PA']
    dom_smry[(dom_zero_net_saver_flag),dom_mean_eval_NTGR_thm:=PA_mean_eval_NTGR_thm]
    dom_smry[(dom_zero_net_saver_flag),dom_eval_svgs_thm:=dom_tot_ep_gr_svgs_thm*dom_mean_eval_NTGR_thm]
    dom_smry$dom_zero_net_saver_flag <- NULL
    dom_smry[,dom_Wh:=dom_pop_net/PA_pop_net]
    dom_smry[,dom_WhSh_thm:=dom_Wh*SE_dom_thm]
    dom_smry[,dom_WhSh2_thm:=dom_Wh*var_dom_thm]
    dom_smry[,dom_Wh2Sh2_thm:=dom_Wh^2*var_dom_thm/dom_cmplt_net]

    ## zero out stats for certainty domains with pop=1
    dom_smry[dom_pop_net==1 & dom_cmplt_net>0,colnames(dom_smry)[grepl('Sh',colnames(dom_smry))]:=0]
    
    PA_smry[,PA_eval_svgs_thm:=PA_tot_ep_gr_svgs_thm*PA_mean_eval_NTGR_thm]
    
    ## SW roll up, now PAs are strata
    SW_smry <- PA_smry[,.(SW_n_net=sum(PA_n_net),SW_cmplt_net=sum(PA_cmplt_net),
                          SW_mean_exante_NTGR_thm=sum(PA_pop_net*PA_mean_exante_NTGR_thm,na.rm = T)/sum(PA_pop_net),
                          SW_mean_eval_NTGR_thm=sum(PA_pop_net*PA_mean_eval_NTGR_thm,na.rm = T)/sum(PA_pop_net),
                          # SW_smpld_ep_gr_svgs_thm=sum(PA_smpld_ep_gr_svgs_thm,na.rm=T),
                          SW_tot_ep_gr_svgs_thm=sum(PA_tot_ep_gr_svgs_thm,na.rm=T))]
    SW_smry[,SW_eval_svgs_thm:=SW_tot_ep_gr_svgs_thm*SW_mean_eval_NTGR_thm]
    
  })
  strat_smry <- dom_smry[strat_smry,on=colnames(strat_smry)[colnames(strat_smry) %in% colnames(dom_smry)]]
  drop_cols <- colnames(dom_smry)[grep('var|SE_|deltaE_|_Wh|gross|rp_|smpld_|tot_|^PA_',colnames(dom_smry))]
  dom_smry[,(drop_cols):=NULL]
  drop_cols_PA <- colnames(PA_smry)[grep('var|SE_|deltaE_|_Wh|SW_|smpld_|tot_',colnames(PA_smry))]
  PA_smry[,(drop_cols_PA):=NULL]
  drop_cols_SW <- colnames(SW_smry)[grep('var|SE_|deltaE_|_Wh|smpld_|tot_',colnames(SW_smry))]
  SW_smry[,(drop_cols_SW):=NULL]
  if(return_strat) return(strat_smry) else {
    if(return_PA) return(PA_smry) else {
      if(return_SW) return(SW_smry) else {
    return(dom_smry)
    }}}
}
