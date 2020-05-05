#an assortment of utility functions
import logging
import numpy as np
from io import StringIO
import os.path
import re

import pandas as pd

from cpuc.sharefileapi import ShareFileSession
from cpuc.sharefileapi import SHAREFILE_OPTIONS
import cpuc.workbookfunctions as wf
from cpuc.workbookfunctions import openworkbook


#import cpuc.workbookfunctions as wf
#from read_cpr_files import rowtolist

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

def dftokeyvaluedict(df, keyfield, valuefield):
    """
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
