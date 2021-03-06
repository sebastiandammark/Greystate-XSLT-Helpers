<?xml version="1.0"?>
<!-- 
	_MultiPickerHelper.xslt

	Helper file for rendering various datatypes that store node ids.
-->
<?umbraco-package XSLT Helpers v1.2.2 - MultiPickerHelper v1.1?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:umb="urn:umbraco.library" version="1.0" exclude-result-prefixes="umb">

	<xsl:key name="document-by-id" match="*[@isDoc]" use="@id"/>

	<xsl:template match="MultiNodePicker | XPathCheckBoxList | CheckBoxTree | WidgetGrid/*[nodeId]" mode="multipicker">
		<!-- Make possible to override the key used to retrieve nodes -->
		<xsl:param name="key" select="'document-by-id'"/>
		
	<!--
		This does the equivalent of calling the `key()` function for every `<nodeId>`,
		collecting the resulting documents into a node-set.

		Ideally we could just apply templates to that set, but unfortunately the nodes
		will be processed in document order, so we need to somehow use the position of
		the nodeId elements as the sort order.
	-->
		<!-- Grab all the selected nodes using the key -->
		<xsl:variable name="nodes" select="key($key, nodeId)"/>

		<!-- We need a reference back to the nodeId elements, so collect them -->
		<xsl:variable name="nodeIds" select="nodeId"/>
		
		<!-- We can't use position like this: $nodeIds[. current()/@id]/position(), so instead count the number of preceding siblings -->
		<xsl:apply-templates select="$nodes">
			<xsl:sort select="count($nodeIds[. = current()/@id]/preceding-sibling::nodeId)" data-type="number" order="ascending"/>
		</xsl:apply-templates>
		
	</xsl:template>
	
	<xsl:template match="MultiNodePicker[@type = 'media']" mode="multipicker">
		<xsl:for-each select="nodeId">
			<xsl:variable name="mediaNode" select="umb:GetMedia(., false())"/>
			<xsl:apply-templates select="$mediaNode[not(error)]"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Template to soak up text nodes being applied by the built-in templates -->
	<xsl:template match="text()" mode="multipicker" priority="-1"/>

</xsl:stylesheet>
