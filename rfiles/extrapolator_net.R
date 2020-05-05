library(data.table)

fname_net_claim <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/net_claim.csv'
fname_import_domGr <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/domain_gross_summary.csv'
fname_gr_claim_ar <- 
  'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/gross_claim.csv'
fname_claim_ar <- 
  'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/claimpop.csv'
fname_import_PA <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/PA_Gross_summary.csv'
fname_import_SW <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/SW_Gross_summary.csv'
fname_export_dom <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/domain_summary.csv'
fname_export_dom_NTGR <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/domain_NTGR_summary.csv'
fname_export_PA <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/PA_summary.csv'
fname_export_SW <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/SW_summary.csv'
fname_export_ar <- 
  'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/AR_summary.csv'

source('Z:/Favorites/CPUC10 (Group D - Custom EM&V)/4 Deliverables/09 - Ex-Post Evaluated Gross Savings Estimates/CIAC/2018 Evaluation/Extrapolation/Strat_mean_estimator.R')
roll_up <- function(savings,rp){
  return(sqrt(sum((savings*rp)^2,na.rm=T))/sum(savings,na.rm=T))
}
dt_ciac_net <- fread(file=fname_net_claim)

dt_ciac_proj_net <- dt_ciac_net[,.(meas_ct=length(ClaimID),
                              ea_AnnGross_kWh=sum(ExAnte_Annualized_NoRR_kWh,na.rm=T),ea_AnnGross_kW=sum(ExAnte_Annualized_NoRR_kW,na.rm=T),
                              ea_LCGross_kWh=sum(ExAnte_LifeCycleGross_NoRR_kWh,na.rm=T),ea_LCGross_kW=sum(ExAnte_LifeCycleGross_NoRR_kW,na.rm=T),
                              ea_AnnGross_thm=sum(ExAnte_Annualized_NoRR_thm,na.rm=T),ea_LCGross_thm=sum(ExAnte_LifeCycleGross_NoRR_thm,na.rm=T),
                              ea_AnnNet_kWh=sum(ExAnte_Annualized_Net_NoRR_kWh,na.rm=T),ea_AnnNet_kW=sum(ExAnte_Annualized_Net_NoRR_kW,na.rm=T),
                              ea_LCNet_kWh=sum(ExAnte_LifeCycleNet_NoRR_kWh,na.rm=T),ea_LCNet_kW=sum(ExAnte_LifeCycleNet_NoRR_kW,na.rm=T),
                              ea_AnnNet_thm=sum(ExAnte_Annualized_Net_NoRR_thm,na.rm=T),ea_LCNet_thm=sum(ExAnte_LifeCycleNet_NoRR_thm,na.rm=T),
                              ep_AnnGross_kWh=sum(EvalExPostAnnualizedGrosskWh,na.rm=T),ep_AnnGross_kW=sum(EvalExPostAnnualizedGrosskW,na.rm=T),
                              ep_LCGross_kWh=sum(EvalExPostLifeCycleGrosskWh,na.rm=T),ep_LCGross_kW=sum(EvalExPostLifeCycleGrosskW,na.rm=T),
                              ep_AnnGross_thm=sum(EvalExPostAnnualizedGrossTherm,na.rm=T),ep_LCGross_thm=sum(EvalExPostLifeCycleGrossTherm,na.rm=T),
                              ep_AnnNet_kWh=sum(prj_EvalExPostAnnualizedNetkWh,na.rm=T),ep_AnnNet_kW=sum(prj_EvalExPostAnnualizedNetkW,na.rm=T),
                              ep_LCNet_kWh=sum(prj_EvalExPostLifeCycleNetkWh,na.rm=T),ep_LCNet_kW=sum(prj_EvalExPostLifeCycleNetkW,na.rm=T),
                              ep_AnnNet_thm=sum(prj_EvalExPostAnnualizedNetthm,na.rm=T),
                              ep_LCNet_thm=sum(prj_EvalExPostLifeCycleNetthm,na.rm=T),
                              dom_eval_RR_kWh_AG=mean(dom_eval_RR_kWh_AG,na.rm=T),dom_eval_RR_kW_AG=mean(dom_eval_RR_kW_AG,na.rm=T),
                              dom_eval_RR_kWh_LG=mean(dom_eval_RR_kWh_LG,na.rm=T),dom_eval_RR_kW_LG=mean(dom_eval_RR_kW_LG,na.rm=T),
                              dom_eval_RR_thm_AG=mean(dom_eval_RR_thm_AG,na.rm=T),
                              dom_eval_RR_thm_LG=mean(dom_eval_RR_thm_LG,na.rm=T),
                              rp_dom_eval_RR_kWh_AG=mean(rp_dom_eval_RR_kWh_AG,na.rm=T),rp_dom_eval_RR_kW_AG=mean(rp_dom_eval_RR_kW_AG,na.rm=T),
                              rp_dom_eval_RR_kWh_LG=mean(rp_dom_eval_RR_kWh_LG,na.rm=T),rp_dom_eval_RR_kW_LG=mean(rp_dom_eval_RR_kW_LG,na.rm=T),
                              rp_dom_eval_RR_thm_AG=mean(rp_dom_eval_RR_thm_AG,na.rm=T),rp_dom_eval_RR_thm_LG=mean(dom_eval_RR_thm_LG,na.rm=T),
                              ea_NTGR_kWh=mean(st_ExAnte_NTGRkWh),ea_NTGR_kW=mean(st_ExAnte_NTGRkW),ea_NTGR_thm=mean(st_ExAnte_NTGRTherm),
                              ep_NTGR_kWh=mean(st_EvalNTGRkWh),ep_NTGR_kW=mean(st_EvalNTGRkW),ep_NTGR_thm=mean(st_EvalNTGRTherm),
                              GrossCompl=max(GrossCompl,na.rm=T),
                              ea_EUL_kWh=mean(ea_EUL_kWh,na.rm=T),ea_EUL_thm=mean(ea_EUL_thm,na.rm=T),
                              ep_EUL_kWh=mean(ep_EUL_kWh,na.rm=T),ep_EUL_thm=mean(ep_EUL_thm,na.rm=T)),
                           by=c('Frame_Electric','Frame_Gas','PA','domain','stratum_kWh','stratum_thm','SBW_ProjID','sampled_kWh','sampled_thm','SampleID',#'Sampled',
                                'smpld_net','smpld_net_kWh','smpld_net_thm','smpld_net_new','NetSurveyComplete')]

