<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.214']">For QDT pattern 'Device, Applied: Intermittent pneumatic compression devices (IPC)', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.7</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.230']">For QDT pattern 'Device, Applied: Venous foot pumps (VFP)', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.7</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.212']">For QDT pattern 'Diagnosis, Active: Hemorrhagic Stroke', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.247']">For QDT pattern 'Diagnosis, Active: Ischemic Stroke', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.11</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.293']">For QDT pattern 'Encounter, Performed: Emergency Department Visit', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.23']">For QDT pattern 'Encounter, Performed: Inpatient Encounter', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.31'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.02.1076']">For QDT pattern 'Intervention, Order: Palliative Care', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.31</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.02.1076']">For QDT pattern 'Intervention, Performed: Palliative Care', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.32</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.213']">For QDT pattern 'Laboratory Test, Result: INR', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.40</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.205']">For QDT pattern 'Medication, Administered: Direct Thrombin Inhibitor', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.211']">For QDT pattern 'Medication, Administered: Factor Xa Inhibitor', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.219']">For QDT pattern 'Medication, Administered: Low Molecular Weight Heparin', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.218']">For QDT pattern 'Medication, Administered: Unfractionated Heparin', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.42'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.232']">For QDT pattern 'Medication, Administered: Warfarin', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.42</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.2.643']">For QDT pattern 'Patient Characteristic Clinical Trial Participant: Clinical Trial Participant', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.51</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.55</assert>
		</rule>
	</pattern>
</schema>