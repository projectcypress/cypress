<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.22']">For QDT pattern 'Care Goal: Arrangements for Follow-up Care', QRDA template id "2.16.840.1.113883.10.20.24.3.1" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.22". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.45']">For QDT pattern 'Care Goal: Environmental Control and Control of Other Triggers', QRDA template id "2.16.840.1.113883.10.20.24.3.1" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.45". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.44']">For QDT pattern 'Care Goal: Home Management Plan of Care Document', QRDA template id "2.16.840.1.113883.10.20.24.3.1" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.44". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.1'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.46']">For QDT pattern 'Care Goal: Methods and Timing of Rescue Actions', QRDA template id "2.16.840.1.113883.10.20.24.3.1" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.46". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.271']">For QDT pattern 'Diagnosis, Active: Asthma', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.271". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.23'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.23']">For QDT pattern 'Encounter, Performed: Inpatient Encounter', QRDA template id "2.16.840.1.113883.10.20.24.3.23" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.23". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.47']">For QDT pattern 'Medication, Active: Asthma Controllers', QRDA template id "2.16.840.1.113883.10.20.24.3.41" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.47". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.41'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.117.1.7.1.51']">For QDT pattern 'Medication, Active: Asthma Relievers', QRDA template id "2.16.840.1.113883.10.20.24.3.41" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.117.1.7.1.51". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.51'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.2.643']">For QDT pattern 'Patient Characteristic Clinical Trial Participant: Clinical Trial Participant', QRDA template id "2.16.840.1.113883.10.20.24.3.51" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.2.643". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.221.5". </assert>
		</rule>
	</pattern>
</schema>