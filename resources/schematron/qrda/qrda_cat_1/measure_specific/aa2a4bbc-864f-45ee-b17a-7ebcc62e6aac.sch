<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.14'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.0003.08.02.0001']">For QDT pattern 'Diagnosis, Resolved: Malignant Neoplasm of Colon', QRDA template id "2.16.840.1.113883.10.20.24.3.14" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.0003.08.02.0001". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.0003.98.02.0011']">For QDT pattern 'Laboratory Test, Performed: Fecal Occult Blood Test (FOBT)', QRDA template id "2.16.840.1.113883.10.20.24.3.38" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.0003.98.02.0011". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.0003.08.02.0020']">For QDT pattern 'Procedure, Performed: Colonoscopy', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.0003.08.02.0020". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.0003.98.02.0010']">For QDT pattern 'Procedure, Performed: Flexible Sigmoidoscopy', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.0003.98.02.0010". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.0003.98.02.0019']">For QDT pattern 'Procedure, Performed: Total Colectomy', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.0003.98.02.0019". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.221.5". </assert>
		</rule>
	</pattern>
</schema>