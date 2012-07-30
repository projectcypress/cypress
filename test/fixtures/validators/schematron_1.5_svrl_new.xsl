<?xml version="1.0" ?>
<!-- 
   ISO_SVRL.xsl   

   Implementation of Schematron Validation Report Language from ISO Schematron
   ISO/IEC 19757 Document Schema Definition Languages (DSDL) 
     Part 3: Rule-based validation  Schematron 
     Annex D: Schematron Validation Report Language 

  This ISO Standard is available free as a Publicly Available Specification in PDF from ISO.
  Also see www.schematron.com for drafts and other information.

  This implementation of SVRL is designed to run with the "Skeleton" implementation 
  of Schematron which Oliver Becker devised. The skeleton code provides a 
  Schematron implementation but with named templates for handling all output; 
  the skeleton provides basic templates for output using this API, but client
  validators can be written to import the skeleton and override the default output
  templates as required. (In order to understand this, you must understand that
  a named template such as "process-assert" in this XSLT stylesheet overrides and
  replaces any template with the same name in the imported skeleton XSLT file.)

  The other important thing to understand in this code is that there are different
  versions of the Schematron skeleton. These track the development of Schematron through
  Schematron 1.5, Schematron 1.6 and now ISO Schematron. One only skeleton must be
  imported. The code has templates for the different skeletons commented out for 
  convenience. ISO Schematron has a different namespace than Schematron 1.5 and 1.6;
  so the ISO Schematron skeleton has been written itself with an optional import
  statement to in turn import the Schematron 1.6 skeleton. This will allow you to 
  validate with schemas from either namespace.
  

  History:
    2007-04-03 
    	* Add option generate-fired-rule (RG)
    2007-02-07
    	* Prefer true|false for parameters. But allow yes|no on some old for compatability
    	* DP Diagnostics output to svrl:text. Diagnosis put out after assertion text.
      	* Removed non-SVRL elements and attributes: better handled as an extra layer that invokes this one
      	* Add more formal parameters
      	* Correct confusion between $schemaVersion and $queryBinding
     	* Indent
     	* Validate against RNC schemas for XSLT 1 and 2 (with regex tests removed)
     	* Validate output with UniversalTest.sch against RNC schema for ISO SVRL
    	
    2007-02-01
       	* DP. Update formal parameters of overriding named templates to handle more attributes.
       	* DP. Refactor handling of rich and linkable parameters to a named template.

    2007-01-22
    	* DP change svrl:ns to svrl:ns-in-attribute-value
		* Change default when no queryBinding from "unknown" to "xslt"
	
    2007-01-18:
     	* Improve documentation
     	* KH Add command-line options to generate paths or not 
       	* Use axsl:attribute rather than xsl:attribute to shut XSLT2 up
       	* Add extra command-line options to pass to the iso_schematron_skeleton
  
    2006-12-01: iso_svrl.xsl Rick Jelliffe, 
          * update namespace, 
          * update phase handling,
          * add flag param to process-assert and process-report & @ flag on output
  
    2001: Conformance1-5.xsl Rick Jelliffe, 
          * Created, using the skeleton code contributed by Oliver Becker
-->
<!--
 Derived from Conformance1-5.xsl.

 Copyright (c) 2001, 2006 Rick Jelliffe and Academia Sinica Computing Center, Taiwan

 This software is provided 'as-is', without any express or implied warranty. 
 In no event will the authors be held liable for any damages arising from 
 the use of this software.

 Permission is granted to anyone to use this software for any purpose, 
 including commercial applications, and to alter it and redistribute it freely,
 subject to the following restrictions:

 1. The origin of this software must not be misrepresented; you must not claim
 that you wrote the original software. If you use this software in a product, 
 an acknowledgment in the product documentation would be appreciated but is 
 not required.

 2. Altered source versions must be plainly marked as such, and must not be 
 misrepresented as being the original software.

 3. This notice may not be removed or altered from any source distribution.
-->

<!-- Ideas nabbed from schematrons by Francis N., Miloslav N. and David C. -->

<!-- The command-line parameters are:
  			phase           NMTOKEN | "#ALL" (default) Select the phase for validation
    		allow-foreign   "true" | "false" (default)   Pass non-Schematron elements to the generated stylesheet
            diagnose= true | false|yes|no    Add the diagnostics to the assertion test in reports (yes|no are obsolete)
            generate-paths=true|false|yes|no   generate the @location attribute with XPaths (yes|no are obsolete)
            sch.exslt.imports semi-colon delimited string of filenames for some EXSLT implementations          
   		 optimize        "visit-no-attributes"     Use only when the schema has no attributes as the context nodes
		 generate-fired-rule "true"(default) | "false"  Generate fired-rule elements
            
