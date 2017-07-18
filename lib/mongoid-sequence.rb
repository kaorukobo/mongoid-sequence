require "mongoid-sequence/version"
require "active_support/concern"

module Mongoid
  module Sequence
    extend ActiveSupport::Concern

    included do
      set_callback :validate, :before, :set_sequence, :unless => :persisted?
    end

    module ClassMethods
      attr_accessor :sequence_fields, :sequence_prefix, :sequence_parent_level

      def sequence(field, options = {})
        self.sequence_fields ||= []
        self.sequence_fields << field
        self.sequence_prefix = options[:prefix]
        self.sequence_parent_level = options[:parent_level]
      end
    end

    def set_sequence
      sequences = self.mongo_client['__sequences']
      prefix    = self.class.sequence_prefix.present? ? self.send(self.class.sequence_prefix).to_s : ''
      klass = if self.class.sequence_parent_level.present?
        (self.class.ancestors - self.class.included_modules)[self.class.sequence_parent_level]
      else
        self.class
      end
      self.class.sequence_fields.each do |field|
        embedded_relation_id = self.embedded? ? self._parent.id.to_s : nil
        sequence_name = [klass.name.underscore, embedded_relation_id, prefix, field].select { |f| !f.blank? }.join("_")
        next_sequence = if sequences.find(_id: sequence_name).count.zero?
          sequences.insert_one _id: sequence_name, seq: 1
          sequences.find(_id: sequence_name).first
        else
          sequences.find_one_and_update({ _id: sequence_name }, { '$inc' => { seq: 1 } }, :return_document => :after )
        end
        self[field] = next_sequence["seq"]
      end if self.class.sequence_fields
    end
  end
end
