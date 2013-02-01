module PreventScriptAttacks
  
    def self.append_features(base)
      super
      base.class_eval do
        before_save :prevent_script_attacks
      end 
    end 
    
    # Escapes anything significant to html in all text fields
    def prevent_script_attacks
      attribute_names.each do |field|
        next unless self[field]
        next unless self[field].is_a? String
        next if exclude_from_xss_checks.include?(field)
        self[field] = self[field].gsub(/&(?!amp;|quot;|lt;|gt;)/, '&amp;').gsub(/\"/, '&quot;').gsub(/>/, '&gt;').gsub(/</, '&lt;')
      end
    end
    
    # If defined in the class then this won't be included
    def exclude_from_xss_checks
      []
    end
end
