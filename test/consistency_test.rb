require "test_helper"

class SequenceTest < BaseTest
  def test_single_sequence_consistency
    n = 200

    n.times do |current|
      FirstSequencedModel.create
      assert_sequence_value "first_sequenced_model_auto_increment", current + 1
    end

    assert_equal FirstSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_id_sequence_consistency
    n = 200

    n.times do |current|
      IdSequencedModel.create
      assert_sequence_value "id_sequenced_model__id", current + 1
    end

    assert_equal IdSequencedModel.only(:id).map(&:id).sort, (1..n).to_a
  end

  def test_double_sequence_consistency
    n = 100

    n.times do |current|
      FirstSequencedModel.create
      assert_sequence_value "first_sequenced_model_auto_increment", current + 1
      SecondSequencedModel.create
      assert_sequence_value "second_sequenced_model_auto_increment", current + 1
    end

    assert_equal FirstSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
    assert_equal SecondSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_prefix_sequence_consistency
    n = 100
    n.times do |current|
      PrefixSequencedModel.create(tenant_id: n)
      assert_sequence_value "prefix_sequenced_model_#{n}_auto_increment", current + 1
    end

    assert_equal PrefixSequencedModel.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_embedded_sequence_consistency
    n = 100
    m = 2
    first_parent_model = ParentModel.create
    second_parent_model = ParentModel.create
    n.times do |current|
      m.times do |current_child_count|
        first_parent_model.children.create
      end
      second_parent_model.children.create
      assert_sequence_value "secuenced_child_model_#{first_parent_model.id.to_s}_auto_increment", (current * m) + m
      assert_sequence_value "secuenced_child_model_#{second_parent_model.id.to_s}_auto_increment", current + 1
    end
    assert_equal first_parent_model.children.only(:auto_increment).map(&:auto_increment).sort, (1..(n*m)).to_a
    assert_equal second_parent_model.children.only(:auto_increment).map(&:auto_increment).sort, (1..n).to_a
  end

  def test_parent_level_consistency
    n = 100
    n.times do |current|
      FirstSubtypeModel.create
      assert_sequence_value "parent_model_auto_increment", (current * 2) + 1
      SecondSubtypeModel.create
      assert_sequence_value "parent_model_auto_increment", (current * 2) + 2
    end
    assert_equal FirstSubtypeModel.all.only(:auto_increment).map(&:auto_increment).sort, (1..n*2).select(&:odd?)
    assert_equal SecondSubtypeModel.all.only(:auto_increment).map(&:auto_increment).sort, (1..n*2).select(&:even?)
  end
end
