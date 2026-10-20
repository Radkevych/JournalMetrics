{**
 * templates/frontend/pages/indexJournal.tpl
 *
 * Journal Metrics theme. Home page of a journal, built from full-width bands:
 * hero with usage numbers, editorial workflow line, most read articles,
 * the latest announcement, and the full list of articles of the current issue.
 *
 * @uses $currentJournal Journal This journal
 * @uses $announcements array List of announcements
 * @uses $issue Issue Current issue
 * @uses $publishedSubmissions array Articles of the current issue, by section
 *
 * @hook Templates::Index::journal []
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName()}

<div class="page_index_journal jm_home">

	{call_hook name="Templates::Index::journal"}

	{if $issue}
		{assign var="jmStats" value=$activeTheme->getIssueStats($publishedSubmissions)}
	{/if}
	{assign var="jmIssn" value=$currentJournal->getData('onlineIssn')|default:$currentJournal->getData('printIssn')}
	{assign var="jmTagline" value=$activeTheme->getHeroTagline()}

	{* ---------- Hero: the only <h1> of the page ---------- *}
	<section class="jm_hero" aria-labelledby="jm-hero-title">
		<div class="jm_wrap jm_hero_grid">
			<div class="jm_hero_text">
				<p class="jm_eyebrow">
					{if $currentJournal->getData('publishingMode') == APP\journal\Journal::PUBLISHING_MODE_OPEN}{translate key="plugins.themes.journalMetrics.eyebrow"}{/if}
					{if $jmIssn}<span class="jm_mono">· ISSN {$jmIssn|escape}</span>{/if}
				</p>
				<h1 id="jm-hero-title">
					{$currentJournal->getLocalizedName()|escape}
					{if $jmTagline}<span class="jm_accent">{$jmTagline|escape}</span>{/if}
				</h1>
				{assign var="jmLead" value=$currentJournal->getLocalizedData('description')|strip_tags|trim}
				{if $jmLead}
					<p class="jm_lead">{$jmLead|truncate:320:"…":true}</p>
				{/if}
				<p class="jm_hero_actions">
					<a class="jm_btn jm_btn_primary" href="{url page="issue" op="current"}">{translate key="plugins.themes.journalMetrics.hero.currentIssue"}</a>
					<a class="jm_btn jm_btn_ghost" href="{url page="about" op="submissions"}">{translate key="plugins.themes.journalMetrics.hero.forAuthors"}</a>
				</p>
			</div>

			{if $issue && $activeTheme->getOption('showHeroStats')}
				<div class="jm_hero_stats">
					<ul class="jm_stats">
						<li>
							<span class="jm_stat_value">{$jmStats.views|escape}</span>
							<span class="jm_stat_label">{translate key="plugins.themes.journalMetrics.stats.views"} · {$issue->getIssueIdentification()|escape}</span>
						</li>
						<li>
							<span class="jm_stat_value jm_accent">{$jmStats.pdf|escape}</span>
							<span class="jm_stat_label">{translate key="plugins.themes.journalMetrics.stats.pdf"}</span>
						</li>
						<li>
							<span class="jm_stat_value">{$jmStats.count|escape}</span>
							<span class="jm_stat_label">{translate key="plugins.themes.journalMetrics.stats.articles"}</span>
						</li>
						{if $jmStats.pages}
							<li>
								<span class="jm_stat_value">{$jmStats.pages|escape}</span>
								<span class="jm_stat_label">{translate key="plugins.themes.journalMetrics.stats.pages"} ({$jmStats.firstPage|escape}–{$jmStats.lastPage|escape})</span>
							</li>
						{/if}
					</ul>
					<p class="jm_source">{translate key="plugins.themes.journalMetrics.stats.source"}</p>
				</div>
			{/if}
		</div>
	</section>

	{if $highlights->count()}
		<div class="jm_wrap">
			{include file="frontend/components/highlights.tpl" highlights=$highlights}
		</div>
	{/if}

	{if $activeTheme && !$activeTheme->getOption('useHomepageImageAsHeader') && $homepageImage}
		<div class="jm_wrap">
			<div class="homepage_image">
				<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}"{if $homepageImage.altText} alt="{$homepageImage.altText|escape}"{/if}>
			</div>
		</div>
	{/if}

	{* ---------- Editorial workflow line with the stage of the latest submission ---------- *}
	{if $activeTheme->getOption('showWorkflowStrip')}
		{assign var="jmStage" value=null}
		{if $activeTheme->getOption('showWorkflowCurrent')}
			{assign var="jmStage" value=$activeTheme->getCurrentStage()}
		{/if}
		<section class="jm_band jm_workflow" aria-labelledby="jm-workflow-title">
			<div class="jm_wrap">
				<div class="jm_band_head">
					<div>
						<p class="jm_eyebrow jm_eyebrow_muted">{translate key="plugins.themes.journalMetrics.workflow.eyebrow"}</p>
						<h2 id="jm-workflow-title">{translate key="plugins.themes.journalMetrics.workflow.title"}</h2>
					</div>
					<p class="jm_band_lead">{translate key="plugins.themes.journalMetrics.workflow.lead"}</p>
				</div>

				<ol class="jm_flow{if $jmStage} jm_flow_tracked{/if}">
					{foreach from=['screening'=>10,'review'=>90,'revision'=>30,'copyediting'=>14,'proofreading'=>14] key=jmKey item=jmDays name=jmFlow}
						{assign var="jmIdx" value=$smarty.foreach.jmFlow.index}
						<li style="flex-grow:{$jmDays}"{if $jmStage && $jmStage.index == $jmIdx} class="is_current" aria-current="step"{elseif $jmStage && $jmStage.index > $jmIdx} class="is_done"{/if}>
							<span class="jm_flow_bar"{if $jmStage && $jmStage.index == $jmIdx} style="--jm-p:{$jmStage.percent|intval}"{/if}>{if $jmStage && $jmStage.index == $jmIdx}<span class="jm_flow_fill" aria-hidden="true"></span><span class="jm_flow_dot" aria-hidden="true"></span>{/if}</span>
							<span class="jm_flow_name">{translate key="plugins.themes.journalMetrics.workflow.`$jmKey`"}</span>
							<span class="jm_flow_term">{translate key="plugins.themes.journalMetrics.workflow.`$jmKey`.term"}</span>
							{if $jmStage && $jmStage.index == $jmIdx}<span class="jm_flow_now">{if $jmStage.mine}{translate key="plugins.themes.journalMetrics.workflow.currentMine"}{else}{translate key="plugins.themes.journalMetrics.workflow.current"}{/if}</span>
								<span class="jm_flow_progress" title="{translate|escape key="plugins.themes.journalMetrics.workflow.progressHint" total=$jmStage.total}">{if $jmStage.over}{translate key="plugins.themes.journalMetrics.workflow.progressOver" day=$jmStage.day total=$jmStage.total}{else}{translate key="plugins.themes.journalMetrics.workflow.progress" day=$jmStage.day total=$jmStage.total percent=$jmStage.percent}{/if}</span>{/if}
						</li>
					{/foreach}
				</ol>
				<p class="jm_source">{translate key="plugins.themes.journalMetrics.workflow.note"}</p>
			</div>
		</section>
	{/if}

	{* Journal Description (optional, as in the default theme) *}
	{if $activeTheme && $activeTheme->getOption('showDescriptionInJournalIndex')}
		<section class="homepage_about jm_wrap jm_block">
			<a id="homepageAbout"></a>
			<h2>{translate key="about.aboutContext"}</h2>
			{$currentContext->getLocalizedData('description')}
		</section>
	{/if}

	{* ---------- Most read articles of the two latest issues ---------- *}
	{assign var="jmMostRead" value=$activeTheme->getMostRead(3, 2)}
	{if $jmMostRead}
		<section class="jm_wrap jm_block jm_mostread" aria-labelledby="jm-mostread-title">
			<p class="jm_eyebrow jm_eyebrow_muted">{translate key="plugins.themes.journalMetrics.mostRead.eyebrow"}</p>
			<h2 id="jm-mostread-title">{translate key="plugins.themes.journalMetrics.mostRead.title"}</h2>
			<ol class="jm_mostread_list">
				{foreach from=$jmMostRead item=jmItem name=jmMost}
					<li>
						<span class="jm_rank">{$smarty.foreach.jmMost.iteration}</span>
						<h3><a href="{$jmItem.url|escape}">{$jmItem.title|escape}</a></h3>
						{if $jmItem.authors}<p class="jm_mostread_authors">{$jmItem.authors|escape}</p>{/if}
						<p class="jm_mostread_numbers">
							<span><strong>{$jmItem.views|escape}</strong> {translate key="plugins.themes.journalMetrics.list.views"}</span>
							{if $jmItem.pdfUrl}<a href="{$jmItem.pdfUrl|escape}">{translate key="plugins.themes.journalMetrics.list.viewPdf"} ({$jmItem.pdf|escape})<span class="jm_screen_reader">: {$jmItem.title|escape}</span></a>{/if}
						</p>
					</li>
				{/foreach}
			</ol>
		</section>
	{/if}

	{* ---------- Latest announcement as a call-to-action band ---------- *}
	{if $numAnnouncementsHomepage && $announcements|@count}
		{foreach from=$announcements item=jmAnnouncement name=jmAnn}
			{if $smarty.foreach.jmAnn.first}
				<section class="jm_band jm_band_dark jm_cta_band" aria-labelledby="jm-announcement-title">
					<a id="homepageAnnouncements"></a>
					<div class="jm_wrap jm_cta_grid">
						<div>
							<p class="jm_eyebrow jm_eyebrow_light">{translate key="announcement.announcements"} · {$jmAnnouncement->datePosted->format($dateFormatShort)}</p>
							<h2 id="jm-announcement-title">{$jmAnnouncement->getLocalizedData('title')|escape}</h2>
							<div class="jm_cta_text">{$jmAnnouncement->getLocalizedData('descriptionShort')|strip_unsafe_html}</div>
						</div>
						<p class="jm_cta_actions">
							<a class="jm_btn jm_btn_accent" href="{url page="about" op="submissions"}">{translate key="plugins.themes.journalMetrics.hero.forAuthors"}</a>
							<a class="jm_btn jm_btn_light" href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="announcement" op="view" path=$jmAnnouncement->id}">{translate key="common.readMore"}</a>
						</p>
					</div>
				</section>
			{/if}
		{/foreach}
	{/if}

	{* ---------- Latest issue: every article with authors, DOI, views and PDF ---------- *}
	{if $issue}
		<section class="jm_wrap jm_block jm_issue current_issue" aria-labelledby="jm-issue-title">
			<a id="homepageIssue"></a>
			<p class="jm_eyebrow jm_eyebrow_muted">{translate key="journal.currentIssue"} · {$issue->getIssueIdentification()|escape}{if $issue->getDatePublished()} · <time datetime="{$issue->getDatePublished()|date_format:"%Y-%m-%d"}">{$issue->getDatePublished()|date_format:$dateFormatShort}</time>{/if}</p>
			<h2 id="jm-issue-title">{translate key="plugins.themes.journalMetrics.list.title"}</h2>

			{assign var="jmN" value=0}
			<ol class="jm_articles">
				{foreach from=$publishedSubmissions item=section}
					{foreach from=$section.articles item=article}
						{assign var="jmN" value=$jmN+1}
						{assign var="publication" value=$article->getCurrentPublication()}
						{assign var="articlePath" value=$publication->getData('urlPath')|default:$article->getId()}
						{assign var="jmId" value=$article->getId()}
						{assign var="jmRow" value=$jmStats.articles[$jmId]}
						{assign var="jmDoi" value=$publication->getData('doiObject')}
						<li class="jm_article">
							<article class="jm_article_row">
								<span class="jm_article_num" aria-hidden="true">{if $jmN < 10}0{/if}{$jmN}</span>
								<div class="jm_article_main">
									<h3 class="jm_article_title">
										<a href="{url page="article" op="view" path=$articlePath}">{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}</a>
									</h3>
									{if (!$section.hideAuthor && $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_DEFAULT) || $publication->getData('hideAuthor') == APP\submission\Submission::AUTHOR_TOC_SHOW}
										<p class="jm_article_authors">{$publication->getAuthorString($authorUserGroups)|escape}</p>
									{/if}
									{if $jmDoi}
										{assign var="jmDoiUrl" value=$jmDoi->getData('resolvingUrl')}
										<p class="jm_article_doi jm_mono">DOI: <a href="{$jmDoiUrl|escape}">{$jmDoiUrl|escape}</a></p>
									{/if}
								</div>
								<div class="jm_article_views">
									<span class="jm_article_views_value">{$jmRow.views|escape}</span>
									<span class="jm_article_views_label">{translate key="plugins.themes.journalMetrics.list.views"}</span>
								</div>
								{foreach from=$publication->getData('galleys') item=galley}
									{if $galley->isPdfGalley()}
										{assign var="jmPdfPath" value=$articlePath|to_array:$galley->getBestGalleyId()}
										<a class="jm_article_pdf" href="{url page="article" op="view" path=$jmPdfPath}">{translate key="plugins.themes.journalMetrics.list.viewPdf"}<span class="jm_screen_reader">: {$publication->getLocalizedTitle(null, 'text')|escape}</span></a>
										{break}
									{/if}
								{/foreach}
							</article>
						</li>
					{/foreach}
				{/foreach}
			</ol>

			<p class="jm_issue_links">
				<a href="{url page="issue" op="view" path=$issue->getBestIssueId()}" class="jm_link_arrow">{translate key="plugins.themes.journalMetrics.hero.currentIssue"}: {$issue->getIssueIdentification()|escape}</a>
				<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="issue" op="archive"}" class="jm_link_arrow">{translate key="journal.viewAllIssues"}</a>
			</p>
		</section>
	{/if}

	{* Additional Homepage Content *}
	{if $additionalHomeContent}
		<div class="additional_content jm_wrap jm_block">
			{$additionalHomeContent}
		</div>
	{/if}
</div><!-- .page -->

{include file="frontend/components/footer.tpl"}
