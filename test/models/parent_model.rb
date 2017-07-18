class ParentModel
  include Mongoid::Document
  include Mongoid::Sequence

  field :auto_increment

  embeds_many :children, class_name: 'SecuencedChildModel'
end
