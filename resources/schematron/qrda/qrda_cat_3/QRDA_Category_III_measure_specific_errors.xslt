<?xml version="1.0"?>
<axsl:stylesheet xmlns:axsl="http://www.w3.org/1999/XSL/Transform" xmlns:sch="http://www.ascc.net/xml/schematron" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:voc="http://www.lantanagroup.com/voc" xmlns:svs="urn:ihe:iti:svs:2008" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cda="urn:hl7-org:v3" xmlns:sdtc="urn:hl7-org:sdtc" version="1.0"><!--Implementers: please note that overriding process-prolog or process-root is 
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
		 <axsl:value-of select="$fileDirParameter"/></axsl:comment><svrl:ns-prefix-in-attribute-values uri="http://www.lantanagroup.com/voc" prefix="voc"/><svrl:ns-prefix-in-attribute-values uri="urn:ihe:iti:svs:2008" prefix="svs"/><svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema-instance" prefix="xsi"/><svrl:ns-prefix-in-attribute-values uri="urn:hl7-org:v3" prefix="cda"/><svrl:ns-prefix-in-attribute-values uri="urn:hl7-org:sdtc" prefix="sdtc"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0d01c6626e46-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0d01c6626e46-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M6"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-01954afc63b2-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-01954afc63b2-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M7"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37bf-6f1b-0137-cdadba302b85-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37bf-6f1b-0137-cdadba302b85-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M8"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37d1-f95b-0137-e776b0467baf-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37d1-f95b-0137-e776b0467baf-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M9"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-0dd50ce621d8-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-0dd50ce621d8-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M10"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-01a1d2c966bc-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-01a1d2c966bc-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M11"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-01959fb76498-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-01959fb76498-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M12"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0138-9b2eaba7321d-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0138-9b2eaba7321d-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M13"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0c4e00454b35-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0c4e00454b35-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M14"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-01965ecf65be-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-01965ecf65be-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M15"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-018ce6f1622a-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-018ce6f1622a-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M16"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-dfaaffd96efe-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-dfaaffd96efe-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M17"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37d1-f95b-0137-e1e272994b3f-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37d1-f95b-0137-e1e272994b3f-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M18"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a58-b777-013a-670ab6932a3b-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a58-b777-013a-670ab6932a3b-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M19"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-295ed21c463c-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-295ed21c463c-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M20"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a58-b777-013a-716dfc096ee3-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a58-b777-013a-716dfc096ee3-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M21"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-4640d11650cb-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-4640d11650cb-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M22"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37bf-6f1b-0137-ccd612a40d0e-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37bf-6f1b-0137-ccd612a40d0e-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M23"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0d071ee37793-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0d071ee37793-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M24"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-12364ae9126f-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-12364ae9126f-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M25"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37d1-f95b-0137-dd4b0eb62de6-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37d1-f95b-0137-dd4b0eb62de6-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M26"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0d08a4be7be6-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0d08a4be7be6-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M27"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0c4e41594c98-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0c4e41594c98-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M28"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-11b262260a92-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-11b262260a92-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M29"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-013b0c87524a-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-013b0c87524a-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M30"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0c49fb8c4757-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0c49fb8c4757-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M31"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0c4e6d2b4d6b-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0c4e6d2b4d6b-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M32"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3887-5df3-0139-0c0d3d783133-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3887-5df3-0139-0c0d3d783133-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M33"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-37d1-f95b-0137-e726ad2f7415-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-37d1-f95b-0137-e726ad2f7415-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M34"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-cae9ed8a01bd-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-cae9ed8a01bd-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M35"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-9cd4937e6c86-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-9cd4937e6c86-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M36"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-7ccb48f6025d-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-7ccb48f6025d-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M37"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0cba8db32c3-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0cba8db32c3-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M38"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0cadcb63221-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0cadcb63221-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M39"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-c648b33d5582-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-c648b33d5582-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M40"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-35fb-4aa7-0136-5a26000d30bd-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-35fb-4aa7-0136-5a26000d30bd-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M41"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-caf11e27054e-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-caf11e27054e-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M42"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0a4bca22cf1-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0a4bca22cf1-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M43"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-35fb-4aa7-0136-403ad4504573-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-35fb-4aa7-0136-403ad4504573-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M44"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-d472724e0c46-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-d472724e0c46-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M45"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-795264d90290-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-795264d90290-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M46"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-79591505044d-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-79591505044d-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M47"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-7e243c8b15b6-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-7e243c8b15b6-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M48"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-78e4e5077d41-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-78e4e5077d41-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M49"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-9bb3331f4c02-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-9bb3331f4c02-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M50"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-7944acb700bd-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-7944acb700bd-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M51"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77de6f785ed7-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77de6f785ed7-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M52"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-5a8af3e97bdb-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-5a8af3e97bdb-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M53"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0a6a11f2da5-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0a6a11f2da5-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M54"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-9cea5d84733a-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-9cea5d84733a-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M55"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77e3e23961ab-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77e3e23961ab-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M56"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-35fb-4aa7-0136-5a7418ff37e8-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-35fb-4aa7-0136-5a7418ff37e8-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M57"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3676-1350-0136-9768076550f0-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3676-1350-0136-9768076550f0-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M58"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-78e0235b7b8b-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-78e0235b7b8b-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M59"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77f580ae6690-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77f580ae6690-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M60"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-78797547731a-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-78797547731a-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M61"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-c61d57895039-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-c61d57895039-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M62"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0cc617e335d-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0cc617e335d-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M63"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77fe9fdc6853-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77fe9fdc6853-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M64"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-7cc6b5b8011e-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-7cc6b5b8011e-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M65"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77e59fa3632e-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77e59fa3632e-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M66"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77ee2510640e-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77ee2510640e-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M67"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-35fb-4aa7-0136-1cb01c4d758c-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-35fb-4aa7-0136-1cb01c4d758c-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M68"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-b0dc53b034a7-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-b0dc53b034a7-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M69"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-a27b83221f9a-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-a27b83221f9a-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M70"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-a1e9806f0ef4-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-a1e9806f0ef4-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M71"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-7941863d7ffd-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-7941863d7ffd-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M72"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-c626c0935307-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-c626c0935307-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M73"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-c6208b875109-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-c6208b875109-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M74"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-d49a6c2a1dd7-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-d49a6c2a1dd7-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M75"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3946-cdae-0139-77e3674a60fc-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3946-cdae-0139-77e3674a60fc-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M76"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a58-b777-013a-652851981835-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a58-b777-013a-652851981835-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M77"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-373f-82e2-0137-be8bf22d0256-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-373f-82e2-0137-be8bf22d0256-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M78"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-397a-48d2-0139-c63d3e41543c-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-397a-48d2-0139-c63d3e41543c-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M79"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-40e66ce1333f-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-40e66ce1333f-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M80"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-39ca-af4b-0139-fedeeaa44f14-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-39ca-af4b-0139-fedeeaa44f14-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M81"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-407c78a12c20-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-407c78a12c20-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M82"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-4b4a282e7048-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-4b4a282e7048-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M83"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3a00-2a25-013a-4b927224747d-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3a00-2a25-013a-4b927224747d-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M84"/><svrl:active-pattern><axsl:attribute name="id">p-8a4d92b2-3927-d7ae-0139-366c49f93102-errors</axsl:attribute><axsl:attribute name="name">p-8a4d92b2-3927-d7ae-0139-366c49f93102-errors</axsl:attribute><axsl:apply-templates/></svrl:active-pattern><axsl:apply-templates select="/" mode="M85"/></svrl:schematron-output></axsl:template>

