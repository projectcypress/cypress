<?xml version="1.0"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:svs="urn:ihe:iti:svs:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cda="urn:hl7-org:v3" version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<axsl:param name="archiveDirParameter"/><axsl:param name="archiveNameParameter"/><axsl:param name="fileNameParameter"/><axsl:param name="fileDirParameter"/>

<!--PHASES-->


<!--PROLOG-->
<axsl:output xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml" omit-xml-declaration="no" standalone="yes" indent="yes"/>

<!--KEYS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template match="*" mode="schematron-select-full-path"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<axsl:template match="*" mode="schematron-get-full-path"><axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/><axsl:text>/</axsl:text><axsl:choose><axsl:when test="namespace-uri()=''"><axsl:value-of select="name()"/><axsl:variable name="p_1" select="1+    count(preceding-sibling::*[name()=name(current())])"/><axsl:if test="$p_1&gt;1 or following-sibling::*[name()=name(current())]">[<axsl:value-of select="$p_1"/>]</axsl:if></axsl:when><axsl:otherwise><axsl:text>*[local-name()='</axsl:text><axsl:value-of select="local-name()"/><axsl:text>' and namespace-uri()='</axsl:text><axsl:value-of select="namespace-uri()"/><axsl:text>']</axsl:text><axsl:variable name="p_2" select="1+   count(preceding-sibling::*[local-name()=local-name(current())])"/><axsl:if test="$p_2&gt;1 or following-sibling::*[local-name()=local-name(current())]">[<axsl:value-of select="$p_2"/>]</axsl:if></axsl:otherwise></axsl:choose></axsl:template><axsl:template match="@*" mode="schematron-get-full-path"><axsl:text>/</axsl:text><axsl:choose><axsl:when test="namespace-uri()=''">@<axsl:value-of select="name()"/></axsl:when><axsl:otherwise><axsl:text>@*[local-name()='</axsl:text><axsl:value-of select="local-name()"/><axsl:text>' and namespace-uri()='</axsl:text><axsl:value-of select="namespace-uri()"/><axsl:text>']</axsl:text></axsl:otherwise></axsl:choose></axsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<axsl:template match="node() | @*" mode="schematron-get-full-path-2"><axsl:for-each select="ancestor-or-self::*"><axsl:text>/</axsl:text><axsl:value-of select="name(.)"/><axsl:if test="preceding-sibling::*[name(.)=name(current())]"><axsl:text>[</axsl:text><axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/><axsl:text>]</axsl:text></axsl:if></axsl:for-each><axsl:if test="not(self::*)"><axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if></axsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<axsl:template match="/" mode="generate-id-from-path"/><axsl:template match="text()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/></axsl:template><axsl:template match="comment()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/></axsl:template><axsl:template match="processing-instruction()" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/></axsl:template><axsl:template match="@*" mode="generate-id-from-path"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:value-of select="concat('.@', name())"/></axsl:template><axsl:template match="*" mode="generate-id-from-path" priority="-0.5"><axsl:apply-templates select="parent::*" mode="generate-id-from-path"/><axsl:text>.</axsl:text><axsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/></axsl:template><!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<axsl:template match="node() | @*" mode="schematron-get-full-path-3"><axsl:for-each select="ancestor-or-self::*"><axsl:text>/</axsl:text><axsl:value-of select="name(.)"/><axsl:if test="parent::*"><axsl:text>[</axsl:text><axsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/><axsl:text>]</axsl:text></axsl:if></axsl:for-each><axsl:if test="not(self::*)"><axsl:text/>/@<axsl:value-of select="name(.)"/></axsl:if></axsl:template>

<!--MODE: GENERATE-ID-2 -->
<axsl:template match="/" mode="generate-id-2">U</axsl:template><axsl:template match="*" mode="generate-id-2" priority="2"><axsl:text>U</axsl:text><axsl:number level="multiple" count="*"/></axsl:template><axsl:template match="node()" mode="generate-id-2"><axsl:text>U.</axsl:text><axsl:number level="multiple" count="*"/><axsl:text>n</axsl:text><axsl:number count="node()"/></axsl:template><axsl:template match="@*" mode="generate-id-2"><axsl:text>U.</axsl:text><axsl:number level="multiple" count="*"/><axsl:text>_</axsl:text><axsl:value-of select="string-length(local-name(.))"/><axsl:text>_</axsl:text><axsl:value-of select="translate(name(),':','.')"/></axsl:template><!--Strip characters--><axsl:template match="text()" priority="-1"/>

<!--SCHEMA METADATA-->
<axsl:template match="/"><svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" title="" schemaVersion=""><axsl:attribute name="phase">errors</axsl:attribute><axsl:comment><axsl:value-of select="$archiveDirParameter"/>  &#xA0;
		 <axsl:value-of select="$archiveNameParameter"/> &#xA0;
		 <axsl:value-of select="$fileNameParameter"/> &#xA0;
		 <axsl:value-of select="$fileDirParameter"/></axsl:comment><svrl:ns-prefix-in-attribute-values uri="urn:ihe:iti:svs:2008" prefix="svs"/><svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/><svrl:ns-prefix-in-attribute-values uri="urn:hl7-org:v3" prefix="cda"/><svrl:active-pattern><axsl:attribute name="id">document-errors</axsl:attribute><axsl:attribute name="name">document-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M5"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.1.1-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.1.1-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M6"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.2.2-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.2.2-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M7"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.2.1-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.2.1-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M8"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.3-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.3-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M9"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.2-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.2-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M10"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.4-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.4-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M11"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.5-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.5-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M12"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.3.98-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.3.98-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M13"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.1-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.1-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M14"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.10-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.10-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M15"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.3.55-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.3.55-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M16"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.9-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.9-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M17"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.8-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.8-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M18"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.7-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.7-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M19"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.6-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.6-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M20"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.11-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.11-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M21"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.17.2.1-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.17.2.1-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M22"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.2.2-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.2.2-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M23"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.14-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.14-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M24"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.15-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.15-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M25"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.17.3.8-errors</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.17.3.8-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M26"/></svrl:schematron-output></axsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN document-errors-->


	<!--RULE -->
<axsl:template match="cda:ClinicalDocument" priority="1000" mode="M5"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:ClinicalDocument"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.1.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.1.1'])=1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        document is not a QRDA CAT III report. It SHALL have template "QRDA Category III Report"
        (templateId: 2.16.840.1.113883.10.20.27.1.1) to claim the HL7 QRDA CAT III implementation
        guide conformance.</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/></axsl:template><axsl:template match="text()" priority="-1" mode="M5"/><axsl:template match="@*|node()" priority="-2" mode="M5"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M5"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.1.1-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.1.1-errors-->
