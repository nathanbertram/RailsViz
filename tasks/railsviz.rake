namespace :railsviz do
  desc "RailsViz: Visualize models and respective relationships using Graphviz [graphviz.org]"
  task :models_and_relationships => :environment do
    superclasses = [ActiveRecord::Base]
    file_output = "#{RAILS_ROOT}/tmp/simpleviz_#{Time.now.to_i}.png"
    graph = GraphViz::new(:G, :type => :digraph) do |g|
      g.node[:fontsize] = "12"
      g.node[:shape] = "Mrecord"
      
      Dir.glob("#{RAILS_ROOT}/app/models/*rb") do |f|
        klassname = f.match(/\/([a-zA-Z_]+).rb/)[1].camelize
        klass = Kernel.const_get klassname
        if superclasses.include?(klass.superclass)
          g.send(klassname)
          klass.reflect_on_all_associations.each do |a|
            g.add_edge(klassname, a.name.to_s.camelize.singularize, :label => a.macro)
          end
        end
      end
    end
    graph.output(:png => file_output)
    puts "Successfully generated: #{file_output}"
    `open #{file_output}`
  end
end


# TODO:
# 1. Make arrows bidirectional in one line where applicable  
# 2. Bold class names
# 3. Color code protect_methods and acessible_methods

# WISHLIST:
# 1. Draw arrows from attribute (ie. from User.user_id ---> Address)

namespace :railsviz do
  desc "RailsViz: Visualize models and respective relationships WITH attributes using Graphviz [graphviz.org]"
  task :models_and_relationships_with_attributes => :environment do
    superclasses = [ActiveRecord::Base]
    file_output = "#{RAILS_ROOT}/tmp/simpleviz_#{Time.now.to_i}.png"
    graph = GraphViz::new(:G, :rankdir => "LR", :type => :digraph) do |g|
      g.node[:fontsize] = "12"
      g.node[:shape] = "Mrecord"
      
      Dir.glob("#{RAILS_ROOT}/app/models/*rb") do |f|
        klassname = f.match(/\/([a-zA-Z_]+).rb/)[1].camelize
        klass = Kernel.const_get klassname
        if superclasses.include?(klass.superclass)
          g.send(klassname, :label => "#{klassname}|#{klass.new.attributes.keys.join(" | ")}")
          klass.reflect_on_all_associations.each do |a|
            g.add_edge(klassname, a.name.to_s.camelize.singularize, :label => a.macro)
          end
        end
      end
    end
    graph.output(:png => file_output)
    puts "Successfully generated: #{file_output}"
    `open #{file_output}`
  end
end