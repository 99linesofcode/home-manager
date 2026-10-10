# ActiveRecord (UUID keys, lean models)

Models use **UUID primary keys** (not auto-increment ints), matching the
modules. This drives the DTO `id` type (`String`, not `Integer`):

```ruby
# Model
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy
end

# Migration
create_table :posts, id: :uuid do |t|
  t.uuid :author_id, null: false
  t.string :title, null: false
  t.timestamps
end
```

Models are data + identity — no calculations, no business logic (see the skill
body). Scopes move to query objects; a computed value is calculated by an action
and stored, so reading it is plain data.
