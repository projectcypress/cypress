<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.273']">For QDT pattern 'Diagnosis, Active: Full Term Delivery', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.67.1.101.1.273". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.269']">For QDT pattern 'Diagnosis, Active: Hepatitis B', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.67.1.101.1.269". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.13'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.269']">For QDT pattern 'Diagnosis, Inactive: Hepatitis B', QRDA template id "2.16.840.1.113883.10.20.24.3.13" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.67.1.101.1.269". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.38'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.279']">For QDT pattern 'Laboratory Test, Performed: HBsAg', QRDA template id "2.16.840.1.113883.10.20.24.3.38" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.67.1.101.1.279". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.67.1.101.1.278']">For QDT pattern 'Procedure, Performed: Delivery', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.67.1.101.1.278". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.114222.4.11.3591']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.114222.4.11.3591". </assert>
		</rule>
	</pattern>
</schema>