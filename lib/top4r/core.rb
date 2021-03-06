# -*- encoding : utf-8 -*-
module Top4R
  # Core
  module ClassUtilMixin
    module ClassMethods
      
    end
    
    module InstanceMethods
      attr_accessor :raw
      
      def initialize(params = {})
        others = {}
        params.each do |key,val|
          if self.respond_to? key
            self.send("#{key}=", val)
          else
            others[key] = val
          end
        end
        self.send("raw=",params)
        self.send("#{:other_attrs}=", others) if self.respond_to? :other_attrs and others.size > 0
        self.send(:init) if self.respond_to? :init
      end
      
      protected
        def require_block(block_given)
          raise ArgumentError, "Must provide a block" unless block_given
        end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end # ClassUtilMixin module
  
  class RESTError < RuntimeError
    include ClassUtilMixin
    @@ATTRIBUTES = [:code, :message, :uri, :error, :sub_code, :sub_msg]
    attr_accessor *@@ATTRIBUTES

    # Returns string in following format:
    # "HTTP #{@code}: #{@message} at #{@uri}"
    # For example,
    # "HTTP 404: Resource Not Found at /i_am_crap.json"
    def to_s
      "HTTP #{@code}: #{@message} at #{@uri}, sub_code: #{@sub_code}, sub_msg: #{@sub_msg}"
    end
  end # RESTError
  
  class SuiteNotOrderedError < RESTError
    def to_s
      "错误代号#{@code}，您没有订购该服务！"
    end
  end
  
  class LoginRequiredError < RuntimeError
    include ClassUtilMixin
    @@ATTRIBUTES = [:model, :method]
    attr_accessor *@@ATTRIBUTES
    
    def to_s
      "#{@method} method at model #{@model} requires you to be logged in first"
    end
  end # LoginRequiredError

  class ShopNotExistError < RESTError
    include ClassUtilMixin
    @@ATTRIBUTES = [:model, :method]
    attr_accessor *@@ATTRIBUTES
    
    def to_s
      "#{@method} method at model #{@model} 错误,错误代号#{@code}，用户没有开通店铺！"
    end
  end # ShopNotExistError
end
