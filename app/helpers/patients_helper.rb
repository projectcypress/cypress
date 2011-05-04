module PatientsHelper
  def result_to_markup(included)
    if included
      '<img src="/images/pass.png"/>'
    else
      ''
    end
  end
end
