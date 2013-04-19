module CleanUtf
  
   def self.append_features(base)
      super
      base.class_eval do
        before_save :clean_utf
      end 
    end 
    
    # Clean up any mal-formatted utf in any string fields
    def clean_utf
      attribute_names.each do |field|
        next unless self[field]
        next unless self[field].is_a? String
        next if field=='password_digest'
        self[field] = self[field].encode("UTF-8",:invalid=>:replace,:undef=>:replace,:replace=>"")
      end
    end
end
