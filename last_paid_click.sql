with tab as(
select
sessions.visitor_id, visit_date, source as utm_source, medium as utm_medium, campaign as utm_campaign,
lead_id, created_at, amount, closing_reason, status_id
from sessions
left join leads on leads.visitor_id=sessions.visitor_id and visit_date<created_at
where medium != 'organic'),

tab2 as(
select *,
row_number() over(partition by tab.visitor_id order by visit_date desc) as rang
from tab
order by visit_date desc)

select visitor_id, visit_date, utm_source, utm_medium, utm_campaign,
lead_id, created_at, amount, closing_reason, status_id
from tab2 where rang=1
order by amount desc NULLS last, visit_date, utm_source, utm_medium, utm_campaign
limit 10;