<!--SCHEMATRON PATTERNS-->


<!--PATTERN p-8a4d92b2-3887-5df3-0139-0d01c6626e46-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d01c6626e46']" priority="1000" mode="M6"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d01c6626e46']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/></axsl:template><axsl:template match="text()" priority="-1" mode="M6"/><axsl:template match="@*|node()" priority="-2" mode="M6"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M6"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-01954afc63b2-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01954afc63b2']" priority="1000" mode="M7"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01954afc63b2']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/></axsl:template><axsl:template match="text()" priority="-1" mode="M7"/><axsl:template match="@*|node()" priority="-2" mode="M7"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M7"/></axsl:template>

<!--PATTERN p-8a4d92b2-37bf-6f1b-0137-cdadba302b85-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37bf-6f1b-0137-cdadba302b85']" priority="1000" mode="M8"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37bf-6f1b-0137-cdadba302b85']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/></axsl:template><axsl:template match="text()" priority="-1" mode="M8"/><axsl:template match="@*|node()" priority="-2" mode="M8"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M8"/></axsl:template>

<!--PATTERN p-8a4d92b2-37d1-f95b-0137-e776b0467baf-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e776b0467baf']" priority="1000" mode="M9"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e776b0467baf']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template><axsl:template match="text()" priority="-1" mode="M9"/><axsl:template match="@*|node()" priority="-2" mode="M9"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M9"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-0dd50ce621d8-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-0dd50ce621d8']" priority="1000" mode="M10"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-0dd50ce621d8']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template><axsl:template match="text()" priority="-1" mode="M10"/><axsl:template match="@*|node()" priority="-2" mode="M10"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M10"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-01a1d2c966bc-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01a1d2c966bc']" priority="1000" mode="M11"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01a1d2c966bc']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template><axsl:template match="text()" priority="-1" mode="M11"/><axsl:template match="@*|node()" priority="-2" mode="M11"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M11"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-01959fb76498-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01959fb76498']" priority="1000" mode="M12"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01959fb76498']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template><axsl:template match="text()" priority="-1" mode="M12"/><axsl:template match="@*|node()" priority="-2" mode="M12"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M12"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0138-9b2eaba7321d-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0138-9b2eaba7321d']" priority="1000" mode="M13"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0138-9b2eaba7321d']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template><axsl:template match="text()" priority="-1" mode="M13"/><axsl:template match="@*|node()" priority="-2" mode="M13"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M13"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0c4e00454b35-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e00454b35']" priority="1000" mode="M14"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e00454b35']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a measure population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template><axsl:template match="text()" priority="-1" mode="M14"/><axsl:template match="@*|node()" priority="-2" mode="M14"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M14"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-01965ecf65be-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01965ecf65be']" priority="1000" mode="M15"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-01965ecf65be']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template><axsl:template match="text()" priority="-1" mode="M15"/><axsl:template match="@*|node()" priority="-2" mode="M15"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M15"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-018ce6f1622a-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-018ce6f1622a']" priority="1000" mode="M16"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-018ce6f1622a']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template><axsl:template match="text()" priority="-1" mode="M16"/><axsl:template match="@*|node()" priority="-2" mode="M16"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M16"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-dfaaffd96efe-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-dfaaffd96efe']" priority="1000" mode="M17"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-dfaaffd96efe']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template><axsl:template match="text()" priority="-1" mode="M17"/><axsl:template match="@*|node()" priority="-2" mode="M17"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M17"/></axsl:template>