dt_ciac_proj <- dt_ciac_proj_net[!is.na(Frame_Electric) & !is.na(Frame_Gas)]

## domain level----
dom_AnnNet_smry_el <- strat.mean.estimator(dt_ciac_proj,period='1stYear',frame='Electric')
dom_AnnNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,period='1stYear',frame='Gas')
dom_AnnNet_smry <- merge(dom_AnnNet_smry_el,dom_AnnNet_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                         by=c('PA','domain'))

dom_LCNet_smry_el <- strat.mean.estimator(dt_ciac_proj,frame='Electric',period='Lifecycle')
dom_LCNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,frame='Gas',period='Lifecycle')
dom_LCNet_smry <- merge(dom_LCNet_smry_el,dom_LCNet_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                         by=c('PA','domain'))

dom_Net_smry <- merge(dom_AnnNet_smry,dom_LCNet_smry,all=T,suffixes = c('_AN','_LN'),
                      by=c('PA','domain','dom_pop_net_kWh','dom_n_net_kWh','dom_cmplt_net_kWh',
                           'dom_pop_net_thm','dom_n_net_thm','dom_cmplt_net_thm'))

dom_Gross_smry <- fread(fname_import_domGr)
dom_smry_all <- merge(dom_Gross_smry,dom_Net_smry,all=T,by=colnames(dom_Net_smry)[colnames(dom_Net_smry) %in% colnames(dom_Gross_smry)])
dom_exante_Net_smry_el <- dt_ciac_proj[(Frame_Electric),.(dom_exante_kWh_AN=sum(ea_AnnNet_kWh,na.rm=T),dom_exante_kW_AN=sum(ea_AnnNet_kW,na.rm=T),
                dom_exante_svgs_kWh_LN=sum(ea_LCNet_kWh,na.rm=T),dom_exante_svgs_kW_LN=sum(ea_LCNet_kW,na.rm=T)),by=c('PA','domain')]
dom_exante_Net_smry_gas <- dt_ciac_proj[(Frame_Gas),.(dom_exante_svgs_thm_AN=sum(ea_AnnNet_thm,na.rm=T),
                                                      dom_exante_svgs_thm_LN=sum(ea_LCNet_thm,na.rm=T)),by=c('PA','domain')]
dom_exante_Net_smry <- merge(dom_exante_Net_smry_el,dom_exante_Net_smry_gas,by=c('PA','domain'),all=T)
dom_smry_all <- dom_exante_Net_smry[dom_smry_all,on=c('PA','domain')]

## create AR domain summary----
dt_ciac_ar <- fread(fname_claim_ar)
dt_ciac_ar <- dom_smry_all[,c('domain','dom_eval_RR_kWh_LG','dom_eval_RR_kW_LG','dom_eval_RR_thm_LG',
                              'dom_mean_eval_NTGR_kWh_LN','dom_mean_eval_NTGR_kW_LN','dom_mean_eval_NTGR_thm_LN')][
                    dt_ciac_ar,on='domain']
