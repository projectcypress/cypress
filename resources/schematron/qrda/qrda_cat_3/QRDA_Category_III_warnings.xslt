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
<axsl:template match="/"><svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" title="" schemaVersion=""><axsl:attribute name="phase">warnings</axsl:attribute><axsl:comment><axsl:value-of select="$archiveDirParameter"/>  &#xA0;
		 <axsl:value-of select="$archiveNameParameter"/> &#xA0;
		 <axsl:value-of select="$fileNameParameter"/> &#xA0;
		 <axsl:value-of select="$fileDirParameter"/></axsl:comment><svrl:ns-prefix-in-attribute-values uri="urn:ihe:iti:svs:2008" prefix="svs"/><svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/><svrl:ns-prefix-in-attribute-values uri="urn:hl7-org:v3" prefix="cda"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.1.1-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.1.1-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M27"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.2.2-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.2.2-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M28"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.2.1-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.2.1-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M29"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.3-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.3-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M30"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.2-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.2-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M31"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.4-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.4-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M32"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.5-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.5-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M33"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.3.98-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.3.98-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M34"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.1-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.1-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M35"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.10-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.10-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M36"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.24.3.55-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.24.3.55-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M37"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.9-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.9-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M38"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.8-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.8-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M39"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.7-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.7-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M40"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.6-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.6-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M41"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.11-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.11-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M42"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.17.2.1-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.17.2.1-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M43"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.2.2-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.2.2-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M44"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.14-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.14-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M45"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.27.3.15-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.27.3.15-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M46"/><svrl:active-pattern><axsl:attribute name="id">p-2.16.840.1.113883.10.20.17.3.8-warnings</axsl:attribute><axsl:attribute name="name">p-2.16.840.1.113883.10.20.17.3.8-warnings</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M47"/></svrl:schematron-output></axsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN p-2.16.840.1.113883.10.20.27.1.1-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.1.1-warnings-->
<axsl:template match="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']" priority="1000" mode="M27"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:ClinicalDocument[cda:templateId/@root='2.16.840.1.113883.10.20.27.1.1']" id="r-2.16.840.1.113883.10.20.27.1.1-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:name)         &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:custodian/cda:assignedCustodian/cda:representedCustodianOrganization[count(cda:name) &lt; 2]"><axsl:attribute name="id">a-18166</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This representedCustodianOrganization SHOULD contain zero or one [0..1] name
        (CONF:18166).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:versionNumber) &lt; 2"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:versionNumber) &lt; 2"><axsl:attribute name="id">a-18260</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHOULD contain zero or one
        [0..1] versionNumber (CONF:18260).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization)         or         cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[not(cda:name)         or cda:name]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization) or cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization[not(cda:name) or cda:name]"><axsl:attribute name="id">a-19659</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This representedOrganization SHOULD contain zero or more [0..*] name
        (CONF:19659).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="not(cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization) or         cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization[count(cda:name) &lt;         2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="not(cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization) or cda:legalAuthenticator/cda:assignedEntity/cda:representedOrganization[count(cda:name) &lt; 2]"><axsl:attribute name="id">a-19673</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The representedOrganization, if present, SHOULD contain zero or one [0..1] name
        (CONF:19673).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template><axsl:template match="text()" priority="-1" mode="M27"/><axsl:template match="@*|node()" priority="-2" mode="M27"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.2.2-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.24.2.2-warnings-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']" priority="1000" mode="M28"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.24.2.2']" id="r-2.16.840.1.113883.10.20.24.2.2-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template><axsl:template match="text()" priority="-1" mode="M28"/><axsl:template match="@*|node()" priority="-2" mode="M28"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.2.1-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.2.1-warnings-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']" priority="1000" mode="M29"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.1']" id="r-2.16.840.1.113883.10.20.27.2.1-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template><axsl:template match="text()" priority="-1" mode="M29"/><axsl:template match="@*|node()" priority="-2" mode="M29"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.3-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.3-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']" priority="1000" mode="M30"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.3']" id="r-2.16.840.1.113883.10.20.27.3.3-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template><axsl:template match="text()" priority="-1" mode="M30"/><axsl:template match="@*|node()" priority="-2" mode="M30"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.2-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.2-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']" priority="1000" mode="M31"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.2']" id="r-2.16.840.1.113883.10.20.27.3.2-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template><axsl:template match="text()" priority="-1" mode="M31"/><axsl:template match="@*|node()" priority="-2" mode="M31"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.4-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.4-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']" priority="1000" mode="M32"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.4']" id="r-2.16.840.1.113883.10.20.27.3.4-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:value) &lt; 2"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:value) &lt; 2"><axsl:attribute name="id">a-17580</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>SHOULD contain zero or one [0..1]
        value (CONF:17580).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template><axsl:template match="text()" priority="-1" mode="M32"/><axsl:template match="@*|node()" priority="-2" mode="M32"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.5-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.5-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']" priority="1000" mode="M33"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.5']" id="r-2.16.840.1.113883.10.20.27.3.5-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template><axsl:template match="text()" priority="-1" mode="M33"/><axsl:template match="@*|node()" priority="-2" mode="M33"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.3.98-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.24.3.98-warnings-->