<!--PATTERN p-8a4d92b2-37d1-f95b-0137-e1e272994b3f-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e1e272994b3f']" priority="1000" mode="M18"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e1e272994b3f']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template><axsl:template match="text()" priority="-1" mode="M18"/><axsl:template match="@*|node()" priority="-2" mode="M18"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M18"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a58-b777-013a-670ab6932a3b-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-670ab6932a3b']" priority="1000" mode="M19"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-670ab6932a3b']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template><axsl:template match="text()" priority="-1" mode="M19"/><axsl:template match="@*|node()" priority="-2" mode="M19"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M19"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-295ed21c463c-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-295ed21c463c']" priority="1000" mode="M20"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-295ed21c463c']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template><axsl:template match="text()" priority="-1" mode="M20"/><axsl:template match="@*|node()" priority="-2" mode="M20"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M20"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a58-b777-013a-716dfc096ee3-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-716dfc096ee3']" priority="1000" mode="M21"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-716dfc096ee3']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template><axsl:template match="text()" priority="-1" mode="M21"/><axsl:template match="@*|node()" priority="-2" mode="M21"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M21"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-4640d11650cb-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4640d11650cb']" priority="1000" mode="M22"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4640d11650cb']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template><axsl:template match="text()" priority="-1" mode="M22"/><axsl:template match="@*|node()" priority="-2" mode="M22"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M22"/></axsl:template>

