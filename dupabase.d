module dupabase;

import std.net.curl, std.json;
import std.algorithm.searching : canFind;
import std.json;
import std.stdio, std.conv : to; //debugging
private class Database {
    ///Used for visual purposes and organization.
    public string name;
    ///The client used for making POST and GET requests to the API.
    public HTTP client;
    ///The anon or service_role key
    protected string key;
    ///The API URL endpoint that the client uses to access the database.
    protected string endpoint;
    private string restEndpoint;
    ///The constructor for the Database class, but it is recommended to use the init() function. Remember to use the service_role key for the keyy variable if you have RLS enabled with no policies.
    this(string endpointt, string keyy, string namee) {
        key = keyy;
        auto temp_endpoint = endpointt;
        if (!endpointt.canFind(".supabase.co")) {
            temp_endpoint = temp_endpoint ~ ".supabase.co";
        }
        if (!endpointt.canFind("https://")) {
            temp_endpoint = "https://" ~ temp_endpoint;
        }
        endpoint = temp_endpoint;
        restEndpoint = endpoint ~ "/rest/v1/";
        name = namee;
        client = HTTP(); //remove endpointt, find a way to manipulate url afterwards
    }
    @property auto getKey() {
        return key;
    }
    @property auto getEndpoint() {
        return endpoint;
    }
    @property void setEndpoint(string endpointt) {
        endpoint = endpointt;
    }
    protected void setHeaders() {
        client.clearRequestHeaders();
        client.addRequestHeader("apikey", key);
        client.addRequestHeader("Authorization",  "Bearer " ~ key);
    }
    ///Returns all rows, or returns a list of rows in the given filter or pagination. Currently only the .eq() function is supported for filtering. Not given the @property attribute so that filtering and pagination may be added as parameters
    auto getRows(string table, string pagination = "0-0", string[string] filter = ["#000nil000#":"#000nil000#"]) {
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
        auto x = get(restEndpoint ~ table ~ "?" ~ filters ~ "select=*", client);
        auto json = parseJSON(x).array();
        foreach (i, v; json) {
            v = v.object();
        }
        return json;
        //client.perform(endpoint ~ "/rest/v1/" ~ name ~ "?select=*", client);
    }
    ///Currently in progress. Will allow you to append one or more rows to the database table.
    @disable auto makeRows(string table, string[string] data ...) {

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
        auto x = get(LLendpoint ~ table ~ "?" ~ filters ~ "select=*", client);
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
Database init(string endpoint, string key, string name = "db") {
    auto xyz = new Database(endpoint, key, name);
    return xyz;
}