dt_ciac_ar_proj <- dt_ciac_ar[,.(meas_ct=length(ClaimID),ea_AR_kWh=mean(Proj_AR_ExAnte_LifeCycleNet_NoRR_kwh,na.rm=T),
                                 ea_AR_kW=mean(Proj_AR_ExAnte_LifeCycleNet_NoRR_kw,na.rm=T),
                                 ea_AR_thm=mean(Proj_AR_ExAnte_LifeCycleNet_NoRR_thm,na.rm=T),
                                 ep_AR_kWh=mean(Proj_AR_ExPost_LifeCycleGross_NoRR_kwh*dom_mean_eval_NTGR_kWh_LN,na.rm=T),
                                 ep_AR_kW=mean(Proj_AR_ExPost_LifeCycleGross_NoRR_kw*dom_mean_eval_NTGR_kW_LN,na.rm=T),
                                 ep_AR_thm=mean(Proj_AR_ExPost_LifeCycleGross_NoRR_thm*dom_mean_eval_NTGR_thm_LN,na.rm=T),
                                 ea_LCGross_kWh=sum(ExAnte_LifeCycleGross_NoRR_kWh,na.rm=T),
                                 ea_LCGross_kW=sum(ExAnte_LifeCycleGross_NoRR_kW,na.rm=T),
                                 ea_LCGross_thm=sum(ExAnte_LifeCycleGross_NoRR_thm,na.rm=T),
                                 ep_LCGross_kWh=sum(ExAnte_LifeCycleGross_NoRR_kWh*dom_eval_RR_kWh_LG,na.rm=T),
                                 ep_LCGross_kW=sum(ExAnte_LifeCycleGross_NoRR_kW*dom_eval_RR_kW_LG,na.rm=T),
                                 ep_LCGross_thm=sum(ExAnte_LifeCycleGross_NoRR_thm*dom_eval_RR_thm_LG,na.rm=T),
                                 ea_LCNet_kWh=sum(ExAnte_LifeCycleNet_NoRR_kWh,na.rm=T),
                                 ea_LCNet_kW=sum(ExAnte_LifeCycleNet_NoRR_kW,na.rm=T),
                                 ea_LCNet_thm=sum(ExAnte_LifeCycleNet_NoRR_thm,na.rm=T),
                                 ep_LCNet_kWh=sum(ExAnte_LifeCycleGross_NoRR_kWh*dom_eval_RR_kWh_LG*dom_mean_eval_NTGR_kWh_LN,na.rm=T),
                                 ep_LCNet_kW=sum(ExAnte_LifeCycleGross_NoRR_kW*dom_eval_RR_kW_LG*dom_mean_eval_NTGR_kW_LN,na.rm=T),
                                 ep_LCNet_thm=sum(ExAnte_LifeCycleGross_NoRR_thm*dom_eval_RR_thm_LG*dom_mean_eval_NTGR_thm_LN,na.rm=T),
                                 ep_AnnNet_kWh=sum(EvalExPostAnnualizedNetkWh,na.rm=T),
                                 ep_AnnNet_kW=sum(EvalExPostAnnualizedNetkW,na.rm=T),
                                 ep_AnnNet_thm=sum(EvalExPostAnnualizedNetTherm,na.rm=T),
                                 net_cmplt_kWh=max(net_complete_kwh,na.rm=T),net_cmplt_thm=max(net_complete_thm,na.rm=T)),
                              by=c('PA','Frame_Electric','Frame_Gas','domain','stratum_kWh','stratum_thm','SampleID','sampled_kWh','sampled_thm')]