<!--PATTERN p-8a4d92b2-37bf-6f1b-0137-ccd612a40d0e-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37bf-6f1b-0137-ccd612a40d0e']" priority="1000" mode="M23"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37bf-6f1b-0137-ccd612a40d0e']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template><axsl:template match="text()" priority="-1" mode="M23"/><axsl:template match="@*|node()" priority="-2" mode="M23"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M23"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0d071ee37793-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d071ee37793']" priority="1000" mode="M24"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d071ee37793']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template><axsl:template match="text()" priority="-1" mode="M24"/><axsl:template match="@*|node()" priority="-2" mode="M24"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M24"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-12364ae9126f-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-12364ae9126f']" priority="1000" mode="M25"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-12364ae9126f']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template><axsl:template match="text()" priority="-1" mode="M25"/><axsl:template match="@*|node()" priority="-2" mode="M25"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M25"/></axsl:template>

<!--PATTERN p-8a4d92b2-37d1-f95b-0137-dd4b0eb62de6-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-dd4b0eb62de6']" priority="1000" mode="M26"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-dd4b0eb62de6']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a measure population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template><axsl:template match="text()" priority="-1" mode="M26"/><axsl:template match="@*|node()" priority="-2" mode="M26"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M26"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0d08a4be7be6-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d08a4be7be6']" priority="1000" mode="M27"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0d08a4be7be6']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template><axsl:template match="text()" priority="-1" mode="M27"/><axsl:template match="@*|node()" priority="-2" mode="M27"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M27"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0c4e41594c98-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e41594c98']" priority="1000" mode="M28"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e41594c98']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='MSRPOPL']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a measure population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template><axsl:template match="text()" priority="-1" mode="M28"/><axsl:template match="@*|node()" priority="-2" mode="M28"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M28"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-11b262260a92-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-11b262260a92']" priority="1000" mode="M29"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-11b262260a92']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template><axsl:template match="text()" priority="-1" mode="M29"/><axsl:template match="@*|node()" priority="-2" mode="M29"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M29"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-013b0c87524a-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-013b0c87524a']" priority="1000" mode="M30"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-013b0c87524a']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template><axsl:template match="text()" priority="-1" mode="M30"/><axsl:template match="@*|node()" priority="-2" mode="M30"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M30"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0c49fb8c4757-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c49fb8c4757']" priority="1000" mode="M31"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c49fb8c4757']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template><axsl:template match="text()" priority="-1" mode="M31"/><axsl:template match="@*|node()" priority="-2" mode="M31"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M31"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0c4e6d2b4d6b-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e6d2b4d6b']" priority="1000" mode="M32"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c4e6d2b4d6b']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template><axsl:template match="text()" priority="-1" mode="M32"/><axsl:template match="@*|node()" priority="-2" mode="M32"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M32"/></axsl:template>

<!--PATTERN p-8a4d92b2-3887-5df3-0139-0c0d3d783133-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c0d3d783133']" priority="1000" mode="M33"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3887-5df3-0139-0c0d3d783133']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template><axsl:template match="text()" priority="-1" mode="M33"/><axsl:template match="@*|node()" priority="-2" mode="M33"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M33"/></axsl:template>

