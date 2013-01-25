<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.102.12.1011']">For QDT pattern 'Diagnosis, Active: Acute Pharyngitis', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.102.12.1011". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.102.12.1012']">For QDT pattern 'Diagnosis, Active: Acute Tonsillitis', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.102.12.1012". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.101.12.1061']">For QDT pattern 'Encounter, Performed: Ambulatory/ED Visit', QRDA template id "2.16.840.1.113883.10.20.24.3.23" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.101.12.1061". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.198.12.1012']">For QDT pattern 'Laboratory Test, Result: Group A Streptococcus Test', QRDA template id "2.16.840.1.113883.10.20.24.3.40" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.198.12.1012". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.196.12.1001']">For QDT pattern 'Medication, Active: Antibiotic Medications', QRDA template id "2.16.840.1.113883.10.20.24.3.41" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.196.12.1001". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.47'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.464.1003.196.12.1001']">For QDT pattern 'Medication, Order: Antibiotic Medications', QRDA template id "2.16.840.1.113883.10.20.24.3.47" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.464.1003.196.12.1001". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.114222.4.11.3591']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.114222.4.11.3591". </assert>
		</rule>
	</pattern>
</schema>