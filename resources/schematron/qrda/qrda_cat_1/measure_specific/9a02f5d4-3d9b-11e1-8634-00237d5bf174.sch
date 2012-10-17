<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.600.1.18']">For QDT pattern 'Diagnosis, Active: Pregnancy', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.307']">For QDT pattern 'Encounter, Performed: Encounter Inpatient', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.35']">For QDT pattern 'Medication, Active: Beta Blocker', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.41</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.35']">For QDT pattern 'Medication, Administered: Beta Blocker', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.2.643']">For QDT pattern 'Patient Characteristic Clinical Trial Participant: Clinical Trial Participant', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.51</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.54'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.78']">For QDT pattern 'Patient Characteristic Expired: Patient Expired', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.54</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.46']">For QDT pattern 'Procedure, Performed: Heart Transplant And Ventricular-Assist-Device Procedure', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.2']">For QDT pattern 'Procedure, Performed: SCIP Major Surgical Procedure', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.55</assert>
		</rule>
	</pattern>
</schema>