/*1. Examine the airports table and display a list of cities (city) that have airports.*/

SELECT distinct city FROM airports;


/*2. Examine the flights table and count the number of departures (flight_id) from each departure airport (departure_airport). 
Name the variable cnt_flights and display it along with the departure_airport column — departure_airport first, then cnt_flights. 
Sort the results in the descending order by the number of departures.*/

SELECT count(flight_id) as cnt_flights, departure_airport
FROM flights
GROUP BY departure_airport
ORDER BY cnt_flights desc;

/*3. Find the number of flights for each aircraft model departing in September 2018. Name the resulting column flights_amount.
Expected output: model, flights_amount */

SELECT aircrafts.model, count(flights.flight_id) as flights_amount
FROM aircrafts
INNER JOIN flights on aircrafts.aircraft_code = flights.aircraft_code
WHERE flights.departure_time :: date BETWEEN '2018-09-01' and '2018-09-30'
GROUP BY aircrafts.model;

/*4. Count the number of flights for Boeing, Airbus and 'other' aircraft models in September.*/

SELECT count(flights.flight_id) as flights_amount,
    CASE
        WHEN aircrafts.model LIKE '%Boeing%' THEN 'Boeing'
        WHEN aircrafts.model LIKE '%Airbus%' THEN 'Airbus'
        ELSE 'other'
    END AS type_aircraft   
FROM aircrafts
INNER JOIN flights on aircrafts.aircraft_code = flights.aircraft_code
WHERE
    flights.departure_time :: date BETWEEN '2018-09-01' and '2018-09-30'
GROUP BY type_aircraft
ORDER BY flights_amount DESC;

/*5. Calculate the average number of arriving flights per day for each city in August 2018. Expected output: city, average_flights.*/

SELECT airports.city, avg(SUBQ.cnt_flights) as average_flights
FROM airports
INNER JOIN
(
SELECT airports.city, count(flights.flight_id) as cnt_flights, extract (day from flights.arrival_time) as days
FROM airports
INNER JOIN flights on airports.airport_code = flights.arrival_airport
WHERE flights.arrival_time :: date BETWEEN '2018-08-01' and '2018-08-31'
GROUP BY city, days
)
as SUBQ ON airports.city = SUBQ.city
GROUP BY airports.city;

/*6. Select the festivals that took place from July 23 to September 30, 2018 in Moscow, and the number of the week in which they took place. 
Expected output: festival_name, festival_week.*/

SELECT festival_name, extract (week from festival_date) as festival_week
FROM festivals
WHERE (festival_date :: date BETWEEN '2018-07-23' and '2018-09-30') and (festival_city = 'Москва');


/*7. For each week from July 23 to September 30, 2018, count the number of tickets purchased for flights to Moscow (week_number and ticket_amount). 
Get a table that will contain the week number; information on the number of tickets purchased per week; the week number again if there was a festival that week, and nan if it didn't; 
as well as the name of the festival. Expected output: week_number, ticket_amount, festival_week, festival_name.*/

SELECT
    T.week_number,
    T.ticket_amount,
    T.festival_week,
    T.festival_name
FROM ((
        SELECT
            EXTRACT(week FROM flights.departure_time) AS week_number,
            COUNT(ticket_flights.ticket_no) AS ticket_amount
        FROM
            airports
            INNER JOIN flights ON airports.airport_code = flights.arrival_airport
            INNER JOIN ticket_flights ON flights.flight_id = ticket_flights.flight_id
        WHERE
            airports.city = 'Москва'
            AND CAST(flights.departure_time AS date) BETWEEN '2018-07-23' AND '2018-09-30'
        GROUP BY
            week_number) t
    LEFT JOIN (
        SELECT
            festival_name,
            EXTRACT(week FROM festivals.festival_date) AS festival_week
        FROM
            festivals
        WHERE
            festival_city = 'Москва'
            AND CAST(festivals.festival_date AS date) BETWEEN '2018-07-23' AND '2018-09-30') t2 ON t.week_number = t2.festival_week) AS T;
