WITH tab AS (
    SELECT
        s.visitor_id,
        MAX(s.visit_date) AS mx_visit
    FROM sessions AS s
    LEFT JOIN leads AS l
        ON s.visitor_id = l.visitor_id
    WHERE s.medium != 'organic'
    GROUP BY s.visitor_id
),

tab2 AS (
    SELECT
        s.visit_date,
        l.lead_id,
        l.created_at,
        l.closing_reason,
        l.status_id
    FROM tab AS t
    INNER JOIN sessions AS s
        ON
            t.visitor_id = s.visitor_id
            AND t.mx_visit = s.visit_date
    LEFT JOIN leads AS l
        ON
            t.visitor_id = l.visitor_id
            AND t.mx_visit <= l.created_at
    WHERE
        s.medium != 'organic'
        AND l.status_id = 142
)

SELECT
    PERCENTILE_DISC(0.9) WITHIN GROUP (
        ORDER BY DATE_TRUNC('day', tab2.created_at - tab2.visit_date)
    )
FROM tab2;
