<?php

/**
 * @file plugins/themes/journalMetrics/JournalMetricsThemePlugin.php
 *
 * Distributed under the GNU GPL v3. For full terms see the file docs/COPYING.
 *
 * @class JournalMetricsThemePlugin
 *
 * @brief Child theme of the OJS 3.5 default theme. It adds a numbers-first
 *  home page (usage statistics, editorial workflow, list of the latest issue),
 *  a usage block on article pages and search-engine markup
 *  (canonical links, schema.org JSON-LD).
 */

namespace APP\plugins\themes\journalMetrics;

use APP\core\Application;
use APP\facades\Repo;
use APP\issue\Collector as IssueCollector;
use APP\journal\Journal;
use APP\submission\Collector as SubmissionCollector;
use APP\submission\Submission;
use Illuminate\Support\Facades\Cache;
use PKP\core\PKPApplication;
use PKP\core\PKPSessionGuard;
use PKP\db\DAORegistry;
use PKP\facades\Locale;
use PKP\plugins\Hook;
use PKP\plugins\ThemePlugin;
use PKP\decision\Collector as DecisionCollector;
use PKP\security\Role;

class JournalMetricsThemePlugin extends ThemePlugin
{
    /** Default accent colour (passes WCAG AA contrast with white text) */
    public const DEFAULT_ACCENT = '#C2410C';

    /** Seconds to keep per-article usage numbers in the cache */
    public const STATS_CACHE_TTL = 3600;

    /** Seconds to keep the current editorial stage in the cache */
    public const STAGE_CACHE_TTL = 600;

    /** Typical term of each segment of the workflow line, in days */
    public const STAGE_DAYS = [10, 90, 30, 14, 14];

    /**
     * @copydoc ThemePlugin::isActive()
     */
    public function isActive()
    {
        if (PKPSessionGuard::isSessionDisable()) {
            return true;
        }
        return parent::isActive();
    }

