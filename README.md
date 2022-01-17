# dupabase
A D wrapper around the PostgREST API for [supabase](https://app.supabase.io)

not much else to it, it's my first D library I made that I think might be useful in the real world so I appreciate contributions and feedback

# Basic Example

```d
import dupabase;
import std.stdio;

auto key = import("key.txt");
void main() {
  auto db = newDB("something.supabase.co", key);
  writeln(db.getRows("test_table"));
  db.makeRows("test_table", true, ["id":"12345"]);
  db.updateRows("test_table", ["id":"1"], ["id":"2"]);
  db.deleteRows("test_table", ["id":"12345"]);
  writeln(db.getRow("test_table", 2));
}
```
