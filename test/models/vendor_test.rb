require 'test_helper'

class VendorTest < MiniTest::Test
  def setup
    Vendor.all.destroy
  end

  def test_new_vendor_can_be_made
    assert Vendor.new(name: 'test_vendor_name')
  end

  def test_vendor_can_be_created
    v = Vendor.new(name: 'test_vendor_name')
    assert v.save!
  end

  def test_vendor_no_name_cannot_be_saved
    v = Vendor.new
    assert_raises Mongoid::Errors::Validations do
      v.save!
    end
  end

  def test_vendor_same_name_cannot_be_saved
    name = 'I have the same name!'
    v1 = Vendor.new(name: name)
    v2 = Vendor.new(name: name)
    v1.save!
    assert_raises Mongoid::Errors::Validations do
      v2.save!
    end
  end

  def test_vendor_with_poc_can_be_saved
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new(name: 'test_poc_name')
    p.vendor = v
    assert v.save!
  end

  def test_vendor_with_multiple_pocs_can_be_saved
    v = Vendor.new(name: 'test_vendor_name')
    p1 = PointOfContact.new(name: 'poc1')
    p2 = PointOfContact.new(name: 'poc2')
    p1.vendor = v
    p2.vendor = v
    assert v.save!
  end

  def test_vendor_with_poc_with_no_name_cannot_be_saved
    v = Vendor.new(name: 'test_vendor_name')
    p = PointOfContact.new
    p.vendor = v
    assert_raises Mongoid::Errors::Validations do
      assert v.save!
    end
  end

  def test_vendor_with_pocs_with_same_name_cannot_be_saved
    poc_name = 'I have the same name!'
    v = Vendor.new(name: 'test_vendor_name')
    p1 = PointOfContact.new(name: poc_name)
    p2 = PointOfContact.new(name: poc_name)
    p1.vendor = v
    p2.vendor = v
    assert_raises Mongoid::Errors::Validations do
      assert v.save!
    end
  end
end

class VendorCachingTest < CachingTest
  def test_vendor_status_and_product_groups_are_not_cached_on_start
    assert !Rails.cache.exist?("#{@vendor.cache_key}/status"), 'cache key for vendor status should not exist'
    assert !Rails.cache.exist?("#{@vendor.cache_key}/products_passing"), "cache key for vendor's passing products should not exist"
    assert !Rails.cache.exist?("#{@vendor.cache_key}/products_failing"), "cache key for vendor's failing products should not exist"
    assert !Rails.cache.exist?("#{@vendor.cache_key}/products_incomplete"), "cache key for vendor's incomplete products should not exist"
  end

  def test_vendor_status_is_cached_after_checking_status
    @vendor.status
    assert Rails.cache.exist?("#{@vendor.cache_key}/status"), 'cache key for vendor status should exist'
  end

  def test_product_groups_are_cached_after_checking_each
    @vendor.products_passing
    @vendor.products_failing
    @vendor.products_incomplete
    assert Rails.cache.exist?("#{@vendor.cache_key}/products_passing"), "cache key for vendor's passing products should exist"
    assert Rails.cache.exist?("#{@vendor.cache_key}/products_failing"), "cache key for vendor's failing products should exist"
    assert Rails.cache.exist?("#{@vendor.cache_key}/products_incomplete"), "cache key for vendor's incomplete products should exist"
  end

  def test_adding_test_execution_updates_vendor_cache_key
    vendor_old_cache_key = "#{Vendor.all.first.cache_key}"
    task_2 = C2Task.new
    task_2.product_test = @product_test
    task_2.save!
    test_execution_2 = TestExecution.new
    test_execution_2.task = task_2
    test_execution_2.save!
    vendor_new_cache_key = "#{Vendor.all.first.cache_key}"
    refute_equal vendor_old_cache_key, vendor_new_cache_key, 'cache keys should be different'
  end

  def test_edditing_test_execution_updates_vendor_cache_key
    vendor_old_cache_key = "#{Vendor.all.first.cache_key}"
    test_execution = TestExecution.all.first
    test_execution.update_attribute(:state, :passed)
    test_execution.save!
    vendor_new_cache_key = "#{Vendor.all.first.cache_key}"
    refute_equal vendor_old_cache_key, vendor_new_cache_key, 'cache keys should be different'
  end

  def test_adding_passing_then_failing_execution_changes_vendor_status
    test_execution = TestExecution.all.first
    test_execution.update_attribute(:state, :passed)
    test_execution.save!
    vendor_old_status = Vendor.all.first.status

    task_2 = C2Task.new
    task_2.product_test = @product_test
    task_2.save!
    test_execution_2 = TestExecution.new
    test_execution_2.task = task_2
    test_execution_2.state = :failing
    test_execution_2.save!
    vendor_new_status = Vendor.all.first.status

    refute_equal vendor_old_status, vendor_new_status, "vendor's status should change from passing to failing"
  end
end
