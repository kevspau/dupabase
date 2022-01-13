import std.net.curl, std.json;
import std.stdio, std.conv : to; //debugging
class Database {
    public string name;
    public HTTP client;
    private string key;
    private string endpoint;
    this(string endpointt, string keyy, string namee) {
        key = keyy;
        endpoint = endpointt;
        name = namee;
        client = HTTP(endpointt); //remove endpointt, find a way to manipulate url afterwards
    }
    @property void getRows() {
        client.clearRequestHeaders();
        client.addRequestHeader("apikey", key);
        client.addRequestHeader("Authorization", key);
        client.method = HTTP.Method.get;
        client.performget(endpoint ~ "/rest/v1/" ~ name ~ "?select=*", client);
    }
}
Database* init(string key, string endpoint, string name = "db1") {
    return new Database(endpoint, key, name);
}

void main() {
    auto x = init("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTY0MjA0MTQ0MSwiZXhwIjoxOTU3NjE3NDQxfQ.THriT1EqLkizCHPVaHb1Y1I6i2J-MuDQybYujVm6T2I", "https://ogkklizgscwqlkrfndpv.supabase.co", "hellow_world");
    writeln(to!string(x.getRows()));
}