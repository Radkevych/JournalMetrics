{**
 * templates/frontend/objects/article_details.tpl
 *
 * Journal Metrics theme. Based on templates/frontend/objects/article_details.tpl
 * of OJS 3.5. The reading column follows one fixed order:
 * title, publication date, authors, DOI and issue, galleys (PDF), abstract,
 * keywords, author biographies, references. The side column holds, from the top:
 * how to cite / citation formats / sharing, article details, usage, licence.
 *
 * @uses $article Submission This article
 * @uses $publication Publication The publication being displayed
 * @uses $firstPublication Publication The first published version of this article
 * @uses $currentPublication Publication The most recently published version of this article
 * @uses $issue Issue The issue this article is assigned to
 * @uses $section Section The journal section this article is assigned to
 * @uses $categories Category The category this article is assigned to
 * @uses $primaryGalleys array List of article galleys that are not supplementary or dependent
 * @uses $supplementaryGalleys array List of article galleys that are supplementary
 * @uses $pubIdPlugins Array of pubId plugins which this article may be assigned
 * @uses $ccLicenseBadge string An image and text with details about the license
 *
 * @hook Templates::Article::Main []
 * @hook Templates::Article::Details::Reference []
 * @hook Templates::Article::Details []
 *}
<article class="obj_article_details jm_article_page">

	{* Indicate if this is only a preview *}
	{if $publication->getData('status') !== PKP\submission\PKPSubmission::STATUS_PUBLISHED}
	<div class="cmp_notification notice">
		{capture assign="submissionUrl"}{url page="dashboard" op="editorial" workflowSubmissionId=$article->getId()}{/capture}
		{translate key="submission.viewingPreview" url=$submissionUrl}
	</div>
	{* Notification that this is an old version *}
	{elseif $currentPublication->getId() !== $publication->getId()}
		<div class="cmp_notification notice">
			{capture assign="latestVersionUrl"}{url page="article" op="view" path=$article->getBestId()}{/capture}
			{translate key="submission.outdatedVersion"
				datePublished=$publication->getData('datePublished')|date_format:$dateFormatShort
				urlRecentVersion=$latestVersionUrl|escape
			}
		</div>
	{/if}

	<div class="jm_article_layout">

		<div class="jm_article_body">

			{* 1. Title *}
			<header class="jm_article_head">
				{if $section || $issue}
					<p class="jm_eyebrow">
						{if $section}{$section->getLocalizedTitle()|escape}{/if}
						{if $section && $issue} · {/if}
						{if $issue}{$issue->getIssueIdentification()|escape}{/if}
						{if $publication->getData('pages')} · {translate key="plugins.themes.journalMetrics.article.pages"} {$publication->getData('pages')|escape}{/if}
					</p>
				{/if}
				<h1 class="page_title">
					{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
				</h1>
				{if $publication->getLocalizedData('subtitle')}
					<p class="subtitle">
						{$publication->getLocalizedSubTitle(null, 'html')|strip_unsafe_html}
					</p>
				{/if}

				{* 2. Publication date *}
				{if $publication->getData('datePublished')}
					<p class="jm_published">
						<span class="jm_published_label">{translate key="submissions.published"}</span>
						{if $firstPublication->getId() === $publication->getId()}
							<time datetime="{$firstPublication->getData('datePublished')|date_format:"%Y-%m-%d"}">{$firstPublication->getData('datePublished')|date_format:$dateFormatShort}</time>
						{else}
							{translate key="submission.updatedOn" datePublished=$firstPublication->getData('datePublished')|date_format:$dateFormatShort dateUpdated=$publication->getData('datePublished')|date_format:$dateFormatShort}
						{/if}
					</p>
				{/if}
			</header>

			{* 3. Authors *}
			{if $publication->getData('authors')}
				<section class="item authors jm_authors">
					<h2 class="pkp_screen_reader">{translate key="article.authors"}</h2>
					<ul class="authors">
					{foreach from=$publication->getData('authors') item=author}
						<li>
							<span class="name">
								{$author->getFullName()|escape}
							</span>
							{if count($author->getAffiliations()) > 0}
								<span class="affiliation">
									{assign var="renderedAffiliation" value=false}
									{foreach from=$author->getAffiliations() item="affiliation"}
										{if $affiliation->getLocalizedName() || $affiliation->getRor()}
											{if $renderedAffiliation}{translate key="common.commaListSeparator"}{/if}
											{if $affiliation->getLocalizedName()}<span>{$affiliation->getLocalizedName()|escape}</span>{/if}
											{if $affiliation->getRor()}<a href="{$affiliation->getRor()|escape}">{$rorIdIcon}</a>{/if}
											{assign var="renderedAffiliation" value=true}
										{/if}
									{/foreach}
								</span>
							{/if}
							{assign var=authorUserGroup value=$userGroupsById[$author->getData('userGroupId')]}
							{if $authorUserGroup->showTitle}
								<span class="userGroup">
									{$authorUserGroup->getLocalizedData('name')|escape}
								</span>
							{/if}
							{if $author->getData('orcid')}
								<span class="orcid">
									{if $author->hasVerifiedOrcid()}
										{$orcidIcon}
									{else}
										{$orcidUnauthenticatedIcon}
									{/if}
									<a href="{$author->getData('orcid')|escape}" target="_blank" rel="noopener">
										{$author->getOrcidDisplayValue()|escape}
									</a>
								</span>
							{/if}
						</li>
					{/foreach}
					</ul>
				</section>
			{/if}

			{* DOI *}
			{assign var=doiObject value=$article->getCurrentPublication()->getData('doiObject')}
			{if $doiObject}
				{assign var="doiUrl" value=$doiObject->getData('resolvingUrl')|escape}
				<p class="item doi jm_doi">
					<span class="jm_doi_label">{translate key="doi.readerDisplayName"}</span>
					<a class="jm_mono" href="{$doiUrl}">{$doiUrl}</a>
				</p>
			{/if}

			{* Galleys: PDF and other full texts *}
			{if $primaryGalleys || $supplementaryGalleys}
				<div class="item galleys jm_galleys">
					<h2 class="pkp_screen_reader">{translate key="submission.downloads"}</h2>
					<ul class="value galleys_links">
						{foreach from=$primaryGalleys item=galley}
							<li>
								{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
							</li>
						{/foreach}
						{foreach from=$supplementaryGalleys item=galley}
							<li>
								{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication galley=$galley isSupplementary="1"}
							</li>
						{/foreach}
					</ul>
				</div>
			{/if}

			{* 4. Abstract *}
			{if $publication->getLocalizedData('abstract')}
				<section class="item abstract">
					<h2 class="label">{translate key="article.abstract"}</h2>
					{$publication->getLocalizedData('abstract')|strip_unsafe_html}
				</section>
			{/if}

			{* 5. Keywords *}
			{if !empty($publication->getLocalizedData('keywords'))}
				<section class="item keywords">
					<h2 class="label">{translate key="article.subject"}</h2>
					<ul class="jm_keywords">
						{foreach from=$publication->getLocalizedData('keywords') item="keyword"}
							<li>{$keyword.name|escape}</li>
						{/foreach}
					</ul>
				</section>
			{/if}

			{call_hook name="Templates::Article::Main"}

			{* 6. Author biographies *}
			{assign var="hasBiographies" value=0}
			{foreach from=$publication->getData('authors') item=author}
				{if $author->getLocalizedData('biography')}
					{assign var="hasBiographies" value=$hasBiographies+1}
				{/if}
			{/foreach}
			{if $hasBiographies}
				<section class="item author_bios">
					<h2 class="label">
						{if $hasBiographies > 1}
							{translate key="submission.authorBiographies"}
						{else}
							{translate key="submission.authorBiography"}
						{/if}
					</h2>
					<ul class="jm_bios">
					{foreach from=$publication->getData('authors') item=author}
						{if $author->getLocalizedData('biography')}
							<li class="jm_bio">
								<p class="jm_bio_name">{$author->getFullName()|escape}</p>
								<div class="jm_bio_text">
									{$author->getLocalizedData('biography')|strip_unsafe_html}
								</div>
								{if $author->getData('orcid')}
									<p class="jm_bio_orcid"><a class="jm_mono" href="{$author->getData('orcid')|escape}" target="_blank" rel="noopener">{$author->getData('orcid')|escape}</a></p>
								{/if}
							</li>
						{/if}
					{/foreach}
					</ul>
				</section>
			{/if}

			{* 7. References *}
			{if count($parsedCitations) || (string) $publication->getData('citationsRaw')}
				<section class="item references">
					<h2 class="label">
						{translate key="submission.citations"}
					</h2>
					<div class="value">
						{if count($parsedCitations)}
							{foreach from=$parsedCitations item="parsedCitation"}
								<p>{$parsedCitation->getCitationWithLinks()|strip_unsafe_html} {call_hook name="Templates::Article::Details::Reference" citation=$parsedCitation}</p>
							{/foreach}
						{else}
							{$publication->getData('citationsRaw')|escape|nl2br}
						{/if}
					</div>
				</section>
			{/if}

		</div><!-- .jm_article_body -->

		<aside class="jm_article_aside" aria-label="{translate|escape key="plugins.themes.journalMetrics.article.details"}">

			{* Cover image *}
			{if $publication->getLocalizedData('coverImage') || ($issue && $issue->getLocalizedCoverImage())}
				<div class="jm_card jm_card_cover">
					{if $publication->getLocalizedData('coverImage')}
						{assign var="coverImage" value=$publication->getLocalizedData('coverImage')}
						<img
							src="{$publication->getLocalizedCoverImageUrl($article->getData('contextId'))|escape}"
							alt="{$coverImage.altText|escape|default:''}"
						>
					{else}
						<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
							<img src="{$issue->getLocalizedCoverImageUrl()|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:''}">
						</a>
					{/if}
				</div>
			{/if}

			{* How to cite, citation formats, download citation and sharing: output of the
			   plugins that use the Templates::Article::Details hook (Citation Style Language and others) *}
			{capture assign="jmCite"}{call_hook name="Templates::Article::Details"}{/capture}
			{if $jmCite|trim}
				<section class="jm_card jm_cite">
					{$jmCite}
				</section>
			{/if}

			<section class="jm_card">
				<h2>{translate key="plugins.themes.journalMetrics.article.details"}</h2>
				<dl class="jm_facts">
					<dt>{translate key="plugins.themes.journalMetrics.article.journal"}</dt>
					<dd>{$currentContext->getLocalizedName()|escape}</dd>
					{if $issue}
						<dt>{translate key="issue.issue"}</dt>
						<dd><a href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{$issue->getIssueIdentification()|escape}</a></dd>
					{/if}
					{if $section}
						<dt>{translate key="section.section"}</dt>
						<dd>{$section->getLocalizedTitle()|escape}</dd>
					{/if}
					{if $publication->getData('pages')}
						<dt>{translate key="plugins.themes.journalMetrics.article.pages"}</dt>
						<dd>{$publication->getData('pages')|escape}</dd>
					{/if}
					{assign var="jmIssn" value=$currentContext->getData('onlineIssn')|default:$currentContext->getData('printIssn')}
					{if $jmIssn}
						<dt>ISSN</dt>
						<dd class="jm_mono">{$jmIssn|escape}</dd>
					{/if}
					{if $publication->getData('locale')}
						<dt>{translate key="common.language"}</dt>
						<dd>{$publication->getData('locale')|replace:"_":"-"|escape}</dd>
					{/if}
					{if $categories}
						<dt>{translate key="category.category"}</dt>
						<dd>
							{foreach from=$categories item=category name=jmCat}
								<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="catalog" op="category" path=$category->getPath()|escape}">{$category->getLocalizedTitle()|escape}</a>{if !$smarty.foreach.jmCat.last}, {/if}
							{/foreach}
						</dd>
					{/if}
					{foreach from=$pubIdPlugins item=pubIdPlugin}
						{if $pubIdPlugin->getPubIdType() == 'doi'}
							{continue}
						{/if}
						{assign var=pubId value=$publication->getStoredPubId($pubIdPlugin->getPubIdType())}
						{if $pubId}
							<dt>{$pubIdPlugin->getPubIdDisplayType()|escape}</dt>
							<dd>
								{if $pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}
									<a id="pub-id::{$pubIdPlugin->getPubIdType()|escape}" href="{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}">{$pubIdPlugin->getResolvingURL($currentJournal->getId(), $pubId)|escape}</a>
								{else}
									{$pubId|escape}
								{/if}
							</dd>
						{/if}
					{/foreach}
				</dl>
			</section>

			{* Usage: views and downloads of this article (cached for an hour) *}
			{assign var="jmStats" value=$activeTheme->getArticleStats($article->getId())}
			{if $jmStats.views || $jmStats.pdf || $jmStats.html}
				<section class="jm_card jm_usage">
					<h2>{translate key="plugins.themes.journalMetrics.usage.title"}</h2>
					<dl class="jm_usage_list">
						<div>
							<dt>{translate key="plugins.themes.journalMetrics.usage.views"}</dt>
							<dd>{$jmStats.views|escape}</dd>
						</div>
						{if $jmStats.pdf}
							<div>
								<dt>{translate key="plugins.themes.journalMetrics.usage.pdf"}</dt>
								<dd>{$jmStats.pdf|escape}</dd>
							</div>
						{/if}
						{if $jmStats.html}
							<div>
								<dt>{translate key="plugins.themes.journalMetrics.usage.html"}</dt>
								<dd>{$jmStats.html|escape}</dd>
							</div>
						{/if}
					</dl>
				</section>
			{/if}

			{* Usage statistics chart of the default theme (only if enabled in its options) *}
			{if $activeTheme && $activeTheme->getOption('displayStats') && $activeTheme->getOption('displayStats') != 'none'}
				{$activeTheme->displayUsageStatsGraph($article->getId())}
				<section class="jm_card downloads_chart">
					<h2>{translate key="plugins.themes.default.displayStats.downloads"}</h2>
					<div class="value">
						<canvas class="usageStatsGraph" data-object-type="Submission" data-object-id="{$article->getId()|escape}"></canvas>
						<div class="usageStatsUnavailable" data-object-type="Submission" data-object-id="{$article->getId()|escape}">
							{translate key="plugins.themes.default.displayStats.noStats"}
						</div>
					</div>
				</section>
			{/if}

			{* Versions *}
			{if count($article->getPublishedPublications()) > 1}
				<section class="jm_card versions">
					<h2>{translate key="submission.versions"}</h2>
					<ul class="value">
						{foreach from=array_reverse($article->getPublishedPublications()) item=iPublication}
							{capture assign="name"}{translate key="submission.versionIdentity" datePublished=$iPublication->getData('datePublished')|date_format:$dateFormatShort version=$iPublication->getData('version')}{/capture}
							<li>
								{if $iPublication->getId() === $publication->getId()}
									{$name}
								{elseif $iPublication->getId() === $currentPublication->getId()}
									<a href="{url page="article" op="view" path=$article->getBestId()}">{$name}</a>
								{else}
									<a href="{url page="article" op="view" path=$article->getBestId()|to_array:"version":$iPublication->getId()}">{$name}</a>
								{/if}
							</li>
						{/foreach}
					</ul>
				</section>
			{/if}

			{* Data Availability Statement *}
			{if $publication->getLocalizedData('dataAvailability')}
				<section class="jm_card dataAvailability" id="data-availability-statement">
					<h2>{translate key="submission.dataAvailability"}</h2>
					{$publication->getLocalizedData('dataAvailability')|strip_unsafe_html}
				</section>
			{/if}

			{* Licensing info *}
			{if $currentContext->getLocalizedData('licenseTerms') || $publication->getData('licenseUrl')}
				<section class="jm_card copyright">
					<h2>{translate key="submission.license"}</h2>
					{if $publication->getData('licenseUrl')}
						{if $ccLicenseBadge}
							{if $publication->getLocalizedData('copyrightHolder')}
								<p>{translate key="submission.copyrightStatement" copyrightHolder=$publication->getLocalizedData('copyrightHolder') copyrightYear=$publication->getData('copyrightYear')}</p>
							{/if}
							{$ccLicenseBadge}
						{else}
							<a href="{$publication->getData('licenseUrl')|escape}" class="copyright">
								{if $publication->getLocalizedData('copyrightHolder')}
									{translate key="submission.copyrightStatement" copyrightHolder=$publication->getLocalizedData('copyrightHolder') copyrightYear=$publication->getData('copyrightYear')}
								{else}
									{translate key="submission.license"}
								{/if}
							</a>
						{/if}
					{/if}
					{$currentContext->getLocalizedData('licenseTerms')}
				</section>
			{/if}

		</aside><!-- .jm_article_aside -->
	</div><!-- .jm_article_layout -->

</article>
