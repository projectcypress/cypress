module VendorsHelper
  def formatted_vendor_address(vendor)
    statezip = formatted_vendor_statezip(vendor)

    if statezip
      address = vendor.address? ? "#{vendor.address}, #{statezip}" : statezip
    elsif vendor.address != ''
      address = vendor.address.to_s
    end

    address || nil
  end

  def formatted_vendor_statezip(vendor)
    if vendor.state? && vendor.zip?
      statezip = "#{vendor.state.upcase}, #{vendor.zip}"
    else
      statezip = vendor.zip.to_s if vendor.zip?
      statezip = vendor.state.upcase.to_s if vendor.state?
    end

    statezip || nil
  end
end
