module PatientsHelper
  def result_to_markup(included)
    if included
      '<img src="/images/pass.png"/>'
    else
      ''
    end
  end
  def result_to_class(included)
    if included
      'class="p"'
    else
      ''
    end
  end
  
  def code_display(code_hash)
    code_hash.map {|code_set, codes| "#{code_set}: #{codes.join(', ')}"}.join(' ')
  end
end
