#Create the files for ciac2018
import logging
import math
import os.path
import re
import subprocess
import time
from datetime import datetime  # to get current time
from io import BytesIO, StringIO
from shutil import copyfile, copystat

import altair as alt
import matplotlib.pyplot as plt
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import plotly.io as pio
import seaborn as sns
import sqlalchemy as db
from plotly.subplots import make_subplots

import cpuc.params as params
import cpuc.plots as vs
import pandas as pd
from cpuc.altair_theme import sbw_cpuc
from cpuc.mylogging import create_logfile
# from cpuc.plots import vis
# from cpuc.plots import d_axis
# from cpuc.plots import facet
from cpuc.plots import mkplot1
from cpuc.sharefileapi import SHAREFILE_OPTIONS, ShareFileSession
from cpuc.utility import (create_folder, df_to_csv_sharefile,
                          get_df_from_driver, replace_strings_with_spaces,
                          swap_out_strings)
# from cpuc.utility import get_datadef_source_info #Has dependencies to work out over there
from cpuc.workbookfunctions import (convertwstodf, getSampleControlFile,
                                    openworkbook)
from createReportData import remapdata
from prefill_workbooks import calculate_workbooks, get_df_from_src
from upload_workbooks import download_data, upload_ciac_trackers

alt.themes.register('sbw_cpuc', sbw_cpuc)
alt.themes.enable('sbw_cpuc')

sns.set()

utility_remap = {
    'PGE': 'PG&E', 
    'SDGE': 'SDG&E', 
    'MCE': 'MCE', 
    'SCG': 'SCG', 
    'SCE': 'SCE',
    'Statewide': 'Statewide'
}

utility_colors = {
    'PGE': params.MAIN_PALETTE[0],
    'PG&E': params.MAIN_PALETTE[0], 
    'SDGE': params.MAIN_PALETTE[1],
    'SDG&E': params.MAIN_PALETTE[1], 
    'MCE': params.MAIN_PALETTE[2], 
    'SCG': params.MAIN_PALETTE[3], 
    'SCE': params.MAIN_PALETTE[5],
    'Statewide': params.MAIN_PALETTE[4]
}
#color_discrete_sequence=["red", "green", "blue", "goldenrod", "magenta"]

fontfamily = "Verdana Pro Condensed Semibold, Verdana"
g_font_size = 16
axis_line_width = 2
grid_line_width = 1
grid_color = 'grey'
axis_color = 'black'
legend_size_increase = 3

def create_cedars_custom(sfsession:ShareFileSession):
    """
    Create the csv file of the cedars custom data
    Only need to run once to create the file. Data doesn't change
    """

    #open definition file
    def_item = sfsession.get_io_version(params.CIAC_2018_DATA_DEF_FILE)
    wb = openworkbook(def_item.io_data)
    ws_def = wb['SourceDef']
    df_def = convertwstodf(ws_def, 1)
    #get claim path
    claim_def = df_def[df_def['sourcename']=='cedarsclaim']    
    filename = claim_def['location'].values[0]
    claimheaders = ['ClaimID', 'SiteID', 'PrgID', 'ImplementationPA', 'ImplementationID', 'BldgType', 'BldgLoc', 'BldgVint', 'BldgHVAC', 'NormUnit', 'Sector', 'MeasAppType', 'DeliveryType', 'PrgElement', 'ProjectID', 'ProjectDescription', 'NAICSBldgType', 'E3TargetSector', 'E3MeaElecEndUseShape', 'E3GasSector', 'E3GasSavProfile', 'E3ClimateZone', 'NumUnits', 'InstalledNumUnits', 'InstalledNormUnit', 'CombustionType', 'NTGRkW', 'NTGRkWh', 'NTGRTherm', 'NTGRCost', 'NTG_ID', 'TotalFirstYearGrosskW', 'TotalFirstYearGrosskWh', 'TotalFirstYearGrossTherm', 'TotalFirstYearNetkW', 'TotalFirstYearNetkWh', 'TotalFirstYearNetTherm', 'TotalLifecycleGrosskW', 'TotalLifecycleGrosskWh', 'TotalLifecycleGrossTherm', 'TotalLifecycleNetkW', 'TotalLifecycleNetkWh', 'TotalLifecycleNetTherm', 'TotalGrossMeasureCost', 'TotalGrossMeasureCost_ER', 'TotalGrossIncentive', 'UnitEndUserRebate', 'UnitIncentiveToOthers', 'UnitDirectInstallLab', 'UnitDirectInstallMat', 'UnitMeaCost1stBaseline', 'UnitMeaCost2ndBaseline', 'WhySavingsZeroed', 'WhyCostsZeroed', 'PartialPaymentPercent', 'PartialPaymentFinal_Flag', 'Upstream_Flag', 'Residential_Flag', 'EUC_Flag', 'LGP_Flag', 'REN_Flag', 'OBF_Flag', 'Prop39_Flag', 'PublicK_12_Flag', 'SchoolIdentifier', 'FundingCycle', 'ClaimYearQuarter', 'ApplicationCode', 'ApplicationDate', 'InstallationDate', 'PaidDate', 'CustomerAgreementDate', 'ProjectCompletionDate', 'AuthorizedSignatureDate', 'ExAnteFirstYearGrosskW', 'ExAnteFirstYearGrosskWh', 'ExAnteFirstYearGrossTherm', 'ExAnteFirstYearNetkW', 'ExAnteFirstYearNetkWh', 'ExAnteFirstYearNetTherm', 'ExAnteLifecycleGrosskW', 'ExAnteLifecycleGrosskWh', 'ExAnteLifecycleGrossTherm', 'ExAnteLifecycleNetkW', 'ExAnteLifecycleNetkWh', 'ExAnteLifecycleNetTherm', 'ExAnteFirstYearGrossBTU', 'ExAnteGrossMeasureCost', 'ExAnteGrossMeasureCost_ER', 'ExAnteGrossIncentive', 'MeasImpactType', 'WaterOnly_Flag', 'FinancingPrgID', 'MarketEffectsBenefits', 'MarketEffectsCosts', 'RateScheduleElec', 'RateScheduleGas', 'Comments']
    claim_item = sfsession.get_io_version(filename)
    claim_item.io_data.seek(0)

    #df_claim = pd.read_csv(claim_item.io_data,names=claimheaders, low_memory=False)
    #df_claim = pd.read_csv(filename, chunksize=1000000, low_memory=False)
    df_claim = pd.read_csv(filename, low_memory=False)

    #get custom
    custom_def = df_def[df_def['sourcename']=='cedarscustom']    
    filename = custom_def['location'].values[0]
    custom_item = sfsession.get_io_version(filename)
    custom_item.io_data.seek(0)
    df_custom = pd.read_csv(custom_item.io_data)
    #df_custom = pd.read_csv(filename, low_memory=False)
    #join together
    #cedars = df_claim.set_index(claim_def['IndexField'].values[0]).join(df_custom.set_index(custom_def['IndexField'].values[0]), how='inner', lsuffix='_msr')
    #cedars = df_claim.reset_index(drop=False, inplace=True).set_index(custom_def['IndexField'].values[0]).join(df_custom.set_index(custom_def['IndexField'].values[0]), how='inner', lsuffix='_msr')
    cedars = df_claim.merge(df_custom, on=custom_def['IndexField'].values[0], how='inner', suffixes=('', '_cmsr'))
    print(f'cedars shape after merge with custom is {cedars.shape}')
    #open sample control file to limit it to just Group D claim
    custom_def = df_def[df_def['sourcename']=='SampleControl']    
    filename = custom_def['location'].values[0]
    custom_item = sfsession.get_io_version(filename)
    custom_item.io_data.seek(0)
    df_grpD = pd.read_csv(custom_item.io_data)
    df_grpD_custom = df_grpD[[custom_def['IndexField'].values[0]]]
    #cedars = cedars.join(df_grpD_custom.set_index(custom_def['IndexField'].values[0]), how='inner', lsuffix='_msr')
    cedars = cedars.merge(df_grpD_custom, on=custom_def['IndexField'].values[0], how='inner', suffixes=('', '_GrpD'))
    
    #getoutput location and write
    output_def = df_def[df_def['sourcename']=='cedars_custom_claim']
    #TODO Cahnge to IO model
    filename = output_def['location'].values[0]
    cedars.to_csv(filename)
    print('woohoo')

def create_detail_pop(sfsession:ShareFileSession, mapsheet:str = 'map_clm'):
    """
    generate the detail level pop source file as defined in the data def file
    output is csv file of data
    """

    #open map file    
    map_item = sfsession.get_io_version(params.CIAC_2018_DATA_DEF_FILE)
    map_wb = openworkbook(map_item.io_data)
    ws_src = map_wb['SourceDef']
    df_srclist = convertwstodf(ws_src,1)
    ws_map = map_wb[mapsheet]
    df_map = convertwstodf(ws_map, 1)

    freshendata = False
    if freshendata:
        #make sure data is fresh
        #open save tracker
        result = calculate_workbooks(sfsession=sfsession,filepaths=[df_srclist.loc['trackerclaim','location']])
        #upload/download tracker
        if result:
            upload_ciac_trackers()
            download_data(df_srclist.loc['claimtracker','tablename'], df_srclist.loc['claimtracker','location'], sfsession)
            download_data(df_srclist.loc['projecttracker','tablename'], df_srclist.loc['projecttracker','location'], sfsession)
            print('tracker data updated')
        else:
            print('tracker data not updated')

    #Collect data from each source and put together
    skipflag = 'skip'
    srcflag = 'src_'
    outflag = 'out_'
    agflag = 'agg_'
    eqnflag = 'eqn_'
    calcflag = 'calc_'
    copyflag = 'copy_'
    npflag = 'np_'
    #finalindex = 'ClaimID'
    columns = list(df_map.columns.values)
    #drop any nones in the list
    columns = list(filter(None.__ne__, columns))
    srccols = [x for x in columns if srcflag in x]
    outcol = [x for x in columns if outflag in x][0]
    calccol = [x for x in columns if calcflag in x]
    aggcols = [x for x in columns if agflag in x]
    eqncol = [x for x in columns if eqnflag in x]
    copycol = [x for x in columns if copyflag in x]
    npcol = [x for x in columns if npflag in x]
    
    dfname = 'out_df' #match to line below.
    out_df = pd.DataFrame
    #drop skips
    df_map = df_map[df_map[skipflag].isnull()]
    #loop though sources adding them to final
    for src in srccols:
        srcname = src.split(srcflag)[1]
        print(f'starting join with {srcname}')
        # if 'netdispo' in srcname:
        #     print('debug')
        df_map_srcfields = df_map[df_map[src].notnull()]
        headers = []
        headers.append(outcol)
        headers.extend(srccols)
        df_map_srcfields = df_map_srcfields[headers]
        df_dups = None
        df_dups = df_map_srcfields[df_map_srcfields.duplicated(src)]
        #print('dup is {}'.format(df_dups))
        #open source
        df_srcinfo = df_srclist[df_srclist['sourcename']==srcname]
        srcdict = df_map_srcfields.set_index(src)[outcol].to_dict()
        #Get the appropriate index
        srcindex = df_srcinfo.iloc[0]['IndexField']
        if not srcindex:
            print(f'must add index for {srcname}')
            continue
        elif not srcdict:
            print(f'No fields to collect for {srcname}')
            continue

        try:
            outindex = srcdict[srcindex] #may have to do list comprehension if dict is backwards
        except Exception as e:
            print(f'index {srcindex} missing for {srcname}')
        filepath = df_srcinfo.iloc[0]['location']
        if not filepath:
            print(f'no file specified for {srcname}, skipping')
            continue
        src_item = sfsession.get_io_version(filepath)
        if src_item is None:
            print(f'src item {srcname} missing. pausing')
            time.sleep(7)
            if src_item is None:
                print(f'src item {srcname} still missing after wait. retrying, longer wait')
                src_item = sfsession.get_io_version(filepath)
                time.sleep(10)
                if src_item is None:
                    print(f'src item {srcname} missing after longer wait. crap')
        src_item.io_data.seek(0)
        filetype = df_srcinfo.iloc[0]['type']
        if filetype == 'csv':
            df_src_all = pd.read_csv(src_item.io_data)
        elif filetype == 'excel':
            df_src_all = pd.read_excel(src_item.io_data, sheet_name=df_srcinfo.iloc[0]['sheet'], header=int(df_srcinfo.iloc[0]['startrow'])-1)
        else:
            print(f'unknown type {filetype} for {srcname} skipping')
            continue
        #limit fields to the ones needed        
        df_src = df_src_all[df_map_srcfields[src].tolist()]
        df_src = df_src.rename(columns=srcdict)
        #join to out df        
        if out_df.empty:
            out_df = df_src #use copy?
        else:            
            if out_df.index.name != None:
                out_df.reset_index(inplace=True)
            out_df = out_df.set_index(outindex).join(df_src.set_index(outindex))
        print(f'out_df shape after join with {srcname} is {out_df.shape}. Cols are {out_df.columns}')
        #if df_dups is not None:
        if len(df_dups.index) > 0:
            #only works if there are not multiple of the same dup
            #add the dup fields
            srcdictdup = df_dups.set_index(srccols)[outcol].to_dict()
            tmp = df_src_all.rename(columns=srcdictdup)   
            if not out_df.index.name == outindex:
                out_df.set_index(outindex, inplace=True)
            out_df = out_df.join(tmp.set_index(srcindex)[df_dups[outcol].tolist()]) #, lsuffix="srcname")
            del tmp

        print('end of loop')
    #write out the raw version of the file
    out_io = StringIO()
    out_io.seek(0)
    out_df.to_csv(out_io, index=False)
    #get file name and folder ID
    df_out_outinfo = df_srclist[df_srclist['sourcename']==outcol.split(outflag)[1]]
    filepath = df_out_outinfo.iloc[0]['location']
    filename = os.path.basename(filepath) #.replace('.csv', '_raw.csv')
    pathroot = filepath.split(filename)[0]
    filename = filename.replace('.csv', '_raw.csv')
    folder_item = sfsession.get_item_by_local_favorites_path(pathroot)
    sfsession.upload_file(folder_item.id, filename, out_io)

    #This section now loops through remaining rows doing whatever is specified
    #assumes that if operations are done in row order dependent fields will be in place

    #build list of operation headers
    opheaders = [outcol]
    opheaders.extend(calccol)
    opheaders.extend(aggcols)
    opheaders.extend(eqncol)
    opheaders.extend(copycol)
    opheaders.extend(npcol)

    df_map_opfields = df_map[opheaders]
    df_map_opfields.set_index(outcol)
    df_map_opfields = df_map_opfields.dropna(axis=0, how='all')
    print(f'op df shape is {df_map_opfields.shape}')

    operators = '*/()+-><!==ANDand&ORor|.FalseTruenot~'
    stringops = 'ANDandORor&|not~'
    out_df.reset_index(inplace=True)    
    for _, row in df_map_opfields.iterrows():        
        row = row.dropna() #drop empty cols
        if len(row)==1:
            continue #because no operation is defined

        if row[outcol] == 'strkwh_smp_count_prelim':
            print('debug')
        #determine which operation and call it
        frow = row.filter(like=copyflag)
        if not frow.empty:
            #call copy function
            add_copy_field(out_df, dfname, row, outcol)
            #print(f'out_df columns: {out_df.columns}')
            continue
        
        frow = row.filter(like=calcflag)
        if not frow.empty:
            #call calc function
            calc_fields(out_df, dfname, row, outcol, operators, stringops)
            #print(f'out_df columns: {out_df.columns}')
            continue
        
        frow = row.filter(like=npflag)
        if not frow.empty:
            #call np where function
            add_np_where(out_df, dfname, row, npflag, outcol, operators, stringops)
            #print(f'out_df columns: {out_df.columns}')
            continue

        frow = row.filter(like=eqnflag)
        if not frow.empty:
            #call eqn function
            add_eqn_field(out_df, dfname, row, eqnflag, outcol, operators, stringops)
            #print(f'out_df columns: {out_df.columns}')
            continue

        frow = row.filter(like=agflag)
        if not frow.empty:
            #call agg function
            #try:
            add_agg_field(out_df, dfname, row, agflag, outcol, operators, stringops)
            #except:
            #    print(f'problem adding agg field for {frow}')
            #print(f'out_df columns: {out_df.columns}')
            continue


    print('done creating data, now onto writing the file')

    #write out file
    out_io = StringIO()
    out_io.seek(0)
    out_df.to_csv(out_io, index=False)
    # out_df.to_csv(r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\net_claim_test.csv")
    #get file name and folder ID
    df_out_outinfo = df_srclist[df_srclist['sourcename']==outcol.split(outflag)[1]]        
    filepath = df_out_outinfo.iloc[0]['location']
    filename = os.path.basename(filepath)
    pathroot = filepath.split(filename)[0]
    folder_item = sfsession.get_item_by_local_favorites_path(pathroot)
    sfsession.upload_file(folder_item.id, filename, out_io)
   
    print('yup done')

def create_sample_pop(sfsession:ShareFileSession, mapsheet:str = 'map_smpl'):
    """
    generate the sample level pop source file as defined in the data def file
    output is csv file of data
    """

    #open map file    
    map_item = sfsession.get_io_version(params.CIAC_2018_DATA_DEF_FILE)
    map_wb = openworkbook(map_item.io_data)
    ws_src = map_wb['SourceDef']
    df_srclist = convertwstodf(ws_src,1)
    ws_map = map_wb[mapsheet]
    df_map = convertwstodf(ws_map, 1)
    #Collect data from each source and put together
    srcflag = 'src_'
    outflag = 'out_'
    agflag = 'agg_'
    eqnflag = 'eqn_'
    calcflag = 'calc_'
    copyflag = 'copy_'
    npflag = 'np_'    
    columns = list(df_map.columns.values)
    #drop any nones in the list
    columns = list(filter(None.__ne__, columns))
    srccols = [x for x in columns if srcflag in x]
    outcol = [x for x in columns if outflag in x][0]
    calccol = [x for x in columns if calcflag in x]
    aggcols = [x for x in columns if agflag in x]
    eqncol = [x for x in columns if eqnflag in x]
    copycol = [x for x in columns if copyflag in x]
    npcol = [x for x in columns if npflag in x]
    
    dfname = 'src_df' #match to line below.
    out_df = pd.DataFrame
    srcname = srccols[0].split(srcflag)[1]
    df_srcinfo = df_srclist[df_srclist['sourcename']==srcname]
    filepath = df_srcinfo.iloc[0]['location']
    if not filepath:
        print(f'no file specified for {srcname}, skipping')
        return False
    src_item = sfsession.get_io_version(filepath)
    src_item.io_data.seek(0)
    filetype = df_srcinfo.iloc[0]['type']
    if filetype == 'csv':
        src_df = pd.read_csv(src_item.io_data)
    elif filetype == 'xls':
        src_df = pd.read_excel(src_item.io_data, sheet_name=df_srcinfo.iloc[0]['sheet'], header=int(df_srcinfo.iloc[0]['startrow'])-1)
    else:
        print(f'unknown type {filetype} for {srcname} skipping')
        return False
    if src_df.empty:
        logging.warning(f'could not open {filepath}')
        return False

    #This section now loops through rows doing whatever is specified
    #assumes that if operations are done in row order dependent fields will be in place

    #build list of operation headers
    opheaders = [outcol]
    opheaders.extend(calccol)
    opheaders.extend(aggcols)
    opheaders.extend(eqncol)
    opheaders.extend(copycol)
    opheaders.extend(npcol)

    df_map_opfields = df_map[opheaders]
    df_map_opfields.set_index(outcol)
    df_map_opfields = df_map_opfields.dropna(axis=0, how='all')
    print(f'op df shape is {df_map_opfields.shape}')

    operators = '*/()+-><!==AND&OR|.FalseTruenot~'
    stringops = 'ANDOR&|not~'
    for _, row in df_map_opfields.iterrows():
        row = row.dropna() #drop empty cols
        if len(row)==1:
            continue #because no operation is defined

        #determine which operation and call it
        frow = row.filter(like=copyflag)
        if not frow.empty:
            #call copy function
            add_copy_field(src_df, dfname, row, outcol)
            print(f'src_df columns: {src_df.columns}')
            continue
        
        frow = row.filter(like=calcflag)
        if not frow.empty:
            #call calc function
            calc_fields(src_df,  dfname, row, outcol, operators, stringops)
            print(f'src_df columns: {src_df.columns}')
            continue
        
        frow = row.filter(like=npflag)
        if not frow.empty:
            #call agg function
            add_np_where(src_df,  dfname, row, npflag, outcol, operators, stringops)
            print(f'src_df columns: {src_df.columns}')
            continue

        frow = row.filter(like=eqnflag)
        if not frow.empty:
            #call eqn function
            add_eqn_field(src_df,  dfname, row, eqnflag, outcol, operators, stringops)
            print(f'src_df columns: {src_df.columns}')
            continue

        frow = row.filter(like=agflag)
        if not frow.empty:
            #call agg function
            try:
                tmp = agg_df(src_df,  dfname, row, agflag, outcol, operators, stringops)
            except Exception as e:
                print(f'problem adding agg field for {frow} is {e}')
                continue
            if tmp.empty:
                print(f'problem adding agg field for {frow}')
                continue
            if out_df.empty:
                out_df = tmp
            else:
                out_df = out_df.join(tmp)
            print(f'src_df columns: {out_df.columns}')
            continue

    print('done creating data, now onto writing the file')

    #write out file
    out_io = StringIO()
    out_io.seek(0)
    out_df.to_csv(out_io)
    #get file name and folder ID
    df_out_outinfo = df_srclist[df_srclist['sourcename']==outcol.split(outflag)[1]]        
    filepath = df_out_outinfo.iloc[0]['location']
    filename = os.path.basename(filepath)
    pathroot = filepath.split(filename)[0]
    folder_item = sfsession.get_item_by_local_favorites_path(pathroot)
    sfsession.upload_file(folder_item.id, filename, out_io)
   
    print('yup done')


