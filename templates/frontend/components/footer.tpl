{**
 * templates/frontend/components/footer.tpl
 *
 * Journal Metrics theme. Based on lib/pkp/templates/frontend/components/footer.tpl.
 * Adds a dark footer with journal identity and the main navigation links.
 *
 *
 * @hook Templates::Common::Footer::PageFooter []
 *}

			</main><!-- pkp_structure_main -->

</div><!-- pkp_structure_content -->

<div class="pkp_structure_footer_wrapper" role="contentinfo">
	<a id="pkp_content_footer"></a>

	<div class="pkp_structure_footer">

		{if $currentContext}
			<div class="jm_footer_grid">
				<div class="jm_footer_id">
					<p class="jm_footer_name">{$currentContext->getLocalizedName()|escape}</p>
					{assign var="jmFooterIssn" value=$currentContext->getData('onlineIssn')|default:$currentContext->getData('printIssn')}
					{if $jmFooterIssn}<p class="jm_footer_meta">{translate key="plugins.themes.journalMetrics.footer.issn" issn=$jmFooterIssn|escape}</p>{/if}
					{if $currentContext->getData('publisherInstitution')}<p class="jm_footer_meta">{$currentContext->getData('publisherInstitution')|escape}</p>{/if}
				</div>
				<nav class="jm_footer_nav" aria-label="{translate|escape key="common.navigation.site"}">
					<ul>
						<li><a href="{url page="issue" op="current"}">{translate key="journal.currentIssue"}</a></li>
						<li><a href="{url page="issue" op="archive"}">{translate key="navigation.archives"}</a></li>
						<li><a href="{url page="about" op="submissions"}">{translate key="about.submissions"}</a></li>
						<li><a href="{url page="about" op="editorialMasthead"}">{translate key="common.editorialMasthead"}</a></li>
						<li><a href="{url page="about" op="contact"}">{translate key="about.contact"}</a></li>
						{if $currentContext->getLocalizedData('readerInformation')}<li><a href="{url page="information" op="readers"}">{translate key="navigation.infoForReaders"}</a></li>{/if}
						{if $currentContext->getLocalizedData('authorInformation')}<li><a href="{url page="information" op="authors"}">{translate key="navigation.infoForAuthors"}</a></li>{/if}
						{if $currentContext->getLocalizedData('librarianInformation')}<li><a href="{url page="information" op="librarians"}">{translate key="navigation.infoForLibrarians"}</a></li>{/if}
					</ul>
				</nav>
			</div>
		{/if}

		{if $pageFooter}
			<div class="pkp_footer_content">
				{$pageFooter}
			</div>
		{/if}

		<div class="jm_footer_bottom">
			<div class="pkp_brand_footer">
				<a href="{url page="about" op="aboutThisPublishingSystem"}">
					<img alt="{translate key="about.aboutThisPublishingSystem"}" src="{$baseUrl}/{$brandImage}">
				</a>
			</div>
			<p class="jm_footer_credit">
				Theme {translate key="plugins.themes.journalMetrics.footer.developedBy"}
				<a href="https://orcid.org/0000-0002-2648-5726" target="_blank" rel="noopener author"><span class="jm_orcid_icon" aria-hidden="true">iD</span>Oleksandr Radkevych</a>
			</p>
		</div>
	</div>
</div><!-- pkp_structure_footer_wrapper -->

</div><!-- pkp_structure_page -->

{load_script context="frontend"}

{call_hook name="Templates::Common::Footer::PageFooter"}
</body>
</html>
