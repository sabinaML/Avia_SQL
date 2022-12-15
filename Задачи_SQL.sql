

--1.Какие самолеты имеют более 50 посадочных мест?
SELECT aircraft_code, count(distinct seat_no) as seat_count FROM bookings.seats
group by aircraft_code
having count(distinct seat_no)>50


--2.Есть ли рейсы, в рамках которых можно добраться бизнес - классом дешевле, чем эконом - классом?
- CTE

--таких рейсов нет
with a as (SELECT flight_id,  min(amount) Business_amount  frOM  bookings.ticket_flights 
where fare_conditions in ('Business')
group by flight_id),
b as (SELECT flight_id,  max(amount) Economy_amount  frOM  bookings.ticket_flights
where fare_conditions in ('Economy')
group by flight_id)
select coalesce(a.flight_id, b.flight_id) flight_id, Business_amount, Economy_amount, Business_amount - Economy_amount as delta
from a full join b on a.flight_id=b.flight_id
where  Business_amount - Economy_amount<0


--3.Есть ли самолеты, не имеющие бизнес - класса?
- array_agg
Да, есть


select * from (select aircraft_code, array_agg(distinct fare_conditions::text) array_ from bookings.seats
group by aircraft_code) a
where  'Business' !=all(array_)




--5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
- Оконная функция
- Оператор ROUND

select departure_airport, arrival_airport, round(count_*100/sum_total, 3) as percent_ from ( 
select *, sum(count_) over(order by count_ rows between unbounded preceding and unbounded following) sum_total from (
select departure_airport, arrival_airport, count(*) count_  from  bookings.flights f 
group by departure_airport, arrival_airport) a
) b
order by 3 desc

--6.Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7

select operator_, count(distinct phone) as count_uniq_passengers from ( 
 select  contact_data ->> 'phone' as phone, substring(contact_data ->> 'phone', 3, 3) as operator_ from bookings.tickets)a
 group by operator_


--7.Между какими городами не существует перелетов?
--- Декартово произведение
--- Оператор EXCEPT
 

with a as (select distinct city from bookings.airports) 
select a.city as departure_city, b.city as arrival_city from a cross join a b
where a.city!= b.city
EXCEPT
(select distinct departure_city , arrival_city   from bookings.routes)

--8.Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
До 50 млн - low
От 50 млн включительно до 150 млн - middle
От 150 млн включительно - high
Выведите в результат количество маршрутов в каждом классе.
- Оператор CASE

select class_, count(*) from ( 
select *, case when oborot < 50000000 then 'low'
when oborot >= 50000000 and oborot<150000000 then 'middle'
when oborot >= 150000000 then 'high' end as class_ from ( 
select flight_no, sum(amount) oborot from  bookings.ticket_flights t left join bookings.flights f on t.flight_id=f.flight_id 
group by flight_no) a) b
group by class_

--9.Выведите пары городов между которыми расстояние более 5000 км
- Оператор RADIANS или использование sind/cosd

select city_a,  city_b from ( 
select *, acos(sin(radians(latitude_a))*sin(radians(latitude_b)) + 
cos(radians(latitude_a))*cos(radians(latitude_b))*cos(radians(longitude_a - longitude_b))) as d from ( 
select a.city as city_a, a.latitude latitude_a, a.longitude longitude_a, b.city city_b, b.latitude latitude_b,
b.longitude longitude_b
from  bookings.airports a , bookings.airports b
where a.city< b.city) a )b
where  d > 0.7848


































