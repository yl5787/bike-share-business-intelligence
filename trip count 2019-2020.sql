WITH MonthlyTrips AS (
  SELECT
    EXTRACT(YEAR FROM DATE_ADD(DATE(TRI.starttime), INTERVAL 5 YEAR)) AS year,
    EXTRACT(MONTH FROM DATE_ADD(DATE(TRI.starttime), INTERVAL 5 YEAR)) AS month,
    TRI.usertype,
    COUNT(TRI.bikeid) AS trip_count
  FROM
    `bigquery-public-data.new_york_citibike.citibike_trips` AS TRI
  INNER JOIN
    `bigquery-public-data.geo_us_boundaries.zip_codes` ZIPSTART
    ON ST_WITHIN(
      ST_GEOGPOINT(TRI.start_station_longitude, TRI.start_station_latitude),
      ZIPSTART.zip_code_geom)
  INNER JOIN
    `bigquery-public-data.geo_us_boundaries.zip_codes` ZIPEND
    ON ST_WITHIN(
      ST_GEOGPOINT(TRI.end_station_longitude, TRI.end_station_latitude),
      ZIPEND.zip_code_geom)
  INNER JOIN
    `bigquery-public-data.noaa_gsod.gsod20*` AS WEA
    ON PARSE_DATE("%Y%m%d", CONCAT(WEA.year, WEA.mo, WEA.da)) = DATE(TRI.starttime)
  INNER JOIN
    `cyclistic.zip_codes` AS ZIPSTARTNAME
    ON ZIPSTART.zip_code = CAST(ZIPSTARTNAME.zip AS STRING)
  INNER JOIN
    `cyclistic.zip_codes` AS ZIPENDNAME
    ON ZIPEND.zip_code = CAST(ZIPENDNAME.zip AS STRING)
  WHERE
    WEA.wban = '94728' -- NEW YORK CENTRAL PARK
    AND EXTRACT(YEAR FROM DATE_ADD(DATE(TRI.starttime), INTERVAL 5 YEAR)) BETWEEN 2019 AND 2020
  GROUP BY
    1,
    2,
    3
)

SELECT
  year,
  month,
  usertype,
  SUM(trip_count) AS trip_count
FROM
  MonthlyTrips
GROUP BY
  1,
  2,
  3
ORDER BY
  1,
  2,
  3;