<axsl:template match="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']" priority="1000" mode="M6"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']" id="r-2.16.840.1.113883.10.20.27.1.1-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code[@codeSystem='2.16.840.1.113883.6.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code[@codeSystem='2.16.840.1.113883.6.1'])=1"><axsl:attribute name="id">a-17210</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL
        contain exactly one [1..1] code (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:17210).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:title)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:title)=1"><axsl:attribute name="id">a-17211</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] title
        (CONF:17211).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:recordTarget)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:recordTarget)=1"><axsl:attribute name="id">a-17212</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>QRDA III is an aggregate summary
        report. Therefore CDA's required recordTarget/id is nulled. The recordTarget element is
        designed for single patient data and is required in all CDA documents. In this case, the
        document does not contain results for a single patient, but rather for groups of patients,
        and thus the recordTarget ID in QRDA Category III documents contains a nullFlavor attribute
        (is nulled). SHALL contain exactly one [1..1] recordTarget (CONF:17212).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:custodian)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:custodian)=1"><axsl:attribute name="id">a-17213</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        custodian (CONF:17213).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:custodian[count(cda:assignedCustodian)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:custodian[count(cda:assignedCustodian)=1]"><axsl:attribute name="id">a-17214</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This custodian
        SHALL contain exactly one [1..1] assignedCustodian (CONF:17214).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:custodian/cda:assignedCustodian[count(cda:representedCustodianOrganization)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:custodian/cda:assignedCustodian[count(cda:representedCustodianOrganization)=1]"><axsl:attribute name="id">a-17215</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This assignedCustodian SHALL contain exactly one [1..1] representedCustodianOrganization
        (CONF:17215).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component)=1"><axsl:attribute name="id">a-17217</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>A QRDA Category III document contains a
        Reporting Parameters Section and a Measure section. SHALL contain exactly one [1..1]
        component (CONF:17217).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:legalAuthenticator)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:legalAuthenticator)=1"><axsl:attribute name="id">a-17225</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] legalAuthenticator (CONF:17225).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:realmCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:realmCode)=1"><axsl:attribute name="id">a-17226</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        realmCode (CONF:17226).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:realmCode[@code='US']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:realmCode[@code='US']"><axsl:attribute name="id">a-17227</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This realmCode SHALL contain exactly
        one [1..1] @code="US" (CONF:17227).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:recordTarget[count(cda:patientRole[count(cda:id)=1])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:recordTarget[count(cda:patientRole[count(cda:id)=1])=1]"><axsl:attribute name="id">a-17233</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This recordTarget SHALL contain exactly one [1..1] patientRole (CONF:17232) such that it
        SHALL contain exactly one [1..1] id (CONF:17233).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:recordTarget/cda:patientRole/cda:id[@nullFlavor='NA']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:recordTarget/cda:patientRole/cda:id[@nullFlavor='NA']"><axsl:attribute name="id">a-17234</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        id SHALL contain exactly one [1..1] @nullFlavor="NA" (CONF:17234).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:component[count(cda:structuredBody)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:component[count(cda:structuredBody)=1]"><axsl:attribute name="id">a-17235</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This component
        SHALL contain exactly one [1..1] structuredBody (CONF:17235).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:id)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:id)=1"><axsl:attribute name="id">a-17236</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] id
        (CONF:17236).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:effectiveTime)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:effectiveTime)=1"><axsl:attribute name="id">a-17237</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        effectiveTime (CONF:17237).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:confidentialityCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.16926']/svs:ConceptList/svs:Concept/@code])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:confidentialityCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.16926']/svs:ConceptList/svs:Concept/@code])=1"><axsl:attribute name="id">a-17238</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] confidentialityCode, which SHOULD be selected from
        ValueSet HL7 BasicConfidentialityKind 2.16.840.1.113883.1.11.16926 STATIC 2010-04-21
        (CONF:17238).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:languageCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:languageCode)=1"><axsl:attribute name="id">a-17239</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        languageCode (CONF:17239).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2'])=1])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2'])=1])=1]"><axsl:attribute name="id">a-17282</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This structuredBody SHALL contain exactly one [1..1] component (CONF:17281) such that it
        SHALL contain exactly one [1..1] QRDA Category III Reporting Parameters Section
        (templateId:2.16.840.1.113883.10.20.27.2.2) (CONF:17282).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1'])=1])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:component/cda:structuredBody[count(cda:component[count(cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1'])=1])=1]"><axsl:attribute name="id">a-17301</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This structuredBody SHALL contain exactly one [1..1] component (CONF:17283) such that it
        SHALL contain exactly one [1..1] QRDA Category III Measure Section
        (templateId:2.16.840.1.113883.10.20.27.2.1) (CONF:17301).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:author[count(cda:assignedAuthor)=1][count(cda:time)=1]) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:author[count(cda:assignedAuthor)=1][count(cda:time)=1]) &gt; 0"><axsl:attribute name="id">a-18158</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The CDA
        standard requires an author with an identifier. In addition, the QRDA Category III document
        type requires that the author be declared as a person or a device. The document can be
        authored solely by a person or by a device, or the document could be authored by a
        combination of one or more devices and/or one or more people. SHALL contain at least one
        [1..*] author (CONF:18156) such that it SHALL contain exactly one [1..1] time
        (CONF:18158).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:author[count(cda:time)=1][count(cda:assignedAuthor[count(cda:assignedAuthoringDevice)         &lt; 2][count(cda:assignedPerson) &lt; 2][count(cda:representedOrganization)=1])=1]) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:author[count(cda:time)=1][count(cda:assignedAuthor[count(cda:assignedAuthoringDevice) &lt; 2][count(cda:assignedPerson) &lt; 2][count(cda:representedOrganization)=1])=1]) &gt; 0"><axsl:attribute name="id">a-18163</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The CDA standard requires an author with an identifier. In addition, the QRDA Category III
        document type requires that the author be declared as a person or a device. The document can
        be authored solely by a person or by a device, or the document could be authored by a
        combination of one or more devices and/or one or more people. SHALL contain at least one
        [1..*] author (CONF:18156) such that it SHALL contain exactly one [1..1] assignedAuthor
        (CONF:18157) such that it SHALL contain exactly one [1..1] representedOrganization
        (CONF:18163).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:id)         &gt; 0]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:id) &gt; 0]"><axsl:attribute name="id">a-18165</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This representedCustodianOrganization SHALL contain at least one [1..*] id
        (CONF:18165).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:legalAuthenticator[count(cda:time)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:legalAuthenticator[count(cda:time)=1]"><axsl:attribute name="id">a-18167</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        legalAuthenticator SHALL contain exactly one [1..1] time (CONF:18167).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:legalAuthenticator[count(cda:signatureCode)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:legalAuthenticator[count(cda:signatureCode)=1]"><axsl:attribute name="id">a-18168</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        legalAuthenticator SHALL contain exactly one [1..1] signatureCode (CONF:18168).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:legalAuthenticator/cda:signatureCode[@code='S']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:legalAuthenticator/cda:signatureCode[@code='S']"><axsl:attribute name="id">a-18169</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        signatureCode SHALL contain exactly one [1..1] @code="S" (CONF:18169).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf) or         cda:documentationOf[count(cda:serviceEvent)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf) or cda:documentationOf[count(cda:serviceEvent)=1]"><axsl:attribute name="id">a-18171</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The documentationOf, if present, SHALL
        contain exactly one [1..1] serviceEvent (CONF:18171).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent) or         cda:documentationOf/cda:serviceEvent[@classCode='PCPR']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent) or cda:documentationOf/cda:serviceEvent[@classCode='PCPR']"><axsl:attribute name="id">a-18172</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This serviceEvent SHALL contain
        exactly one [1..1] @classCode="PCPR" Care Provision (CodeSystem: HL7ActClass
        2.16.840.1.113883.5.6 STATIC) (CONF:18172).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent) or         cda:documentationOf/cda:serviceEvent[count(cda:performer) &gt; 0]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent) or cda:documentationOf/cda:serviceEvent[count(cda:performer) &gt; 0]"><axsl:attribute name="id">a-18173</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This serviceEvent SHALL
        contain at least one [1..*] performer (CONF:18173).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or         cda:documentationOf/cda:serviceEvent/cda:performer[@typeCode='PRF']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or cda:documentationOf/cda:serviceEvent/cda:performer[@typeCode='PRF']"><axsl:attribute name="id">a-18174</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>Such performers SHALL
        contain exactly one [1..1] @typeCode="PRF" Performer (CodeSystem: HL7ParticipationType
        2.16.840.1.113883.5.90 STATIC) (CONF:18174).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or         cda:documentationOf/cda:serviceEvent/cda:performer[count(cda:assignedEntity)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent/cda:performer) or cda:documentationOf/cda:serviceEvent/cda:performer[count(cda:assignedEntity)=1]"><axsl:attribute name="id">a-18176</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>Such
        performers SHALL contain exactly one [1..1] assignedEntity (CONF:18176).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or         cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:representedOrganization)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:representedOrganization)=1]"><axsl:attribute name="id">a-18180</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This assignedEntity SHALL contain exactly one [1..1] representedOrganization
        (CONF:18180).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:typeId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:typeId)=1"><axsl:attribute name="id">a-18186</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] typeId
        (CONF:18186).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:typeId[@root='2.16.840.1.113883.1.3']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:typeId[@root='2.16.840.1.113883.1.3']"><axsl:attribute name="id">a-18187</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This typeId SHALL
        contain exactly one [1..1] @root="2.16.840.1.113883.1.3" (CONF:18187).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:typeId[@extension='POCD_HD000040']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:typeId[@extension='POCD_HD000040']"><axsl:attribute name="id">a-18188</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This typeId SHALL
        contain exactly one [1..1] @extension="POCD_HD000040" (CONF:18188).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:effectiveTime[string-length(@value)&gt;=8]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:effectiveTime[string-length(@value)&gt;=8]"><axsl:attribute name="id">a-18189</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The content
        SHALL be a conformant US Realm Date and Time (DTM.US.FIELDED)
        (2.16.840.1.113883.10.20.22.5.4) (CONF:18189).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson])         or         cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson][count(cda:softwareName)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson]) or cda:author/cda:assignedAuthor[cda:time]/cda:assignedAuthoringDevice[cda:representedOrganization][cda:assignedPerson][count(cda:softwareName)=1]"><axsl:attribute name="id">a-18262</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The assignedAuthoringDevice, if present, SHALL contain exactly one [1..1] softwareName
        (CONF:18262).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:author/cda:assignedAuthor/cda:representedOrganization[count(cda:name) &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:author/cda:assignedAuthor/cda:representedOrganization[count(cda:name) &lt; 2]"><axsl:attribute name="id">a-18265</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This representedOrganization SHALL contain at least one [1..*] name
        (CONF:18265).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]) or         cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]) or cda:participant[@typeCode='DEV'][count(cda:associatedEntity)=1]"><axsl:attribute name="id">a-18302</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The generic participant
        with a participationType of device and an associatedEntity class code of RGPR (regulated
        product) is used to represent Electronic Health Record (EHR) government agency certification
        identifiers. MAY contain zero or more [0..*] participant (CONF:18300) such that it SHALL
        contain exactly one [1..1] @typeCode="DEV" device (CodeSystem: HL7ParticipationType
        2.16.840.1.113883.5.90 STATIC) (CONF:18301). SHALL contain exactly one [1..1]
        associatedEntity (CONF:18302).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or         cda:participant[@typeCode='DEV']/cda:associatedEntity[@classCode='RGPR']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or cda:participant[@typeCode='DEV']/cda:associatedEntity[@classCode='RGPR']"><axsl:attribute name="id">a-18303</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        associatedEntity SHALL contain exactly one [1..1] @classCode="RGPR" regulated product
        (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:18303).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1'])         &lt; 2]) or         cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1'])         &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1']) &lt; 2]) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.2074.1']) &lt; 2]"><axsl:attribute name="id">a-18305</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>If the EHR has an ONC Certification Number, the value of the root attribute is as
        specified and the value of the extension attribute is the Certification Number. This
        associatedEntity MAY contain zero or one [0..1] id (CONF:18304) such that it SHALL contain
        exactly one [1..1] @root="2.16.840.1.113883.3.2074.1" Office of the National Coordinator
        Certification Number (CONF:18305).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or         cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:code)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:code)=1]"><axsl:attribute name="id">a-18308</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        associatedEntity SHALL contain exactly one [1..1] code (CONF:18308).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code) or         cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code[@code='129465004' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code) or cda:participant[@typeCode='DEV']/cda:associatedEntity/cda:code[@code='129465004' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-18309</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="129465004" medical record, device (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96
        STATIC) (CONF:18309).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization) or         cda:authorization[count(cda:consent)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization) or cda:authorization[count(cda:consent)=1]"><axsl:attribute name="id">a-18360</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The authorization, if present, SHALL contain
        exactly one [1..1] consent (CONF:18360).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization/cda:consent) or         cda:authorization/cda:consent[count(cda:id)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:id)=1]"><axsl:attribute name="id">a-18361</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The consent/id is the identifier of the
        consent given by the eligible provider. This consent SHALL contain exactly one [1..1] id
        (CONF:18361).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization/cda:consent) or         cda:authorization/cda:consent[count(cda:code[@codeSystem='2.16.840.1.113883.6.96'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:code[@codeSystem='2.16.840.1.113883.6.96'])=1]"><axsl:attribute name="id">a-18363</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        consent SHALL contain exactly one [1..1] code (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96
        STATIC) (CONF:18363).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization/cda:consent) or         cda:authorization/cda:consent[count(cda:statusCode)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization/cda:consent) or cda:authorization/cda:consent[count(cda:statusCode)=1]"><axsl:attribute name="id">a-18364</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This consent SHALL contain exactly
        one [1..1] statusCode (CONF:18364).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21'])         &lt; 2]) or         cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21'])         &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21']) &lt; 2]) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id[@root='2.16.840.1.113883.3.249.21']) &lt; 2]"><axsl:attribute name="id">a-18381</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>If the EHR has a CMS Security Code (a unique identifier assigned by CMS for each
        qualified EHR vendor application), the value of the root attribute is as specified and the
        value of the extension attribute is the CMS Security Code. This associatedEntity MAY contain
        zero or one [0..1] id (CONF:18380) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.3.249.21" CMS Certified EHR Security Code Identifier
        (CONF:18381).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or         cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity[count(cda:id) &gt; 0]"><axsl:attribute name="id">a-19474</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This assignedEntity SHALL contain at least one [1..*] id (CONF:19474).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='55184-6' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='55184-6' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19549</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55184-6" " Quality Reporting Document Architecture Calculated Summary Report
        (CodeSystem: LOINC 2.16.840.1.113883.6.1) (CONF:19549).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization/cda:consent/cda:code) or         cda:authorization/cda:consent/cda:code[@code='425691002' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization/cda:consent/cda:code) or cda:authorization/cda:consent/cda:code[@code='425691002' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-19550</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="425691002" Consent given for electronic record sharing (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96) (CONF:19550).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:authorization/cda:consent/cda:statusCode) or         cda:authorization/cda:consent/cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:authorization/cda:consent/cda:statusCode) or cda:authorization/cda:consent/cda:statusCode[@code='completed']"><axsl:attribute name="id">a-19551</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14) (CONF:19551).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:author/cda:assignedAuthor[count(cda:assignedPerson)=1 or         count(cda:assignedAuthoringDevice)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:author/cda:assignedAuthor[count(cda:assignedPerson)=1 or count(cda:assignedAuthoringDevice)=1]"><axsl:attribute name="id">a-19667</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The CDA standard requires an author with an
        identifier. In addition, the QRDA Category III document type requires that the author be
        declared as a person or a device. The document can be authored solely by a person or by a
        device, or the document could be authored by a combination of one or more devices and/or one
        or more people. SHALL contain at least one [1..*] author (CONF:18156) such that it There
        SHALL be exactly one assignedAuthor/assignedPerson or exactly one
        assignedAuthor/assignedAuthoringDevice (CONF:19667).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:languageCode[@code]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:languageCode[@code]"><axsl:attribute name="id">a-19669</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This languageCode SHALL contain
        exactly one [1..1] @code, which SHALL be selected from ValueSet Language
        2.16.840.1.113883.1.11.11526 DYNAMIC (CONF:19669).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:legalAuthenticator[count(cda:assignedEntity)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:legalAuthenticator[count(cda:assignedEntity)=1]"><axsl:attribute name="id">a-19670</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        legalAuthenticator SHALL contain exactly one [1..1] assignedEntity
        (CONF:19670).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization) or         cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization[count(cda:id) &gt; 0]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization) or cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization[count(cda:id) &gt; 0]"><axsl:attribute name="id">a-19672</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The representedOrganization, if present, SHALL contain at least one [1..*] id
        (CONF:19672).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or         cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id) &gt; 0]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:participant[@typeCode='DEV']/cda:associatedEntity) or cda:participant[@typeCode='DEV']/cda:associatedEntity[count(cda:id) &gt; 0]"><axsl:attribute name="id">a-20954</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        associatedEntity SHALL contain at least one [1..*] id (CONF:20954).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.1.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.1.1'])=1"><axsl:attribute name="id">a-17209</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:17208) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.1.1" (CONF:17209).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/></axsl:template><axsl:template match="text()" priority="-1" mode="M6"/><axsl:template match="@*|node()" priority="-2" mode="M6"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.2.2-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.24.2.2-errors-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']" priority="1000" mode="M7"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']" id="r-2.16.840.1.113883.10.20.24.2.2-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-12798</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:12798).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',         'abcdefghijklmnopqrstuvwxyz')='measure section'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='measure section'])=1"><axsl:attribute name="id">a-12799</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        title="Measure Section" (CONF:12799).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:text)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:text)=1"><axsl:attribute name="id">a-12800</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] text
        (CONF:12800).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1])         &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1]) &gt; 0"><axsl:attribute name="id">a-16677</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] entry (CONF:13003) such that it SHALL contain
        exactly one [1..1] Measure Reference (templateId:2.16.840.1.113883.10.20.24.3.98)
        (CONF:16677).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='55186-1' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='55186-1' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19230</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55186-1" Measure Section (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:19230).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.2'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.2.2'])=1"><axsl:attribute name="id">a-12802</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:12801) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.2.2" (CONF:12802).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/></axsl:template><axsl:template match="text()" priority="-1" mode="M7"/><axsl:template match="@*|node()" priority="-2" mode="M7"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.2.1-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.2.1-errors-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']" priority="1000" mode="M8"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']" id="r-2.16.840.1.113883.10.20.27.2.1-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-12798</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:12798).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',         'abcdefghijklmnopqrstuvwxyz')='measure section'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='measure section'])=1"><axsl:attribute name="id">a-12799</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        title="Measure Section" (CONF:12799).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:text)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:text)=1"><axsl:attribute name="id">a-12800</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] text
        (CONF:12800).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1])         &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98'])=1]) &gt; 0"><axsl:attribute name="id">a-16677</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] entry (CONF:13003) such that it SHALL contain
        exactly one [1..1] Measure Reference (templateId:2.16.840.1.113883.10.20.24.3.98)
        (CONF:16677).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='55186-1' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='55186-1' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19230</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55186-1" Measure Section (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:19230).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1'])=1])         &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[count(cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1'])=1]) &gt; 0"><axsl:attribute name="id">a-17907</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] entry (CONF:17906) such that it SHALL contain
        exactly one [1..1] Measure Reference and Results (templateId:2.16.840.1.113883.10.20.27.3.1)
        (CONF:17907).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.1'])=1"><axsl:attribute name="id">a-17285</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:17284) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.2.1" (CONF:17285).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/></axsl:template><axsl:template match="text()" priority="-1" mode="M8"/><axsl:template match="@*|node()" priority="-2" mode="M8"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.3-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.3-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']" priority="1000" mode="M9"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']" id="r-2.16.840.1.113883.10.20.27.3.3-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-17563</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17563).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-17564</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17564).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-17566</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:17566).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='INT'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='INT'])=1"><axsl:attribute name="id">a-17567</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="INT" (CONF:17567).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:value[@value]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:value[@value]"><axsl:attribute name="id">a-17568</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This value SHALL contain exactly one [1..1]
        @value (CONF:17568).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange) or         cda:referenceRange[count(cda:observationRange)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]"><axsl:attribute name="id">a-18393</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The referenceRange, if present, SHALL
        contain exactly one [1..1] observationRange (CONF:18393).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange/cda:observationRange) or         cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='INT'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='INT'])=1]"><axsl:attribute name="id">a-18394</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        observationRange SHALL contain exactly one [1..1] value with @xsi:type="INT"
        (CONF:18394).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='MSRAGG' and         @codeSystem='2.16.840.1.113883.5.4']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='MSRAGG' and @codeSystem='2.16.840.1.113883.5.4']"><axsl:attribute name="id">a-19508</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="MSRAGG" rate aggregation (CodeSystem: ActCode 2.16.840.1.113883.5.4)
        (CONF:19508).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:methodCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:methodCode)=1"><axsl:attribute name="id">a-19509</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        methodCode (CONF:19509).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:methodCode[@code='COUNT']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:methodCode[@code='COUNT']"><axsl:attribute name="id">a-19510</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This methodCode SHALL contain
        exactly one [1..1] @code="COUNT" Count (CodeSystem: ObservationMethod
        2.16.840.1.113883.5.84) (CONF:19510).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.3'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.3'])=1"><axsl:attribute name="id">a-18095</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:17565) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.3" (CONF:18095).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template><axsl:template match="text()" priority="-1" mode="M9"/><axsl:template match="@*|node()" priority="-2" mode="M9"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.2-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.2-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']" priority="1000" mode="M10"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']" id="r-2.16.840.1.113883.10.20.27.3.2-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-17569</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17569).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-17570</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17570).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-17571</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:17571).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value)=1"><axsl:attribute name="id">a-17572</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] value
        (CONF:17572).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:methodCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.20450']/svs:ConceptList/svs:Concept/@code])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:methodCode[@code=document('voc.xml')/svs:RetrieveMultipleValueSetsResponse/svs:DescribedValueSet[@ID='2.16.840.1.113883.1.11.20450']/svs:ConceptList/svs:Concept/@code])=1"><axsl:attribute name="id">a-18242</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] methodCode, which SHALL be selected from ValueSet
        ObservationMethodAggregate 2.16.840.1.113883.1.11.20450 STATIC (CONF:18242).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference)=1"><axsl:attribute name="id">a-18243</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        reference (CONF:18243).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[count(cda:externalObservation)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[count(cda:externalObservation)=1]"><axsl:attribute name="id">a-18244</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This reference
        SHALL contain exactly one [1..1] externalObservation (CONF:18244).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference/cda:externalObservation[count(cda:id)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference/cda:externalObservation[count(cda:id)=1]"><axsl:attribute name="id">a-18245</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalObservation SHALL contain exactly one [1..1] id (CONF:18245).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange) or         cda:referenceRange[count(cda:observationRange)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]"><axsl:attribute name="id">a-18390</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The referenceRange, if present, SHALL
        contain exactly one [1..1] observationRange (CONF:18390).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange/cda:observationRange) or         cda:referenceRange/cda:observationRange[count(cda:value)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value)=1]"><axsl:attribute name="id">a-18391</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This observationRange SHALL
        contain exactly one [1..1] value (CONF:18391).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.2'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.2'])=1"><axsl:attribute name="id">a-18097</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:18096) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.2" (CONF:18097).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template><axsl:template match="text()" priority="-1" mode="M10"/><axsl:template match="@*|node()" priority="-2" mode="M10"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.4-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.4-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']" priority="1000" mode="M11"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']" id="r-2.16.840.1.113883.10.20.27.3.4-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-17575</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17575).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-17576</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17576).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-17577</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:17577).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='ASSERTION' and         @codeSystem='2.16.840.1.113883.5.4']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']"><axsl:attribute name="id">a-17578</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC)
        (CONF:17578).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-17579</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:17579).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-17584</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:17581) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" (CONF:17582). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:17583). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:17584).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18201</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18201).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference)=1"><axsl:attribute name="id">a-18204</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        reference (CONF:18204).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']"><axsl:attribute name="id">a-18205</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This reference SHALL contain
        exactly one [1..1] @typeCode="REFR" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18205).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[count(cda:externalObservation)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[count(cda:externalObservation)=1]"><axsl:attribute name="id">a-18206</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This reference
        SHALL contain exactly one [1..1] externalObservation (CONF:18206).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference/cda:externalObservation[count(cda:id)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference/cda:externalObservation[count(cda:id)=1]"><axsl:attribute name="id">a-18207</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>If this
        reference is to an eMeasure, this id equals the referenced stratification id defined in the
        eMeasure. This externalObservation SHALL contain exactly one [1..1] id
        (CONF:18207).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(testable)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(testable)"><axsl:attribute name="id">a-18259</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>If this Reporting Stratum references an
        eMeasure, and the value of externalObservation/id equals the reference stratification id
        defined in the eMeasure, then this value SHALL be the same as the contents of the
        observation/code element in the eMeasure that is defined along with the observation/id
        element (CONF:18259).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1])         or         cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]) or cda:entryRelationship[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"><axsl:attribute name="id">a-19513</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The Continuous Variable template may also be nested inside the Reporting Stratum Template
        to represent continuous variables found in quality measures for the various strata. MAY
        contain zero or more [0..*] entryRelationship (CONF:19511) such that it SHALL contain
        exactly one [1..1] Continuous Variable Measure Value
        (templateId:2.16.840.1.113883.10.20.27.3.2) (CONF:19513).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.4'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.4'])=1"><axsl:attribute name="id">a-18094</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:18093) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.4" (CONF:18094).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template><axsl:template match="text()" priority="-1" mode="M11"/><axsl:template match="@*|node()" priority="-2" mode="M11"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.5-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.5-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']" priority="1000" mode="M12"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']" id="r-2.16.840.1.113883.10.20.27.3.5-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-17615</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CONF:17615).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-17616</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CONF:17616).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-17617</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:17617).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-17618</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHOULD be selected from ValueSet
        ObservationPopulationInclusion 2.16.840.1.113883.1.11.20369 DYNAMIC
        (CONF:17618).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-17620</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:17619) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" (CONF:17910). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:17911). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:17620).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-17912</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:17912).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4'])=1]"><axsl:attribute name="id">a-17920</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:17918) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CONF:17919). SHALL contain exactly one [1..1] Reporting
        Stratum (templateId:2.16.840.1.113883.10.20.27.3.4) (CONF:17920).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6'])=1]"><axsl:attribute name="id">a-18138</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:18136) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18137). SHALL contain exactly one [1..1] Sex
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.6)
        (CONF:18138).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7'])=1]"><axsl:attribute name="id">a-18149</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:18139) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18144). SHALL contain exactly one [1..1] Ethnicity
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.7)
        (CONF:18149).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8'])=1]"><axsl:attribute name="id">a-18150</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:18140) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18145). SHALL contain exactly one [1..1] Race
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.8)
        (CONF:18150).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9'])=1]"><axsl:attribute name="id">a-18151</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:18141) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18146). SHALL contain exactly one [1..1] Payer
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.9)
        (CONF:18151).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10'])=1]"><axsl:attribute name="id">a-18152</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entryRelationship (CONF:18142) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18147). SHALL contain exactly one [1..1] Postal Code
        Supplemental Data Element (templateId:2.16.840.1.113883.10.20.27.3.10)
        (CONF:18152).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1])         or         cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]) or cda:entryRelationship[@typeCode='COMP'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2'])=1]"><axsl:attribute name="id">a-18153</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>If observation/value/@code="MSRPOPL" then the following entryRelationship SHALL be present.
        MAY contain zero or more [0..*] entryRelationship (CONF:18143) such that it SHALL contain
        exactly one [1..1] @typeCode="COMP" (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18148). SHALL contain exactly one [1..1] Continuous
        Variable Measure Value (templateId:2.16.840.1.113883.10.20.27.3.2)
        (CONF:18153).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='ASSERTION' and         @codeSystem='2.16.840.1.113883.5.4']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='ASSERTION' and @codeSystem='2.16.840.1.113883.5.4']"><axsl:attribute name="id">a-18198</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="ASSERTION" Assertion (CodeSystem: ActCode 2.16.840.1.113883.5.4 STATIC)
        (CONF:18198).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18199</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CodeSystem: ActStatus 2.16.840.1.113883.5.14 STATIC) (CONF:18199).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference[count(cda:externalObservation)=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference[count(cda:externalObservation)=1])=1"><axsl:attribute name="id">a-18240</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL
        contain exactly one [1..1] reference (CONF:18239) such that it SHALL contain exactly one
        [1..1] externalObservation (CONF:18240).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference/cda:externalObservation[count(cda:id)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference/cda:externalObservation[count(cda:id)=1]"><axsl:attribute name="id">a-18241</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalObservation SHALL contain exactly one [1..1] id (CONF:18241).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-19555</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14) (CONF:19555).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.5']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.5']"><axsl:attribute name="id">a-17913</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.5"
        (CONF:17913).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template><axsl:template match="text()" priority="-1" mode="M12"/><axsl:template match="@*|node()" priority="-2" mode="M12"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.3.98-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.24.3.98-errors-->
<axsl:template match="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']" priority="1000" mode="M13"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']" id="r-2.16.840.1.113883.10.20.24.3.98-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='CLUSTER'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='CLUSTER'"><axsl:attribute name="id">a-12979</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="CLUSTER" cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:12979).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-12980</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:12980).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode[@code='completed'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode[@code='completed'])=1"><axsl:attribute name="id">a-12981</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] statusCode="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:12981).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR'][cda:externalDocument[@classCode='DOC']]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR'][cda:externalDocument[@classCode='DOC']]"><axsl:attribute name="id">a-12984</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] reference (CONF:12982) such that it SHALL contain exactly one [1..1]
        @typeCode="REFR" refers to (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002
        STATIC) (CONF:12983). SHALL contain exactly one [1..1] externalDocument
        (CONF:12984).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt;         0]) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt; 0]) &gt; 0"><axsl:attribute name="id">a-12986</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalDocument SHALL contain exactly one [1..1] id (CONF:12985) such that
        it SHALL contain exactly one [1..1] @root (CONF:12986).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0"><axsl:attribute name="id">a-12987</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        ID references the ID of the Quality Measure (CONF:12987).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference/cda:externalDocument/cda:text"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference/cda:externalDocument/cda:text"><axsl:attribute name="id">a-12998</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This text is the
        title of the eMeasure (CONF:12998).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98'])=1"><axsl:attribute name="id">a-19533</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] templateId (CONF:19532) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.3.98" (CONF:19533).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"><axsl:attribute name="id">a-19534</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHALL contain exactly one [1..1] @classCode (CodeSystem: HL7ActClass
        2.16.840.1.113883.5.6) (CONF:19534).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template><axsl:template match="text()" priority="-1" mode="M13"/><axsl:template match="@*|node()" priority="-2" mode="M13"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.1-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.1-errors-->
