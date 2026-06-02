create database zomato;
use zomato;

# 1. Build a Country Map Table 

CREATE TABLE country_map (
    country_code INT PRIMARY KEY,
    country_name VARCHAR(50)
);

INSERT INTO country_map (country_code, country_name) VALUES 
(1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Philippines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'UAE'),
(215, 'United Kingdom'),
(216, 'United States');
SELECT * FROM country_map;

#2 Build a Calendar Table using the Column Datekey

RENAME TABLE zomato TO res_details;
alter table res_details add opening_date date;
SET SQL_SAFE_UPDATES = 0;
update  res_details set opening_date=STR_TO_DATE(Datekey_Opening, '%Y_%c_%e');

CREATE TABLE new_calendar (
    calendar_date DATE ,
    cal_year INT,
    month_no INT,
    month_fullname VARCHAR(15),
    cal_quarter VARCHAR(2),
    year_mon VARCHAR(10),
    weekday_no INT,
    weekday_name VARCHAR(10),
    financial_month VARCHAR(5),
    financial_quarter VARCHAR(5)
);

INSERT INTO new_calendar (calendar_date)
SELECT opening_date
FROM res_details
WHERE opening_date IS NOT NULL;

select * from new_calendar;

update new_calendar set cal_year=year(calendar_date),month_no=month(calendar_date),month_fullname=monthname(calendar_date),cal_quarter=concat('Q',quarter(calendar_date)),
year_mon=date_format(calendar_date,'%Y-%b'),weekday_no=Weekday(calendar_date)+1,weekday_name=dayname(calendar_date);
UPDATE new_calendar
SET financial_month =
    CASE
        WHEN MONTH(calendar_date) >= 4
            THEN CONCAT('FM', MONTH(calendar_date) - 3)
        ELSE
            CONCAT('FM', MONTH(calendar_date) + 9)
    END
WHERE calendar_date IS NOT NULL;

update new_calendar 
set financial_quarter=
	case
		when month(calendar_date) >=4 and month(calendar_date)<=6 then "FQ1"
		when month(calendar_date)>= 7 and month(calendar_date)<= 9 then "FQ2"
        when month(calendar_date)>=10 and month(calendar_date)<=12 then "FQ3"
        else "FQ4"
	end;
    select * from res_details;
    select * from new_calendar;
    
#3  Find the Numbers of Resturants based on City and Country.
    
    SELECT cm.country_name,rd.city,COUNT(rd.restaurantid) AS restaurant_count
    FROM res_details rd
	JOIN country_map cm
    ON rd.CountryCode = cm.country_code
    GROUP BY cm.country_name, rd.city;
    
# 4.Numbers of Resturants opening based on Year , Quarter , Month
  
SELECT  nc.cal_year,nc.cal_quarter, nc.month_fullname,COUNT(rd.restaurantid) AS restaurants_opened
FROM res_details rd
JOIN new_calendar nc
ON rd.opening_date = nc.calendar_date
GROUP BY nc.cal_year,nc.cal_quarter, nc.month_fullname,nc.month_no
ORDER BY nc.cal_year,nc.cal_quarter,nc.month_no; 

# 5. Count of Resturants based on Average Ratings

SELECT Rating,COUNT(RestaurantID) AS NumberOfRestaurants
FROM res_details
GROUP BY Rating
ORDER BY Rating;

# 6. Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets

SELECT
    CASE
        WHEN Average_Cost_for_two BETWEEN 0 AND 25 THEN '0-25'
        WHEN Average_Cost_for_two BETWEEN 26 AND 50 THEN '26-50'
        WHEN Average_Cost_for_two BETWEEN 51 AND 75 THEN '51-75'
        WHEN Average_Cost_for_two BETWEEN 76 AND 100 THEN '76-100'
        ELSE '100+' 
    END AS CostBucket,
    COUNT(*) AS RestaurantCount,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM res_details),
        2
    ) AS SharePercentage

FROM res_details
GROUP BY CostBucket
ORDER BY 
    CASE
        WHEN CostBucket = '0-25' THEN 1
        WHEN CostBucket = '26-50' THEN 2
        WHEN CostBucket = '51-75' THEN 3
        WHEN CostBucket = '76-100' THEN 4
        ELSE 5
    END;
    
# 7. Percentage of Resturants based on "Has_Table_booking"

SELECT
    Has_Table_booking,
    COUNT(*) AS RestaurantCount,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM res_details),
        2
    ) AS SharePercentage
FROM res_details
GROUP BY Has_Table_booking
ORDER BY Has_Table_booking;

# 8. Percentage of Resturants based on "Has_Online_delivery"

SELECT
    Has_Online_delivery,
    COUNT(*) AS RestaurantCount,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM res_details),
        2
    ) AS SharePercentage
FROM res_details
GROUP BY Has_Online_delivery
ORDER BY Has_Online_delivery;
    

