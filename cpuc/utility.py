#an assortment of utility functions
import logging
import numpy as np
from io import StringIO
from io import BytesIO
import os.path
import re
from zipfile import ZipFile
from datetime import datetime

import pandas as pd
import psycopg2
from sqlalchemy import MetaData
from sqlalchemy import Table
from sqlalchemy import Boolean
# from sqlalchemy import Column
# from sqlalchemy import column
from sqlalchemy import DateTime
from sqlalchemy import Float
# from sqlalchemy import ForeignKey
from sqlalchemy import Integer
# from sqlalchemy import MetaData
from sqlalchemy import String
# from sqlalchemy import Table
from sqlalchemy import Text
# from sqlalchemy import text
# from sqlalchemy import select


import cpuc.params as params #Try to remove this
from cpuc.db import engine
from cpuc.sharefileapi import ShareFileSession
from cpuc.sharefileapi import SHAREFILE_OPTIONS
from cpuc.postgreutil import df_to_db
import cpuc.workbookfunctions as wf
from cpuc.workbookfunctions import openworkbook
from cpuc.workbookfunctions import getSampleControlFile
from cpuc.postgreutil import run_sql

from cpuc.sensitive import AWS_POSTGRES_OPTIONS
#pull these function to a separate file
from cpuc.project_tracker import download_data 
from cpuc.project_tracker import get_table_list

#import cpuc.workbookfunctions as wf
#from read_cpr_files import rowtolist

# cpuc types
# "character"
# "boolean"
# "text":str
# "bigint"
# "double precision"
# "date"
# "timestamp without time zone"
# "character varying"
# "integer" : int

POSTGRE_PYTHON_MAPPING = {
    'character' : str,
    'boolean' : bool,
    'text' : str,
    'bigint' : int,
    'double precision' : float,
    'date' : datetime,
    'timestamp without time zone' : datetime,
    'character varying' : str,
    'integer' : int
}

class oLoggger():
     def __init__(self, **kwargs):
        self.pathid = ''
        self.filename = ''
        self.logfile = None


def df_to_csv_sharefile(df, zfilepath):
    """
    write dataframe to csv vial sharefile api
    """
    if not zfilepath:
        logging.critical('cannot write csv file becasue no path passed')
        return False
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    #write out file
    out_io = StringIO()
    out_io.seek(0)
    df.to_csv(out_io)   
    filename = os.path.basename(zfilepath)
    pathroot = zfilepath.split(filename)[0]
    folder_item = sfsession.get_item_by_local_favorites_path(pathroot)
    sfsession.upload_file(folder_item.id, filename, out_io)

def xdftokeyvaluedict(df, keyfield, valuefield):
    """
    Moved to util_min file
    transform a dataframe to a dict in the form of 
     {'keyfield1': 'valuefield1', 'keyfield2': 'valuefield2', ...}
     Pass in the two column names that are to be the key and value
    """

    if keyfield == valuefield:
        fielddict = df[keyfield].to_list()
        fielddict = {x:x for x in fielddict}
    else:
        fielddict = df[[keyfield, valuefield]]
        fielddict.set_index(keyfield, inplace=True)
        fielddict = fielddict.to_dict()[valuefield]
    return fielddict


def download_tables(sfsession:ShareFileSession, df_list=None, criteriafield='download', groupfield='tblroot', downloadpathfield='downloadpath'):
    """
    make local copies of the db tables
    """

    if not isinstance(df_list, pd.DataFrame):
        #open driver and get list, limit to active
        df_list = get_df_from_driver(filepath=params.READ_WORKBOOKS_TEMPLATE_LIST_FILE, sheet='read', querystr='active=="y"')
        if not isinstance(df_list, pd.DataFrame):
            return False
    #Shouldn't this be checking download?
    # filelist_grp = df_list[df_list['overwritetracker'] == True].groupby('tblroot')
    filelist_grp = df_list[df_list[criteriafield] == True].groupby(groupfield)
    alltablelist = get_table_list(nameonly=True)
    for tbl, filerow in filelist_grp:            
        tableroot = tbl
        filepathroot = filerow.downloadpath.values[0]            
        #get list of tables with this root
        tablelist = [x for x in alltablelist if tableroot in x]
        for table in tablelist:
            filepath = filepathroot + '\\' + table + '.csv'
            #logging.warning(f'INFO - downloading {table} to {filepath}')
            download_data(table, filepath, sfsession)

