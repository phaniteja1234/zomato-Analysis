use uncleaned;

--- what is the total amount each customer spent on zomato
select userid,sum(price) from sales s1
join product p2
on s1.product_id=p2.product_id
group by userid;

--- how many days each customer visited the zomato
select userid,count(distinct(created_date)) from sales s1
group by userid;

-- what was the first product purchased by each customer
select t.userid,dates,product_id from(
select userid, min(created_date) 'dates' from sales
group by userid) t
join sales s
on t.dates=s.created_date
and t.userid=s.userid
order by userid;

select * from
(select  *,rank() over(partition by userid order by created_date) 'rank' from sales)t
where t.rank=1;

-- what is the most purchased item on the menu and how many times it was purchased by the all ustomer
select product_id,count(*) from sales
group by product_id;

select s.userid,count(s.product_id) from(
select product_id,count(*) 'count' from sales
group by product_id
order by count desc limit 1)t
join sales s
on
t.product_id=s.product_id
group by s.userid;

-- which item is most purchased for each customer

select * from(
select *,rank() over(partition by userid order by count desc) as 'rank' from(
select userid,product_id,count(*) 'count' from sales
group by userid,product_id)t)s
where s.rank=1;
 -- which item was purchased  the  customer after they become meber
select * from(
SELECT 
  t.*, 
  RANK() OVER (PARTITION BY t.userid ORDER BY t.created_date) AS rank
FROM (
  SELECT g.userid, g.gold_signup_date, s.userid as sale_userid, s.created_date, s.product_id 
  FROM goldusers_signup g
  JOIN sales s ON g.userid=s.userid AND s.created_date>=g.gold_signup_date
) t)s
where s.rank=1;

-- which item was first purchased by the customer just before they take membership
select * from(
SELECT 
  t.*, 
  RANK() OVER (PARTITION BY t.userid ORDER BY t.created_date DESC) AS rank
FROM (
  SELECT g.userid, g.gold_signup_date, s.userid as sale_userid, s.created_date, s.product_id 
  FROM goldusers_signup g
  JOIN sales s ON g.userid=s.userid AND s.created_date< g.gold_signup_date
) t)s
where s.rank=1;

-- what is the total orders and amount spent by each customer before they become a member
SELECT s.userid,sum(p.price),count(*) 'total_orders'
  FROM goldusers_signup g
  JOIN sales s ON g.userid=s.userid AND s.created_date< g.gold_signup_date
  join product p
  on s.product_id=p.product_id
  group by userid;
-- give zomato bonus points to user based on their total money spent 
-- for product_id=1 5rs=1 and product_id=2 10rs=2 pts
-- so on...
  select userid,round(sum(zomato_points)*2.5,2) as'total_cashbackearned' from(
select *,
case 
when product_id=1 then tot_price/5
when product_id=2 then tot_price/2
when product_id=3 then tot_price/5
else 0
end
as 'zomato_points'
  from(
select s.userid,p.product_id,sum(price) as'tot_price' from sales s
join product p
on s.product_id=p.product_id
group by userid,product_id)t)s
group by userid;

-- rank the customers based on their transaction
select userid,sum(price), rank() over(order by sum(price) desc) 'rank' from sales s
join product p
on s.product_id=p.product_id
group by userid