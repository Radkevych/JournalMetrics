{**
 * templates/frontend/components/header.tpl
 *
 * Journal Metrics theme. Based on lib/pkp/templates/frontend/components/header.tpl.
 * Differences from the original:
 *  - no hidden <h1> on the home page (the hero prints the only <h1>);
 *  - a top bar with ISSN, language switch and the user menu;
 *  - the main menu is one line on wide screens and a burger menu on small ones;
 *  - a "Submit manuscript" button;
 *  - the sidebar is never used.
 *}
{strip}
	{assign var="showingLogo" value=true}
	{if !$displayPageHeaderLogo}
		{assign var="showingLogo" value=false}
	{/if}
{/strip}
<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
{if !$pageTitleTranslated}{capture assign="pageTitleTranslated"}{translate key=$pageTitle}{/capture}{/if}
{include file="frontend/components/headerHead.tpl"}
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"}{if $showingLogo} has_site_logo{/if}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	<div class="pkp_structure_page">

		{* Header *}
		<header class="pkp_structure_head" id="headerNavigationContainer" role="banner">
			{* Skip links: invisible until a keyboard user focuses them *}
			{include file="frontend/components/skipLinks.tpl"}

			{* Top bar: ISSN, language switch, user menu *}
			<div class="jm_topbar">
				<div class="jm_topbar_inner">
					{assign var="jmIssn" value=$currentContext->getData('onlineIssn')|default:$currentContext->getData('printIssn')}
					<span class="jm_topbar_issn">{if $currentContext && $jmIssn}ISSN {$jmIssn|escape}{/if}</span>
					<div class="jm_topbar_right">
						{if $currentContext}
							{assign var="jmLocaleLinks" value=$activeTheme->getLocaleLinks()}
							{if $jmLocaleLinks}
								<nav class="jm_lang" aria-label="{translate|escape key="plugins.themes.journalMetrics.header.language"}">
									<svg class="jm_lang_icon" aria-hidden="true" focusable="false" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9.5"/><path d="M2.5 12h19"/><path d="M12 2.5c2.6 2.7 4 5.9 4 9.5s-1.4 6.8-4 9.5c-2.6-2.7-4-5.9-4-9.5s1.4-6.8 4-9.5z"/></svg>
									<ul>
										{foreach from=$jmLocaleLinks item=jmLink}
											<li>
												<a href="{$jmLink.url|escape}" rel="nofollow" lang="{$jmLink.lang|escape}"{if $jmLink.current} aria-current="true" class="is_current"{/if}>{$jmLink.label|escape}</a>
											</li>
										{/foreach}
									</ul>
								</nav>
							{/if}
						{/if}
						<div class="jm_user" id="navigationUserWrapper">
							{load_menu name="user" id="navigationUser" ulClass="pkp_navigation_user" liClass="profile"}
						</div>
					</div>
				</div>
			</div>

			<div class="pkp_head_wrapper">

				<div class="pkp_site_name_wrapper">
					<button class="pkp_site_nav_toggle" aria-label="{translate|escape key="common.navigation.site"}">
						<span>Open Menu</span>
					</button>
					<div class="pkp_site_name">
					{capture assign="homeUrl"}
						{url page="index" router=PKP\core\PKPApplication::ROUTE_PAGE}
					{/capture}
					{if $displayPageHeaderLogo}
						<a href="{$homeUrl}" class="is_img">
							<img src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" width="{$displayPageHeaderLogo.width|escape}" height="{$displayPageHeaderLogo.height|escape}" {if $displayPageHeaderLogo.altText != ''}alt="{$displayPageHeaderLogo.altText|escape}"{/if} />
						</a>
					{elseif $displayPageHeaderTitle}
						<a href="{$homeUrl}" class="is_text">{$displayPageHeaderTitle|escape}</a>
					{else}
						<a href="{$homeUrl}" class="is_img">
							<img src="{$baseUrl}/templates/images/structure/logo.png" alt="{$applicationName|escape}" title="{$applicationName|escape}" width="180" height="90" />
						</a>
					{/if}
					</div>
				</div>

				{if $currentContext}
					<a class="jm_cta jm_cta_desktop" href="{url page="submission"}">{translate key="plugins.themes.journalMetrics.header.submit"}</a>
				{/if}

				{capture assign="primaryMenu"}
					{load_menu name="primary" id="navigationPrimary" ulClass="pkp_navigation_primary"}
				{/capture}

				<nav class="pkp_site_nav_menu" aria-label="{translate|escape key="common.navigation.site"}">
					<a id="siteNav"></a>
					<div class="pkp_navigation_primary_row">
						<div class="pkp_navigation_primary_wrapper">
							{* Primary navigation menu for current application *}
							{$primaryMenu}

							{if $currentContext}
								<a class="jm_cta jm_cta_mobile" href="{url page="submission"}">{translate key="plugins.themes.journalMetrics.header.submit"}</a>
							{/if}
						</div>
					</div>
				</nav>
			</div><!-- .pkp_head_wrapper -->
		</header><!-- .pkp_structure_head -->

		{* Wrapper for page content; the theme has no sidebar *}
		{assign var=hasSidebar value=0}
		<div class="pkp_structure_content">
			<main class="pkp_structure_main" role="main">
				<a id="pkp_content_main"></a>
