<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='1.3.6.1.4.1.33895.1.3.0.42']">For QDT pattern 'Diagnosis, Active: Hospital Measures-Joint Commission Mental Disorders', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "1.3.6.1.4.1.33895.1.3.0.42". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.900']">For QDT pattern 'Encounter, Performed: Hospital Measures - Encounter ED', QRDA template id "2.16.840.1.113883.10.20.24.3.23" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.666.5.900". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.625']">For QDT pattern 'Encounter, Performed: Hospital Measures-Encounter Inpatient', QRDA template id "2.16.840.1.113883.10.20.24.3.23" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.666.5.625". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.82'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.3013']">For QDT pattern 'Transfer To: Hospital Measures-Acute care hospital', QRDA template id "2.16.840.1.113883.10.20.24.3.82" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.666.5.3013". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.82'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.754']">For QDT pattern 'Transfer To: Hospital Measures-Observation status', QRDA template id "2.16.840.1.113883.10.20.24.3.82" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.666.5.754". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.114222.4.11.3591']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.114222.4.11.3591". </assert>
		</rule>
	</pattern>
</schema>