<axsl:template match="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']" priority="1000" mode="M14"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']" id="r-2.16.840.1.113883.10.20.27.3.1-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='CLUSTER'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='CLUSTER'"><axsl:attribute name="id">a-12979</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="CLUSTER" cluster (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:12979).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-12980</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:12980).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode[@code='completed'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode[@code='completed'])=1"><axsl:attribute name="id">a-12981</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] statusCode="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:12981).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR'][cda:externalDocument[@classCode='DOC']]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR'][cda:externalDocument[@classCode='DOC']]"><axsl:attribute name="id">a-12984</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] reference (CONF:12982) such that it SHALL contain exactly one [1..1]
        @typeCode="REFR" refers to (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002
        STATIC) (CONF:12983). SHALL contain exactly one [1..1] externalDocument
        (CONF:12984).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt;         0]) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:id[@root]) &gt; 0]) &gt; 0"><axsl:attribute name="id">a-12986</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalDocument SHALL contain exactly one [1..1] id (CONF:12985) such that
        it SHALL contain exactly one [1..1] @root (CONF:12986).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference/cda:externalDocument/cda:id) &gt; 0"><axsl:attribute name="id">a-12987</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        ID references the ID of the Quality Measure (CONF:12987).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference/cda:externalDocument/cda:text"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference/cda:externalDocument/cda:text"><axsl:attribute name="id">a-12998</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This text is the
        title of the eMeasure (CONF:12998).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98'])=1"><axsl:attribute name="id">a-19533</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] templateId (CONF:19532) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.3.98" (CONF:19533).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"><axsl:attribute name="id">a-19534</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHALL contain exactly one [1..1] @classCode (CodeSystem: HL7ActClass
        2.16.840.1.113883.5.6) (CONF:19534).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='CLUSTER'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='CLUSTER'"><axsl:attribute name="id">a-17887</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="CLUSTER" (CONF:17887).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-17888</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1. .1]
        @moodCode="EVN" (CONF:17888).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-17889</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:17889).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']"><axsl:attribute name="id">a-17892</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] reference (CONF:17890) such that it SHALL contain exactly one [1..1]
        @typeCode="REFR" (CONF:17891). SHALL contain exactly one [1..1] externalDocument
        (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:17892).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14'])=1])         or         cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14'])=1]) or cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14'])=1]"><axsl:attribute name="id">a-17904</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] component (CONF:17903) such that it SHALL contain exactly
        one [1..1] Performance Rate for Proportion Measure
        (templateId:2.16.840.1.113883.10.20.27.3.14) (CONF:17904).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference[@typeCode='REFR']/cda:externalDocument) =         count(cda:reference[@typeCode='REFR']/cda:externalDocument[cda:id[@root]])"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference[@typeCode='REFR']/cda:externalDocument) = count(cda:reference[@typeCode='REFR']/cda:externalDocument[cda:id[@root]])"><axsl:attribute name="id">a-18193</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHALL contain exactly one [1..1] id (CONF:18192) such that it SHALL contain
        exactly one [1..1] @root (CONF:18193).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation) or         cda:reference/cda:externalObservation"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation) or cda:reference/cda:externalObservation"><axsl:attribute name="id">a-18354</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>In the case that an eMeasure is part of a measure set
        or group, the following reference is used to identify that set or group. If the eMeasure is
        not part of a measure set, the following reference element should not be defined. SHOULD
        contain exactly one [1..1] reference (CONF:18353) such that it SHALL contain exactly one
        [1..1] externalObservation (CONF:18354).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:reference/cda:externalObservation) =         count(cda:reference/cda:externalObservation[cda:id])"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:reference/cda:externalObservation) = count(cda:reference/cda:externalObservation[cda:id])"><axsl:attribute name="id">a-18355</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalObservation SHALL contain
        at least one [1..*] id (CONF:18355).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(testable)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(testable)"><axsl:attribute name="id">a-18356</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This id SHALL equal the id of the corresponding
        measure set definition within the eMeasure (CONF:18356).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation) or         cda:reference/cda:externalObservation[cda:code[@code='55185-3'][@codeSystem='2.16.840.1.113883.6.1']]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation) or cda:reference/cda:externalObservation[cda:code[@code='55185-3'][@codeSystem='2.16.840.1.113883.6.1']]"><axsl:attribute name="id">a-18357</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalObservation SHALL contain exactly one [1..1] code (CodeSystem: LOINC
        2.16.840.1.113883.6.1 STATIC) (CONF:18357).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation) or         cda:reference/cda:externalObservation[count(cda:text)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation) or cda:reference/cda:externalObservation[count(cda:text)=1]"><axsl:attribute name="id">a-18358</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalObservation SHALL
        contain exactly one [1..1] text (CONF:18358).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15'])=1])         &lt; 2"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15'])=1]) &lt; 2"><axsl:attribute name="id">a-18424</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or one [0..1] component (CONF:18423) such that it SHALL contain
        exactly one [1..1] Reporting Rate for Proportion Measure
        (templateId:2.16.840.1.113883.10.20.27.3.15) (CONF:18424).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5'])=1])         &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component[count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5'])=1]) &gt; 0"><axsl:attribute name="id">a-18426</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] component (CONF:18425) such that it SHALL contain
        exactly one [1..1] Measure Data (templateId:2.16.840.1.113883.10.20.27.3.5)
        (CONF:18426).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode]"><axsl:attribute name="id">a-19548</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHALL contain exactly one [1..1] @classCode (CodeSystem: HL7ActClass
        2.16.840.1.113883.5.6) (CONF:19548).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-19552</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14) (CONF:19552).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference[@typeCode='REFR']/cda:externalDocument/cda:code) or         cda:reference[@typeCode='REFR']/cda:externalDocument/cda:code[@code='57024-2' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference[@typeCode='REFR']/cda:externalDocument/cda:code) or cda:reference[@typeCode='REFR']/cda:externalDocument/cda:code[@code='57024-2' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19553</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The code, if present, SHALL contain exactly one [1..1]
        @code="57024-2" Health Quality Measure Document (CodeSystem: LOINC 2.16.840.1.113883.6.1)
        (CONF:19553).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(tested)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(tested)"><axsl:attribute name="id">a-19554</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55185-3" measure set (CodeSystem: LOINC 2.16.840.1.113883.6.1)
        (CONF:19554).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(testable)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(testable)"><axsl:attribute name="id">a-19660</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalDocument SHALL contain exactly one
        [1..1] id (CONF:18192) such that it SHALL contain exactly one [1..1] @root (CONF:18193). If
        this reference is to an eMeasure, this id/@root SHALL equal the version specific identifier
        for eMeasure (i.e. QualityMeasureDocument/id) (CONF:19660).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.1'])=1"><axsl:attribute name="id">a-17909</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:17908) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.1" (CONF:17909).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template><axsl:template match="text()" priority="-1" mode="M14"/><axsl:template match="@*|node()" priority="-2" mode="M14"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.10-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.10-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']" priority="1000" mode="M15"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']" id="r-2.16.840.1.113883.10.20.27.3.10-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18100</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18100).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18101</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18101).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-18105</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:18102) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18103). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18104). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18105).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18209</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18209).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18210</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18210).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-18211</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:18211).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18213</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18213).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='184102003' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='184102003' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-18214</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="184102003" Patient postal code (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC)
        (CONF:18214).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='ST'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='ST'])=1"><axsl:attribute name="id">a-18215</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="ST" (CONF:18215).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.10']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.10']"><axsl:attribute name="id">a-18212</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.10"
        (CONF:18212).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template><axsl:template match="text()" priority="-1" mode="M15"/><axsl:template match="@*|node()" priority="-2" mode="M15"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.3.55-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.24.3.55-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']" priority="1000" mode="M16"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']" id="r-2.16.840.1.113883.10.20.24.3.55-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:id) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:id) &gt; 0"><axsl:attribute name="id">a-12564</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] id
        (CONF:12564).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-12565</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:12565).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='48768-6' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='48768-6' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-14029</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="48768-6" Payment source (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:14029).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-14213</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:14213).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-14214</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:14214).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-16710</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD" (CONF:16710).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:value[@code]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:value[@code]"><axsl:attribute name="id">a-16855</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This value SHALL contain exactly one [1..1]
        @code (CONF:16855).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.55'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.24.3.55'])=1"><axsl:attribute name="id">a-12562</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] templateId (CONF:12561) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.24.3.55" (CONF:12562).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template><axsl:template match="text()" priority="-1" mode="M16"/><axsl:template match="@*|node()" priority="-2" mode="M16"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.9-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.9-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']" priority="1000" mode="M17"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']" id="r-2.16.840.1.113883.10.20.27.3.9-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:id) &gt; 0"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:id) &gt; 0"><axsl:attribute name="id">a-12564</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain at least one [1..*] id
        (CONF:12564).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-12565</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:12565).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='48768-6' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='48768-6' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-14029</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="48768-6" Payment source (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:14029).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-14213</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:14213).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-14214</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:14214).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-16710</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD" (CONF:16710).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:value[@code]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:value[@code]"><axsl:attribute name="id">a-16855</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This value SHALL contain exactly one [1..1]
        @code (CONF:16855).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18106</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18106).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18107</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18107).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-18111</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:18108) such that it SHALL contain exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002 STATIC) (CONF:18109). SHALL contain exactly one [1..1] @inversionInd="true" (CONF:18110). SHALL contain exactly one [1..1] Aggregate Count (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18111).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-18250</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet Source of
        Payment Typology (PHDSC) 2.16.840.1.114222.4.11.3591 DYNAMIC (CONF:18250).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-21155</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC) (CONF:21155).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.9'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.9'])=1"><axsl:attribute name="id">a-18238</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:18237) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.9" (CONF:18238).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template><axsl:template match="text()" priority="-1" mode="M17"/><axsl:template match="@*|node()" priority="-2" mode="M17"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.8-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.8-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']" priority="1000" mode="M18"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']" id="r-2.16.840.1.113883.10.20.27.3.8-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18112</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18112).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18113</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18113).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-18117</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:18114) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18115). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18116). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18117).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18223</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18223).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18224</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18224).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-18225</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:18225).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18227</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18227).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='103579009' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='103579009' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-18228</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="103579009" Race (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96)
        (CONF:18228).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-18229</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        NHSNRaceCategory 2.16.840.1.114222.4.11.836 DYNAMIC (CONF:18229).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.8']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.8']"><axsl:attribute name="id">a-18226</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.8"
        (CONF:18226).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template><axsl:template match="text()" priority="-1" mode="M18"/><axsl:template match="@*|node()" priority="-2" mode="M18"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.7-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.7-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']" priority="1000" mode="M19"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']" id="r-2.16.840.1.113883.10.20.27.3.7-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18118</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18118).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18119</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18119).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-18123</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:18120) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18121). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18122). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18123).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18216</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18216).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18217</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18217).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-18218</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:18218).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18220</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18220).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='364699009' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='364699009' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-18221</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="364699009" Ethnic Group (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96)
        (CONF:18221).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-18222</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        EthnicityGroup 2.16.840.1.114222.4.11.837 DYNAMIC (CONF:18222).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.7']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.7']"><axsl:attribute name="id">a-18219</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.7"
        (CONF:18219).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template><axsl:template match="text()" priority="-1" mode="M19"/><axsl:template match="@*|node()" priority="-2" mode="M19"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.6-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.6-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']" priority="1000" mode="M20"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']" id="r-2.16.840.1.113883.10.20.27.3.6-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18124</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18124).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18125</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" Completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18125).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entryRelationship[@typeCode='SUBJ'][@inversionInd='true'][count(cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3'])=1])=1"><axsl:attribute name="id">a-18129</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entryRelationship (CONF:18126) such that it SHALL contain
        exactly one [1..1] @typeCode="SUBJ" Has Subject (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18127). SHALL contain exactly one [1..1]
        @inversionInd="true" (CONF:18128). SHALL contain exactly one [1..1] Aggregate Count
        (templateId:2.16.840.1.113883.10.20.27.3.3) (CONF:18129).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18230</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18230).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18231</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18231).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-18232</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:18232).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18234</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18234).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='184100006' and         @codeSystem='2.16.840.1.113883.6.96']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='184100006' and @codeSystem='2.16.840.1.113883.6.96']"><axsl:attribute name="id">a-18235</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="184100006" Patient sex (CodeSystem: SNOMED-CT 2.16.840.1.113883.6.96 STATIC)
        (CONF:18235).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='CD'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='CD'])=1"><axsl:attribute name="id">a-18236</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="CD", where the @code SHALL be selected from ValueSet
        Administrative Gender (HL7 V3) 2.16.840.1.113883.1.11.1 DYNAMIC (CONF:18236).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.6']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.6']"><axsl:attribute name="id">a-18233</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.6"
        (CONF:18233).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template><axsl:template match="text()" priority="-1" mode="M20"/><axsl:template match="@*|node()" priority="-2" mode="M20"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.11-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.11-errors-->
