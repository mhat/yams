module YAMS
  module Util
    def Util.arrayify ( arg )
      return arg.is_a?(Array) ? arg : arg.nil?? [] : [arg] 
    end
  end
end
