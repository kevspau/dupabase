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
## Features not implemented
- Log in with Magic Link via email
- Sign up with phone & password
- Login via SMS OTP (Requires twilio credentials)
- Verify login via SMS OTP (Requires twilio credentials)
- Reset password via email
- Update a users information
- Send a user an invite over email (Supabase note: This endpoint requires you use the `service_role_key` when initializing the client, and should only be invoked from the server, never from the client.)