<axsl:template match="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']" priority="1000" mode="M21"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']" id="r-2.16.840.1.113883.10.20.27.3.11-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='ENC'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='ENC'"><axsl:attribute name="id">a-18312</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="ENC" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18312).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:effectiveTime)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:effectiveTime)=1"><axsl:attribute name="id">a-18314</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        effectiveTime (CONF:18314).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-21154</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:21154).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.11'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.3.11'])=1"><axsl:attribute name="id">a-18370</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain
        exactly one [1..1] templateId (CONF:18369) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.3.11" (CONF:18370).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template><axsl:template match="text()" priority="-1" mode="M21"/><axsl:template match="@*|node()" priority="-2" mode="M21"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.17.2.1-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.17.2.1-errors-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']" priority="1000" mode="M22"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']" id="r-2.16.840.1.113883.10.20.17.2.1-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',         'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1"><axsl:attribute name="id">a-4142</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        title="Reporting Parameters" (CONF:4142).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:text)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:text)=1"><axsl:attribute name="id">a-4143</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] text
        (CONF:4143).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1"><axsl:attribute name="id">a-17496</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entry (CONF:3277) such that it SHALL contain exactly one
        [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:3278). SHALL contain exactly one [1..1] Reporting
        Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:17496).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='55187-9' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='55187-9' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19229</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55187-9" Reporting Parameters (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:19229).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.2.1'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.2.1'])=1"><axsl:attribute name="id">a-14612</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:14611) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.17.2.1" (CONF:14612).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template><axsl:template match="text()" priority="-1" mode="M22"/><axsl:template match="@*|node()" priority="-2" mode="M22"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.2.2-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.2.2-errors-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']" priority="1000" mode="M23"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']" id="r-2.16.840.1.113883.10.20.27.2.2-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',         'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:title[translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')='reporting parameters'])=1"><axsl:attribute name="id">a-4142</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        title="Reporting Parameters" (CONF:4142).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:text)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:text)=1"><axsl:attribute name="id">a-4143</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] text
        (CONF:4143).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])=1"><axsl:attribute name="id">a-17496</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] entry (CONF:3277) such that it SHALL contain exactly one
        [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:3278). SHALL contain exactly one [1..1] Reporting
        Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:17496).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='55187-9' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='55187-9' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-19229</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="55187-9" Reporting Parameters (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:19229).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11'])=1])         or         cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11'])=1]) or cda:entry[count(cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11'])=1]"><axsl:attribute name="id">a-18330</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>MAY contain zero or more [0..*] entry (CONF:18328) such that it SHALL contain exactly one
        [1..1] Service Encounter (templateId:2.16.840.1.113883.10.20.27.3.11)
        (CONF:18330).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1])         &lt; 2"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:entry[@typeCode='DRIV'][count(cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8'])=1]) &lt; 2"><axsl:attribute name="id">a-18428</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHOULD contain zero or one [0..1] entry (CONF:18325) such that it SHALL contain
        exactly one [1..1] @typeCode="DRIV" Is derived from (CodeSystem: HL7ActRelationshipType
        2.16.840.1.113883.5.1002 STATIC) (CONF:18427). SHALL contain exactly one [1..1] Reporting
        Parameters Act (templateId:2.16.840.1.113883.10.20.17.3.8) (CONF:18428).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.2'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.27.2.2'])=1"><axsl:attribute name="id">a-18324</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:18323) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.27.2.2" (CONF:18324).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template><axsl:template match="text()" priority="-1" mode="M23"/><axsl:template match="@*|node()" priority="-2" mode="M23"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.14-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.14-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']" priority="1000" mode="M24"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']" id="r-2.16.840.1.113883.10.20.27.3.14-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18395</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18395).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18396</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18396).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18397</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18397).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='72510-1' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='72510-1' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-18398</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="72510-1" Performance Rate (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:18398).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='REAL'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='REAL'])=1"><axsl:attribute name="id">a-18399</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="REAL" (CONF:18399).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange) or         cda:referenceRange[count(cda:observationRange)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]"><axsl:attribute name="id">a-18401</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The referenceRange, if present, SHALL
        contain exactly one [1..1] observationRange (CONF:18401).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange/cda:observationRange) or         cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"><axsl:attribute name="id">a-18402</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        observationRange SHALL contain exactly one [1..1] value with @xsi:type="REAL"
        (CONF:18402).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18421</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18421).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18422</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18422).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId)=1"><axsl:attribute name="id">a-19649</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        templateId (CONF:19649).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.14']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:templateId[@root='2.16.840.1.113883.10.20.27.3.14']"><axsl:attribute name="id">a-19650</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        templateId SHALL contain exactly one [1..1] @root="2.16.840.1.113883.10.20.27.3.14"
        (CONF:19650).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference) or cda:reference[@typeCode='REFR']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference) or cda:reference[@typeCode='REFR']"><axsl:attribute name="id">a-19652</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The
        reference, if present, SHALL contain exactly one [1..1] @typeCode="REFR" refers to
        (CodeSystem: HL7ActRelationshipType 2.16.840.1.113883.5.1002) (CONF:19652).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference) or         cda:reference[count(cda:externalObservation)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference) or cda:reference[count(cda:externalObservation)=1]"><axsl:attribute name="id">a-19653</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The reference, if present, SHALL contain
        exactly one [1..1] externalObservation (CONF:19653).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation) or         cda:reference/cda:externalObservation[@classCode]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation) or cda:reference/cda:externalObservation[@classCode]"><axsl:attribute name="id">a-19654</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalObservation SHALL contain
        exactly one [1..1] @classCode (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6)
        (CONF:19654).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(tested)"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(tested)"><axsl:attribute name="id">a-19655</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The externalObservationID contains the ID of the
        numerator in the referenced eMeasure. This externalObservation SHALL contain exactly one
        [1..1] id (CONF:19655).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation/cda:id) or         cda:reference/cda:externalObservation/cda:id[@root]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation/cda:id) or cda:reference/cda:externalObservation/cda:id[@root]"><axsl:attribute name="id">a-19656</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This id SHALL contain exactly one
        [1..1] @root (CONF:19656).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation) or         cda:reference/cda:externalObservation[count(cda:code)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation) or cda:reference/cda:externalObservation[count(cda:code)=1]"><axsl:attribute name="id">a-19657</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalObservation SHALL
        contain exactly one [1..1] code (CONF:19657).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:reference/cda:externalObservation/cda:code) or         cda:reference/cda:externalObservation/cda:code[@code='NUMER' and         @codeSystem='2.16.840.1.113883.5.1063']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:reference/cda:externalObservation/cda:code) or cda:reference/cda:externalObservation/cda:code[@code='NUMER' and @codeSystem='2.16.840.1.113883.5.1063']"><axsl:attribute name="id">a-19658</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="NUMER" Numerator (CodeSystem: ObservationValue 2.16.840.1.113883.5.1063)
        (CONF:19658).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template><axsl:template match="text()" priority="-1" mode="M24"/><axsl:template match="@*|node()" priority="-2" mode="M24"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.15-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.15-errors-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']" priority="1000" mode="M25"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']" id="r-2.16.840.1.113883.10.20.27.3.15-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='OBS'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='OBS'"><axsl:attribute name="id">a-18411</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="OBS" Observation (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:18411).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-18412</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:18412).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code)=1"><axsl:attribute name="id">a-18413</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1] code
        (CONF:18413).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:code[@code='72509-3' and         @codeSystem='2.16.840.1.113883.6.1']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:code[@code='72509-3' and @codeSystem='2.16.840.1.113883.6.1']"><axsl:attribute name="id">a-18414</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This code SHALL contain exactly one [1..1]
        @code="72509-3" Reporting Rate (CodeSystem: LOINC 2.16.840.1.113883.6.1 STATIC)
        (CONF:18414).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value[@xsi:type='REAL'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value[@xsi:type='REAL'])=1"><axsl:attribute name="id">a-18415</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one
        [1..1] value with @xsi:type="REAL" (CONF:18415).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange) or         cda:referenceRange[count(cda:observationRange)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange) or cda:referenceRange[count(cda:observationRange)=1]"><axsl:attribute name="id">a-18417</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The referenceRange, if present, SHALL
        contain exactly one [1..1] observationRange (CONF:18417).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:referenceRange/cda:observationRange) or         cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:referenceRange/cda:observationRange) or cda:referenceRange/cda:observationRange[count(cda:value[@xsi:type='REAL'])=1]"><axsl:attribute name="id">a-18418</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        observationRange SHALL contain exactly one [1..1] value with @xsi:type="REAL"
        (CONF:18418).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:statusCode)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:statusCode)=1"><axsl:attribute name="id">a-18419</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        statusCode (CONF:18419).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:statusCode[@code='completed']"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:statusCode[@code='completed']"><axsl:attribute name="id">a-18420</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This statusCode SHALL
        contain exactly one [1..1] @code="completed" completed (CodeSystem: ActStatus
        2.16.840.1.113883.5.14 STATIC) (CONF:18420).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template><axsl:template match="text()" priority="-1" mode="M25"/><axsl:template match="@*|node()" priority="-2" mode="M25"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.17.3.8-errors-->


	<!--RULE r-2.16.840.1.113883.10.20.17.3.8-errors-->
