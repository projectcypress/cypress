module UsersHelper
  def options_for_owner_vendor
    options_for_select([%w[Owner owner], %w[Vendor vendor]])
  end
end
