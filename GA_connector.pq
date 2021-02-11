
// Title: Advanced Google Analytics Connector for Power BI
// Description & Goal: Data connector using the full capabilities of GA REST API with a Oauth2 connection
// Author: Pedro Magalhães - (@pmags) - www.mosaic.pt
// E-mail: pedro.magalhaes@mosaic.pt
// Repository Url:
// Based on: Ruth Pozuelo Martinez (@curbalen] https://github.com/ruthpozuelo/GoogleAnalyticsConnector

section GA_connector;

// Connection Parameters
clientId = "612276308906-p468kqi1smecbpga88qd4c75sv2lkuie.apps.googleusercontent.com";
clientSecret = "7kEn9JrouVhniNvV8-TC_jo-";

redirectUrl = "https://oauth.powerbi.com/views/oauthredirect.html";
token_uri = "https://oauth2.googleapis.com/token";
auth_uri = "https://accounts.google.com/o/oauth2/auth";
logout_uri = "https://accounts.google.com/logout";
scope = "https://www.googleapis.com/auth/analytics.readonly";

windowWidth = 720;
windowHeight = 1024;


[DataSource.Kind="GA_connector", Publish="GA_connector.Publish"]
shared NavigationTable.Simple = () =>
    let
        objects = #table(
            { "Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf" },
            { 
                { "GET Reports", "Googleanalytics.GETReports", Googleanalytics.GETReports,"Function", "Function", true }
            }       
        ),
        NavTable = Table.ToNavigationTable(objects, { "Key" }, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        NavTable;


[DataSource.Kind="GA_connector"]
shared Googleanalytics.GETReports = Value.ReplaceType( GetReports, GetReportsType );

GetReportsType = type function (
    optional PStartDate as (type text meta [ 
        Documentation.FieldCaption = "Start Date"
    ]),
     optional PEndDate as (type text meta [ 
        Documentation.FieldCaption = "End Date"
    ]),
     optional Pids as (type text meta [
        Documentation.FieldCaption = "Google account id",
        Documentation.FieldDescription = "9-letter account id",
        Documentation.SampleValues = {"ga:88362167"}
    ]),
     optional Pmetrics as (type text meta [
        Documentation.FieldCaption = "Metrics",
        Documentation.SampleValues = {"ga:sessions"}
    ]),
      optional Pdimensions as (type text meta [
        Documentation.FieldCaption = "Dimensions",
        Documentation.SampleValues = {"ga:date"}
    ]),
      optional Psort as (type text meta [
        Documentation.FieldCaption = "Sort",
        Documentation.SampleValues = {"ga:country,ga:browser"}
    ]),
      optional Pfilters as (type text meta [
        Documentation.FieldCaption = "Filters",
        Documentation.SampleValues = {"ga:medium"}
    ]),
      optional Psegment as (type text meta [
        Documentation.FieldCaption = "Max Results"
    ]))

    as table meta [
        Documentation.Name = "Google Analytics - Advance Custom Connector",
        Documentation.LongDescription = "Read the full Google Analytics API documentation from Google and find how to construct your query at:https://ga-dev-tools.appspot.com/query-explorer/",
        Documentation.Examples = {[
            Description = "Quick query to get the views by day from June 1st, 2017 until June 3rd, 2017",
            Code = "Check the Documentation at: https://ga-dev-tools.appspot.com/query-explorer/
            
            Example: 
            GoogleAnalytics.GETReports (
             #date(2017,6,1), 
             #date(2017,6,3), 
             ""ga:88362167"", 
             ""ga:sessions"", 
             ""ga:date"", 
             null, 
             null, 
             null, 
             null)",
                        Result = "#table({""date"",""sessions""},{
                        {""2017-06-01"",""230""},
                        {""2017-06-02"",""255""},
                        {""2017-06-03"",""386""}}))"
        ]}
    ];

