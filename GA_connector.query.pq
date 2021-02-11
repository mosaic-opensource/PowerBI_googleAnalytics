// Use this file to write queries to test your data connector
let
    result = Googleanalytics.GETReports(
        "30daysAgo",
        "today",
        "ga:194571240",
        "ga:sessions",
        "ga:clientId,ga:country,ga:date"
    )
in
    result