dt_ciac_ar_proj[(Frame_Electric),str_ea_LCGross_kWh:=lapply(.SD,sum,na.rm=T),.SDcols='ea_LCGross_kWh',by=c('domain','stratum_kWh')]
dt_ciac_ar_proj[(Frame_Electric),str_ea_LCGross_kW:=lapply(.SD,sum,na.rm=T),.SDcols='ea_LCGross_kW',by=c('domain','stratum_kWh')]
dt_ciac_ar_proj[(Frame_Gas),str_ea_LCGross_thm:=lapply(.SD,sum,na.rm=T),.SDcols='ea_LCGross_thm',by=c('domain','stratum_thm')]
dt_ciac_ar_proj[(Frame_Electric),wi_kWh:=ea_LCGross_kWh/str_ea_LCGross_kWh]
dt_ciac_ar_proj[(Frame_Electric),wi_kW:=ea_LCGross_kW/str_ea_LCGross_kW]
dt_ciac_ar_proj[(Frame_Gas),wi_thm:=ea_LCGross_thm/str_ea_LCGross_thm]
dt_ciac_ar_proj[(Frame_Electric) & (sampled_kWh =='Y' | (net_cmplt_kWh)),ea_pct_AR_kWh:=ea_AR_kWh/ea_LCNet_kWh]
dt_ciac_ar_proj[(Frame_Electric) & (sampled_kWh =='Y' | (net_cmplt_kWh)),ea_pct_AR_kW:=ea_AR_kW/ea_LCNet_kW]
dt_ciac_ar_proj[(Frame_Gas) & (sampled_thm =='Y' | (net_cmplt_thm)),ea_pct_AR_thm:=ea_AR_thm/ea_LCNet_thm]
dt_ciac_ar_proj[(Frame_Electric),ep_pct_AR_kWh:=ep_AR_kWh/ep_LCNet_kWh]
dt_ciac_ar_proj[(Frame_Electric),ep_pct_AR_kW:=ep_AR_kW/ep_LCNet_kW]
dt_ciac_ar_proj[(Frame_Gas),ep_pct_AR_thm:=ep_AR_thm/ep_LCNet_thm]
dt_ciac_ar_proj[(Frame_Electric) & (sampled_kWh =='Y' | (net_cmplt_kWh)) & is.na(ea_AR_kWh),c('ea_AR_kWh','ea_AR_kW'):=0]
dt_ciac_ar_proj[(Frame_Electric) & (sampled_kWh =='Y' | (net_cmplt_kWh)) & is.na(ep_AR_kWh),c('ep_AR_kWh','ep_AR_kW'):=0]
dt_ciac_ar_proj[(Frame_Gas) & (sampled_thm =='Y' | (net_cmplt_thm)) & is.na(ea_AR_thm),ea_AR_thm:=0]
dt_ciac_ar_proj[(Frame_Gas) & (sampled_thm =='Y' | (net_cmplt_thm)) & is.na(ep_AR_thm),ep_AR_thm:=0]
dt_ciac_ar_proj[(Frame_Electric),wi_ea_pct_AR_kWh:=wi_kWh*ea_pct_AR_kWh]
dt_ciac_ar_proj[(Frame_Electric),wi_ea_pct_AR_kW:=wi_kW*ea_pct_AR_kW]
dt_ciac_ar_proj[(Frame_Gas),wi_ea_pct_AR_thm:=wi_thm*ea_pct_AR_thm]
dt_ciac_ar_proj[(Frame_Electric),wi_ep_pct_AR_kWh:=wi_kWh*ep_pct_AR_kWh]
dt_ciac_ar_proj[(Frame_Electric),wi_ep_pct_AR_kW:=wi_kW*ep_pct_AR_kW]
dt_ciac_ar_proj[(Frame_Gas),wi_ep_pct_AR_thm:=wi_thm*ep_pct_AR_thm]

strat_smry_ar_el <- dt_ciac_ar_proj[(Frame_Electric) & (sampled_kWh =='Y' | (net_cmplt_kWh)),.(n_h=length(SampleID),
                            str_ea_pct_AR_kWh=sum(wi_ea_pct_AR_kWh,na.rm=T),
                            str_ea_pct_AR_kW=sum(wi_ea_pct_AR_kW,na.rm=T),
                            str_ep_pct_AR_kWh=sum(wi_ep_pct_AR_kWh,na.rm=T),
                            str_ep_pct_AR_kW=sum(wi_ep_pct_AR_kW,na.rm=T),
                            mean_ea_LCNet_kWh=mean(ea_LCNet_kWh,na.rm=T),mean_ea_LCNet_kW=mean(ea_LCNet_kW,na.rm=T),
                            mean_ep_LCNet_kWh=mean(ep_LCNet_kWh,na.rm=T),mean_ep_LCNet_kW=mean(ep_LCNet_kW,na.rm=T),
                            mean_ep_AnnNet_kWh=mean(ep_AnnNet_kWh,na.rm=T),mean_ep_AnnNet_kW=mean(ep_AnnNet_kW,na.rm=T)
),
by=c('PA','domain','stratum_kWh')][
  dt_ciac_ar_proj[(Frame_Electric),.(pop_h=length(SampleID)),by=c('PA','domain','stratum_kWh')],on=c('PA','domain','stratum_kWh')][
    dt_ciac_ar_proj[(Frame_Electric),.(pop=length(SampleID)),
                    by=c('PA','domain')],on=c('PA','domain')]
dom_smry_ar_el <- strat_smry_ar_el[,.(dom_pop=sum(pop,na.rm=T),exante_pct_AR_kWh=sum(pop_h*str_ea_pct_AR_kWh,na.rm=T)/sum(pop_h,na.rm=T),
                                      exante_pct_AR_kW=sum(pop_h*str_ea_pct_AR_kW,na.rm=T)/sum(pop_h,na.rm=T),
                                      dom_ea_LCNet_kWh=sum(pop*mean_ea_LCNet_kWh,na.rm=T),
                                      dom_ea_LCNet_kW=sum(pop*mean_ea_LCNet_kW,na.rm=T),
                                      expost_pct_AR_kWh=sum(pop_h*str_ep_pct_AR_kWh,na.rm=T)/sum(pop_h,na.rm=T),
                                      expost_pct_AR_kW=sum(pop_h*str_ep_pct_AR_kW,na.rm=T)/sum(pop_h,na.rm=T),
                                      dom_ep_LCNet_kWh=sum(pop*mean_ep_LCNet_kWh,na.rm=T),
                                      dom_ep_LCNet_kW=sum(pop*mean_ep_LCNet_kW,na.rm=T),
                                      dom_ep_AnnNet_kWh=sum(pop*mean_ep_AnnNet_kWh,na.rm=T),
                                      dom_ep_AnnNet_kW=sum(pop*mean_ep_AnnNet_kW,na.rm=T)),
                                   by=c('PA','domain')]
