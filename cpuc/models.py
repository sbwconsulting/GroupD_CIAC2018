from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import Float
from sqlalchemy import ForeignKey
from sqlalchemy import Index
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import Table
from sqlalchemy import Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.orm.session import object_session

Base = declarative_base()

class Study(Base):
    __tablename__ = 'studies'
    table_args = (Index('ix_study_name', 'name'), )

    id = Column(Integer, primary_key=True)
    name = Column(String(50), index=True, unique=True)

class Sample(Base):
    """
    Stores data for an individual sample (project-level). Keyed by
    SBW_ProjID. One-to-many relationship from Study to Sample via
    study_id.

    Instead of hard-coding an attribute on the model class for each
    field, fields are built from WORKBOOK_MAPPING, a list of tuples that
    contains three items:

        0. snake_case_field_name, a slightly more readable name than
           what is provided in CEDARS data and the workbooks
        1. Excel workbook field name
        2. sqlalchemy data type

    The second item in the tuple is used for the database field name.
    The first item in the tuple isn't currently used, and a fourth may
    be added later to hold the output field name for ATR files.
    """
    WORKBOOK_MAPPING = [
        # SITE INFORMATION worksheet
        ('program_administrator', 'PA', String(50)),
        ('service_account_name', 'ServiceAccountName', String(50)),
        ('site_address', 'SiteAddress', String(100)),
        ('site_city', 'SiteCity', String(50)),
        ('site_zip_code', 'SiteZipCode', String(10)),
        ('program_id', 'PrgID', String(50)),
        ('project_id', 'ProjectID', String(50)),
        ('claim_year_quarter', 'ClaimYearQuarter', String(10)),
        ('measure_application_type', 'MeasAppType', String(50)),
        ('e3_climate_zone', 'E3ClimateZone', String(50)),
        ('building_type', 'BldgType', String(50)),

        # ELIGIBILITY worksheet
        ('review_installation_date', 'RvwInstallDate', String(50)),
        ('review_application_installation_date', 'RvwAppVsInstallDate', String(50)),
        ('review_paid_incentive', 'RvwPaidIncentive', String(50)),
        ('review_permit', 'RvwPermit', String(50)),

        #Extra datafields
        ('HTR', 'HTR', String(10)),
        ('HTR_Documentation_File', 'HTR_Documentation_File', String(50)),
    ]

    __table__ = Table(
        'samples',
        Base.metadata,
        Column('id', Integer, primary_key=True),
        Column('study_id', Integer, ForeignKey('studies.id')),
        Column('SampleID', Integer, index=True, unique=True),
        Column('SBW_ProjID', String(50), index=True, unique=True),
        # Generate other columns dynamically from mapping.
        *(Column(field[1], field[2]) for field in WORKBOOK_MAPPING),
    )

    study = relationship('Study', back_populates='samples')

Study.samples = relationship(
    'Sample',
    order_by=Sample.SBW_ProjID,
    back_populates='study'
)