<!--PATTERN p-8a4d92b2-37d1-f95b-0137-e726ad2f7415-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e726ad2f7415']" priority="1000" mode="M34"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-37d1-f95b-0137-e726ad2f7415']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template><axsl:template match="text()" priority="-1" mode="M34"/><axsl:template match="@*|node()" priority="-2" mode="M34"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M34"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-cae9ed8a01bd-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-cae9ed8a01bd']" priority="1000" mode="M35"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-cae9ed8a01bd']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template><axsl:template match="text()" priority="-1" mode="M35"/><axsl:template match="@*|node()" priority="-2" mode="M35"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M35"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-9cd4937e6c86-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9cd4937e6c86']" priority="1000" mode="M36"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9cd4937e6c86']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template><axsl:template match="text()" priority="-1" mode="M36"/><axsl:template match="@*|node()" priority="-2" mode="M36"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M36"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-7ccb48f6025d-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7ccb48f6025d']" priority="1000" mode="M37"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7ccb48f6025d']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template><axsl:template match="text()" priority="-1" mode="M37"/><axsl:template match="@*|node()" priority="-2" mode="M37"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M37"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0cba8db32c3-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cba8db32c3']" priority="1000" mode="M38"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cba8db32c3']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template><axsl:template match="text()" priority="-1" mode="M38"/><axsl:template match="@*|node()" priority="-2" mode="M38"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M38"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0cadcb63221-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cadcb63221']" priority="1000" mode="M39"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cadcb63221']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template><axsl:template match="text()" priority="-1" mode="M39"/><axsl:template match="@*|node()" priority="-2" mode="M39"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M39"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-c648b33d5582-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c648b33d5582']" priority="1000" mode="M40"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c648b33d5582']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template><axsl:template match="text()" priority="-1" mode="M40"/><axsl:template match="@*|node()" priority="-2" mode="M40"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M40"/></axsl:template>

<!--PATTERN p-8a4d92b2-35fb-4aa7-0136-5a26000d30bd-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-5a26000d30bd']" priority="1000" mode="M41"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-5a26000d30bd']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template><axsl:template match="text()" priority="-1" mode="M41"/><axsl:template match="@*|node()" priority="-2" mode="M41"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M41"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-caf11e27054e-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-caf11e27054e']" priority="1000" mode="M42"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-caf11e27054e']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template><axsl:template match="text()" priority="-1" mode="M42"/><axsl:template match="@*|node()" priority="-2" mode="M42"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M42"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0a4bca22cf1-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0a4bca22cf1']" priority="1000" mode="M43"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0a4bca22cf1']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template><axsl:template match="text()" priority="-1" mode="M43"/><axsl:template match="@*|node()" priority="-2" mode="M43"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M43"/></axsl:template>