dom_smry_ar_el[,expost_avg_EUL_kWh:=dom_ep_LCNet_kWh/dom_ep_AnnNet_kWh]
dom_smry_ar_el[,expost_avg_EUL_kW:=dom_ep_LCNet_kW/dom_ep_AnnNet_kW]

strat_smry_ar_gas <- dt_ciac_ar_proj[(Frame_Gas) & (sampled_thm=='Y' | (net_cmplt_thm)),.(n_h=length(SampleID),
                              str_ea_pct_AR_thm=sum(wi_ea_pct_AR_thm,na.rm=T),
                              str_ep_pct_AR_thm=sum(wi_ep_pct_AR_thm,na.rm=T),
                              mean_ea_LCNet_thm=mean(ea_LCNet_thm,na.rm=T),
                              mean_ep_LCNet_thm=mean(ep_LCNet_thm,na.rm=T),
                              mean_ep_AnnNet_thm=mean(ep_AnnNet_thm,na.rm=T)),
by=c('PA','domain','stratum_thm')][
  dt_ciac_ar_proj[(Frame_Gas),.(pop_h=length(SampleID)),by=c('PA','domain','stratum_thm')],on=c('PA','domain','stratum_thm')][
    dt_ciac_ar_proj[(Frame_Gas),.(pop=length(SampleID)),
                    by=c('PA','domain')],on=c('PA','domain')]
dom_smry_ar_gas <- strat_smry_ar_gas[,.(dom_pop=sum(pop,na.rm=T),exante_pct_AR_thm=sum(pop_h*str_ea_pct_AR_thm,na.rm=T)/sum(pop_h,na.rm=T),
                                      dom_ea_LCNet_thm=sum(pop*mean_ea_LCNet_thm,na.rm=T),
                                      expost_pct_AR_thm=sum(pop_h*str_ep_pct_AR_thm,na.rm=T)/sum(pop_h,na.rm=T),
                                      dom_ep_LCNet_thm=sum(pop*mean_ep_LCNet_thm,na.rm=T),
                                      dom_ep_AnnNet_thm=sum(pop*mean_ep_AnnNet_thm,na.rm=T)),
                                   by=c('PA','domain')]
dom_smry_ar_gas[,expost_avg_EUL_thm:=dom_ep_LCNet_thm/dom_ep_AnnNet_thm]

dom_smry_ar <- merge(dom_smry_ar_el,dom_smry_ar_gas,all=T,by=c('PA','domain'),suffixes = c('_kWh','_thm'))
keep_cols_ar_dom <- c('exante_pct_AR_kWh','exante_pct_AR_kW','exante_pct_AR_thm',
                      'expost_pct_AR_kWh','expost_pct_AR_kW','expost_pct_AR_thm',
                      'expost_avg_EUL_kWh','expost_avg_EUL_kW','expost_avg_EUL_thm')
pct_AR_cols <- colnames(dom_smry_ar)[grep('AR',colnames(dom_smry_ar))]
dom_smry_ar[,(pct_AR_cols):=lapply(.SD,function(x)ifelse(is.infinite(x),0,x)),.SDcols=pct_AR_cols]

dom_smry_all <- dom_smry_ar[,c('PA','domain',keep_cols_ar_dom),with=F][dom_smry_all,on=c('PA','domain')]
keep_cols <- colnames(dom_smry_all)[!grepl('_n_net|pop_net|_Wh|ep|ea_|PA_|gr_',colnames(dom_smry_all))]
dom_smry_all[,c('domain',keep_cols[grepl('AR',keep_cols)]),with=F]
RP_NTGR_cols <- colnames(dom_smry_all)[grep('RP.*NTGR',colnames(dom_smry_all))]
dom_smry_all[,RP_NTGR_cols,with=F]
dom_smry_all[,(RP_NTGR_cols):=lapply(.SD,function(x)ifelse(is.nan(x),NA,x)),.SDcols=RP_NTGR_cols]
write.csv(dom_smry_all[,keep_cols,with=F],file=fname_export_dom,row.names = F)

## roll up to PA level ----
## Gross
PA_Gross_smry <- fread(fname_import_PA)
## Net
PA_AnnNet_smry_el <- strat.mean.estimator(dt_ciac_proj,frame='Electric',period='1stYear',return_PA = T)
PA_AnnNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,frame='Gas',period='1stYear',return_PA = T)
PA_AnnNet_smry <- merge(PA_AnnNet_smry_el,PA_AnnNet_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                         by=c('PA'))
PA_LCNet_smry_el <- strat.mean.estimator(dt_ciac_proj,frame='Electric',period='Lifecycle',return_PA = T)
PA_LCNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,frame='Gas',period='Lifecycle',return_PA = T)
PA_LCNet_smry <- merge(PA_LCNet_smry_el,PA_LCNet_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                        by=c('PA'))
PA_Net_smry <- merge(PA_AnnNet_smry,PA_LCNet_smry,all=T,suffixes = c('_AN','_LN'),
                      by=c('PA','PA_pop_net_kWh','PA_n_net_kWh','PA_cmplt_net_kWh',
                           'PA_pop_net_thm','PA_n_net_thm','PA_cmplt_net_thm'))
