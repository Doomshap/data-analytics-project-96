WITH tab AS (
    SELECT
        sessions.visitor_id,
        sessions.visit_date,
        sessions.source AS utm_source,
        sessions.medium AS utm_medium,
        sessions.campaign AS utm_campaign,
        leads.lead_id,
        leads.created_at,
        leads.amount,
        leads.closing_reason,
        leads.status_id
    FROM sessions
    LEFT JOIN leads
        ON
            leads.visitor_id = sessions.visitor_id
            AND sessions.visit_date < leads.created_at
    WHERE sessions.medium != 'organic'
),

tab2 AS (
    SELECT
        tab.*,
        ROW_NUMBER() OVER
            (PARTITION BY tab.visitor_id ORDER BY tab.visit_date DESC) AS rang
    FROM tab
    ORDER BY tab.visit_date DESC
)

SELECT
    tab2.visitor_id,
    tab2.visit_date,
    tab2.utm_source,
    tab2.utm_medium,
    tab2.utm_campaign,
    tab2.lead_id,
    tab2.created_at,
    tab2.amount,
    tab2.closing_reason,
    tab2.status_id
FROM tab2
WHERE tab2.rang = 1
ORDER BY
    tab2.amount DESC NULLS LAST,
    tab2.visit_date ASC,
    tab2.utm_source ASC,
    tab2.utm_medium ASC,
    tab2.utm_campaign ASC
LIMIT 10;