def formatws(wb, cell = 'A1', zoomlvl = 100, shtnames = None):
    '''
    SM: formats sheets in workbook. Currently resets topleftcell of view and zoom level of specified sheets.

    wb = workbook to be formatted
    cell = cell reference as string to be used for topLeftCell. Defaults to A1 if not provided
    zoomlvl = zoom level as int to be used to set zoom of sheets. Defaults to 100 if not provided
    shtname = list of sheets within a workbok to be formatted. Will format all sheets if not provided.
    '''
      
    if shtnames == None:
        lws = wb.sheetnames

    for i in lws:
        ws = wb[i]
        ws.sheet_view.topLeftCell= cell
        ws.sheet_view.zoomScale = zoomlvl

def get_df_from_driver(filepath:str, sheet:str, querystr:str=None):
    """
    Get a dataframe of a sheet from the driver spreadsheet
    Pass in:
        filepath: Path to the driverfile
        sheet: Sheet with the list
        querystr: Optional Query string to limit the list. The form of the query string is 'active == "y"'
        Assumes tables starts with first row. If not try using 
    Returns a dataframe
    """
    filelist = None
    try:
        sfsession = ShareFileSession(SHAREFILE_OPTIONS)
        readlist_item = sfsession.get_io_version(filepath)
        control_wb = wf.openworkbook(readlist_item.io_data)
        if not control_wb:
            logging.warning('cannot open read template file list workbook')
            return False
        ws = control_wb[sheet]
        filelist = wf.convertwstodf(ws)
        if querystr:
            filelist = filelist.query(querystr)
        control_wb.close()
    except Exception as e:
        msg = f'Problem in get_df_from_driver: {e}'
        logging.critical(msg)
        print(msg)
        return False

    readlist_item = None
    sfsession = None
    return filelist

def get_item_mod_date(item):
    """ Return mod date if present, otherwise return creation date """

    if 'ClientModifiedDate' in item.data:
        moddate = item.data['ClientModifiedDate']
    else:
        moddate = item.data['CreationDate']

    return moddate

def input_to_str_list(stuff, sep:str=','):
    """
    converts character separated input into list of string elements
    does not remove ' or ". So if those are in the input they will be encapsualted in quotes, e.g. "'1'"
    """

    if stuff is None:
        return []
    #case where blank input interpreted as float
    try:
        if np.isnan(stuff):
            return []
    except:
        pass

    try:  
        return [x.strip() for x in stuff.split(sep)]
    except: #above will fail for single number
        return [str(stuff).replace('.0','')]

def is_archive_empty(filepath):
    """returns true if the archive is empty
    filepath can be a string or filelike object
    """
    archive = ZipFile(filepath)
    names = archive.namelist()
    return len(names)==0


def replace_strings_with_spaces(string):
    """
    replaces single quoted strings in a string that have spaces
    returns a dictionary with the new string with a dummy string replacement and a dict of the original strings and their replacement
    passed string: "blah blah 'warts are good' blah blah"
    output = {
        newstring: "blah blah '999x1' blah blah", 
        replacedict: {
            '999x1': 'warts are good'
        }
    }
    """
    inputString = string

    strings = re.findall(r"'([^']*)'", inputString)
    int = 1
    replacestrings = dict()
    for s in strings:
        replstr = '999x' + str(int)
        if s != '':
            inputString = inputString.replace(s, replstr)
            int += 1
            replacestrings[replstr] = s

    output = {
        'newstring':inputString, 
        'replace_dict':replacestrings
    }

    return output

def rgb_to_hex(rgb):
    """ 
    convert rgb color to hex
    Input rgb in the form of a numeric string
    """
    if isinstance(rgb, tuple):
        hex = '#' + '%02x%02x%02x' % rgb
        return hex
    if len(rgb)==9:
        input = (int(rgb[:3]), int(rgb[3:6]), int(rgb[6:9]))
        hex = '#' + '%02x%02x%02x' % rgb
        return hex
    try:
        input = int(rgb)
        if input == 0:
            hex = '#FFFFFF'
            return hex
    except: #must already be semi hex form
        input = rgb
        hex = '#' + input[2:]    
        return hex
    
        #rgb_to_hex((255, 255, 195))

