<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<sch:schema xmlns:voc="http://www.lantanagroup.com/voc" xmlns:svs="urn:ihe:iti:svs:2008"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cda="urn:hl7-org:v3"
  xmlns="urn:hl7-org:v3" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
  <sch:ns prefix="voc" uri="http://www.lantanagroup.com/voc"/>
  <sch:ns prefix="svs" uri="urn:ihe:iti:svs:2008"/>
  <sch:ns prefix="xsi" uri="http://www.w3.org/2001/XMLSchema-instance"/>
  <sch:ns prefix="cda" uri="urn:hl7-org:v3"/>
  <sch:phase id="errors">
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.1.1-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.2-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.2.1-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.3-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.2-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.4-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.5-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.98-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.1-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.10-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.55-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.9-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.8-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.7-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.6-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.11-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.12-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.1-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.2.2-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.14-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.15-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.5.2-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.5.1.1-errors"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.3.8-errors"/>
  </sch:phase>
  <sch:phase id="warnings">
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.1.1-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.2.2-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.2.1-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.3-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.2-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.4-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.5-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.98-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.1-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.10-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.24.3.55-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.9-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.8-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.7-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.6-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.11-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.12-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.2.1-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.2.2-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.14-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.27.3.15-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.5.2-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.22.5.1.1-warnings"/>
    <sch:active pattern="p-2.16.840.1.113883.10.20.17.3.8-warnings"/>
  </sch:phase>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.1.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.1.1-errors-abstract" abstract="true">
      <sch:assert id="a-17210"
        test="count(cda:code[@code='55184-6'][@codeSystem='2.16.840.1.113883.6.1'])=1">SHALL contain
        exactly one [1..1] code="55184-6" Quality Reporting Document Architecture Calculated Summary
        Report (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:17210).</sch:assert>
      <sch:assert id="a-17211" test="count(cda:title)=1">SHALL contain exactly one [1..1] title
        (CONF:17211).</sch:assert>
      <sch:assert id="a-17212" test="count(cda:recordTarget)=1">QRDA III is an aggregate summary
        report. Therefore CDA's required recordTarget/id is nulled. The recordTarget element is
        designed for single patient data and is required in all CDA documents. In this case, the
        document does not contain results for a single patient, but rather for groups of patients,
        and thus the recordTarget ID in QRDA Category III documents contains a nullFlavor attribute
        (is nulled). SHALL contain exactly one [1..1] recordTarget (CONF:17212).</sch:assert>
      <sch:assert id="a-17213" test="count(cda:custodian)=1">SHALL contain exactly one [1..1]
        custodian (CONF:17213).</sch:assert>
      <sch:assert id="a-17214" test="cda:custodian[count(cda:assignedCustodian)=1]">This custodian
        SHALL contain exactly one [1..1] assignedCustodian (CONF:17214).</sch:assert>
      <sch:assert id="a-17215"
        test="cda:custodian/cda:assignedCustodian[count(cda:representedCustodianOrganization)=1]"
        >This assignedCustodian SHALL contain exactly one [1..1] representedCustodianOrganization
        (CONF:17215).</sch:assert>
      <sch:assert id="a-17217" test="count(cda:component)=1">A QRDA Category III document contains a
        Reporting Parameters Section and a Measure section. SHALL contain exactly one [1..1]
        component (CONF:17217).</sch:assert>
      <sch:assert id="a-17225" test="count(cda:legalAuthenticator)=1">SHALL contain exactly one
        [1..1] legalAuthenticator (CONF:17225).</sch:assert>
      <sch:assert id="a-17226" test="count(cda:realmCode)=1">SHALL contain exactly one [1..1]
        realmCode (CONF:17226).</sch:assert>
      <sch:assert id="a-17227" test="cda:realmCode[@code='US']">This realmCode SHALL contain exactly
        one [1..1] @code="US" (CONF:17227).</sch:assert>
      <sch:assert id="a-17233" test="cda:recordTarget[count(cda:patientRole[count(cda:id)=1])=1]"
        >This recordTarget SHALL contain exactly one [1..1] patientRole (CONF:17232) such that it
        SHALL contain exactly one [1..1] id (CONF:17233).</sch:assert>
      <sch:assert id="a-17234" test="cda:recordTarget/cda:patientRole/cda:id[@nullFlavor='NA']">This
        id SHALL contain exactly one [1..1] @nullFlavor="NA" (CONF:17234).</sch:assert>
      <sch:assert id="a-17235" test="cda:component[count(cda:structuredBody)=1]">This component
        SHALL contain exactly one [1..1] structuredBody (CONF:17235).</sch:assert>
      <sch:assert id="a-17236" test="count(cda:id)=1">SHALL contain exactly one [1..1] id
        (CONF:17236).</sch:assert>
      <sch:assert id="a-17237" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1]
        effectiveTime (CONF:17237).</sch:assert>
      <sch:assert id="a-17238"
        test="count(cda:confidentialityCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.16926']/svs:ConceptList/svs:Concept/@code])=1"
        >SHALL contain exactly one [1..1] confidentialityCode, which SHOULD be selected from
        ValueSet HL7 BasicConfidentialityKind 2.16.840.1.113883.1.11.16926 STATIC 2010-04-21
        (CONF:17238).</sch:assert>
      <sch:assert id="a-17239" test="count(cda:languageCode)=1">SHALL contain exactly one [1..1]
        languageCode, which SHALL be selected from ValueSet Language 2.16.840.1.113883.1.11.11526
        DYNAMIC (CONF:17239).</sch:assert>
      <sch:assert id="a-17282"
        test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2'])=1])=1]"
        >This structuredBody SHALL contain exactly one [1..1] component (CONF:17281) such that it
        SHALL contain exactly one [1..1] QRDA Category III Reporting Parameters Section
        (templateId:2.16.840.1.113883.10.20.27.2.2) (CONF:17282).</sch:assert>
      <sch:assert id="a-17301"
        test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1'])=1])=1]"
        >This structuredBody SHALL contain exactly one [1..1] component (CONF:17283) such that it
        SHALL contain exactly one [1..1] QRDA Category III Measure Section
        (templateId:2.16.840.1.113883.10.20.27.2.1) (CONF:17301).</sch:assert>
      <sch:assert id="a-18158"
        test="count(cda:author[count(cda:assignedAuthor)=1][count(cda:time)=1]) &gt; 0">SHALL
        contain at least one [1..*] author (CONF:18156) such that it SHALL contain exactly one
        [1..1] time (CONF:18158).</sch:assert>
      <sch:assert id="a-18163"
        test="count(cda:author[count(cda:time)=1][count(cda:assignedAuthor[count(cda:assignedAuthoringDevice) &lt; 2][count(cda:assignedPerson) &lt; 2][count(cda:representedOrganization)=1])=1]) &gt; 0"
        >SHALL contain at least one [1..*] author (CONF:18156) such that it SHALL contain exactly
        one [1..1] assignedAuthor (CONF:18157) such that it SHALL contain exactly one [1..1]
        representedOrganization (CONF:18163).</sch:assert>
      <sch:assert id="a-18165"
        test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:id) &gt; 0]"
        >This representedCustodianOrganization SHALL contain at least one [1..*] id
        (CONF:18165).</sch:assert>
      <sch:assert id="a-18167" test="cda:legalAuthenticator[count(cda:time)=1]">This
        legalAuthenticator SHALL contain exactly one [1..1] time (CONF:18167).</sch:assert>
      <sch:assert id="a-18168" test="cda:legalAuthenticator[count(cda:signatureCode)=1]">This
        legalAuthenticator SHALL contain exactly one [1..1] signatureCode (CONF:18168).</sch:assert>
      <sch:assert id="a-18169" test="cda:legalAuthenticator/cda:signatureCode[@code='S']">This
        signatureCode SHALL contain exactly one [1..1] @code="S" (CONF:18169).</sch:assert>
      <sch:assert id="a-18171"
        test="not(cda:documentationOf) or cda:documentationOf[count(cda:serviceEvent)=1]">The
        documentationOf, if present, SHALL contain exactly one [1..1] serviceEvent
        (CONF:18171).</sch:assert>
      <sch:assert id="a-18172"
        test="not(cda:documentationOf/cda:serviceEvent) or cda:documentationOf/cda:serviceEvent[@classCode='PCPR']"
        >This serviceEvent SHALL contain exactly one [1..1] @classCode="PCPR" Care Provision
        (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:18172).</sch:assert>
      <sch:assert id="a-18173"
        test="not(cda:documentationOf/cda:serviceEvent) or cda:documentationOf/cda:serviceEvent[count(cda:performer) &gt; 0]"
        >This serviceEvent SHALL contain at least one [1..*] performer (CONF:18173).</sch:assert>
      <sch:assert id="a-18174"
        test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or cda:documentationOf/cda:serviceEvent/cda:performer[@typeCode='PRF']"
        >Such performers SHALL contain exactly one [1..1] @typeCode="PRF" Performer (CodeSystem:
        HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:18174).</sch:assert>
      <sch:assert id="a-18176"
        test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or cda:documentationOf/cda:serviceEvent/cda:performer[count(cda:assignedEntity)=1]"
        >Such performers SHALL contain exactly one [1..1] assignedEntity (CONF:18176).</sch:assert>
      <sch:assert id="a-18180"
        test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:representedOrganization)=1]"
        >This assignedEntity SHALL contain exactly one [1..1] representedOrganization
        (CONF:18180).</sch:assert>
      <sch:assert id="a-18182"
        test="cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:id[@root='2.16.840.1.113883.4.2']) &lt; 2]"
        >This representedOrganization id/@root coupled with the id/@extension can be used to
        represent the organization's Tax Identification Number (TIN). Other representedOrganization
        ids may be present. This representedOrganization MAY contain zero or one [0..1] id
        (CONF:18181) such that it SHALL contain exactly one [1..1] @extension (CONF:18190). SHALL
        contain exactly one [1..1] @root="2.16.840.1.113883.4.2" Tax ID Number
        (CONF:18182).</sch:assert>
      <sch:assert id="a-18184"
        test="cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:id[@root='2.16.840.1.113883.4.336']) &lt; 2]"
        >This representedOrganization id/@root coupled with the id/@extension represents the
        organization's Facility CMS Certification Number (CCN). Other representedOrganization ids
        may be present. This representedOrganization MAY contain zero or one [0..1] id (CONF:18183)
        such that it SHALL contain exactly one [1..1] @extension (CONF:18185). SHALL contain exactly
        one [1..1] @root="2.16.840.1.113883.4.336" Facility CMS Certification Number
        (CONF:18184).</sch:assert>
      <sch:assert id="a-18185"
        test="cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:id[@root='2.16.840.1.113883.4.336' and @extension]) &lt; 2]"
        >This representedOrganization id/@root coupled with the id/@extension represents the
        organization's Facility CMS Certification Number (CCN). Other representedOrganization ids
        may be present. This representedOrganization MAY contain zero or one [0..1] id (CONF:18183)
        such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.4.336" Facility CMS
        Certification Number (CONF:18184). SHALL contain exactly one [1..1] @extension
        (CONF:18185).</sch:assert>
      <sch:assert id="a-18186" test="count(cda:typeId)=1">SHALL contain exactly one [1..1] typeId
        (CONF:18186).</sch:assert>
      <sch:assert id="a-18187" test="cda:typeId[@root='2.16.840.1.113883.1.3']">This typeId SHALL
        contain exactly one [1..1] @root="2.16.840.1.113883.1.3" (CONF:18187).</sch:assert>
      <sch:assert id="a-18188" test="cda:typeId[@extension='POCD_HD000040']">This typeId SHALL
        contain exactly one [1..1] @extension="POCD_HD000040" (CONF:18188).</sch:assert>
      <sch:assert id="a-18190"
        test="cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[count(cda:id[@root='2.16.840.1.113883.4.2' and @extension]) &lt; 2]"
        >This representedOrganization id/@root coupled with the id/@extension can be used to
        represent the organization's Tax Identification Number (TIN). Other representedOrganization
        ids may be present. This representedOrganization MAY contain zero or one [0..1] id
        (CONF:18181) such that it SHALL contain exactly one [1..1] @root="2.16.840.1.113883.4.2" Tax
        ID Number (CONF:18182). SHALL contain exactly one [1..1] @extension
        (CONF:18190).</sch:assert>
      <sch:assert id="a-18262"
        test="not(cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson]) or cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson][count(cda:softwareName)=1]"
        >The assignedAuthoringDevice, if present, SHALL contain exactly one [1..1] softwareName
        (CONF:18262).</sch:assert>
      <sch:assert id="a-18265"
        test="cda:author/cda:assignedAuthor/cda:representedOrganization[count(cda:name) &lt; 2]"
        >This representedOrganization SHALL contain at least one [1..*] name
        (CONF:18265).</sch:assert>
      <sch:assert id="a-18302"
        test="not(cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]) or cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]"
        >The generic participant with a participationType of device and an associatedEntity class
        code of RGPR (regulated product) is used to represent Electronic Health Record (EHR)
        government agency certification identifiers. MAY contain zero or more [0..*] participant
        (CONF:18300) such that it SHALL contain exactly one [1..1] @typeCode="DEV" device
        (CodeSystem: HL7ParticipationType 2.16.840.1.113883.5.90 STATIC) (CONF:18301). SHALL contain
        exactly one [1..1] associatedEntity (CONF:18302).</sch:assert>
      <sch:assert id="a-18303"
        test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or cda:participant[@typeCode='DEV']/cda:associatedEntity[@classCode='RGPR']"
        >This associatedEntity SHALL contain exactly one [1..1] @classCode="RGPR" regulated product
        (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:18303).</sch:assert>
      <sch:assert id="a-18308"
        test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:code)=1]"
        >This associatedEntity SHALL contain exactly one [1..1] code (CONF:18308).</sch:assert>
      <sch:assert id="a-18309"
        test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code) or cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code[@code='129465004' and @codeSystem='2.16.840.1.113883.6.96']"
        >This code SHALL contain exactly one [1..1] @code="129465004" medical record, device
        (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC) (CONF:18309).</sch:assert>
      <sch:assert id="a-18360"
        test="not(cda:authorization) or cda:authorization[count(cda:consent)=1]">The authorization,
        if present, SHALL contain exactly one [1..1] consent (CONF:18360).</sch:assert>
      <sch:assert id="a-18361"
        test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:id)=1]"
        >The consent/id is the identifier of the consent given by the eligible provider. This
        consent SHALL contain exactly one [1..1] id (CONF:18361).</sch:assert>
      <sch:assert id="a-18363"
        test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:code[@code='425691002'][@codeSystem='2.16.840.1.113883.6.96'])=1]"
        >This consent SHALL contain exactly one [1..1] code="425691002" consent given for electronic
        record sharing (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC)
        (CONF:18363).</sch:assert>
      <sch:assert id="a-18364"
        test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:statusCode[@code='completed'])=1]"
        >This consent SHALL contain exactly one [1..1] statusCode="completed"
        (CONF:18364).</sch:assert>
      <sch:assert id="a-19443" test="cda:legalAuthenticator[count(cda:assignedEntity)=1]">This
        legalAuthenticator SHALL contain exactly one [1..1] assignedEntity
        (CONF:19443).</sch:assert>
      <sch:assert id="a-19444"
        test="cda:legalAuthenticator/cda:assignedEntity[count(cda:id) &gt; 0]">This assignedEntity
        SHALL contain at least one [1..*] id (CONF:19444).</sch:assert>
      <sch:assert id="a-19447"
        test="cda:legalAuthenticator/cda:assignedEntity[count(cda:addr) &gt; 0]"
        >This assignedEntity SHALL contain at least one [1..*] US Realm Address (AD.US.FIELDED)
        (templateId:2.16.840.1.113883.10.20.22.5.2) (CONF:19447).</sch:assert>
      <sch:assert id="a-19448"
        test="cda:legalAuthenticator/cda:assignedEntity[count(cda:telecom) &gt; 0]">This
        assignedEntity SHALL contain at least one [1..*] telecom (CONF:19448).</sch:assert>
      <sch:assert id="a-19450"
        test="cda:legalAuthenticator/cda:assignedEntity[count(cda:assignedPerson)=1]">This
        assignedEntity SHALL contain exactly one [1..1] assignedPerson (CONF:19450).</sch:assert>
      <sch:assert id="a-19451"
        test="cda:legalAuthenticator/cda:assignedEntity/cda:assignedPerson[count(cda:name) &gt; 0]"
        >This assignedPerson SHALL contain at least one [1..*] US Realm Person Name (PN.US.FIELDED)
        (templateId:2.16.840.1.113883.10.20.22.5.1.1) (CONF:19451).</sch:assert>
      <sch:assert id="a-19474"
        test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]"
        >This assignedEntity SHALL contain at least one [1..*] id (CONF:19474).</sch:assert>
      <!--No schematron defined for primitive constraint 19512 on template 1145-->
      <sch:assert id="a-19512" test="(cda:author/cda:assignedAuthor/cda:assignedAuthoringDevice) or (cda:author/cda:assignedAuthor/cda:assignedPerson)">There SHALL be at least one
        author/assignedAuthor/assignedPerson and/or at least one
        author/assignedAuthor/assignedAuthoringDevice.</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.1.1-errors"
      context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.1.1-errors-abstract"/>
      <sch:assert id="a-17209"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.1.1'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:17208) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.1.1" (CONF:17209).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.2-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract" abstract="true">
      <sch:assert id="a-12798" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:12798).</sch:assert>
      <sch:assert id="a-12799"
        test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='measure section'])=1"
        >SHALL contain exactly one [1..1] title="Measure Section" (CONF:12799).</sch:assert>
      <sch:assert id="a-12800" test="count(cda:text)=1">SHALL contain exactly one [1..1] text
        (CONF:12800).</sch:assert>
      <sch:assert id="a-16677"
        test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1]) &gt; 0"
        >SHALL contain at least one [1..*] entry (CONF:13003) such that it SHALL contain exactly one
        [1..1] Measure Reference (templateId:2.16.840.1.113883.10.20.24.3.98)
        (CONF:16677).</sch:assert>
      <sch:assert id="a-19230"
        test="cda:code[@code='55186-1' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL
        contain exactly one [1..1] @code="55186-1" Measure Section (CodeSystem: LOINC
        2.16.840.1.113883.6.1 STATIC) (CONF:19230).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-errors"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract"/>
      <sch:assert id="a-12802"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.2'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:12801) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.2.2" (CONF:12802).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.2.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.1-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-errors-abstract"/>
      <sch:assert id="a-17907"
        test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1'])=1]) &gt; 0"
        >SHALL contain at least one [1..*] entry (CONF:17906) such that it SHALL contain exactly one
        [1..1] Measure Reference and Results (templateId:2.16.840.1.113883.10.20.27.3.1)
        (CONF:17907).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.1-errors"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.2.1-errors-abstract"/>
      <sch:assert id="a-17285"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.1'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:17284) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.2.1" (CONF:17285).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.3-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.3-errors-abstract" abstract="true">
      <sch:assert id="a-17563" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17563).</sch:assert>
      <sch:assert id="a-17564" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17564).</sch:assert>
      <sch:assert id="a-17566" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:17566).</sch:assert>
      <sch:assert id="a-17567" test="count(cda:value[@xsi:type='INT'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="INT" (CONF:17567).</sch:assert>
      <sch:assert id="a-17568" test="cda:value[@value]">This value SHALL contain exactly one [1..1]
        @value (CONF:17568).</sch:assert>
      <sch:assert id="a-18393"
        test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The
        referenceRange, if present, SHALL contain exactly one [1..1] observationRange
        (CONF:18393).</sch:assert>
      <sch:assert id="a-18394"
        test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='INT'])=1]"
        >This observationRange SHALL contain exactly one [1..1] value with @xsi:type="INT"
        (CONF:18394).</sch:assert>
      <sch:assert id="a-19508"
        test="cda:code[@code='MSRAGG' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL
        contain exactly one [1..1] @code="MSRAGG" rate aggregation (CodeSystem: ActCode
        2.16.840.1.113883.5.4) (CONF:19508).</sch:assert>
      <sch:assert id="a-19509" test="count(cda:methodCode)=1">SHALL contain exactly one [1..1]
        methodCode (CONF:19509).</sch:assert>
      <sch:assert id="a-19510" test="cda:methodCode[@code='COUNT']">This methodCode SHALL contain
        exactly one [1..1] @code="COUNT" Count (CodeSystem: ObservationMethod
        2.16.840.1.113883.5.84) (CONF:19510).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.3-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.3-errors-abstract"/>
      <sch:assert id="a-18095"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.3'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:17565) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.3" (CONF:18095).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.2-errors-abstract" abstract="true">
      <sch:assert id="a-17569" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17569).</sch:assert>
      <sch:assert id="a-17570" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17570).</sch:assert>
      <sch:assert id="a-17571" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:17571).</sch:assert>
      <sch:assert id="a-17572" test="count(cda:value)=1">SHALL contain exactly one [1..1] value
        (CONF:17572).</sch:assert>
      <sch:assert id="a-18242"
        test="count(cda:methodCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.20450']/svs:ConceptList/svs:Concept/@code])=1"
        >SHALL contain exactly one [1..1] methodCode, which SHALL be selected from ValueSet
        ObservationMethodAggregate 2.16.840.1.113883.1.11.20450 STATIC (CONF:18242).</sch:assert>
      <sch:assert id="a-18243" test="count(cda:reference)=1">SHALL contain exactly one [1..1]
        reference (CONF:18243).</sch:assert>
      <sch:assert id="a-18244" test="cda:reference[count(cda:externalObservation)=1]">This reference
        SHALL contain exactly one [1..1] externalObservation (CONF:18244).</sch:assert>
      <sch:assert id="a-18245" test="cda:reference/cda:externalObservation[count(cda:id)=1]">This
        externalObservation SHALL contain exactly one [1..1] id (CONF:18245).</sch:assert>
      <sch:assert id="a-18390"
        test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The
        referenceRange, if present, SHALL contain exactly one [1..1] observationRange
        (CONF:18390).</sch:assert>
      <sch:assert id="a-18391"
        test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value)=1]"
        >This observationRange SHALL contain exactly one [1..1] value (CONF:18391).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.2-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.2-errors-abstract"/>
      <sch:assert id="a-18097"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.2'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:18096) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.2" (CONF:18097).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.4-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.4-errors-abstract" abstract="true">
      <sch:assert id="a-17575" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17575).</sch:assert>
      <sch:assert id="a-17576" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17576).</sch:assert>
      <sch:assert id="a-17577" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:17577).</sch:assert>
      <sch:assert id="a-17578"
        test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL
        contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode
        2.16.840.1.113883.5.4 STATIC) (CONF:17578).</sch:assert>
      <sch:assert id="a-17579" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:17579).</sch:assert>
      <sch:assert id="a-17584"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:17581) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" (CONF:17582). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:17583). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:17584).</sch:assert>
      <sch:assert id="a-18201" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18201).</sch:assert>
      <sch:assert id="a-18204" test="count(cda:reference)=1">SHALL contain exactly one [1..1]
        reference (CONF:18204).</sch:assert>
      <sch:assert id="a-18205" test="cda:reference[@typeCode='REFR']">This reference SHALL contain
        exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18205).</sch:assert>
      <sch:assert id="a-18206" test="cda:reference[count(cda:externalObservation)=1]">This reference
        SHALL contain exactly one [1..1] externalObservation (CONF:18206).</sch:assert>
      <sch:assert id="a-18207" test="cda:reference/cda:externalObservation[count(cda:id)=1]">If this
        reference is to an eMeasure, this id equals the referenced stratification id defined in the
        eMeasure. This externalObservation SHALL contain exactly one [1..1] id
        (CONF:18207).</sch:assert>
      <sch:assert id="a-19513"
        test="not(cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]) or cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:19511) such that it SHALL contain
        exactly one [1..1] Continuous Variable Measure Value
        (templateId:2.16.840.1.113883.10.20.27.3.2) (CONF:19513).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.4-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.4-errors-abstract"/>
      <sch:assert id="a-18094"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.4'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:18093) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.4" (CONF:18094).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.5-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.5-errors-abstract" abstract="true">
      <sch:assert id="a-17615" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17615).</sch:assert>
      <sch:assert id="a-17616" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17616).</sch:assert>
      <sch:assert id="a-17617" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:17617).</sch:assert>
      <sch:assert id="a-17618" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHOULD be selected from ValueSet
        ObservationPopulationInclusion 2.16.840.1.113883.1.11.20369 DYNAMIC
        (CONF:17618).</sch:assert>
      <sch:assert id="a-17620"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:17619) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" (CONF:17910). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:17911). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:17620).</sch:assert>
      <sch:assert id="a-17912" test="count(cda:templateId)=1">SHALL contain exactly one [1..1]
        templateId (CONF:17912).</sch:assert>
      <sch:assert id="a-17920"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:17918) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CONF:17919). SHALL contain exactly one [1..1] Reporting
        Stratum (templateId:2.16.840.1.113883.10.20.27.3.4) (CONF:17920).</sch:assert>
      <sch:assert id="a-18138"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:18136) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18137). SHALL contain exactly one [1..1] Sex
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.6)
        (CONF:18138).</sch:assert>
      <sch:assert id="a-18149"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:18139) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18144). SHALL contain exactly one [1..1] Ethnicity
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.7)
        (CONF:18149).</sch:assert>
      <sch:assert id="a-18150"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:18140) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18145). SHALL contain exactly one [1..1] Race
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.8)
        (CONF:18150).</sch:assert>
      <sch:assert id="a-18151"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:18141) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18146). SHALL contain exactly one [1..1] Payer
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.9)
        (CONF:18151).</sch:assert>
      <sch:assert id="a-18152"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1]"
        >MAY contain zero or more [0..*] entryRelationship (CONF:18142) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18147). SHALL contain exactly one [1..1] Postal Code
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.10)
        (CONF:18152).</sch:assert>
      <sch:assert id="a-18153"
        test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"
        >If observation/value/@code="MSRPOPL" then the following entryRelationship SHALL be present.
        MAY contain zero or more [0..*] entryRelationship (CONF:18143) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18148). SHALL contain exactly one [1..1] Continuous
        Variable Measure Value (templateId:2.16.840.1.113883.10.20.27.3.2)
        (CONF:18153).</sch:assert>
      <sch:assert id="a-18198"
        test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']">This code SHALL
        contain exactly one [1..1] @code="ASSERTION" Assertion (CodeSystem: ActCode
        2.16.840.1.113883.5.4 STATIC) (CONF:18198).</sch:assert>
      <sch:assert id="a-18199" test="count(cda:statusCode[@code='completed'])=1">SHALL contain
        exactly one [1..1] statusCode="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18199).</sch:assert>
      <sch:assert id="a-18240" test="count(cda:reference[count(cda:externalObservation)=1])=1">SHALL
        contain exactly one [1..1] reference (CONF:18239) such that it SHALL contain exactly one
        [1..1] externalObservation (CONF:18240).</sch:assert>
      <sch:assert id="a-18241" test="cda:reference/cda:externalObservation[count(cda:id)=1]">This
        externalObservation SHALL contain exactly one [1..1] id (CONF:18241).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.5-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.5-errors-abstract"/>
      <sch:assert id="a-17913" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.5']">This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.5"
        (CONF:17913).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.98-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract" abstract="true">
      <sch:assert id="a-12979" test="@classCode='CLUSTER'">SHALL contain exactly one [1..1]
        @classCode="CLUSTER" cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:12979).</sch:assert>
      <sch:assert id="a-12980" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:12980).</sch:assert>
      <sch:assert id="a-12981" test="count(cda:statusCode[@code='completed'])=1">SHALL contain
        exactly one [1..1] statusCode="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:12981).</sch:assert>
      <sch:assert id="a-12984"
        test="cda:reference[@typeCode='REFR'][cda:externalDocument[@classCode='DOC']]"
        >SHALL contain exactly one [1..1] reference (CONF:12982) such that it SHALL contain exactly
        one [1..1] @typeCode="REFR" refers to (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:12983). SHALL contain exactly one [1..1]
        externalDocument="DOC" Document (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:12984).</sch:assert>
      <sch:assert id="a-12986"
        test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt; 0]) &gt; 0"
        >This externalDocument SHALL contain exactly one [1..1] id (CONF:12985) such that it SHALL
        contain exactly one [1..1] @root (CONF:12986).</sch:assert>
      <sch:assert id="a-12987" test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0">This
        ID references the ID of the Quality Measure (CONF:12987).</sch:assert>
      <sch:assert id="a-12998" test="cda:reference/cda:externalDocument/cda:text">This
        text is the title of the eMeasure (CONF:12998).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-errors"
      context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.1-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-errors-abstract"/>
      <sch:assert id="a-17887" test="@classCode='CLUSTER'">SHALL contain exactly one [1..1]
        @classCode="CLUSTER" (CONF:17887).</sch:assert>
      <sch:assert id="a-17888" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17888).</sch:assert>
      <sch:assert id="a-17889" test="count(cda:statusCode[@code='completed'])=1">SHALL contain
        exactly one [1..1] statusCode="completed" (CONF:17889).</sch:assert>
      <sch:assert id="a-17892"
        test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']"
        >SHALL contain exactly one [1..1] reference (CONF:17890) such that it SHALL contain exactly
        one [1..1] @typeCode="REFR" (CONF:17891). SHALL contain exactly one [1..1]
        externalDocument="DOC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:17892).</sch:assert>
      <sch:assert id="a-17904"
        test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14'])=1]) &lt; 2"
        >MAY contain zero or one [0..1] component (CONF:17903) such that it SHALL contain exactly
        one [1..1] Performance Rate for Proportion Measure
        (templateId:2.16.840.1.113883.10.20.27.3.14) (CONF:17904).</sch:assert>
      <sch:assert id="a-18193"
        test="cda:reference[@typeCode='REFR']/cda:externalDocument[cda:id[@root]]"
        >This externalDocument SHALL contain exactly one [1..1] id (CONF:18192) such that it SHALL
        contain exactly one [1..1] @root (CONF:18193).</sch:assert>
      <sch:assert id="a-18354" test="cda:reference/cda:externalDocument">In the
        case that an eMeasure is part of a measure set or group, the following reference is used to
        identify that set or group. SHOULD contain exactly one [1..1] reference (CONF:18353) such
        that it SHALL contain exactly one [1..1] externalDocument (CONF:18354).</sch:assert>
      <sch:assert id="a-18355" test="cda:reference/cda:externalDocument[count(cda:id) &gt; 0]">This
        externalDocument SHALL contain at least one [1..*] id (CONF:18355).</sch:assert>
      <sch:assert id="a-18357"
        test="cda:reference/cda:externalDocument[cda:code[@code='55185-3'][@codeSystem='2.16.840.1.113883.6.1']]"
        >This externalDocument SHALL contain exactly one [1..1] code="55185-3" measure set
        (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:18357).</sch:assert>
      <sch:assert id="a-18358" test="cda:reference/cda:externalDocument[count(cda:text)=1]">This
        externalDocument SHALL contain exactly one [1..1] text (CONF:18358).</sch:assert>
      <sch:assert id="a-18424"
        test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15'])=1]) &lt; 2"
        >MAY contain zero or one [0..1] component (CONF:18423) such that it SHALL contain exactly
        one [1..1] Reporting Rate for Proportion Measure
        (templateId:2.16.840.1.113883.10.20.27.3.15) (CONF:18424).</sch:assert>
      <sch:assert id="a-18426"
        test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5'])=1]) &gt; 0"
        >SHALL contain at least one [1..*] component (CONF:18425) such that it SHALL contain exactly
        one [1..1] Measure Data (templateId:2.16.840.1.113883.10.20.27.3.5)
        (CONF:18426).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.1-errors"
      context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.1-errors-abstract"/>
      <sch:assert id="a-17909"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:17908) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.1" (CONF:17909).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.10-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.10-errors-abstract" abstract="true">
      <sch:assert id="a-18100" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18100).</sch:assert>
      <sch:assert id="a-18101" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18101).</sch:assert>
      <sch:assert id="a-18105"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:18102) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18103). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18104). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18105).</sch:assert>
      <sch:assert id="a-18209" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18209).</sch:assert>
      <sch:assert id="a-18210" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18210).</sch:assert>
      <sch:assert id="a-18211" test="count(cda:templateId)=1">SHALL contain exactly one [1..1]
        templateId (CONF:18211).</sch:assert>
      <sch:assert id="a-18213" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18213).</sch:assert>
      <sch:assert id="a-18214"
        test="cda:code[@code='184102003' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL
        contain exactly one [1..1] @code="184102003" patient postal code (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96 STATIC) (CONF:18214).</sch:assert>
      <sch:assert id="a-18215" test="count(cda:value[@xsi:type='ST'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="ST" (CONF:18215).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.10-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.10-errors-abstract"/>
      <sch:assert id="a-18212" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.10']">This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.10"
        (CONF:18212).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.55-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-errors-abstract" abstract="true">
      <sch:assert id="a-12564" test="count(cda:id) &gt; 0">SHALL contain at least one [1..*] id
        (CONF:12564).</sch:assert>
      <sch:assert id="a-12565" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:12565).</sch:assert>
      <sch:assert id="a-14029"
        test="cda:code[@code='48768-6' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL
        contain exactly one [1..1] @code="48768-6" Payment source (CodeSystem: LOINC
        2.16.840.1.113883.6.1 STATIC) (CONF:14029).</sch:assert>
      <sch:assert id="a-14213" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:14213).</sch:assert>
      <sch:assert id="a-14214" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:14214).</sch:assert>
      <sch:assert id="a-16710" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD" (CONF:16710).</sch:assert>
      <sch:assert id="a-16855" test="cda:value[@code]">This value SHALL contain exactly one [1..1]
        @code (CONF:16855).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-errors-abstract"/>
      <sch:assert id="a-12562"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.55'])=1">SHALL contain
        exactly one [1..1] templateId (CONF:12561) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.3.55" (CONF:12562).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.9-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.9-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-errors-abstract"/>
      <sch:assert id="a-18106" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18106).</sch:assert>
      <sch:assert id="a-18107" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18107).</sch:assert>
      <sch:assert id="a-18111"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:18108) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18109). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18110). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18111).</sch:assert>
      <sch:assert id="a-18250" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet Source of
        Payment Typology (PHDSC) 2.16.840.1.114222.4.11.3591 DYNAMIC (CONF:18250).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.9-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.9-errors-abstract"/>
      <sch:assert id="a-18238"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.9'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:18237) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.9" (CONF:18238).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.8-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.8-errors-abstract" abstract="true">
      <sch:assert id="a-18112" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18112).</sch:assert>
      <sch:assert id="a-18113" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18113).</sch:assert>
      <sch:assert id="a-18117"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:18114) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18115). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18116). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18117).</sch:assert>
      <sch:assert id="a-18223" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18223).</sch:assert>
      <sch:assert id="a-18224" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18224).</sch:assert>
      <sch:assert id="a-18225" test="count(cda:templateId)=1">SHALL contain exactly one [1..1]
        templateId (CONF:18225).</sch:assert>
      <sch:assert id="a-18227" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18227).</sch:assert>
      <sch:assert id="a-18228"
        test="cda:code[@code='103579009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL
        contain exactly one [1..1] @code="103579009" Race (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96) (CONF:18228).</sch:assert>
      <sch:assert id="a-18229" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        NHSNRaceCategory 2.16.840.1.114222.4.11.836 DYNAMIC (CONF:18229).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.8-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.8-errors-abstract"/>
      <sch:assert id="a-18226" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.8']">This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.8"
        (CONF:18226).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.7-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.7-errors-abstract" abstract="true">
      <sch:assert id="a-18118" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18118).</sch:assert>
      <sch:assert id="a-18119" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18119).</sch:assert>
      <sch:assert id="a-18123"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:18120) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18121). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18122). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18123).</sch:assert>
      <sch:assert id="a-18216" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18216).</sch:assert>
      <sch:assert id="a-18217" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18217).</sch:assert>
      <sch:assert id="a-18218" test="count(cda:templateId)=1">SHALL contain exactly one [1..1]
        templateId (CONF:18218).</sch:assert>
      <sch:assert id="a-18220" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18220).</sch:assert>
      <sch:assert id="a-18221"
        test="cda:code[@code='364699009' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL
        contain exactly one [1..1] @code="364699009" Ethnic Group (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96) (CONF:18221).</sch:assert>
      <sch:assert id="a-18222" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        EtnicityGroup 2.16.840.1.114222.4.11.837 DYNAMIC (CONF:18222).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.7-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.7-errors-abstract"/>
      <sch:assert id="a-18219" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.7']">This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.7"
        (CONF:18219).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.6-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.6-errors-abstract" abstract="true">
      <sch:assert id="a-18124" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18124).</sch:assert>
      <sch:assert id="a-18125" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18125).</sch:assert>
      <sch:assert id="a-18129"
        test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"
        >SHALL contain exactly one [1..1] entryRelationship (CONF:18126) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18127). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18128). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18129).</sch:assert>
      <sch:assert id="a-18230" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18230).</sch:assert>
      <sch:assert id="a-18231" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18231).</sch:assert>
      <sch:assert id="a-18232" test="count(cda:templateId)=1">SHALL contain exactly one [1..1]
        templateId (CONF:18232).</sch:assert>
      <sch:assert id="a-18234" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18234).</sch:assert>
      <sch:assert id="a-18235"
        test="cda:code[@code='184100006' and @codeSystem='2.16.840.1.113883.6.96']">This code SHALL
        contain exactly one [1..1] @code="184100006" patient sex (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96 STATIC) (CONF:18235).</sch:assert>
      <sch:assert id="a-18236" test="count(cda:value[@xsi:type='CD'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        Administrative Gender (HL7 V3) 2.16.840.1.113883.1.11.1 DYNAMIC (CONF:18236).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.6-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.6-errors-abstract"/>
      <sch:assert id="a-18233" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.6']">This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.6"
        (CONF:18233).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.11-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.11-errors-abstract" abstract="true">
      <sch:assert id="a-18312" test="@classCode='ENC'">SHALL contain exactly one [1..1]
        @classCode="ENC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18312).</sch:assert>
      <sch:assert id="a-18314" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1]
        effectiveTime (CONF:18314).</sch:assert>
      <sch:assert id="a-18315" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL
        contain exactly one [1..1] low (CONF:18315).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.11-errors"
      context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.11-errors-abstract"/>
      <sch:assert id="a-18370"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.11'])=1">SHALL contain
        exactly one [1..1] templateId (CONF:18369) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.11" (CONF:18370).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.12-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.12-errors-abstract" abstract="true">
      <sch:assert id="a-18316" test="@classCode='ENC'">SHALL contain exactly one [1..1]
        @classCode="ENC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18316).</sch:assert>
      <sch:assert id="a-18318" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1]
        effectiveTime (CONF:18318).</sch:assert>
      <sch:assert id="a-18320" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL
        contain exactly one [1..1] high (CONF:18320).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.12-errors"
      context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.12-errors-abstract"/>
      <sch:assert id="a-18372"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.12'])=1">SHALL contain
        exactly one [1..1] templateId (CONF:18371) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.12" (CONF:18372).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.1-errors">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-errors-abstract" abstract="true">
      <sch:assert id="a-4142"
        test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1"
        >SHALL contain exactly one [1..1] title="Reporting Parameters" (CONF:4142).</sch:assert>
      <sch:assert id="a-4143" test="count(cda:text)=1">SHALL contain exactly one [1..1] text
        (CONF:4143).</sch:assert>
      <sch:assert id="a-17496"
        test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1"
        >SHALL contain exactly one [1..1] entry (CONF:3277) such that it SHALL contain exactly one
        [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:3278). SHALL contain exactly one [1..1] Reporting
        Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:17496).</sch:assert>
      <sch:assert id="a-18191"
        test="count(cda:code[@code='55187-9'][@codeSystem='2.16.840.1.113883.6.1'])">SHALL contain
        exactly one [1..1] code (CONF:18191).</sch:assert>
      <sch:assert id="a-19229"
        test="cda:code[@code='55187-9' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL
        contain exactly one [1..1] @code="55187-9" Reporting Parameters (CodeSystem: LOINC
        2.16.840.1.113883.6.1 STATIC) (CONF:19229).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-errors"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-errors-abstract"/>
      <sch:assert id="a-14612"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.2.1'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:14611) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.17.2.1" (CONF:14612).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.2.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.2-errors-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-errors-abstract"/>
      <sch:assert id="a-18330"
        test="count(cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.12'])=1]) &lt; 2"
        >MAY contain zero or one [0..1] entry (CONF:18328) such that it SHALL contain exactly one
        [1..1] Last Encounter (templateId:2.16.840.1.113883.10.20.27.3.12)
        (CONF:18330).</sch:assert>
      <sch:assert id="a-18428"
        test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1]) &lt; 2"
        >SHOULD contain zero or one [0..1] entry (CONF:18325) such that it SHALL contain exactly one
        [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18427). SHALL contain exactly one [1..1] Reporting
        Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:18428).</sch:assert>
      <sch:assert id="a-18430"
        test="count(cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11'])=1]) &lt; 2"
        >MAY contain zero or one [0..1] entry (CONF:18429) such that it SHALL contain exactly one
        [1..1] First Encounter (templateId:2.16.840.1.113883.10.20.27.3.11)
        (CONF:18430).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.2-errors"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.2.2-errors-abstract"/>
      <sch:assert id="a-18324"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.2'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:18323) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.2.2" (CONF:18324).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.14-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.14-errors-abstract" abstract="true">
      <sch:assert id="a-18395" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18395).</sch:assert>
      <sch:assert id="a-18396" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18396).</sch:assert>
      <sch:assert id="a-18397" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18397).</sch:assert>
      <sch:assert id="a-18398"
        test="cda:code[@code='PERFR-X' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL
        contain exactly one [1..1] @code="PERFR-X" Performance Rate (proportion measure)
        (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:18398).</sch:assert>
      <sch:assert id="a-18399" test="count(cda:value[@xsi:type='REAL'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="REAL" (CONF:18399).</sch:assert>
      <sch:assert id="a-18401"
        test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The
        referenceRange, if present, SHALL contain exactly one [1..1] observationRange
        (CONF:18401).</sch:assert>
      <sch:assert id="a-18402"
        test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"
        >This observationRange SHALL contain exactly one [1..1] value with @xsi:type="REAL"
        (CONF:18402).</sch:assert>
      <sch:assert id="a-18421" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18421).</sch:assert>
      <sch:assert id="a-18422" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18422).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.14-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.14-errors-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.15-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.15-errors-abstract" abstract="true">
      <sch:assert id="a-18411" test="@classCode='OBS'">SHALL contain exactly one [1..1]
        @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18411).</sch:assert>
      <sch:assert id="a-18412" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18412).</sch:assert>
      <sch:assert id="a-18413" test="count(cda:code)=1">SHALL contain exactly one [1..1] code
        (CONF:18413).</sch:assert>
      <sch:assert id="a-18414"
        test="cda:code[@code='REPR-X' and @codeSystem='2.16.840.1.113883.6.1']">This code SHALL
        contain exactly one [1..1] @code="REPR-X" Reporting Rate (for Proportion Measures)
        (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:18414).</sch:assert>
      <sch:assert id="a-18415" test="count(cda:value[@xsi:type='REAL'])=1">SHALL contain exactly one
        [1..1] value with @xsi:type="REAL" (CONF:18415).</sch:assert>
      <sch:assert id="a-18417"
        test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]">The
        referenceRange, if present, SHALL contain exactly one [1..1] observationRange
        (CONF:18417).</sch:assert>
      <sch:assert id="a-18418"
        test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"
        >This observationRange SHALL contain exactly one [1..1] value with @xsi:type="REAL"
        (CONF:18418).</sch:assert>
      <sch:assert id="a-18419" test="count(cda:statusCode)=1">SHALL contain exactly one [1..1]
        statusCode (CONF:18419).</sch:assert>
      <sch:assert id="a-18420" test="cda:statusCode[@code='completed']">This statusCode SHALL
        contain exactly one [1..1] @code="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18420).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.15-errors"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.15-errors-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.5.2-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.2-errors-abstract" abstract="true">
      <sch:assert id="a-7291"
        test="count(cda:streetAddressLine[@xsi:type='ST']) &gt; 0 and count(cda:streetAddressLine[@xsi:type='ST']) &lt; 5"
        >SHALL contain at least one and not more than 4 streetAddressLine (CONF:7291).</sch:assert>
      <sch:assert id="a-7292" test="count(cda:city[@xsi:type='ST'])=1">SHALL contain exactly one
        [1..1] city (CONF:7292).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.2-errors"
      context="cda:AD[cda:templateId/@root='2.16.840.1.113883.10.20.22.5.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.5.2-errors-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.5.1.1-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.1.1-errors-abstract" abstract="true">
      <sch:assert id="a-9368" test="count(cda:name)=1">SHALL contain exactly one [1..1] name
        (CONF:9368).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.1.1-errors"
      context="cda:PN[cda:templateId/@root='2.16.840.1.113883.10.20.22.5.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.5.1.1-errors-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.3.8-errors">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-errors-abstract" abstract="true">
      <sch:assert id="a-3269" test="@classCode='ACT'">SHALL contain exactly one [1..1]
        @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:3269).</sch:assert>
      <sch:assert id="a-3270" test="@moodCode='EVN'">SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:3270).</sch:assert>
      <sch:assert id="a-3272"
        test="count(cda:code[@code='252116004'][@codeSystem='2.16.840.1.113883.6.96'])=1">SHALL
        contain exactly one [1..1] code="252116004" Observation Parameters (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96 STATIC) (CONF:3272).</sch:assert>
      <sch:assert id="a-3273" test="count(cda:effectiveTime)=1">SHALL contain exactly one [1..1]
        effectiveTime (CONF:3273).</sch:assert>
      <sch:assert id="a-3274" test="cda:effectiveTime[count(cda:low)=1]">This effectiveTime SHALL
        contain exactly one [1..1] low (CONF:3274).</sch:assert>
      <sch:assert id="a-3275" test="cda:effectiveTime[count(cda:high)=1]">This effectiveTime SHALL
        contain exactly one [1..1] high (CONF:3275).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-errors"
      context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.3.8-errors-abstract"/>
      <sch:assert id="a-18099"
        test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8'])=1">SHALL contain exactly
        one [1..1] templateId (CONF:18098) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.17.3.8" (CONF:18099).</sch:assert>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.1.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.1.1-warnings-abstract" abstract="true">
      <sch:assert id="a-18166"
        test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:name) &lt; 2]"
        >This representedCustodianOrganization SHOULD contain zero or one [0..1] name
        (CONF:18166).</sch:assert>
      <sch:assert id="a-18260" test="count(cda:versionNumber) &lt; 2">SHOULD contain zero or one
        [0..1] versionNumber (CONF:18260).</sch:assert>
      <sch:assert id="a-18305"
        test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1']) &gt; 0]) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1']) &gt; 0]"
        >The EHR may have an ONC Certification Number, which goes here. This associatedEntity SHALL
        contain at least one [1..*] id (CONF:18304) such that it SHOULD contain zero or one [0..1]
        @root="2.16.840.1.113883.3.2074.1" Office of the National Coordinator Certification Number
        (CONF:18305).</sch:assert>
      <sch:assert id="a-18381"
        test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21']) &gt; 0]) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21']) &gt; 0]"
        >The EHR may have a CMS Security Code (a unique identifier assigned by CMS for each
        qualified EHR vendor application), which goes here. This associatedEntity MAY contain at
        least one [1..*] id (CONF:18380) such that it SHOULD contain zero or one [0..1]
        @root="2.16.840.1.113883.3.249.21" CMS Certified EHR Security Code Identifier
        (CONF:18381).</sch:assert>
      <sch:assert id="a-19449" test="cda:legalAuthenticator/cda:assignedEntity/cda:telecom[@use]"
        >Such telecoms SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet
        Telecom Use (US Realm Header) 2.16.840.1.113883.11.20.9.20 DYNAMIC
        (CONF:19449).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.1.1-warnings"
      context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.1.1-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.2.2-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.2.2-warnings"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.2.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.1-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.2.2-warnings-abstract"/>
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.1-warnings"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.2.1-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.3-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.3-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.3-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.3-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.2-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.2-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.2-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.4-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.4-warnings-abstract" abstract="true">
      <sch:assert id="a-17580" test="count(cda:value) &lt; 2">SHOULD contain zero or one [0..1]
        value (CONF:17580).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.4-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.4-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.5-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.5-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.5-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.5-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.98-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract" abstract="true">
      <sch:assert id="a-12997"
        test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]">This
        externalDocument SHOULD contain zero or one [0..1] text (CONF:12997).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.98-warnings"
      context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.1-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.98-warnings-abstract"/>
      <sch:assert id="a-17896"
        test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:code[@code='57024-2'][@codeSystem='2.16.840.1.113883.6.1']) &lt; 2]"
        >This externalDocument SHOULD contain zero or one [0..1] code="57024-2" Health Quality
        Measure Document (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC) (CONF:17896).</sch:assert>
      <sch:assert id="a-17897"
        test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]">This
        text is the title and optionally a brief description of the Quality Measure. This
        externalDocument SHOULD contain zero or one [0..1] text (CONF:17897).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.1-warnings"
      context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.1-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.10-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.10-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.10-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.10-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.24.3.55-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.24.3.55-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.9-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.9-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.24.3.55-warnings-abstract"/>
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.9-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.9-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.8-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.8-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.8-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.8-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.7-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.7-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.7-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.7-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.6-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.6-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.6-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.6-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.11-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.11-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.11-warnings"
      context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.11-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.12-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.12-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.12-warnings"
      context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.12']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.12-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.2.1-warnings">
    <!--Pattern is used in an implied relationship.-->
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.2.1-warnings"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.2.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.2-warnings-abstract" abstract="true">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.2.1-warnings-abstract"/>
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.2.2-warnings"
      context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.2.2-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.14-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.14-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.14-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.14-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.27.3.15-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.15-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.27.3.15-warnings"
      context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.27.3.15-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.5.2-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.2-warnings-abstract" abstract="true">
      <sch:assert id="a-7290"
        test="@use and @use=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.10637']/svs:ConceptList/svs:Concept/@code"
        >SHOULD contain exactly one [1..1] @use, which SHALL be selected from ValueSet
        PostalAddressUse 2.16.840.1.113883.1.11.10637 STATIC 2005-05-01 (CONF:7290).</sch:assert>
      <sch:assert id="a-7293" test="count(cda:state[@xsi:type='ST']) &lt; 2">SHOULD contain zero or
        one [0..1] state (ValueSet: StateValueSet 2.16.840.1.113883.3.88.12.80.1 DYNAMIC)
        (CONF:7293).</sch:assert>
      <sch:assert id="a-7294" test="count(cda:postalCode[@xsi:type='ST']) &lt; 2">SHOULD contain
        zero or one [0..1] postalCode (ValueSet: PostalCodeValueSet 2.16.840.1.113883.3.88.12.80.2
        DYNAMIC) (CONF:7294).</sch:assert>
      <sch:assert id="a-7295" test="count(cda:country[@xsi:type='ST']) &lt; 2">SHOULD contain zero
        or one [0..1] country, where the @code SHALL be selected from ValueSet CountryValueSet
        2.16.840.1.113883.3.88.12.80.63 DYNAMIC (CONF:7295).</sch:assert>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.2-warnings"
      context="cda:AD[cda:templateId/@root='2.16.840.1.113883.10.20.22.5.2']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.5.2-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.22.5.1.1-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.1.1-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.22.5.1.1-warnings"
      context="cda:PN[cda:templateId/@root='2.16.840.1.113883.10.20.22.5.1.1']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.22.5.1.1-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
  <sch:pattern id="p-2.16.840.1.113883.10.20.17.3.8-warnings">
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-warnings-abstract" abstract="true">
      <sch:assert test="."/>
    </sch:rule>
    <sch:rule id="r-2.16.840.1.113883.10.20.17.3.8-warnings"
      context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']">
      <sch:extends rule="r-2.16.840.1.113883.10.20.17.3.8-warnings-abstract"/>
    </sch:rule>
  </sch:pattern>
</sch:schema>
