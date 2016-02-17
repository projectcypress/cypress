root_directory = File.join(__dir__, '..', '..', 'resources', 'schematron')
Validators::CmsQRDA3ChematronValidator =
  ::Validators::CMSSchematronValidator.new(File.join(root_directory,
                                                     'EP_CMS_2016_QRDA_Category_III_v2.sch'), 'CMS QRDA 3 Schematron Validator')
Validators::CmsQRDA1HQRChematronValidator =
  Validators::CMSSchematronValidator.new(File.join(root_directory,
                                                   'HQR_CMS_2016_QRDA_Category_I_v2.1_cypress_20160127.sch'), 'CMS QRDA 1 HQR Schematron Validator')
Validators::CmsQRDA1PQRSChematronValidator =
  Validators::CMSSchematronValidator.new(File.join(root_directory,
                                                   'PQRS_CMS_2016_QRDA_Category_I_v2.1_cypress_20160127.sch'), 'CMS QRDA 1 PQRS Schematron Validator')
