WITH tab1 AS (
    SELECT DISTINCT ON (sessions.visitor_id)
        sessions.visitor_id,
        sessions.visit_date,
        leads.created_at,
        leads.status_id,
        leads.amount,
        leads.lead_id,
        leads.closing_reason,
        sessions.medium,
        sessions.source,
        sessions.campaign
    FROM sessions
    LEFT JOIN leads
        ON sessions.visitor_id = leads.visitor_id
            AND sessions.visit_date <= leads.created_at
    WHERE sessions.medium != 'organic'
    ORDER BY
        sessions.visitor_id ASC,
        sessions.visit_date DESC
),
        
    tab AS (
    SELECT
            utm_source,
            utm_medium,
            utm_campaign,
            CAST(campaign_date AS DATE) AS campaign_date,
            SUM(daily_spent) AS total_cost
        FROM vk_ads
        GROUP BY utm_source, utm_medium, utm_campaign, campaign_date

        UNION

        SELECT
            utm_source,
            utm_medium,
            utm_campaign,
            CAST(campaign_date AS DATE) AS campaign_date,
            SUM(daily_spent) AS total_cost
        FROM ya_ads
        GROUP BY utm_source, utm_medium, utm_campaign, campaign_date
),

    tab2 AS (
        SELECT
            tab1.source,
            tab1.medium,
            tab1.campaign,
            CAST(tab1.visit_date AS DATE) AS visit_date,
            COUNT(tab1.visitor_id) AS visitors_count,
            COUNT(tab1.visitor_id) FILTER (WHERE tab1.created_at IS NOT NULL) 
                AS leads_count,
            COUNT(tab1.visitor_id) FILTER (WHERE tab1.status_id = 142) 
                AS purchases_count,
            SUM(tab1.amount) FILTER (WHERE tab1.status_id = 142) AS revenue
        FROM tab1
        GROUP BY
            tab1.source,
            tab1.medium,
            tab1.campaign,
            CAST(tab1.visit_date AS DATE)
)

SELECT
    TO_CHAR(tab2.visit_date, 'YYYY-MM-DD') AS visit_date,
    tab2.visitors_count,
    tab2.source AS utm_source,
    tab2.medium AS utm_medium,
    tab2.campaign AS utm_campaign,
    tab.total_cost,
    tab2.leads_count,
    tab2.purchases_count,
    tab2.revenue
FROM tab2
LEFT JOIN tab
    ON tab2.medium = tab.utm_medium
    AND tab2.source = tab.utm_source
    AND tab2.campaign = tab.utm_campaign
    AND tab2.visit_date = tab.campaign_date
WHERE tab2.medium != 'organic'
ORDER BY
    tab2.revenue DESC NULLS LAST,
    tab2.visit_date ASC,
    tab2.visitors_count DESC,
    tab2.source ASC,
    tab2.medium ASC,
    tab2.campaign ASC
LIMIT 15;
