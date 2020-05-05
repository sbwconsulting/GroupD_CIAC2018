import os.path

#from cpuc.sensitive import *

### Workbook paths and configuration
TMP_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    r'..\tmp',
)
CPUC10_PATH_ID = 'fob0f384-d037-4854-a0da-4181d7de6924'
DCF_PATH_ID = 'fofc19c2-16fc-43bb-bba3-971605a34145'
LOG_PATH_ID = 'fo12a508-87fb-4e29-92ee-89d21b526d18'
LOG_FILENAME_ROOT = 'aws_upload_wkb_'
LOG_TASK_FILENAME_ROOT = 'create_tasks_'
DELIVERABLES_PATH = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables'
DELIVERABLES_PATH_ID = 'fo3e6341-24f6-4513-980d-273d5433200b'
SAMPLES_PATH = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\5 Samples'
SAMPLES_PATH_ID = 'fo58a481-c096-40fe-af52-a9971b650017'
CONTROL_FILES_PATH = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\7 DCF'
SAMPLE_CONTROL_FILE = 'ProjectAssignments.xlsx'
NTG_FILE = 'NTGAssignments.xlsx'
EUL_FILE = 'EULAssignments.xlsx'
HTR_FILE = 'HTR_Reporting.xlsx'
TEMP_TRACKER_EXTENSION = '_tmp'
LOCAL_ROOT_PATH = 'C:\\tmp\\'

D0_DATABASE_REVIEW_FILE = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\00 - 2017 Evaluation\ESPI input prep\ATR_2017_All_Custom-Filled_v5.csv'
D0_DATABASE_REVIEW_EXTENDED_FILE = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\00 - 2017 Evaluation\Database Review\E350 Data Additions\Raw Data Files\Report Data DB Review.csv'
D0_ATR_SOURCE_FILE =  r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\00 - 2017 Evaluation\ESPI input prep\downloads\ATR\ATR_2017.csv'
D0_FIELD_CROSS_REF_FILE = r'Z:\Folders\Projects\CPUC10 (Group D - Custom EM&V)\4 Deliverables\00 - 2017 Evaluation\ESPI input prep\FieldNameCrossRef.xlsx'
CIAC_2018_DATA_DEF_FILE = r'Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\11 - Draft and Final Evaluation Reports\CIAC 2018\Design\DataSourceDef.xlsx'
CIAC_2018_PREFILL_DRIVER = r"Z:\Favorites\CPUC10 (Group D - Custom EM&V)\4 Deliverables\__ - Cross Cutting\Evaluation Tools\Site-Specific Tools\Treatment Templates\prefill_driver.xlsx"

WORKBOOK_TEMPLATES_PATH = os.path.join(
    DELIVERABLES_PATH,
    '__ - Cross Cutting',
    'Evaluation Tools',
    'Site-Specific Tools',
    'Treatment Templates',    
)

PROCESS_DEV_TEMPLATE_LIST_FILE = os.path.join(
    WORKBOOK_TEMPLATES_PATH,
    'ProcessDevTemplate.xlsm',
)

READ_WORKBOOKS_TEMPLATE_LIST_FILE = os.path.join(
    WORKBOOK_TEMPLATES_PATH,
    'ReadWorkbooks.xlsx',
)

INDEX_FILE = os.path.join(
    DELIVERABLES_PATH,
    '__ - Cross Cutting',
    'Evaluation Tools',
    'Site-Specific Tools',
    'Index',
    'Production',
    'Index.xlsm'
)

D0_WORKBOOK_TEMPLATES_PATH = os.path.join(
    DELIVERABLES_PATH,
    '__ - Cross Cutting',
    'Evaluation Tools',
    'Site-Specific Tools',
    'Treatment Templates',
    'ExPost2017',
    'Review',
    'Production',
)
TEMPLATE_WORKBOOK = os.path.join(
    WORKBOOK_TEMPLATES_PATH,
    'ExPost2017Review.xlsx',
)

REFERENCES_PATH = os.path.join(
    DELIVERABLES_PATH,
    r'__ - Cross Cutting\References',
)

SAMPLED_SITE_REVIEW_PATH = os.path.join(
    DELIVERABLES_PATH,
    r'00 - 2017 Evaluation\Sampled Site Review',
)

D0_REPORT_DATA_FILE = os.path.join(
    SAMPLED_SITE_REVIEW_PATH,
    r'evaldata.csv',
)

D0_ALL_DATA_FILE = os.path.join(
    SAMPLED_SITE_REVIEW_PATH,
    r'alldata.csv',
)

D0_DATA_DUMP_FILE = os.path.join(
    SAMPLED_SITE_REVIEW_PATH,
    r'datadump.csv',
)

D0_REPORT_STEPTABLE_DATA_FILE = os.path.join(
    SAMPLED_SITE_REVIEW_PATH,
    r'datawithsteps.csv',
)

### Claim data paths and configuration
D0_DELIVERABLES_PATH = os.path.join(
    DELIVERABLES_PATH,
    r'00 - 2017 Evaluation',
)

D0_DATA_PATH = os.path.join(
    DELIVERABLES_PATH,
    r'00 - 2017 Evaluation\Sample Design',
)

D0_ESPI_PATH = os.path.join(
    D0_DELIVERABLES_PATH,
    r'ESPI input prep',
)

D0_PADUMP_PATH = os.path.join(
    D0_DELIVERABLES_PATH,
    r'PAData',
)

D0_ATR_OUTPUT_FILE = os.path.join(
    D0_ESPI_PATH,
    r'ATR 2017 for Group A\\ATR_2017_All_Custom.csv',
)

D0_LOCAL_ATR_OUTPUT_FILE = os.path.join(
    D0_ESPI_PATH,
    r'finalatr.csv',
)

D0_DATA_FILE = os.path.join(
    D0_DATA_PATH,
    r'D0 sample frame - claim level (4-5-2019).csv',
)

D0_SAMPLES_ROOT = os.path.join(
    SAMPLES_PATH,
    r'ExPost2017',
)

SAMPLED_SITE_REVIEW_PATH = os.path.join(
    DELIVERABLES_PATH,
    r'00 - 2017 Evaluation',
    r'Sampled Site Review',
)

SAMPLE_ID_FIELD = 'SampleID'
SAMPLE_FLAG = 'sampled'
STUDY_TABLE = 'cpuc.d0tracking'
QUERY_SAMPLE_IDS = """
    SELECT {}, COUNT(claimid) AS count
    FROM {}
    GROUP BY {}
    ORDER BY count DESC;
""".format(
    SAMPLE_ID_FIELD,
    STUDY_TABLE,
    SAMPLE_ID_FIELD
)

MAIN_PALETTE = ["#4f81bd",
                    "#c0504d",
                    "#9bbb59",
                    "#8064a2",
                    "#4bacc6",
                    "#f79646",
                    "#1696d2",
                   ]