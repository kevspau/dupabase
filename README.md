# dupabase
A D wrapper around the PostgREST API for [supabase](https://app.supabase.io)

not much else to it, it's my first D library I made that I think might be useful in the real world so I appreciate contributions and feedback

# Basic Example
As of writing this, dupabase only has the ability to get data, not post it.

```d
import dupabase;
import std.stdio;

auto key = import("key.txt")
void main() {
  auto db = init("something.supabase.co", key);
  writeln(db.getRows("test_table"));
}
```
