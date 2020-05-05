library(data.table)

fname_ciac_gr <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/gross_claim.csv'
fname_export_projGross <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/proj_pop_gross.csv'
fname_export_domGr <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/domain_gross_summary.csv'
fname_export_PA <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/PA_Gross_summary.csv'
fname_export_SW <- 'Z:/Favorites/CPUC10 (Group D - Custom EM&V)/8 PII/11 - Draft and Final Evaluation Reports/CIAC2018/Data/SW_Gross_summary.csv'
# conf <- 0.9

source('Z:/Favorites/CPUC10 (Group D - Custom EM&V)/4 Deliverables/09 - Ex-Post Evaluated Gross Savings Estimates/CIAC/2018 Evaluation/Extrapolation/Strat_ratio_estimator.R')
roll_up <- function(savings,rp){
  return(sqrt(sum((savings*rp)^2,na.rm=T))/sum(savings,na.rm=T))
}

dt_ciac_gr <- fread(file=fname_ciac_gr)

dt_ciac_proj_gr <- dt_ciac_gr[,.(meas_ct=length(ClaimID),ea_AnnGross_kWh=sum(ExAnte_Annualized_kWh,na.rm=T),ea_AnnGross_kW=sum(ExAnte_Annualized_kW,na.rm=T),
                           ea_LCGross_kWh=sum(ExAnte_LifeCycleGross_NoRR_kWh,na.rm=T),ea_LCGross_kW=sum(ExAnte_LifeCycleGross_NoRR_kW,na.rm=T),
                           ea_AnnGross_thm=sum(ExAnte_Annualized_thm,na.rm=T),ea_LCGross_thm=sum(ExAnte_LifeCycleGross_NoRR_thm,na.rm=T),
                           ea_AnnNet_kWh=sum(ExAnte_Annualized_Net_NoRR_kWh,na.rm=T),ea_AnnNet_kW=sum(ExAnte_Annualized_Net_NoRR_kW,na.rm=T),
                           ea_LCNet_kWh=sum(ExAnte_LifeCycleNet_NoRR_kWh,na.rm=T),ea_LCNet_kW=sum(ExAnte_LifeCycleNet_NoRR_kW,na.rm=T),
                           ea_AnnNet_thm=sum(ExAnte_Annualized_Net_NoRR_thm,na.rm=T),ea_LCNet_thm=sum(ExAnte_LifeCycleNet_NoRR_thm,na.rm=T),
                           ep_AnnGross_kWh=sum(EvalExPostAnnualizedGrosskWh,na.rm=T),ep_AnnGross_kW=sum(EvalExPostAnnualizedGrosskW,na.rm=T),
                           ep_LCGross_kWh=sum(EvalExPostLifeCycleGrosskWh,na.rm=T),ep_LCGross_kW=sum(EvalExPostLifeCycleGrosskW,na.rm=T),
                           ep_AnnGross_thm=sum(EvalExPostAnnualizedGrossTherm,na.rm=T),ep_LCGross_thm=sum(EvalExPostLifeCycleGrossTherm,na.rm=T),
                           # ep_NTGR_kWh=mean(st_EvalNTGRkWh,na.rm=T),ep_NTGR_kW=mean(st_EvalNTGRkW,na.rm=T),ep_NTGR_thm=mean(st_EvalNTGRTherm,na.rm=T),
                           GrossCompl=max(SavingsAnalysisComplQC,na.rm=T),ea_EUL_kWh=mean(prj_ExAnte_EUL_kwh,na.rm=T),ea_EUL_thm=mean(prj_ExAnte_EUL_thm,na.rm=T),
                           ep_EUL_kWh=mean(prj_EvalEUL_Yrs_kwh,na.rm=T),ep_EUL_thm=mean(prj_EvalEUL_Yrs_thm,na.rm=T)),
                           by=c('domain','PA','SBW_ProjID','Frame_Electric','Frame_Gas','stratum_kWh','stratum_thm','sampled_kWh','sampled_thm','SampleID','Sampled',
                                'smpld_net','smpld_net_kWh','smpld_net_thm','smpld_net_new','NetSurveyComplete')]

# dt_ciac_proj_gr[!is.na((Frame_Electric)) & !is.na((Frame_Gas)),.N]
dt_ciac_proj <- dt_ciac_proj_gr[!is.na(Frame_Electric) & !is.na(Frame_Gas)]

## domain level results----
dom_AnnGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,period='1stYear',frame='Electric')
dom_AnnGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,period='1stYear',frame='Gas')
dom_AnnGross_smry <- merge(dom_AnnGross_smry_el,dom_AnnGross_smry_gas,by=c('PA','domain'),all=T,suffixes = c('_kWh','_thm'))

