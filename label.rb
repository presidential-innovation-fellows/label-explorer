


class OppLabel
  def initialize(registration_id,pdf_content)
    @registration_id = registration_id
    @pdf_content = pdf_content
  end

  attr_accessor :registration_id
  attr_accessor :pdf_content

end