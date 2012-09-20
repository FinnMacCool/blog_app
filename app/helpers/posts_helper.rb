module PostsHelper
  
  def wrap(content)
    sanitize(raw(content.split.map{ |s| wrap_long_string(s) }.join(' ')))
  end
  
  def wrap_title(content)
    sanitize(raw(content.split.map{ |s| wrap_long_title_string(s) }.join(' ')))
  end

  private

    def wrap_long_string(text, max_width = 41)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
    
    def wrap_long_title_string(text, max_width = 21)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? text : 
                                  text.scan(regex).join(zero_width_space)
    end
end
