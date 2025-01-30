with tab1 as (
    select distinct on (sessions.visitor_id)
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
    from sessions
    left join leads
        on sessions.visitor_id = leads.visitor_id
        and sessions.visit_date <= leads.created_at
    where sessions.medium != 'organic'
    order by
        sessions.visitor_id,
        sessions.visit_date desc
),

tab as (
    select
        utm_source,
        utm_medium,
        utm_campaign,
        cast(campaign_date as date) as campaign_date,
        sum(daily_spent) as total_cost
    from vk_ads
    group by
        1, 2, 3, 4
    union
    select
        utm_source,
        utm_medium,
        utm_campaign,
        cast(campaign_date as date) as campaign_date,
        sum(daily_spent) as total_cost
    from ya_ads
    group by
        1, 2, 3, 4
),

tab2 as (
    select
        tab1.source,
        tab1.medium,
        tab1.campaign,
        cast(tab1.visit_date as date) as visit_date,
        count(tab1.visitor_id) as visitors_count,
        count(tab1.visitor_id) filter (where tab1.created_at is not null) as leads_count,
        count(tab1.visitor_id) filter (where tab1.status_id = 142) as purchases_count,
        sum(tab1.amount) filter (where tab1.status_id = 142) as revenue
    from tab1
    group by
        tab1.source,
        tab1.medium,
        tab1.campaign,
        cast(tab1.visit_date as date)
)

select
    to_char(tab2.visit_date, 'yyyy-mm-dd') as visit_date,
    tab2.visitors_count,
    tab2.source as utm_source,
    tab2.medium as utm_medium,
    tab2.campaign as utm_campaign,
    tab.total_cost,
    tab2.leads_count,
    tab2.purchases_count,
    tab2.revenue
from tab2
left join tab
    on tab2.medium = tab.utm_medium
    and tab2.source = tab.utm_source
    and tab2.campaign = tab.utm_campaign
    and tab2.visit_date = tab.campaign_date
where tab2.medium != 'organic'
order by
    tab2.revenue desc nulls last,
    tab2.visit_date asc,
    tab2.visitors_count desc,
    tab2.source asc,
    tab2.medium asc,
    tab2.campaign asc
limit 15;