def add_copy_field(out_df, dfname, row, outcol):
    """
    Add a copy of the field with a new name
    """
    try:
        p = row.loc['copy_field']
    except:
        p = row.iloc[1]
    myargs = "{}['{}']".format(dfname,p)
    print(f'adding {row[outcol]} using {myargs}')
    out_df[row[outcol]] = eval(myargs)   

def calc_fields(out_df, dfname, row, outcol, operators, stringops):
    """
    use the info pased in the row to calculate a field on the passed out_df

    TODO: currently relies on df name matching fname. find a way to mak it more resilient
    """
    
    
    try:
        inputString = row.loc['calc_1']
    except:
        inputString = row.iloc[1]
    
    #see if it should just use the string without processing
    skip = False
    skipstring = 'STR_LIT:'
    if skipstring in inputString:
        eqn = inputString[len(skipstring):]
        skip = True

    if not skip:
        #Pull out any quoted bits that have spaces, so they don't mess up the splitting/parsing routine
        strings = re.findall(r"'([^']*)'", inputString)
        int = 1
        replacestrings = dict()
        for s in strings:
            replstr = '999x' + str(int)
            inputString = inputString.replace(s, replstr)
            int += 1
            replacestrings[replstr] = s
    
        parts = inputString.split()
        nojoin = False
        for p in parts:
            if len(parts)==1:
                eqn = p
                nojoin = True
            elif p not in operators and '==' not in p and '!=' not in p and '.' not in p and ',' not in p and not is_number(p):
                parts[parts.index(p)] = "{}['{}']".format(dfname,p)
            elif p in stringops:
                parts[parts.index(p)] = ' %s ' % p

        if not nojoin:
            eqn = ''.join(parts)
        #put back any space filled quotes that were removed
        for k,v in replacestrings.items():
            eqn = eqn.replace(k,v)
    myargs =  eqn
    print(f'adding calc {row[outcol]} using {myargs}')
    if row[outcol] == 'net_complete_kwh':
        print ('debug')
    out_df[row[outcol]] = eval(myargs)
    try:
        out_df[row[outcol]].replace(np.inf, None, inplace=True) #get rid of divide by zero errors
    except:
        pass
    #end of calc_fields section

def add_agg_field(out_df, dfname, row, agflag, outcol, operators, stringops):
    """
    add aggregated field at the nonaggregated level
    """
    if row[outcol] == 'strkwh_pop_count':
        print('debug')

    reducerprefix = 'r_'
    headers = row.index    
    ag_grp_col = [x for x in headers if agflag + 'group' == x]
    ag_imd_grp_col = [x for x in headers if agflag + 'imd_group' == x]
    ag_filter_col = [x for x in headers if agflag + 'filter' == x]
    ag_field_col = [x for x in headers if agflag + 'field' == x]
    ag_fxn_col = [x for x in headers if agflag + 'function' == x]
    ag_imd_fxn_col = [x for x in headers if agflag + 'imd_function' == x]
    ag_redux_col = [x for x in headers if agflag + 'reducer' == x]
    #ag_weight_cols = [x for x in headers if agflag + 'weight' in x]
    
    #TODO change these to handle missing params
    try:
        group = row[ag_grp_col][0]
    except Exception as e:
        print(f'error for {row[ag_grp_col]}: {e}')
        group = row[ag_grp_col]
    try:
        rfilter = row[ag_filter_col][0] 
    except:
        rfilter = None
    field = row[ag_field_col][0]
    function = row[ag_fxn_col][0]
    try:
        reducer = row[ag_redux_col][0]
    except:
        reducer = []
    try:
        imdgrp = row[ag_imd_grp_col][0]
        imdfxn = row[ag_imd_fxn_col][0]
    except:
        imdgrp = []
        imdfxn = []
    
    fname = row[outcol]
    print(f'adding {fname} in agg')
    if rfilter:
        rfilterparts = rfilter.split(' ') #what if there aren't any spaces?
        for p in rfilterparts:        
            if p not in operators and '==' not in p and '!=' not in p and '.' not in p and not is_number(p):
                rfilterparts[rfilterparts.index(p)] = "{}['{}']".format(dfname,p)
            elif p in stringops:
                rfilterparts[rfilterparts.index(p)] = ' %s ' % p                                  
        
        rfilter = ''.join(rfilterparts)
    groupbylist = group.split()
    try:
        imdgrglist = imdgrp.split()
    except:
        pass
    fields = [x.strip() for x in field.split(',')]
    functions = [x.strip() for x in function.split(',')]
    try:
        imdfxns = [x.strip() for x in imdfxn.split(',')]
    except:
        pass
    aggdict = dict(zip(fields, functions))
    #TODO update rename to use new format as it's deprecated
    #groupby(...).agg(name=('column', aggfunc))
    #aggform [reducerprefix + x = ('x', 'sum') for x in fields]
    #myargs = f"{dfname}.merge({dfname}[{rfilter}].groupby('{group}').agg({aggform}).reset_index())"

    #there are multiple paths here. One or simple aggregations and one for new fields created by reducing two aggregated fields by a function
    if len(reducer) == 0 and len(imdgrp) == 0: #then it's a simple agg        
        #df['sum_values_A'] = df.groupby('A')['values'].transform(np.sum)
        #myargs = f"{dfname}.groupby({groupbylist})[{fields}].transform({functions})"
        #myargs = f"{dfname}[{rfilter}].reset_index().groupby({groupbylist})[{fields}].transform('{functions[0]}').set_index({dfname}.index.names)"
        
        #myargs = f"{dfname}[{rfilter}].reset_index().groupby({groupbylist})[{fields}].transform('{functions[0]}')" #makes sample count get the wrong answer
        if rfilter:
            myargs = f"{dfname}[{rfilter}].groupby({groupbylist})[{fields}].transform('{functions[0]}')"
        else:
            myargs = f"{dfname}.groupby({groupbylist})[{fields}].transform('{functions[0]}')"
        if fname == 'domain_project_count_kwh_f':
            print('debug')
        try:
            out_df[fname] = eval(myargs)
        except Exception as e:
            print(f'problem with {fname}: {e}')
    elif len(imdgrp) > 1: #it's got an intermediate operation
        #TODO This operation is slow. See if there is a faster way
        #out_df.join(out_df[(out_df['Sampled_kwh']==True)].groupby(['SampleID', 'ss_stratum_kwh']).max().reset_index() \
        #.groupby(['SampleID']).agg({'wtd_mean_ntgr_kw': 'sum'}).rename({'wtd_mean_ntgr_kw':'NTGR_st'}, axis=1), how='left', on='SampleID', rsuffix='_grp')

        #myargs = f"{dfname}[{rfilter}].groupby({imdgrglist}).{imdfxns[0]}().reset_index().groupby({groupbylist})[{fields}].transform('{functions[0]}')"
        renamedict = {fields[0]: fname}
        if rfilter:
            myargs = f"{dfname}.join({dfname}[{rfilter}].groupby({imdgrglist}).{imdfxns[0]}().reset_index()"
        else:
            myargs = f"{dfname}.join({dfname}.groupby({imdgrglist}).{imdfxns[0]}().reset_index()"
        myargs += f".groupby({groupbylist}).agg({aggdict}).rename({renamedict}, axis=1), how='left', on='{groupbylist[0]}', rsuffix='_grp')"
        #myargs = f"{dfname}.merge({dfname}[{rfilter}].groupby({imdgrglist}).{imdfxns[0]}().reset_index()"
        #myargs += f".groupby({groupbylist}).agg({aggdict}).rename({renamedict}, axis=1), how='left', on='{groupbylist[0]}', suffixes=('', '_grp'))"

        print(f'adding imd agg {fname} using {myargs}')
        if fname == 'domain_project_count_kwh_f':
            print('debug')
        try:
            tmp_df = eval(myargs)
        except Exception as e:
            print(f'problem with {fname}: {e}')
            #NOTE if this fails it's likely due to a bad upload of project tracker resulting in ProjectDropped being empty so no records are returned
            # Just make sure Trackers last save was not admin and rerun upload_ciac_trackers, and then download Project Tracker
            # can first check db. if projectdropped has false, then just need to download project tracker
            
            #time.sleep(10)
            #tmp_df = eval(myargs)
        #try:
        else:
            out_df[fname] = tmp_df[fname]
        # except Exception as e:
        #     print(f'problem adding {fname}: {e}. Trying again')
        #     try:
        #         time.sleep(5.5) #time in seconds
        #         out_df[fname] = tmp_df[fname]
        #     except Exception as e:
        #         print(f'abort: problem adding {fname}: {e}')

    elif len(reducer) > 0: #it's a reducer option
        renamedict = {x: reducerprefix + x for x in fields}
        myargs = f"{dfname}.reset_index().merge({dfname}"
        if rfilter:
            myargs = myargs + f"[{rfilter}]"
        myargs = myargs + f".groupby({groupbylist}).agg({aggdict}).rename({renamedict}, axis=1).reset_index(), how='left')"
        if out_df.index.name != None:
            myargs = myargs + f".set_index({dfname}.index.names)"
        #     myargs = f"{dfname}.reset_index().merge({dfname}[{rfilter}].groupby({groupbylist}).agg({aggdict}).rename({renamedict}, axis=1).reset_index(), how='left').set_index({dfname}.index.names)"
        # else:
        #     myargs = f"{dfname}.reset_index().merge({dfname}[{rfilter}].groupby({groupbylist}).agg({aggdict}).rename({renamedict}, axis=1).reset_index(), how='left')"
        print(f'adding {renamedict} using {myargs}')
        try:
            dftmp = eval(myargs)
        except Exception as e:
            print(f'problem with {fname}: {e}')
        tmpname = 'dftmp'
        #Add test for not fields[1]? or is the hard fail good?
        myargs  =f"{tmpname}['{reducerprefix}' + '{fields[0]}'] {reducer} {tmpname}['{reducerprefix}' + '{fields[1]}']"
        out_df[fname] = eval(myargs)
        if fname == 'strthm_smp_count':
            print('debug')
        out_df[fname].replace(np.inf, 0, inplace=True) #get rid of divide by zero errors
    
    print(f'out_df shape after adding {fname} is {out_df.shape}')
    #end of add_agg_field

def add_eqn_field(out_df, dfname, row, eqnflag, outcol, operators, stringops):
    """
    add conditional field from a true and false value. False value can be missing
    building to the form df[fieldtoset] = (truecalc).where(condition, (falsecalc))
    if no false calc the false section is omitted
    building to the form df[fieldtoset] = (truecalc).where(condition)
    """
    headers = row.index    
    true_col = [x for x in headers if eqnflag + 'true' == x]
    false_col = [x for x in headers if eqnflag + 'false' == x]
    condition_col = [x for x in headers if eqnflag + 'condition' == x]
    fname = row[outcol]
    print(f'adding {fname} in eqn')
    parts_true = row[true_col][0].split()
    try:
        parts_false = row[false_col][0].split()
    except:
        parts_false = None
    parts_cond = row[condition_col][0].split()     

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
    
    if parts_false is not None:
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
        #find better way to handle the == and != cases more generically
        elif p not in operators and '==' not in p and '!=' not in p and '.' not in p and not is_number(p): #maybe change to startswith in operators if can use list
            parts_cond[parts_cond.index(p)] = "{}['{}']".format(dfname,p) 
        elif p in stringops:
            parts_cond[parts_cond.index(p)] = ' %s ' % p
    if not nojoin:
        eqn_cond = ''.join(parts_cond)

    if parts_false is None:
        myargs =  eqn_true + '.where(' + eqn_cond + ')'
    else:
        myargs =  eqn_true + '.where(' + eqn_cond + ', ' + eqn_false + ')'
    print(f'adding {row[outcol]} using {myargs}')
    if row[outcol] == 'EvalExPostLifecycleGrosskWh':
        print ('debug')
    out_df[row[outcol]] = eval(myargs)
    #end of add_eqn_field

def add_np_where(out_df, dfname, row, partflag, outcol, operators, stringops):
    """
    Implement inline np.where action
    sections split by semicolon
    within section test, result
    form df[newfield'] = np.where(df['field1'], iftrue, np.where(df['field2'], iftrue,iffalse))
    """
    headers = row.index
    col = [x for x in headers if partflag in x]
    sections = [x.strip() for x in row[col][0].split(';')]
    closer = ')'
    #nojoin = False
    npstring = ''
    for w in sections:
        #clauses = [x.strip().split() for x in w.split(',')]
        clauses = [x.strip() for x in w.split(',')]
        for clause in clauses:
            #nojoin = False
            parts = clause.split()
            #cbit = ''
            for p in parts:
                if len(parts)==1:
                    pass
                    #cbit = p
                    #nojoin = True
                elif p[0] =="'": #for strings
                    pass
                elif p not in operators and '==' not in p and '!=' not in p and '.' not in p and 'None' not in p and not is_number(p):
                    parts[parts.index(p)] = "{}['{}']".format(dfname,p)
                elif p in stringops:
                    parts[parts.index(p)] = ' %s ' % p
            #if not nojoin:
            clauses[clauses.index(clause)] = ''.join(parts)

        #if not nojoin:
        eqn = ','.join(clauses)
        npstring = f'{npstring}np.where({eqn}, '

    npstring = npstring[:-2] + closer*len(sections)
    myargs =  npstring
    print(f'adding {row[outcol]} using {myargs}')
    if row[outcol] == 'sampled_net_full':
        print('debug')
    out_df[row[outcol]] = eval(myargs)
    #end of add_np_where

def agg_df(src_df, dfname, row, agflag, outcol, operators, stringops):
    """
    return aggregated df
    """
    reducerprefix = 'r_'
    headers = row.index    
    ag_grp_col = [x for x in headers if agflag + 'group' == x]
    ag_filter_col = [x for x in headers if agflag + 'filter' == x]
    ag_field_col = [x for x in headers if agflag + 'field' == x]
    ag_fxn_col = [x for x in headers if agflag + 'function' == x]
    ag_redux_col = [x for x in headers if agflag + 'reducer' == x]
    
    #TODO change these to handle missing params
    try:
        group = row[ag_grp_col][0]
    except Exception as e:
        print(f'error for {row[ag_grp_col]}: {e}')
        group = row[ag_grp_col]
    try:
        rfilter = row[ag_filter_col][0] #add try in case there is no filter
        hasFilter = True
    except:
        rfilter = ''
        hasFilter = False
    field = row[ag_field_col][0]
    function = row[ag_fxn_col][0]
    try:
        reducer = row[ag_redux_col][0]
    except:
        reducer = []
    fname = row[outcol]
    print(f'adding {fname} in agg_df')
    if hasFilter:
        repl = replace_strings_with_spaces(rfilter)
        replacements = repl['replace_dict']
        rplFilter = repl['newstring']
        rfilterparts = rplFilter.split(' ') #what if there aren't any spaces?
        for p in rfilterparts:        
            if p not in operators and '=' not in p and '.' not in p and not is_number(p):
                rfilterparts[rfilterparts.index(p)] = "{}['{}']".format(dfname,p)
            elif p in stringops:
                rfilterparts[rfilterparts.index(p)] = ' %s ' % p                                  
        
        rfilter = ''.join(rfilterparts)
        rfilter = swap_out_strings(rfilter, replacements)
    groupbylist = group.split()
    fields = [x.strip() for x in field.split(',')]
    functions = [x.strip() for x in function.split(',')]
    aggdict = dict(zip(fields, functions))    
    
    if hasFilter:
        myargs = f"{dfname}[{rfilter}].groupby({groupbylist}).agg({aggdict})"
    else:
        myargs = f"{dfname}.groupby({groupbylist}).agg({aggdict})"
    if fname == 'project_fraction_LCNet_kwh':
        print('debug')
    dftmp = eval(myargs)
    
    
    if len(reducer) != 0: #then it's got a calculation
        tmpname = 'dftmp'
        myargs  =f"{tmpname}['{fields[0]}'] {reducer} {tmpname}['{fields[1]}']"
        dftmp[fname] = eval(myargs)
        dftmp = dftmp[[fname]]
    else:
        dftmp.columns = [fname]

    print(f'agg shape {fname} is {dftmp.shape}')
    return dftmp

def is_number(string):
    try:
        float(string)
        return True
    except ValueError:
        return False

def get_datadef_source_info(listdef, defpath=params.CIAC_2018_DATA_DEF_FILE):
    """
    Pass in a list of dicts defining the desired objects to return from the datadef list and the path to the def file
        Dict form is
            name: name for the return dict key that gets returned
            src: the sourcename
            return: the type of object to return
    returns a dict of objects based on the return type:
        df: dataframe from the source defined in datadefs
        path: pathname for the output table
        list: df filtered from the source
    """

    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    #open map file  
    map_item = sfsession.get_io_version(defpath)
    if not map_item:
        #Try again
        map_item = sfsession.get_io_version(defpath)
        if not map_item:
            print(f'problem retrieving {defpath}')
            return None
    map_wb = openworkbook(map_item.io_data)
    ws_src = map_wb['SourceDef']
    df_srclist = convertwstodf(ws_src,1)
    returndict = dict()
    for item in listdef:        
        if item['return'] == 'list':
            item_list = df_srclist.filter(like=item['src'], axis=0)    
            returndict[item['name']] = item_list
            continue
        else:
            item_list = df_srclist[df_srclist['sourcename']==item['src']]
        try:
            filepath = item_list.iloc[0]['location']
        except:
            returndict[item['name']] = None
            continue
        if item['return'] == 'path':            
            if not filepath:
                returndict[item['name']] = None
            else:
                returndict[item['name']] = filepath
            continue
           
        #open source
        src_item = sfsession.get_io_version(filepath)
        src_item.io_data.seek(0)
        filetype = item_list.iloc[0]['type']
        if filetype == 'csv':
            df_out = pd.read_csv(src_item.io_data)
        elif filetype == 'xls':
            sheetname = item_list.iloc[0]['sheet']
            try:
                headerrow = int(item_list.iloc[0]['startrow'])-1
            except:
                headerrow = 1
            if sheetname:
                df_out = pd.read_excel(src_item.io_data, sheet_name=sheetname, header=headerrow)
            else:
                df_out = pd.read_excel(src_item.io_data)
        else:
            returndict[item['name']] = None
            continue

        returndict[item['name']] = df_out

    return returndict

