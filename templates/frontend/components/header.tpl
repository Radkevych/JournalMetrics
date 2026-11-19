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

{assign var="jmPrefs" value=$activeTheme->getDisplayPrefs()}
{if $jmPrefs.textSize || $jmPrefs.themeSwitch}
{* Display settings (text size, light/dark theme) are applied before the page is painted, so that it does not flash *}
<script>window.jmPrefs={$activeTheme->getDisplayPrefsJson()};</script>
{literal}<script>
(function (w, d) {
	var P = w.jmPrefs, R = d.documentElement;
	function get(k) { try { return w.localStorage.getItem(k); } catch (e) { return null; } }
	function set(k, v) { try { w.localStorage.setItem(k, v); } catch (e) {} }
	var size = P.textSize ? parseInt(get('jm_size'), 10) : 0;
	if (isNaN(size) || size < -1 || size > 3) { size = 0; }
	var mode = P.themeSwitch ? get('jm_mode') : null;
	if (['auto', 'day', 'night'].indexOf(mode) < 0) { mode = P.mode; }
	function isNight() {
		var h = new Date().getHours(), a = P.nightFrom, b = P.nightTo;
		if (a === b) { return false; }
		return a > b ? (h >= a || h < b) : (h >= a && h < b);
	}
	function apply() {
		var dark = mode === 'night' || (mode === 'auto' && isNight());
		R.setAttribute('data-jm-theme', dark ? 'dark' : 'light');
		R.setAttribute('data-jm-mode', mode);
		R.setAttribute('data-jm-size', String(size));
		var i, b, el;
		el = d.querySelectorAll('[data-jm-mode-btn]');
		for (i = 0; i < el.length; i++) {
			el[i].setAttribute('aria-pressed', el[i].getAttribute('data-jm-mode-btn') === mode ? 'true' : 'false');
		}
		el = d.querySelectorAll('[data-jm-size-step]');
		for (i = 0; i < el.length; i++) {
			b = parseInt(el[i].getAttribute('data-jm-size-step'), 10);
			el[i].disabled = (b < 0 && size <= -1) || (b > 0 && size >= 3);
		}
		el = d.querySelector('[data-jm-size-reset]');
		if (el) { el.setAttribute('aria-pressed', size === 0 ? 'true' : 'false'); }
	}
	apply();
	d.addEventListener('DOMContentLoaded', function () {
		apply();
		d.addEventListener('click', function (e) {
			var t = e.target.closest ? e.target.closest('[data-jm-size-step],[data-jm-size-reset],[data-jm-mode-btn]') : null;
			if (!t) { return; }
			if (t.hasAttribute('data-jm-size-step')) {
				size = Math.max(-1, Math.min(3, size + parseInt(t.getAttribute('data-jm-size-step'), 10)));
				set('jm_size', String(size));
			} else if (t.hasAttribute('data-jm-size-reset')) {
				size = 0;
				set('jm_size', '0');
			} else {
				mode = t.getAttribute('data-jm-mode-btn');
				set('jm_mode', mode);
			}
			apply();
		});
		// In the automatic mode the theme follows the hour of the day
		w.setInterval(function () { if (mode === 'auto') { apply(); } }, 60000);
	});
})(window, document);
</script>{/literal}
{/if}

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
						{if $jmPrefs.textSize || $jmPrefs.themeSwitch}
							<div class="jm_prefs" role="group" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.label"}">
								{if $jmPrefs.textSize}
									<div class="jm_prefs_group" role="group" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.textSize"}">
										<button type="button" class="jm_pref_btn jm_pref_text" data-jm-size-step="-1" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.smaller"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.smaller"}"><span aria-hidden="true" class="jm_pref_a jm_pref_a_small">A</span></button>
										<button type="button" class="jm_pref_btn jm_pref_text" data-jm-size-reset aria-pressed="true" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.reset"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.reset"}"><span aria-hidden="true" class="jm_pref_a">A</span></button>
										<button type="button" class="jm_pref_btn jm_pref_text" data-jm-size-step="1" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.larger"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.larger"}"><span aria-hidden="true" class="jm_pref_a jm_pref_a_large">A</span></button>
									</div>
								{/if}
								{if $jmPrefs.themeSwitch}
									<div class="jm_prefs_group" role="group" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.theme"}">
										<button type="button" class="jm_pref_btn" data-jm-mode-btn="auto" aria-pressed="false" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.auto"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.auto"}"><svg aria-hidden="true" focusable="false" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="8.5"/><path d="M12 3.5a8.5 8.5 0 0 1 0 17z" fill="currentColor"/></svg></button>
										<button type="button" class="jm_pref_btn" data-jm-mode-btn="day" aria-pressed="false" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.day"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.day"}"><svg aria-hidden="true" focusable="false" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2M5.3 5.3l1.6 1.6M17.1 17.1l1.6 1.6M5.3 18.7l1.6-1.6M17.1 6.9l1.6-1.6"/></svg></button>
										<button type="button" class="jm_pref_btn" data-jm-mode-btn="night" aria-pressed="false" aria-label="{translate|escape key="plugins.themes.journalMetrics.prefs.night"}" title="{translate|escape key="plugins.themes.journalMetrics.prefs.night"}"><svg aria-hidden="true" focusable="false" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 14.2A8 8 0 1 1 9.8 4a6.3 6.3 0 0 0 10.2 10.2z"/></svg></button>
									</div>
								{/if}
							</div>
						{/if}
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