-->

<xsl:stylesheet
   version="1.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
   xmlns:sch="http://www.ascc.net/xml/schematron"
   xmlns:iso="http://purl.oclc.org/dsdl/schematron"
   xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 
>

<!-- Select the import statement and adjust the path as 
   necessary for your system.
-->

<xsl:import href="skeleton1-5.xsl"/>
<!--
<xsl:import href="iso_schematron_skeleton.xsl"/>
<xsl:import href="skeleton1-6.xsl"/>
-->

<xsl:param name="diagnose">true</xsl:param>
<xsl:param name="phase">
	<xsl:choose>
		<!-- Handle Schematron 1.5 and 1.6 phases -->
		<xsl:when test="//sch:schema/@defaultPhase">
			<xsl:value-of select="//sch:schema/@defaultPhase"/>
		</xsl:when>
		<!-- Handle ISO Schematron phases -->
		<xsl:when test="//iso:schema/@defaultPhase">
			<xsl:value-of select="//iso:schema/@defaultPhase"/>
		</xsl:when>
		<xsl:otherwise>#ALL</xsl:otherwise>
	</xsl:choose>
</xsl:param>
<xsl:param name="allow-foreign">false</xsl:param>
<xsl:param name="generate-paths">true</xsl:param>
<xsl:param name="generate-fired-rule">true</xsl:param>
<xsl:param name="optimize" />
<!-- e.g. saxon file.xml file.xsl "sch.exslt.imports=.../string.xsl;.../math.xsl" -->
<xsl:param name="sch.exslt.imports"/>

<!-- Experimental: If this file called, then must be generating svrl -->
<xsl:variable name="svrlTest" select="true()" />

<!-- ================================================================ -->

<xsl:template name="process-prolog">
	<axsl:output method="xml" omit-xml-declaration="no" standalone="yes"
		indent="yes"/>
</xsl:template>


<!-- SCHEMA -->
<xsl:template match="sch:schema | schema">
    <axsl:stylesheet version="1.0">
        <xsl:for-each select="sch:ns | ns">
            <xsl:attribute name="{concat(@prefix,':dummy-for-xmlns')}" namespace="{@uri}"/>
        </xsl:for-each>
 
        <xsl:if test="count(sch:title/* | title/* )">
            <xsl:message>
                <xsl:text>Warning: </xsl:text>
                <xsl:value-of select="name(.)"/>
                <xsl:text> must not contain any child elements</xsl:text>
            </xsl:message>
        </xsl:if>
 
        <xsl:call-template name="process-prolog"/>
        <!-- utility routine for implementations -->
        <axsl:template match="*|@*" mode="schematron-get-full-path">

            <axsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
            <axsl:text>/</axsl:text>
            <axsl:if test="count(. | ../@*) = count(../@*)">@</axsl:if>
            <axsl:value-of select="name()"/>
            <axsl:text>[</axsl:text>
            <axsl:value-of select="1+count(preceding-sibling::*[name()=name(current())])"/>
            <axsl:text>]</axsl:text>
            </axsl:template>

        <xsl:apply-templates mode="do-keys" 
                select="sch:pattern/sch:rule/sch:key | pattern/rule/key | sch:key | key "/>

       
        <axsl:template match="/">
            <xsl:call-template name="process-root">
                <xsl:with-param name="fpi" select="@fpi"/>
                <xsl:with-param     xmlns:sch="http://www.ascc.net/xml/schematron"
                name="title" select="./sch:title | title"/>
                <xsl:with-param name="id" select="@id"/>
                <xsl:with-param name="icon" select="@icon"/>
                <xsl:with-param name="lang" select="@xml:lang"/>
                <xsl:with-param name="version" select="@version" />
                <xsl:with-param name="schemaVersion" select="@schemaVersion" />
                <xsl:with-param name="contents">
                    <xsl:apply-templates select="//sch:phase"/>
                </xsl:with-param>
            </xsl:call-template>
        </axsl:template>
    
        <xsl:apply-templates/>
        <axsl:template match="text()" priority="-1">
            <!-- strip characters -->
        </axsl:template>
    </axsl:stylesheet>
</xsl:template>


<xsl:template match="/sch:schema/sch:phase" >

    <svrl:phase id="{./@id}">
        <xsl:apply-templates />
    </svrl:phase>
</xsl:template>

<xsl:template match="sch:active | active" >
     
       <xsl:variable name="pat" select="@pattern" />
        <xsl:apply-templates select="//sch:pattern[@id=$pat]" mode="do-all-patterns"/>
    
</xsl:template>

