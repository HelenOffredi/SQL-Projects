/*
This data set contains booking information for a city hotel and a resort hotel, and includes information such as when the booking was made, length of stay, the number of adults, children, and/or babies, and the number of available parking spaces, among other things.
*/

--Explore raw data

SELECT column_name, data_type
FROM INFORMATION_SCHEMA.COLUMNS;

SELECT TOP(50) *
FROM hotel_bookings$;

--Summary Stats

SELECT 'Total', COUNT(lead_time) AS lead_time, SUM(booking_changes) AS booking_changes, SUM(adr) AS avg_daily_rate, SUM(total_nights_stay) AS Total_nights_stay
FROM hotel_bookings$
UNION
SELECT 'MIN', MIN(lead_time), MIN(booking_changes), MIN(adr), MIN(total_nights_stay)
FROM hotel_bookings$
UNION
SELECT 'MAX', MAX(lead_time), MAX(booking_changes), MAX(adr), MAX(total_nights_stay)
FROM hotel_bookings$
UNION
SELECT 'AVG', AVG(lead_time), AVG(booking_changes), AVG(adr), AVG(total_nights_stay)
FROM hotel_bookings$;


--DATA CLEANSING & FORMATTING

--Add in total nights stay

ALTER TABLE hotel_bookings$
ADD total_nights_stay INT;

UPDATE hotel_bookings$
SET total_nights_stay = stays_in_week_nights + stays_in_weekend_nights;

--Add columns for check in date & check out date in date format

ALTER TABLE hotel_bookings$
ADD check_in_date DATE, check_out_date DATE;

--Convert arrival date, month & year into DATE format

--Need to convert month to corresponding month number

ALTER TABLE hotel_bookings$
ADD arrival_date_month_converted FLOAT;

UPDATE hotel_bookings$
SET arrival_date_month_converted = CASE WHEN arrival_date_month = 'January' THEN 1
										WHEN arrival_date_month  = 'February' THEN 2
										WHEN arrival_date_month  = 'March' THEN 3
										WHEN arrival_date_month  = 'April' THEN 4
										WHEN arrival_date_month  = 'May' THEN 5
										WHEN arrival_date_month = 'June' THEN 6
										WHEN arrival_date_month = 'July' THEN 7
										WHEN arrival_date_month = 'August' THEN 8
										WHEN arrival_date_month = 'September' THEN 9
										WHEN arrival_date_month = 'October' THEN 10
										WHEN arrival_date_month = 'November' THEN 11
										ELSE 12 END

--Concat year, month and date as varchar then convert to date format and insert into earlier added columns
ALTER TABLE hotel_bookings$
ADD checkindateconcat VARCHAR(50)

UPDATE hotel_bookings$
SET checkindateconcat = concat(arrival_date_year, '-', arrival_date_month_converted,'-',arrival_date_day_of_month)


UPDATE hotel_bookings$
SET check_in_date = convert(DATE, checkindateconcat)

UPDATE hotel_bookings$
SET check_out_date = CONVERT(date, reservation_status_date)

--DATA EXPLORATION

--Which month has the most arrivals?
--Does this differ for Resort v City

SELECT hotel, arrival_date_year, arrival_date_month, count(*) AS ttl_arrivals
FROM hotel_bookings$
WHERE is_canceled <> 1
GROUP BY hotel, arrival_date_year, arrival_date_month, arrival_date_month_converted
ORDER BY hotel, arrival_date_year, arrival_date_month_converted;


--What is the average length of stay in days?
--Does this differ for Resort v City

SELECT hotel, AVG(total_nights_stay) AS avg_nights_stay
FROM hotel_bookings$
WHERE is_canceled <> 1
GROUP BY hotel;

--Does the avg length of stay differ throughout the year?

SELECT hotel, arrival_date_year, arrival_date_month, count(*) AS ttl_arrivals, AVG(total_nights_stay) AS avg_nights_stay
FROM hotel_bookings$
WHERE is_canceled <> 1
GROUP BY hotel, arrival_date_year, arrival_date_month, arrival_date_month_converted
ORDER BY hotel, arrival_date_year, arrival_date_month_converted;

--Which Hotel type is more popular for Babies & Children?

