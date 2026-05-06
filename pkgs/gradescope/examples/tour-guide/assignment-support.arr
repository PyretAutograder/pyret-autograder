provide: * end
provide: type * end

import string-dict as SD
provide from SD: *, type * end
import valueskeleton as VS
# import lists as L

string-dict = SD.string-dict
mutable-string-dict = SD.mutable-string-dict

newtype Graph as GraphT
is-Graph = GraphT.test

#|
   zespirit: All graph definitions
   jmcclel1: Updated is-graph-connected because the previous version only
     checked there were no isolated nodes but allowed graphs with larger
     disconnected components (i.e. A-B C-D was fine, only A-B C was not).
     Also added a separate check for bidirectionality, as this was rolled
     into the connectedness check, but actually only verified that every
     node was the neighbor of some other node so it didn't work either.
     (A -> B
      |    |
      C <- D) worked before as each node is listed as a neighbor of something.
     I think we now have functional connectedness and bidirectionality checks,
     though I apologize to future staffs if I'm wrong.
   Yay graph theory!
   Note: this code won't type check due to the use of valueskeleton, as that
     library doesn't type some things. Maybe see if there's another way to get
     things to print in the REPL?
|#

######################
## Data Definitions ##
######################

# The `Name` of a place is represented by a string.
type Name = String

# A `Point` is a classic, 2-dimensional position, represented by `x` and `y`.
data Point:
  | point(x :: Exactnum, y :: Exactnum)
sharing:
  method distance(self, other :: Point) -> Exactnum:
    doc: "Returns the Tour Guide distance between two Points."
    num-abs(self.x - other.x) + num-abs(self.y - other.y)
  end
end

# A `Place` has a name, position, and a list of neighboring places that are 
# reachable from it.
data Place:
  | place(
      name :: Name,
      position :: Point,
      neighbors :: Set<Name>)
sharing:
  method distance(self, other :: Place) -> Exactnum:
    doc: "Returns the Tour Guide distance between two Places."
    self.position.distance(other.position)
  end
end

# A `Path` is a list of place `Name`s.
type Path = List<Name>

# A Tour has a title and a set of stops to visit on the tour.
data Tour:
  | tour(title :: String, stops :: Set<Name>)
end

######################
## Helper Functions ##
######################

fun merge-components(p1 :: Name, p2 :: Name, components :: Set<Set<Name>>):
  doc: "Merges the components containing p1 and p2"
  fun get-component(p :: Name, c :: List<Set<Name>>) -> Set<Name>:
    doc: "Locates the component containing p"
    cases (List) c:
      | empty => raise("Component not found")
      | link(f, r) =>
        if f.member(p):
          f
        else:
          get-component(p, r)
        end
    end
  end
  lc = components.to-list()
  # finds the components, gets all others, and adds the union of the found ones
  c1 = get-component(p1, lc)
  c2 = get-component(p2, lc)
  others = components.difference([set: c1, c2])
  others.add(c1.union(c2))
  #|where:
  merge-components("a", "b", [set: [set: "a", "n", "c"], [set: "d", "b"], [set: "e", "f", "g"]])
    is [set: [set: "a", "n", "c", "d", "b"], [set: "e", "f", "g"]]
  merge-components("b", "e", [set: [set: "a"], [set: "b"], [set: "c"], [set: "d"], [set: "e"]])
    is [set: [set: "a"], [set: "b", "e"], [set: "c"], [set: "d"]]
  merge-components("b", "e", [set: [set: "a"], [set: "b", "e"], [set: "c"], [set: "d"]])
    is [set: [set: "a"], [set: "b", "e"], [set: "c"], [set: "d"]]|#
end

fun to-graph(vertices :: Set<Place>) -> Graph:
  doc: "Given a set of places, converts the Places to a Graph representation."

  fun are-place-names-unique() -> Boolean:
    doc: ```Returns true if all of the names of Places in the input Set<Place> 
         are unique; otherwise, returns false.```
    place-names  = vertices.to-list().map(_.name)
    set-of-names = lists.distinct(place-names)
    place-names.length() == set-of-names.length()
  end
  
  fun contains-no-self-references() -> Boolean:
    doc: ```Returns true if the graph contains no self references; otherwise,
         returns false.```
    not(vertices.to-list().any({(p :: Place): p.neighbors.member(p.name) }))
  end

  fun is-graph-connected() -> Boolean:
    doc: ```Returns true if the input Set<Place> represents a connected graph;
         otherwise, returns false.```
    init-comps = list-to-list-set(vertices.to-list().map(lam(p): [set: p.name] end))
    comps = vertices.fold(
      lam(c, p1): p1.neighbors.fold(
          lam(shadow c, p2): merge-components(p1.name, p2, c) end, 
        c) end, init-comps)
    comps.size() <= 1
  end
  
  fun is-graph-bidirected():
    doc: ```Verifies that the graph is bidirected: if A is a neighbor of B,
         B is a neighbor of A```
    init-dict = vertices.fold(lam(d, p): d.set(p.name, empty-list-set) end, [string-dict: ])
    expected-sets = vertices.fold(lam(d, p):
        p.neighbors.fold(
          lam(shadow d, n): d.set(n, d.get-value(n).add(p.name)) end,
        d) end, init-dict)
    lists.all(lam(p): expected-sets.get-value(p.name) == p.neighbors end, vertices.to-list())
  end

  if not(are-place-names-unique()) 
    or not(contains-no-self-references())
    or not(is-graph-connected())
    or not(is-graph-bidirected()):
    raise("Invalid graph!")
  else:
    sd = [mutable-string-dict: ]
    _  = vertices.to-list().each({(p :: Place): sd.set-now(p.name, p)})

    GraphT.brand(
      { 
        method get(self, name :: String) -> Place:
          doc: "Produces the `Place` in the graph with the given `name`."
          sd.get-value-now(name)
        end,

        method names(self) -> Set<Name>:
          doc: "Produces the set of `Name`s in the graph."
          list-to-set(sd.keys-now().to-list())
        end,

        method _output(self):
          doc: "Internal, cool stuff for printing this type in the REPL."
          
          VS.vs-collection("Graph",  vertices.to-list().map(VS.vs-value))
        end
      })
  end
end


## data used in tests

tg-loc-A = place("tg-loc-A", point(0, 0), [set: "tg-loc-B"])
tg-loc-B = place("tg-loc-B", point(0, 1), [set: "tg-loc-A", "tg-loc-C"])
tg-loc-C = place("tg-loc-C", point(0, 2), [set: "tg-loc-B", "tg-loc-D"])
tg-loc-D = place("tg-loc-D", point(0, 3), [set: "tg-loc-C", "tg-loc-E"])
tg-loc-E = place("tg-loc-E", point(0, 4), [set: "tg-loc-D"])

# graph = [list: tg-loc-A,tg-loc-B,tg-loc-C,tg-loc-D,tg-loc-E]