class Measure(Base):
    """
    Stores data for an individual measurement. Keyed by ClaimID.
    One-to-many relationship from Sample to Measure via SBW_ProjID.
    """
    WORKBOOK_MAPPING = [
        # MEASURES worksheet
        ('MeasDescription', 'MeasDescription', String(50)),
        ('RvwInstallDate', 'RvwInstallDate', String(50)),
        ('RvwAppVsInstallDate', 'RvwAppVsInstallDate', String(50)),
        ('RvwPaidIncentive', 'RvwPaidIncentive', String(50)),
        ('RvwPermit', 'RvwPermit', String(50)),
        ('RvwFuelSwitchTest', 'RvwFuelSwitchTest', String(50)),
        ('RvwCogenImpact', 'RvwCogenImpact', String(50)),
        ('RvwCodeRegs', 'RvwCodeRegs', String(50)),
        ('RvwISPMet', 'RvwISPMet', String(50)),
        ('RvwEffIncrease', 'RvwEffIncrease', String(50)),
        ('RvwMeasEUL', 'RvwMeasEUL', String(50)),
        ('MeasAppType', 'MeasAppType', String(50)),
        ('EUL_Yrs', 'EUL_Yrs', Float),
        ('RUL_Yrs', 'RUL_Yrs', Float),
        ('CalcGrosskW1stBaseline', 'CalcGrosskW1stBaseline', Float),
        ('CalcGrosskWh1stBaseline', 'CalcGrosskWh1stBaseline', Float),
        ('CalcGrossTherm1stBaseline', 'CalcGrossTherm1stBaseline', Float),
        ('CalcGrosskW2ndBaseline', 'CalcGrosskW2ndBaseline', Float),
        ('CalcGrosskWh2ndBaseline', 'CalcGrosskWh2ndBaseline', Float),
        ('CalcGrossTherm2ndBaseline', 'CalcGrossTherm2ndBaseline', Float),
        ('UseCategory', 'UseCategory', String(50)),
        ('UseSubCategory', 'UseSubCategory', String(50)),
        ('TechGroup', 'TechGroup', String(50)),
        ('TechType', 'TechType', String(50)),

        ('eval_initial_review_notes', 'EvalInitialRvwNotes', Text),
        ('eval_measure_description', 'EvalMeasDescription', Text),

        ('eval_ntgr_building_type', 'EvalNTGRBldgType', String(50)),
        ('eval_ntgr_building_vintage', 'EvalNTGRBldgVint', String(50)),
        ('eval_ntgr_sector', 'EvalNTGRSector', String(50)),
        ('eval_ntgr_measure_delivery', 'EvalNTGRMeasure_Delivery', String(50)),
        ('eval_ntgr_technology_group', 'EvalNTGRTechGroup', String(50)),
        ('eval_ntgr_technology_type', 'EvalNTGRTechType', String(50)),
        ('eval_ntgr_use_category', 'EvalNTGRUseCategory', String(50)),
        ('eval_ntgr_use_subcategory', 'EvalNTGRUseSubcategory', String(50)),

        ('eval_eul_building_type', 'EvalEULBldgType', String(50)),
        ('eval_eul_sector', 'EvalEULSector', String(50)),
        ('eval_eul_technology_group', 'EvalEULTechGroup', String(50)),
        ('eval_eul_technology_type', 'EvalEULTechType', String(50)),
        ('eval_eul_use_category', 'EvalEULUseCategory', String(50)),
        ('eval_eul_use_subcategory', 'EvalUseSubcategory', String(50)),
        ('eval_baseline_type', 'EvalBaselineType', String(50)),

        ('eval_ntg_decision_process', 'EvalNTGDecisionProcess', String(10)),       
        ('eval_ntg_project_initiation', 'EvalNTGProjectInitation', String(10)),
        ('eval_ntg_measure_identified', 'EvalNTGMeasureIdent', String(10)),
        ('eval_ntg_measure_options', 'EvalNTGMeasOptions', String(10)),
        ('eval_ntg_cost_energy_benefits', 'EvalNTGCostNRGBenefits', String(10)),
        ('eval_ntg_non_energy_benefits', 'EvalNTGNEBs', String(10)),
        ('eval_ntg_program_influence_timing', 'EvalNTGProgInfluenceTiming', String(10)),
        ('eval_ntg_cost_effectiveness', 'EvalNTGCostEffectiveness', String(10)),
        ('eval_ntg_other_influence', 'EvalNTGOtherInfluence', Text),

        ('eval_intermediate_review_notes', 'EvalIntermediateRvwNotes', Text),

        ('eval_base_2_kW_savings', 'EvalBase2kWSvgs', Float),
        ('eval_base_2_kW_reasons', 'EvalBase2kWReasons', String(50)),
        ('eval_base_2_kWh_savings', 'EvalBase2kWhSvgs', Float),
        ('eval_base_2_kWh_reasons', 'EvalBase2kWhReasons', String(50)),
        ('eval_base_2_therm_savings', 'EvalBase2ThermSvgs', Float),
        ('eval_base_2_therm_reasons', 'EvalBase2ThermReasons', String(50)),
        ('eval_base_1_kW_savings', 'EvalBase1kWSvgs', Float),
        ('eval_base_1_kW_reasons', 'EvalBase1kWReasons', String(50)),
        ('eval_base_1_kWh_savings', 'EvalBase1kWhSvgs', Float),
        ('eval_base_1_kWh_reasons', 'EvalBase1kWhReasons', String(50)),
        ('eval_base_1_therm_savings', 'EvalBase1ThermSvgs', Float),
        ('eval_base_1_therm_reasons', 'EvalBase1ThermReasons', String(50)),
        ('eval_final_review_notes', 'EvalFinalRvwNotes', Text),

        # ELIGIBILITY worksheet
        ('review_fuel_switch_test', 'RvwFuelSwitchTest', String(50)),
        ('review_cogen_impact', 'RvwCogenImpact', String(50)),
        ('review_code_regs', 'RvwCodeRegs', String(50)),
        ('review_isp_met', 'RvwISPMet', String(50)),
        ('review_efficiency_increase', 'RvwEffIncrease', String(50)),
        ('review_measure_EUL', 'RvwMeasEUL', String(50)),

        # Manage Assignemnts sheet in Program Assignemts 
        ('IneligibleMeasure', 'IneligibleMeasure', String(10)),
        ('NotEvaluable', 'NotEvaluable', String(10)),
        ('InsufficientTime', 'InsufficientTime', String(10)),
        ('DefaultGRR', 'DefaultGRR', Float),
        ('MissNoSupReq', 'MissNoSupReq', String(10)),
    
        # NTG, EUL and HTR workbooks
        ('EvalNTG_ID', 'EvalNTG_ID', String(50)),
        ('EvalNTG_kWH', 'EvalNTG_kWH', Float),
        ('EvalNTG_therms', 'EvalNTG_therms', Float),
        ('EvalEUL_ID', 'EvalEUL_ID', String(50)),
        ('EvalEUL_Yrs', 'EvalEUL_Yrs', Float),        
        ('EvalRUL_Yrs', 'EvalRUL_Yrs', Float),        

    ]

    __table__ = Table(
        'measures',
        Base.metadata,
        Column('id', Integer, primary_key=True),
        Column('SBW_ProjID', String(50), ForeignKey('samples.SBW_ProjID')),
        Column('ClaimID', String(50), index=True, unique=True),
        # Generate other columns dynamically from mapping.
        *(Column(field[1], field[2]) for field in WORKBOOK_MAPPING),
    )

    sample = relationship('Sample', back_populates='measures')

Sample.measures = relationship(
    'Measure',
    order_by=Measure.ClaimID,
    back_populates='sample'
)


class Logworkbook(Base):
    """
    Stores data on when workbooks were generated or read
    """
    LOG_WORKBOOK_MAPPING = [
        ('createdate', Text),
        ('version', Text),
        ('readdate', Text),
        ('readnotes', Text),
        ('logdate', Text),
 ]

    __table__ = Table(
        'log_workbook',
        Base.metadata,
        Column('filepath', Text, primary_key=True),
        # Generate other columns dynamically from mapping.
        *(Column(field[0], field[1]) for field in LOG_WORKBOOK_MAPPING),
    )

class cprSubmission(Base):
    """
    Stores data submitted by the PA's biweekly
    """
    SUBMISSION_MAPPING = [        
        ('COL_1', Text),
        ('COL_2', Text),
        ('COL_3', Date),
        ('COL_4', Text),
        ('COL_5', Text),
        ('COL_6', Text),
        ('COL_7', Text),
        ('COL_8', Text),
        ('COL_9', Text),
        ('COL_10', Text),
        ('COL_11', Date),
        ('COL_12', Text),
        ('COL_13', Text),
        ('COL_14', Date),
        ('COL_15', Text),
        ('COL_16', Text),
        ('COL_17', Text),
        ('COL_18', Text),
        ('COL_19', Text),
        ('COL_20', Text),
        ('COL_21', Text),
        ('COL_22', Text),
        ('COL_23', Text),
        ('COL_24', Text),
        ('COL_25', Text),
        ('COL_26', Text),
        ('COL_27', Text),
        ('COL_28', Text),
        ('COL_29', Text),
        ('COL_30', Text),
        ('COL_31', Text),
        ('COL_32', Text),
        ('COL_33', Text),
        ('COL_34', Text),
        ('COL_35', Float),
        ('COL_36', Float),
        ('COL_37', Float),
        ('COL_38', Text),
        ('COL_39', Float),
        ('COL_40', Float),
        ('COL_41', Text),
        ('srcfile', Text),
    ]

    __table__ = Table(
        'cpr_submissions_OLD',
        Base.metadata,
        Column('id', Integer, primary_key=True),        
        # Generate other columns dynamically from mapping.
        *(Column(field[0], field[1]) for field in SUBMISSION_MAPPING),
    )