def create_framedesign(sfsession:ShareFileSession):
    """
    create the frame design data files for the ciac 2018 report that are outside the datadef file creation process due to time constraints
    output is csv file of data
    """

    srclist = [
        {'name':'frame', 'src':'framedesign', 'return':'df'},
        {'name':'pop', 'src':'SamplePop', 'return':'df'},
        {'name':'framelist', 'src':'framedesign', 'return':'list'},
    ]

    results = get_datadef_source_info(srclist)
    df_frame = results['frame']
    df_pop = results['pop']
    df_frame_list = results['framelist']
    
    domainparts = ['PA', 'SBW_ImpactType','SBW_Sector']
    df_pop['domain'] = df_pop[domainparts].apply(lambda row: '-'.join(row.values.astype(str)), axis=1)
    #limit to sampled for design values
    df_pop_smpl = df_pop.query('SampleID.notnull()')
    #limit to gross completes
    df_pop_completes = df_pop.query('GrossDisposition == "Completed"')
    #limit to net completes
    df_pop_net_completes = df_pop.query('NetDisposition == "COMPLETE"')
    # df_pop_net_sample = df_pop.query('SampleID.notnull() & NetSurveyComplDate != "NOT YET RECRUITED"')


    fuellist = []
    kwhdict = { 'fuel': 'kwh',
        'frame':'Electric',
        'sample':'Frame_Electric', 
        'strata': 'stratum_kWh'}
    thmdict = { 'fuel': 'thm',
        'frame':'Gas',
        'sample':'Frame_Gas', 
        'strata': 'stratum_thm'}
    fuellist.append(kwhdict)
    fuellist.append(thmdict)

    #get the list of the two fuel files
    df_outs = df_frame_list.iloc[1:3]
    for _, out_row in df_outs.iterrows():
        srcname = out_row['sourcename']
        fuel = srcname.split('_')[1]
        fueldict = [d for d in fuellist if d['fuel'] == fuel][0]
        popgrpby = []
        popgrpby.extend(domainparts)
        popgrpby.append('domain')
        #pull in frame, filter to fuel        
        df_frame_fuel = df_frame[df_frame.frame == fueldict['frame']]
        #pull samplepop, filter to fuel
        fuelvar = fueldict['sample']
        # fuelvarnet = 'smpld_net_'+ fueldict['sample']
        df_pop_smpl_gross_fuel = df_pop_smpl[(df_pop_smpl[fuelvar] == True) & (df_pop_smpl['smpld_primary'] == 'Y')]        
        # df_pop_smpl_net_fuel = df_pop_smpl[(df_pop_smpl[fuelvar] == 'Y') & ((df_pop_smpl['smpld_net'] == 'Y') | (df_pop_smpl['smpld_net_new'] == 'Y'))]
        df_pop_smpl_net_fuel = df_pop_smpl[(df_pop_smpl[fuelvar] == True) & ((df_pop_smpl['NetSurveyComplDate'] != 'NOT YET RECRUITED'))]
        df_pop_complete_fuel = df_pop_completes[df_pop_completes[fuelvar] == True]
        df_pop_net_complete_fuel = df_pop_net_completes[df_pop_net_completes[fuelvar] == True]

        #calculate counts
        aggdict = {'SampleID': 'count'}
        df_pop_agg = df_pop.groupby(popgrpby).agg(aggdict).reset_index()
        #add strata for the aggs
        popgrpby.append(fueldict['strata'])
        df_pop_smpl_gross_fuel_domain = df_pop_smpl_gross_fuel.groupby(popgrpby).agg(aggdict).reset_index()
        df_pop_smpl_net_fuel_domain = df_pop_smpl_net_fuel.groupby(popgrpby).agg(aggdict).reset_index()
        df_pop_gross_domain = df_pop_complete_fuel.groupby(popgrpby).agg(aggdict).reset_index()
        df_pop_net_domain = df_pop_net_complete_fuel.groupby(popgrpby).agg(aggdict).reset_index()

        #df_pop_agg.rename(columns = {fueldict['strata']:'stratum'}, inplace = True)
        df_pop_smpl_gross_fuel_domain.rename(columns = {fueldict['strata']:'stratum', 'SampleID':'GrossSampled'}, inplace = True)
        df_pop_smpl_net_fuel_domain.rename(columns = {fueldict['strata']:'stratum', 'SampleID':'NetSampled'}, inplace = True)
        df_pop_gross_domain.rename(columns = {fueldict['strata']:'stratum', 'SampleID':'GrossCompletes'}, inplace = True)
        df_pop_net_domain.rename(columns = {fueldict['strata']:'stratum', 'SampleID':'NetCompletes'}, inplace = True)
        #now can add new values to this frame (including joining on frame)
        df_frame_fuel.drop(['PA','Unnamed: 0'], axis=1, inplace=True) #dropping PA because it's in the pop tabel that we will be merging with
        df_pop_agg.drop(['SampleID'], axis=1, inplace=True)        
        indexfields = ['domain', 'stratum']
        mergefields = ['domain']
        df_domain = df_frame_fuel.merge(df_pop_agg, on=mergefields, how='left')
        indexfields.extend(domainparts)
        df_domain = df_domain.merge(df_pop_gross_domain, on=indexfields, how='left')
        #Add net completes
        df_domain = df_domain.merge(df_pop_net_domain, on=indexfields, how='left')
        df_domain = df_domain.merge(df_pop_smpl_gross_fuel_domain, on=indexfields, how='left')
        df_domain = df_domain.merge(df_pop_smpl_net_fuel_domain, on=indexfields, how='left')

        #write out file
        out_io = StringIO()
        out_io.seek(0)
        df_domain.to_csv(out_io)
        #get file name and folder ID
        # filepath = out_row['location']
        filepath = out_row['location']
        filename = os.path.basename(filepath)
        pathroot = filepath.split(filename)[0]
        folder_item = sfsession.get_item_by_local_favorites_path(pathroot)
        sfsession.upload_file(folder_item.id, filename, out_io)

def create_specialtables(sfsession:ShareFileSession):
    """
    Not implemended yet, just a stub copied from elsewhere
    create the special data files for the ciac 2018 report that are outside the datadef file creation process due to time constraints
    output is csv file of data
    """

    
    return
    #open map file    
    map_item = sfsession.get_io_version(params.CIAC_2018_DATA_DEF_FILE)
    map_wb = openworkbook(map_item.io_data)
    ws_src = map_wb['SourceDef']
    df_srclist = convertwstodf(ws_src,1)
    df_pop_list = df_srclist.filter(like='SamplePop', axis=0) #.loc['SamplePop']

    #open frame
    
    filepath = df_pop_list.iloc[0]['location']
    if not filepath:
        #print(f'no file specified for {srcname}, skipping')
        return False
    pop_item = sfsession.get_io_version(filepath)
    pop_item.io_data.seek(0)
    filetype = df_pop_list.iloc[0]['type']
    if filetype == 'csv':
        df_pop = pd.read_csv(pop_item.io_data)
    elif filetype == 'xls':
        df_pop = pd.read_excel(pop_item.io_data, sheet_name=df_pop_list.iloc[0]['sheet'], header=int(df_pop_list.iloc[0]['startrow'])-1)
    else:
        #print(f'unknown type {filetype} for {srcname} skipping')
        return False

def copy_deliverable_code(driverfile:str, sheet:str=None, srcfield='srcpath', destfield='destfolder', listfilter:str=None):
    """
    copy files as defined in passed driver file (path)
    uses internal filesystem not cloud for copy(since might be stuff not in cloud (sharefile)), but uses cloud for driver processing   
    """
    #open driver file
    df = get_df_from_driver(driverfile, sheet, listfilter)
    if df is None:
        print(f'problem opening driver file {driverfile}')
        return False

    #go through the files
    for _, row in df.iterrows():        
        if os.path.exists(row[srcfield]):
            try:
                name = os.path.basename(row[srcfield])
                create_folder(row[destfield])
                dest = os.path.join(
                    row[destfield],
                    name
                )        
                copyfile(row[srcfield], dest)
                copystat(row[srcfield], dest) #copy the file date mod etc.
            #TODO add error logging
            except PermissionError:
                print(f'Permission error for {row[srcfield]}')
            except Exception as e:                
                print(f'Error for {row[srcfield]}: {e}')
        else:
            print(f'src missing {row[srcfield]}')
    

def run_r_code(filepath):
    """
    run r code to generate tables
    """

    #run faith's r scripts
    pgm = 'Rscript.exe'
    rcommandbase = []
    rcommandbase.append(pgm)
    rcommandbase.append("--vanilla")
    path = f'"{filepath}"'
    # rcommand = rcommandbase + [r'"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\09 - Ex-Post Evaluated Gross Savings Estimates\CIAC\2018 Evaluation\Extrapolation\extrapolator_gross.R"']
    rcommand = rcommandbase + [path]
    rpath = r'C:\Program Files\R\R-3.5.2\bin' + '\\' + pgm
    #result = subprocess.run([" ".join(rcommand)], stdout=subprocess.PIPE)
    cmd = ' '.join(rcommand)
    print(cmd)
    #TODO see if this can be changed to use sharefile so at a minimum it can be run on a cloud machine, if not cloud function
    #Doesn't matter the R code is not set up to run in the cloud :(
    # cmditem = sfsession.get_io_version()
    result = subprocess.run(cmd, executable=rpath, stdout=subprocess.PIPE)
    #subprocess.call ([r"C:\Program Files\R\R-3.5.2\bin\Rscript.exe", "--vanilla", r"C:\Users\gina\OneDrive - sbw consulting\cpuc10\rtest.R"])
    #subprocess.call (["/usr/bin/Rscript", "--vanilla", "/pathto/MyrScript.r"])
    #subprocess.call (rcommand)
    
    print(result)
    if result.returncode != 0:
        print(f'problem running script:{result.returncode}')
    #or maybe 
    #subprocess.call (["/usr/bin/Rscript", "--vanilla", "/pathto/MyrScript.r"])

def create_combined_summary_tables():
    """
    combine the domain, pa and statewide tables 
    """
    srclist = [
        {'name':'domain', 'src':'domainpop', 'return':'df'},
        {'name':'pa', 'src':'papop', 'return':'df'},
        {'name':'state', 'src':'state_summary', 'return':'df'},
        {'name':'output', 'src':'combined_summary', 'return':'path'},        
    ]

    results = get_datadef_source_info(srclist)
    df_domain = results['domain']
    df_pa = results['pa']
    df_state = results['state']
    outpathname = results['output']

    df_combined = df_domain.merge(df_pa, on='PA', suffixes=('', '_pa'))
    for col in df_state.columns:
        df_combined[col] = df_state[col][0]  #df_combined.merge(df_state,suffixes=('', '_state'))
    df_to_csv_sharefile(df_combined, outpathname)

def create_combined_ar_table():
    """
    combine the AR domain, pa and statewide tables 
    """
    srclist = [
        {'name':'domain', 'src':'ar_domain', 'return':'df'},
        {'name':'pa', 'src':'ar_pa', 'return':'df'},
        {'name':'state', 'src':'ar_state', 'return':'df'},
        {'name':'output', 'src':'ar_combined', 'return':'path'},        
    ]

    results = get_datadef_source_info(srclist)
    df_domain = results['domain']
    df_pa = results['pa']
    df_state = results['state']
    outpathname = results['output']

    df_combined = df_domain.merge(df_pa, on='PA', suffixes=('', '_pa'))
    for col in df_state.columns:
        df_combined[col] = df_state[col][0]  #df_combined.merge(df_state,suffixes=('', '_state'))
    df_to_csv_sharefile(df_combined, outpathname)

