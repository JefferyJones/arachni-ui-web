=begin
    Copyright 2012 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

class RedundantInput < SimpleForm::Inputs::Base
    def input
        pp input_html_options
        pp attribute_name
        pp options
        s = <<-HMTL
            #{@builder.text_field( attribute_name, input_html_options )}
            #{@builder.text_field( attribute_name, input_html_options )}
        HMTL
        s.html_safe
    end
end