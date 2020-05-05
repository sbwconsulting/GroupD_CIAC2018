#Create the final ATR export file
import logging

from sqlalchemy.sql import select
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import sqlalchemy as db
import pandas as pd
import locale
from locale import atof

from cpuc.db import engine
from cpuc.mylogging import create_logfile
import cpuc.params as params
from cpuc.models import Base
from cpuc.models import Measure
from cpuc.models import Sample
from cpuc.models import Study
from cpuc.workbookfunctions import convertwstodf
from cpuc.workbookfunctions import openworkbook
from cpuc.workbookfunctions import getSampleControlFile

Session = sessionmaker(bind=engine)

def createEvalResults(session, WriteFinalFile = False):
    
#create sample file
    data = pd.read_csv(params.D0_DATA_FILE)
    # Exclude replaced measurements
    not_replaced = data[data.Replaced != 'Yes']
    # Pick only sampled rows
    sample_list = not_replaced[not_replaced.sampled == 'Y']
    # Group by SampleID and SBW_ProjID
    sample_groups = sample_list.groupby(['SampleID','SBW_ProjID']).size().reset_index().rename(columns={0:''})
    sample_groups = sample_groups.rename(columns={'': 'msrcount'})
    sample_groups = sample_groups.astype({'SampleID':int})
    #read data from database
    df_control = getSampleControlFile()
    df_control = df_control[df_control['ProjectStatus'] == 'Complete']
    #join together so have complete and projectids
    mylist = df_control.set_index('SampleID').join(sample_groups.set_index('SampleID'), how='left', lsuffix='_msr')
    #print('MYLIST TYPE IS {}'.format(mylist))
    #print('list cols:{}'.format(mylist.columns))
    msrheaders = ['SBW_ProjID', 'ProjectStatus', 'msrcount'] 
    mylist = mylist[msrheaders]
    
    print('complete list shape: {}'.format(mylist.shape))
    #print(mylist)
    #s.query(User).filter(User.name == 'Mariana').one()
    #msrs = session.query(Measure).all()
    #print('msr type is {}'.format(type(msrs)))
    #df_msrs = pd.DataFrame(session.query(Measure).all())
    df_msrs = pd.read_sql(session.query(Measure).statement, session.bind)
    #print('msr type: {}'.format(type(df_msrs)))
    #mylist.set_index('SBW_ProjID', inplace=True)
    #df_msrs.set_index('SBW_ProjID', inplace=True)
    df_complete_msrs = mylist.set_index('SBW_ProjID').join(df_msrs.set_index('SBW_ProjID'), how='left', lsuffix='_msr')
    #df_complete_msrs = mylist.join(df_msrs, how='left', lsuffix='_msr')
    #print('msr shape:{}'.format(df_msrs.shape))
    print('msr complete shape:{}'.format(df_complete_msrs.shape))
    #print(df_complete_msrs)

        #Make adjustments
        #read crossreference file
    xreffile = params.D0_FIELD_CROSS_REF_FILE
    wb = openworkbook(xreffile)
    ws_map = wb['Eligibility']
    #convert to datframe
    df_map = convertwstodf(ws_map, 1)
 
    anycol = 'noteligfieldsany'
    allcol = 'noteligfieldsall'
    df_map_fields = df_map[df_map[anycol].notnull()]
    anyfields = df_map_fields[anycol].tolist()
    df_map_fields = df_map[df_map[allcol].notnull()]
    allfields = df_map_fields[allcol].tolist()

        #Measures Not eligible
    savingsfields = ['EvalBase1kWhSvgs', 'EvalBase1kWSvgs', 'EvalBase1ThermSvgs', 'EvalBase2kWhSvgs', 'EvalBase2kWSvgs', 'EvalBase2ThermSvgs']
    df_complete_msrs.reset_index(inplace=True)
    df_complete_msrs['EvalIneligiblekw'] = False
    df_complete_msrs['EvalIneligiblekwh'] = False
    df_complete_msrs['EvalIneligiblethm'] = False
    for field in savingsfields:
        if 'kWSvgs' in field:
            engtype = 'kw'
        if 'kWhSvgs' in field:
            engtype = 'kwh'
        if 'ThermSvgs' in field:
            engtype = 'thm'

        df_complete_msrs[field + '_Orig'] = df_complete_msrs[field]  #create Orig field to hold original value
        df_complete_msrs[field + '_ChangeReason'] = 'NA'
        df_complete_msrs[field] = df_complete_msrs[field].where((df_complete_msrs[anyfields] != 'No').all(1), 0)
        #df_complete_msrs[field] = df_complete_msrs[field].where((df_complete_msrs[anyfields] != 'No').all(1) 
        #    & (df_complete_msrs[allfields] != 'No').any(1), 0)
        df_complete_msrs[field+ '_ChangeReason'] = df_complete_msrs[field+ '_ChangeReason'].where((df_complete_msrs[anyfields] != 'No').all(1), 'Ineligible')
        #df_complete_msrs[field+ '_ChangeReason'] = df_complete_msrs[field+ '_ChangeReason'].where((df_complete_msrs[anyfields] != 'No').all(1) 
        #    & (df_complete_msrs[allfields] != 'No').any(1),  'Ineligible')
        df_complete_msrs['EvalIneligible' + engtype] = df_complete_msrs['EvalIneligible' + engtype].where((df_complete_msrs[anyfields] != 'No').all(1), True)
        #df_complete_msrs['EvalIneligible' + engtype] = df_complete_msrs['EvalIneligible' + engtype].where((df_complete_msrs[anyfields] != 'No').all(1) 
        #    & (df_complete_msrs[allfields] != 'No').any(1), True)
    #ntgr to zero
    ntgrfields = ['EvalNTG_kWH', 'EvalNTG_therms']  #, 'EvalNTGRTherm','EvalNTGRCost']
    df_complete_msrs['ProgInfluenceFlag'] = (df_complete_msrs[allfields] == 'No').all(1)
    for field in ntgrfields:
        df_complete_msrs[field] = df_complete_msrs[field].where((df_complete_msrs[allfields] != 'No').any(1), 0)    



    df_project = pd.read_sql(session.query(Sample).statement, session.bind)
    print('prj shape:{}'.format(df_project.shape))
    #produces cartesian join, ouch
    #df_join = pd.DataFrame(session.query(Measure, Sample).all())
    #print('join shape:{}'.format(df_join.shape))
   
    #add calculated/lookup fields
    #set column names
    ws_map = wb['mapping']
    #convert to datframe
    df_map = convertwstodf(ws_map, 1)
    #print('map shape is {}'.format(df_map.shape))
    #print(df_map)
    #df_all_msrs[df_all_msrs[testfields_MeasAppType].notnull().any(1)
    atrfinalcol = 'ATRFieldlist'
    atrcol = 'InternalFields'
    claimcol = 'FD_SampleFieldName'
    wkbcol = 'workbookFieldName'
    dbcol = 'databasefieldname'
    srccol = 'atraccess'
    constcol = 'Constant'
    calccol = 'Calculation'
    calc2col = 'DependantCalc'
    rndcol = 'roundto'
    eqncol = ['eqn_true', 'eqn_false', 'eqn_condition']
    claimheaders = [atrcol,claimcol]
    #wkbheaders = [atrcol,wkbcol]
    dbheaders = [atrcol, dbcol]
    srcheaders = [atrcol, srccol]
    calcheaders = [atrcol, calccol]
    calc2headers = [atrcol, calc2col]
    constheaders = [atrcol, constcol]
    eqnheaders = [atrcol]
    eqnheaders.extend(eqncol)
    rndheaders = [atrfinalcol, rndcol]

        #Bring in Faiths claim fields
    df_map_claimfields = df_map[df_map[claimcol].notnull()]
    df_map_claimfields = df_map_claimfields[claimheaders]
    df_dups = None
    df_dups = df_map_claimfields[df_map_claimfields.duplicated(claimcol)]
    print('dup is {}'.format(df_dups))
    
    df_map_claimfields.drop(df_dups[atrcol].tolist(), axis=0, inplace=True)
    claimdict = df_map_claimfields.set_index(claimcol)[atrcol].to_dict()        
    df_atr = sample_list[df_map_claimfields[claimcol].tolist()]    
    df_atr = df_atr.rename(columns=claimdict)
    #if df_dups is not None:
    if len(df_dups.index) >0:
        #only works if there are not multiple of the same dup
        #add the dup fields
        claimdict = df_dups.set_index(claimcol)[atrcol].to_dict()
        tmp = sample_list.rename(columns=claimdict)
        df_atr = df_atr.join(tmp[df_dups[atrcol].tolist()])
        del tmp
        #print ('atr shape : {}, cols: {}'.format(df_atr.shape, df_atr.columns))               
    
        #Add fields from db column
    df_map_dbfields = df_map[df_map[dbcol].notnull()]
    df_map_dbfields = df_map_dbfields[dbheaders]
    df_dups = None
    df_dups = df_map_dbfields[df_map_dbfields.duplicated(dbcol)]
    print('dup is {}'.format(df_dups))    
    df_map_dbfields.drop(df_dups[atrcol].tolist(), axis=0, inplace=True) #works even if no dups
    dbdict = df_map_dbfields.set_index(dbcol)[atrcol].to_dict()    
    df_eval_msrs = df_complete_msrs[df_map_dbfields[dbcol].tolist()]
    df_eval_msrs = df_eval_msrs.rename(columns=dbdict)
    df_atr = df_atr.set_index('ClaimId').join(df_eval_msrs.set_index('ClaimId')) #uses lowercase because fields have been renamed to ATR versions

    #df_atr = sample_list[df_map_dbfields[claimcol].tolist()]    
    #df_atr = df_atr.rename(columns=claimdict)
    if len(df_dups.index) >0:
        #only works if there are not multiple of the same dup
        #add the dup fields
        dbdictdup = df_dups.set_index(dbcol)[atrcol].to_dict()
        tmp = df_complete_msrs.rename(columns=dbdictdup)        
        if not df_atr.index.name == 'ClaimId':
            df_atr.set_index('ClaimId', inplace=True)
        df_atr = df_atr.join(tmp.set_index('ClaimID')[df_dups[atrcol].tolist()])
        del tmp
        #print ('atr shape : {}, cols: {}'.format(df_atr.shape, df_atr.columns))   
   
    #print ('atr shape with db fields : {}'.format(df_atr.shape))
    
        # Add in atraccess fields
    df_map_srcfields = df_map[df_map[srccol].notnull()]
    df_map_srcfields = df_map_srcfields[srcheaders]    
    df_src = pd.read_csv(params.D0_ATR_SOURCE_FILE)
    df_src = df_src[df_map_srcfields[srccol].tolist()]
    df_atr = df_atr.join(df_src.set_index('ClaimId'))

    #print ('atr shape with atr source fields : {}'.format(df_atr.shape))

    # At this point df_atr has all the fields in columns B:F from cross ref. Just need to add the calculated fields
        #pull in constants    
    df_map_constants = df_map[df_map[constcol].notnull()]
    df_map_constants = df_map_constants[constheaders]
    dbdict = df_map_constants.set_index(atrcol)[constcol].to_dict()        
    for i in dbdict:
        if isinstance(dbdict[i],  (int, float, complex)) or dbdict[i].lower() != "null":
            df_atr[i] = dbdict[i]
        else:
            df_atr[i] = None        
    
    #print ('atr shape with constants added : {}'.format(df_atr.shape))

    #some constants for the calculated stuff
    operators = '*/()+-><!==AND&OR|.'
    stringops = 'ANDOR&|'
    dfname = 'df_all_fields'

        #pull in conditional
    df_map_eqnfields = df_map[df_map[eqncol].notnull().any(1)]
    df_map_eqnfields = df_map_eqnfields[eqnheaders]
    for _, row in df_map_eqnfields.iterrows():         
        df_all_fields = df_atr.join(df_complete_msrs.set_index('ClaimID'), how='left', rsuffix='_msr')
        #print ('type of row is {}, fieldname is {}, value is {}'.format(type(row), row[eqncol], row))
        parts_true = row[eqncol[0]].split()
        parts_false = row[eqncol[1]].split()        
        parts_cond = row[eqncol[2]].split()        

        nojoin = False
        for p in parts_true:
            if len(parts_true)==1:
                eqn_true = p
                nojoin = True
            elif p not in operators and '==' not in p and not is_number(p):
                parts_true[parts_true.index(p)] = "{}['{}']".format(dfname,p)         
        if not nojoin:
            eqn_true = ''.join(parts_true)
        nojoin = False
        
        for p in parts_false:
            if len(parts_false)==1:
                eqn_false = p
                nojoin = True
            elif p not in operators and '==' not in p and not is_number(p):
                parts_false[parts_false.index(p)] = "{}['{}']".format(dfname,p)         
        if not nojoin:
            eqn_false = ''.join(parts_false)
        nojoin = False
        
        for p in parts_cond:
            if len(parts_cond)==1:
                eqn_cond = p
                nojoin = True
            elif p not in operators and '==' not in p and '.' not in p and not is_number(p): #maybe change to startswith in operators if can use list
                parts_cond[parts_cond.index(p)] = "{}['{}']".format(dfname,p) 
        if not nojoin:
            eqn_cond = ''.join(parts_cond)
    
        #print('eqn true:{}'.format(eqn_true))
        #print('eqn false:{}'.format(eqn_false))
        #print('eqn cond:{}'.format(eqn_cond))

        #df['d'] = df['b'].where(df['b'] < 0, df['c'])

        myargs =  eqn_true + '.where(' + eqn_cond + ', ' + eqn_false + ')'        
        dftmp = df_complete_msrs.set_index('ClaimID')
        dftmp[row[atrcol]] = eval(myargs)
        
        dftmp = dftmp[row[atrcol]]
        df_atr = df_atr.join(dftmp)
    
    #print ('atr shape with conditionals added : {}'.format(df_atr.shape))

    ###    #pull in the calculated fields
    df_map_calcfields = df_map[df_map[calccol].notnull()]
    df_map_calcfields = df_map_calcfields[calcheaders]
        #append dependent calcs
    df_map_calc2fields = df_map[df_map[calc2col].notnull()]
    df_map_calc2fields = df_map_calc2fields[calc2headers]
    df_map_calc2fields.columns = calcheaders  #.rename({calc2col : calccol}, inplace=True)
    df_map_calcfields = pd.concat([df_map_calcfields, df_map_calc2fields])

    #loop through
    for _, row in df_map_calcfields.iterrows(): 
        df_all_fields = df_atr.join(df_complete_msrs.set_index('ClaimID'), how='left', rsuffix='_msr')
        parts = row[calccol].split()
        nojoin = False
        for p in parts:
            if len(parts)==1:
                eqn = p
                nojoin = True
            elif p not in operators and '==' not in p and '.' not in p and not is_number(p):
                parts[parts.index(p)] = "{}['{}']".format(dfname,p)
            elif p in stringops:
                parts[parts.index(p)] = ' %s ' % p

        if not nojoin:
            eqn = ''.join(parts)
        nojoin = False
        myargs =  eqn
        dftmp = df_complete_msrs.set_index('ClaimID')
        dftmp[row[atrcol]] = eval(myargs)
        
        dftmp = dftmp[row[atrcol]]

        df_atr = df_atr.join(dftmp)

    #New appends the last field delete if trouble
    df_all_fields = df_atr.join(df_complete_msrs.set_index('ClaimID'), how='left', rsuffix='_msr')
    #above ok?
    print ('atr shape with everything added : {}'.format(df_atr.shape))

    ## Drop passthru from atr to dbreview record will stay in place
    #df[df.name != 'Tina']
    df_atr = df_atr[df_atr.EvalNetPassThru != True]
    print ('atr shape after drop EvalNetPassThru : {}'.format(df_atr.shape))
    
    # Pull in db review file    
    df_dbrvw = pd.read_csv(params.D0_DATABASE_REVIEW_FILE)
    # Hack to fix string number column. Not needed anymore
    #df_dbrvw["ExAnteLifecycleNetkWh"] = df_dbrvw["ExAnteLifecycleNetkWh"].str.replace('-', '0')
    #df_dbrvw["ExAnteLifecycleNetkWh"] = df_dbrvw["ExAnteLifecycleNetkWh"].str.replace(',', '').astype(float)    
    
    #Combine with atr
    #dropping all sampled records, then join
    ''' Didn't work
    #df_dbrvwnonsampled = (df_dbrvw.merge(df_atr, on=['ClaimID', 'ClaimId'], how='left', indicator=True)
    df_dbrvwnonsampled = (df_dbrvw.merge(df_atr, how='left', indicator=True)
     .query('_merge == "left_only"')
     .drop('_merge', 1))
    '''
    df_dbrvwnonsampled = df_dbrvw[~df_dbrvw.ClaimId.isin(df_atr.index)]   

    #print('original shape is {}, after drop it is {}'.format(df_dbrvw.shape, df_dbrvwnonsampled.shape))
    
    #df_atr.reset_index(inplace=True)
    df_fullatr = pd.concat([df_dbrvwnonsampled.set_index('ClaimId'),df_atr], sort=False)
    try:
        csvfile = params.SAMPLED_SITE_REVIEW_PATH + '\\allfieldsatrdata.csv'
        df_fullatr.to_csv(csvfile)
        logging.info(f'wrote csv for {csvfile}')
    except:
        logging.info("file in use writing to backup")
        df_fullatr.to_csv(params.SAMPLED_SITE_REVIEW_PATH + '\\allfieldsatrdata2.csv')

    #get cols
    df_map_atrfields = df_map[df_map[atrfinalcol].notnull()]
    atrcols = df_map_atrfields[atrfinalcol].tolist()
    #print('final cols are {}'.format(atrcols))
    df_fullatr.index.name = 'ClaimId'
    df_fullatr = df_fullatr.reset_index()
    #df_fullatr.rename(columns={'ClaimID': 'ClaimId'}, inplace = True )
    df_fullatr = df_fullatr[atrcols]
    df_fullatr.set_index('ClaimId', inplace = True)    

    #Final data Clean up 
    #df_fullatr.fillna(0, inplace=True) # don't turn back on unless deal with marketeffectsbenefits nulls
    df_fullatr.replace({True: '1', False: '0'}, inplace=True)

    
    # round output for passthru = 0
    rounding = False
    if(rounding):
        df_map_roundfields = df_map[df_map[rndcol].notnull()]
        df_map_roundfields = df_map_roundfields[rndheaders]
        df_map_roundfields.set_index(atrfinalcol, inplace=True)
        df_map_roundfields = df_map_roundfields.astype({rndcol : int})
        df_map_roundfields['types'] = 'float'    
        df_fullatr = df_fullatr.astype(df_map_roundfields['types'])        
        print('fullatr shape before round: {}'.format(df_fullatr.shape))
        df_fullatr[df_fullatr['EvalNetPassThru'] == 1].round(df_map_roundfields[rndcol])
        print('fullatr shape after round: {}'.format(df_fullatr.shape))
    #df_fullatr = sigfigs(df_fullatr)
    print('alldata shape: {}'.format(df_all_fields.shape))
    
    logging.info('printing atr files')
    try:
        csvfile = params.SAMPLED_SITE_REVIEW_PATH + '\\atrdata.csv'
        df_atr.to_csv(csvfile)
        logging.info(f'wrote csv for {csvfile}')
    except:
        logging.info("file in use writing to backup")
        df_atr.to_csv(params.SAMPLED_SITE_REVIEW_PATH + '\\tmpatr2.csv')

    try:
        csvfile = params.D0_ALL_DATA_FILE
        #csvfile = params.SAMPLED_SITE_REVIEW_PATH + '\\alldata.csv'
        df_all_fields.to_csv(csvfile)
        logging.info(f'wrote csv for {csvfile}')
    except:
        logging.info("file in use writing to backup")
        df_all_fields.to_csv(params.SAMPLED_SITE_REVIEW_PATH + '\\alldata2.csv')

    try:
        csvfile = params.D0_LOCAL_ATR_OUTPUT_FILE
        df_fullatr.to_csv(csvfile)
        logging.info(f'wrote csv for {csvfile}')
    except:
        logging.info("file in use writing to backup")
        df_fullatr.to_csv(params.D0_ESPI_PATH + '\\finalatr_backup.csv')

    if WriteFinalFile:
        try:
            csvfile = params.D0_ATR_OUTPUT_FILE
            df_fullatr.to_csv(csvfile)
            logging.info(f'wrote csv for {csvfile}')

        except:
            logging.info("file in use writing to backup")
            df_fullatr.to_csv(params.D0_ESPI_PATH + '\\actualatr_backup.csv')

    print('yup')

