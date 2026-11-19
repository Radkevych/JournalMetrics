# Journal Metrics — a numbers-first theme for OJS 3.5

[Українська версія нижче](#journal-metrics--тема-для-ojs-35)

A child theme of the OJS default theme that turns a journal website into a clear, fast and search-friendly page: a wide fluid layout without a sidebar, usage figures on the home page, the full table of contents of the latest issue, a live editorial-workflow line, and a logical article page.

![license](https://img.shields.io/badge/license-GPL--3.0-blue) ![OJS](https://img.shields.io/badge/OJS-3.5-0a7bb5) ![locales](https://img.shields.io/badge/locales-uk%20%7C%20en-green)

## Features

**Layout**
- Wide, fluid container (up to 1560 px) with no sidebar; works from phones to ultra-wide monitors.
- One-line main menu on desktop, burger menu below 992 px.
- Compact top bar: ISSN, display settings, language switcher with a globe icon, user menu as a dropdown (Login / Dashboard / Profile / Logout).
- **Display settings:** text size (smaller / default / larger, five steps) and **light / dark / automatic** theme. The automatic mode switches to the dark theme at night by the hour of the visitor's device (default 20:00–07:00). The choice is kept in the visitor's browser.
- Skip links are hidden and appear only for keyboard users.

**Home page**
- Single `<h1>`, call-to-action buttons and four figure cards: article views, PDF downloads, articles, pages.
- **Editorial workflow line** "From submission to publication": screening → review → revision → copyediting → proofreading. Segment widths are proportional to the typical term of each stage.
  - A round marker shows where the manuscript is within the typical term of its current stage (for example, day 25 of 90 = 27 %).
  - The marker is tied to the visitor: a logged-in author sees the stage of **their own** latest submission ("Your submission is at this stage"). Other visitors (and authors without a submission in progress) see the stage of the journal's latest manuscript, clearly labelled as not theirs. Drafts that were not submitted are ignored. Only the stage and the elapsed time are shown, never the title or the author. A theme option can limit the marker to authors only.
- "Most read": three articles from the two latest issues.
- Latest announcement band.
- Full list of articles of the latest issue: title, authors, DOI, views, PDF button.

**Article page**
- Order: title → publication date → authors → DOI → PDF → abstract → keywords → author biography → references.
- Side column: how to cite, citation download (RIS, BibTeX) and share links first, then article details, usage figures, versions, licence.
- Archive page: cover in its own column, title and description next to it.

**SEO**
- `rel="canonical"` for the home page, issue and article, per language.
- JSON-LD: `Periodical` on the home page, `ScholarlyArticle` on the article page.
- Semantic markup, one `<h1>` per page. Alternate-language links and Google Scholar meta tags stay with OJS core and the Google Scholar plugin.
- Language switcher links are `nofollow`, so crawlers do not follow the `setLocale` redirects.

## Requirements
- OJS 3.5.x (PHP 8.2+, Smarty 4).
- The default theme must be present (this theme is its child).

## Installation
1. Copy the theme to `plugins/themes/journalMetrics/` so that `plugins/themes/journalMetrics/version.xml` exists. If you download the repository as a ZIP, rename the extracted folder (for example `JournalMetrics-main`) to `journalMetrics`; the ZIP from the Releases page already has the right folder name.
2. Make sure the web server can read the files: `chmod -R a+rX plugins/themes/journalMetrics`.
3. Clear caches: *Administration → Clear Template Cache* and *Clear Data Caches*.
4. Open *Settings → Website → Appearance → Theme*, select **Journal Metrics**, save.

## Theme options
| Option | Purpose |
|---|---|
| Accent colour | Main accent of the interface |
| Hero tagline | Short line under the journal title on the home page |
| Show usage figures | Cards with views, PDF downloads, articles, pages |
| Show workflow line | The "From submission to publication" band |
| Show current stage | Round marker with the percentage of the stage term |
| Who sees the stage marker | Author: own submission, others: latest manuscript — or only logged-in authors |
| Most read articles | Three most read articles of the two latest issues |
| Issue article list | Full list of articles of the latest issue |
| Announcement band | Latest announcement as a dark band |
| Text size | Text size buttons in the top bar |
| Day and night | Light/dark theme buttons in the top bar |
| Default theme mode | Automatic (by time of day), always light or always dark |
| Night starts / ends at | Hours for the automatic mode |

## Customisation
- **Stage names and terms:** `locale/<lang>/locale.po`, keys `plugins.themes.journalMetrics.workflow.*`.
- **Typical stage terms in days** (used for segment widths and the percentage): `STAGE_DAYS` in `JournalMetricsThemePlugin.php` and the matching `flex-grow` values in `templates/frontend/pages/indexJournal.tpl`. Default: 10 / 90 / 30 / 14 / 14.
- **Colours, sizes:** CSS variables at the top of `styles/journalMetrics.css`.

## How the figures are calculated
- Views and PDF downloads come from the OJS statistics service (`publicationStats`) and are cached for one hour. If statistics are disabled, the figures are zero.
- The start of a stage is the submission date (screening) or the date of the latest editorial decision (sending to review, requesting revisions, acceptance, sending to production). Unfinished drafts are ignored.
- The stage for visitors is cached for 10 minutes; for a logged-in author it is not cached.

## Notes
- The theme was checked by rendering its templates and styles in a test harness and in a headless browser at 390, 1100 and 1440 px. Please test it on a staging copy of your OJS before using it in production.
- Styling of third-party blocks (citation formats, sharing buttons) is generic because their markup comes from other plugins.

## Changelog
- **v2.4** — display settings in the top bar: text size and light / dark / automatic theme; the stage marker is tied to the visitor (own submission for an author, the journal's latest manuscript for others) with a compact status line; dark-theme fixes for pages of the parent theme and for sites with their own stylesheet; new theme options for blocks and for the stage marker.
- **v2.3** — stage progress marker (percentage of the typical term), globe in the language switcher, archive layout in two columns, "Developed by" credit in the footer.
- **v2.1–v2.2** — wide fluid layout, one-line menu with a burger on small screens, cite/share card moved to the side column of the article page, language switch through the OJS core in one click.
- **v1.0** — first version: numbers-first home page, workflow line, list of the latest issue.

## Contributing
Issues and pull requests are welcome. Please describe the OJS version, the browser and, for layout problems, attach a screenshot.

## Licence
GNU GPL v3, the same as OJS.

---

# Journal Metrics — тема для OJS 3.5

Дочірня тема до теми за замовчуванням, яка робить сайт журналу зрозумілим, швидким і зручним для пошукових систем: широке адаптивне розташування без бічної колонки, показники використання на головній, повний зміст останнього випуску, жива лінія редакційного процесу та логічна сторінка статті.

## Можливості

**Каркас**
- Широкий контейнер (до 1560 px) без бічної колонки; працює від телефонів до широких моніторів.
- Основне меню в один рядок на комп'ютері, бургер на екранах до 992 px.
- Компактна верхня смуга: ISSN, параметри відображення, перемикач мови зі значком глобуса, меню користувача як випадний список.
- **Параметри відображення:** розмір тексту (менший / звичайний / більший, п'ять кроків) і **світла / темна / автоматична** тема. Автоматичний режим вмикає темну тему вночі за годиною на пристрої відвідувача (за замовчуванням 20:00–07:00). Вибір зберігається в браузері відвідувача.
- Skip-посилання приховані й з'являються лише для користувачів клавіатури.

**Головна сторінка**
- Один `<h1>`, кнопки дій і чотири картки показників: перегляди, завантаження PDF, статті, сторінки.
- **Лінія «Від подання до публікації»**: попередня оцінка → рецензування → доопрацювання → редагування → верстка. Ширина сегментів пропорційна типовому строку етапу.
  - Круглий маркер показує, на якому відсотку типового строку поточного етапу перебуває рукопис (наприклад, день 25 з 90 = 27 %).
  - Позначка прив'язана до відвідувача: автор, що увійшов, бачить етап **власної** останньої статті («Ваша стаття зараз на цьому етапі»). Інші відвідувачі (і автори без поданої статті в роботі) бачать етап останньої рукописи журналу з чітким підписом, що це не їхня стаття. Незавершені чернетки не враховуються. Показується лише етап і час, без назви й автора. Параметр теми дає змогу показувати позначку лише авторам.
- «Найчитаніші статті»: три статті з двох останніх випусків.
- Смуга з останнім оголошенням.
- Повний список статей останнього випуску: назва, автори, DOI, перегляди, кнопка PDF.

**Сторінка статті**
- Порядок: назва → дата публікації → автори → DOI → PDF → анотація → ключові слова → біографія автора → список літератури.
- Бічна колонка: «Як цитувати», завантаження цитування (RIS, BibTeX) і поширення, далі відомості про статтю, використання, версії, ліцензія.
- Архів: обкладинка в окремій колонці, назва й опис поруч.

**SEO**
- `rel="canonical"` для головної, випуску та статті окремо для кожної мови.
- JSON-LD: `Periodical` на головній, `ScholarlyArticle` на статті.
- Семантична розмітка, один `<h1>` на сторінці. Посилання на інші мови та мета-теги Google Scholar лишаються за ядром OJS і плагіном Google Scholar.
- Посилання перемикача мови мають `nofollow`, щоб пошукові роботи не переходили за перенаправленнями `setLocale`.

## Вимоги
- OJS 3.5.x (PHP 8.2+, Smarty 4).
- Наявна тема за замовчуванням (ця тема є її дочірньою).

## Встановлення
1. Скопіюйте тему до `plugins/themes/journalMetrics/`, щоб існував файл `plugins/themes/journalMetrics/version.xml`. Якщо ви завантажили репозиторій як ZIP, перейменуйте розпаковану папку (наприклад, `JournalMetrics-main`) на `journalMetrics`; ZIP зі сторінки Releases уже має правильну назву папки.
2. Переконайтеся, що веб-сервер може читати файли: `chmod -R a+rX plugins/themes/journalMetrics`.
3. Очистіть кеш: *Адміністрування → Очистити кеш шаблонів* та *Очистити кеш даних*.
4. Відкрийте *Налаштування → Вебсайт → Вигляд → Тема*, оберіть **Journal Metrics**, збережіть.

## Налаштування теми
| Параметр | Призначення |
|---|---|
| Акцентний колір | Основний акцент інтерфейсу |
| Слоган | Короткий рядок під назвою журналу на головній |
| Показники використання | Картки переглядів, PDF, статей, сторінок |
| Лінія редакційного процесу | Смуга «Від подання до публікації» |
| Позначка поточного етапу | Круглий маркер із відсотком строку етапу |
| Кому показувати позначку етапу | Автору — його статтю, решті — останню рукопис журналу; або лише авторам |
| Найчитаніші статті | Три найчитаніші статті двох останніх випусків |
| Список статей випуску | Повний список статей останнього випуску |
| Смуга оголошення | Останнє оголошення темною смугою |
| Розмір тексту | Кнопки розміру тексту у верхній смузі |
| День і ніч | Кнопки світлої та темної теми у верхній смузі |
| Режим теми за замовчуванням | Автоматично (за часом доби), завжди світла або завжди темна |
| Ніч починається / закінчується о | Години для автоматичного режиму |

## Налаштування під себе
- **Назви й терміни етапів:** `locale/<мова>/locale.po`, ключі `plugins.themes.journalMetrics.workflow.*`.
- **Типові строки етапів у днях** (ширина сегментів і відсоток): `STAGE_DAYS` у `JournalMetricsThemePlugin.php` та відповідні значення `flex-grow` у `templates/frontend/pages/indexJournal.tpl`. За замовчуванням: 10 / 90 / 30 / 14 / 14.
- **Кольори й розміри:** CSS-змінні на початку `styles/journalMetrics.css`.

## Як розраховуються показники
- Перегляди й завантаження PDF беруться зі служби статистики OJS (`publicationStats`) і кешуються на 1 годину. Якщо статистику вимкнено, показники дорівнюють нулю.
- Початок етапу: дата подання (попередня оцінка) або дата останнього рішення редактора (відправлення на рецензію, запит правок, прийняття, відправлення у верстку). Незавершені чернетки не враховуються.
- Етап для відвідувачів кешується на 10 хвилин; для автора, що увійшов, кеш не застосовується.

## Примітки
- Тему перевірено відтворенням шаблонів і стилів у тестовому середовищі та в браузері без інтерфейсу на ширинах 390, 1100 і 1440 px. Перед застосуванням на робочому сайті перевірте її на тестовій копії OJS.
- Стилі сторонніх блоків (формати цитування, кнопки поширення) загальні, бо їхню розмітку формують інші плагіни.

## Історія змін
- **v2.4** — параметри відображення у верхній смузі: розмір тексту та світла / темна / автоматична тема; позначка етапу прив'язана до відвідувача (автору — його стаття, іншим — остання рукопис журналу), компактний рядок стану; виправлення темної теми для сторінок батьківської теми та сайтів зі власною таблицею стилів; нові параметри теми для блоків і позначки етапу.
- **v2.3** — позначка просування етапу (відсоток типового строку), глобус у перемикачі мови, архів у дві колонки, підпис «Розроблено» у футері.
- **v2.1–v2.2** — широкий адаптивний каркас, меню в один рядок і бургер на малих екранах, блок цитування й поширення в бічній колонці статті, перемикання мови через ядро OJS одним кліком.
- **v1.0** — перша версія: головна «у цифрах», лінія етапів, список статей останнього випуску.

## Внесок
Запити та пул-реквести вітаються. Вкажіть версію OJS, браузер і, у разі проблем із версткою, додайте знімок екрана.

## Ліцензія
GNU GPL v3, як і OJS.