class cprSubmission_shef(Base):
    # Stores data submitted by the PA's biweekly
    SUBMISSION_MAPPING = [        
        ('Comment_Only_Row', Text),
        ('PA', Text),
        ('Bi_Weekly_List_Submission_date_to_CPUC', Date),
        ('Program_ID', Text),
        ('Program_Name', Text),
        ('Program_Type', Text),
        ('Program_Implementer_Name', Text),
        ('Market_Sector', Text),
        ('Application_Number', Text),
        ('Project_ID', Text),
        ('Application_Executed_date', Date),
        ('Most_senior_status_as_of_bimonthly_submission', Text),
        ('Ready_for_CPUC_Staff_Selection', Text),
        ('Status_Change_Date', Date),
        ('Special_Projects_Designation', Text),
        ('Project_Name', Text),
        ('Measure_End_Use', Text),
        ('Measure_Types', Text),
        ('Measure_Codes', Text),
        ('Measure_Code_Description', Text),
        ('Project_Description', Text),
        ('Is_post_installation_measurement_required', Text),
        ('PA_Review_Engineer_Firm', Text),
        ('PA_Review_Engineer_Name', Text),
        ('PA_QC_Engineer_Reviewer_Firm', Text),
        ('PA_QC_Review_Engineer_Name', Text),
        ('PA_Application_Review_Date', Date),
        ('Project_Sponsor_or_Vendor_Company', Text),
        ('Customer_name', Text),
        ('Project_Street_Address', Text),
        ('Project_City', Text),
        ('PA_Implementation_Manager', Text),
        ('PA_Implementation_Manager_Email_Address', Text),
        ('PA_Customer_Account_Manager_Name', Text),
        ('Total_first_year_kW_Demand_Reduction', Float),
        ('Total_first_year_kWh_Savings', Float),
        ('Total_first_year_Therms_Savings', Float),
        ('Calculation_software_utilized', Text),
        ('Total_Incentive', Float),
        ('Project_Probability_Pct', Text),
        ('PA_special_request_to_CPUC_Staff', Text),
        ('srcfile', Text),
    ]

    __table__ = Table(
        'cpr_submissions',
        Base.metadata,
        Column('id', Integer, primary_key=True),        
        # Generate other columns dynamically from mapping.
        *(Column(field[0], field[1]) for field in SUBMISSION_MAPPING),
    )

class cprQuarterly(Base):
    # Stores Quarterly data submitted by the PA's
    SUBMISSION_MAPPING = [        
        ('application_id', Text),
        ('claimid', Text),
        ('pa', Text),
        ('market_sector', Text),
        ('special_project', Text),
        ('post_installation_measurement_required', Text),
        ('customer_name', Text),
        ('project_street_address', Text),
        ('project_city', Text),
        ('total_first_year_kw_demand_reduction', Float),
        ('total_first_year_kwh_savings', Float),
        ('total_first_year_therms_savings', Float),
        ('total_incentive', Float),
        ('measure_code', Text),
        ('current_status', Text),
        ('application_submitted_date', Date),
        ('pa_technical_review_complete_date', Date),
        ('Bimonthly_submission_date', Date),
        ('selected_for_review', Text),
        ('incentive_agreement_signed_date', Date),
        ('construction_complete_date', Date),
        ('post_installation_report_complete_date', Date),
        ('first_incentive_paid_date', Date),
        ('last_incentive_paid_date', Date),
        ('claimed_date', Date),
        ('project_withdrawn_date', Date),
        ('project_rejected_date', Date),
        ('probability', Text),
        ('program_id', Text),
        ('program_name', Text),
        ('program_type', Text),
        ('program_implementer', Text),
        ('pa_review_engineer_firm', Text),
        ('pa_review_engineer_name', Text),
        ('pa_qc_engineer_reviewer_firm', Text),
        ('pa_qc_review_engineer_name', Text),
        ('pa_implementation_manager', Text),
        ('pa_implementation_manager_email_address', Text),
        ('pa_customer_account_manager_name', Text),
        ('srcfile', Text),
    ]

    __table__ = Table(
        'cpr_quarterly',
        Base.metadata,
        Column('id', Integer, primary_key=True),        
        # Generate other columns dynamically from mapping.
        *(Column(field[0], field[1]) for field in SUBMISSION_MAPPING),
    )