dom_LCGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,period='LifeCycle',frame='Electric')
dom_LCGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,period='LifeCycle',frame='Gas')
dom_LCGross_smry <- merge(dom_LCGross_smry_el,dom_LCGross_smry_gas,by=c('PA','domain'),all=T,suffixes = c('_kWh','_thm'))

dom_Gross_smry <- merge(dom_AnnGross_smry,dom_LCGross_smry,all=T,suffixes=c('_AG','_LG'),
                        by=c('PA','domain','dom_pop_kWh','dom_n_kWh','dom_cmplt_kWh',
                             'dom_pop_thm','dom_n_thm','dom_cmplt_thm'))
drop_cols_dom <- colnames(dom_Gross_smry)[grep('var_|se_|eb_|sd_|lb|ub|CI|^r_|_r_|wtd',colnames(dom_Gross_smry))]
keep_cols_dom <- setdiff(colnames(dom_Gross_smry),drop_cols_dom)
write.csv(dom_Gross_smry[,keep_cols_dom,with=F],fname_export_domGr,row.names = F)

dom_Gross_smry[,c('domain',colnames(dom_Gross_smry)[grep('eval_RR|rp_dom',colnames(dom_Gross_smry))]),with=F]

## domain results apply to project level
dt_ciac_proj_gr_out <- merge(dom_Gross_smry[,c('PA','domain',colnames(dom_Gross_smry)[grepl('RR',colnames(dom_Gross_smry))]),with=F],dt_ciac_proj,by=c('PA','domain'),all=T)
write.csv(dt_ciac_proj_gr_out,fname_export_projGross,row.names = F)

## PA Roll up----
PA_AnnGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,frame='Electric',period='1stYear',return_PA = T)
PA_AnnGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,frame='Gas',period='1stYear',return_PA = T)
PA_AnnGross_smry <- merge(PA_AnnGross_smry_el,PA_AnnGross_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                         by=c('PA'))
PA_LCGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,frame='Electric',period='Lifecyle',return_PA = T)
PA_LCGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,frame='Gas',period='Lifecyle',return_PA = T)
PA_LCGross_smry <- merge(PA_LCGross_smry_el,PA_LCGross_smry_gas,all=T,suffixes=c('_kWh','_thm'),
                         by=c('PA'))
PA_Gross_smry <- merge(PA_AnnGross_smry,PA_LCGross_smry,all=T,suffixes = c('_AG','_LG'),
                      by=c('PA','PA_pop_kWh','PA_n_kWh','PA_cmplt_kWh',
                           'PA_pop_thm','PA_n_thm','PA_cmplt_thm'))
PA_Gross_smry <- PA_Gross_smry[dom_Gross_smry[,.(PA_rp_kWh_AG=roll_up(dom_eval_gross_svgs_kWh_AG,rp_svgs_dom_kWh_AG),
                                                 PA_rp_kW_AG=roll_up(dom_eval_gross_svgs_kW_AG,rp_svgs_dom_kW_AG),
                                                 PA_rp_thm_AG=roll_up(dom_eval_gross_svgs_thm_AG,rp_svgs_dom_thm_AG),
                                                 PA_rp_kWh_LG=roll_up(dom_eval_gross_svgs_kWh_LG,rp_svgs_dom_kWh_LG),
                                                 PA_rp_kW_LG=roll_up(dom_eval_gross_svgs_kW_LG,rp_svgs_dom_kW_LG),
                                                 PA_rp_thm_LG=roll_up(dom_eval_gross_svgs_thm_LG,rp_svgs_dom_thm_LG)),by='PA'],on='PA']

PA_Gross_smry[,c('PA',colnames(PA_Gross_smry)[grep('RR|rp',colnames(PA_Gross_smry))]),with=F]

grr_cols <- colnames(PA_Gross_smry)[grep('RR',colnames(PA_Gross_smry))]
grr_cols_new <- gsub('_eval_','_',grr_cols)
setnames(PA_Gross_smry,grr_cols,grr_cols_new)
grr_cols <- colnames(PA_Gross_smry)[grep('gross',colnames(PA_Gross_smry))]
grr_cols_new <- gsub('gross_','',grr_cols)
setnames(PA_Gross_smry,grr_cols,grr_cols_new)
grr_cols <- colnames(PA_Gross_smry)[grep('exante',colnames(PA_Gross_smry))]
grr_cols_new <- gsub('exante_','exante_svgs_',grr_cols)
setnames(PA_Gross_smry,c(grr_cols,'PA_n_kWh','PA_cmplt_kWh','PA_n_thm','PA_cmplt_thm'),c(grr_cols_new,'PA_n_gr_kWh','PA_cmplt_gr_kWh','PA_n_gr_thm','PA_cmplt_gr_thm'))
PA_Gross_smry[,c('PA',colnames(PA_Gross_smry)[grep('RR|rp',colnames(PA_Gross_smry))]),with=F]
write.csv(PA_Gross_smry,fname_export_PA,row.names = F)