def sigfigs(df):
    """
    determine the number of significant figures for the eval fields.
    Output the dataframe with the sig figs applied
    """
    return df

def is_number(string):
    try:
        float(string)
        return True
    except ValueError:
        return False
'''
def ineligible(row):
    noteligiblefields = ['RvwInstallDate', 'RvwAppVsInstallDate', 'RvwPermit', 'RvwFuelSwitchTest', 'RvwCogenImpact', 'RvwEffIncrease', 
        'EvalNTGDecisionProcess', 'EvalNTGProjectInitation', 'EvalNTGMeasureIdent', 'EvalNTGMeasOptions', 'EvalNTGCostNRGBenefits', 'EvalNTGNEBs', 
        'EvalNTGProgInfluenceTiming', 'EvalNTGCostEffectiveness']
    if row([noteligiblefields].all() != 'No')
        df_complete_msrs[field] = df_complete_msrs[field].where(df_complete_msrs[noteligiblefields].all() != 'No', 0)
        df_complete_msrs[field+ '_ChangeReason'] = df_complete_msrs[field+ '_ChangeReason'].where(df_complete_msrs[noteligiblefields].all() != 'No', 'Ineligible')
'''

def runCreateATR(WriteFinalFile):
    session = Session()
    createEvalResults(session,WriteFinalFile)    
    logging.info('done with CreateATR')

if __name__ == '__main__':
    create_logfile('../logs/createATR.log')
    logging.info('Beginning session')
    session = Session()
    createEvalResults(session, False)
