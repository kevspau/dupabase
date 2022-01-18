module dupabase;

import std.net.curl, std.json;
import std.algorithm.searching, std.algorithm.mutation;
import std.json, std.array;
import std.stdio, std.conv : to; //debugging
///The main class used for sending API requests.
class Database {
    ///Used for visual purposes and organization.
    public string name;
    ///The client used for making POST and GET requests to the API.
    public HTTP client;
    ///The anon or service_role key
    protected string key;
    ///The API URL endpoint that the client uses to access the database.
    protected string endpoint;
    private string restEndpoint;
    private string authEndpoint;
    ///The access token of the currently logged in user. This is changed every time Database.login() is called.
    public string access_token;
    ///The constructor for the Database class, but it is recommended to use the init() function. Remember to use the service_role key for the keyy variable if you have RLS enabled with no policies.
    this(string endpointt, string keyy, string namee) {
        key = keyy;
        auto temp_endpoint = endpointt;
        if (!endpointt.endsWith(".supabase.co")) {
            temp_endpoint = temp_endpoint ~ ".supabase.co";
        }
        if (!endpointt.startsWith("https://")) {
            temp_endpoint = "https://" ~ temp_endpoint;
        }
        endpoint = temp_endpoint;
        restEndpoint = endpoint ~ "/rest/v1/";
        authEndpoint = endpoint ~ "/auth/v1/";
        name = namee;
        client = HTTP(); //remove endpointt, find a way to manipulate url afterwards
    }
    ///Returns the currently set key.
    @property auto gkey() {
        return key;
    }
    ///Returns the currently set endpoint.
    @property auto gendpoint() {
        return endpoint;
    }
    protected void setHeaders() {
        client.url = "";
        client.clearRequestHeaders();
        client.addRequestHeader("apikey", key);
        client.addRequestHeader("Authorization",  "Bearer " ~ key);
    }
    protected void setAuthPostHeaders() {
        client.clearRequestHeaders();
        client.addRequestHeader("apikey", key);
        client.addRequestHeader("Content-Type", "application/json");
    }
    protected void setAuthHeaders() {
        client.clearRequestHeaders();
        client.addRequestHeader("apikey", key);
    }
    ///Creates a new user using the given email and password. Returns a CurlCode.
    @property auto newUser(string email, string password) {
        setAuthPostHeaders();
        client.setPostData(JSONValue(["email":email, "password":password]).to!string(), "application/json");
        client.url = authEndpoint ~ "signup";
        //writeln(JSONValue(["email":email, "password":password]).to!string());
        return client.perform();//post(authEndpoint ~ "signup", JSONValue(["email":email, "password":password]).to!string(), client);
    }
    ///Logs into a users account using the given email and password. This changes the access_token.
    auto login(string email, string password, string grant_type = "password") {
        setAuthPostHeaders();
        auto json = post(authEndpoint ~ "token?grant_type=" ~ grant_type, JSONValue(["email":email, "password":password]).to!string(), client);
        access_token = json.parseJSON().object["access_token"].str;
        return json;
    }
    ///In progress. Will allow you to sign into a database using the given third party service.
    @disable auto externalLogin(string service = "github") {
        setAuthPostHeaders();
        return post(authEndpoint ~ "token", JSONValue(["provider":service]).to!string());
    }
    ///Returns a map of data relating to the currently logged in user.
    @property auto getUser() {
        setAuthHeaders();
        client.addRequestHeader("Authorization", "Bearer " ~ access_token);
        auto json = get(authEndpoint ~ "user", client).parseJSON().object;
        return json;
    }
    ///Logs the current user out. This also resets the access_token.
    @property auto logout() {
        client.clearRequestHeaders();
        client.postData("");
        client.addRequestHeader("apikey", key);
        client.addRequestHeader("Authorization", "Bearer " ~ access_token);
        client.addRequestHeader("Content-Type", "application/json");
        client.method(HTTP.Method.post);
        client.url = authEndpoint ~ "logout";
        access_token = "";
        return client.perform();
    }
    ///Returns all rows, or returns a list of rows in the given filter or pagination. Currently only the .eq() function is supported for filtering. Not given the @property attribute so that filtering and pagination may be added as parameters
    auto getRows(string table, string pagination = "0-0", string[string] filter = ["":""]) {
        //client.method = HTTP.Method.get;
        setHeaders();
        string filters = "";
        if (filter != ["":""]) {
            foreach (k, v; filter) {
                filters ~= k ~ "=eq." ~ v ~ "&";
            }
        }
        if (pagination != "0-0") {
            client.addRequestHeader("Range", pagination);
        }
        auto x = get(restEndpoint ~ table ~ "?" ~ filters ~ "select=*", client);
        auto json = parseJSON(x).array();
        foreach (i, v; json) {
            v = v.object();
        }
        return json;
        //client.perform(endpoint ~ "/rest/v1/" ~ name ~ "?select=*", client);
    }
    ///Deletes all rows that have the given filter. At the moment, does not work with values that include spaces.
    @property auto deleteRows(string table, string[string] filter) {
        setHeaders();
        char[] filters;
        foreach (k, v; filter) {
            filters ~= k ~ "=eq." ~ v ~ "&";
        }
        filters = filters.remove(filters.length-1);
        /*filters = filters.replace("=", "=\"");
        filters = filters ~ "\"";
        writeln(filters.to!string());*/
        return del(restEndpoint ~ table ~ "?" ~ filters.to!string(), client);
    }
    ///Updates all rows that match the given filter with the given data. Returns a CurlCode.
    auto updateRows(string table, string[string] filter, string[string] data) {
        setHeaders();
        client.method(HTTP.Method.patch);
        char[] filters;
        foreach (k, v; filter) {
            filters ~= k ~ "=eq." ~ v ~ "&";
        }
        filters = filters.remove(filters.length-1);
        client.url = restEndpoint ~ table ~ "?" ~ filters;
        client.setPostData(JSONValue(data).to!string(), "application/json");
        return client.perform();
    }
    ///Appends one or more rows to the given table. Not completely trustable, as it randomly returns code 400s. Returns the POST request to the server. Set upsert to true unless you know what you're doing.
    auto makeRows(string table, bool upsert, string[string][] data ...) { //TODO: fix constantly getting response code 400
        setHeaders();
        client.addRequestHeader("Content-Type", "application/json");
        if (upsert) {
            client.addRequestHeader("Prefer", "resolution=merge-duplicates");
        }
        JSONValue[] postArr;
        string postObj;
        if (data.length > 1) {
            foreach (i, v; data) {
                auto postValue = JSONValue(v);
                postArr ~= postValue;
            }
            return post(restEndpoint ~ table, postArr.to!string(), client);
        } else {
            postObj = JSONValue(data[0]).to!string();
            //writeln(postObj);
            return post(restEndpoint ~ table, postObj, client);
        }
        return post(restEndpoint ~ table, "{\"hello\":\"world\"}", client);
    }
    ///Gets a specific column and all of its values in an array
    @property auto getColumn(string table, string column) {
        setHeaders();
        auto x = get(restEndpoint ~ table ~ "?select=" ~ column, client);
        auto json = parseJSON(x).array();
        string[] ret;
        foreach (i, v; json) {
            ret ~= to!string(v.object()[column]);
        }
        return ret;
    }
    ///Gets a specific row and all of its values in a map
    @property auto getRow(string table, int row) {
        setHeaders();
        auto json = get(restEndpoint ~ table ~ "?select=*", client);
        auto x = parseJSON(json)[row - 1].object();
        return x;
    }
}
///The same as Database, but the member functions return the naked JSONValue instead of a modified value, and requires more context on the endpoint (you have to add /rest/v1, /auth/v1, etc.)
class LLDatabase : Database { //TODO: CHANGE THE FUNCTIONS

