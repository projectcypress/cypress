<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.490']">For QDT pattern 'Diagnosis, Active: Guillian-Barre syndrome', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.494']">For QDT pattern 'Diagnosis, Active: Latex anaphylaxis', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.307']">For QDT pattern 'Encounter, Performed: Encounter Inpatient', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.496']">For QDT pattern 'Medication, Administered: Influenza vaccine med', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.44'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.496']">For QDT pattern 'Medication, Allergy: Influenza vaccine med', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.44</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.336']">For QDT pattern 'Procedure, Performed: Bone marrow transplant', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.499']">For QDT pattern 'Procedure, Performed: Influenza vaccination administration group', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.357']">For QDT pattern 'Procedure, Performed: Organ transplant group', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.55</assert>
		</rule>
	</pattern>
</schema>