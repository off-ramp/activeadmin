# frozen_string_literal: true
# This sets up aliases for old Metasearch query methods so they behave
# identically to the versions given in Ransack.
#
Ransack.configure do |config|
  { "contains" => "cont", "starts_with" => "start", "ends_with" => "end" }.each do |old, current|
    config.add_predicate old, Ransack::Constants::DERIVED_PREDICATES.detect { |q, _| q == current }[1]
  end

  { "equals" => "eq", "greater_than" => "gt", "less_than" => "lt" }.each do |old, current|
    config.add_predicate old, arel_predicate: current
  end

  config.add_predicate "gteq_datetime",
                       arel_predicate: "gteq",
                       formatter: ->(v) { v.beginning_of_day }

  config.add_predicate "lteq_datetime",
                       arel_predicate: "lt",
                       formatter: ->(v) { v + 1.day }


  Ransack::Adapters::ActiveRecord::Base.class_eval do
    def self.extended(base)
      # alias :search :ransack unless base.respond_to? :search
      base.class_eval do
        class_attribute :_ransackers
        class_attribute :_ransack_aliases
        self._ransackers ||= {}
        self._ransack_aliases ||= {}
      end
    end
  end
  
end