<!--PATTERN p-8a4d92b2-35fb-4aa7-0136-403ad4504573-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-403ad4504573']" priority="1000" mode="M44"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-403ad4504573']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template><axsl:template match="text()" priority="-1" mode="M44"/><axsl:template match="@*|node()" priority="-2" mode="M44"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M44"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-d472724e0c46-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-d472724e0c46']" priority="1000" mode="M45"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-d472724e0c46']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template><axsl:template match="text()" priority="-1" mode="M45"/><axsl:template match="@*|node()" priority="-2" mode="M45"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M45"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-795264d90290-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-795264d90290']" priority="1000" mode="M46"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-795264d90290']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template><axsl:template match="text()" priority="-1" mode="M46"/><axsl:template match="@*|node()" priority="-2" mode="M46"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M46"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-79591505044d-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-79591505044d']" priority="1000" mode="M47"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-79591505044d']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template><axsl:template match="text()" priority="-1" mode="M47"/><axsl:template match="@*|node()" priority="-2" mode="M47"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M47"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-7e243c8b15b6-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7e243c8b15b6']" priority="1000" mode="M48"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7e243c8b15b6']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M48"/></axsl:template><axsl:template match="text()" priority="-1" mode="M48"/><axsl:template match="@*|node()" priority="-2" mode="M48"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M48"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-78e4e5077d41-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78e4e5077d41']" priority="1000" mode="M49"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78e4e5077d41']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M49"/></axsl:template><axsl:template match="text()" priority="-1" mode="M49"/><axsl:template match="@*|node()" priority="-2" mode="M49"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M49"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-9bb3331f4c02-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9bb3331f4c02']" priority="1000" mode="M50"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9bb3331f4c02']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M50"/></axsl:template><axsl:template match="text()" priority="-1" mode="M50"/><axsl:template match="@*|node()" priority="-2" mode="M50"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M50"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-7944acb700bd-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-7944acb700bd']" priority="1000" mode="M51"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-7944acb700bd']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M51"/></axsl:template><axsl:template match="text()" priority="-1" mode="M51"/><axsl:template match="@*|node()" priority="-2" mode="M51"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M51"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77de6f785ed7-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77de6f785ed7']" priority="1000" mode="M52"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77de6f785ed7']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M52"/></axsl:template><axsl:template match="text()" priority="-1" mode="M52"/><axsl:template match="@*|node()" priority="-2" mode="M52"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M52"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-5a8af3e97bdb-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-5a8af3e97bdb']" priority="1000" mode="M53"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-5a8af3e97bdb']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M53"/></axsl:template><axsl:template match="text()" priority="-1" mode="M53"/><axsl:template match="@*|node()" priority="-2" mode="M53"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M53"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0a6a11f2da5-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0a6a11f2da5']" priority="1000" mode="M54"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0a6a11f2da5']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M54"/></axsl:template><axsl:template match="text()" priority="-1" mode="M54"/><axsl:template match="@*|node()" priority="-2" mode="M54"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M54"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-9cea5d84733a-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9cea5d84733a']" priority="1000" mode="M55"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-9cea5d84733a']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M55"/></axsl:template><axsl:template match="text()" priority="-1" mode="M55"/><axsl:template match="@*|node()" priority="-2" mode="M55"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M55"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77e3e23961ab-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e3e23961ab']" priority="1000" mode="M56"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e3e23961ab']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M56"/></axsl:template><axsl:template match="text()" priority="-1" mode="M56"/><axsl:template match="@*|node()" priority="-2" mode="M56"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M56"/></axsl:template>

<!--PATTERN p-8a4d92b2-35fb-4aa7-0136-5a7418ff37e8-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-5a7418ff37e8']" priority="1000" mode="M57"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-5a7418ff37e8']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M57"/></axsl:template><axsl:template match="text()" priority="-1" mode="M57"/><axsl:template match="@*|node()" priority="-2" mode="M57"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M57"/></axsl:template>

<!--PATTERN p-8a4d92b2-3676-1350-0136-9768076550f0-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3676-1350-0136-9768076550f0']" priority="1000" mode="M58"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3676-1350-0136-9768076550f0']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M58"/></axsl:template><axsl:template match="text()" priority="-1" mode="M58"/><axsl:template match="@*|node()" priority="-2" mode="M58"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M58"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-78e0235b7b8b-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78e0235b7b8b']" priority="1000" mode="M59"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78e0235b7b8b']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M59"/></axsl:template><axsl:template match="text()" priority="-1" mode="M59"/><axsl:template match="@*|node()" priority="-2" mode="M59"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M59"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77f580ae6690-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77f580ae6690']" priority="1000" mode="M60"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77f580ae6690']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M60"/></axsl:template><axsl:template match="text()" priority="-1" mode="M60"/><axsl:template match="@*|node()" priority="-2" mode="M60"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M60"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-78797547731a-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78797547731a']" priority="1000" mode="M61"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-78797547731a']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M61"/></axsl:template><axsl:template match="text()" priority="-1" mode="M61"/><axsl:template match="@*|node()" priority="-2" mode="M61"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M61"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-c61d57895039-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c61d57895039']" priority="1000" mode="M62"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c61d57895039']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M62"/></axsl:template><axsl:template match="text()" priority="-1" mode="M62"/><axsl:template match="@*|node()" priority="-2" mode="M62"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M62"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0cc617e335d-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cc617e335d']" priority="1000" mode="M63"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0cc617e335d']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M63"/></axsl:template><axsl:template match="text()" priority="-1" mode="M63"/><axsl:template match="@*|node()" priority="-2" mode="M63"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M63"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77fe9fdc6853-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77fe9fdc6853']" priority="1000" mode="M64"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77fe9fdc6853']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M64"/></axsl:template><axsl:template match="text()" priority="-1" mode="M64"/><axsl:template match="@*|node()" priority="-2" mode="M64"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M64"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-7cc6b5b8011e-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7cc6b5b8011e']" priority="1000" mode="M65"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-7cc6b5b8011e']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M65"/></axsl:template><axsl:template match="text()" priority="-1" mode="M65"/><axsl:template match="@*|node()" priority="-2" mode="M65"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M65"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77e59fa3632e-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e59fa3632e']" priority="1000" mode="M66"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e59fa3632e']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M66"/></axsl:template><axsl:template match="text()" priority="-1" mode="M66"/><axsl:template match="@*|node()" priority="-2" mode="M66"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M66"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77ee2510640e-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77ee2510640e']" priority="1000" mode="M67"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77ee2510640e']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M67"/></axsl:template><axsl:template match="text()" priority="-1" mode="M67"/><axsl:template match="@*|node()" priority="-2" mode="M67"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M67"/></axsl:template>