<!-- Overrides skeleton.xsl -->
<xsl:template name="process-root">
	<xsl:param name="title"/>
	<xsl:param name="contents" />
	<xsl:param name="queryBinding" >xslt1</xsl:param>
	<xsl:param name="schemaVersion" />
	<xsl:param name="id" />
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	
	<svrl:schematron-output title="{$title}" schemaVersion="{$schemaVersion}" >
		<xsl:if test=" string-length( normalize-space( $phase )) &gt; 0 and 
		not( normalize-space( $phase ) = '#ALL') ">
			<axsl:attribute name="phase">
				<xsl:value-of select=" $phase " />
			</axsl:attribute>
		</xsl:if>
		<xsl:apply-templates mode="do-schema-p" />
		<xsl:copy-of select="$contents" />
	</svrl:schematron-output>
</xsl:template>


<xsl:template name="process-assert">
	<xsl:param name="test"/>
	<xsl:param name="diagnostics" />
	<xsl:param name="id" />
	<xsl:param name="flag" />
	<!-- "Linkable" parameters -->
	<xsl:param name="role"/>
	<xsl:param name="subject"/>
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<svrl:failed-assert test="{$test}" >
		<xsl:if test="string-length( $id ) &gt; 0">
			<axsl:attribute name="id">
				<xsl:value-of select=" $id " />
			</axsl:attribute>
		</xsl:if>
		<xsl:if test=" string-length( $flag ) &gt; 0">
			<axsl:attribute name="flag">
				<xsl:value-of select=" $flag " />
			</axsl:attribute>
		</xsl:if>
		<!-- Process rich attributes.  -->
		<xsl:call-template name="richParms">
			<xsl:with-param name="fpi" select="$fpi"/>
			<xsl:with-param name="icon" select="$icon"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="see" select="$see" />
			<xsl:with-param name="space" select="$space" />
		</xsl:call-template>
		<xsl:call-template name='linkableParms'>
			<xsl:with-param name="role" select="$role" />
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
		<xsl:if test=" $generate-paths = 'true' or $generate-paths= 'yes' ">
			<!-- true/false is the new way -->
			<axsl:attribute name="location">
				<axsl:apply-templates select="." mode="schematron-get-full-path"/>
			</axsl:attribute>
		</xsl:if>
		<svrl:text>
			<xsl:apply-templates mode="text" />
	
		    <xsl:if test="$diagnose = 'yes' or $diagnose= 'true' ">
			<!-- true/false is the new way -->
				<xsl:call-template name="diagnosticsSplit">
					<xsl:with-param name="str" select="$diagnostics"/>
				</xsl:call-template>
			</xsl:if>
		</svrl:text>
	</svrl:failed-assert>
</xsl:template>

<xsl:template name="process-report">
	<xsl:param name="id"/>
	<xsl:param name="test"/>
	<xsl:param name="diagnostics"/>
	<xsl:param name="flag" />
	<!-- "Linkable" parameters -->
	<xsl:param name="role"/>
	<xsl:param name="subject"/>
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<svrl:successful-report test="{$test}" >
		<xsl:if test=" string-length( $id ) &gt; 0">
			<axsl:attribute name="id">
				<xsl:value-of select=" $id " />
			</axsl:attribute>
		</xsl:if>
		<xsl:if test=" string-length( $flag ) &gt; 0">
			<axsl:attribute name="flag">
				<xsl:value-of select=" $flag " />
			</axsl:attribute>
		</xsl:if>
		
		<!-- Process rich attributes.  -->
		<xsl:call-template name="richParms">
			<xsl:with-param name="fpi" select="$fpi"/>
			<xsl:with-param name="icon" select="$icon"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="see" select="$see" />
			<xsl:with-param name="space" select="$space" />
		</xsl:call-template>
		<xsl:call-template name='linkableParms'>
			<xsl:with-param name="role" select="$role" />
			<xsl:with-param name="subject" select="$subject"/>
		</xsl:call-template>
		<xsl:if test=" $generate-paths = 'yes' or $generate-paths = 'true' ">
			<!-- true/false is the new way -->
			<axsl:attribute name="location">
				<axsl:apply-templates select="." mode="schematron-get-full-path"/>
			</axsl:attribute>
		</xsl:if>
		<svrl:text>
			<xsl:apply-templates mode="text" />

			<xsl:if test="$diagnose = 'yes' or $diagnose='true' ">
			<!-- true/false is the new way -->
				<xsl:call-template name="diagnosticsSplit">
					<xsl:with-param name="str" select="$diagnostics"/>
				</xsl:call-template>
			</xsl:if>
		</svrl:text>
	</svrl:successful-report>
</xsl:template>


