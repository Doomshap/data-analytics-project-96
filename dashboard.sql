with tab as (
    select
        s.visitor_id,
        max(visit_date) as mx_visit 
    from sessions as s 
    left join leads as l 
        on s.visitor_id = l.visitor_id 
    where s.medium <> 'organic'
    group by 1
)
, tab2 as (
select
    s.visit_date,
    lead_id,
    l.created_at,
    closing_reason, 
    status_id 
from tab as t
inner join sessions as s
    on
        t.visitor_id = s.visitor_id
        and t.mx_visit = s.visit_date
left join leads as l 
    on
        t.visitor_id = l.visitor_id
        and t.mx_visit <= l.created_at
where medium <> 'organic' 
and status_id  = 142
), tab3 as (
select 
    (created_at-visit_date) as diff_days,
    lead_id
from tab2
order by (created_at-visit_date)
)
select 
    percentile_disc(0.9) within group (order by date_trunc('day', created_at - visit_date))
from tab2;