<!--PATTERN p-8a4d92b2-35fb-4aa7-0136-1cb01c4d758c-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-1cb01c4d758c']" priority="1000" mode="M68"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-35fb-4aa7-0136-1cb01c4d758c']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M68"/></axsl:template><axsl:template match="text()" priority="-1" mode="M68"/><axsl:template match="@*|node()" priority="-2" mode="M68"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M68"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-b0dc53b034a7-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0dc53b034a7']" priority="1000" mode="M69"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-b0dc53b034a7']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M69"/></axsl:template><axsl:template match="text()" priority="-1" mode="M69"/><axsl:template match="@*|node()" priority="-2" mode="M69"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M69"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-a27b83221f9a-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-a27b83221f9a']" priority="1000" mode="M70"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-a27b83221f9a']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M70"/></axsl:template><axsl:template match="text()" priority="-1" mode="M70"/><axsl:template match="@*|node()" priority="-2" mode="M70"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M70"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-a1e9806f0ef4-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-a1e9806f0ef4']" priority="1000" mode="M71"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-a1e9806f0ef4']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M71"/></axsl:template><axsl:template match="text()" priority="-1" mode="M71"/><axsl:template match="@*|node()" priority="-2" mode="M71"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M71"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-7941863d7ffd-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-7941863d7ffd']" priority="1000" mode="M72"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-7941863d7ffd']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M72"/></axsl:template><axsl:template match="text()" priority="-1" mode="M72"/><axsl:template match="@*|node()" priority="-2" mode="M72"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M72"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-c626c0935307-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c626c0935307']" priority="1000" mode="M73"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c626c0935307']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M73"/></axsl:template><axsl:template match="text()" priority="-1" mode="M73"/><axsl:template match="@*|node()" priority="-2" mode="M73"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M73"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-c6208b875109-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c6208b875109']" priority="1000" mode="M74"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c6208b875109']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M74"/></axsl:template><axsl:template match="text()" priority="-1" mode="M74"/><axsl:template match="@*|node()" priority="-2" mode="M74"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M74"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-d49a6c2a1dd7-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-d49a6c2a1dd7']" priority="1000" mode="M75"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-d49a6c2a1dd7']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M75"/></axsl:template><axsl:template match="text()" priority="-1" mode="M75"/><axsl:template match="@*|node()" priority="-2" mode="M75"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M75"/></axsl:template>

<!--PATTERN p-8a4d92b2-3946-cdae-0139-77e3674a60fc-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e3674a60fc']" priority="1000" mode="M76"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3946-cdae-0139-77e3674a60fc']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M76"/></axsl:template><axsl:template match="text()" priority="-1" mode="M76"/><axsl:template match="@*|node()" priority="-2" mode="M76"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M76"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a58-b777-013a-652851981835-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-652851981835']" priority="1000" mode="M77"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a58-b777-013a-652851981835']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M77"/></axsl:template><axsl:template match="text()" priority="-1" mode="M77"/><axsl:template match="@*|node()" priority="-2" mode="M77"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M77"/></axsl:template>