ntgr_cols <- colnames(PA_Net_smry)[grep('PA_mean_eval_NTGR',colnames(PA_Net_smry))]
ntgr_cols_new <- gsub('_mean_eval_','_',ntgr_cols)
setnames(PA_Net_smry,ntgr_cols,ntgr_cols_new)
ntgr_cols <- colnames(PA_Net_smry)[grep('NTGR',colnames(PA_Net_smry))]
ntgr_cols_new <- gsub('_AN','_Ann',ntgr_cols)
ntgr_cols_new <- gsub('_LN','_LC',ntgr_cols_new)
setnames(PA_Net_smry,ntgr_cols,ntgr_cols_new)

PA_Net_smry <- PA_Net_smry[dom_Net_smry[,.(PA_rp_kWh_AN=roll_up(dom_eval_svgs_kWh_AN,RP_dom_NTGR_kWh_AN),
                                                 PA_rp_kW_AN=roll_up(dom_eval_svgs_kW_AN,RP_dom_NTGR_kW_AN),
                                                 PA_rp_thm_AN=roll_up(dom_eval_svgs_thm_AN,RP_dom_NTGR_thm_AN),
                                                 PA_rp_kWh_LN=roll_up(dom_eval_svgs_kWh_LN,RP_dom_NTGR_kWh_LN),
                                                 PA_rp_kW_LN=roll_up(dom_eval_svgs_kW_LN,RP_dom_NTGR_kW_LN),
                                                 PA_rp_thm_LN=roll_up(dom_eval_svgs_thm_LN,RP_dom_NTGR_thm_LN)),by='PA'],on='PA']
PA_smry <- PA_Net_smry[PA_Gross_smry,on='PA']
PA_smry[,c('PA',colnames(PA_smry)[grep('rr|ntgr',colnames(PA_smry),ignore.case = T)]),with=F]

PA_smry_ar <- dom_smry_ar[,.(PA_exante_pct_AR_kWh=sum(dom_pop_kWh*exante_pct_AR_kWh,na.rm=T)/sum(dom_pop_kWh,na.rm=T),
                             PA_exante_pct_AR_kW=sum(dom_pop_kWh*exante_pct_AR_kW,na.rm=T)/sum(dom_pop_kWh,na.rm=T),
                             PA_exante_pct_AR_thm=sum(dom_pop_thm*exante_pct_AR_thm,na.rm=T)/sum(dom_pop_thm,na.rm=T),
                             PA_exante_LCNet_kWh=sum(dom_ea_LCNet_kWh,na.rm=T),
                             PA_exante_LCNet_kW=sum(dom_ea_LCNet_kW,na.rm=T),
                             PA_exante_LCNet_thm=sum(dom_ea_LCNet_thm,na.rm=T),
                             PA_expost_pct_AR_kWh=sum(dom_pop_kWh*expost_pct_AR_kWh,na.rm=T)/sum(dom_pop_kWh,na.rm=T),
                             PA_expost_pct_AR_kW=sum(dom_pop_kWh*expost_pct_AR_kW,na.rm=T)/sum(dom_pop_kWh,na.rm=T),
                             PA_expost_pct_AR_thm=sum(dom_pop_thm*expost_pct_AR_thm,na.rm=T)/sum(dom_pop_thm,na.rm=T),
                             PA_ep_LCNet_kWh=sum(dom_ep_LCNet_kWh,na.rm=T),
                             PA_ep_LCNet_kW=sum(dom_ep_LCNet_kW,na.rm=T),
                             PA_ep_LCNet_thm=sum(dom_ep_LCNet_thm,na.rm=T),
                             PA_ep_AnnNet_kWh=sum(dom_ep_AnnNet_kWh,na.rm=T),
                             PA_ep_AnnNet_kW=sum(dom_ep_AnnNet_kW,na.rm=T),
                             PA_ep_AnnNet_thm=sum(dom_ep_AnnNet_thm,na.rm=T),
                             # PA_expost_AR_kWh=sum(expost_AR_kWh,na.rm=T),
                             # PA_expost_AR_kW=sum(expost_AR_kW,na.rm=T),
                             # PA_expost_AR_thm=sum(expost_AR_thm,na.rm=T)
                             PA_pop_kWh=sum(dom_pop_kWh,na.rm=T),PA_pop_thm=sum(dom_pop_thm,na.rm=T)),by=PA]
