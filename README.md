# Journal Metrics — тема для OJS 3.5 v1.0

New version is here (v2.1): https://github.com/Radkevych/JournalMetrics/releases/tag/JournalMetrics

Child theme of the default OJS theme. Implements the "Journal in Numbers" journal layout.

Installation
Copy the journalMetrics folder into your OJS plugins/themes/ directory so that the path becomes plugins/themes/journalMetrics/version.xml.
Ensure the files are readable by the web server (chmod -R a+rX plugins/themes/journalMetrics).
Clear template and data caches: Administration → Site Administration → Clear Template Cache and Clear Data Caches.
Go to Settings → Website → Appearance → Theme, select Journal Metrics Theme, and click Save.
On the same page, configure the accent color, slogan, and the Usage Metrics and Editorial Process switches.
Features
Layout: Wide container (up to 1560 px) without a sidebar. The header includes ISSN, language switcher, user menu (dropdown), journal title, a Submit Manuscript button, and the main navigation menu on a single row. On screens below 992 px, the menu collapses into a hamburger menu. Skip links remain hidden and appear only for keyboard users.
Homepage: Single H1 heading, action buttons, metric cards (views, PDF downloads, articles, pages), an editorial workflow timeline showing the current stage of the latest manuscript in process (stage only, without title or author), Most Read Articles (3 articles from the two latest issues), a banner displaying the latest announcement, and a complete list of articles from the current issue (title, authors, DOI, views, PDF).
Article Page: Title → publication date → authors → DOI → PDF → abstract → keywords → author biography → references → “How to Cite” section and citation downloads. Article details and usage statistics are displayed in a sidebar card.
SEO: Canonical URLs for the homepage, issue pages, and article pages (separately for each language); JSON-LD markup (Periodical on the homepage, ScholarlyArticle on article pages); semantic HTML structure; a single H1 heading. hreflang tags and Google Scholar meta tags remain managed by the OJS core and the Google Scholar plugin.
Customizing Editorial Workflow Stages

Stage names and descriptions can be edited in:

locale/uk/locale.po
locale/en/locale.po

using the plugins.themes.journalMetrics.workflow.* keys.

The relative width of workflow segments is controlled by the flex-grow values in:

templates/frontend/pages/indexJournal.tpl

Statistics

View counts are retrieved from the OJS statistics service (publicationStats) and cached for one hour. If statistics are disabled or unavailable, all metrics will display as zero.

Google Indexing (outside the scope of the theme)

To ensure proper indexing in Google:

Enable the Google Scholar plugin.
Verify that the journal is publicly accessible and not marked with noindex.
Submit the sitemap to Google Search Console:
 https://jrnls.ivet.edu.ua/index/sitemap
Check Manual Actions and Security Issues reports in Search Console.
License

GNU General Public License v3.0 (GPL v3).
