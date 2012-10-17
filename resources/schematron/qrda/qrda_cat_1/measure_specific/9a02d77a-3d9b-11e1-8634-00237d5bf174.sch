<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.16']">For QDT pattern 'Device, Applied: Hair Clipper', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.7</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.7'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.17']">For QDT pattern 'Device, Applied: Razor', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.7</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.666.5.307']">For QDT pattern 'Encounter, Performed: Encounter Inpatient', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.23</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.3']">For QDT pattern 'Intervention, Performed: Hair Removal', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.32</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.32'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.4']">For QDT pattern 'Intervention, Performed: Self Hair Removal', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.32</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.2.643']">For QDT pattern 'Patient Characteristic Clinical Trial Participant: Clinical Trial Participant', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.51</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.2']">For QDT pattern 'Procedure, Performed: SCIP Major Surgical Procedure', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.64</assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', the following QRDA template id SHOULD be present: 2.16.840.1.113883.10.20.24.3.55</assert>
		</rule>
	</pattern>
</schema>