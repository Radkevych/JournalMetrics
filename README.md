# Journal Metrics

**A numbers-first theme for OJS 3.5**

Journal Metrics is a child theme of the default OJS theme that turns a journal website into a clear, fast, and search-friendly page. It provides a wide, fluid layout without a sidebar, usage figures on the home page, the full table of contents of the latest issue, a live editorial workflow line, and a logically structured article page.

## Features

### Layout

- Wide, fluid container of up to 1560 px with no sidebar; works on screens ranging from phones to ultra-wide monitors.
- One-line main menu on desktop and a burger menu below 992 px.
- Compact top bar with the ISSN, a language switcher with a globe icon, and a user menu displayed as a dropdown: Login, Dashboard, Profile, and Logout.
- Skip links are hidden by default and appear only for keyboard users.

### Home page

- A single `<h1>`, call-to-action buttons, and four figure cards: article views, PDF downloads, articles, and pages.
- Editorial workflow line, “From submission to publication”: screening → review → revision → copyediting → proofreading. Segment widths are proportional to the typical duration of each stage.
- A round marker shows the manuscript’s position within the typical duration of its current stage. For example, day 25 of 90 equals 27%.
- A logged-in author sees the stage of their own latest submission. Other visitors see the stage of the most recently submitted manuscript. Only the stage and elapsed time are shown, never the title or author.
- “Most read” section featuring three articles from the two latest issues.
- Latest announcement band.
- Full list of articles from the latest issue, including the title, authors, DOI, views, and PDF button.

### Article page

- Content order: title → publication date → authors → DOI → PDF → abstract → keywords → author biography → references.
- Side column: how to cite, citation downloads in RIS and BibTeX formats, and sharing links, followed by article details, usage figures, versions, and licence information.
- Archive page: the issue cover is displayed in a separate column, with the title and description next to it.

### SEO

- `rel="canonical"` for the home page, issue pages, and article pages in each language.
- JSON-LD structured data: `Periodical` on the home page and `ScholarlyArticle` on article pages.
- Semantic markup with one `<h1>` per page.
- Alternate-language links and Google Scholar meta tags remain managed by the OJS core and the Google Scholar plugin.
- Language-switcher links use `nofollow`, preventing crawlers from following `setLocale` redirects.

## Requirements

- OJS 3.5.x
- PHP 8.2 or later
- Smarty 4
- The default OJS theme must be installed because Journal Metrics is its child theme.

## Installation

1. Copy the `journalMetrics` folder to `plugins/themes/` so that the following file exists:
