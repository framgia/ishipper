class CheckParams
  attr_reader :args

  def initialize args
    @attributes_params = args[:attributes_params]
    @params = args[:params]
  end

  def perform?
    if @params.class.to_s != "ActionController::Parameters" || @params.nil?
      return false
    else
      @attributes_params.each do |attribute|
        return false unless @params.include? attribute
      end
    end
  end
end
