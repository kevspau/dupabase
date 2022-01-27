<img src="https://github.com/csharpdf/dupabase/blob/main/YjAw.png"/>

# dupabase
A D wrapper around the PostgREST API for [supabase](https://app.supabase.io)

## Basic Example

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

## Current Progress

<table>
  <tr>
    <th>Rest API</th>
    <th>Auth</th>
    <th>Realtime</th>
  </tr>
  <tr>
  <td>Done</td>
  <td>In progress</td>
  <td>Not Done</td>
  </tr>
</table>