    /**
     * Initialize the theme's styles, scripts and hooks. This is run on the
     * currently active theme and its parent themes.
     */
    public function init()
    {
        $this->setParent('defaultthemeplugin');

        // Theme options (Settings > Website > Appearance)
        $this->addOption('accentColour', 'FieldColor', [
            'label' => __('plugins.themes.journalMetrics.option.accent.label'),
            'description' => __('plugins.themes.journalMetrics.option.accent.description'),
            'default' => self::DEFAULT_ACCENT,
        ]);
        $this->addOption('heroTagline', 'FieldText', [
            'label' => __('plugins.themes.journalMetrics.option.tagline.label'),
            'description' => __('plugins.themes.journalMetrics.option.tagline.description'),
            'isMultilingual' => true,
            'default' => '',
        ]);
        $this->addOption('showHeroStats', 'FieldOptions', [
            'label' => __('plugins.themes.journalMetrics.option.heroStats.label'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.journalMetrics.option.heroStats.option'),
                ],
            ],
            'default' => true,
        ]);
        $this->addOption('showWorkflowStrip', 'FieldOptions', [
            'label' => __('plugins.themes.journalMetrics.option.workflow.label'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.journalMetrics.option.workflow.option'),
                ],
            ],
            'default' => true,
        ]);

        $this->addOption('showWorkflowCurrent', 'FieldOptions', [
            'label' => __('plugins.themes.journalMetrics.option.workflowCurrent.label'),
            'options' => [
                [
                    'value' => true,
                    'label' => __('plugins.themes.journalMetrics.option.workflowCurrent.option'),
                ],
            ],
            'default' => true,
        ]);

        // Re-skin the parent theme through its LESS variables, so that every
        // page (login, search, archive, forms) follows the new look.
        $this->removeStyle('font');
        $accent = $this->getAccentColour();
        $this->appendParentLessVariables(join("\n", [
            '@bg-base: #FFFFFF;',
            '@text-bg-base: #141414;',
            '@bg-base-border-color: #E4E4E4;',
            '@bg-border-color: #E4E4E4;',
            '@text: rgba(20,20,20,0.92);',
            '@text-light: rgba(20,20,20,0.68);',
            '@primary: #141414;',
            '@primary-lift: ' . $accent . ';',
            '@font: "Manrope", -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Helvetica Neue", Arial, sans-serif;',
            '@font-heading: "Manrope", -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Helvetica Neue", Arial, sans-serif;',
            '@screen-lg-desktop: 1320px;',
            '@screen-lg-desktop-container: 1280px;',
        ]));

        // Fonts, accent colour and the theme stylesheet
        $this->addStyle(
            'journalMetricsFonts',
            'https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;800&family=IBM+Plex+Mono:wght@500&display=swap',
            ['baseUrl' => '']
        );
        $this->addStyle('journalMetricsAccent', ':root{--jm-accent:' . $accent . ';}', ['inline' => true]);
        $this->addStyle('journalMetrics', 'styles/journalMetrics.css');

        // Search-engine markup (canonical links, JSON-LD)
        Hook::add('TemplateManager::display', $this->onTemplateDisplay(...));
    }

    /**
     * @copydoc Plugin::getDisplayName()
     */
    public function getDisplayName()
    {
        return __('plugins.themes.journalMetrics.name');
    }

    /**
     * @copydoc Plugin::getDescription()
     */
    public function getDescription()
    {
        return __('plugins.themes.journalMetrics.description');
    }

    //
    // Methods used from Smarty templates through $activeTheme
    //

    /**
     * Usage numbers for one article: abstract-page views, PDF views and HTML views.
     * Results are cached for an hour, because they are read for every article
     * in the issue list on the home page.
     */
    public function getArticleStats(int $submissionId): array
    {
        $empty = ['views' => 0, 'pdf' => 0, 'html' => 0];
        $contextId = Application::get()->getRequest()->getContext()?->getId();
        if (!$contextId) {
            return $empty;
        }
        return Cache::remember(
            "jm_stats_{$contextId}_{$submissionId}",
            self::STATS_CACHE_TTL,
            function () use ($submissionId, $contextId, $empty): array {
                try {
                    $totals = app('publicationStats')->getTotalsByType($submissionId, $contextId, null, null);
                    return [
                        'views' => (int) ($totals['abstract'] ?? 0),
                        'pdf' => (int) ($totals['pdf'] ?? 0),
                        'html' => (int) ($totals['html'] ?? 0),
                    ];
                } catch (\Throwable $e) {
                    return $empty;
                }
            }
        );
    }

    /**
     * Usage numbers for all articles of an issue ($publishedSubmissions is the
     * list of sections assigned by the issue handler), plus issue totals and
     * the percentage of each article relative to the largest value.
     */
    public function getIssueStats($publishedSubmissions): array
    {
        $rows = [];
        $views = $pdf = $count = $max = 0;
        $firstPage = null;
        $lastPage = null;
        foreach ((array) $publishedSubmissions as $section) {
            foreach (($section['articles'] ?? []) as $submission) {
                $pages = (string) $submission->getCurrentPublication()?->getData('pages');
                if (preg_match('/^\s*(\d+)\s*[-–—]\s*(\d+)\s*$/u', $pages, $m)) {
                    $firstPage = $firstPage === null ? (int) $m[1] : min($firstPage, (int) $m[1]);
                    $lastPage = $lastPage === null ? (int) $m[2] : max($lastPage, (int) $m[2]);
                }
                $stats = $this->getArticleStats((int) $submission->getId());
                $rows[$submission->getId()] = $stats;
                $views += $stats['views'];
                $pdf += $stats['pdf'];
                $max = max($max, $stats['views'], $stats['pdf']);
                $count++;
            }
        }
        foreach ($rows as &$row) {
            $row['viewsPct'] = $max > 0 ? round($row['views'] / $max * 100, 1) : 0;
            $row['pdfPct'] = $max > 0 ? round($row['pdf'] / $max * 100, 1) : 0;
        }
        unset($row);

        $pageCount = ($firstPage !== null && $lastPage >= $firstPage) ? $lastPage - $firstPage + 1 : 0;

        return [
            'articles' => $rows,
            'views' => $views,
            'pdf' => $pdf,
            'count' => $count,
            'max' => $max,
            'pages' => $pageCount,
            'firstPage' => $firstPage,
            'lastPage' => $lastPage,
        ];
    }

    /**
     * The most read articles of the latest published issues. Returns plain
     * arrays (title, authors, url, pdfUrl, views, pdf), cached for an hour.
     */
    public function getMostRead(int $limit = 3, int $issuesCount = 2): array
    {
        $context = Application::get()->getRequest()->getContext();
        if (!$context) {
            return [];
        }
        $contextId = (int) $context->getId();
        $locale = Locale::getLocale();

        return Cache::remember(
            "jm_mostread_{$contextId}_{$locale}_{$limit}_{$issuesCount}",
            self::STATS_CACHE_TTL,
            function () use ($contextId, $limit, $issuesCount): array {
                try {
                    $request = Application::get()->getRequest();
                    $dispatcher = $request->getDispatcher();
                    $issues = Repo::issue()->getCollector()
                        ->filterByContextIds([$contextId])
                        ->filterByPublished(true)
                        ->orderBy(IssueCollector::ORDERBY_DATE_PUBLISHED)
                        ->limit($issuesCount)
                        ->getMany();

                    $rows = [];
                    foreach ($issues as $issue) {
                        $submissions = Repo::submission()->getCollector()
                            ->filterByContextIds([$contextId])
                            ->filterByIssueIds([$issue->getId()])
                            ->filterByStatus([Submission::STATUS_PUBLISHED])
                            ->getMany();
                        foreach ($submissions as $submission) {
                            $publication = $submission->getCurrentPublication();
                            if (!$publication) {
                                continue;
                            }
                            $stats = $this->getArticleStats((int) $submission->getId());
                            $path = $publication->getData('urlPath') ?: $submission->getId();
                            $authors = [];
                            foreach ($publication->getData('authors') ?? [] as $author) {
                                $authors[] = $author->getFullName();
                            }
                            $pdfUrl = null;
                            foreach ($publication->getData('galleys') ?? [] as $galley) {
                                if ($galley->isPdfGalley()) {
                                    $pdfUrl = $dispatcher->url($request, PKPApplication::ROUTE_PAGE, null, 'article', 'view', [$path, $galley->getBestGalleyId()]);
                                    break;
                                }
                            }
                            $rows[] = [
                                'title' => trim(strip_tags((string) $publication->getLocalizedTitle(null, 'text'))),
                                'authors' => join(', ', $authors),
                                'issue' => $issue->getIssueIdentification(),
                                'url' => $dispatcher->url($request, PKPApplication::ROUTE_PAGE, null, 'article', 'view', [$path]),
                                'pdfUrl' => $pdfUrl,
                                'views' => $stats['views'],
                                'pdf' => $stats['pdf'],
                            ];
                        }
                    }
                    usort($rows, fn ($a, $b) => [$b['views'], $b['pdf']] <=> [$a['views'], $a['pdf']]);
                    return array_slice(array_values(array_filter($rows, fn ($r) => $r['views'] > 0)), 0, $limit);
                } catch (\Throwable $e) {
                    return [];
                }
            }
        );
    }

    /**
     * Editorial stage shown on the workflow line.
     *
     * For a logged-in author it is the stage of their own latest submission
     * that is still in progress. For everybody else it is the stage of the most
     * recently submitted manuscript in progress; only the stage is public,
     * never the title or the author.
     *
     * @return array|null ['index' => 0..4, 'key' => string, 'mine' => bool]; the
     *  index follows the five segments of the workflow strip: screening,
     *  review, revision, copyediting, proofreading.
     */
    public function getCurrentStage(): ?array
    {
        $request = Application::get()->getRequest();
        $contextId = $request->getContext()?->getId();
        if (!$contextId) {
            return null;
        }

        // The author's own submission first (not cached: it depends on the user)
        $user = PKPSessionGuard::isSessionDisable() ? null : $request->getUser();
        if ($user) {
            $own = $this->findStage((int) $contextId, [(int) $user->getId()]);
            if ($own) {
                return $own + ['mine' => true];
            }
        }

        $stage = Cache::remember(
            "jm_stage_{$contextId}",
            self::STAGE_CACHE_TTL,
            fn (): array => $this->findStage((int) $contextId, null) ?? []
        );
        return $stage ? $stage + ['mine' => false] : null;
    }

    /**
     * Stage of the newest complete submission in progress, optionally of the
     * given authors only.
     *
     * @param int[]|null $authorIds
     */
    private function findStage(int $contextId, ?array $authorIds): ?array
    {
        try {
            $collector = Repo::submission()->getCollector()
                ->filterByContextIds([$contextId])
                ->filterByStatus([Submission::STATUS_QUEUED, Submission::STATUS_SCHEDULED])
                ->orderBy(SubmissionCollector::ORDERBY_DATE_SUBMITTED)
                ->limit(30);
            if ($authorIds) {
                $collector->assignedTo($authorIds, [Role::ROLE_ID_AUTHOR]);
            }
            foreach ($collector->getMany() as $submission) {
                // Drafts that the author has not finished sending are not "in progress".
                // filterByIncomplete(false) does not exclude them, so check here.
                if ((string) $submission->getData('submissionProgress') !== '') {
                    continue;
                }
                $stage = $this->resolveStage($submission);
                return $stage ? $stage + $this->stageProgress($submission, $stage['index']) : null;
            }
        } catch (\Throwable $e) {
            // no marker is better than a broken page
        }
        return null;
    }

    /**
     * Where the manuscript is within the typical term of its current stage.
     *
     * The stage starts at the submission date (screening) or at the date of the
     * latest editorial decision (sending to review, requesting revisions,
     * acceptance, sending to production).
     *
     * @return array ['day' => int, 'total' => int, 'percent' => int (1..100), 'over' => bool]
     */
    private function stageProgress(Submission $submission, int $index): array
    {
        $total = self::STAGE_DAYS[$index] ?? 30;
        $start = $submission->getData('dateSubmitted');
        if ($index > 0) {
            try {
                $decision = Repo::decision()->getCollector()
                    ->filterBySubmissionIds([$submission->getId()])
                    ->orderBy(DecisionCollector::ORDERBY_DATE_DECIDED, DecisionCollector::ORDER_DIR_DESC)
                    ->getMany()
                    ->first();
                if ($decision && $decision->getData('dateDecided')) {
                    $start = $decision->getData('dateDecided');
                }
            } catch (\Throwable $e) {
                // fall back to the submission date
            }
        }
        $startTime = $start ? strtotime((string) $start) : false;
        $elapsed = $startTime ? max(0, (int) floor((time() - $startTime) / 86400)) : 0;
        $percent = (int) round($elapsed / $total * 100);
        return [
            'day' => $elapsed + 1,
            'total' => $total,
            'percent' => min(100, max(1, $percent)),
            'over' => $elapsed >= $total,
        ];
    }

    private function resolveStage(Submission $submission): ?array
    {
        // Workflow stage ids of OJS: 1 submission, 2 internal review,
        // 3 external review, 4 copyediting, 5 production
        $stageId = (int) $submission->getData('stageId');
        switch ($stageId) {
            case 1:
                return ['index' => 0, 'key' => 'screening'];
            case 2:
            case 3:
                $round = DAORegistry::getDAO('ReviewRoundDAO')->getLastReviewRoundBySubmissionId($submission->getId(), $stageId);
                $status = $round ? (int) $round->getStatus() : 0;
                // 1: revisions requested, 2: resubmit for review
                if (in_array($status, [1, 2], true)) {
                    return ['index' => 2, 'key' => 'revision'];
                }
                return ['index' => 1, 'key' => 'review'];
            case 4:
                return ['index' => 3, 'key' => 'copyediting'];
            case 5:
                return ['index' => 4, 'key' => 'proofreading'];
        }
        return null;
    }

    /**
     * Links for the language switch. They use the core "setLocale" operation
     * (the same one the language block uses): it stores the language in the
     * session and in a cookie and redirects to the same page with the new
     * language in the address, so one click is enough.
     */
    public function getLocaleLinks(): array
    {
        $request = Application::get()->getRequest();
        $locales = $request->getContext()?->getSupportedLocales() ?? [];
        if (count($locales) < 2) {
            return [];
        }

        $router = $request->getRouter();
        $current = Locale::getLocale();
        $source = $request->getCompleteUrl();

        $links = [];
        foreach ($locales as $locale) {
            $code = strtolower((string) strtok($locale, '_'));
            $links[] = [
                'locale' => $locale,
                'label' => ['uk' => 'UA'][$code] ?? strtoupper($code),
                'lang' => str_replace('_', '-', $locale),
                'current' => $locale === $current,
                'url' => $router->url($request, null, 'user', 'setLocale', [$locale], ['source' => $source]),
            ];
        }
        return $links;
    }

    /**
     * Optional second part of the home page title, in the current locale.
     */
    public function getHeroTagline(): string
    {
        $value = $this->getOption('heroTagline');
        if (is_array($value)) {
            $locale = Locale::getLocale();
            $value = $value[$locale] ?? (reset($value) ?: '');
        }
        return trim((string) $value);
    }

    /**
     * The accent colour chosen in the theme options (validated hex value).
     */
    public function getAccentColour(): string
    {
        $colour = (string) $this->getOption('accentColour');
        return preg_match('/^#[0-9a-fA-F]{6}$/', $colour) ? $colour : self::DEFAULT_ACCENT;
    }

    //
    // Hooks
    //

    /**
     * Adds canonical links and schema.org markup to the <head> of the home page,
     * issue pages and article pages.
     *
     * @hook TemplateManager::display [[$templateMgr, &$template, &$output]]
     */
    public function onTemplateDisplay(string $hookName, array $args): bool
    {
        $templateMgr = $args[0];
        $template = $args[1];
        $request = Application::get()->getRequest();
        $context = $request->getContext();
        if (!$context || !is_string($template)) {
            return Hook::CONTINUE;
        }
        $dispatcher = $request->getDispatcher();
        $options = ['contexts' => ['frontend']];

        if ($template === 'frontend/pages/indexJournal.tpl') {
            $url = $dispatcher->url($request, PKPApplication::ROUTE_PAGE, null, null);
            $this->addCanonical($templateMgr, $url);
            $templateMgr->addHeader('jmJsonLd', $this->jsonLdScript($this->buildJournalJsonLd($context, $url)), $options);
        } elseif ($template === 'frontend/pages/issue.tpl') {
            $issue = $templateMgr->getTemplateVars('issue');
            if ($issue) {
                $url = $dispatcher->url($request, PKPApplication::ROUTE_PAGE, null, 'issue', 'view', [$issue->getBestIssueId()]);
                $this->addCanonical($templateMgr, $url);
            }
        } elseif ($template === 'frontend/pages/article.tpl') {
            $article = $templateMgr->getTemplateVars('article');
            $publication = $templateMgr->getTemplateVars('publication');
            $issue = $templateMgr->getTemplateVars('issue');
            if ($article && $publication) {
                $url = $dispatcher->url($request, PKPApplication::ROUTE_PAGE, null, 'article', 'view', [$article->getBestId()]);
                $this->addCanonical($templateMgr, $url);
                $templateMgr->addHeader(
                    'jmJsonLd',
                    $this->jsonLdScript($this->buildArticleJsonLd($context, $article, $publication, $issue, $url)),
                    $options
                );
            }
        }
        return Hook::CONTINUE;
    }

    //
    // Helpers
    //

    /**
     * Add the LESS variables to the parent theme's main stylesheet. They are
     * appended, so they win over the variables the parent sets from its options.
     */
    private function appendParentLessVariables(string $variables): void
    {
        $style = &$this->getStyle('stylesheet');
        if (empty($style)) {
            return;
        }
        $existing = $style['addLessVariables'] ?? '';
        if (is_array($existing)) {
            $existing = join("\n", $existing);
        }
        $style['addLessVariables'] = trim($existing . "\n" . $variables);
    }

    private function addCanonical($templateMgr, string $url): void
    {
        $templateMgr->addHeader(
            'jmCanonical',
            '<link rel="canonical" href="' . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . '" />',
            ['contexts' => ['frontend']]
        );
    }

    private function jsonLdScript(array $data): string
    {
        $flags = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP;
        return '<script type="application/ld+json">' . json_encode($data, $flags) . '</script>';
    }

    private function buildPeriodical($context): array
    {
        $issn = array_values(array_filter([
            $context->getData('onlineIssn'),
            $context->getData('printIssn'),
        ]));
        $periodical = [
            '@type' => 'Periodical',
            'name' => $context->getLocalizedName(),
        ];
        if ($issn) {
            $periodical['issn'] = count($issn) === 1 ? $issn[0] : $issn;
        }
        return $periodical;
    }

    private function buildPublisher($context): ?array
    {
        $name = $context->getData('publisherInstitution');
        return $name ? ['@type' => 'Organization', 'name' => $name] : null;
    }

    private function buildJournalJsonLd($context, string $url): array
    {
        $data = ['@context' => 'https://schema.org'] + $this->buildPeriodical($context) + ['url' => $url];
        if ($publisher = $this->buildPublisher($context)) {
            $data['publisher'] = $publisher;
        }
        if ($context->getData('publishingMode') == Journal::PUBLISHING_MODE_OPEN) {
            $data['isAccessibleForFree'] = true;
        }
        return $data;
    }

    private function buildArticleJsonLd($context, $article, $publication, $issue, string $url): array
    {
        $authors = [];
        foreach ($publication->getData('authors') ?? [] as $author) {
            $person = ['@type' => 'Person', 'name' => $author->getFullName()];
            if ($affiliation = $author->getLocalizedAffiliationNamesAsString(null, ', ')) {
                $person['affiliation'] = ['@type' => 'Organization', 'name' => $affiliation];
            }
            if ($orcid = $author->getData('orcid')) {
                $person['sameAs'] = $orcid;
            }
            $authors[] = $person;
        }

        $data = [
            '@context' => 'https://schema.org',
            '@type' => 'ScholarlyArticle',
            'headline' => trim(strip_tags((string) $publication->getLocalizedFullTitle(null, 'text'))),
            'url' => $url,
            'mainEntityOfPage' => $url,
        ];
        if ($authors) {
            $data['author'] = $authors;
        }
        if ($datePublished = $publication->getData('datePublished')) {
            $data['datePublished'] = date('Y-m-d', strtotime((string) $datePublished));
        }
        if ($abstract = trim(strip_tags(html_entity_decode((string) $publication->getLocalizedData('abstract'))))) {
            $data['abstract'] = $abstract;
        }
        $keywords = [];
        foreach ((array) $publication->getLocalizedData('keywords') as $keyword) {
            if (!empty($keyword['name'])) {
                $keywords[] = $keyword['name'];
            }
        }
        if ($keywords) {
            $data['keywords'] = join(', ', $keywords);
        }
        if ($locale = $publication->getData('locale')) {
            $data['inLanguage'] = str_replace('_', '-', $locale);
        }
        if ($doiUrl = $publication->getData('doiObject')?->getData('resolvingUrl')) {
            $data['sameAs'] = $doiUrl;
            $data['identifier'] = ['@type' => 'PropertyValue', 'propertyID' => 'DOI', 'value' => preg_replace('#^https?://(dx\.)?doi\.org/#i', '', $doiUrl)];
        }
        if ($pages = trim((string) $publication->getData('pages'))) {
            $parts = preg_split('/\s*[-–—]\s*/u', $pages);
            $data['pageStart'] = $parts[0];
            if (count($parts) > 1 && $parts[1] !== '') {
                $data['pageEnd'] = $parts[1];
            }
        }
        if ($licenseUrl = $publication->getData('licenseUrl')) {
            $data['license'] = $licenseUrl;
        }
        if ($publisher = $this->buildPublisher($context)) {
            $data['publisher'] = $publisher;
        }
        if ($context->getData('publishingMode') == Journal::PUBLISHING_MODE_OPEN) {
            $data['isAccessibleForFree'] = true;
        }

        // Journal > volume > issue > article
        $periodical = $this->buildPeriodical($context);
        $partOf = $periodical;
        if ($issue) {
            if ($issue->getVolume()) {
                $partOf = ['@type' => 'PublicationVolume', 'volumeNumber' => (string) $issue->getVolume(), 'isPartOf' => $periodical];
            }
            $issuePart = ['@type' => 'PublicationIssue', 'isPartOf' => $partOf];
            if ($issue->getNumber()) {
                $issuePart['issueNumber'] = (string) $issue->getNumber();
            }
            if ($issue->getYear()) {
                $issuePart['datePublished'] = (string) $issue->getYear();
            }
            $partOf = $issuePart;
        }
        $data['isPartOf'] = $partOf;

        return $data;
    }
}

if (!PKP_STRICT_MODE) {
    class_alias('\APP\plugins\themes\journalMetrics\JournalMetricsThemePlugin', '\JournalMetricsThemePlugin');
}
