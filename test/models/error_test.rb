require 'test_helper'

class ErrorTest < ActiveSupport::TestCase

  context "model attributes" do
    setup do
      @error = FactoryGirl.create(:error)
    end

    should "have right fields" do
      @error.status
    end

    should "default status to active" do
      assert @error.active?
    end
  end

  context "model validations" do
    setup do
      @error = FactoryGirl.create(:error)
    end

    should "force backtrace_hash to be unique" do
      @second_error = FactoryGirl.create(:error)
      @second_error.backtrace = @error.backtrace
      assert_not @second_error.valid?
    end
  end

  context "model linkages" do
    setup do
      @error = FactoryGirl.create(:error)
    end

    should "have correct relations" do
      @error.error_occurrences
    end

    should "have counter cache for occurrences" do
      assert_difference '@error.reload.occurrence_count', 1 do
        @error.error_occurrences.create
      end
    end

    should "set the last experiencer to the last occurrence's user" do
      @occ1 = @error.error_occurrences.create(experiencer: users(:user))
      @occ2 = @error.error_occurrences.create(experiencer: users(:user2))
      assert_equal @occ2.reload.experiencer, @error.reload.last_experiencer
    end
  end

  context "methods" do
    setup do
      @error = FactoryGirl.create(:error)
    end

    should "compute correct users affected" do
      @occ1 = @error.error_occurrences.create(experiencer: users(:user))
      assert_equal @error.affected_users, [users(:user)]
      @occ2 = @error.error_occurrences.create(experiencer: users(:user2))
      assert_equal @error.affected_users, [users(:user), users(:user2)]
      @occ2 = @error.error_occurrences.create(experiencer: users(:user2))
      assert_equal @error.affected_users, [users(:user), users(:user2)]
    end

    should "get oldest occurrence" do
      @occ1 = @error.error_occurrences.create(experiencer: users(:user))
      @occ2 = @error.error_occurrences.create(experiencer: users(:user), created_at: 1.week.ago)
      @occ3 = @error.error_occurrences.create(experiencer: users(:user2))
      assert_equal @error.oldest_occurrence, @occ2
    end

    should "get newest occurrence" do
      @occ1 = @error.error_occurrences.create(experiencer: users(:user))
      @occ2 = @error.error_occurrences.create(experiencer: users(:user), created_at: 1.week.ago)
      @occ3 = @error.error_occurrences.create(experiencer: users(:user2))
      assert_equal @error.newest_occurrence, @occ3
    end
  end

end
