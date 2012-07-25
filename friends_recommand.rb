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

def suggestions_for(node)
  @neo.traverse(node,
                "nodes",
                {"order" => "breadth first",
                 "uniqueness" => "node global",
                 "relationships" => {"type"=> "friends",
                                     "direction" => "in"},
                 "return filter" => {"language" => "javascript",
                                     "body" => "position.length() == 2;"},
                 "depth" => 2}).map{|n| n["data"]["name"]}.join(', ')
end

mehdi    = create_person('Mehdi')
kevin    = create_person('Kevin')
antoine  = create_person('Antoine')
marie    = create_person('Marie')
foof     = create_person('Foof')
clement     = create_person('Clement')

make_mutual_friends(mehdi, kevin)
make_mutual_friends(kevin, marie)
make_mutual_friends(kevin, foof)
make_mutual_friends(marie, foof)
make_mutual_friends(mehdi, antoine)
make_mutual_friends(kevin, antoine)
make_mutual_friends(mehdi, clement)

puts "Mehdi should become friends with #{suggestions_for(mehdi)}"