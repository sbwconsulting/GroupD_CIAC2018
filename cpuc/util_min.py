import logging
import os.path

import pandas as pd

from cpuc.sharefileapi import ShareFileSession
from cpuc.sharefileapi import SHAREFILE_OPTIONS

def clean_data(datalist, schema):
    """
    Clean up data so it can get posted to database
    Clear text out of number fields
    Clear apostrophes out of text
    """

    numbertypes = ['datetime', 'float', 'integer']
    stringtypes = ['string', 'text']
    if datalist is None:
        #print(f'no data for {schema}')
        return datalist
    for k,v in schema.items():
        if v.lower() in numbertypes:
            for d in datalist:
                d.update((key, None) for key, value in d.items() if key == k and not is_number(value))
            #datalist = [ key:(None if key == k and not is_number(value)  else value) for key, value in datalist ] 
        elif v.lower() in stringtypes:
            #datalist = [ key:(value.replace("'", "") if key == k and "'" in value  else value) for key, value in datalist ]
            for d in datalist:
                d.update((key, str(value).replace("'", "")) for key, value in d.items() if key == k and "'" in str(value))

    return datalist

def cleanfields(datalist, schema):
    """
    Remove special characters
    Currently only deals with %
    """
    #TODO add ability to handle numeric keys
    schema = { (key.replace('%', 'Pct')): value for key, value in schema.items() } 
    fixeddatalist = []
    if datalist is None:
        return [datalist, schema]
    for d in datalist:
        d.pop(None, None) #in case there are any bad fieldnames that were turned into None
        d = { (key.replace('%', 'Pct')): value for key, value in d.items() }
        #for field in d.iterkeys():
        #    if '%' in field:
        #        d[field.replace('%', 'Pct')] = d.pop(field)
        fixeddatalist.append(d)
    package = [fixeddatalist, schema]
    
    return package

def copy_file(sourcefilepath, destinationpath):
    """
    make a copy of the file. Rename if the destination includes a filename
    Pass in z paths
    """

    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    src_item = sfsession.get_item_by_local_favorites_path(sourcefilepath)
    if not src_item:
        print(f'problem with source{sourcefilepath}')
        return False
    destfolder, destname = os.path.split(destinationpath)
    if not '.' in destname:
        destname = None
        destfolder = destinationpath
    dest_item = sfsession.get_item_by_local_favorites_path(destfolder)
    if not dest_item:
        print(f'problem with destination path {destfolder}')
        return False
        #check to see if dest is a file
    print(f'starting copy of {sourcefilepath} to {destfolder}')
    #this method used to work, but seems to be causing issues now. So implementing a slower download/upload method
    # result = sfsession.copy_item(src_item.id, dest_item.id, True)
    src_item.download_io()
    sfsession.upload_file(dest_item.id, src_item.name, src_item.io_data)
    # if not result:
    #     print(f'problem copying file')
    #     return False
    if destname: #rename destfile
        destpath = os.path.join(destfolder, src_item.name)
        dest_item = sfsession.get_item_by_local_favorites_path(destpath)
        if dest_item:
            data = {
                "Name": destname
            }
            dest_item.update(data)

    # print('after copy')
    return True

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

def is_number(s):
    """
    Is the value numeric
    """
    if s is None:
        return False
    if 'Time' in type(s).__name__:        
        return True
    if 'Na' in type(s).__name__:
        return False
    try:
        float(s)
        return True
    except ValueError:
        return False

def uploadfile(fileobj, filepath):
    """
    upload a fileobj to sharefile
    """
    sfsession = ShareFileSession(SHAREFILE_OPTIONS)
    if not filepath:
        print('No file path')
        return False
    folder, filename = os.path.split(filepath) #won't work in lambda linux environ
    #TODO write routine to do the split
    parts = filepath.split('\\')
    filename = parts.pop()
    folder = '\\'.join(parts)
    print(f'folder {folder}\\n filename {filename}\\n filepath {filepath}')
    folder_item = sfsession.get_item_by_local_favorites_path(folder)
    if not folder_item:
        print(f'problem getting {folder}')
        return False
    try:
        sfsession.upload_file(folder_item.id, filename, fileobj)
        return True
    except Exception as e:
        print(e)
        return False
    
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