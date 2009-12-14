class ActiveResource::Base
  include Winch::Base

  def initialize_with_winch(attributes)
    initialize_winch(attributes)
    initialize_without_winch(attributes).tap { preform_type_check }
  end

  alias_method_chain :initialize, :winch
end