SELECT hotel, SUM(adults) AS ttl_adults, SUM(children) AS ttl_children, SUM(babies) AS ttl_babies
FROM hotel_bookings$
WHERE is_canceled <> 1
GROUP BY hotel;

--Is there a difference in Board Type (meal) between the resorts?

SELECT hotel, meal, COUNT(meal) AS count_meal_type
FROM hotel_bookings$
WHERE is_canceled <> 1
GROUP BY hotel, meal
ORDER BY hotel, meal;

--What country do most guests come from?

SELECT country, COUNT(*) AS bookings_by_country
FROM hotel_bookings$
GROUP BY country
ORDER BY bookings_by_country DESC;


--What is the Average Daily rate split by hotel type

SELECT hotel, round(avg(adr),2)
FROM hotel_bookings$
GROUP BY hotel;


--What is the average daily rate by month?
SELECT hotel, arrival_date_month, arrival_date_month_converted, round(avg(adr),2)
FROM hotel_bookings$
GROUP BY hotel, arrival_date_month,  arrival_date_month_converted
ORDER BY hotel, arrival_date_month_converted, arrival_date_month;

--What is the range of rates by hotel type
SELECT hotel, MAX(adr) AS max_adr, MIN(adr) AS min_adr
FROM hotel_bookings$
WHERE is_canceled <> 1 
GROUP BY hotel;

--Adr by room type

SELECT hotel, reserved_room_type, round(AVG(adr),2) AS avg_adr
FROM hotel_bookings$
GROUP BY hotel, reserved_room_type
ORDER BY hotel, avg_adr DESC;

--Market segment analysis

SELECT market_segment, COUNT(*) AS no_bookings_by_market
FROM hotel_bookings$
GROUP BY market_segment
ORDER BY no_bookings_by_market DESC;


--On how many bookings was a Deposit paid?

SELECT deposit_type, COUNT(*)
FROM hotel_bookings$
GROUP BY deposit_type;


--WHAT FACTORS AFFECT CANCELLATION RATE?

--Does ADR correlate with cancellation rate? 

SELECT adr, sum(is_canceled) AS no_cancellations
FROM hotel_bookings$ 
GROUP BY adr
ORDER BY adr;


--Does paying a deposit effect cancellation rate?

SELECT deposit_type, sum(is_canceled) AS no_cancelled_bookings, COUNT(*) AS ttl_bookings, ROUND(SUM(is_canceled)/COUNT(*)*100,1) AS canx_rate
FROM hotel_bookings$
GROUP BY deposit_type
ORDER BY no_cancelled_bookings DESC;

--Investigate the Non Refund 99.4% canx rate further, do we need to exclude these from our analysis

SELECT *
FROM hotel_bookings$
WHERE deposit_type = 'Non Refund';



--Does customer type effect cancellation rate?

SELECT customer_type, sum(is_canceled) AS no_cancelled_bookings, COUNT(*) AS ttl_bookings, ROUND(SUM(is_canceled)/COUNT(*)*100,1) AS canx_rate
FROM hotel_bookings$
GROUP BY customer_type
ORDER BY no_cancelled_bookings DESC;

--Which country has the highest cancellation rate?

SELECT country, sum(is_canceled) AS no_cancelled_bookings, COUNT(*) AS ttl_bookings, ROUND(SUM(is_canceled)/COUNT(*)*100,1) AS canx_rate
FROM hotel_bookings$
GROUP BY country
ORDER BY no_cancelled_bookings DESC;

--AVG cancellation rate

SELECT sum(is_canceled) AS no_cancelled_bookings, COUNT(*) AS ttl_bookings, ROUND(SUM(is_canceled)/COUNT(*)*100,1) AS canx_rate
FROM hotel_bookings$
WHERE deposit_type <> 'Non Refund';



--Tableau Dashboard Views
--1 Guest Info
SELECT hotel, country, check_in_date, total_nights_stay, customer_type, adults, children, babies
FROM hotel_bookings$
WHERE is_canceled = 0;

--2 Booking Info
SELECT hotel, lead_time, adr, meal, market_segment, reserved_room_type, assigned_room_type, total_of_special_requests
FROM hotel_bookings$
WHERE is_canceled = 0;

--Cancellation Info
SELECT hotel, is_canceled, country, customer_type, lead_time, adr, market_segment, deposit_type
FROM hotel_bookings$