## SW Roll up----
## Annualized
SW_AnnGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,frame='Electric',period='1stYear',return_SW = T)
gross_cols <- colnames(SW_AnnGross_smry_el)[!grepl('kW',colnames(SW_AnnGross_smry_el))]
new_gross_cols <- paste0(gross_cols,rep('_kWh',3))
setnames(SW_AnnGross_smry_el,gross_cols,new_gross_cols)
SW_AnnGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,frame='Gas',period='1stYear',return_SW = T)
gross_cols <- colnames(SW_AnnGross_smry_gas)[!grepl('thm',colnames(SW_AnnGross_smry_gas))]
new_gross_cols <- paste0(gross_cols,rep('_thm',3))
setnames(SW_AnnGross_smry_gas,gross_cols,new_gross_cols)
SW_AnnGross_smry <- cbind(SW_AnnGross_smry_el,SW_AnnGross_smry_gas)
ann_cols <- setdiff(colnames(SW_AnnGross_smry),c('domain','SW_pop_kWh','SW_n_kWh','SW_cmplt_kWh','SW_pop_thm','SW_n_thm','SW_cmplt_thm'))
setnames(SW_AnnGross_smry,ann_cols,paste0(ann_cols,'_AG'))

## Lifecycle
SW_LCGross_smry_el <- strat.ratio.estimator(dt_ciac_proj,frame='Electric',period='Lifecyle',return_SW = T)
gross_cols <- colnames(SW_LCGross_smry_el)[!grepl('kW',colnames(SW_LCGross_smry_el))]
new_gross_cols <- paste0(gross_cols,rep('_kWh',3))
setnames(SW_LCGross_smry_el,gross_cols,new_gross_cols)
SW_LCGross_smry_gas <- strat.ratio.estimator(dt_ciac_proj,frame='Gas',period='Lifecyle',return_SW = T)
gross_cols <- colnames(SW_LCGross_smry_gas)[!grepl('thm',colnames(SW_LCGross_smry_gas))]
new_gross_cols <- paste0(gross_cols,rep('_thm',3))
setnames(SW_LCGross_smry_gas,gross_cols,new_gross_cols)
SW_LCGross_smry <- cbind(SW_LCGross_smry_el,SW_LCGross_smry_gas)
LC_cols <- setdiff(colnames(SW_LCGross_smry),c('domain','SW_pop_kWh','SW_n_kWh','SW_cmplt_kWh','SW_pop_thm','SW_n_thm','SW_cmplt_thm'))
setnames(SW_LCGross_smry,LC_cols,paste0(LC_cols,'_LG'))

## combine Annualized and Lifecycle
SW_Gross_smry <- cbind(SW_AnnGross_smry,SW_LCGross_smry[,setdiff(colnames(SW_LCGross_smry),colnames(SW_AnnGross_smry)),with=F])
SW_Gross_smry <- cbind(SW_Gross_smry,PA_Gross_smry[,.(SW_rp_kWh_AG=roll_up(PA_eval_svgs_kWh_AG,PA_rp_kWh_AG),
                                                      SW_rp_kW_AG=roll_up(PA_eval_svgs_kW_AG,PA_rp_kW_AG),
                                                      SW_rp_thm_AG=roll_up(PA_eval_svgs_thm_AG,PA_rp_thm_AG),
                                                      SW_rp_kWh_LG=roll_up(PA_eval_svgs_kWh_LG,PA_rp_kWh_LG),
                                                      SW_rp_kW_LG=roll_up(PA_eval_svgs_kW_LG,PA_rp_kW_LG),
                                                      SW_rp_thm_LG=roll_up(PA_eval_svgs_thm_LG,PA_rp_thm_LG))])

grr_cols <- colnames(SW_Gross_smry)[grep('RR',colnames(SW_Gross_smry))]
grr_cols_new <- gsub('_eval_','_',grr_cols)
setnames(SW_Gross_smry,grr_cols,grr_cols_new)
grr_cols <- colnames(SW_Gross_smry)[grep('gross',colnames(SW_Gross_smry))]
grr_cols_new <- gsub('gross_','',grr_cols)
setnames(SW_Gross_smry,grr_cols,grr_cols_new)
grr_cols <- colnames(SW_Gross_smry)[grep('exante',colnames(SW_Gross_smry))]
grr_cols_new <- gsub('exante_','exante_svgs_',grr_cols)
setnames(SW_Gross_smry,c(grr_cols,'SW_n_kWh','SW_cmplt_kWh','SW_n_thm','SW_cmplt_thm'),c(grr_cols_new,'SW_n_gr_kWh','SW_cmplt_gr_kWh','SW_n_gr_thm','SW_cmplt_gr_thm'))
write.csv(SW_Gross_smry,fname_export_SW,row.names = F)