    public string LLendpoint;
    public string LLkey;
    this(string endpointt, string keyy, string namee = "db") {
        super(endpointt, keyy, namee);
        LLkey = keyy;
        LLendpoint = endpointt;
        name = namee;
        client = HTTP(); //remove endpointt, find a way to manipulate url afterwards
    }
    auto getRowsLL(string table, string pagination = "0-0", string[string] filter = ["#000nil000#":"#000nil000#"]) {
        //client.method = HTTP.Method.get;
        setHeaders();
        string filters = "";
        if (filter == ["#000nil000#":"#000nil000#"]) {
            foreach (k, v; filter) {
                filters ~= k ~ "=eq." ~ v ~ "&";
            }
        }
        if (pagination != "0-0") {
            client.addRequestHeader("Range", pagination);
        }
        auto x = get(LLendpoint ~ "/" ~ table ~ "?" ~ filters ~ "select=*", client);
        auto json = parseJSON(x);
        return json;
        //client.perform(endpoint ~ "/rest/v1/" ~ name ~ "?select=*", client);
    }
    ///Gets a specific column and all of its values in a map
    @property auto getColumnLL(string table, string column) {
        setHeaders();
        auto x = get(LLendpoint ~ table ~ "?select=" ~ column, client);
        auto json = parseJSON(x);
        return json;
    }
    ///Gets a specific row and all of its values in a map, row indexes start at 1
    @property auto getRowLL(string table, int row) {
        setHeaders();
        auto json = get(LLendpoint ~ table ~ "?select=*", client);
        auto x = parseJSON(json)[row - 1];
        return x;
    }
}
///Initializes and returns a Database class. You may omit the "https://" or ".supabase.co" section of the endpoint for readability.
Database newDB(string endpoint, string key, string name = "db") {
    auto xyz = new Database(endpoint, key, name);
    return xyz;
}