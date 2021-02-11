# PowerBI Google Analytics Custom Connector

Advance google analytics custom connector for Power BI.

## Motivation:

Power Bi usage has grown exponencialy in the last year. The ease of use combined with a very capable analytics engine has proved to be an attractive for many teams from startups to big companies. Marketing deparments and digital marketing teams are no expection. Daily they need to make sense of an increasing amount of data from different data sources.

Although PowerBI comes with a Google Analytics connector out of the box, is has its limitations. For starters it doesn´t allow the user to access sort and segment funcionalities which are key for a complete understand of clickstream data. On the other hand, although M does Query Folding time filters, it requires the user to have some degree of M Language knowledge which often lacks among marketeers. 

Therefore, there was a need to create a custom connector that would allow to access all the funcionalities available in Google Analytics API which could complement power bi official connector.

## What you can do with this connector:

Allows to create API queries similiar to the ones found on Google's query explorer (https://ga-dev-tools.appspot.com/query-explorer/). This connector compensates for the 10.000 rows limit in each request.

## Initial Setup:

To use this connector you will have to create a app with the necessary credential ids and screts. You can find a tutoria here https://developers.google.com/identity/protocols/oauth2. The values generated this way should be replaced in the files <cliente_id> and <client_secret> in this project.

## Known limitations:

- As of Fev/2021 custom connectors only run on power bi service if a on-premises Getway is setup. (this could be achieve with a VM)
- Currently this connector does not avoid Sampling at the free accounr achieved at the 500.000 sessions.

## How to use this connector

- Install power query sdk https://docs.microsoft.com/en-us/power-query/installingsdk,
- Clone this repository into your local environment,
- use Visual Studio to build this project,
- Copy the .mez file from build into *./Documents/Power BI Desktop/Custom connectors
- It should appear as a new datasource. Select the function in the navigation and start creating your queries.

## Special thanks and much deserved recognition:

This connector is inspired and expands on the amazing worke form Ruth Pozuelo Martinez (@curbalen). You can find her implementation in the following link <https://github.com/ruthpozuelo/GoogleAnalyticsConnector>

<a href="www.mosaic.pt">
  <img src="https://www.mosaic.pt/images/Logo%20Cor%20Final%20Mosaic.png" alt="www.mosaic.ot" width="100" height="20">
</a> 
