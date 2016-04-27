module Helpers
  def element_position_by_id(id)
    script = "function() {" + \
      "var ele  = document.getElementById('#{id}');" + \
      '''
      var rect = ele.getBoundingClientRect();
      return [rect.left, rect.top];
      }();
      '''
    page.driver.evaluate_script(script)
  end
end