PA_smry_ar[,PA_expost_EUL_kWh:=PA_ep_LCNet_kWh/PA_ep_AnnNet_kWh]
PA_smry_ar[,PA_expost_EUL_kW:=PA_ep_LCNet_kW/PA_ep_AnnNet_kW]
PA_smry_ar[,PA_expost_EUL_thm:=PA_ep_LCNet_thm/PA_ep_AnnNet_thm]
keep_cols_ar_PA <- paste0(rep('PA_',12),keep_cols_ar_dom)
keep_cols_ar_PA <- gsub('avg_','',keep_cols_ar_PA)

PA_smry <- PA_smry_ar[,c('PA',keep_cols_ar_PA),with=F][PA_smry,on='PA']

PA_exante_Net_smry_el <- dt_ciac_proj[(Frame_Electric),.(PA_exante_kWh_AN=sum(ea_AnnNet_kWh,na.rm=T),PA_exante_kW_AN=sum(ea_AnnNet_kW,na.rm=T),
                PA_exante_svgs_kWh_LN=sum(ea_LCNet_kWh,na.rm=T),PA_exante_svgs_kW_LN=sum(ea_LCNet_kW,na.rm=T)),by=c('PA')]
PA_exante_Net_smry_gas <- dt_ciac_proj[(Frame_Gas),.(PA_exante_svgs_thm_AN=sum(ea_AnnNet_thm,na.rm=T),
                                                      PA_exante_svgs_thm_LN=sum(ea_LCNet_thm,na.rm=T)),by=c('PA')]
PA_exante_Net_smry <- merge(PA_exante_Net_smry_el,PA_exante_Net_smry_gas,all=T,by=c('PA'))
PA_smry <- PA_exante_Net_smry[PA_smry,on=c('PA')]

write.csv(PA_smry,fname_export_PA,row.names = F)

## roll up to SW level----
SW_AnnNet_smry_el <- strat.mean.estimator(dt_ciac_proj,frame='Electric',period='1stYear',return_SW = T)
setnames(SW_AnnNet_smry_el,c('SW_n_net','SW_cmplt_net'),c('SW_n_net_kWh','SW_cmplt_net_kWh'))
SW_AnnNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,frame='Gas',period='1stYear',return_SW = T)
setnames(SW_AnnNet_smry_gas,c('SW_n_net','SW_cmplt_net'),c('SW_n_net_thm','SW_cmplt_net_thm'))
SW_AnnNet_smry <- cbind(SW_AnnNet_smry_el,SW_AnnNet_smry_gas)
cols <- setdiff(colnames(SW_AnnNet_smry),colnames(SW_AnnNet_smry)[grep('_n_|_cmplt_',colnames(SW_AnnNet_smry))])
cols_new <- paste0(cols,rep('_AN',6))
setnames(SW_AnnNet_smry,cols,cols_new)

SW_LCNet_smry_el <- strat.mean.estimator(dt_ciac_proj,frame='Electric',period='Lifecycle',return_SW = T)
SW_LCNet_smry_el[,c('SW_n_net','SW_cmplt_net'):=NULL]
SW_LCNet_smry_gas <- strat.mean.estimator(dt_ciac_proj,frame='Gas',period='Lifecycle',return_SW = T)
SW_LCNet_smry_gas[,c('SW_n_net','SW_cmplt_net'):=NULL]
SW_LCNet_smry <- cbind(SW_LCNet_smry_el,SW_LCNet_smry_gas)
cols <- setdiff(colnames(SW_LCNet_smry),colnames(SW_LCNet_smry)[grep('_n_|_cmplt_',colnames(SW_LCNet_smry))])
cols_new <- paste0(cols,rep('_LN',6))
setnames(SW_LCNet_smry,cols,cols_new)

SW_Net_smry <- cbind(SW_AnnNet_smry,SW_LCNet_smry)

ntgr_cols <- colnames(SW_Net_smry)[grep('SW_mean_eval_NTGR',colnames(SW_Net_smry))]
ntgr_cols_new <- gsub('_mean_eval_','_',ntgr_cols)
setnames(SW_Net_smry,ntgr_cols,ntgr_cols_new)
ntgr_cols <- colnames(SW_Net_smry)[grep('NTGR',colnames(SW_Net_smry))]
ntgr_cols_new <- gsub('_AN','_Ann',ntgr_cols)
ntgr_cols_new <- gsub('_LN','_LC',ntgr_cols_new)
setnames(SW_Net_smry,ntgr_cols,ntgr_cols_new)

