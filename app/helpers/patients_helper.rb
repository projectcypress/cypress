module PatientsHelper
  
  def result_to_markup(included)
    if included
      '<img src="/assets/pass.png"/>'
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
end
