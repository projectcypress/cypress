CV_METHOD_CODES = ["OBSRV", "COUNT","SUM", "AVERAGE","STDEV.S","VARIANCE.S","STDEV.P","VARIANCE.P","MIN","MAX", "MEDIAN", "MODE"]
CV_POPULATION_CODE = QME::QualityReport::OBSERVATION

ISO_SCHEMATRON = 'resources/schematron/iso-schematron-xslt1/iso_svrl_for_xslt1.xsl'
QRDA_SCHEMA_VALIDATOR = Validators::Schema::Validator.new("CDA Schema validator", APP_CONFIG["validation"]["schema"])

SUPPLEMENTAL_DATA_MAPPING = {QME::QualityReport::RACE=> "2.16.840.1.113883.10.20.27.3.8", 
                             QME::QualityReport::ETHNICITY => "2.16.840.1.113883.10.20.27.3.7", 
                             QME::QualityReport::SEX => "2.16.840.1.113883.10.20.27.3.6",  
                             QME::QualityReport::PAYER => "2.16.840.1.113883.10.20.27.3.9"}
MEASURE_VALIDATORS = {}