<axsl:template match="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']" priority="1000" mode="M34"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.98']" id="r-2.16.840.1.113883.10.20.24.3.98-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"><axsl:attribute name="id">a-12997</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHOULD contain zero or one [0..1] text (CONF:12997).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template><axsl:template match="text()" priority="-1" mode="M34"/><axsl:template match="@*|node()" priority="-2" mode="M34"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.1-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.1-warnings-->
<axsl:template match="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']" priority="1000" mode="M35"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.1']" id="r-2.16.840.1.113883.10.20.27.3.1-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"><axsl:attribute name="id">a-12997</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        externalDocument SHOULD contain zero or one [0..1] text (CONF:12997).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:code[@codeSystem='2.16.840.1.113883.6.1'])         &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:code[@codeSystem='2.16.840.1.113883.6.1']) &lt; 2]"><axsl:attribute name="id">a-17896</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This externalDocument SHOULD contain zero or one [0..1] code (CodeSystem: LOINC
        2.16.840.1.113883.6.1 STATIC) (CONF:17896).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="cda:reference[@typeCode='REFR']/cda:externalDocument[count(cda:text) &lt; 2]"><axsl:attribute name="id">a-17897</axsl:attribute><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>This
        text is the title and optionally a brief description of the Quality Measure. This
        externalDocument SHOULD contain zero or one [0..1] text (CONF:17897).</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template><axsl:template match="text()" priority="-1" mode="M35"/><axsl:template match="@*|node()" priority="-2" mode="M35"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.10-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.10-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']" priority="1000" mode="M36"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.10']" id="r-2.16.840.1.113883.10.20.27.3.10-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template><axsl:template match="text()" priority="-1" mode="M36"/><axsl:template match="@*|node()" priority="-2" mode="M36"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.24.3.55-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.24.3.55-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']" priority="1000" mode="M37"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.55']" id="r-2.16.840.1.113883.10.20.24.3.55-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template><axsl:template match="text()" priority="-1" mode="M37"/><axsl:template match="@*|node()" priority="-2" mode="M37"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.9-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.9-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']" priority="1000" mode="M38"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.9']" id="r-2.16.840.1.113883.10.20.27.3.9-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template><axsl:template match="text()" priority="-1" mode="M38"/><axsl:template match="@*|node()" priority="-2" mode="M38"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.8-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.8-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']" priority="1000" mode="M39"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.8']" id="r-2.16.840.1.113883.10.20.27.3.8-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template><axsl:template match="text()" priority="-1" mode="M39"/><axsl:template match="@*|node()" priority="-2" mode="M39"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.7-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.7-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']" priority="1000" mode="M40"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.7']" id="r-2.16.840.1.113883.10.20.27.3.7-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template><axsl:template match="text()" priority="-1" mode="M40"/><axsl:template match="@*|node()" priority="-2" mode="M40"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.6-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.6-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']" priority="1000" mode="M41"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.6']" id="r-2.16.840.1.113883.10.20.27.3.6-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template><axsl:template match="text()" priority="-1" mode="M41"/><axsl:template match="@*|node()" priority="-2" mode="M41"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.11-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.11-warnings-->
<axsl:template match="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']" priority="1000" mode="M42"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:encounter[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.11']" id="r-2.16.840.1.113883.10.20.27.3.11-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template><axsl:template match="text()" priority="-1" mode="M42"/><axsl:template match="@*|node()" priority="-2" mode="M42"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.17.2.1-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.17.2.1-warnings-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']" priority="1000" mode="M43"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.17.2.1']" id="r-2.16.840.1.113883.10.20.17.2.1-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template><axsl:template match="text()" priority="-1" mode="M43"/><axsl:template match="@*|node()" priority="-2" mode="M43"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.2.2-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.2.2-warnings-->
<axsl:template match="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']" priority="1000" mode="M44"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:section[cda:templateId/@root='2.16.840.1.113883.10.20.27.2.2']" id="r-2.16.840.1.113883.10.20.27.2.2-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template><axsl:template match="text()" priority="-1" mode="M44"/><axsl:template match="@*|node()" priority="-2" mode="M44"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.14-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.14-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']" priority="1000" mode="M45"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.14']" id="r-2.16.840.1.113883.10.20.27.3.14-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template><axsl:template match="text()" priority="-1" mode="M45"/><axsl:template match="@*|node()" priority="-2" mode="M45"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.27.3.15-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.27.3.15-warnings-->
<axsl:template match="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']" priority="1000" mode="M46"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.27.3.15']" id="r-2.16.840.1.113883.10.20.27.3.15-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template><axsl:template match="text()" priority="-1" mode="M46"/><axsl:template match="@*|node()" priority="-2" mode="M46"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template>

<!--PATTERN p-2.16.840.1.113883.10.20.17.3.8-warnings-->


	<!--RULE r-2.16.840.1.113883.10.20.17.3.8-warnings-->
<axsl:template match="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']" priority="1000" mode="M47"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.17.3.8']" id="r-2.16.840.1.113883.10.20.17.3.8-warnings"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="."/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="."><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text/></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template><axsl:template match="text()" priority="-1" mode="M47"/><axsl:template match="@*|node()" priority="-2" mode="M47"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template></axsl:stylesheet>
