require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

def create_person(name)
  @neo.create_node("name" => name)
end

def make_mutual_friends(node1, node2)
  @neo.create_relationship("friends", node1, node2)
  @neo.create_relationship("friends", node2, node1)
end

def degrees_of_separation(start_node, destination_node)
  paths =  @neo.get_paths(start_node,
                          destination_node,
                          {"type"=> "friends", "direction" => "in"},
                          depth=4,
                          algorithm="allSimplePaths")
  paths.each do |p|
   p["names"] = p["nodes"].collect { |node|
     @neo.get_node_properties(node, "name")["name"] }
  end
end

mehdi    = create_person('Mehdi')
kevin    = create_person('Kevin')
antoine  = create_person('Antoine')
marie    = create_person('Marie')
foof     = create_person('Foof')
clement  = create_person('Clement')

make_mutual_friends(mehdi, kevin)
make_mutual_friends(kevin, marie)
make_mutual_friends(kevin, foof)
make_mutual_friends(marie, foof)
make_mutual_friends(mehdi, antoine)
make_mutual_friends(kevin, antoine)
make_mutual_friends(mehdi, clement)

degrees_of_separation(mehdi, marie).each do |path|
  puts "#{(path["names"].size - 1 )} degrees: " + path["names"].join(' => friends => ')
end

# Output
# 2 degrees: Mehdi => friends => Kevin => friends => Marie
# 3 degrees: Mehdi => friends => Kevin => friends => Foof => friends => Marie
# 3 degrees: Mehdi => friends => Antoine => friends => Kevin => friends => Marie
# 4 degrees: Mehdi => friends => Antoine => friends => Kevin => friends => Foof => friends => Marie