<!--PATTERN p-8a4d92b2-373f-82e2-0137-be8bf22d0256-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-373f-82e2-0137-be8bf22d0256']" priority="1000" mode="M78"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-373f-82e2-0137-be8bf22d0256']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M78"/></axsl:template><axsl:template match="text()" priority="-1" mode="M78"/><axsl:template match="@*|node()" priority="-2" mode="M78"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M78"/></axsl:template>

<!--PATTERN p-8a4d92b2-397a-48d2-0139-c63d3e41543c-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c63d3e41543c']" priority="1000" mode="M79"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-397a-48d2-0139-c63d3e41543c']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M79"/></axsl:template><axsl:template match="text()" priority="-1" mode="M79"/><axsl:template match="@*|node()" priority="-2" mode="M79"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M79"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-40e66ce1333f-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-40e66ce1333f']" priority="1000" mode="M80"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-40e66ce1333f']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M80"/></axsl:template><axsl:template match="text()" priority="-1" mode="M80"/><axsl:template match="@*|node()" priority="-2" mode="M80"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M80"/></axsl:template>

<!--PATTERN p-8a4d92b2-39ca-af4b-0139-fedeeaa44f14-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-fedeeaa44f14']" priority="1000" mode="M81"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-39ca-af4b-0139-fedeeaa44f14']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M81"/></axsl:template><axsl:template match="text()" priority="-1" mode="M81"/><axsl:template match="@*|node()" priority="-2" mode="M81"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M81"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-407c78a12c20-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-407c78a12c20']" priority="1000" mode="M82"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-407c78a12c20']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M82"/></axsl:template><axsl:template match="text()" priority="-1" mode="M82"/><axsl:template match="@*|node()" priority="-2" mode="M82"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M82"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-4b4a282e7048-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4b4a282e7048']" priority="1000" mode="M83"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4b4a282e7048']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M83"/></axsl:template><axsl:template match="text()" priority="-1" mode="M83"/><axsl:template match="@*|node()" priority="-2" mode="M83"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M83"/></axsl:template>

<!--PATTERN p-8a4d92b2-3a00-2a25-013a-4b927224747d-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4b927224747d']" priority="1000" mode="M84"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3a00-2a25-013a-4b927224747d']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENEX']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator exceptions</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M84"/></axsl:template><axsl:template match="text()" priority="-1" mode="M84"/><axsl:template match="@*|node()" priority="-2" mode="M84"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M84"/></axsl:template>

<!--PATTERN p-8a4d92b2-3927-d7ae-0139-366c49f93102-errors-->


	<!--RULE -->
<axsl:template match="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3927-d7ae-0139-366c49f93102']" priority="1000" mode="M85"><svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="cda:organizer[cda:reference/cda:externalDocument/cda:id/@root='8a4d92b2-3927-d7ae-0139-366c49f93102']"/>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='IPP']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report on initial patient population</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='DENOM']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a denominator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose>

		<!--ASSERT -->
<axsl:choose><axsl:when test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"/><axsl:otherwise><svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:schold="http://www.ascc.net/xml/schematron" test="count(cda:component/cda:observation/cda:value[@code='NUMER']) = 1"><axsl:attribute name="location"><axsl:apply-templates select="." mode="schematron-get-full-path"/></axsl:attribute><svrl:text>The QRDA Cat III report is required to report a numerator</svrl:text></svrl:failed-assert></axsl:otherwise></axsl:choose><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M85"/></axsl:template><axsl:template match="text()" priority="-1" mode="M85"/><axsl:template match="@*|node()" priority="-2" mode="M85"><axsl:apply-templates select="@*|*|comment()|processing-instruction()" mode="M85"/></axsl:template></axsl:stylesheet>
