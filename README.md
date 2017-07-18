# Mongoid Sequence

Mongoid Sequence allows you to specify fields to behave like a sequence number (exactly like the "id" column in conventional SQL flavors).

## Credits

This gem was inspired by a couple of gists by [masatomo](https://gist.github.com/730677) and [ShogunPanda](https://gist.github.com/1086265).

## Usage

Include `Mongoid::Sequence` in your class and call `sequence(:field)`.

Like this:

```ruby
class Sequenced
	include Mongoid::Document
	include Mongoid::Sequence

	field :my_sequence, :type => Integer
	sequence :my_sequence
end

s1 = Sequenced.create
s1.sequence #=> 1

s2 = Sequenced.create
s2.sequence #=> 2 # and so on
```

It is possible to add an additional discriminator to the sequence (e.g. a tenant id)
```ruby
class Sequenced
	include Mongoid::Document
	include Mongoid::Sequence

  field :my_sequence, :type => Integer
  belongs_to :organization

	sequence :my_sequence, prefix: :organization_id
end
```

If you have an embedded document, you don't have worrying about fake increment inside each child, mongoid-secuence will recognize this association and segregate the count per each child
```ruby
class Sequenced
	include Mongoid::Document
	include Mongoid::Sequence

  field :my_sequence, :type => Integer

  embedded_in :parent

	sequence :my_sequence
end
```

If you have an inheritance relation and you want to keep the sequence associated with one of your parents, you
can specify what ancestors level you want using the parent_level option, below scenario will keep the sequence
called parent_my_sequence sequence for Child instances
```ruby
class Parent
	include Mongoid::Document
	include Mongoid::Sequence

  field :my_sequence, :type => Integer
end

class Child
	include Mongoid::Document
	include Mongoid::Sequence

  sequence :my_sequence, parent_level: 1
end
```

It's also possible to make the `id` field behave like this:

```ruby
class Sequenced
	include Mongoid::Document
	include Mongoid::Sequence

	sequence :_id
end

s1 = Sequenced.create
s1.id #=> 1

s2 = Sequenced.create
s2.id #=> 2 # and so on
```

## Consistency

Mongoid::Sequence uses the atomic [findAndModify](http://www.mongodb.org/display/DOCS/findAndModify+Command) command, so you shouldn't have to worry about the sequence's consistency.

## Installation

Just add it to your projects' `Gemfile`:

```ruby
gem "mongoid-sequence"
```

<hr/>

Copyright © 2017 Gonçalo Silva, Johan Tique released under the MIT license