def rowtolist(worksheet, row, tolower = True, removeblanks=True):
    """
    Input worksheet and integer
    """
    dataheader = [cell.value for cell in worksheet[row]]                       
    if removeblanks:
        dataheader = list(filter(None.__ne__, dataheader)) #remove Nones from the list            
    try:
        if tolower:
            dataheader = [i.lower() for i in dataheader]
    except: #above will fail if there are blanks
        pass 
    return dataheader

def swap_out_strings(input, replacedict):
    """
    swaps out any strings that are in the replacement dict
    """
    if isinstance(input, str):
        for k,v in replacedict.items():
            input = input.replace(k,v)
        modinput = input
    elif isinstance(input, list):
        modinput = []
        for item in input:
            for k,v in replacedict.items():
                item = item.replace(k,v)
            modinput.append(item)
    return modinput

def writetoexcel(ws_vals, ws_out, header_row, datalist, key, key_data = None, append=False):
    """
    Writes the data to the passed sheet in the area starting with header_row.
    Vals version of the sheet is used for searching, out version will be written to
    header_row      integer
    datalist    data as a list of dictionaries
    key     Index field in worksheet
    keydata     index field for data if it's different. If not passed will use key

    Returns worksheet
    """
    #TODO this seems to run slow. See if there is a more efficient way to do this.
    ws_out_vals = ws_vals
    if key_data == None:
        key_data = key
    
    if not ws_out:
        return False
    for data in datalist:
        datakeys = data.keys()

        #check if keyfield exists in ws
        headers = rowtolist(ws_out_vals, header_row, tolower=False)
        if key not in headers:
            continue
        #build header to column dict
        headercols = {}
        dtrow = header_row - 2
        for c in range(1,ws_out_vals.max_column +1):
            if ws_out_vals.cell(header_row, c).value in datakeys:
                headercols[ws_out_vals.cell(header_row, c).value] = c
            if ws_out_vals.cell(header_row, c).value == key:
                keycol = c
        if key in headercols and not append:            
            keycol = headercols.pop(key)        

        if append:
            #find last used row
            if 'lastrow' not in locals():
                lastrow = ws_out_vals.max_row + 1
            else:
                lastrow += 1
            for k,v in headercols.items():
                if 'time' in str(type(data[k])):
                    ws_out.cell(lastrow,v).value = data[k].strftime('%m/%d/%Y')                    
                else:
                    if data[k] != data[k]: #then it's nan
                        pass
                        #ws_out.cell(lastrow,v).value = 'NA'
                    else:
                        ws_out.cell(lastrow,v).value = data[k]
            
        else:
            #TODO for efficiency find way to determine the row #'s of the keys and then just access those directly, kind of how it is with the cols.
            for row in ws_out_vals.iter_rows():
                if type(row) is tuple:
                    if row[0].row <= header_row:
                        continue
                    if str(ws_out_vals.cell(row[0].row,keycol).value) == str(data[key_data]):
                        for k,v in headercols.items():
                            if 'datatime' in str(type(data[k])):
                                ws_out.cell(row[0].row,v).value = data[k].strftime('%m/%d/%Y')
                                #or maybe change to excel integer value
                            else:
                                ws_out.cell(row[0].row,v).value = data[k]                        
                else:
                    print('row not tuple')
        
    return ws_out

def excel_to_df(filepath):
    """
    Open a single sheet excel file and return it as a df
    """
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)    
    item = sfsession.get_io_version(filepath)
    if item is None:
        msg = f'Could not find file {filepath}'
        print(msg)
        logging.critical(msg)
        return None
    else:
        try:
            df = pd.read_excel(item.io_data)            
        except Exception as e:
            msg = f'File open FAILED for {filepath} error:{e}'
            print(msg)
            logging.critical(msg)
            return None
    
    return df

