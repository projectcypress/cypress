<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.1430']">For QDT pattern 'Diagnosis, Active: Burn Diagnosis Group', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.696']">For QDT pattern 'Diagnosis, Active: Hospital Measures - Any infection', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.695']">For QDT pattern 'Diagnosis, Active: Hospital Measures-Infection diagnosis', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.815']">For QDT pattern 'Diagnosis, Active: Hospital Measures-Transplant diagnosis', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.307']">For QDT pattern 'Encounter, Performed: Encounter Inpatient', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.816']">For QDT pattern 'Laboratory Test, Result: Hospital Measures-Glucose (SNOMED-CT)', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.40</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.1125']">For QDT pattern 'Patient Characteristic Clinical Trial Participant: Clinical Trial Participant', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.51</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.54'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.78']">For QDT pattern 'Patient Characteristic Expired: Patient Expired', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.54</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.3000']">For QDT pattern 'Procedure, Performed: Cardiac Surgery', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='1.3.6.1.4.1.33895.1.3.0.31']">For QDT pattern 'Procedure, Performed: Hospital Measures-Joint Commission Evidence of a surgical procedure requiring general or neuraxial anesthesia', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.55</assert>
		</rule>
	</pattern>
</schema>