SW_Net_smry <- cbind(SW_Net_smry,PA_Net_smry[,.(SW_rp_kWh_AN=roll_up(PA_eval_svgs_kWh_AN,PA_rp_kWh_AN),
                                                      SW_rp_kW_AN=roll_up(PA_eval_svgs_kW_AN,PA_rp_kW_AN),
                                                      SW_rp_thm_AN=roll_up(PA_eval_svgs_thm_AN,PA_rp_thm_AN),
                                                      SW_rp_kWh_LN=roll_up(PA_eval_svgs_kWh_LN,PA_rp_kWh_LN),
                                                      SW_rp_kW_LN=roll_up(PA_eval_svgs_kW_LN,PA_rp_kW_LN),
                                                      SW_rp_thm_LN=roll_up(PA_eval_svgs_thm_LN,PA_rp_thm_LN))])

SW_Gross_smry <-fread(fname_import_SW)
SW_smry <- cbind(SW_Gross_smry,SW_Net_smry)
SW_smry[,colnames(SW_smry)[grepl('rp',colnames(SW_smry),ignore.case = T) & !grepl('kW_',colnames(SW_smry))],with=F]
SW_smry[,colnames(SW_smry)[grep('RR|NTGR',colnames(SW_smry))],with=F]

SW_smry_ar <- PA_smry_ar[,.(SW_exante_pct_AR_kWh=sum(PA_pop_kWh*PA_exante_pct_AR_kWh,na.rm=T)/sum(PA_pop_kWh,na.rm=T),
                            SW_exante_pct_AR_kW=sum(PA_pop_kWh*PA_exante_pct_AR_kW,na.rm=T)/sum(PA_pop_kWh,na.rm=T),
                            SW_exante_pct_AR_thm=sum(PA_pop_thm*PA_exante_pct_AR_thm,na.rm=T)/sum(PA_pop_thm,na.rm=T),
                             SW_exante_LCNet_kWh=sum(PA_exante_LCNet_kWh,na.rm=T),
                             SW_exante_LCNet_kW=sum(PA_exante_LCNet_kW,na.rm=T),
                             SW_exante_LCNet_thm=sum(PA_exante_LCNet_thm,na.rm=T),
                            SW_expost_pct_AR_kWh=sum(PA_pop_kWh*PA_expost_pct_AR_kWh,na.rm=T)/sum(PA_pop_kWh,na.rm=T),
                            SW_expost_pct_AR_kW=sum(PA_pop_kWh*PA_expost_pct_AR_kW,na.rm=T)/sum(PA_pop_kWh,na.rm=T),
                            SW_expost_pct_AR_thm=sum(PA_pop_thm*PA_expost_pct_AR_thm,na.rm=T)/sum(PA_pop_thm,na.rm=T),
                            SW_ep_LCNet_kWh=sum(PA_ep_LCNet_kWh,na.rm=T),
                            SW_ep_LCNet_kW=sum(PA_ep_LCNet_kW,na.rm=T),
                             SW_ep_LCNet_thm=sum(PA_ep_LCNet_thm,na.rm=T),
                             SW_ep_AnnNet_kWh=sum(PA_ep_AnnNet_kWh,na.rm=T),
                             SW_ep_AnnNet_kW=sum(PA_ep_AnnNet_kW,na.rm=T),
                             SW_ep_AnnNet_thm=sum(PA_ep_AnnNet_thm,na.rm=T))]
SW_smry_ar[,SW_expost_EUL_kWh:=SW_ep_LCNet_kWh/SW_ep_AnnNet_kWh]
SW_smry_ar[,SW_expost_EUL_kW:=SW_ep_LCNet_kWh/SW_ep_AnnNet_kW]
SW_smry_ar[,SW_expost_EUL_thm:=SW_ep_LCNet_thm/SW_ep_AnnNet_thm]
keep_cols_ar_SW <- paste0(rep('SW_',12),keep_cols_ar_dom)
keep_cols_ar_SW <- gsub('avg_','',keep_cols_ar_SW)

SW_smry <- cbind(SW_smry_ar[,keep_cols_ar_SW,with=F],SW_smry)
SW_exante_Net_smry_el <- dt_ciac_proj[(Frame_Electric),.(SW_exante_kWh_AN=sum(ea_AnnNet_kWh,na.rm=T),SW_exante_kW_AN=sum(ea_AnnNet_kW,na.rm=T),
                SW_exante_svgs_kWh_LN=sum(ea_LCNet_kWh,na.rm=T),SW_exante_svgs_kW_LN=sum(ea_LCNet_kW,na.rm=T))]
SW_exante_Net_smry_gas <- dt_ciac_proj[(Frame_Gas),.(SW_exante_svgs_thm_AN=sum(ea_AnnNet_thm,na.rm=T),
                                                      SW_exante_svgs_thm_LN=sum(ea_LCNet_thm,na.rm=T))]
SW_smry <- cbind(SW_smry,SW_exante_Net_smry_el,SW_exante_Net_smry_gas)
SW_smry[,colnames(SW_smry)[grep('AR',colnames(SW_smry))],with=F]
write.csv(SW_smry,fname_export_SW,row.names = F)

PA_smry[,c('PA',colnames(PA_smry)[grep('(rp)|(NTGR.*_LC)',colnames(PA_smry))]),with=F]

