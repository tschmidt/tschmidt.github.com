require 'liquid'
require 'coderay'

class AwesomeCodeblock < Liquid::Block
  
  attr_accessor :title, :language, :markup, :options, :code
  
  def initialize(tag_name, markup, tokens)
    @markup = markup
    super
  end
  
  def render(context)
    @code = super
    output = ''
    output += header
    output += tableized_code(code)
    output += footer
    output
  end
  
  private
  
  def header
    %Q[<figure class="#{css_classes.join(' ')}">#{wrapped_title}<div class="CodeRay"><table class="code">]
  end
  
  def wrapped_title
    return '' unless title
    %Q[<figcaption class="code-header"><span>#{title}</span></figcaption>]
  end
  
  def title
    @title = (markup =~ /\s*title:"([^"]+)"/i) ?  $1 : nil
  end
  
  def footer
    %q[</table></div></figure>]
  end
  
  def tableized_code(code)
    lines = ''
    wrapped_code = ''
    code.strip.split("\n").each_with_index do |line, index|
      index += starting_line_number
      line = line.empty? ? "&nbsp" : CodeRay.scan(line, language.to_sym).html
      lines        += %Q[<div class="line-number#{' highlight' if lines_to_highlight && lines_to_highlight.include?(index)}">#{index}</div>]
      wrapped_code += %Q[<div class="code-part#{' highlight' if lines_to_highlight && lines_to_highlight.include?(index)}">#{line}</div>]
    end
    tr_str do
      ''.tap do |str|
        str << %Q[<td class="gutter">#{lines}</td>] if show_line_numbers?
        str << %Q[<td class="lines-of-code"><pre>#{wrapped_code}</pre></td>]
        str
      end
    end
  end
  
  def tr_str
    %Q[<tbody><tr>#{yield}</tr></tbody>]
  end
  
  def language
    @language = (markup =~ /\s*lang(?:uage)?:['"]?([^"'\s]+)*['"]?/i) ? $1 : 'text'
  end
  
  def css_classes
    ['code', language].compact
  end
  
  def show_line_numbers?
    show_line_numbers || lines_to_highlight || starting_line_number > 1
  end
  
  def show_line_numbers
    (markup =~ /\s*show_line_numbers:['"]?([^"'\s]+)['"]?/i) ? true : false
  end
  
  def lines_to_highlight
    (markup =~ /\s*highlight:['"]?([^"'\s]+)*['"]?/i) ? $1.split(/, ?/).map(&:to_i) : false
  end
  
  def starting_line_number
    (markup =~ /\s*start_at:['"]?([^"'\s]+)['"]?/i) ? $1.to_i : 1
  end
  
end

Liquid::Template.register_tag('awesome_codeblock', AwesomeCodeblock)