def create_responserate(sfsession):
    """"
    create the response rate data file 
    """

    srclist = [
        {'name':'eval', 'src':'ClaimPop', 'return':'df'},
        # {'name':'netdispo', 'src':'netdispo', 'return':'df'},
        {'name':'output', 'src':'responserate', 'return':'path'},        
    ]

    results = get_datadef_source_info(srclist)
    # df_dispo = results['netdispo']
    df_eval = results['eval']
    outpathname = results['output']

    #get dispo category map
    map_item = sfsession.get_io_version(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\DataSourceDef.xlsx')
    df_map = pd.read_excel(map_item.io_data, sheet_name='dispomap')
    
    df_map_ = df_map.groupby(['category', 'grosscategory', 'catkey', 'status']).size().reset_index()
    df_gross_e = df_eval[df_eval['Frame_Electric']==True].groupby(['SampleID', 'PA',  'GrossDisposition']).size().reset_index()
    df_gross_e['Frame'] = 'Electric'
    df_gross_g = df_eval[df_eval['Frame_Gas']==True].groupby(['SampleID', 'PA', 'GrossDisposition']).size().reset_index()
    df_gross_g['Frame'] = 'Gas'
    df_gross_ = pd.concat([df_gross_e, df_gross_g])
    df_dispo_e = df_eval[df_eval['NetSample_kwh']==True].groupby(['SampleID', 'PA', 'dispositioncategory']).size().reset_index()
    df_dispo_e['Frame'] = 'Electric'
    df_dispo_g = df_eval[df_eval['NetSample_thm']==True].groupby(['SampleID', 'PA', 'dispositioncategory']).size().reset_index()
    df_dispo_g['Frame'] = 'Gas'
    df_dispo_ = pd.concat([df_dispo_e, df_dispo_g])
    df_all = df_dispo_.merge(df_map_, left_on='dispositioncategory', right_on='category')
    print(df_all.shape)
    df_all_master = df_all.groupby(['catkey', 'Frame']).size().reset_index()
    df_rate = df_all.groupby(['PA', 'Frame', 'catkey']).size().reset_index()
    df_counts = df_all.groupby(['PA', 'Frame', 'status']).size().reset_index()
    df_totals = df_all.groupby(['PA', 'Frame']).size().reset_index()
    field = 'count'
    df_rate.rename(columns={0:field}, inplace=True)
    df_all_master.rename(columns={0:field}, inplace=True)
    df_counts.rename(columns={0:field}, inplace=True)
    df_totals.rename(columns={0:field}, inplace=True)
    # print(df_totals)
    # tmp = df_all.groupby(['PA','dispositioncategory']).pipe(lambda grp: grp.domain_weight_kwh.max() * grp.subsample_weight_kwh.max() * grp.size())
    # df_rate = df_rate.pivot(index=('PA', 'Frame_Electric', 'Frame_Gas'), columns='catkey', values=field).reset_index()
    # df_rate = df_rate.set_index(['PA', 'Frame_Electric', 'Frame_Gas','catkey']).unstack(level=-1).reset_index()
    # df_rate.columns = df_rate.columns.droplevel(0)
    # df_rate.reset_index(inplace=True)
    df_rate = df_rate.groupby(['PA', 'Frame','catkey'])[field].sum().unstack(fill_value=0).reset_index()
    # df_counts = df_counts.pivot(index=['PA', 'Frame_Electric', 'Frame_Gas'], columns='status', values=field).reset_index()
    df_counts = df_counts.groupby(['PA', 'Frame','status'])[field].sum().unstack(fill_value=0).reset_index()
    df_all_master = df_all_master.groupby(['Frame','catkey'])[field].sum().unstack(fill_value=0).reset_index()
    # df_all_master.set_index('catkey', 'Frame', inplace=True)
    # df_all_master = df_all_master.transpose()
    df_rate.fillna(0, inplace=True)
    df_counts.fillna(0, inplace=True)

    df = df_all_master
    df['rate']= df.I/((df.I + df.P) + (df.UHR + df.UHNC) + (df.UH * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    df.reset_index(inplace=True)
    totalrate = df[['Frame', 'rate']]
    totalrate.rename(columns={'rate':'totalrate'}, inplace=True)
    print (df)
    df = df_rate
    df['rate']= df.I/((df.I + df.P) + (df.UHR + df.UHNC) + (df.UH * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    print (df)
    df = df_counts
    df_final = df_rate.merge(df_counts, on=['PA', 'Frame'])
    df_final = df_final.merge(df_totals, on=['PA', 'Frame'])
    df_final = df_final.merge(totalrate, on=['Frame'])
    # df_final['totalrate'] = totalrate
    
    #add in Gross counts
    #TODO change merge so all categories are kept even if no counts
    df_gross_all = df_gross_.merge(df_map_, left_on='GrossDisposition', right_on='grosscategory')
    df_gross_all_master = df_gross_all.groupby(['catkey', 'Frame']).size().reset_index()
    df_gross_rate = df_gross_all.groupby(['PA', 'Frame', 'catkey']).size().reset_index()
    df_gross_counts = df_gross_all.groupby(['PA', 'Frame', 'status']).size().reset_index()    
    df_gross_totals = df_gross_all.groupby(['PA', 'Frame']).size().reset_index()    
    
    df_gross_all_master.rename(columns={0:field}, inplace=True)
    df_gross_rate.rename(columns={0:field}, inplace=True)
    df_gross_counts.rename(columns={0:field}, inplace=True)
    df_gross_totals.rename(columns={0:field}, inplace=True)
    print(df_gross_totals)
    # df_gross_rate = df_gross_rate.pivot(index='PA', columns='catkey', values=field).reset_index()
    df_gross_rate = df_gross_rate.groupby(['PA', 'Frame','catkey'])[field].sum().unstack(fill_value=0).reset_index()
    # df_gross_counts = df_gross_counts.pivot(index='PA', columns='status', values=field).reset_index()
    df_gross_counts = df_gross_counts.groupby(['PA', 'Frame','status'])[field].sum().unstack(fill_value=0).reset_index()
    df_gross_all_master = df_gross_all_master.groupby(['Frame','catkey'])[field].sum().unstack(fill_value=0).reset_index()
    # df_gross_all_master.set_index('catkey', inplace=True)
    # df_gross_all_master = df_gross_all_master.transpose()
    df_gross_rate.fillna(0, inplace=True)
    df_gross_counts.fillna(0, inplace=True)

    df = df_gross_all_master
    # df['rate']= df.I/((df.I + df.P) + (df.UHR + df.UHNC) + (df.UH * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    df['rate']= df.I/((df.I + 0) + (0) + (0 * ((df.I + 0)/(df.I + 0 + df.X1)))) *100
    # df['rate']= df.I/((df.I + df.P) + (0) + (0 * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    totalrate = df[['Frame', 'rate']]
    totalrate.rename(columns={'rate':'totalrate_g'}, inplace=True)
    print (df)
    df = df_gross_rate
    # df['rate']= df.I/((df.I + df.P) + (df.UHR + df.UHNC) + (df.UH * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    df['rate']= df.I/((df.I + 0) + (0) + (0 * ((df.I + 0)/(df.I + 0 + df.X1)))) *100
    # df['rate']= df.I/((df.I + df.P) + (0) + (0 * ((df.I + df.P)/(df.I + df.P + df.X1)))) *100
    print (df)
    df = df_gross_counts

    #Jeff's quick and dirty fix for zero count variables
    df_gross_counts['Partial'] = 0
    df_gross_counts['Refused'] = 0
    df_gross_counts['Ineligible'] = 0
    df_gross_counts['NoInfo'] = 0

    df_final = df_final.merge(df_gross_counts, on=['PA', 'Frame'], suffixes=('', '_g'))
    df_final = df_final.merge(df_gross_totals, on=['PA', 'Frame'], suffixes=('', '_g'))
    df_final = df_final.merge(df_gross_rate, on=['PA', 'Frame'], suffixes=('', '_g'))
    df_final = df_final.merge(totalrate, on=['Frame'])
    # df_final['totalrate_g'] = totalrate

    print (df_final)
    df_to_csv_sharefile(df_final, outpathname)

  
    print('yeah baby')

def compare_datasets(): #olddata, newdata, indexlist, comparefields, outputfile):
    """
    compare data between two datasets
    """

    filepath = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop3_29.csv"
    item = sfsession.get_io_version(filepath)
    item.io_data.seek(0)
    df_old = pd.read_csv(item.io_data)

    filepath = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop.csv"
    item = sfsession.get_io_version(filepath)
    item.io_data.seek(0)
    df_new = pd.read_csv(item.io_data)
    # dfMA = pd.merge(dfMA, dfData, how='left', left_on=[lindex], right_on=[rindex], suffixes = ('','_msr'))
    df = pd.merge(df_old, df_new, on='ClaimID', suffixes = ('_old',''))
    df_dif = df

    fields = ['SampleID', 'ClaimID']
    
    roots = ['st_EvalNTGR', 'EvalExPostAnnualizedNet', 'EvalExPostLifeCycleNet']
    fuels = ['kW', 'kWh', 'Therm']
    for root in roots:
        for fuel in fuels:
            df_dif[root + fuel + '_dif'] = df_dif[root + fuel] - df_dif[root + fuel + '_old']        
            fields.append(root + fuel)
            fields.append(root + fuel + '_dif')
            fields.append(root + fuel + '_old')

    extrafields = ['EUL_Yrs','RUL_Yrs','Eval_adj_EUL','Eval_adj_RUL'
]
    fields.extend(extrafields)
    df_out = df_dif[fields]
    fileout = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\netdif.csv'
    df_out.to_csv(fileout)

    # df = pd.concat([df_old, df_new]) # concat dataframes
    # df = df.reset_index(drop=True) # reset the index
    # df_gpby = df.groupby(list(df.columns)) #group by
    # idx = [x[0] for x in df_gpby.groups.values() if len(x) == 1] 

    # print(f'what is with idx: {len(idx)}')
    # df = pd.concat([df1, df2]) # concat dataframes
    # df = df.reset_index(drop=True) # reset the index
    # df_gpby = df.groupby(list(df.columns)) #group by
    # idx = [x[0] for x in df_gpby.groups.values() if len(x) == 1] 


def xcreate_reasons_plots():
    """
    Not used anymore
    specific to ciac 2018

    Chart save action is not via sharefile api, so only run locally
    """

    source = pd.read_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\claimpop.csv')
    fields = ['EvalBase1kWhReasons', 'EvalBase1ThermReasons', 'EvalBase2kWhReasons', 'EvalBase2ThermReasons']
    #fields = ['EvalBase1kWhReasons']
    totalcnts = source[source['Frame_Electric'].notnull()].groupby(['PA']).size().reset_index()
    totalcnts.rename(columns={0:'pop'}, inplace=True)
    root = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output'
    for field in fields:
        if 'kwh' in field.lower():
            stratumfield = 'ss_stratum_kwh'
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
        else:
            stratumfield = 'ss_stratum_thm'
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'        
        df_reasons = source[source[field].notnull()]
        reasons_list = df_reasons[field].unique().tolist()
        reasons_list = [x for x in reasons_list if 'Not ' not in x]
        df_reasons  = df_reasons[df_reasons[field].isin(reasons_list)]
        # df_to_csv_sharefile(df_reasons, root + f'\\reasons_{field}.csv')
        
        tmp = df_reasons.groupby(['PA','domain', 'SampleID', stratumfield, field]).pipe(lambda grp: (1 / (grp[dwfield].max() * grp[sswfield].max())) * grp.size()).unstack().reset_index().groupby(['domain', 'PA']).sum().round(0).astype(int).reset_index()
        tmp.reset_index(drop=True, inplace=True)#.set_index('PA')
        tmp.drop(['SampleID', stratumfield, 'domain'], axis=1, inplace=True)
        tmp = tmp.groupby(['PA']).sum()
        #print(tmp.columns)
        tmp = totalcnts.merge(tmp, on='PA')
        #tmp.set_index('PA', inplace=True)
        df_chart = tmp.melt(id_vars=['PA', 'pop'], var_name='reason', value_name='count')
        df_chart['pctclm']= (1-(df_chart['count'] / df_chart['pop']) * 100).round(0).astype(int)
        #print(f'chart shape {df_chart.shape}')
    #     print(tmp)
        # df_to_csv_sharefile(tmp, root + f'\\reasons_tmp_{field}.csv')
        
        
        
        base = alt.Chart().encode(
            alt.X(
                'PA:N',
                # scale=alt.Scale(rangeStep=20),
                axis=alt.Axis(title='', labels=False, ticks=False),
            ),
            alt.Y(
                #'count(ClaimID)',
                'pctclm:Q',
                axis=alt.Axis(title='Percent of Claims')
            ),
        ).properties(width=110) #TODO figure out way to adjust size without hard coding it
        bars = base.mark_bar(size=18).encode(
                color='PA:N',
        )
        text = base.mark_text(dy=-8).encode(
                #text='count(ClaimID)',
                text='pctclm:Q',
        )
        chart_cc = alt.layer(bars, text, data=df_chart).facet(
            #column=field,
            column='reason',
        ).configure_axis(
            domainWidth=1,
            domainColor='black',
        ).configure_header(
            title=None,
            labelOrient='bottom',
        ).configure_view(
            height=400,
        ).configure_legend(
            title=None,
            orient='bottom',
            columnPadding=20,
        )
        
        chart_cc.save(root + '\\' + field + '.svg', webdriver='firefox')
        #chart_cc.save(root + '\\' + field + '.png', webdriver='firefox')

def create_ciac2018_ar_table():
    """
    Generate the table for the AR report table.
    Not generalized, specific to 2018 ciac
    """

    srclist = [
        {'name':'source', 'src':'ClaimPop', 'return':'df'},
        {'name':'output', 'src':'ar_table', 'return':'path'},        
    ]

    results = get_datadef_source_info(srclist)
    source = results['source']
    outpathname = results['output']

    df_ar = source[(source['Frame_Electric']==True)]
    domains = pd.DataFrame(df_ar.groupby(['domain', 'PA']).groups.keys())
    domains.rename(columns={0:'domain', 1:'PA'}, inplace=True)
    stratumfield = 'ss_stratum_kwh'
    dwfield = 'domain_prob_sel_kwh'
    sswfield = 'ss_prob_sel_kwh'
    field_AR_clm = 'Claim_AR_ExAnte_LifeCycleGross_NoRR_kwh'
    field_clm = 'ExAnte_LifeCycleNet_NoRR_kWh'
    field_AR_eval = 'Eval_AR_ExAnte_LifeCycleGross_NoRR_kwh'
    field_eval = 'EvalExPostLifeCycleNetkWh'
    field_eval_an = 'EvalExPostAnnualizedGrosskWh'
    fields = [field_AR_clm, field_clm, field_AR_eval, field_eval, field_eval_an]
    df_final = None
    for field in fields:
        tmp = df_ar.groupby(['PA','domain', 'SampleID', stratumfield]).pipe(lambda grp: (1 / (grp[dwfield].max() * grp[sswfield].max())) * grp[field].sum()).reset_index().groupby(['domain', 'PA']).sum().round(0).astype(int).reset_index()
        tmp.rename(columns={0:field}, inplace=True)
        tmp.drop(['SampleID', 'PA', stratumfield], axis=1, inplace=True)
        if df_final is None:
            df_final = tmp
        else:
            df_final = df_final.merge(tmp, on='domain')
            
    df_final['exante_pct_ar'] = (df_final[field_AR_clm] /df_final[field_clm] * 100).round(0).astype(int)
    df_final['expost_pct_ar'] = (df_final[field_AR_eval] /df_final[field_eval] * 100).round(0).astype(int)
    df_final['EUL'] = (df_final[field_eval] / df_final[field_eval_an]).round(2)
    df_final = df_final.merge(domains, how='right')    
    df_to_csv_sharefile(df_final, outpathname)

def create_ciac2018_dist_savings(captions, outputfolder=None, printdata=False):
    """
    Create the distribution savings visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
        # {'name':'dsum', 'src':'domainpop', 'return':'df'},
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']
    # domain = results['dsum']
    # source = claim.merge(domain, on='domain')
    # print(source.shape)
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    clusterfield = 'PA'
    seqfield = 'seq'
    colorfield = 'typesector'
    source[colorfield] = source['SBW_ImpactType'] + ' - ' + source['SBW_Sector'] 
    weighted = False

    for caption in captions:
        if 'kWh' in caption and 'GRR' in caption:
            # rrfield = 'dom_eval_RR_kWh_LG'
            rrfield = 'prj_lifecyclegross_rr_kwh'
            if weighted:
                savfield = 'weighted_expost_lifecycle_gross_kwh'
            else:
                savfield = 'EvalExPostAnnualizedGrosskWh'
                savfield = 'EvalExPostLifeCycleGrosskWh'
            ytitle = 'Gross Realization Rate'            
            fuelfield = 'sampled_kWh'
            fuelfield = 'Frame_Electric'
            # grossdomain =  True
            filterfield = 'GrossDisposition'
            filtervalue = 'Completed' 
        elif 'kWh' in caption and 'NTGR' in caption:
            rrfield = 'mean_ntgr_kwh'
            if weighted:
                savfield = 'weighted_expost_lifecycle_net_kwh'
            else:
                savfield = 'EvalExPostAnnualizedNetkWh'
                savfield = 'EvalExPostLifeCycleNetkWh'
            ytitle = 'Net-to-Gross Ratio'
            fuelfield = 'sampled_kWh'
            fuelfield = 'Frame_Electric'
            # grossdomain = False
            filterfield = 'NetDisposition'
            filtervalue = 'COMPLETE'
        elif 'Therm' in caption and 'GRR' in caption:
            # rrfield = 'dom_eval_RR_thm_LG'
            rrfield = 'prj_lifecyclegross_rr_thm'
            if weighted:
                savfield = 'weighted_expost_lifecycle_gross_thm'
            else:
                savfield = 'EvalExPostAnnualizedGrossTherm'
                savfield = 'EvalExPostLifeCycleGrossTherm'
            ytitle = 'Gross Realization Rate'
            fuelfield = 'sampled_thm'
            fuelfield = 'Frame_Gas'
            # grossdomain = True
            filterfield = 'GrossDisposition'
            filtervalue = 'Completed' 
        elif 'Therm' in caption and 'NTGR' in caption:
            rrfield = 'mean_ntgr_thm'
            if weighted:
                savfield = 'weighted_expost_lifecycle_net_thm'
            else:
                savfield = 'EvalExPostAnnualizedNetTherm'
                savfield = 'EvalExPostLifeCycleNetTherm'
            ytitle = 'Net-to-Gross Ratio'
            fuelfield = 'sampled_thm'
            fuelfield = 'Frame_Gas'
            # grossdomain = False
            filterfield = 'NetDisposition'
            filtervalue = 'COMPLETE'            
        else:
            print(f'unknown caption {caption}, cannot make plot')
            continue
        # if grossdomain:
        # bubblesource = source[(source[fuelfield]=='Y') & (source[filterfield]==filtervalue)].groupby(['SampleID', clusterfield, colorfield ]).agg({savfield:sum, rrfield:'mean'}).reset_index()
        bubblesource = source[(source[fuelfield]) & (source[filterfield]==filtervalue)].groupby(['SampleID', clusterfield, colorfield ]).agg({savfield:sum, rrfield:'mean'}).reset_index()
        # else:
        #     bubblesource = source[(source[fuelfield]=='Y') & (source[filterfield]=='Completed')].groupby(['SampleID', clusterfield, colorfield ]).agg({savfield:sum, rrfield:'mean'}).reset_index()
        logsavfield = 'logsave'
        bubblesource[logsavfield] = np.log10(bubblesource[savfield])
        binmin = int(bubblesource[bubblesource[logsavfield] > 0][logsavfield].min())
        binmax = math.ceil(bubblesource[logsavfield].max())
        totalbins = 6
        binstep = math.ceil((binmax-binmin)/totalbins)
        binstr = f'bin=alt.Bin(extent=[{binmin}, {binmax}], step={binstep})'
        # binstr = f'bin=alt.Bin(extent=[{binmin}, {binmax}], step=2)'

        # print(f'binstr is: {binstr}')
        bubblesource[seqfield] = bubblesource.groupby([clusterfield, colorfield]).cumcount()+1
        #remap utlity names
        bubblesource[clusterfield] = bubblesource[clusterfield].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'bubbles_'+ fuelfield + '-' + rrfield + '-weighted_' + str(weighted) + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(bubblesource,tmppath)

        #temp because regular section below is broken
        base = alt.Chart().encode(
            alt.X('seq:Q',axis=alt.Axis(title='Sampled Projects', grid=False, labels=False, ticks=False)), 
            alt.Y('prj_lifecyclegross_rr_kwh:Q',title='Gross Realization Rate',)
            ).properties(width=150,height=150)
        rule = alt.Chart().mark_rule(color='red').encode(y='mean(prj_lifecyclegross_rr_kwh):Q')

        points = base.mark_point(filled=True, size=100).encode(color=alt.Color('typesector:N'))

        fig = alt.layer(points  + rule, data=bubblesource).facet(column='PA:N',
            ).configure_axis(domainWidth=1,
            ).configure_header(title=None,labelOrient='top'
        ).configure_legend(title=None,orient='bottom'
            ).resolve_scale(y='independent',x='independent')

        filepath = os.path.join(outputfolder, caption + '.svg')
        #TODO see if can save to fileobject
        fig.save(filepath, webdriver='firefox')

        continue
        #stuff below here is broken
        spec = vs.vis()
        spec.type = 'point'
        spec.size = 100
        spec.source = bubblesource
        spec.size_src = False   #logsavfield
        spec.sizecolor = True
        spec.binspec = binstr
        spec.size_legend = False #True
        spec.color_src = colorfield + ':N'
        spec.color_legend = True   #change back to true after sort out size
        spec.column_src = clusterfield + ':N'
        if weighted:
            spec.name = caption
        else:
            spec.name = caption + '_unweighted'
        spec.path = outputfolder
        spec.legend_title = None
        spec.legend_orient = 'bottom'
        spec.filled = True
        spec.rule = True
        spec.rule_field = rrfield
        spec.rule_type = 'mean'
        
        xaxis = vs.d_axis()
        xaxis.title = 'Sampled Projects'
        xaxis.source = seqfield + ':Q'
        xaxis.resolvescale = 'independent'

        yaxis = vs.d_axis()
        yaxis.title = ytitle
        yaxis.source = rrfield + ':Q'
        yaxis.resolvescale = 'independent'

        spec.x = xaxis
        spec.y = yaxis

        vs.facet(spec)

def ciac2018_dist_savings_plotly(captions, outputfolder=None, printdata=True):
    """
    Create the distribution savings visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
        # {'name':'dsum', 'src':'domainpop', 'return':'df'},
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']
    # domain = results['dsum']
    # source = claim.merge(domain, on='domain')
    # print(source.shape)
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    clusterfield = 'PA'
    seqfield = 'seq'
    colorfield = 'typesector'
    source[colorfield] = source['SBW_ImpactType'] + ' - ' + source['SBW_Sector'] 
    weighted = False
    markersize = 12
    fontsize = 16

    coloritemlist = source[colorfield].unique().tolist()
    #plotly = ['#636EFA', '#EF553B', '#00CC96', '#AB63FA', '#FFA15A', '#19D3F3', '#FF6692', '#B6E880', '#FF97FF', '#FECB52']
    #alphabet = ['#AA0DFE', '#3283FE', '#85660D', '#782AB6', '#565656', '#1C8356', '#16FF32', '#F7E1A0', '#E2E2E2', '#1CBE4F', '#C4451C', '#DEA0FD', '#FE00FA', '#325A9B', '#FEAF16', '#F8A19F', '#90AD1C', '#F6222E', '#1CFFCE', '#2ED9FF', '#B10DA1', '#C075A6', '#FC1CBF', '#B00068', '#FBE426', '#FA0087']
    customcolorlist = ['#AA0DFE', '#3283FE', '#85660D', '#1C8356', '#EF553B','#222A2A','#F7E1A0']
    customcolorlist = ['red', 'violet', 'blue', 'green', 'orange','black', 'yellow']
    # colormap = {x:px.colors.qualitative.Plotly[coloritemlist.index(x)] for x in coloritemlist}
    colormap = {x:customcolorlist[coloritemlist.index(x)] for x in coloritemlist}
    #other color names to try are Vivid, Safe
    #for full list see https://plotly.com/python/discrete-color/#color-sequences-in-plotly-express

    for caption in captions:
        if 'kWh' in caption and 'GRR' in caption:
            # rrfield = 'dom_eval_RR_kWh_LG'
            rrfield = 'prj_lifecyclegross_rr_kwh'
            if weighted:
                savfield = 'weighted_expost_lifecycle_gross_kwh'
            else:
                savfield = 'EvalExPostAnnualizedGrosskWh'
                savfield = 'EvalExPostLifeCycleGrosskWh'
            ytitle = 'Gross Realization Rate'            
            fuelfield = 'sampled_kWh'
            fuelfield = 'Frame_Electric'
            # grossdomain =  True
            filterfield = 'GrossDisposition'
            filtervalue = 'Completed' 
        elif 'kWh' in caption and 'NTGR' in caption:
            rrfield = 'mean_ntgr_kwh'
            if weighted:
                savfield = 'weighted_expost_lifecycle_net_kwh'
            else:
                savfield = 'EvalExPostAnnualizedNetkWh'
                savfield = 'EvalExPostLifeCycleNetkWh'
            ytitle = 'Net-to-Gross Ratio'
            fuelfield = 'sampled_kWh'
            fuelfield = 'Frame_Electric'
            # grossdomain = False
            filterfield = 'NetDisposition'
            filtervalue = 'COMPLETE'
        elif 'Therm' in caption and 'GRR' in caption:
            # rrfield = 'dom_eval_RR_thm_LG'
            rrfield = 'prj_lifecyclegross_rr_thm'
            if weighted:
                savfield = 'weighted_expost_lifecycle_gross_thm'
            else:
                savfield = 'EvalExPostAnnualizedGrossTherm'
                savfield = 'EvalExPostLifeCycleGrossTherm'
            ytitle = 'Gross Realization Rate'
            fuelfield = 'sampled_thm'
            fuelfield = 'Frame_Gas'
            filterfield = 'GrossDisposition'
            filtervalue = 'Completed' 
        elif 'Therm' in caption and 'NTGR' in caption:
            rrfield = 'mean_ntgr_thm'
            if weighted:
                savfield = 'weighted_expost_lifecycle_net_thm'
            else:
                savfield = 'EvalExPostAnnualizedNetTherm'
                savfield = 'EvalExPostLifeCycleNetTherm'
            ytitle = 'Net-to-Gross Ratio'
            fuelfield = 'sampled_thm'
            fuelfield = 'Frame_Gas'
            filterfield = 'NetDisposition'
            filtervalue = 'COMPLETE'            
        else:
            print(f'unknown caption {caption}, cannot make plot')
            continue
        bubblesource = source[(source[fuelfield]) & (source[filterfield]==filtervalue)].groupby(['SampleID', clusterfield, colorfield ]).agg({savfield:sum, rrfield:'mean'}).reset_index()
        logsavfield = 'logsave'
        bubblesource[logsavfield] = np.log10(bubblesource[savfield])
        bubblesource[seqfield] = bubblesource.groupby([clusterfield, colorfield]).cumcount()+1
        #remap utlity names
        bubblesource[clusterfield] = bubblesource[clusterfield].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'bubbles_'+ fuelfield + '-' + rrfield + '-weighted_' + str(weighted) + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(bubblesource,tmppath)

        # plottype = 'scatter'
        plotfiletype = '.svg'
        utillist = bubblesource[clusterfield].unique()
        totalsubplots = len(utillist)

        if not outputfolder:
            outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
        
        rows = 1
        cols = totalsubplots
        subplot_titlelist = [f'<b>{x}</b>' for x in utillist]

        fig = make_subplots(rows=rows, cols=cols, shared_yaxes=False,
                subplot_titles=subplot_titlelist, #for titles above subplots
                )
        i=0
        j = 1
        legendlist = []

        for util in utillist:
            df_chart = bubblesource[bubblesource[clusterfield]==util]
            i += 1
            if i > cols:
                i = 1
                j = 2

            # position = (j-1) * cols + i
            if df_chart[rrfield].max() <4:
                tickformatstring = '.1f'
            else:
                tickformatstring = None
            plotdata = []
            coloritems = df_chart[colorfield].unique()
            ymean = df_chart[rrfield].mean()
            xmax = df_chart[seqfield].max()

            for item in coloritems:
                df_item = df_chart[df_chart[colorfield]==item]
                plotdata.append(
                    go.Scatter(
                        x=df_item[seqfield], 
                        y=df_item[rrfield],                        
                        mode='markers',
                        name= item,
                        marker=dict(
                            color=colormap[item],
                            opacity=0.75,
                            size=markersize,
                            ),                        
                        showlegend= item not in legendlist, #(position % 2 ) == 1,   #odd places
                    )
                )            
                legendlist.append(item)

            # fig = go.Figure(plotdata)
            # Add traces
            fig.add_traces(plotdata,  rows=[j] * len(plotdata), cols=[i] * len(plotdata))
            linelegend = 'mean'
            fig.add_trace(go.Scatter(x=[0,xmax +1], y=[ymean, ymean],
                                mode='lines',
                                name=linelegend,
                                marker=dict(color='red'),
                                # legendgroup='line',
                                showlegend= False, #position==totalsubplots,
                            ) 
                    , row=j, col=i
                    )
            legendlist.append(linelegend)

            fig.update_xaxes(title_text='<b>Sampled Projects</b>', showticklabels= False,
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                row=j, col=i)
            fig.update_yaxes(
                # range=yrange
                nticks=6,
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                zeroline=True, zerolinewidth=axis_line_width, zerolinecolor=grid_color, 
                showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color,
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                tickformat= tickformatstring, row=j, col=i)            
        
        fig.update_yaxes(title_text=f'<b>{ytitle}</b>', row=j, col=1)
        width = cols * 300
        rowheight = 400 #rows 5
        fig.update_layout(
            title=None,
            plot_bgcolor='white',
            # legend=dict(x=.5, y=-.3, xanchor='center', yanchor='top', orientation="h",
            legend=dict(x=.5, xanchor='center', yanchor='top', orientation="h",
                font=dict(
                    family=fontfamily,
                    size=g_font_size + 2,
                    ),
                ),            
            width=width,
            height=rowheight * rows ,# * 1.2,
            font=dict(
                family=fontfamily,                
                size=g_font_size,
        #         color="#7f7f7f"
            ),
            margin=dict(
                t=40, #to leave room for the subplot titles
                b=0,
                l=0,
                r=10,
                pad=0
            )
        )
            
  
        filename = os.path.join(outputfolder, caption + plotfiletype)
        fig.write_image(filename)  # save the figure to file
            

def create_ciac2018_netanal(captions, printdata=True):
    """
    Create the net survey process analysis tables (from Rick) for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [{'name':'netsurvey', 'src':'netsurvey', 'return':'df'}]
    results = get_datadef_source_info(srclist)
    dfnetanal = results['netsurvey']
    
    outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    
    clusterfield = 'variable:N'
    colorfield = 'type'
    yfield = 'pct:Q'
    ytitle = '' 
    xfield = colorfield
    

    for caption in captions:
        if 'Learned' in caption:
            df = dfnetanal[(dfnetanal.table == 'Awareness')]
            df = df.drop(['table'], axis=1)
            df = df[df['variable'] != 'Total']
            df.replace('sbd', 'SBD Participants', inplace=True)
            df.replace('xsbd', 'Non-SBD Participants', inplace=True)
            field = 'Awareness'
            viz = alt.Chart(df).mark_bar().encode(
                alt.X(yfield, axis=alt.Axis(title=None)),# grid=False, labels=False)),
                alt.Y(colorfield,axis=alt.Axis(title=None, grid=False, labels=False, ticks=False)),
                color=colorfield,
                row=alt.Row(clusterfield, title="",header=alt.Header(labelAngle=0, labelAnchor='end'))
            ).configure_legend(
                title=None,
                orient='bottom',                
            )
            filepath = os.path.join(outputfolder, caption + '.svg')
            #TODO see if can save to fileobject
            viz.save(filepath, webdriver='firefox')
        elif 'Strengths' in caption:
            df = dfnetanal[(dfnetanal.table == 'Strengths')]
            df = df.drop(['table'], axis=1) 
            field = 'Strengths'
        elif 'Satisfaction' in caption:
            df = dfnetanal[(dfnetanal.table == 'Satisfaction')]
            df = df.drop(['table'], axis=1)
            field = 'Satisfaction'
        elif 'Years' in caption:
            df = dfnetanal[(dfnetanal.table == 'LT2')]
            df = df.drop(['table', 'sbd',  'pctsbd'], axis=1)
            field = 'LT2'
        else:
            print(f'unknown caption {caption}, cannot make plot')
            continue
        
        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'reasons_'+ field + '-' + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df,tmppath)
        
        # spec = vs.vis()
        # spec.type = 'bar'
        # spec.source = df
        # spec.color = colorfield
        # # spec.size_src = savfield
        # # spec.sizecolor = True
        # spec.column_src = clusterfield + ':N'
        # spec.name = caption
        # spec.path = outputfolder
        # spec.facet_labelOrient = 'bottom'
        # spec.legend_orient = 'bottom'
        # spec.c_height = 400
        
        # xaxis = vs.d_axis()
        # xaxis.title = ''
        # yaxis = vs.d_axis()
        # yaxis.title = ytitle
        # if field == 'Awareness':
        #     xaxis.source = xfield + ':Q'
        #     yaxis.source = yfield + ':N'
        # else:
        #     xaxis.source = xfield + ':N'
        #     yaxis.source = yfield + ':Q'
        # # xaxis.resolvescale = 'independent'
        # # yaxis.resolvescale = 'independent'
        
        # spec.x = xaxis
        # spec.y = yaxis
        
        # vs.facet(spec)
        
def create_ciac2018_reasons_diff(captions, outputfolder=None, printdata=True):
    """
    Create the reasons for diff visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
        # {'name':'dsum', 'src':'domainpop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']


    fields = ['EvalBase1kWhReasons', 'EvalBase1ThermReasons', 'EvalBase2kWhReasons', 'EvalBase2ThermReasons']
    #fields = ['EvalBase1kWhReasons']
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
 
    for caption in captions:         
        if 'kwh' in caption.lower():
            stratumfield = 'ss_stratum_kwh'
            # domainstratum = 'stratum_kWh'
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
            frame = 'Frame_Electric'
            if 'First' in caption:
                field = 'EvalBase1kWhReasons'
            else: 
                field = 'EvalBase2kWhReasons'
        else:
            stratumfield = 'ss_stratum_thm'
            # domainstratum = 'stratum_thm'
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'
            frame = 'Frame_Gas'
            if 'First' in caption:
                field = 'EvalBase1ThermReasons'
            else: 
                field = 'EvalBase2ThermReasons'

        colorfield = 'PA'
        yfield = 'pctclm'
        ytitle = 'Percent of Claims'
        xfield = colorfield
        reasonfield = 'reason'
        df_reasons = source[source[field].notnull() & (source[frame]==True)]
        reasons_list = df_reasons[field].unique().tolist()
        reasons_list = [x for x in reasons_list if 'Not ' not in x]
        df_reasons  = df_reasons[df_reasons[field].isin(reasons_list)]
        
        totalcnts = source[source[frame]==True].groupby([colorfield]).size().reset_index()
        totalcnts.rename(columns={0:'pop'}, inplace=True)
        #replace inf?
        # df_reasons.replace(np.inf, 0, inplace=True)
        tmp = df_reasons.groupby([colorfield,'domain','SampleID', stratumfield, field]).pipe(lambda grp: (1 / (grp[dwfield].max() * grp[sswfield].max())) * grp.size()).unstack().reset_index().groupby(['domain', 'PA']).sum().round(0).reset_index()
        tmp.replace(np.inf, 0, inplace=True)
        tmp.reset_index(drop=True, inplace=True)#.set_index('PA')
        tmp.drop(['SampleID', stratumfield, 'domain'], axis=1, inplace=True)
        tmp = tmp.groupby([colorfield]).sum()
        #drop any Utilities that only have zeros
        tmp = tmp.loc[tmp[tmp.columns.difference(['PA'])].sum(axis=1) != 0]        
        tmp = totalcnts.merge(tmp, on=colorfield)
        #drop any reason that only has zeros
        tmp = tmp.loc[:, (tmp != 0).any(axis=0)]
        #tmp.set_index('PA', inplace=True)
        df_chart = tmp.melt(id_vars=[colorfield, 'pop'], var_name=reasonfield, value_name='count')
        # df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1).astype(int)
        df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1)
        #remap utlity names
        df_chart[colorfield] = df_chart[colorfield].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'reasons_'+ field + '-' + '.csv'
            filename = caption + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        # outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
        clusterfield = reasonfield

        spec = vs.vis()
        spec.type = 'bar'
        spec.size = 18
        spec.source = df_chart
        spec.color = colorfield
        # spec.size_src = savfield
        # spec.sizecolor = True
        spec.column_src = clusterfield + ':N'
        spec.name = caption
        spec.path = outputfolder
        spec.facet_labelOrient = 'bottom'
        spec.legend_orient = 'bottom'
        spec.c_height = 400
        
        xaxis = vs.d_axis()
        xaxis.title = ''
        xaxis.source = xfield + ':N'
        # xaxis.resolvescale = 'independent'
        

        yaxis = vs.d_axis()
        yaxis.title = ytitle
        yaxis.source = yfield + ':Q'
        # yaxis.resolvescale = 'independent'
        
        spec.x = xaxis
        spec.y = yaxis

        vs.facet(spec)

def create_ciac2018_reasons_diff_plotly(captions, outputfolder=None, printdata=True):
    """
    Create the reasons for diff visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
        # {'name':'dsum', 'src':'domainpop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']

    # fields = ['EvalBase1kWhReasons', 'EvalBase1ThermReasons', 'EvalBase2kWhReasons', 'EvalBase2ThermReasons']
    #fields = ['EvalBase1kWhReasons']
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
 
    for caption in captions:         
        if 'kwh' in caption.lower():
            stratumfield = 'ss_stratum_kwh'
            # domainstratum = 'stratum_kWh'
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
            frame = 'Frame_Electric'
            if 'First' in caption:
                field = 'EvalBase1kWhReasons'
            else: 
                field = 'EvalBase2kWhReasons'
        else:
            stratumfield = 'ss_stratum_thm'
            # domainstratum = 'stratum_thm'
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'
            frame = 'Frame_Gas'
            if 'First' in caption:
                field = 'EvalBase1ThermReasons'
            else: 
                field = 'EvalBase2ThermReasons'

        colorfield = 'PA'
        yfield = 'pctclm'
        ytitle = 'Percent of Claims'
        xfield = colorfield
        reasonfield = 'reason'
        df_reasons = source[source[field].notnull() & (source[frame]==True)]
        reasons_list = df_reasons[field].unique().tolist()
        reasons_list = [x for x in reasons_list if 'Not ' not in x]
        df_reasons  = df_reasons[df_reasons[field].isin(reasons_list)]
        
        totalcnts = source[source[frame]==True].groupby([colorfield]).size().reset_index()
        totalcnts.rename(columns={0:'pop'}, inplace=True)
        #replace inf?
        # df_reasons.replace(np.inf, 0, inplace=True)
        tmp = df_reasons.groupby([colorfield,'domain','SampleID', stratumfield, field]).pipe(lambda grp: (1 / (grp[dwfield].max() * grp[sswfield].max())) * grp.size()).unstack().reset_index().groupby(['domain', 'PA']).sum().round(0).reset_index()
        tmp.replace(np.inf, 0, inplace=True)
        tmp.reset_index(drop=True, inplace=True)#.set_index('PA')
        tmp.drop(['SampleID', stratumfield, 'domain'], axis=1, inplace=True)
        tmp = tmp.groupby([colorfield]).sum()
        #drop any Utilities that only have zeros
        tmp = tmp.loc[tmp[tmp.columns.difference(['PA'])].sum(axis=1) != 0]        
        tmp = totalcnts.merge(tmp, on=colorfield)
        #drop any reason that only has zeros
        tmp = tmp.loc[:, (tmp != 0).any(axis=0)]
        #tmp.set_index('PA', inplace=True)
        df_chart = tmp.melt(id_vars=[colorfield, 'pop'], var_name=reasonfield, value_name='count')
        # df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1).astype(int)
        df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1)
        #remap utlity names
        df_chart[colorfield] = df_chart[colorfield].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'reasons_'+ field + '-' + '.csv'
            filename = caption + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        grpvar = reasonfield
        varfield = xfield
        valfield = yfield
        textfield = valfield

        reasonlist = df_chart.sort_values(by=valfield,ascending=False)[grpvar].unique()
        cols = 4
        rows = math.ceil(len(reasonlist) / cols)
        if 'electric' in frame.lower():
            yrange = [0,math.ceil(df_chart[valfield].max())+5]
        else:
            yrange = [0,math.ceil(df_chart[valfield].max())+3]

        fig = make_subplots(rows=rows, cols=cols, shared_yaxes=True,
            # specs = [[{}, {}]],
            vertical_spacing=0.08,
        #                     subplot_titles=df_bar_loop['PA'].unique(), #for titles above subplots
                        )
        i=0
        j = 1
        df_bar_loop = df_chart
        for rsn in reasonlist:
            i += 1
            if i > cols:
                i = 1 #reset
                j += 1 #increment
            utillist = sorted(df_chart[varfield].unique().tolist())            
            utilcolors = [utility_colors[x] for x in utillist]
            df_chart = df_bar_loop[df_bar_loop[grpvar]==rsn]
            fig.add_trace(go.Bar(x=df_chart[varfield], y=df_chart[valfield], 
                                text=df_chart[textfield],textposition='outside',
                                textfont=dict(size=g_font_size + legend_size_increase + 1),
        #                          xaxis_tickangle=45,                                
                        marker=dict(color=utilcolors),
                                ),                  
                    row=j, col=i)
            fig.update_xaxes(title_text= f'<b>{rsn}</b>', 
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                row=j, col=i)
            fig.update_yaxes(
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color, 
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,)
            
        width = 1200
        rowheight = width /2 
        ytitle = f'<b>Percent of Claims</b>'
        fig.update_layout(
            yaxis_title= ytitle,            
            plot_bgcolor='white',
            showlegend=False,
            width=width,
            height=rowheight * rows ,# * 1.2,
            font=dict(
                family=fontfamily,
                size=g_font_size,
        #         color="#7f7f7f"
            ),
            margin=dict(
                t=0,
                b=0,
                l=0,
                r=0,
                pad=0
            )
            )

        for row in range(0,j):
            fig['layout']['yaxis' + str(cols * row +1)].update(title=ytitle, range=yrange) #to get the yaxis on the first plot of each subsequent row

        filename = os.path.join(outputfolder, caption + '.svg')
        fig.write_image(filename)

def create_ciac2018_reasons_diff_state(captions, outputfolder=None, printdata=True):
    """
    Create the reasons for diff visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
        # {'name':'dsum', 'src':'domainpop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']


    fields = ['EvalBase1kWhReasons', 'EvalBase1ThermReasons', 'EvalBase2kWhReasons', 'EvalBase2ThermReasons']
    #fields = ['EvalBase1kWhReasons']
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
 
    for caption in captions:         
        if 'kwh' in caption.lower():
            stratumfield = 'ss_stratum_kwh'
            domainstratum = 'stratum_kWh'
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
            frame = 'Frame_Electric'
            fuel = 'kwh'
            if 'First' in caption:
                field = 'EvalBase1kWhReasons'
            else: 
                field = 'EvalBase2kWhReasons'
        elif 'therm' in caption.lower():
            stratumfield = 'ss_stratum_thm'
            domainstratum = 'stratum_thm'
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'
            frame = 'Frame_Gas'
            fuel = 'thm'
            if 'First' in caption:
                field = 'EvalBase1ThermReasons'
            else: 
                field = 'EvalBase2ThermReasons'
        else:
            print(f'uh oh, cannot sort our caption: {caption}')
            continue
        colorfield = 'PA'
        yfield = 'pctclm'
        ytitle = 'Percent of Claims'
        xfield = colorfield
        reasonfield = 'reason'
        df_reasons = source[source[field].notnull() & (source[frame]==True)]
        reasons_list = df_reasons[field].unique().tolist()
        reasons_list = [x for x in reasons_list if 'Not ' not in x]
        df_reasons  = df_reasons[df_reasons[field].isin(reasons_list)]
        
        
        totalcnts = source[source[frame]==True].groupby([colorfield]).size().reset_index()
        # totalcnts = source[source[frame].notnull()].groupby([colorfield]).size().reset_index()
        totalcnts.rename(columns={0:'pop'}, inplace=True)
        #replace inf?
        # df_reasons.replace(np.inf, 0, inplace=True)
        tmp = df_reasons.groupby([colorfield,'domain', domainstratum, 'SampleID', stratumfield, field]).pipe(lambda grp: (1 / (grp[dwfield].max() * grp[sswfield].max())) * grp.size()).unstack().reset_index().groupby(['domain', 'PA']).sum().round(0).reset_index()
        tmp.replace(np.inf, 0, inplace=True)
        tmp.reset_index(drop=True, inplace=True)#.set_index('PA')
        tmp.drop(['SampleID', stratumfield, 'domain'], axis=1, inplace=True)
        tmp = tmp.groupby([colorfield]).sum()
        #drop any Utilities that only have zeros
        # tmp = tmp.loc[tmp[tmp.columns.difference(['PA'])].sum(axis=1) != 0]        
        tmp = totalcnts.merge(tmp, on=colorfield)
        #drop any reason that only has zeros
        tmp = tmp.loc[:, (tmp != 0).any(axis=0)]
        #tmp.set_index('PA', inplace=True)
        # tmp = tmp.groupby([reasonfield]).sum()
        tmp.drop(columns='PA', inplace=True)
        df_chart = tmp.melt(id_vars=['pop'], var_name=reasonfield, value_name='count')

        df_chart = df_chart.groupby(reasonfield).sum()
        # df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1).astype(int)
        df_chart[yfield]= ((df_chart['count'] / df_chart['pop']) * 100).round(1)
        #remap utlity names
        # df_chart[colorfield] = df_chart[colorfield].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = 'reasons_'+ field + '-' + '.csv'
            filename = caption + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        # continue
        # outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
        clusterfield = reasonfield

        spec = vs.vis()
        spec.type = 'bar'
        spec.size = 18
        spec.source = df_chart
        spec.color = colorfield
        # spec.size_src = savfield
        # spec.sizecolor = True
        spec.column_src = clusterfield + ':N'
        spec.name = caption
        spec.path = outputfolder
        spec.facet_labelOrient = 'bottom'
        spec.legend_orient = 'bottom'
        spec.c_height = 400
        
        xaxis = vs.d_axis()
        xaxis.title = ''
        xaxis.source = xfield + ':N'
        # xaxis.resolvescale = 'independent'
        

        yaxis = vs.d_axis()
        yaxis.title = ytitle
        yaxis.source = yfield + ':Q'
        # yaxis.resolvescale = 'independent'
        
        spec.x = xaxis
        spec.y = yaxis

        vs.facet(spec)

def mkplot_ciac2018_ExSum_grrntgr_bar(captions, outputfolder=None, printdata=True):
    '''SM: Print bar chart of gross and net savings. Replaces first half (the data processing part) of create_ciac2018_ExSum_grrntgr_bar written by GH.
        captions = captions requested by engineer
        outputfolder = folder in which plot is saved
        printdata = When True, publishes a a csv file of the final processed dataframe used for the plot
        '''
       
    #set default output folder if not provided
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    
    srclist = [{'name':'state', 'src':'state_summary', 'return':'df'},             
            {'name':'pa', 'src':'papop', 'return':'df'}]
    
    #prepare data
    try:
        results = get_datadef_source_info(srclist)
        df_sw = results['state'] #TODO: make generic
        df_pa = results['pa'] #TODO: make generic
        df_sw.columns = df_sw.columns.str.replace("SW", "PA")
        df_sw['PA'] = 'Statewide'
        #merge them
        dsrc = pd.concat([df_pa, df_sw], sort=True)
    except Exception as e:
        print(f'FAIL: Print of gross and net savings using plotly - missing sclist {str(datetime.now())}: {e}')
        return False
    
    #TODO: need to put the fields below in datadefs
    rrfields = ['PA','PA_RR_kWh_LG','PA_NTGR_kWh_LC', 'PA_RR_kW_LG', 'PA_NTGR_kW_LC', 'PA_RR_thm_LG', 'PA_NTGR_thm_LC']
    fields_dsum = ['PA', 'PA_exante_svgs_kWh_LG', 'PA_exante_svgs_kW_LG', 'PA_exante_svgs_thm_LG', 'PA_eval_svgs_kWh_LG', 'PA_eval_svgs_kW_LG', 'PA_eval_svgs_thm_LG', 'PA_eval_svgs_kWh_LN', 'PA_eval_svgs_kW_LN', 'PA_eval_svgs_thm_LN']
    
    #set field names
    fields = set(fields_dsum + rrfields)
    claimrrfield = 'ClaimRR'
    claimfield = 'Claim'
    fuelfield = 'Fuel'
    labelfield = 'text'
    valfield = 'value'
    varfield = 'variable'
    xfield = 'PA'
    
    #set standard text by which to call out fuels
    thermfuel = 'therms'
    kwhfuel = 'kWh'
    # kwfuel = 'kW'
     
    df = dsrc[fields].copy()
    rrfield = 'grr_effect'
    ntgfield = 'ntgr_effect'
    fuels = ['kW', 'kWh', 'thm']
    post_root = 'PA_eval_svgs_'           
    for fuel in fuels:
        ante = 'PA_exante_svgs_' + fuel + '_LG'
        grr = post_root + fuel +'_LG'
        ntgr = post_root + fuel +'_LN'
        df[rrfield + '_' + fuel] =  (df[grr] - df[ante])
        df[ntgfield + '_' + fuel] = df[ntgr] - df[ante] - df[rrfield + '_' + fuel]
    
    #start manipulating the data
    df_text = df[rrfields].groupby(xfield).max().reset_index()
    df_text = df_text.melt(xfield)
    df_text[fuelfield] = 'kW'
    df_text[fuelfield] = df_text[fuelfield].where(~df_text[varfield].str.contains('kWh_'), kwhfuel)
    df_text[fuelfield] = df_text[fuelfield].where(~df_text[varfield].str.contains('thm_'), thermfuel)
    df_text[varfield] = df_text[varfield].where(~df_text[varfield].str.contains('_RR_'), 'RR')
    df_text[varfield] = df_text[varfield].where(~df_text[varfield].str.contains('_NTGR_'), 'NTGR')
    df_text.replace(np.inf, 0, inplace=True)
    df_text.fillna(0, inplace=True)
    df_text[valfield] = (df_text[valfield] * 100).round(0).astype(int)
    df_text = df_text.pivot_table(index=[xfield, fuelfield], columns=varfield,
                        values=valfield, aggfunc='first').reset_index()
    
    #drop utilities with only zeros
    df_text = df_text.loc[df_text[df_text.columns.difference([xfield, fuelfield])].sum(axis=1) != 0]
    df_text['gntgr'] = ((df_text['NTGR'] * df_text['RR'])/100).round(0).astype(int)#.astype(str) 
    df_text[claimrrfield] = 100
    
    df_bar = dsrc[fields_dsum]
    df_bar = df_bar.groupby(xfield).max().reset_index()
    df_bar = df_bar.melt(id_vars=[xfield])
       
    df_bar[fuelfield] = 'kW'
    df_bar[fuelfield] = df_bar[fuelfield].where(~df_bar[varfield].str.contains('kWh_'), kwhfuel)
    df_bar[fuelfield] = df_bar[fuelfield].where(~df_bar[varfield].str.contains('thm_'), thermfuel)
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('exante'), claimfield)
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('_LG'), 'Gross')
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('_LN'), 'Net')
    
    df_bar = df_bar.merge(df_text, on=[xfield, fuelfield])
    df_bar[labelfield] = df_bar[claimrrfield].astype(str) + '%'
    df_bar[labelfield] = df_bar[labelfield].where(df_bar[varfield] != 'Net', df_bar['gntgr'].astype(str) + '%')
    df_bar[labelfield] = df_bar[labelfield].where(df_bar[varfield] != 'Gross', df_bar['RR'].astype(str) + '%')
    
    valkwhfield = valfield + kwhfuel
    valthmfield = valfield + thermfuel
    # valkwfield = valfield + kwfuel
    billion = 1000000000
    million = 1000000
    # thousand = 1000
    
    df_bar[valkwhfield] = df_bar[valfield]/billion
    df_bar[valthmfield] = df_bar[valfield]/million    
    df_bar[xfield] = df_bar[xfield].map(utility_remap)
    
    if printdata:
        pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
        filename = 'exSumBarData.csv'
        tmppath = os.path.join(pathroot, filename)
        df_to_csv_sharefile(df_bar,tmppath)
    
    #create plot specification object    
    spec = vs.pvis()
    spec.annotation['text'] = f"Percentages (%) are compared to {claimfield}"
    spec.captions = captions
    spec.colors = [params.MAIN_PALETTE[2], params.MAIN_PALETTE[0], params.MAIN_PALETTE[4]]
    spec.colorsrc = varfield 
    spec.datasrc = valfield
    spec.datasrckwh = valkwhfield
    spec.datasrcthm = valthmfield
    # spec.datasrckw = valkwfield
    spec.fuelsrc = fuelfield
    spec.labelsrc = labelfield
    spec.type = 'bar'
    spec.x = vs.axis()
    spec.xaxissrc = xfield
    # spec.y = vs.axis()
    # spec.y = vs.axis(tickformat = '.1f') #can't set here because captions are being passed
    mkplot1(df_bar, spec, outputfolder)

def create_ciac2018_ExSumm_savings_scatter_combined(caption, outputfolder=None, printdata=True):
    """
    Create a 2x2 matrix of using the caption as the filename
    """
    
    filtercaptions = ['kwh gross', 'kwh net', 'thm gross', 'thm net'] #controls order of figures
    if isinstance(caption, list):
        caption = caption[0]
    create_ciac2018_ExSumm_savings_scatter_plotly (caption, filtercaptions, outputfolder, printdata)


def create_ciac2018_ExSumm_savings_scatter(captions,outputfolder=None, printdata=True):
    """
    Creates individual plots for each captions
    """

    create_ciac2018_ExSumm_savings_scatter_plotly (None, captions, outputfolder, printdata)


def create_ciac2018_ExSumm_savings_scatter_plotly(fileroot, captions, outputfolder=None, printdata=True):
    """
    Create the savings scatter for ciac2018
    For a combined figure pass in the filename and a list of the caption filters
    For individual figures, fileroot should be None and the captions will serve as both filters and filenames
    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']

    spec = vs.pvis() #TODO change to mvis    
    spec.type = 'scatter'
    spec.plotfiletype = '.svg'
    scale = {'one': [1, ''],
        'thousand': [1000, 'thousand'], 
        'million': [1000000, 'million'], 
        'tenmillion': [10000000, 'Ten-Million'], 
        'billion': [1000000000, 'Billion']}
    
    spec.scalekwh = scale['million']
    spec.scalethm = scale['million']

    kwh = 'kWh'
    thm = 'therms'
    kw = 'kW'

    if fileroot:
        totalsubplots = len(captions)
    else:
        totalsubplots = 1

    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    
    if fileroot:
        rows = 2
        cols = 2
    else:
        rows = 1
        cols = 1

    fig = make_subplots(rows=rows, cols=cols, shared_yaxes=False,
            # specs = [[{}, {}]], vertical_spacing=0.05,
            # row_heights=None,
            # subplot_titles=df_bar_loop['PA'].unique(), #for titles above subplots
            )
    i=0
    j = 1
    legendlist = []

    for caption in captions:
        #control subplots
        if not fileroot: #reset position counters and figure
            i=0
            j = 1
            legendlist = []
            fig = make_subplots(rows=rows, cols=cols)

        i += 1
        if i > cols:
            i = 1
            j = 2

        position = (j-1) * cols + i
        if 'electric' in caption.lower() or 'kwh' in caption.lower():           
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
            spec.fuel = kwh
            
            if 'gross' in caption.lower():
                fields = ['EvalExPostLifeCycleGrosskWh', 'ExAnte_LifeCycleGross_NoRR_kWh']
                frame = 'GrossDisposition'
                study = 'Gross'
                df = source[(source[frame]=='Completed') & (source['sampled_kWh']=='Y')]
            else:
                frame = 'NetDisposition'
                study = 'Net'
                df = source[(source[frame]=='COMPLETE') & (source['sampled_kWh']=='Y')]
                fields = ['EvalExPostLifeCycleNetkWh', 'ExAnte_LifeCycleNet_NoRR_kWh']
        else:
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'
            spec.fuel = thm
            if 'gross' in caption.lower():
                frame = 'GrossDisposition'
                study = 'Gross'
                fields = ['EvalExPostLifeCycleGrossTherm', 'ExAnte_LifeCycleGross_NoRR_thm']
                df = source[(source[frame]=='Completed') & (source['sampled_thm']=='Y')]
            else: 
                fields = ['EvalExPostLifeCycleNetTherm', 'ExAnte_LifeCycleNet_NoRR_thm']
                frame = 'NetDisposition'
                study = 'Net'
                df = source[(source[frame]=='COMPLETE') & (source['sampled_thm']=='Y')]

        spec.colorsrc = 'PA'
        spec.yaxissrc = fields[0]
        spec.xaxissrc = fields[1]

        if spec.fuel == kwh:
            tickformatstring = '.0f'
        elif spec.fuel == thm:
            tickformatstring = '.1f'

        weighted = False
        if weighted:
            for idx in range(0,len(fields)):
                #weight the savings
                # df[fields[i] + '_extrap'] = (1/(df[dwfield] * df[sswfield])) * df[fields[i]] #only needed if we want to have both original and extatpolated returned
                df[fields[idx]] = (1/(df[dwfield] * df[sswfield])) * df[fields[idx]]
                df.replace(np.inf, 0, inplace=True)        
                df.replace(-np.inf, 0, inplace=True)        
            
        tmp = df.groupby([spec.colorsrc,'domain', 'SampleID']).sum().round(0).reset_index()

        #drop any Utilities that only have zeros
        tmp = tmp.loc[tmp[tmp.columns.difference([spec.colorsrc])].sum(axis=1) != 0]                

        keepfields = [spec.colorsrc, 'SampleID', spec.xaxissrc, spec.yaxissrc]
        tmp = tmp[keepfields]
        df_chart = tmp

        #remap utlity names
        df_chart[spec.colorsrc] = df_chart[spec.colorsrc].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = caption + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)

        if spec.fuel == kwh:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalekwh[0])
            labelscale = spec.scalekwh[1]
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalekwh[0])
        elif spec.fuel == thm:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalethm[0])
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalethm[0])
            labelscale = spec.scalethm[1]
        elif spec.fuel == kw:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalekw[0])
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalekw[0])
            labelscale = spec.scalekw[1]
        else:
            msg =f'cannot match caption for {caption}'
            logging.warning(msg)
            print(msg)

        spec.x = vs.axis(text = (f'Claimed Life-Cycle {study} Savings ({labelscale} {spec.fuel})'))
        spec.y = vs.axis(text = (f'Evaluated Life-Cycle {study} Savings ({labelscale} {spec.fuel})'))
        spec.rmax = min(df_chart[spec.xaxissrc].max(), df_chart[spec.yaxissrc].max())

        print(f'caption: {caption}, {study}, {frame}, {spec.fuel}, i is {i}, j is {j}, position is {position}')

        plotdata = []
        pas = df_chart[spec.colorsrc].unique()

        for pa in pas:
            df_pa = df_chart[df_chart[spec.colorsrc]==pa]
            plotdata.append(
                go.Scatter(
                    x=df_pa[spec.xaxissrc], 
                    y=df_pa[spec.yaxissrc],
                    mode='markers',
                    name= pa,
                    marker=dict(
                        color=utility_colors[pa],
                        opacity=0.75,
                        size=16,
                        ),
                    # legendgroup='pa',
                    showlegend= pa not in legendlist and fileroot == None, #(position % 2 ) == 1,   #odd places
                )
            )            
            legendlist.append(pa)

        # fig = go.Figure(plotdata)
        # Add traces
        fig.add_traces(plotdata,  rows=[j] * len(plotdata), cols=[i] * len(plotdata))
        # fig.append_trace(go.Scatter(x=[0,spec.rmax], y=[0, spec.rmax],
        linelegend = 'RR = 1'
        fig.add_trace(go.Scatter(x=[0,spec.rmax], y=[0, spec.rmax],
                            mode='lines',
                            name=linelegend,
                            marker=dict(color='grey'),
                            # legendgroup='line',
                            showlegend= position==totalsubplots and fileroot == None,
                        ) 
                , row=j, col=i
                )
        legendlist.append(linelegend)

        fig.update_xaxes(zeroline=True, zerolinewidth=grid_line_width, zerolinecolor=grid_color, 
            title_font=dict(size=g_font_size + legend_size_increase, family=fontfamily, color=axis_color),
            tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
            showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
            tickformat= tickformatstring,
            row=j, col=i
            )
        fig.update_yaxes(zeroline=True, zerolinewidth=grid_line_width, zerolinecolor=grid_color,
            title_font=dict(size=g_font_size + legend_size_increase , family=fontfamily, color=axis_color),
            tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
            showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color,
            showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
            tickformat= tickformatstring,
            row=j, col=i
            )

        fig.update_xaxes(title_text=f'<b>{spec.x.titletext}</b>', rangemode="tozero", row=j, col=i) #tick0= rangemode="tozero", range = [1,5]
        fig.update_yaxes(title_text=f'<b>{spec.y.titletext}</b>', row=j, col=i)
        # fig['layout']['yaxis' + str(position)].update(title=spec.y.titletext)
        # fig['layout']['xaxis' + str(position)].update(title=spec.x.titletext)

        #leaving in captions loop incase they are printing individually
        width = 1000
        rowheight = width / rows 
        fig.update_layout(
            plot_bgcolor='white',
            legend=dict(
                xanchor='left', yanchor='top', orientation="v",
                font=dict(
                    family=fontfamily,
                    size=g_font_size + 2,
                    ),
                ),
            # legend=dict(x=0, y=1, xanchor='left', yanchor='bottom', orientation="h"),
            width=width,
            height=rowheight * rows ,# * 1.2,
            font=dict(
                family=fontfamily,                
                size=g_font_size,
        #         color="#7f7f7f"
            ),
            margin=dict(
                t=0,
                b=0,
                l=0,
                r=0,
                pad=0
            )
    
        )
            
        #saving plot as image to output folder for indivudual plots
        if not fileroot:
            filename = os.path.join(outputfolder, caption + spec.plotfiletype)
            fig.write_image(filename)  # save the figure to file

    #for multiplot write    
    if fileroot:
        #arrange legend
        palist = [x for x in set(legendlist) if x in utility_colors]
        extras = [x for x in set(legendlist) if x not in utility_colors]
        palist.sort()
        extras.sort()
        legendlist = palist + extras
        dummydata = []

        for item in palist:
            dummydata.append(go.Scatter(
                x=[0],
                y=[0],
                name=item,
                mode='markers', 
                marker=dict(
                        color=utility_colors[item],
                        opacity = 1,
                        size=16,
                        ),
                showlegend=True,
                # visible="legendonly"
            ))
        for item in extras:
            dummydata.append(go.Scatter(
                x=[0],
                y=[0],
                name=item,
                mode='lines',                            
                marker=dict(color='grey'),
                showlegend=True,
                # visible="legendonly"
            ))

        fig.add_traces(dummydata)
        fig.update_layout(
            legend=dict(
                x=.5, xanchor='center', yanchor='top', orientation="h"),
                font=dict(
                    family=fontfamily,
                    size=g_font_size + 2,
                    ),
                )
        filename = os.path.join(outputfolder, fileroot + spec.plotfiletype)
        fig.write_image(filename)  # save the figure to file
        

def create_ciac2018_ExSumm_savings_scatter_matplot(captions, outputfolder=None, printdata=True):
    """
    Create the reasons for diff visualization for ciac2018
    Pass in the list of captions for the output files

    """

    srclist = [
        {'name':'claimpop', 'src':'ClaimPop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    source = results['claimpop']

    spec = vs.pvis() #TODO change to mvis
    sns.set(font=fontfamily)
                # size=g_font_size,
    spec.type = 'scatter'
    scale = {'one': [1, ''],
        'thousand': [1000, ' Thousand '], 
        'million': [1000000, ' Million '], 
        'tenmillion': [10000000, ' Ten-Million '], 
        'billion': [1000000000, ' Billion ']}
    spec.scalekwh = scale['million']
    spec.scalethm = scale['one']

    kwh = 'kWh'
    thm = 'Therm'
    kw = 'kW'

    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
    
    for caption in captions:
        if 'electric' in caption.lower() or 'kwh' in caption.lower():
            # stratumfield = 'ss_stratum_kwh'
            dwfield = 'domain_prob_sel_kwh'
            sswfield = 'ss_prob_sel_kwh'
            spec.fuel = kwh
            
            if 'gross' in caption.lower():
                fields = ['EvalExPostLifeCycleGrosskWh', 'ExAnte_LifeCycleGross_NoRR_kWh']
                frame = 'GrossDisposition'
                study = 'Gross'
                df = source[(source[frame]=='Completed') & (source['Frame_Electric']==True)]
                # spec.x = vs.axis(spec, text = (f'Claimed Life-Cycle Gross Savings (spec.fuel)'))
                # spec.y = vs.axis(spec, text = (f'Evaluated Life-Cycle Gross Savings (spec.fuel)'))
            else:
                frame = 'NetDisposition'
                study = 'Net'
                df = source[(source[frame]=='COMPLETE') & (source['Frame_Electric']==True)]
                fields = ['EvalExPostLifeCycleNetkWh', 'ExAnte_LifeCycleNet_NoRR_kWh']
                # spec.x = vs.axis(spec, text = ('Claimed Life-Cycle Net Savings (kWh)'))
                # spec.y = vs.axis(spec, text = ('Evaluated Life-Cycle Net Savings (kWh)'))
        else:
            dwfield = 'domain_prob_sel_thm'
            sswfield = 'ss_prob_sel_thm'
            spec.fuel = thm
            if 'gross' in caption.lower():
                study = 'Gross'
                fields = ['EvalExPostLifeCycleGrossTherm', 'ExAnte_LifeCycleGross_NoRR_thm']
                frame = 'GrossDisposition'
                df = source[(source[frame]=='Completed') & (source['Frame_Gas']==True)]
                # spec.x = vs.axis(spec, text = ('Claimed Life-Cycle Gross Savings (therms)'))
                # spec.y = vs.axis(spec, text = ('Evaluated Life-Cycle Gross Savings (therms)'))
            else: 
                fields = ['EvalExPostLifeCycleNetTherm', 'ExAnte_LifeCycleNet_NoRR_thm']
                frame = 'NetDisposition'
                study = 'Net'
                df = source[(source[frame]=='COMPLETE') & (source['Frame_Gas']==True)]
                # spec.x = vs.axis(spec, text = ('Claimed Life-Cycle Net Savings (therms)'))
                # spec.y = vs.axis(spec, text = ('Evaluated Life-Cycle Net Savings (therms)'))

       
        spec.x = vs.axis(text = (f'Claimed Life-Cycle {study} Savings {spec.fuel}'))
        spec.y = vs.axis(text = (f'Evaluated Life-Cycle {study} Savings {spec.fuel}'))
        spec.colorsrc = 'PA'
        spec.yaxissrc = fields[0]
        spec.xaxissrc = fields[1]
        
        for i in range(0,len(fields)):
            print(f'i is {i} and field is {fields[i]}')
            #weight the savings
            # df[fields[i] + '_extrap'] = (1/(df[dwfield] * df[sswfield])) * df[fields[i]] #only needed if we want to have both original and extatpolated returned
            df[fields[i]] = (1/(df[dwfield] * df[sswfield])) * df[fields[i]]
            df.replace(np.inf, 0, inplace=True)        
            
        tmp = df.groupby([spec.colorsrc,'domain', 'SampleID']).sum().round(0).reset_index()

        #drop any Utilities that only have zeros
        tmp = tmp.loc[tmp[tmp.columns.difference([spec.colorsrc])].sum(axis=1) != 0]                

        keepfields = [spec.colorsrc, 'SampleID', spec.xaxissrc, spec.yaxissrc]
        tmp = tmp[keepfields]
        #if you need the menlted version
        # df_chart = tmp.melt(id_vars=[colorfield, 'SampleID'], var_name=reasonfield, value_name='sum')
        df_chart = tmp

        #remap utlity names
        df_chart[spec.colorsrc] = df_chart[spec.colorsrc].map(utility_remap)

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename = caption + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)

        if spec.fuel == kwh:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalekwh[0])
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalekwh[0])
        elif spec.fuel == thm:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalethm[0])
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalethm[0])
        elif spec.fuel == kw:
            df_chart[spec.xaxissrc] = df_chart[spec.xaxissrc].div(spec.scalekw[0])
            df_chart[spec.yaxissrc] = df_chart[spec.yaxissrc].div(spec.scalekw[0])
        else:
            msg =f'cannot match caption for {caption}'
            logging.warning(msg)
            print(msg)

        spec.rmax = min(df_chart[spec.xaxissrc].max(), df_chart[spec.yaxissrc].max())
        line = 0.5*np.linspace(0, spec.rmax, 100)
        x_line = np.linspace(0, spec.rmax, 100)
        sns.axes_style()
        sns.set_style("darkgrid", {"axes.facecolor": "1", 'axes.edgecolor': '.9','figure.facecolor': 'white', 'grid.color': '.8', 
                                'xtick.color': '0','ytick.color': '0'})

        fig, ax = plt.subplots(figsize=(10,6))
        #You pass the wanted axis to the ax argument
        # sns.scatterplot(x = spec.xaxissrc, y = spec.yaxissrc, hue = spec.colorsrc, data = df_chart, markers = markers, ax = ax)
        sns.scatterplot(x = spec.xaxissrc, y = spec.yaxissrc, hue = spec.colorsrc, data = df_chart, ax = ax) #, label='medium')
        ax.set(xlabel = spec.x.titletext,
            ylabel = spec.y.titletext)
        ax.legend(loc='lower center', bbox_to_anchor=(.5, -.3), ncol=5, columnspacing = 0.3, borderpad = 0, edgecolor = 'white')
        ax.xaxis.grid(False)
        ax.plot(line, x_line, zorder=-1)

        #saving plot as image to output folder
        filename = os.path.join(outputfolder, caption + spec.plotfiletype)
        fig.savefig(filename)   # save the figure to file
        # plt.close(fig) 

def create_ExSumGRRNTGR(captions, outputfolder=None, printdata=True):
    """
    Create the charts for ExSumGRRNTGR
    """
    
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
 
    srclist = [
        {'name':'state', 'src':'state_summary', 'return':'df'},             
        {'name':'pa', 'src':'papop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    df_sw = results['state']
    df_pa = results['pa']

    df_sw.columns = df_sw.columns.str.replace("SW", "PA")

    df_sw['PA'] = 'Statewide'
    #merge them
    df = pd.concat([df_pa, df_sw], sort=True)
    fields = ['PA','PA_RR_kWh_LG','PA_NTGR_kWh_LC', 'PA_RR_kW_LG', 'PA_NTGR_kW_LC', 'PA_RR_thm_LG', 'PA_NTGR_thm_LC']
    df = df[fields]
    df_chart_all = df.melt('PA')
    #not there are only 3 fields PA, variable, value
    varfield = 'variable'
    valfield = 'value'
    clusterfield = 'PA'

    for caption in captions:        
        if 'kwh' in caption.lower():
            fuel = 'kWh_'           
        elif 'therm' in caption.lower():
            fuel = 'thm_'
        else:
            msg =f'cannot match caption foe {caption}'
            logging.warning(msg)
            print(msg)
            continue
        df_chart = df_chart_all
        #filter by fuel
        df_chart = df_chart[df_chart[varfield].str.contains(fuel)]
        #Replace variable values with frienldy ones
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('_RR_'), 'GRR')
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('_NTGR_'), 'NTGR')

        #remap utlity names
        df_chart[clusterfield] = df_chart[clusterfield].map(utility_remap)
        
        #round value field
        df_chart[valfield] = df_chart[valfield].round(2)

        colorfield = varfield
        yfield = valfield
        ytitle = ' '
        xfield = colorfield
        

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename =  caption + '-' + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        spec = vs.vis()
        spec.type = 'bar'
        spec.size = 18
        spec.source = df_chart
        spec.color = colorfield
        # spec.size_src = savfield
        # spec.sizecolor = True
        spec.column_src = clusterfield + ':N'
        spec.name = caption
        spec.path = outputfolder
        spec.facet_labelOrient = 'bottom'
        spec.legend_orient = 'bottom'
        spec.c_height = 400
        spec.c_width = 100 
        
        xaxis = vs.d_axis()
        xaxis.title = ''
        xaxis.source = xfield + ':N'
        # xaxis.resolvescale = 'independent'
        

        yaxis = vs.d_axis()
        yaxis.title = ytitle
        yaxis.source = yfield + ':Q'
        # yaxis.resolvescale = 'independent'
        
        spec.x = xaxis
        spec.y = yaxis

        vs.facet(spec)

def create_ciac2018_ExSum_grrntgr_bar(captions,  outputfolder=None, printdata=True):
    """
    Print bar chart of gross and net savings
    """
    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"
 
    srclist = [
        {'name':'state', 'src':'state_summary', 'return':'df'},             
        {'name':'pa', 'src':'papop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    df_sw = results['state']
    df_pa = results['pa']

    df_sw.columns = df_sw.columns.str.replace("SW", "PA")

    df_sw['PA'] = 'Statewide'
    #merge them
    dsrc = pd.concat([df_pa, df_sw], sort=True)

    # fields_claim = ['PA','ExAnte_LifeCycleGross_NoRR_kW', 'ExAnte_LifeCycleGross_NoRR_kWh', 'ExAnte_LifeCycleGross_NoRR_thm', 'EvalExPostLifeCycleNetkW', 'EvalExPostLifeCycleNetkWh', 'EvalExPostLifeCycleNetTherm', 'EvalExPostLifeCycleGrosskW', 'EvalExPostLifeCycleGrosskWh', 'EvalExPostLifeCycleGrossTherm']
    rrfields = ['PA','PA_RR_kWh_LG','PA_NTGR_kWh_LC', 'PA_RR_kW_LG', 'PA_NTGR_kW_LC', 'PA_RR_thm_LG', 'PA_NTGR_thm_LC']
    fields_dsum = ['PA', 'PA_exante_svgs_kWh_LG', 'PA_exante_svgs_kW_LG', 'PA_exante_svgs_thm_LG', 'PA_eval_svgs_kWh_LG', 'PA_eval_svgs_kW_LG', 'PA_eval_svgs_thm_LG', 'PA_eval_svgs_kWh_LN', 'PA_eval_svgs_kW_LN', 'PA_eval_svgs_thm_LN']
    fields = set(fields_dsum + rrfields)
    varfield = 'variable'
    valfield = 'value'
    fuelfield = 'Fuel'
    claimrrfield = 'ClaimRR'
    claimfield = 'Claim'
    thermfuel = 'therms'
    kwhfuel = 'kWh'
    # df = source[source.copy()
    # df = 
    df = dsrc[fields].copy()
    rrfield = 'grr_effect'
    ntgfield = 'ntgr_effect'
    fuels = ['kW', 'kWh', 'thm']
    fuels_ante = ['kW', 'kWh', 'thm']
    fuels_post = ['kW', 'kWh', 'Therm']
    post_root = 'PA_eval_svgs_'
   
    # for i in range(0,3):
    for fuel in fuels:
        ante = 'PA_exante_svgs_' + fuel + '_LG'
        grr = post_root + fuel +'_LG'
        ntgr = post_root + fuel +'_LN'
        df[rrfield + '_' + fuel] =  (df[grr] - df[ante])
        df[ntgfield + '_' + fuel] = df[ntgr] - df[ante] - df[rrfield + '_' + fuel]

    #start manipulating the data
    df_text = df[rrfields].groupby('PA').max().reset_index()
    df_text = df_text.melt('PA')
    df_text[fuelfield] = 'kW'
    df_text[fuelfield] = df_text[fuelfield].where(~df_text[varfield].str.contains('kWh_'), kwhfuel)
    df_text[fuelfield] = df_text[fuelfield].where(~df_text[varfield].str.contains('thm_'), thermfuel)
    df_text[varfield] = df_text[varfield].where(~df_text[varfield].str.contains('_RR_'), 'RR')
    df_text[varfield] = df_text[varfield].where(~df_text[varfield].str.contains('_NTGR_'), 'NTGR')
    df_text.replace(np.inf, 0, inplace=True)
    df_text.fillna(0, inplace=True)
    df_text[valfield] = (df_text[valfield] * 100).round(0).astype(int)
    df_text = df_text.pivot_table(index=['PA', fuelfield], columns=varfield,
                        values=valfield, aggfunc='first').reset_index()
    #drop useless varfield - Code below didn't work
    # df_text.reset_index(drop=True)
    # df_text.drop([varfield], inplace=True, axis=1)

    #drop utilities with only zeros
    df_text = df_text.loc[df_text[df_text.columns.difference(['PA', fuelfield])].sum(axis=1) != 0]
    df_text['gntgr'] = ((df_text['NTGR'] * df_text['RR'])/100).round(0).astype(int)#.astype(str) 
    df_text[claimrrfield] = 100

    df_bar = dsrc[fields_dsum]
    df_bar = df_bar.groupby('PA').max().reset_index()
    df_bar = df_bar.melt(id_vars=['PA'])
    varfield = 'variable'
    valfield = 'value'
    fuelfield = 'Fuel'
    colorfield = 'Color'

    df_bar[fuelfield] = 'kW'
    df_bar[fuelfield] = df_bar[fuelfield].where(~df_bar[varfield].str.contains('kWh_'), kwhfuel)
    df_bar[fuelfield] = df_bar[fuelfield].where(~df_bar[varfield].str.contains('thm_'), thermfuel)
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('exante'), claimfield)
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('_LG'), 'Gross')
    df_bar[varfield] = df_bar[varfield].where(~df_bar[varfield].str.contains('_LN'), 'Net')
    df_bar[colorfield] = 'Eval'
    df_bar[colorfield] = df_bar[colorfield].where(~df_bar[varfield].str.contains(claimfield), claimfield)

    df_bar = df_bar.merge(df_text, on=['PA', fuelfield])
    txt = 'text'
    df_bar[txt] = df_bar[claimrrfield].astype(str) + '%'
    df_bar[txt] = df_bar[txt].where(df_bar[varfield] != 'Net', df_bar['gntgr'].astype(str) + '%')
    df_bar[txt] = df_bar[txt].where(df_bar[varfield] != 'Gross', df_bar['RR'].astype(str) + '%')

    # df_bar.columns
    df_bar[valfield + kwhfuel] = df_bar[valfield]/1000000000
    df_bar[valfield + thermfuel] = df_bar[valfield]/1000000

    df_bar['PA'] = df_bar['PA'].map(utility_remap)

    if printdata:
        pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
        filename = 'exSumBarData.csv'
        tmppath = os.path.join(pathroot, filename)
        df_to_csv_sharefile(df_bar,tmppath)


    #This is an alternative subplot version where each trace is added separately to a single plot
    #I suppose it might not need to use the subplot at all, but it is
    #Final version for now.
    #just uncomment the therm fuel to generate the therm version
    txt = 'text'
    fuel = kwhfuel
    fuel = thermfuel #toggle this line to change fuels
    fuels = [kwhfuel, thermfuel]
    elements = 5
    colorslist = [
        ['blue'] * elements,
        ['lightgreen'] * elements,
        ['green'] * elements,
    ]

    for caption in captions:
        if 'kwh' in caption.lower():
            fuel = kwhfuel
            yaxistitle = 'Billions of ' + fuel + '/year'
            yheight = 2.7
        elif 'therm' in caption.lower():
            fuel = thermfuel
            yaxistitle = 'Millions of ' + fuel + '/year'
            yheight = 70
        else:
            msg =f'cannot match caption for {caption}'
            logging.warning(msg)
            print(msg)
            continue
        i=0
        df_bar_loop = df_bar[df_bar[fuelfield]==fuel].copy()
        # df_bar_loop['PA']=df_bar_loop['PA'].map(utility_remap) #done above

        traces = []
        for valtype in df_bar_loop[varfield].unique():
            i += 1    
            df_chart = df_bar_loop[df_bar_loop[varfield]==valtype]
            trace = go.Bar(x=df_chart['PA'], y=df_chart[valfield + fuel], 
                    text=df_chart[txt],textposition='outside',
                    marker=dict(color=colorslist[i-1]),
                    name=valtype,
                        )
            traces.append(trace)

        fig = go.Figure()
        fig = make_subplots(rows=1, cols=1, shared_xaxes=True)
        for trace in traces:
            fig.append_trace(trace, 1,1)

        width = 1000
        fig.update_layout(
            plot_bgcolor='white',
            width=width,
            height=.6*width,
            font=dict(
            family=fontfamily,
            size=g_font_size,
            ),
            margin=dict(
                t=0,
                b=0,
                l=0,
                r=0,
                pad=0
            )
        )

        fig.update_yaxes(title_text= yaxistitle, row=1, col=1)
        fig.update_layout(
            legend=dict(
                x=0,y=1,
                font=dict(
                    family=fontfamily,
                    size=g_font_size + 2,
                    ),
            ),
            annotations=[
                dict(
                    x=1,
                    y=yheight,
                    showarrow=False,
                    text=f" Percentages (%) are compared to {claimfield} ",
        #             bgcolor="LightSteelBlue",
                    bordercolor="Black",
                    borderwidth=1
                )],
            margin=dict(
                t=0,
                b=0,
                l=0,
                r=0,
                pad=0
            )
    
        )

        #both of these crash with error psutil.NoSuchProcess no process found with pid xxx
        #check of status (pio.orca.status) shows that the server is running and the PID is correct
        # filename = os.path.join(outputfolder, caption + '.png')
        # fig.write_image(filename)
        filename = os.path.join(outputfolder, caption + '.svg')
        fig.write_image(filename)
        # img_bytes = fig.to_image(format="png")
        # sfsession.upload_file(params.LOG_PATH_ID, 'plotlyimagetest.png', img_bytes)

        #these files must be opened in a browser and saved to a picture format, but at least it's something :(
        # filename = os.path.join(outputfolder, caption + '.html')
        # fig.write_html(filename, include_plotlyjs='cdn') #Change to True to have files that can work offline

def create_ExSumAR(captions, outputfolder=None, printdata=True):
    """
    Create the charts for ExSum AR
    """

    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"

    srclist = [
        {'name':'state', 'src':'state_summary', 'return':'df'},             
        {'name':'pa', 'src':'papop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    df_sw = results['state']
    df_pa = results['pa']

    df_sw.columns = df_sw.columns.str.replace("SW", "PA")

    df_sw['PA'] = 'Statewide'
    #merge them
    df = pd.concat([df_pa, df_sw], sort=True)
    fields = ['PA','PA_exante_pct_AR_kWh', 'PA_exante_pct_AR_kW', 'PA_exante_pct_AR_thm', 'PA_expost_pct_AR_kWh', 'PA_expost_pct_AR_kW', 'PA_expost_pct_AR_thm']
    df = df[fields]
    df_chart_all = df.melt('PA')
    df_chart_all['value'] = df_chart_all['value'] * 100
    #not there are only 3 fields PA, variable, value
    varfield = 'variable'
    valfield = 'value'
    clusterfield = 'PA'

    for caption in captions:        
        if 'kwh' in caption.lower():
            fuel = '_kWh'           
        elif 'therm' in caption.lower():
            fuel = '_thm'
        else:
            msg = f'cannot amtch caption to fuel: {caption}'
            logging.critical(msg)
            print(msg)
            continue

        df_chart = df_chart_all
        #filter by fuel
        df_chart = df_chart[df_chart[varfield].str.contains(fuel)]
        #Replace variable values with frienldy ones
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('exante'), 'AR % of Claimed Savings')
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('expost'), 'AR % of Evaluated Savings')

        #remap utlity names
        df_chart[clusterfield] = df_chart[clusterfield].map(utility_remap)
        
        #round value field
        df_chart[valfield] = df_chart[valfield].round(2)

        colorfield = varfield
        yfield = valfield
        ytitle = ' '
        xfield = colorfield
        

        if printdata:
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename =  caption + '-' + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"        

        spec = vs.vis()
        spec.type = 'bar'
        spec.size = 18
        spec.source = df_chart
        spec.color = colorfield
        # spec.size_src = savfield
        # spec.sizecolor = True
        spec.column_src = clusterfield + ':N'
        spec.name = caption
        spec.path = outputfolder
        spec.facet_labelOrient = 'bottom'
        spec.legend_orient = 'bottom'
        spec.c_height = 400
        spec.c_width = 100 
        
        xaxis = vs.d_axis()
        xaxis.title = ''
        xaxis.source = xfield + ':N'
        # xaxis.resolvescale = 'independent'
        

        yaxis = vs.d_axis()
        yaxis.title = ytitle
        yaxis.source = yfield + ':Q'
        # yaxis.resolvescale = 'independent'
        
        spec.x = xaxis
        spec.y = yaxis

        vs.facet(spec)

def create_ExSumAR_plotly(captions, outputfolder=None, printdata=True):
    """
    Create the charts for ExSum AR
    """

    if not outputfolder:
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"

    srclist = [
        {'name':'state', 'src':'state_summary', 'return':'df'},             
        {'name':'pa', 'src':'papop', 'return':'df'},             
    ]

    results = get_datadef_source_info(srclist)
    df_sw = results['state']
    df_pa = results['pa']

    df_sw.columns = df_sw.columns.str.replace("SW", "PA")

    df_sw['PA'] = 'Statewide'
    #merge them
    df = pd.concat([df_pa, df_sw], sort=True)
    fields = ['PA','PA_exante_pct_AR_kWh', 'PA_exante_pct_AR_kW', 'PA_exante_pct_AR_thm', 'PA_expost_pct_AR_kWh', 'PA_expost_pct_AR_kW', 'PA_expost_pct_AR_thm']
    df = df[fields]
    df_chart_all = df.melt('PA')
    df_chart_all['value'] = df_chart_all['value'] * 100
    #not there are only 3 fields PA, variable, value
    varfield = 'variable'
    valfield = 'value'
    clusterfield = varfield
    pafield = 'PA'
    grpfield = pafield

    # fontsize = 14

    for caption in captions:        
        if 'kwh' in caption.lower():
            fuel = '_kWh'           
        elif 'therm' in caption.lower():
            fuel = '_thm'
        else:
            msg = f'cannot match caption to fuel: {caption}'
            logging.critical(msg)
            print(msg)
            continue

        df_chart = df_chart_all
        #filter by fuel
        df_chart = df_chart[df_chart[varfield].str.contains(fuel)]
        #Replace variable values with frienldy ones
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('exante'), 'AR % of Claimed Savings')
        df_chart[varfield] = df_chart[varfield].where(~df_chart[varfield].str.contains('expost'), 'AR % of Evaluated Savings')

        #remap utlity names
        df_chart[pafield] = df_chart[pafield].map(utility_remap)

        #drop any Utilities that only have zeros
        df_chart = df_chart.loc[df_chart[df_chart.columns.difference(['PA'])].sum(axis=1) != 0]
        
        #round value field
        df_chart[valfield] = df_chart[valfield].round(2)

        # colorfield = clusterfield
        yfield = valfield
        # ytitle = ' '
        xfield = clusterfield
        

        if printdata:
  
            pathroot= r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data"
            filename =  caption + '-' + '.csv'
            tmppath = os.path.join(pathroot, filename)
            df_to_csv_sharefile(df_chart,tmppath)
        
        outputfolder = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\output"        

        grpvar = grpfield
        varfield = xfield
        valfield = yfield
        textfield = valfield

        grplist = sorted(df_chart.sort_values(by=valfield,ascending=False)[grpvar].unique().tolist())
        # totalsubplots = len(grplist)
        cols = len(grplist)
        tickformatstring = None
        rows = 1 #math.ceil(len(reasonlist) / cols)
        # yrange = [0,math.ceil(df_chart[valfield].max())+5]
        clusterlist = sorted(df_chart[varfield].unique().tolist())
        # clustercolors = [px.colors.qualitative.Plotly[x] for x in range(0, len(clusterlist))]
        colormap = {x:px.colors.qualitative.Plotly[clusterlist.index(x)] for x in clusterlist}
        fig = make_subplots(rows=rows, cols=cols, shared_yaxes=True,
                # subplot_titles=clusterlist, #for titles above subplots
                )
        i=0
        j = 1
        df_bar_loop = df_chart        
        legendlist = []

        for grp in grplist:
            df_chart = df_bar_loop[df_bar_loop[grpvar]==grp]
            i += 1
            if i > cols:
                i = 1 #reset
                j += 1 #increment

            plotdata = []
            for item in clusterlist:
                df_item=df_chart[df_chart[clusterfield]==item]
                plotdata.append(
                    go.Bar(x=df_item[varfield], y=df_item[valfield],
                                width = 1, #bars will touch at 1. smaller numbers will leave space
                                text=df_item[textfield],textposition='outside',
                                textfont=dict(size=g_font_size + legend_size_increase + 1, color='black'),
                                name=f'<b>{item}</b>',
                                # title=None,
        #                          xaxis_tickangle=45,                                
                                marker=dict(color=colormap[item],
                                    ),                                 
                                showlegend= item not in legendlist,
                    )
                )
                legendlist.append(item)

            fig.add_traces(plotdata,  rows=[j] * len(plotdata), cols=[i] * len(plotdata))

            fig.update_xaxes(title_text=grp, showticklabels= False,
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                row=j, col=i)
            fig.update_yaxes(
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color,
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                row=j, col=i)

        fullwidth = 1200
        width = 240 * cols
        rowheight = fullwidth /2         
        fig.update_layout(
        # yaxis_title= ytitle,            
            plot_bgcolor='white',
            # legend=dict(x=.5, y=-.3, xanchor='center', yanchor='top', orientation="h",
            legend=dict(x=.5, xanchor='center', yanchor='top', orientation="h",
                font=dict(
                    family=fontfamily,
                    size=g_font_size + 2,
                    ),
                ),
            width=width,
            height=rowheight * rows ,# * 1.2,
            font=dict(
                family=fontfamily,
                size=g_font_size,
        #         color="#7f7f7f"
            ),
            margin=dict(
                t=0,
                b=0,
                l=0,
                r=0,
                pad=0
            )
    
        )

        for row in range(0,j):
            fig.update_yaxes(showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color,
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                showline=True, linewidth=axis_line_width, linecolor=axis_color, 
                tickformat= tickformatstring, row=row, col=1)
            # fig.update_yaxes(title_text= ytitle, range=yrange,row=j, col=1)           
            # fig['layout']['yaxis' + str(cols * row +1)].update(title=ytitle, range=yrange) #to get the yaxis on the first plot of each subsequent row

        filename = os.path.join(outputfolder, caption + '.svg')
        fig.write_image(filename)


def make_charts():
    """
    Process the plots on datadef

    temporary hack to test building.

    Connect to datadefs to run properly
    """

    printdata = False
    captions = [
        'Distribution of kWh Savings GRR by PA', 
        'Distribution of Therm Savings GRR by PA', 
        'Distribution of kWh Savings NTGR by PA', 
        'Distribution of Therm Savings NTGR by PA']
    
    captions = [
        'test Distribution of kWh Savings NTGR by PA',
        # 'Distribution of Therm Savings GRR by PA', 
    ]
    # create_ciac2018_dist_savings(captions, printdata=printdata)
    # ciac2018_dist_savings_plotly(captions, printdata=printdata)

    captions = [
        'test Primary Reasons for Differences in First Baseline (All Claims) Gross Savings (kWh)', 
        # 'test Primary Reasons for Differences in First Baseline (All Claims) Gross Savings (Therms)', 
        # 'Primary Reasons for Differences in Second Baseline (All Claims) Gross Savings (kWh)', 
        # 'Primary Reasons for Differences in Second Baseline (All Claims) Gross Savings (Therms)'
    ]

    # create_ciac2018_reasons_diff(captions)
    # create_ciac2018_reasons_diff_plotly(captions, printdata=printdata)

    captions = [
        'State_Primary Reasons for Differences in First Baseline (All Claims) Gross Savings (kWh)', 
        'State_Primary Reasons for Differences in First Baseline (All Claims) Gross Savings (Therms)',
    ]
    # create_ciac2018_reasons_diff_state(captions)
    

    captions = [
        'kwh rr and ntgr',
        'thm rr and ntgr' 
    ]
    # create_ExSumGRRNTGR(captions)

    captions = [
        'test Impact of Accelerated Replacement on Life-Cycle Net kWh Savings',
        'test Impact of Accelerated Replacement on Life-Cycle Net Therm Savings'
        # 'thm ar' 
    ]
    # create_ExSumAR(captions)
    # create_ExSumAR_plotly(captions, printdata=printdata)

    captions = ['kwh rr and ntgr', 'thm rr and ntgr']
    # create_ciac2018_ExSum_grrntgr_bar(captions, printdata=False)
    mkplot_ciac2018_ExSum_grrntgr_bar(captions, printdata=True)

    captions = ['test kwh gross eval vs claim']#, 'kwh net g plot test', 'thm gross test', 'thm net test']
    # create_ciac2018_ExSumm_savings_scatter(captions, printdata=printdata)

    captions = ['combined test']
    # create_ciac2018_ExSumm_savings_scatter_combined(captions, printdata=printdata)

def check_rollup_totals():
    """
    create qc table that shows savings differences between aggregation levels
    """
    srclist = [
        {'name':'domain', 'src':'domainpop', 'return':'df'},
        {'name':'pa', 'src':'papop', 'return':'df'},
        # {'name':'pa', 'src':'patest', 'return':'df'}, #For getting the answers to go to zero for testing
        {'name':'state', 'src':'state_summary', 'return':'df'},
        # {'name':'state', 'src':'swtest', 'return':'df'},
        {'name':'map', 'src':'agg_map', 'return':'df'},
        # {'name':'output', 'src':'agg_subtotal_variance', 'return':'path'},        
    ]

    results = get_datadef_source_info(srclist)
    df_domain = results['domain']
    df_pa = results['pa']
    df_state = results['state']
    df_map = results['map']
    # outpathname = results['output']
    #make sure these match what is in the map file
    dommap = 'Domain'
    pamap = 'PA'
    swmap = 'State'
    friendly = 'FullHeader'
    agglevel = 'agglevel'  #not header, but a field

    df_map_nopa = df_map[df_map[dommap] != 'PA']
    # p = re.compile('dom_.*?(AN|LN|AG|LG|1G)')
    # domfields = [s for s in df_domain.columns if p.match(s)]
    # domfields.append('PA')
    domfields = df_map[df_map[dommap].notnull()][dommap].tolist()
    df_domain_trunc = df_domain[domfields]
    #aggregate domain by PA
    df_domain_pa = df_domain_trunc.groupby(['PA']).sum().reset_index()
    df_domain_sw = pd.DataFrame(df_domain_trunc.sum()).T
    df_domain_sw.drop('PA', axis=1, inplace=True)
    
    df_pa_sw = pd.DataFrame(df_pa.sum()).T
    df_pa_sw.drop('PA', axis=1, inplace=True)
    #rename fields so they match the pa table
    df_domain_pa_remapped = remapdata(df_map, dommap, pamap, df_domain_pa)
    #rename to match statewide
    df_domain_sw_remap = remapdata(df_map_nopa, dommap, swmap, df_domain_sw)
    df_pa_sw_remap = remapdata(df_map_nopa, pamap, swmap, df_pa_sw)
    
    #Prep PA
    df_pa = df_pa[df_domain_pa_remapped.columns]
    df_domain_pa_remapped.set_index('PA', inplace=True)
    df_pa.set_index('PA', inplace=True)
    #Prep SW
    df_sw = df_state[df_domain_sw_remap.columns]

    print(f'num shape {df_domain_pa_remapped.shape}, den shape {df_pa.shape}')
    print(f'num shape {df_domain_sw_remap.shape}, den shape {df_sw.shape}')
    print(f'num shape {df_pa_sw_remap.shape}, den shape {df_sw.shape}')
    if df_domain_pa_remapped.shape == df_pa.shape:
        domainpct = 1 - (df_domain_pa_remapped / df_pa)
    else:
        print(f'Shapes are different for df_domain_pa_remapped/df_pa. num shape {df_domain_pa_remapped.shape}, den shape {df_pa.shape}')
    if df_domain_sw_remap.shape == df_sw.shape:
        dom_st_pct = 1 - (df_domain_sw_remap / df_sw)
    else:
        print(f'Shapes are different for df_domain_sw_remap/df_sw. num shape {df_domain_sw_remap.shape}, den shape {df_sw.shape}')
    if df_pa_sw_remap.shape == df_sw.shape:
        pa_st_pct = 1 - (df_pa_sw_remap / df_sw)
    else:
        print(f'Shapes are different for df_pa_sw_remap/df_sw. num shape {df_pa_sw_remap.shape}, den shape {df_sw.shape}')
    
    # dom_st_pct = 1 - (df_domain_sw_remap / df_sw)
    # pa_st_pct = 1 - (df_pa_sw_remap / df_sw)

    #combine dom and pa into single df
    dom_st_pct[agglevel] = 'domain'
    pa_st_pct[agglevel] = 'pa'
    st_pct = pd.concat([dom_st_pct, pa_st_pct])
    df_domain_pa_remapped.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_domain_pa_remapped.csv')
    df_domain_sw_remap.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_domain_sw_remap.csv')
    # df_pa.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_pa.csv')
    # domaindiff.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\domaindiff.csv')
    domainpct.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\domain_papct.csv')
    st_pct.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\sw_pct.csv')
    domainpct = domainpct.reset_index()
    domainpct_friendly = remapdata(df_map, pamap, friendly, domainpct)

    # dom_st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, dom_st_pct)
    # pa_st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, pa_st_pct)
    # pa_st_pct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\pa_sw_pct_friendly.csv')

    st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, st_pct)
    domainpct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\domain_papct_friendly.csv', index=False)
    st_pct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\sw_pct_friendly.csv', index=False)
        
    print('doh')

def check_rollup_totals_multiple():
    """
    create qc table that shows savings differences between aggregation levels
    """

    #build list of files
    sources = [
        ['domain_4-1', 'papop_4-1', 'swpop_4-1', 'agg_map_4-1', '4-1'],
        ['domain_5-1', 'papop_5-1', 'swpop_5-1','agg_map_5-1', '5-1'],
        ['domain_8-3', 'papop_8-3', 'swpop_8-3','agg_map', '9-15'],
    ]

    for slist in sources:
        srclist = [
            {'name':'domain', 'src':slist[0], 'return':'df'},
            {'name':'pa', 'src':slist[1], 'return':'df'},
            {'name':'state', 'src':slist[2], 'return':'df'},
            {'name':'map', 'src':slist[3], 'return':'df'},
        ]

        results = get_datadef_source_info(srclist)
        df_domain = results['domain']
        df_pa = results['pa']
        df_state = results['state']
        df_map = results['map']
        dommap = 'Domain'
        pamap = 'PA'
        swmap = 'State'
        friendly = 'FullHeader'
        agglevel = 'agglevel'  #not header, but a field

        df_map_nopa = df_map[df_map[dommap] != 'PA']
        domfields = df_map[df_map[dommap].notnull()][dommap].tolist()
        df_domain_trunc = df_domain[domfields]
        #aggregate domain by PA
        df_domain_pa = df_domain_trunc.groupby(['PA']).sum().reset_index()
        df_domain_sw = pd.DataFrame(df_domain_trunc.sum()).T
        df_domain_sw.drop('PA', axis=1, inplace=True)
        
        df_pa_sw = pd.DataFrame(df_pa.sum()).T
        df_pa_sw.drop('PA', axis=1, inplace=True)
        #rename fields so they match the pa table
        df_domain_pa_remapped = remapdata(df_map, dommap, pamap, df_domain_pa)
        #rename to match statewide
        df_domain_sw_remap = remapdata(df_map_nopa, dommap, swmap, df_domain_sw)
        df_pa_sw_remap = remapdata(df_map_nopa, pamap, swmap, df_pa_sw)
        
        #Prep PA
        df_pa = df_pa[df_domain_pa_remapped.columns]
        df_domain_pa_remapped.set_index('PA', inplace=True)
        df_pa.set_index('PA', inplace=True)
        #Prep SW
        df_sw = df_state[df_domain_sw_remap.columns]

        print(f'num shape {df_domain_pa_remapped.shape}, den shape {df_pa.shape}')
        print(f'num shape {df_domain_sw_remap.shape}, den shape {df_sw.shape}')
        print(f'num shape {df_pa_sw_remap.shape}, den shape {df_sw.shape}')
        if df_domain_pa_remapped.shape == df_pa.shape:
            domainpct = 1 - (df_domain_pa_remapped / df_pa)
        else:
            print(f'Shapes are different for df_domain_pa_remapped/df_pa. num shape {df_domain_pa_remapped.shape}, den shape {df_pa.shape}')
        if df_domain_sw_remap.shape == df_sw.shape:
            dom_st_pct = 1 - (df_domain_sw_remap / df_sw)
        else:
            print(f'Shapes are different for df_domain_sw_remap/df_sw. num shape {df_domain_sw_remap.shape}, den shape {df_sw.shape}')
        if df_pa_sw_remap.shape == df_sw.shape:
            pa_st_pct = 1 - (df_pa_sw_remap / df_sw)
        else:
            print(f'Shapes are different for df_pa_sw_remap/df_sw. num shape {df_pa_sw_remap.shape}, den shape {df_sw.shape}')
        
        domainpct['Revision'] = slist[4]
        #combine dom and pa into single df
        dom_st_pct[agglevel] = 'domain'
        pa_st_pct[agglevel] = 'pa'
        st_pct = pd.concat([dom_st_pct, pa_st_pct])
        st_pct['Revision'] = slist[4]

        if 'domainpct_combined' not in locals():
            domainpct_combined = domainpct
        else:
            domainpct_combined = pd.concat([domainpct_combined, domainpct])

        if 'st_pct_combined' not in locals():
            st_pct_combined = st_pct
        else:
            st_pct_combined = pd.concat([st_pct_combined, st_pct])

    # df_domain_pa_remapped.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_domain_pa_remapped.csv')
    # df_domain_sw_remap.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_domain_sw_remap.csv')
    # df_pa.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\df_pa.csv')
    # domaindiff.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\domaindiff.csv')
    domainpct_combined.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\domain_papct_revisions.csv')
    st_pct_combined.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\sw_pct_revisions.csv')
    # domainpct = domainpct.reset_index()
    # domainpct_friendly = remapdata(df_map, pamap, friendly, domainpct)

    # dom_st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, dom_st_pct)
    # pa_st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, pa_st_pct)
    # pa_st_pct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\pa_sw_pct_friendly.csv')

    # st_pct_friendly = remapdata(df_map_nopa, swmap, friendly, st_pct)
    # domainpct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\domain_papct_friendly.csv', index=False)
    # st_pct_friendly.to_csv(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\Test\sw_pct_friendly.csv', index=False)
        
    print('doh')

def build_combined_summary_compare():
    """
    put the 5-1 version together with the current version
    """
    file51 = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_5-1.csv"
    filecurrent = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary.csv"

    df_51 = pd.read_csv(file51)
    df_cur = pd.read_csv(filecurrent)

    df_51['period']='51'
    df_cur['period']='cur'

    df = pd.concat([df_cur, df_51])
    outfile = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_qccompare.csv"
    df.to_csv(outfile, index=False)

    commoncols = [x for x in df_51.columns if x in df_cur.columns]
    commoncols.remove('Unnamed: 0')
    commoncols.remove('period')


    df_51_com = df_51[commoncols]
    df_cur_com = df_cur[commoncols]
    df_51_com.set_index(['PA', 'domain'], inplace = True)
    df_cur_com.set_index(['PA', 'domain'], inplace = True)
    df_dif = 1 - (df_51_com / df_cur_com)
    outfile = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_qcdifs.csv"
    df_dif.to_csv(outfile)

def build_combined_summary_compare_multiple():
    """
    compare the various versions of the report data
    """
    
    file41 = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_4-1.xlsx"
    file51 = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_5-1.xlsx"
    file83 = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_8-3.csv"

    df_41 = pd.read_excel(file41)
    df_51 = pd.read_excel(file51)
    df_83 = pd.read_csv(file83)

    df_41['period']='41'
    df_51['period']='51'
    df_83['period']='915'

    versions = [df_41, df_51, df_83]
    df_cur = df_83
    for i in range(0,len(versions)-1):
    # for df_old in oldversions:
        df_old = versions[i]
        df_cur = versions[i+1]
        if 'df' not in locals():
            df = pd.concat([df_cur, df_old])
        else:
            df = pd.concat([df, df_cur])

        commoncols = [x for x in df_old.columns if x in df_cur.columns]
        commoncols.remove('Unnamed: 0')
        commoncols.remove('period')

        df_old_com = df_old[commoncols]
        df_cur_com = df_cur[commoncols]
        df_old_com.set_index(['PA', 'domain'], inplace = True)
        df_cur_com.set_index(['PA', 'domain'], inplace = True) #does this cause a problem the second time through? need to reset?
        df_dif_interim = 1 - (df_old_com / df_cur_com)
        df_dif_interim['period'] = f"{df_old['period'].unique()[0]}-{df_cur['period'].unique()[0]}"
        if 'df_dif' not in locals():
            df_dif = df_dif_interim
        else:
            df_dif = pd.concat([df_dif, df_dif_interim])


    outfile = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_qccompare_all.csv"
    df.to_csv(outfile, index=False)
    outfile = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\8 PII\11 - Draft and Final Evaluation Reports\CIAC2018\Data\combined_summary_qcdifs_all.csv"
    df_dif.to_csv(outfile)

def runcode():
        
    logging.info('done with running')


if __name__ == '__main__':
    
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    #create_cedars_custom(sfsession)

    # create_detail_pop(sfsession, mapsheet='map_gross')
    #need a pause between the two to give sharefile time to sync the cloud to local
    # time.sleep(30)
    # path = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\09 - Ex-Post Evaluated Gross Savings Estimates\CIAC\2018 Evaluation\Extrapolation\extrapolator_gross.R'
    # run_r_code(path) #can't be run in the cloud

    # # #run net code
    # create_detail_pop(sfsession, mapsheet='map_net')
    
    # Run net R  code
    # time.sleep(30)
    # path = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\09 - Ex-Post Evaluated Gross Savings Estimates\CIAC\2018 Evaluation\Extrapolation\extrapolator_net.R'
    # run_r_code(path) #can't be run in the cloud

    # create_combined_summary_tables()

    #  run final claimpop creation
    # create_detail_pop(sfsession, mapsheet='map_clm')
   
    # create_sample_pop(sfsession)
    # create_framedesign(sfsession)
    # create_responserate(sfsession)       
    

    # create_detail_pop(sfsession, mapsheet='map_atrbuild')
    # create_detail_pop(sfsession, mapsheet='map_atr')

    copy_deliverable_code(params.CIAC_2018_DATA_DEF_FILE, sheet='codefiles', listfilter='active=="y"')
    # # copy_deliverable_code(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\__ - Cross Cutting\Evaluation Tools\codeoutputdriver.xlsx', sheet='2017review', listfilter='active=="y"')
    # # copy_deliverable_code(r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\__ - Cross Cutting\Evaluation Tools\codeoutputdriver.xlsx', sheet='2017review', listfilter='active=="y"')

    # compare_datasets()
    # make_charts() #temporary until real driver is built. Driven through generate tables now

    # check_rollup_totals()
    # build_combined_summary_compare()
    # build_combined_summary_compare_multiple()
    # check_rollup_totals_multiple()