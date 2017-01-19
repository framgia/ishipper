class Simples::BaseSimple
  def initialize args
    @object = args[:object]
    @class_name = args[:class_name]
    @scope = args[:scope]

    if @scope
      @scope.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end
  end

  def simple
    simples = Array.new
    superclass = @object.class.superclass
    if superclass == ActiveRecord::Relation || superclass.superclass == ActiveRecord::Relation
      if @object.empty?
        simples = []
      else
        class_name = if @class_name
          @class_name
        elsif self.class == Simples::BaseSimple
          "Simples::BaseSimple"
          super_class = @object.first.class
          while super_class != ApplicationRecord do
            sub_class = super_class
            super_class = super_class.superclass
          end
          "Simples::#{sub_class.to_s.pluralize}Simple"
        else
          self.class.to_s
        end

        @object.each do |object|
          object_simple = class_name.constantize.new object: object, scope: @scope
          simple = object_simple.simple
          simples << simple
        end
      end
    else
      simples = Hash.new
      self.attributes.each do |attribute|
        instance_variable_set "@#{attribute}", @object.try(attribute)
      end
      self.attributes.each do |method|
        simples[method.to_sym] = self.send method
      end
      if self.class.attributes
        self.class.attributes.each do |method|
          simples[method.to_sym] = self.send method
        end
      end

      self.class.condition.each do |key, value|
        unless self.send value
          simples.delete key
        end
      end
    end
    simples
  end

  def attributes
    attributes = self.class.attributes
    attributes = [] unless attributes
    superclass = self.class.superclass
    while superclass != Simples::BaseSimple do
      attributes += superclass.attributes
      superclass = superclass.superclass
    end
    attributes
  end

  class << self
    def attr_accessor *vars
      @attributes ||= []
      @condition ||= Hash.new
      attr_var = []
      vars.each_with_index.map do |var, i|
        if vars[i+1] && vars[i+1].class == Hash
          @condition["#{vars[i]}".to_sym] = vars[i+1][:if]
          attr_var.push vars[i+1]
        end
      end
      vars -= attr_var
      @attributes.concat vars
      super *vars
    end

    def attributes
      @attributes ||= Array.new
    end

    def condition
      @condition ||= Array.new
    end
  end
end
