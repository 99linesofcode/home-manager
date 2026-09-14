# Models & migrations (UUIDs)

Models use **UUID primary keys** (not auto-increment ints), matching the news
module. This drives the DTO `id` type (`?string`, not `?int`):

```php
// Model
use Illuminate\Database\Eloquent\Concerns\HasUuids;
class Todo extends Model
{
    use HasFactory, HasUuids;
}

// Migration
Schema::create('todos', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('assignee_id')->nullable()->constrained('users')->nullOnDelete();
    // ...
});
```