def create_folder(folder):
        """
        Create a folder. Fills in intermediate directories if they don't
        exist.
        """
        #TODO update to use sharefile api
        try:
            os.makedirs(folder)
            logging.info('Created {}'.format(folder))
        except FileExistsError:
            logging.info('{} already exists, skipping'.format(folder))

def download_db_data(sql, filepath, delimiter=',', quote='"'):
    """
    Downlaod data from db to a csv file
    Pass in sql statement and local file path
    This is slower than download_data so don't recommend use for full tables.
    Must be connected to vpn or be coming from a whitelisted IP address to use
    """

    db_conn = psycopg2.connect(host=AWS_POSTGRES_OPTIONS['host'], port=AWS_POSTGRES_OPTIONS['port'], 
        dbname=AWS_POSTGRES_OPTIONS['db'], user=AWS_POSTGRES_OPTIONS['user'], password=AWS_POSTGRES_OPTIONS['password'])
    db_cursor = db_conn.cursor()

    fileobj = StringIO()

    # SQL_for_file_output = f"COPY ({sql}) TO STDOUT WITH CSV HEADER"
    SQL_for_file_output = f"COPY ({sql}) TO STDOUT WITH (FORMAT csv, DELIMITER '{delimiter}', QUOTE '{quote}', HEADER TRUE)"
    # WITH (FORMAT csv, DELIMITER '|', QUOTE '^', HEADER FALSE)"
    out_file = StringIO()
    folderpath, filename = os.path.split(filepath)
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    folder_item = sfsession.get_item_by_local_favorites_path(folderpath)
    if not folder_item:
        msg = f'problem with {filepath}'
        print(msg)
        returnval = msg
    
    try:
        # WITH Open(t_path_n_file, 'w') as f_output:
            # db_cursor.copy_expert(SQL_for_file_output, f_output)
        db_cursor.copy_expert(SQL_for_file_output, fileobj)
        #upload fileobj to sharefile
        sfsession.upload_file(folder_item.id, filename, fileobj) 
        returnval = True           

    except psycopg2.Error as e:
        msg = f"Error: {e}/n query we ran: {sql}/n t_path_n_file: {filepath}"
        print(msg)
        # return render_template("error.html", t_message = t_message)
        returnval = msg
    db_cursor.close()
    db_conn.close()

    return returnval