<axsl:template match="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']" priority="1000" mode="M26"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']" id="r-2.16.840.1.113883.10.20.17.3.8-errors"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@classCode='ACT'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@classCode='ACT'"><axsl:attribute name="id">a-3269</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @classCode="ACT" (CodeSystem: HL7ActClass 2.16.840.1.113883.5.6 STATIC)
        (CONF:3269).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="@moodCode='EVN'"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="@moodCode='EVN'"><axsl:attribute name="id">a-3270</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        @moodCode="EVN" Event (CodeSystem: ActMood 2.16.840.1.113883.5.1001 STATIC)
        (CONF:3270).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:code[@code='252116004'][@codeSystem='2.16.840.1.113883.6.96'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:code[@code='252116004'][@codeSystem='2.16.840.1.113883.6.96'])=1"><axsl:attribute name="id">a-3272</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL
        contain exactly one [1..1] code="252116004" Observation Parameters (CodeSystem: SNOMED-CT
        2.16.840.1.113883.6.96 STATIC) (CONF:3272).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:effectiveTime)=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:effectiveTime)=1"><axsl:attribute name="id">a-3273</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly one [1..1]
        effectiveTime (CONF:3273).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:effectiveTime[count(cda:low)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:effectiveTime[count(cda:low)=1]"><axsl:attribute name="id">a-3274</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This effectiveTime SHALL
        contain exactly one [1..1] low (CONF:3274).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:effectiveTime[count(cda:high)=1]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:effectiveTime[count(cda:high)=1]"><axsl:attribute name="id">a-3275</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This effectiveTime SHALL
        contain exactly one [1..1] high (CONF:3275).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8'])=1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8'])=1"><axsl:attribute name="id">a-18099</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHALL contain exactly
        one [1..1] templateId (CONF:18098) such that it SHALL contain exactly one [1..1]
        @root="2.16.840.1.113883.10.20.17.3.8" (CONF:18099).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template><axsl:template match="text()" priority="-1" mode="M26"/><axsl:template match="@*|node()" priority="-2" mode="M26"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template></axsl:stylesheet>
