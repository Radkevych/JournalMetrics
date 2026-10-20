# JournalMetrics
A child theme of the OJS default theme that turns a journal website into a clear, fast and search-friendly page: a wide fluid layout without a sidebar, usage figures on the home page, the full table of contents of the latest issue, a live editorial-workflow line, and a logical article page.


Features
Layout
•	Wide, fluid container (up to 1560 px) with no sidebar; works from phones to ultra-wide monitors.
•	One-line main menu on desktop, burger menu below 992 px.
•	Compact top bar: ISSN, language switcher with a globe icon, user menu as a dropdown (Login / Dashboard / Profile / Logout).
•	Skip links are hidden and appear only for keyboard users.
Home page
•	Single <h1>, call-to-action buttons and four figure cards: article views, PDF downloads, articles, pages.
•	Editorial workflow line "From submission to publication": screening → review → revision → copyediting → proofreading. Segment widths are proportional to the typical term of each stage. 
o	A round marker shows where the manuscript is within the typical term of its current stage (for example, day 25 of 90 = 27 %).
o	A logged-in author sees the stage of their own latest submission; other visitors see the stage of the most recently submitted manuscript. Only the stage and the elapsed time are shown, never the title or the author.
•	"Most read": three articles from the two latest issues.
•	Latest announcement band.
•	Full list of articles of the latest issue: title, authors, DOI, views, PDF button.
Article page
•	Order: title → publication date → authors → DOI → PDF → abstract → keywords → author biography → references.
•	Side column: how to cite, citation download (RIS, BibTeX) and share links first, then article details, usage figures, versions, licence.
•	Archive page: cover in its own column, title and description next to it.
SEO
•	rel="canonical" for the home page, issue and article, per language.
•	JSON-LD: Periodical on the home page, ScholarlyArticle on the article page.
•	Semantic markup, one <h1> per page. Alternate-language links and Google Scholar meta tags stay with OJS core and the Google Scholar plugin.
•	Language switcher links are nofollow, so crawlers do not follow the setLocale redirects.
Requirements
•	OJS 3.5.x (PHP 8.2+, Smarty 4).
•	The default theme must be present (this theme is its child).
Installation
1.	Copy the journalMetrics folder to plugins/themes/ so that plugins/themes/journalMetrics/version.xml exists.
2.	Make sure the web server can read the files: chmod -R a+rX plugins/themes/journalMetrics.
3.	Clear caches: Administration → Clear Template Cache and Clear Data Caches.
4.	Open Settings → Website → Appearance → Theme, select Journal Metrics, save.
Theme options
Option	Purpose
Accent colour	Main accent of the interface
Hero tagline	Short line under the journal title on the home page
Show usage figures	Cards with views, PDF downloads, articles, pages
Show workflow line	The "From submission to publication" band
Show current stage	Round marker with the percentage of the stage term
Customisation
•	Stage names and terms: locale/<lang>/locale.po, keys plugins.themes.journalMetrics.workflow.*.
•	Typical stage terms in days (used for segment widths and the percentage): STAGE_DAYS in JournalMetricsThemePlugin.php and the matching flex-grow values in templates/frontend/pages/indexJournal.tpl. Default: 10 / 90 / 30 / 14 / 14.
•	Colours, sizes: CSS variables at the top of styles/journalMetrics.css.
How the figures are calculated
•	Views and PDF downloads come from the OJS statistics service (publicationStats) and are cached for one hour. If statistics are disabled, the figures are zero.
•	The start of a stage is the submission date (screening) or the date of the latest editorial decision (sending to review, requesting revisions, acceptance, sending to production). Unfinished drafts are ignored.
•	The stage for visitors is cached for 10 minutes; for a logged-in author it is not cached.
Notes
•	The theme was checked by rendering its templates and styles in a test harness and in a headless browser at 390, 1100 and 1440 px. Please test it on a staging copy of your OJS before using it in production.
•	Styling of third-party blocks (citation formats, sharing buttons) is generic because their markup comes from other plugins.
Contributing
Issues and pull requests are welcome. Please describe the OJS version, the browser and, for layout problems, attach a screenshot.
Licence
GNU GPL v3, the same as OJS.