def copy_deliverable_code(driverfile:str, sheet:str=None, srcfield='srcpath', destfield='destfolder', listfilter:str=None):
    """
    copy files as defined in passed driver file (path)
    uses internal filesystem not cloud for copy(since might be stuff not on system), but uses cloud for driver processing   
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

def upload_excel_data(df_data):
    """   
    upload data for everything defined datadef (a pandas dataframe)
    Assumes a specific columns are present  in datadef: TableName, Source, IndexField, sheet, startrow
    Okay if additional columns present
    Will drop unnamed columns. So don't include 'Unnamed' in any field names

    """
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)

    for tablerow in df_data.itertuples():
        tablename = tablerow.TableName
        key = tablerow.IndexField        
        file_item = sfsession.get_io_version(tablerow.Source)
        #get list of headers in the file
        df = pd.read_excel(io=file_item.io_data,sheet_name=tablerow.sheet, skiprows=tablerow.startrow-1, nrows=1)
        excelheaderlist = [x for x in df.columns if 'Unnamed' not in x]
        #get columns and types from the db
        sql = 'SELECT column_name, data_type FROM information_schema.columns '
        sql += f"WHERE table_name = '{tablename}' AND table_schema = 'cpuc';"
        results = run_sql(sql, returnresults=True)

        tabletypedict = {}
        #Create type list for excel read
        for item in excelheaderlist:
            try:
                dbtype = [j for i,j in results if i == item][0]
                tabletypedict[item] = POSTGRE_PYTHON_MAPPING[dbtype]
            except:
                print(f'{item} is not in database table, assiging str type')
                #Should this be dropped so pandas can just pick the best type?
                tabletypedict[item] = str        

        df = pd.read_excel(io=file_item.io_data,sheet_name=tablerow.sheet, skiprows=tablerow.startrow-1, dtype=tabletypedict)
        
        #drop unnamed columns
        try:
            df = df.loc[:, ~df.columns.str.match('Unnamed')]
        except:
            # print('no unnamed')
            pass

        #convert NANs to None
        df = df.where(pd.notnull(df), None)
        df_to_db(df=df, tablename=tablename, key=key)

def isMergedCell(cell):
    """
    Returns if the cell is part of a merged cell
    """
    for item in sorted(cell.parent.merged_cells.ranges):
        if cell.row >= item.bounds[1] and cell.row <= item.bounds[3] \
            and cell.column >= item.bounds[0] and cell.column <= item.bounds[2]: 
        # if item.left[0][0] == cell.row or item.left[0][1] == cell.column:     
            return True
    return False

def db_to_excel(filepath):
    """
    Move data from the db (or other source) to excel files as defined in the passed excel filename
    The passed workbook must have a sheet named spec and columns named active, srctype, tablename, srcindex, srcfields, destindex, destfile, sheet, startrow, fields

    """
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    #open workbook
    control_item = sfsession.get_io_version(filepath)
    if not control_item:
        logging.warning(f'driver file {filepath} not found for db_to_excel')
        return False
    control_wb = wf.openworkbook(control_item.io_data)
    ws = control_wb['spec']
    filelist = wf.convertwstodf(ws)
    filelist = filelist.query('active == "y"')
    control_wb.close()
    control_item = None
    #gather needed parts

    #TODO sort list so all changes to a workbook can be done and then that workbook saved rather than needing to open and close for each write
    for filerow in filelist.itertuples():
        excelpath = filerow.destfile
        localname = os.path.basename(excelpath)
        headerrow = filerow.headerrow
        sheet = filerow.sheet
        fields = filerow.fields
        table = filerow.tablename
        srcindex = filerow.srcindex
        dstindex = filerow.destindex
        wkb_item = sfsession.get_io_version(excelpath)
        hasvba = '.xlsm' in excelpath
        srcfields = filerow.srcfields
        srctype = filerow.srctype

        if srctype == 'db':
        #get data from db
            data = pd.read_sql(table, engine)
        elif srctype == 'csv':
            src_item = sfsession.get_io_version(table)
            if not src_item:
                logging.warning(f'file {table} not found for db_to_excel')
                continue
            src_item.io_data.seek(0)
            data = pd.read_csv(src_item.io_data)
        elif srctype == 'excel':
            src_item = sfsession.get_io_version(table)
            if not src_item:
                logging.warning(f'file {table} not found for db_to_excel')
                continue
            srcsheet = filerow.srcsheet
            srcrow = filerow.srcheaderrow
            data = pd.read_excel(src_item.io_data, sheet_name=srcsheet, start_row=srcrow-1)
           
        srcfieldlist = srcfields.split(',')
        srcfieldlist.append(srcindex)
        data_fields = data[srcfieldlist]
        dstfieldlist = fields.split(',')
        dstfieldlist.append(dstindex)
        #remap src field names to dst field names
        data_fields.columns = dstfieldlist
        datalist = data_fields.to_dict('records')
        
        #this is to figure out where data should go, but since it uses values, can't save
        ws_vals = getSampleControlFile(filepath = wkb_item.io_data,
            wks = sheet,
            headerrow = headerrow, #not used but passing it anyway
            asdf = False,
            usevalues = True)
        #this is the one where values actually get written to
        ws_out = getSampleControlFile(filepath = wkb_item.io_data,
            wks = sheet,
            headerrow = headerrow, #not used but passing it anyway
            asdf = False,
            usevalues = False, 
            usevba=hasvba)
        print(f'starting to write to excel {fields} {str(datetime.now())}')
        ws_results = writetoexcel(ws_vals = ws_vals, ws_out = ws_out, header_row = headerrow, datalist = datalist, key = dstindex)
        print(f'done writing  to excel {str(datetime.now())}')
        if not ws_results:
            print('bad results')
        else:
            tracker_io = BytesIO()
            ws_results.parent.save(tracker_io)
            #upload to sf
            wkb_folderID = wkb_item.data['Parent']['Id']
            sfsession.upload_file(wkb_folderID, localname, tracker_io)
            print(f'done uploading to sharefile {str(datetime.now())}')
