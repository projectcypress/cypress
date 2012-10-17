<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://purl.oclc.org/dsdl/schematron C:/Users/rickg/workspaces-svn/ClientProjects/QRDATesting/measure-specific-schematron/schematron.xsd">
	<ns uri="urn:hl7-org:v3" prefix="cda"/>
	<ns uri="urn:hl7-org:sdtc" prefix="sdtc"/>
	<phase id="warnings">
		<active pattern="p"/>
	</phase>
	<pattern id="p">
		<rule context="/cda:ClinicalDocument">
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.451']">For QDT pattern 'Diagnosis, Active: Pain Related to Prostate Cancer', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.451". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.319']">For QDT pattern 'Diagnosis, Active: Prostate Cancer', QRDA template id "2.16.840.1.113883.10.20.24.3.11" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.319". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.17'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.320']">For QDT pattern 'Diagnostic Study, Order: Bone Scan', QRDA template id "2.16.840.1.113883.10.20.24.3.17" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.320". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.18'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.320']">For QDT pattern 'Diagnostic Study, Performed: Bone Scan', QRDA template id "2.16.840.1.113883.10.20.24.3.18" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.320". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.397']">For QDT pattern 'Laboratory Test, Result: Gleason Score', QRDA template id "2.16.840.1.113883.10.20.24.3.40" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.397". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.40'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.401']">For QDT pattern 'Laboratory Test, Result: Prostate Specific Antigen Test', QRDA template id "2.16.840.1.113883.10.20.24.3.40" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.401". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.398']">For QDT pattern 'Procedure, Performed: Prostate Cancer Treatment', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.398". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.64'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.399']">For QDT pattern 'Procedure, Performed: Salvage Therapy', QRDA template id "2.16.840.1.113883.10.20.24.3.64" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.399". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.66'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.3.526.03.1098']">For QDT pattern 'Procedure, Result: Clinical Staging Procedure', QRDA template id "2.16.840.1.113883.10.20.24.3.66" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.3.526.03.1098". </assert>
			<assert test="//*[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55'][descendant::*/@sdtc:valueSet='2.16.840.1.113883.221.5']">For QDT pattern 'Patient Characteristic Payer: Payer', QRDA template id "2.16.840.1.113883.10.20.24.3.55" SHOULD be present and SHOULD be bound to value set "2.16.840.1.113883.221.5". </assert>
		</rule>
	</pattern>
</schema>