<xsl:template name="process-diagnostic">
	<xsl:param name="id"/>
	<!-- Rich parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<svrl:diagnostic-reference diagnostic="{$id}" >
		<xsl:if test="string($id)">
			<xsl:attribute name="id">
				<xsl:value-of select="$id"/>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="richParms">
			<xsl:with-param name="fpi" select="$fpi"/>
			<xsl:with-param name="icon" select="$icon"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="see" select="$see" />
			<xsl:with-param name="space" select="$space" />
		</xsl:call-template>
		<svrl:text>
		</svrl:text>
		<xsl:apply-templates mode="text"/>
	</svrl:diagnostic-reference>
</xsl:template>

<xsl:template name="process-rule">
	<xsl:param name="id"/>
	<xsl:param name="context"/>
	<xsl:param name="flag"/>
	<!-- "Linkable" parameters -->
	<xsl:param name="role"/>
	<xsl:param name="subject"/>
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<xsl:if test=" $generate-fired-rule = 'true'">
	<svrl:fired-rule context="{$context}" >
		<!-- Process rich attributes.  -->
		<xsl:call-template name="richParms">
			<xsl:with-param name="fpi" select="$fpi"/>
			<xsl:with-param name="icon" select="$icon"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="see" select="$see" />
			<xsl:with-param name="space" select="$space" />
		</xsl:call-template>
		<xsl:if test=" string( $id )">
			<xsl:attribute name="id">
				<xsl:value-of select=" $id " />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test=" string-length( $role ) &gt; 0">
			<xsl:attribute name="role">
				<xsl:value-of select=" $role " />
			</xsl:attribute>
		</xsl:if>
		
	</svrl:fired-rule>
</xsl:if>
</xsl:template>

<xsl:template name="process-ns">
	<xsl:param name="prefix"/>
	<xsl:param name="uri"/>
	<svrl:ns-prefix-in-attribute-values uri="{$uri}" prefix="{$prefix}" />
</xsl:template>

<xsl:template name="process-p">
	<xsl:param name="role"/>
	<xsl:param name="icon"/>
	<xsl:param name="id"/>
	<xsl:param name="lang"/>

	<svrl:text>
		<xsl:apply-templates mode="text"/>
	</svrl:text>
</xsl:template>

<xsl:template name="process-pattern">
	<xsl:param name="name"/>
	<xsl:param name="id"/>
	<xsl:param name="is-a"/>
	
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<svrl:active-pattern >
		<xsl:if test=" string( $id )">
			<axsl:attribute name="id">
				<xsl:value-of select=" $id " />
			</axsl:attribute>
		</xsl:if>
		<xsl:if test=" string( $name )">
			<axsl:attribute name="name">
				<xsl:value-of select=" $name " />
			</axsl:attribute>
		</xsl:if>
		
		<xsl:call-template name='richParms'>
			<xsl:with-param name="fpi" select="$fpi"/>
			<xsl:with-param name="icon" select="$icon"/>
			<xsl:with-param name="lang" select="$lang"/>
			<xsl:with-param name="see" select="$see" />
			<xsl:with-param name="space" select="$space" />
		</xsl:call-template>
		
		<!-- ?? report that this screws up iso:title processing  -->
		<xsl:apply-templates mode="do-pattern-p"/>
		<!-- ?? Seems that this apply-templates is never triggered DP -->
		<axsl:apply-templates />
	</svrl:active-pattern>
</xsl:template>

<!-- Overrides skeleton -->
<xsl:template name="process-message"/> 


<!-- =========================================================================== -->
<!-- processing rich parameters. -->
<xsl:template name='richParms'>
	<!-- "Rich" parameters -->
	<xsl:param name="fpi" />
	<xsl:param name="icon" />
	<xsl:param name="lang" />
	<xsl:param name="see" />
	<xsl:param name="space" />
	<!-- Process rich attributes.  -->
	<xsl:if test="string($space)">
		<axsl:attribute name="xml:space">
			<xsl:value-of select="$space"/>
		</axsl:attribute>
	</xsl:if>
	<xsl:if test="string($lang)">
		<axsl:attribute name="xml:lang">
			<xsl:value-of select="$lang"/>
		</axsl:attribute>
	</xsl:if>
</xsl:template>

<!-- processing linkable parameters. -->
<xsl:template name='linkableParms'>
	<xsl:param name="role"/>
	<xsl:param name="subject"/>
	
	<!-- ISO SVRL has a role attribute to match the Schematron role attribute -->
	<xsl:if test=" string($role )">
		<axsl:attribute name="role">
			<xsl:value-of select=" $role " />
		</axsl:attribute>
	</xsl:if>
	<!-- ISO SVRL does not have a subject attribute to match the Schematron subject attribute.
       Instead, the Schematron subject attribute is folded into the location attribute -->
</xsl:template>


</xsl:stylesheet>