GetReports = ( 
    optional PStartDate as text, 
    optional PEndDate as text, 
    optional Pids as text, 
    optional Pmetrics as text, 
    optional Pdimensions as text, 
    optional Psort as text, 
    optional Pfilters as text, 
    optional Psegment as text ) as table =>
    let
        testQuery = 
            [
                #"ids" = Pids,
                #"start-date" = PStartDate,
                #"end-date" = PEndDate,
                #"dimensions" = Pdimensions,
                #"metrics" = Pmetrics,
                #"max-results" = "1",
                #"start-index" = "1",
                #"samplingLevel" = "HIGHER_PRECISION",
                #"filters" = Pfilters,
                #"sort" = Psort,
                #"segment" = Psegment
            ],
        CleanedTestQuery = Record.RemoveFields( testQuery,  Table.SelectRows( Record.ToTable ( testQuery ), each ([Value] = null))[Name] ),
        testResults = Json.Document(
            Web.Contents("https://www.googleapis.com/analytics/v3/data/ga" , [Query =  CleanedTestQuery ])
        ),
        resultsSize = testResults[totalResults],
        nQueries = Number.RoundDown((resultsSize - 1) / 10000) ,
        startIndexList = Table.FromRecords(
            List.Generate(
                () => [x = 0, y = "1"],
                each [x] <= nQueries,
                each [x = [x] + 1, y = Number.ToText(10000* x + 1) ]
            )
        ),
        runQueryIndex = Table.TransformColumns(startIndexList,{"y", each getQuery(Pids, Pdimensions, Pmetrics, PStartDate, PEndDate, _, 
                                                                                    if Pfilters = null then "" else Pfilters,
                                                                                    if Psort = null then "" else Psort,
                                                                                    if Psegment = null then "" else Psegment)}),
        columnHeaders = Table.ColumnNames(runQueryIndex{0}[y]),
        ExpandData = Table.ExpandTableColumn(runQueryIndex,"y", columnHeaders),
        Output = Table.RemoveColumns(ExpandData,"x")
    in
        Output;
        

// Data Source Kind description
GA_connector = [
    Authentication = [
         OAuth = [
            StartLogin = StartLogin,
            FinishLogin = FinishLogin
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
GA_connector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = GA_connector.Icons,
    SourceTypeImage = GA_connector.Icons
];

GA_connector.Icons = [
    Icon16 = { Extension.Contents("GA_connector16.png"), Extension.Contents("GA_connector20.png"), Extension.Contents("GA_connector24.png"), Extension.Contents("GA_connector32.png") },
    Icon32 = { Extension.Contents("GA_connector32.png"), Extension.Contents("GA_connector40.png"), Extension.Contents("GA_connector48.png"), Extension.Contents("GA_connector64.png") }
];

// Functions

getQuery = ( 
    id as text,
    dimensions as text,
    metrics as text,
    startDate as text, 
    endDate as text,
    startIndex as text,
    filters as text,
    sort as text,
    segment as text
) =>
let
    maxRows = "10000",
    query = 
        [
            #"ids" = id,
            #"start-date" = startDate,
            #"end-date" = endDate,
            #"dimensions" = dimensions,
            #"metrics" = metrics,
            #"max-results" = maxRows,
            #"start-index" = startIndex,
            #"filters" = filters,
            #"sort" = sort,
            #"segment" = segment,
            #"samplingLevel" = "HIGHER_PRECISION"
        ],
    CleanedQuery = Record.RemoveFields( query,  Table.SelectRows( Record.ToTable ( query ), each ([Value] = ""))[Name] ),
    Source = Json.Document(
        Web.Contents("https://www.googleapis.com/analytics/v3/data/ga" , [Query =  CleanedQuery ])
    ),
    ColumnHeaders = Table.FromRecords(Source[columnHeaders])[name],
    DataValues = List.Transform(Source[rows], each Record.FromList(_, ColumnHeaders)),
    OutputTable = Table.FromRecords( DataValues ),
    RenameHeaders = List.Transform(Table.ColumnNames(OutputTable), each {_, Text.Replace(_,"ga:","")}),
    Output = Table.RenameColumns(OutputTable, RenameHeaders)        
in
    Output;

StartLogin = (resourceUrl, state, display) =>
    let
        AuthorizeUrl = auth_uri & "?" & Uri.BuildQueryString([
            client_id = clientId,  
            redirect_uri = redirectUrl,   
            state = "security_token",
            scope = scope,
            response_type = "code",
            response_mode = "query",
            access_type = "offline",
            login = "login"    
        ])
    in
        [
            LoginUri = AuthorizeUrl,
            CallbackUri = redirectUrl,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        parts = Uri.Parts(callbackUri)[Query],
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                   TokenMethod(parts[code])
    in
        result;

TokenMethod = (code) =>
    let
        response = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString([
                grant_type = "authorization_code",
                client_id = clientId,
                client_secret = clientSecret,
                code = code,
                redirect_uri = redirectUrl])),
            Headers = [#"Content-type" = "application/x-www-form-urlencoded",#"Accept" = "application/json"], ManualStatusHandling = {400}]),
            body = Json.Document(response),
            result = if (Record.HasFields(body, {"error", "error_description"})) 
                    then 
                        error Error.Record(body[error], body[error_description], body)
                    else
                        body
    in
        result;

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;